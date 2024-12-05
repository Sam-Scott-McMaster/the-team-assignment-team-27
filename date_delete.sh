#!/bin/bash

# This utility deletes files in a specific directory that are older than a specified number of days.
# Aakash Satish, McMaster University, 400503380


#help screen
if [[ "$1" == "--help" ]]; 
then
   echo "Usage: ./date_delete.sh <directory> <days>"
   exit 0;
fi

#check if the correct number of arguements are provided
if [[ $# -ne 2 ]];
then 
   echo "Invalid number of arguements" 
   exit 1;
fi

#store arguements in variables
DIRECTORY=$1
FILE_DATE=$2

#check if the directory exists
if [[ ! -d "$DIRECTORY" ]];
then
   echo "Error: $DIRECTORY does not exist"
   exit 1;
fi 

#check for files older than the specified number of days
FILES=$(find "$DIRECTORY" -type f -mtime +$FILE_DATE)


#check if files were found
if [[ -z "$FILES" ]];
then 
   echo "No files found older than $FILE_DATE"
   exit 0;
fi

echo "The following files are being prepared to be deleted: "
echo "$FILES"

#prompt the user for confirmation
echo "Are you sure you want to proceed? (y/n)" 
read line
if [[ "$line" != "y" ]];
then
   echo "Operation cancelled. Exiting Program."
   echo "Exited Successfully"
   exit 0
fi 

#delete the files
find "$DIRECTORY" -type f -mtime +"$FILE_DATE" -exec rm -f {} \;

echo "Files older than $FILE_DATE days have been deleted successfully"






