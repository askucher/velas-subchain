#!/bin/sh
source "./common.sh"
source "./install_deps.sh"

# https://docs.blockscout.com/setup/env-variables/backend-envs-chain-specific
#

# start the docker of explorer
start_explorer() {
    goto_root
    cd explorer || exit
    cd docker-compose || exit
    docker-compose up -d
    sleep 3
    docker ps
}

# remove the explorer folder
reset_whole_explorer() {
    goto_root
    rm -rf explorer
}

# reset explorer with full database
reset_explorer() {
    goto_root
    if [ -n "$1" ]; then
        cd "$1" || exit
    else
        cd explorer || exit
    fi
    ARTIFACTS="./artifact.json"
    file_needed "$ARTIFACTS"
    cd docker-compose || exit
    docker-compose down --rmi all -v
    docker system prune -a --volumes
    cd services || exit
    rm -rf blockscout-db-data
    rm -rf stats-db-data
    rm -rf redis-data
    rm -rf logs
    rm -rf dets
    reset_whole_explorer
}

# show backend logs
log_explorer() {
    docker logs backend
}

# apply all style, naming changes from envs
apply_explorer_variables() {
    goto_root_and_defaults "install_explorer"
    require "$EXPLORER_DOMAIN" "EXPLORER_DOMAIN"
    require "$NAME" "NAME"
    require "$CHAINID" "CHAINID"
    cd explorer || exit
    FILE='docker-compose/envs/common-frontend.env'
    file_needed "$FILE"
    if [ -z "$PUBLIC_RPC_URL" ]; then
        RPC_URL="http://127.0.0.1:8545"
    else
        RPC_URL="$PUBLIC_RPC_URL"
    fi

    require "$EXPLORER_DOMAIN" "EXPLORER_DOMAIN"
    require "$PUBLIC_DDOS_PROTECTED_RPC" "PUBLIC_DDOS_PROTECTED_RPC"

    if [ -n "$LOGO_LIGHT_URL" ]; then
        dotenv-replacer -n NEXT_PUBLIC_NETWORK_LOGO -v "$LOGO_LIGHT_URL" -e $FILE
    fi

    if [ -n "$LOGO_DARK_URL" ]; then
        dotenv-replacer -n NEXT_PUBLIC_NETWORK_LOGO_DARK -v "$LOGO_DARK_URL" -e $FILE
    fi

    if [ -n "$ICON_LIGHT_URL" ]; then
        dotenv-replacer -n NEXT_PUBLIC_NETWORK_ICON -v "$ICON_LIGHT_URL" -e $FILE
    fi

    if [ -n "$ICON_DARK_URL" ]; then
        dotenv-replacer -n NEXT_PUBLIC_NETWORK_LOGO_DARK -v "$ICON_DARK_URL" -e $FILE
    fi

    if [ -n "$FAVICON_MASTER_URL" ]; then
        dotenv-replacer -n FAVICON_MASTER_URL -v "$FAVICON_MASTER_URL" -e $FILE
    fi

    if [ -n "$EXPLORER_PLATE_BACKGROUND" ]; then
        dotenv-replacer -n NEXT_PUBLIC_HOMEPAGE_PLATE_BACKGROUND -v "$EXPLORER_PLATE_BACKGROUND" -e $FILE
    fi

    dotenv-replacer -n NEXT_PUBLIC_NAVIGATION_HIDDEN_LINKS -v "['eth_rpc_api','rpc_api']" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_AD_BANNER_PROVIDER -v "none" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_AD_TEXT_PROVIDER -v "none" -e $FILE

    #dotenv-replacer -n NEXT_PUBLIC_NETWORK_ID -v "$L2_CHAIN_ID" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_NETWORK_RPC_URL -v "$PUBLIC_DDOS_PROTECTED_RPC" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_API_HOST -v "$EXPLORER_DOMAIN/" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_APP_HOST -v "$EXPLORER_DOMAIN/" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_STATS_API_HOST -v "https://$EXPLORER_DOMAIN/stats" -e $FILE

    dotenv-replacer -n NEXT_PUBLIC_NETWORK_NAME -v "$NAME" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_NETWORK_SHORT_NAME -v "$NAME" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_NETWORK_CURRENCY_NAME -v "$NAME" -e $FILE
    dotenv-replacer -n SYMBOL -v "$NEXT_PUBLIC_NETWORK_CURRENCY_SYMBOL" -e $FILE
    dotenv-replacer -n NEXT_PUBLIC_NETWORK_ID -v "$CHAINID" -e $FILE

    FILE='docker-compose/envs/common-blockscout.env'
    file_needed "$FILE"

    dotenv-replacer -n ETHEREUM_JSONRPC_HTTP_URL -v "$RPC_URL" -e $FILE
    dotenv-replacer -n ETHEREUM_JSONRPC_TRACE_URL -v "$RPC_URL" -e $FILE
    dotenv-replacer -n USER_OPS_INDEXER__INDEXER__RPC_URL -v "$RPC_URL" -e $FILE
    dotenv-replacer -n "APPLICATION_MODE" -v "all" -e $FILE
    dotenv-replacer -n "ETHEREUM_JSONRPC_WS_URL" -v "ws://127.0.0.1:8546" -e $FILE
}

# install docker instance of blockscout explorer
install_explorer() {
    install_docker_if_needed
    install_nodejs_if_needed
    #install_nodejs_packages
    install_dotenv_replacer
    goto_root_and_defaults "install_explorer"
    git_clone git@github.com:blockscout/blockscout.git explorer
    cd explorer || exit
    git checkout v8.0.1
    apply_explorer_variables
    cd docker-compose/ || exit
    sudo chmod +x /usr/local/bin/docker-compose
    start_explorer
}
