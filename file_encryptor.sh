#!/bin/bash
# Encryption Utility Script: Encrypts or decrypts files or all files in a folder using AES-256-CBC encryption via OpenSSL.
# This script accepts an action (encrypt or decrypt) and a file or folder as arguments. It encrypts or decrypts files based on the provided password.
# Author: Saqib Khan, McMaster University, 400504486, 2024-11-2

###########################
# Display usage information
# Globals: None
# Arguments: None
# Outputs: Displays usage string on stderr
# Returns: N.A.
###########################
usage() {
    echo "Usage: $0 <encrypt|decrypt> <filename|folder>" >&2
    exit 1
}

###########################
# Display help text
# Globals: None
# Arguments: None
# Outputs: Help information on stdout
# Returns: Exits after printing help text
###########################
help() {
    echo "Encryption Utility"
    echo "Encrypts or decrypts files using AES-256-CBC encryption via OpenSSL."
    echo
    echo "Usage:"
    echo "$0 <encrypt|decrypt> <filename|folder>"
    echo
    echo "Arguments:"
    echo "  encrypt   Encrypt a file or all files in a folder."
    echo "  decrypt   Decrypt a file or all files in a folder ending in .enc."
    echo
    echo "Examples:"
    echo "  $0 encrypt document.txt"
    echo "  $0 decrypt document.txt.enc"
    echo "  $0 encrypt myfolder"
    echo "  $0 decrypt myfolder"
    echo
    echo "Note: Password is entered once for batch encryption or decryption."
    exit 0
}

###########################
# Validate input arguments
# Globals: None
# Arguments: $1 = action (encrypt|decrypt), $2 = target (file|folder)
# Outputs: Error messages on stderr if the inputs are invalid
# Returns: Exits with code 2 if the arguments are invalid
###########################
check_args() {
    local action="$1"
    local target="$2"

    # Validate action
    if ! [[ "$action" =~ ^(encrypt|decrypt)$ ]]
    then
        echo "Error: Invalid action '$action'. Must be 'encrypt' or 'decrypt'." >&2
        usage
        exit 2
    fi

    # Validate target
    if [ ! -e "$target" ]
    then
        echo "Error: Target '$target' not found" >&2
        usage
        exit 2
    fi
}

# If the user does not give exactly two arguments
if [ "$#" -ne 2 ]
    then
    if [ "$1" == "--help" ]
        then
            help  # Call the help function if only one argument is given
    else
        usage  # Call the usage function for invalid argument count
    fi
fi

# Validate arguments
check_args "$1" "$2"

# First argument = action
# Second argument = the file or folder
ACTION=$1
TARGET=$2

# Prompt for password
read -s -p "Enter password: " PASSWORD
echo
read -s -p "Confirm password: " CONFIRM_PASSWORD
echo
if [ "$PASSWORD" != "$CONFIRM_PASSWORD" ]
    then
        echo "Error: Passwords do not match." >&2
        exit 1
fi

###########################
# Encrypt a single file
# Globals: PASSWORD
# Arguments: $1 = file to encrypt
# Outputs: Encrypts the file and deletes the original
# Returns: Exits if encryption or file deletion fails
###########################
encrypt_file() {
    local file="$1"
    echo "Encrypting file: $file"
    openssl enc -aes-256-cbc -salt -in "$file" -out "$file.enc" -pass pass:"$PASSWORD"
    if [ $? -eq 0 ] #if command openssl successfully ran
        then
            echo "File successfully encrypted: $file.enc" #output file
            # Delete the original file
            rm "$file"
        if [ $? -eq 0 ] #if command rm successfully ran
            then
                echo "Original file deleted: $file"
        else
            echo "Error: Could not delete the original file." >&2
            exit 1
        fi
    else
        echo "Error: Encryption failed for $file." >&2
        exit 1
    fi
}

###########################
# Decrypt a single file
# Globals: PASSWORD
# Arguments: $1 = file to decrypt
# Outputs: Decrypts the file and deletes the original encrypted file
# Returns: Exits if decryption or file deletion fails
###########################
decrypt_file() {
    local file="$1"
    local decrypted_file="${file%.enc}" #removes the .enc
    echo "Decrypting file: $file"
    openssl enc -aes-256-cbc -d -in "$file" -out "$decrypted_file" -pass pass:"$PASSWORD"
    if [ $? -eq 0 ] #if command openssl successfully ran
        then
            echo "File successfully decrypted: $decrypted_file"
            # Delete the original file
            rm "$file"
        if [ $? -eq 0 ] #if command rm successfully ran
            then
                echo "Encrypted file deleted: $file"
        else
            echo "Error: Could not delete the encrypted file.">&2
            exit 1
        fi
    else
        echo "Error: Decryption failed for $file. Ensure you entered the correct password." >&2
        exit 1
    fi
}

# Check if the target is a directory
if [ -d "$TARGET" ]
    then
    read -p "$TARGET is a directory. Do you want to process all files in it? (y/n): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]
        then
        if [ "$ACTION" = "encrypt" ]
            then
                for file in "$TARGET"/*
                    do
                        [ -f "$file" ] && encrypt_file "$file"
                    done
        elif [ "$ACTION" = "decrypt" ]
            then
                for file in "$TARGET"/*.enc
                    do
                        [ -f "$file" ] && decrypt_file "$file"
                    done
        fi
    else
        echo "Aborting."
        exit 0
    fi
else
    # Single file encryption or decryption
    if [ "$ACTION" = "encrypt" ]
        then
            encrypt_file "$TARGET"
    elif [ "$ACTION" = "decrypt" ]
        then
            decrypt_file "$TARGET"
    fi
fi
