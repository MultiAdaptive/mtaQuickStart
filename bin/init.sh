#!/bin/bash

# init env or getting start
ACTION="init env"

# join or create chain
TYPE=""

# bin path
MULTIADAPTIVE_BIN=$(pwd -P)

# the bash home path
MULTIADAPTIVE_HOME_PATH=${MULTIADAPTIVE_BIN%/bin}


#root path
ROOT_PATH="/home/ubuntu/"

CHAIN_INFO_FILE=""
CHAIN_CONF_DIR=""
CHAIN_DATA_DIR=""

# MultiAdaptive broadcast node ,MultiAdaptive storage node
# value  "b"  match the node type is MultiAdaptive broadcast node
# value  "s" match the node type is MultiAdaptive storage node
NODETYPE="b"


# MultiAdaptive suport two kind of chain type ：one of them is eth,another is btc
CHAINTYPE="eth"

# go
DOWNLOAD_COMMOND="curl -sSL https://golang.org/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -C /usr/local -xz"

#eth scan url
L1Url=""

#btc scan host
BTCHost=""

BTCUser=""

BTCPWD=""

BTCPriv=""

# chain id
ChainID=11155111


ADDRESS_LIST=""

# boot to p2p connect
BOOTNODEINFO="enode://dbffc218798fd2febbb1106aa910d336b33bc1b01267a9181b7411af57b37751f9ebcf24e5264dd5fc7fb7572d799d5830882445de76e334590d4662c2a23034@13.212.115.195:30303"

# initialize a utopia blockchain
initenv_getstart() {
    PS3="Please pick an option: "
    select opt in "init env" "getting start"; do
        case "$REPLY" in
            1 ) ACTION="init env"; break;;
            2 ) ACTION="getting start"; break;;
            *) echo "Invalid option, please retry";;
        esac
    done
    
    select_node_type
}

select_node_type() {
    NODETYPE="b"
    if [ "$ACTION" == "init env" ];then
            ##init env
            echo "exec apt-get updating...."
            sudo apt-get update
        if [ $? -eq 0 ]; then
              echo "normal node"
              install_go
              install_git
              install_nettool
              install_make
              install_gcc
        else
            echo "Sudo apt-get update failed，please check or do it on your own。"
        fi
    
    else
        # starting a node
        echo "starting a node..."
    fi
}

install_go() {
    echo "Download go package and uncompressing....."
    eval "$DOWNLOAD_COMMOND"
    if [ $? -eq 0 ]; then
        echo "Download and uncompressed success."
        # 添加Go相关环境变量到~/.bashrc
        echo -e "export PATH=\$PATH:/usr/local/go/bin\nexport GOPATH=/home/ubuntu\nexport PATH=\$PATH:/home/ubuntu/bin" >> ~/.bashrc
        echo "Go env needed is done."
        
    else
        echo "Download and uncompressed failed，please check go or do it on your own：$DOWNLOAD_COMMOND"
    fi
}

install_git() {
    echo "Update git....."
    sudo apt-get install -y git
    if [ $? -eq 0 ]; then
        echo "Git is success."
    else
        echo "Git update failed，please check git or do it on your own."
    fi
}

install_nettool() {
    echo "Update net-tool....."
    sudo apt install net-tools
    if [ $? -eq 0 ]; then
        echo "net-tool update successful."
    else
        echo "net-tool update failed，please check net-tool or do it on your own."
    fi
}

install_make() {
    echo "Update make...."
    sudo apt-get install make
    if [ $? -eq 0 ]; then
       echo "Update make success"
    else
       echo "Update make failed"
    fi
}

install_gcc() {
    echo "Update gcc...."
    sudo apt-get install gcc
    if [ $? -eq 0 ]; then
       echo "Update make success"
       
       echo 'NOTE!!! You should do !!!:  1.Do "source /home/ubuntu/.bashrc"； 2. Input "go env -w CGO_ENABLED=1" When initenv.sh is finished.'
       
    else
       echo "Update gcc failed"
    fi

}

init_datapath() {
    CHAIN_DATA_DIR=$MULTIADAPTIVE_HOME_PATH/chain/$ChainID
    CHAIN_CONF_DIR=$MULTIADAPTIVE_HOME_PATH/conf/$ChainID
    CHAIN_INFO_FILE=$CHAIN_CONF_DIR/chain-info.properties
    
    # remove existing one
    if [ -d "$CHAIN_DATA_DIR" ];then
        rm -rf $CHAIN_DATA_DIR
        rm -rf $CHAIN_CONF_DIR
    fi
    
    mkdir -p $CHAIN_DATA_DIR/data
    mkdir -p $CHAIN_CONF_DIR
    
    touch $CHAIN_INFO_FILE
}

# create account
new_account() {
    echo "Create account..."
    
    SAVEDSTTY=`stty -g`
    stty -echo
    echo "Enter your password:"
    read PASSWORD
    stty $SAVEDSTTY

    $MULTIADAPTIVE_BIN/geth account new --datadir "$CHAIN_DATA_DIR/data"
    
    if [ $? -eq 0 ]; then
   
        touch $CHAIN_DATA_DIR/data/keystore/.password.txt

        echo "$PASSWORD" >> $CHAIN_DATA_DIR/data/keystore/.password.txt

        get_account_address
    fi
    
}


# get account address
get_account_address() {
    ADDRESS_LIST=`$MULTIADAPTIVE_BIN/geth  account list --datadir "$CHAIN_DATA_DIR/data"`
    if  [ ! -n "$ADDRESS_LIST" ];then
        new_account
    else
        ADDRESS=`echo $ADDRESS_LIST | cut -d '{' -f 2 | cut -d '}' -f 1`
    fi

    echo "address=0x$ADDRESS" >> $CHAIN_INFO_FILE
}


config_url() {
    echo "Please conf the environment variable file...."
    
    if [ "$CHAINTYPE" == "eth" ];then
        echo "Please pick an option that Kind of L1 RPC you're connecting to, used to inform DA data receipts fetching.: "
        select opt in "alchemy" "quicknode" "infura" "parity" "nethermind" "debug_geth" "erigon" "basic" "any"; do
        case "$REPLY" in
            1 ) L1_RPC_KIND="alchemy"; break;;
            2 ) L1_RPC_KIND="quicknode"; break;;
            3 ) L1_RPC_KIND="infura"; break;;
            4 ) L1_RPC_KIND="parity"; break;;
            5 ) L1_RPC_KIND="nethermind"; break;;
            6 ) L1_RPC_KIND="debug_geth"; break;;
            7 ) L1_RPC_KIND="erigon"; break;;
            8 ) L1_RPC_KIND="any"; break;;
            *) echo "Invalid option, please retry";;
        esac
        done
        echo
        
            while true; do
            read -p "Enter the L1Url: " L1Url
            # 判断输入是否为空
            if [ -z "$L1Url" ]; then
                echo "Error: Input cannot be empty. Please enter a valid L1Url."
            else
                break  # 用户输入不为空，退出循环
            fi
            done

            echo "L1 RPC URL will written into $CHAIN_INFO_FILE later."
            echo
    else
            while true; do
            read -p "Enter the BTC URL you want to scan: " BTCHost
            # 判断输入是否为空
            if [ -z "$BTCHost" ]; then
                echo "Error: Input cannot be empty. Please enter a valid BTC URL."
            else
                break  # 用户输入不为空，退出循环
            fi
            done
        
            echo
        
            while true; do
            read -p "Enter the BTC URL User you want config it can be empty: " BTCUser
            done
            
            echo
            
            while true; do
            read -p "Enter the BTC URL password you want config it can be empty: " BTCPWD
            done
            
            echo
            
            while true; do
            read -p "Enter the BTC Private key :" BTCPriv
            # 判断输入是否为空
            if [ -z "$BTCPriv" ]; then
                echo "Error: Input cannot be empty. Please enter a valid BTC PrivateKey ."
            else
                break  # 用户输入不为空，退出循环
            fi
            done
    fi
   
}

chose_chain_type() {
    echo
    echo "Please chose a chain type to run...."
    echo "Please pick an option that type of multiadaptive suport :"
    select opt in "eth" "btc"; do
        case "$REPLY" in
            1 ) CHAINTYPE="eth"; break;;
            2 ) CHAINTYPE="btc"; break;;
            *) echo "Invalid option, please retry";;
        esac
    done
    echo

}



P2P_PORT=30303

write_env_conf() {
    echo "writting chain config into $CHAIN_INFO_FILE"
    # write net info
    echo "chainID=$ChainID" >> $CHAIN_INFO_FILE
    echo "host=127.0.0.1" >> $CHAIN_INFO_FILE
    echo "p2p_port=$P2P_PORT" >> $CHAIN_INFO_FILE
    echo "nodeType=$NODETYPE" >> $CHAIN_INFO_FILE
    echo "chainType=$CHAINTYPE" >> $CHAIN_INFO_FILE
    # write bootnode info
    echo "bootnode=$BOOTNODEINFO" >> $CHAIN_INFO_FILE
    
    if [ "$CHAINTYPE" == "eth" ];then
        echo "l1Url=$L1Url" > $CHAIN_INFO_FILE
    else
        echo "BTCHost=$BTCHost" >> $CHAIN_INFO_FILE
        echo "BTCUser=$BTCUser" >> $CHAIN_INFO_FILE
        echo "BTCPriv=$BTCPriv" >> $CHAIN_INFO_FILE
    fi
    echo "chain config info is written into $CHAIN_INFO_FILE,please check that."
    echo
}

init_geth() {
    echo "starting init geth data...."
    
    cd "$MULTIADAPTIVE_BIN"
    
    cp $MULTIADAPTIVE_HOME_PATH/chain/genesis.json  $CHAIN_DATA_DIR
    
    #需要执行domicon geth
    ./geth init --datadir="$CHAIN_DATA_DIR/data" "$CHAIN_DATA_DIR/genesis.json" && wait

    echo "geth is inited."
    echo
    
}


main() {
    initenv_getstart
    if [ "$ACTION" == "getting start" ];then
        ##创建目录
        init_datapath
        ##创建账户
        new_account
      
        ##选择了链的类型
        chose_chain_type
    
        ##填写l1 url
        config_url
        ##将配置记录下来
        write_env_conf
        #init geth
        init_geth
    fi
}

main
