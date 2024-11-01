#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' 


log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> setup.log
}


print_styled() {
    echo -e "${1}${2}${NC}"
    log "${2}"
}


print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo -e "║               ${MAGENTA}Development Environment Setup Script${CYAN}                ║"
    echo "║                                                                   ║"
    echo "╠═══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                   ║"
    echo -e "║  ${GREEN}Author:${CYAN}  Sed                                                     ║"
    echo -e "║  ${GREEN}Date:${CYAN}    $(date '+%Y-%m-%d')                                              ║"
    echo -e "║  ${GREEN}System:${CYAN}  $(uname -s) $(uname -r)                                      ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}[*] Initializing setup process...${NC}\n"
    log "Setup process initialized"
}


check_last_command() {
    if [ $? -ne 0 ]; then
        print_styled "${RED}" "[ERROR] - $1 failed. Exiting."
        exit 1
    fi
}


is_package_installed() {
    if command -v $1 &> /dev/null
    then
        return 0
    else
        return 1
    fi
}


install_package() {
    if is_package_installed $1; then
        print_styled "${GREEN}" "[INSTALLED] - $1 is already installed."
    else
        print_styled "${BLUE}" "[INSTALLING] - $1..."
        sudo apt install -y $1
        check_last_command "$1 installation"
    fi
}


install_docker() {
    if is_package_installed docker; then
        print_styled "${GREEN}" "[INSTALLED] - Docker is already installed."
    else
        print_styled "${BLUE}" "[INSTALLING] - Docker..."
        
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

    
        echo \
          "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        
        sudo usermod -aG docker $USER
        check_last_command "Docker installation"
    fi
}


install_gcloud() {
    if is_package_installed gcloud; then
        print_styled "${GREEN}" "[INSTALLED] - Google Cloud SDK is already installed."
    else
        print_styled "${BLUE}" "[INSTALLING] - Google Cloud SDK..."
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt-get update
        sudo apt-get install -y google-cloud-sdk
        check_last_command "Google Cloud SDK installation"
    fi
}


main() {
    print_header

    
    print_styled "${BLUE}" "[UPDATE] Updating package lists..."
    sudo apt-get update
    check_last_command "Package list update"

    
    PACKAGES="i3 i3lock xautolock python3-pip lightdm git vim xterm nautilus nodejs brightnessctl wget nmap stellarium"
    for pkg in $PACKAGES; do
        install_package $pkg
    done

    
    print_styled "${BLUE}" "[INSTALLING] Python packages and tools..."
    pip install notebook jupyter awscli
    check_last_command "Python packages installation"


    install_docker

    
    install_gcloud

    
    print_styled "${BLUE}" "[DOWNLOADING] Visual Studio Code..."
    wget https://go.microsoft.com/fwlink/?LinkID=760868
    check_last_command "VS Code download"
    
    print_styled "${BLUE}" "[INSTALLING] Visual Studio Code..."
    sudo apt install ./code_*
    check_last_command "VS Code installation"
    rm code_*

    
    print_styled "${BLUE}" "[DOWNLOADING] Google Chrome..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    check_last_command "Chrome download"
    
    print_styled "${BLUE}" "[INSTALLING] Google Chrome..."
    sudo apt install ./google-chrome-stable_current_amd64.deb
    check_last_command "Chrome installation"
    rm google-chrome-stable_current_amd64.deb

    
    print_styled "${BLUE}" "[SETUP] Configuring i3..."
    git clone https://github.com/sudoping01/i3-config.git
    check_last_command "i3 config download"

    
    mkdir -p ~/.config/i3
    check_last_command "Config directory creation"

    
    cp i3-config/config ~/.config/i3/config
    check_last_command "i3 config file copy"
    
    cp i3-config/Xresources ~/.Xresources
    check_last_command "Xresources file copy"

    
    rm -rf i3-config

    print_styled "${GREEN}" "[SUCCESS] Setup completed successfully!"
    print_styled "${YELLOW}" "[INFO] Please log out and log back in to apply all configurations."
    print_styled "${YELLOW}" "[INFO] For Docker, you may need to restart your system to use it without sudo."
    log "Setup completed successfully"
}


main