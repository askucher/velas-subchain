#!/bin/sh

# Deploy new subchain
deploy() {
    set -euo pipefail

    source .env

    ###############################################
    # Build the NativeERCToken contract artifact  #
    ###############################################

    ROOT=$(pwd)

    cd nativeErcToken || {
        echo "nativeErcToken directory not found"
        exit 1
    }

    echo "INITIAL_SUPPLY: $INITIAL_SUPPLY"
    forge script script/DeployAndDumpGenesis.sol:DeployAndDumpGenesis --ffi --evm-version london
    #kill -9 $ANVIL_PID
    # Extract the deployed (runtime) bytecode from the JSON output.

    if [ ! -f "./genesis_alloc.json" ]; then
        exit
    fi
    ALLOC=$(cat ./genesis_alloc.json)

    ###############################################
    # Now use HEX_BYTECODE in your genesis.json    #
    ###############################################
    # For example, you might insert this bytecode into the appropriate field.

    ###############################################
    # Clone and build the Velas chain repository  #
    ###############################################

    # Go back to the parent directory
    cd $ROOT

    # Clone the repository (if not already cloned)
    if [ ! -d "velas" ]; then
        git clone git@github.com:velas/velas-chain.git velas
    fi

    cd velas || {
        echo "Failed to change directory to velas"
        exit 1
    }

    # Checkout the desired branch
    git checkout $GIT_BRANCH

    # TODO: check that we switched the git version
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" != "$GIT_BRANCH" ]; then
        echo "Failed to switch to $GIT_BRANCH branch. Currently on $CURRENT_BRANCH"
        exit 1
    fi

    # Build the project in release mode
    cargo build --release

    if [ ! -f "./target/release/velas" ]; then
        echo "velas binary not found at ./target/release/velas"
        exit 1
    fi
    ./target/release/velas --version

    if [ ! -f "./target/release/velas-keygen" ]; then
        echo "velas-keygen binary not found at ./target/release/velas-keygen"
        exit 1
    fi

    if [ ! -f "$KEY_FILE" ]; then
        echo "create new key file $KEY_FILE"
        ./target/release/velas-keygen new --outfile "$KEY_FILE"
    fi

    ./target/release/velas config set --keypair "$KEY_FILE"

    # Configure Velas to use your keypair

    # Retrieve and show your Velas address
    ADDRESS=$(./target/release/velas address)
    echo "Deposit tokens on $ADDRESS then press Enter to continue..."
    read -r

    ###############################################
    # Prepare and update the genesis configuration #
    ###############################################

    # Copy the genesis file from one directory up
    cp ../genesis-template.json ./genesis.json

    CHAINID_HEX=$(printf '%x\n' "$CHAINID")

    jq --arg chainId "0x$CHAINID_HEX" '.config.chainId = $chainId' genesis.json >genesis.tmp && mv genesis.tmp genesis.json
    jq --arg networkName "$NAME" '.config.networkName = $networkName' genesis.json >genesis.tmp && mv genesis.tmp genesis.json
    jq --arg tokenName "$SYMBOL" '.config.tokenName = $tokenName' genesis.json >genesis.tmp && mv genesis.tmp genesis.json
    jq --argjson alloc "$ALLOC" '.alloc = $alloc' genesis.json >genesis.tmp && mv genesis.tmp genesis.json

    # Optionally, to start the evm-bridge, uncomment the line below and adjust as needed.
    echo "RUST_LOG=info,rpc=trace,evm_bridge=trace,evm_bridge::pool=warn ./target/release/evm-bridge $KEY_FILE http://bootstrap.devnet.veladev.net:13899 127.0.0.1:8545 $CHAINID --subchain --no-simulate --borsh-encoding" >gateway.sh

    ###############################################
    # Create and deploy the subchain              #
    ###############################################

    RESULT=$(./target/release/subchain-manager create-and-deploy --config-file genesis.json --velas-rpc http://bootstrap.devnet.veladev.net:13899)
    echo $RESULT
}

# Print total supply of minted tokens
total_supply() {
    # Use cast to call the totalSupply function of the ERC20 contract.
    ERC20_ADDRESS="0x0000000000000000000000000000000000000000"
    TOTAL_SUPPLY=$(cast call "$ERC20_ADDRESS" "totalSupply()" --rpc-url http://127.0.0.1:8545)

    # Display the result.
    echo "Total Supply of ERC20 contract ($ERC20_ADDRESS): $TOTAL_SUPPLY"
}

# Print token name
name() {
    # Use cast to call the totalSupply function of the ERC20 contract.
    ERC20_ADDRESS="0x0000000000000000000000000000000000000000"
    TOTAL_SUPPLY=$(cast call "$ERC20_ADDRESS" "name()" --rpc-url http://127.0.0.1:8545)

    # Display the result.
    echo "Total Supply of ERC20 contract ($ERC20_ADDRESS): $TOTAL_SUPPLY"
}
