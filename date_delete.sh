#!/bin/bash

if [[ "$1" == "--help" ]]; 
then
   echo "Usage"
   exit 0;
fi
if [[ $# -ne 2 ]];
then 
   echo "Invalid number of arguements" 
   exit 1;
fi

DIRECTORY=$1
FILE_DATE=$2

if [[ ! -d "DIRECTORY" ]];
then
   echo "Error: $DIRECTORY does not exist"
fi 

FILES=$(find "$DIRECTORY" -type f -mtime +$FILE_DATE)

if [[ -z "$FILES" ]];
then 
   echo "No files found older than $FILE_DATE"
   exit 0;
fi

echo "The following files are being prepared to be deleted: "
echo "$FILES"
echo "Are you sure you want to proceed? (y/n)" 
read line
if [[ "$line" != "y" ]];
then
   echo "Operation cancelled. Exiting Program."
   echo "Exited Successfully"
   exit 0
fi 

find "$DIRECTORY" -type f -mtime +"$FILE_DATE" -exec rm -f {} \;

echo "Files older than $FILE_DATE days have been deleted successfully"






