#!/bin/bash

install_on_arch() {
    sudo pacman -Syu ansible
}

install_on_mac() {
    brew install ansible
}

OS="$(uname -s)"
case "${OS}" in
    Linux*)
        if [ -f /etc/arch-release ]; then
            install_on_arch
        elif [ -f /etc/lsb-release ]; then
            install_on_arch
        else
            echo "Unsupported Linux distribution"
            exit 1
        fi
        ;;
    Darwin*)
        install_on_mac
        ;;
    *)
        echo "Unsupported operating system: ${OS}"
        exit 1
        ;;
esac


ansible-playbook ~/.bootstrap/setup.yml -K

echo "Ansible installation complete."
