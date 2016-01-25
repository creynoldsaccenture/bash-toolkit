#!/bin/bash

# Colours
reset="\e[0m"
red="\e[91m"
green="\e[92m"
green_bg="\e[42m"

function setup_ssh_keys {
    # Prompt user for their Github email address (required for setting up SSH keys) - NOT WORKING!
    read -p "Please enter your Github email address [ENTER]: " git_email

    if [ "$git_email" != "" ]; then
        # Set up SSH keys (-N means no passphrase and -f denotes the file to store the key in)
        ssh-keygen -t rsa -b 4096 -C "$git_email" -N "" -f ~/.ssh/id_rsa_git -q
        ssh-agent -s
        ssh-add ~/.ssh/id_rsa_git

        printf "\nCopy the SSH key below (inside the double quote marks) and paste it into the SSH keys section of your Github profile:\n"

        ssh_key=$(cat ~/.ssh/id_rsa_git.pub)

        printf "\n${green_bg}\"${ssh_key}\"${reset}\n\n"
    else
        printf "\n${red}This script requires your Github email address to generate SSH keys!${reset}\n\n"
        exit 1
    fi
}

function setup_git_aliases {
    printf "\nSetting up Git aliases... "

    # Set up Git aliases
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.cm commit
    git config --global alias.st status
    git config --global alias.un 'reset HEAD --'

    printf "${green}Done${reset}\n\n"

    setup_ssh_keys
}

# Check if Git is already installed
if hash git 2>/dev/null; then
    setup_git_aliases
else
    printf "\nGit not found, installing...\n\n"

    # Install Git
    sudo apt-get install git

    printf "\n${green}Git installed successfully!${reset}\n"

    setup_git_aliases
fi

# Quash git push message (use simple version of git push)
git config --global push.default simple

exit 0
