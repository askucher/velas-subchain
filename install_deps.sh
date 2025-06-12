#!/bin/sh
source ./check_version.sh

# SHC (Shell Script Compiler)
# Overview: SHC is a widely used tool that compiles a Bash script into a binary executable. It encrypts the script and embeds it in the binary, but it’s important to note that SHC is more of an obfuscation tool than a true compiler.
# How It Works: SHC generates C source code from your script, which it then compiles into an executable binary using a standard C compiler.
# Security Consideration: The script is encrypted and hidden within the binary, but it can potentially be extracted or decompiled by a skilled reverse engineer.
install_shc_if_needed() {
    echo "install_shc_if_needed"
    if command -v shc 2>&1 >/dev/null; then
        return
    fi
    apt-get install shc -y
    brew install shc
}

install_just() {
    echo "install_just"
    if [[ $(check_version "just" 0) -eq 1 ]]; then
        return 0
    fi
    cargo install just
    brew install just
    apt install just -y
    #You should see the version number printed. This repo has been tested with version 1.28.0.
}

install_tar_if_needed() {
    echo "install_tar_if_needed"
    if [[ $(check_version "tar" 0) -eq 1 ]]; then
        return 0
    fi
    apt install tar
    brew install tar
}

install_curl_if_needed() {
    echo "install_curl_if_needed"
    if [[ $(check_version "curl" 0) -eq 1 ]]; then
        return 0
    fi
    apt install curl
    brew install curl
}

install_logratate_if_needed() {
    echo "install_logratate_if_needed"
    if [[ $(check_version "logrotate" 0) -eq 1 ]]; then
        return 0
    fi
    apt install logrotate -y
    brew install logrotate
}

# install python
install_pyenv_if_needed() {
    if [[ $(check_version "pyenv" 0) -eq 1 ]]; then
        return
    fi
    curl https://pyenv.run | bash_with_verify "1065197a9fff657e0e2941e4ca8c8b6e72833833466b777b9eddd0fff335ec41"
}

change_python_version() {
    if [[ $(check_version "python3" "$1") -eq 1 ]]; then
        echo "already right python3 version $1"
        return
    fi
    install_pyenv_if_needed
    pyenv install "$1" -y
    pyenv local "$1"
}

# gpg --symmetric --cipher-algo AES256 plaintext.txt
# gpg --decrypt encrypted.gpg > decrypted.txt
install_gpg_if_needed() {
    echo "install_gpg_if_needed"
    if [[ $(check_version "gpg" 0) -eq 1 ]]; then
        return 0
    fi
    sudo apt-get install gpg -y
}

# install tools to encrypt the data, do not keep it visible on storage
install_encryption_tools() {
    install_shc_if_needed
    install_gpg_if_needed
}

install_pm2_if_needed() {
    echo "install_pm2_if_needed"
    if [[ $(check_version "pm2" 0) -eq 1 ]]; then
        #nvm use $1
        return 0
    fi
    npm i pm2 -g
    pm2 install pm2-logrotate
    pm2 install pm2-metrics
    # PORT :9209
}

install_yarn_if_needed() {
    echo "install_yarn_if_needed"
    if [[ $(check_version "yarn" 0) -eq 1 ]]; then
        #nvm use $1
        return 0
    fi
    npm i yarn -g
}

install_pnpm_packages_if_needed() {
    if [[ $(check_version "pnpm" 0) -eq 1 ]]; then
        #nvm use $1
        return 0
    fi
    npm i pnpm -g
}

install_nodejs_packages() {
    echo "install_nodejs_packages"
    install_pnpm_packages_if_needed
    install_pm2_if_needed
    install_yarn_if_needed
    node --version
    npm --version

}

change_nodejs_version() {
    nvm install "$1"
    nvm use "$1"
}

bash_with_verify() {
    # Ensure exactly one argument (the expected checksum) is provided
    if [ "$#" -ne 1 ]; then
        echo "Usage: bash-with-verify <expected-checksum>" >&2
        return 1
    fi

    local expected_checksum="$1"
    local tmpfile
    tmpfile=$(mktemp)
    # Read the incoming script from STDIN and save it to a temporary file
    cat >"$tmpfile"

    # Calculate the SHA256 checksum of the file's content
    local actual_checksum
    actual_checksum=$(shasum -a 256 "$tmpfile" | awk '{print $1}')

    # Compare the computed checksum with the expected value
    if [ "$actual_checksum" = "$expected_checksum" ]; then
        echo "Checksum verification passed, executing script."
        bash "$tmpfile" -y
    else
        echo "Checksum verification failed! Aborting execution. Expected Checksum: $expected_checksum, Actual Checksum: $actual_checksum" >&2
        rm -f "$tmpfile"
        return 1
    fi

    # Clean up the temporary file
    rm -f "$tmpfile"
}

install_shasum_if_needed() {
    if [[ $(check_version "shasum" 0) -eq 1 ]]; then
        return 0
    fi
    apt install shasum
}

# This function installs a specific version of Node.js using the Node Version Manager(nvm).
# It takes an argument specifying the version of Node.js to be installed.
# This function also installs pnpm globally.
#
# Usage:
# install_nodejs "v18"

install_nvm_if_needed() {
    if [[ $(check_version "nvm" 0) -eq 1 ]]; then
        return 0
    fi
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash_with_verify "bdea8c52186c4dd12657e77e7515509cda5bf9fa5a2f0046bce749e62645076d"
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
}

install_nodejs_if_needed() {
    echo "install_nodejs_if_needed"
    change_nodejs_version "$1"
    install_nvm_if_needed
    if [[ $(check_version "node" "$1") -eq 1 ]]; then
        #nvm use $1
        install_nodejs_packages
        return 0

    fi
    echo "Install Nodejs"
    change_nodejs_version "$1"
    install_nodejs_packages
}

install_dotenv_replacer() {
    npm i dotenv-replacer -g
}

install_nc_if_needed() {
    if [[ $(check_version "nc" 0) -eq 1 ]]; then
        return 0
    fi
    sudo apt install netcat-traditional
}

install_yq_if_needed() {
    if [[ $(check_version "yq" 0) -eq 1 ]]; then
        return 0
    fi
    echo "Install jq"
    apt install yq -y
}

install_jq_if_needed() {
    if [[ $(check_version "jq" 0) -eq 1 ]]; then
        return 0
    fi
    echo "Install jq"
    apt install jq -y
}

install_ufw_if_needed() {
    if [[ $(check_version "ufw" 0) -eq 1 ]]; then
        return 0
    fi
    echo "Install ufw"
    apt install ufw -y
}

install_docker() {
    # Add Docker's official GPG key:
    sudo apt-get update s
    sudo apt install apt-transport
    curl -fsSL ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64]"
    #sudo apt-get remove docker docker-engine docker.io
    sudo apt-get update -y
    sudo apt install docker.io -y
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

}

install_docker_if_needed() {
    if [[ $(check_version "docker" 0) -eq 1 ]]; then
        return 0
    fi
    install_docker
}

install_direnv_if_needed() {

    if [[ $(check_version "direnv" 0) -eq 1 ]]; then
        return 0
    fi

    echo "Install direnv"
    apt install direnv -y
    direnv --version
}

install_aicommits_if_needed() {
    if [[ $(check_version "aicommits" 0) -eq 1 ]]; then
        return 0
    fi
    npm install -g aicommits
}

install_nginx_if_needed() {
    if [[ $(check_version "nginx" 0) -eq 1 ]]; then
        return 0
    fi

    echo "Install nginx"
    apt install nginx -y
    nginx --version
}

install_make_if_needed() {

    if [[ $(check_version "make" 0) -eq 1 ]]; then
        return 0
    fi

    echo "Install make"
    apt install make -y
    make --version
}

install_md5sum_if_needed() {
    if [[ $(check_version "md5sum" "0") -eq 1 ]]; then
        return 0
    fi
    apt install md5sum -y
    brew install md5sha1sum
}

install_bc_if_needed() {

    if [[ $(check_version "bc" "$1") -eq 1 ]]; then
        return 0
    fi

    echo "Install bc"
    apt install bc -y
}

install_git_if_needed() {

    check_res=$(check_version "git" $1)
    if [[ check_res -eq "1" ]]; then
        return 0
    fi

    echo "Install git"
    apt install git -y
    git --version
}

# uninstall rust is available
uninstall_rust() {
    rustup self uninstall
}

install_unzip_if_needed() {
    if [[ $(check_version 'unzip' 0) -eq 1 ]]; then
        return 0
    fi
    apt install unzip
    brew install unzip
}

install_rust_if_needed() {
    if [[ $(check_version 'cargo' 0) -eq 1 ]]; then
        return 0
    fi

    curl https://sh.rustup.rs -sSf | bash_with_verify "b25b33de9e5678e976905db7f21b42a58fb124dd098b35a962f963734b790a9b"
}

install_rsync_if_needed() {
    if [[ $(check_version 'rsync' 0) -eq 1 ]]; then
        return 0
    fi
    apt install rsync -y
}

set_foundry_exact_version() {
    install_rust_if_needed
    require "$1" "version"
    foundryup -C "$1"
}

set_foundry_known_version() {
    set_foundry_exact_version "626221f"
}

set_foundry_nightly_version() {
    set_foundry_exact_version nightly
}

foundry_source() {
    echo "Source foundry ~/.bashrc"
    source ~/.bashrc
    export PATH="$HOME/.foundry/bin:$PATH"
    if [ -f "/home/$USER/.bashrc" ]; then
        echo "Source foundry /home/$USER/.bashrc"
        source /home/$USER/.bashrc
    fi
}

# This function installs Foundry, a tool used for deployment and management of Ethereum projects.
# It does this by downloading and running the Foundry install script from its GitHub repository.
# The script is sourced into the bash runtime and Foundry is started.
#
# Usage:
# install_foundry
install_foundry_if_needed() {
    foundry_source
    if [[ $(check_version "forge" 0) -eq 1 ]]; then
        echo "installed"
        return 0
    fi

    echo "Install Foundry"
    ## forge cast
    curl -L https://foundry.paradigm.xyz | bash_with_verify "e4456a15d43054b537b329f6ca6d00962242050d24de4c59657a44bc17ad8a0c"
    foundry_source
    if [ -f "/home/$USER/.foundry/bin/foundryup" ]; then
        /home/$USER/.foundry/bin/foundryup
    else
        foundryup
    fi
    foundry_source
    if [[ $(check_version "forge" 0) -eq 1 ]]; then
        return 0
    fi

    echo "Cannot install forge. Please install it manually"
    exit 1
}

install_geth_if_needed() {
    goto_root
    check_program "git"
    check_program "make"
    #check_program "go"
    if [ -d "./go-ethereum" ]; then
        return 0
    fi
    #if [[ $(check_version "geth" 0) -eq 1 ]]; then
    #  return 0
    #fi
    git_clone https://github.com/ethereum/go-ethereum "go-ethereum"
    cd go-ethereum || exit
    # Prague
    if [ -z "$DEV_GETH_VERSION" ]; then
        DEV_GETH_VERSION="release/1.15"
    fi
    git checkout "$DEV_GETH_VERSION"

    CURRENT_VERSION=$(git rev-parse --abbrev-ref HEAD)

    if [ "$CURRENT_VERSION" != "$DEV_GETH_VERSION" ]; then
        echo "git checkout $DEV_GETH_VERSION. This version not found"
        exit 1
    fi

    make geth
    file_needed "./build/bin/geth" "Geth is not found"
}

install_bootnode_if_needed() {
    if [[ $(check_version "bootnode" 0) -eq 1 ]]; then
        return 0
    fi
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install bootnode -y
}

install_unzip_if_needed() {
    if [[ $(check_version "unzip" 0) -eq 1 ]]; then
        return 0
    fi
    sudo apt install unzip -y
}

install_zip_if_needed() {
    if [[ $(check_version "zip" 0) -eq 1 ]]; then
        return 0
    fi
    sudo apt install zip -y
}

install_java_if_needed() {

    if [[ $(check_version "java" 0) -eq 1 ]]; then
        return 0
    fi
    install_zip_if_needed
    install_unzip_if_needed
    curl -s "https://get.sdkman.io" | bash_with_verify "63af2d288adb6e4fdad84e83aca03d33cea9380bfe872bbec5353561081eb692"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install java
}

install_localles() {
    if [[ $(check_version "locale-gen" 0) -eq 1 ]]; then
        return 0
    fi
    apt update
    apt-get install -y locales
    sudo locale-gen
}

install_localles_manual() {
    apt update
    apt-get install -y locales
    echo "Enable en_US.UTF-8"
    read
    sudo nano /etc/locale.gen
    sudo locale-gen
    echo 'sudo vi /etc/ssh/ssh_config'
    echo 'Find these settings:'
    echo 'Host *'
    echo '      SendEnv LANG LC_*'
    echo 'Change it to :'
    echo 'Host *'
    echo '#      SendEnv LANG LC_*'
    echo 'service sshd restart'
}

# This function installs all the dependencies that are required for the project.
# It does this by calling the functions to install Node.js, direnv, golang, Foundry,
# and finally checks the various version of the packages.
install_all_deps() {
    echo "Install All Deps"
    install_localles
    install_rust_if_needed
    install_shasum_if_needed
    install_curl_if_needed
    install_md5sum_if_needed
    install_encryption_tools
    install_jq_if_needed 0
    install_make_if_needed 3
    install_git_if_needed 2
    install_nodejs_if_needed "21.0.0"
    install_dotenv_replacer
    install_direnv_if_needed 2
    install_foundry_if_needed 0
    install_bc_if_needed 0
    echo "Install All Deps Done"
}
