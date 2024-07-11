



#MultiAdaptive QuickStart
MultiAdaptive Network Quick Start Bash

## bin Directory
Used to store executable programs and execution scripts.

### bin/init.sh - Script for Initializing the Running Environment or Starting Nodes
After running the script, it will output two options in the terminal for the user to choose from: 1. Initialize the Environment, 2. Start Nodes. The user only needs to input 1 or 2 to proceed with the subsequent operations based on their situation.

#### 1. Initialize the Environment
After the user chooses to initialize the environment, the script will install the necessary environment as a regular node in the Domicon network. This includes the installation and configuration of Go, Git, GCC, Make, and NetTool. After the installation is complete, the user needs to manually enter the command source /home/ubuntu/.bashrc to make the configuration file effective.

#### 2. Start Nodes
- 2.1 After choosing to start nodes, the terminal will output 'Create a new account'. The terminal will then prompt the user to enter a password for creating a new account. After entering the password three times correctly, the new account will be successfully created. Once successful, the account information will be automatically recorded in conf/chain-info.properties.And in the terminal we will display the address of the account created and the private key information, please keep it properly.

- 2.2 After completing the above operation, the terminal will output 'Please choose the chain type supported by the program to run'. Currently, MultiAdaptive only supports Ethereum and Bitcoin types.

- 2.2.1 If the user chooses the chain type as: eth, configure the L1 URL information. We need to configure the URL and its type to communicate with L1, mainly for querying. The terminal will ask for the type of URL to communicate with L1, such as "alchemy", "quicknode", "infura", "parity", "nethermind", "debug_geth", "erigon", "basic", "any". The user can choose from these types by inputting 1, 2, 3, etc., and then the terminal will prompt for the L1 URL. After entering, the configuration will be completed.

- 2.2.2 If the user chooses the chain type as: btc, configure the L1 URL information. We need to configure the URL to scan the Bitcoin network. After entering the URL, the terminal will ask for the username and password for scanning the Bitcoin URL, which can be empty. After configuration, the terminal will ask for the Bitcoin private key to sign Bitcoin data.

- 2.3 After completing the preparation configuration, all the configuration information will be recorded in conf/chain-info.properties for the user to review.

- 2.4 Initialize geth to generate the genesis block and basic data.
bin/start.sh - Start Script
After executing the start script, it will read the configuration file, start geth, and capture its bootNode information by reading the log information.

## chain Directory
Used to store chain data and the genesis.json file.

## conf Directory
Used to record some configuration information, as well as PID information and bootNode information.

