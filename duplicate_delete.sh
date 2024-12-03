#!/bin/bash

#check if the correct number of arguments are provided
if [[ $# -ne 1 ]];
then 
   echo "Invalid number of arguements" 
   exit 1;
fi

#check if the user wants help screen
if [[ "$1" == "--help" ]]; 
then
   echo "Usage: ./duplicate_delete.sh <directory>"
   exit 0;
fi

#assign the directory to a variable
DIRECTORY=$1

#check if the directory exists
if [[ ! -d "$DIRECTORY" ]];
then
   echo "Error: $DIRECTORY does not exist"
   exit 1;
fi 

#check for duplicates in the directory
echo "Checking for duplicates in $DIRECTORY"

#find the duplicates and store them in a file
find "$DIRECTORY" -type f -exec md5sum {} \; | \

#format the output to be easier to read
sed 's/MD5 (\(.*\)) = \(.*\)/\2 \1/' | \

#sort the output to be easier to read
sort | awk '{
    if ($1 in seen)
        print $2
    else
        seen[$1] = $2
}' > duplicates.txt #store the output in a file called duplicates.txt

#check if the duplicates file is empty meaning no duplicates were found
if [[ ! -s duplicates.txt ]];
then
    echo "No duplicates were found in $DIRECTORY"
    rm duplicates.txt
    exit 0;
fi

#display the duplicate files that are being prepared to be deleted
echo "The following duplicate files are being prepared to be deleted (only the first instance of the duplicate is kept): "
cat duplicates.txt

#ask the user if they want to proceed with deleting the duplicates
echo "Are you sure you want to proceed? (y/n)" 
read line

#if the user wants to proceed (y), delete the duplicates 
if [[ "$line" == "y" ]];
then
    #delete the duplicates using xargs to read the file and delete the files
    xargs rm -v < duplicates.txt
    #keep the first version of the duplicate
    echo "Duplicate files deleted. One version of each file was kept."
else
    #if the user does not want to proceed, exit the program
    echo "Operation cancelled. Exiting Program."
    echo "Exited Successfully"
    exit 0
fi

#delete the duplicates file (no longer needed)
rm duplicates.txt
exit 0


