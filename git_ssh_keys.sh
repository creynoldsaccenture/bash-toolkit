#!/bin/bash

function setup_git_aliases {
    # Set up Git aliases
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.cm commit
    git config --global alias.st status
    git config --global alias.un 'reset HEAD --'

    setup_ssh_keys
}

# Check if Git is already installed
if hash git 2>/dev/null; then
    git --version
    setup_git_aliases
else
    # Install Git
    sudo apt-get install git
    setup_git_aliases
fi

function setup_ssh_keys {
    # Prompt user for their Github email address (required for setting up SSH keys) - NOT WORKING!
    echo -n "Please enter your Github email address [ENTER]: "
    read git_email

    if [ "$git_email" != "" ]; then
        # Set up SSH keys (-N means no passphrase and -f denotes the file to store the key in)
        ssh-keygen -t rsa -b 4096 -C "$git_email" -N "" -f ~/.ssh/id_rsa_git -q
        ssh-agent -s
        ssh-add ~/.ssh/id_rsa_git

        echo -e "\nCopy this SSH key and paste it into the SSH keys section of your Github profile:\n"

        cat ~/.ssh/id_rsa_git.pub

        echo -e "\n"
    else
        echo -e "\nThis script requires your Github email address to generate SSH keys."
        exit 1
    fi
}

# Quash git push message (use simple version of git push)
git config --global push.default simple

exit 0
