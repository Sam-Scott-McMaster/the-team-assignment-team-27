#!/bin/bash


###########################
# Display usage information
# Globals: None
# Arguments: None
# Outputs: Displays usage string on stderr
# Returns: N.A.
###########################
usage() {
    echo "Usage: $0 <encrypt|decrypt> <filename>" >&2
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
    echo "$0 <encrypt|decrypt> <filename>"
    echo
    echo "Arguments:"
    echo "  encrypt   Encrypt a file and save as <filename>.enc."
    echo "  decrypt   Decrypt a file ending in .enc and save it without the .enc extension."
    echo
    echo "Examples:"
    echo "  $0 encrypt document.txt"
    echo "  $0 decrypt document.txt.enc"
    echo
    echo "Note: You will be prompted to enter a password for encryption or decryption."
    echo "In order to encrypt a file you must re-enter the password to verfiy encryption"
    exit 0
}


# if the user does not provice two arguments
if [ "$#" -ne 2 ]
    then
    usage
fi

# first argument = action 
#second argument = the file 
ACTION=$1
FILE=$2


# if the file doesn't exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi



# Encrypt the file
if [ "$ACTION" = "encrypt" ]
    then
    echo "Encrypting file: $FILE"
    openssl enc -aes-256-cbc -salt -in "$FILE" -out "$FILE.enc"
    if [ $? -eq 0 ] #if command openssl succesfully ran 
        then
        echo "File successfully encrypted: $FILE.enc" #output file
    else
        echo "Error: Encryption failed."
        exit 1
    fi

# Decrypt the file
elif [ "$ACTION" = "decrypt" ]
    then
    echo "Decrypting file: $FILE"
    FILE_DECRYPTED="${FILE%.enc}"
    openssl enc -aes-256-cbc -d -in "$FILE" -out "$FILE_DECRYPTED"
    if [ $? -eq 0 ] #if command openssl succesfully ran 
        then
        echo "File successfully decrypted: $FILE_DECRYPTED" #output file
    else
        echo "Error: Decryption failed. Make sure you entered the correct password."
        exit 1
    fi

# Handle invalid actions
else
    echo "Error: Invalid action '$ACTION'."
    usage
fi