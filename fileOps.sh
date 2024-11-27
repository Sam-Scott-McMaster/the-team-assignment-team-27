#!/bin/bash
usage() {
    echo "Usage: $0 -d <directory> -c <criteria>"
    echo ""
    echo "Organize files in a directory based on the specified criteria."
    echo ""
    echo "Options:"
    echo "  -d <directory>  Specify the target directory to organize."
    echo "  -c <criteria>   Choose the organization criteria:"
    echo "                   type  - Organize files by type (e.g., Images, Documents, Videos)"
    echo "                   size  - Organize files by size (e.g., Small, Medium, Large)"
    echo "                   date  - Organize files by modification date (e.g., Year-Month folders)"
    echo ""
    echo "Examples:"
    echo "  $0 -d ~/Downloads -c type"
    echo "      Organize all files in the ~/Downloads folder into subfolders based on file type."
    echo ""
    echo "  $0 -d ~/Documents -c size"
    echo "      Organize all files in the ~/Documents folder into 'Small', 'Medium', and 'Large' subfolders based on file size."
    echo ""
    echo "  $0 -d /path/to/folder -c date"
    echo "      Organize all files in the specified folder into subfolders by the year and month they were last modified."
    echo ""
    exit 1
}
if [[ $# -lt 1 ]]; then
    usage
fi

first_input=$1
second_input=$2

case "$first_input" in
    delete)
        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 delete <directory> <days>"
            exit 1
        fi
        ./date_delete.sh "$second_input" "$3"
        ;;
    encrypt)
        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 encrypt <encrypt|decrypt> <filename>"
            exit 1
        fi
        ./file_encryptor.sh "$second_input" "$3"
        ;;
    organize)
        if [[ $# -ne 3 ]]; then
            echo "Usage: $0 organize <directory> <criteria>"
            exit 1
        fi
        ./organize.sh -d "$second_input" -c "$3"
        ;;
    *) #basically any other case
        echo "Command does not exist: $first_input"
        usage
        ;;
esac

