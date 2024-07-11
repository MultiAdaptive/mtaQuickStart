#!/bin/bash

# bin path
MULTIADAPTIVE_BIN=$(pwd -P)

# the bash home path
MULTIADAPTIVE_HOME_PATH=${MULTIADAPTIVE_BIN%/bin}

# lib path
DOMICON_ENV="${DOMICON_HOME_PATH}/env"

DOMICON_PKG="${DOMICON_HOME_PATH}/packages"

#root path
ROOT_PATH="/home/ubuntu/"

CHAIN_INFO_FILE=""
CHAIN_CONF_DIR=""
CHAIN_DATA_DIR=""

# MultiAdaptive broadcast node ,MultiAdaptive storage node
# value  "b"  match the node type is MultiAdaptive broadcast node
# value  "s" match the node type is MultiAdaptive storage node
NODETYPE="b"

ChainID=11155111

# join or create chain
TYPE=""

P2P_PORT=

BOOTNODEINFO=

L1Url=

#btc scan host
BTCHost=""

BTCUser=""

BTCPWD=""

BTCPriv=""

CHAINTYPE=


read_chain_conf() {
    first_folder=$(find $MULTIADAPTIVE_HOME_PATH/conf -mindepth 1 -maxdepth 1 -type d -print -quit)
    first_folder_name=$(basename "$first_folder")
    CHAIN_CONF_DIR=$MULTIADAPTIVE_HOME_PATH/conf/$first_folder_name
    CHAIN_DATA_DIR=$MULTIADAPTIVE_HOME_PATH/chain/$first_folder_name/data
    echo "read chain config in $CHAIN_CONF_DIR"
    CHAIN_INFO_FILE=$MULTIADAPTIVE_HOME_PATH/conf/$first_folder_name/chain-info.properties
    
    if [ -f "$CHAIN_INFO_FILE" ];then
        while IFS='=' read -r key value
        do
            key=$(echo $key | tr '.' '_')
            eval ${key}=\${value}
        done < "$CHAIN_INFO_FILE"
    else
        echo "$CHAIN_INFO_FILE not found, existing."
        exit 0
    fi
    
}


start_geth() {
    echo "getting start with geth...."

    cd $MULTIADAPTIVE_BIN
    
    nohup ./geth --datadir $CHAIN_DATA_DIR --http --http.corsdomain=* --http.vhosts=* --http.addr=0.0.0.0 --http.api=eth,net --ws --ws.addr=0.0.0.0 --ws.origins=* --ws.api=eth,net--syncmode=full --gcmode=archive --maxpeers=10  --authrpc.vhosts=*  --l1Url $L1Url --password $CHAIN_DATA_DIR/keystore/.password.txt --bootnodes $BOOTNODEINFO >> $CHAIN_DATA_DIR/geth.log 2>&1 &
    
    pidFile="$CHAIN_CONF_DIR/geth.pid"
    if [ ! -f $pidFile ];then
         touch $pidFile
    fi

    echo $! > $pidFile
    echo "geth is started. pid is written into $pidFile."
    echo
}

start_btc() {
    echo "getting start with btc...."

    cd $MULTIADAPTIVE_BIN
    
    nohup ./geth --datadir $CHAIN_DATA_DIR --http --http.corsdomain=* --http.vhosts=* --http.addr=0.0.0.0 --http.api=eth,net --ws --ws.addr=0.0.0.0 --ws.origins=* --ws.api=eth,net--syncmode=full --gcmode=archive --maxpeers=10 --l1Host $BTCHost --l1User $BTCUser --l1Password $BTCPWD --nodeType $NODETYPE --btcPrivate $BTCPriv --chainName bitcoin  --networkid=$ChainID --bootnodes $BOOTNODEINFO >> $CHAIN_DATA_DIR/geth.log 2>&1 &
    
    pidFile="$CHAIN_CONF_DIR/geth.pid"
    if [ ! -f $pidFile ];then
         touch $pidFile
    fi

    echo $! > $pidFile
    echo "geth is started. pid is written into $pidFile."
    echo


}


# write bootnodes file
write_bootnodes_file() {
    echo "find self bootnode info from log."
    
    bootnodeFile="$CHAIN_CONF_DIR/bootnode.txt"
    if ! test -e $bootnodeFile;then
         touch $bootnodeFile
    fi

    i=1
    while true
    do
        num_bootnodes=`grep -c 'Started P2P networking' $CHAIN_DATA_DIR/geth.log`
        if [ $num_bootnodes -ne 0 ];then
            bootnode=`grep 'Started P2P networking' $CHAIN_DATA_DIR/geth.log`
            bootnode=`echo $bootnode | cut -d '=' -f 2 | cut -d ' ' -f 2`
            ips=0
            for i in `ifconfig | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | grep -v '127\|255\|0.0.0.0'`;do
            if [ $ips -eq 0 ];then
              modified=$(echo "$bootnode" | sed "s/@[^:]*:/@$i:/")
              echo -n "$modified" >> $bootnodeFile;
            else
              modified=$(echo "$bootnode" | sed 's/@[^:]*:/@"$i":/')
              echo -n "$modified" >> $bootnodeFile;
            fi
            let ips++
            done
            break
        else
         i=`expr ${i} + 1`
         if [ $i -gt 7 ];then
            echo  "can not find bootnode info, utopia start may have failed, please check $CHAIN_DATA_DIR/geth.log"
            break
         else
            sleep 1
         fi
    fi
    done
}


main() {
    read_chain_conf
    if [ "$CHAINTYPE" == "eth" ];then
        start_geth
    else
        start_btc
    fi
    write_bootnodes_file
}

main
