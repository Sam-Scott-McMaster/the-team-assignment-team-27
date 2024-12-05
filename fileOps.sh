#!/bin/bash
usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "For all commands: Usage: ./fileOps.sh <command> [options]"
    echo "A utility script to perform various file operations such as deletion, encryption, and organization."
    echo ""
    echo "Commands:"
    echo "  date_delete    Delete files in a directory older than a specified number of days."
    echo "  duplicate_delete    Delete duplicate files in a directory."
    echo "  encrypt   Encrypt or decrypt files using AES-256-CBC with batch processing support."
    echo "  organize  Organize files in a directory based on the specified criteria."
    echo ""
    echo "Options:"
    echo "  date_delete:"
    echo "    Usage: $0 date_delete <directory> <days>"
    echo "    Deletes files in the specified directory that are older than the specified number of days."
    echo "    Example:"
    echo "      $0 date_delete ~/Downloads 10"
    echo "      Deletes files older than 10 days from the ~/Downloads directory."
    echo ""
    echo "  duplicate_delete:"
    echo "    Usage: $0 duplicate_delete <directory>"
    echo "    Deletes duplicate files in the specified directory."
    echo ""
    echo "  encrypt:"
    echo "    Usage: $0 encrypt <encrypt|decrypt> <filename|directory>"
    echo "    Encrypts or decrypts a file or all files in a directory using AES-256-CBC encryption."
    echo "    Features:"
    echo "      - Password entered once and reused for batch operations."
    echo "      - Deletes the original file after encryption or decryption."
    echo "    Examples:"
    echo "      $0 encrypt encrypt myfile.txt"
    echo "      Encrypts 'myfile.txt' and creates 'myfile.txt.enc', deleting the original file."
    echo ""
    echo "      $0 encrypt decrypt myfile.txt.enc"
    echo "      Decrypts 'myfile.txt.enc' back to 'myfile.txt', deleting the encrypted file."
    echo ""
    echo "      $0 encrypt encrypt /path/to/folder"
    echo "      Encrypts all files in the specified folder, creating '.enc' versions and deleting the originals."
    echo ""
    echo "      $0 encrypt decrypt /path/to/folder"
    echo "      Decrypts all '.enc' files in the specified folder, restoring the originals and deleting the encrypted files."
    echo ""
    echo "  organize:"
    echo "    Usage: $0 organize <directory> <criteria>"
    echo "    Organizes files in the specified directory based on the chosen criteria."
    echo "    Criteria:"
    echo "      type  - Organize files by type (e.g., Images, Documents, Videos)"
    echo "      size  - Organize files by size (e.g., Small, Medium, Large)"
    echo "      date  - Organize files by modification date (e.g., Year-Month folders)"
    echo "    Examples:"
    echo "      $0 organize ~/Downloads type"
    echo "      Organizes all files in the ~/Downloads folder into subfolders based on file type."
    echo ""
    echo "      $0 organize ~/Documents size"
    echo "      Organizes all files in the ~/Documents folder into 'Small', 'Medium', and 'Large' subfolders based on file size."
    echo ""
    echo "      $0 organize /path/to/folder date"
    echo "      Organizes all files in the specified folder into subfolders by the year and month they were last modified."
    echo ""
    echo "  --help    Displays this help message."
    echo ""
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

first_input=$1
second_input=$2

case "$first_input" in
    date_delete)
        if [[ $1 == "--help" ]]; then
        ./date_delete.sh --help
        fi

        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 delete <directory> <days>"
            exit 1
        fi

        ./date_delete.sh "$second_input" "$3"
        ;;
    duplicate_delete)
        if [[ $1 == "--help" ]]; then
        ./duplicate_delete.sh --help
        fi
        
        if [[ $# -ne 2 ]]; then
            echo "Usage: $0 duplicate_delete <directory>"
            exit 1
        fi
        ./duplicate_delete.sh "$second_input"
        ;;
    encrypt)
        if [[ $1 == "--help" ]]; then
        ./file_encryptor.sh --help
        fi
        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 encrypt <encrypt|decrypt> <filename>"
            exit 1
        fi
        ./file_encryptor.sh "$second_input" "$3"
        ;;
    organize)
        if [[ $1 == "--help" ]]; then
        ./organize.sh --help
        fi
        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 organize <directory> <criteria>"
            exit 1
        fi
        ./organize.sh -d "$second_input" -c "$3"
        ;;
    backup)
        if [[ $1 == "--help" ]]; then
        ./backup.sh --help
        fi
        if [[ $# -ne 3 ]]; then
            echo "Usage: ./backup.sh <backup folder or -na> <input .txt file>"
            exit 1
        fi
        ./backup.sh "$second_input" "$3"
        ;;
    *) #basically any other case
        echo "Command does not exist: $first_input"
        usage
        ;;
esac
