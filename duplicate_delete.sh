#!/bin/bash

#check for correct number of arguments 
if [[ $# -ne 1 ]]; then 
   echo "Invalid number of arguments" 
   exit 1
fi

#display help screen
if [[ "$1" == "--help" ]]; then
   echo "Usage: ./duplicate_delete.sh <directory>"
   exit 0
fi

#assign the directory to a variable
DIRECTORY=$1

#check if the directory exiists
if [[ ! -d "$DIRECTORY" ]]; then
   echo "Error: $DIRECTORY does not exist"
   exit 1
fi 

#check for duplicates in the directory
echo "Checking for duplicates in $DIRECTORY"

#find the duplicates and store them in a file
find "$DIRECTORY" -type f -exec md5 {} + | \
sed 's/MD5 (\(.*\)) = \(.*\)/\2 \1/' | \
sort | awk '{
    if ($1 in seen)
        print $2
    else
        seen[$1] = $2
}' > duplicates.txt

#check if duplicates were found in the directory
if [[ ! -s duplicates.txt ]]; then
    echo "No duplicates were found in $DIRECTORY"
    rm duplicates.txt
    exit 0
fi

#display the duplicate that were found 
echo "The following duplicate files are being prepared to be deleted (only the first instance of the duplicate is kept):"
cat duplicates.txt

#prompt the user for confirmation
if [ -t 0 ]; then
    echo "Are you sure you want to proceed? (y/n)"
    read -r line
else
    line="n"  #default to 'n' in non-interactive mode (cancel the deletion)
fi

# Process the user's decision
if [[ "$line" == "y" ]]; then
    xargs -d '\n' rm -v < duplicates.txt
    echo "Duplicate files deleted. One version of each file was kept."
else
    echo "Operation cancelled. Exiting Program."
    echo "Exited Successfully"
    exit 0
fi

#remove the file containing the duplicates
rm duplicates.txt
exit 0
