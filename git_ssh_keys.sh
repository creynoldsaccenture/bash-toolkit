#!/bin/bash

# Colours
reset="\e[0m"
red="\e[91m"
green="\e[92m"
green_bg="\e[42m"

# Matches {anything}@{anything}.{anything}
email_regex=.+@.+\..+
ssh_key_file=~/.ssh/id_rsa_git

function new_line {
    printf "\n"
}

function prompt_user {
    # Prompt user for their Github email address (required for setting up SSH keys)
    read -p "Please enter your full name [ENTER]: " name
    read -p "Please enter your Github email address [ENTER]: " git_email

    setup_git_author
}

function setup_git_author {
    git config user.name "$name"
    git config user.email "$git_email"

    printf "Git author set as \"$name <$git_email>\""

    setup_ssh_keys
}

function setup_ssh_keys {

    if [[ "$git_email" != "" && "$git_email" =~ $email_regex ]]; then

        new_line

        # Set up SSH keys (-N means no passphrase and -f denotes the file to store the key in)
        ssh-keygen -t rsa -b 4096 -C "$git_email" -N "" -f $ssh_key_file -q

        # If the user chooses to not overwrite an existing SSH key file then tell them the script will use the pre-existing SSH key
        if [ $? -ne 0 ]; then
            printf "\nUsing existing SSH key in \"${ssh_key_file}\".\n\n"
        fi

        eval $(ssh-agent -s)
        new_line
        ssh-add $ssh_key_file

        printf "\nCopy the SSH key below (inside the double quote marks) and add it to the SSH keys section of your Github profile:\n"

        ssh_key=$(cat ${ssh_key_file}.pub)

        printf "\n${green_bg}\"${ssh_key}\"${reset}\n\n"

    elif ! [[ "$git_email" =~ $email_regex ]]; then
        printf "\n${red}\"${git_email}\" is not a valid email address!${reset}\n\n"
        prompt_user
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

    prompt_user
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
