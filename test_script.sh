#!/bin/bash
#
# A simple framework for testing the bn scripts
#
# Returns the number of failed test cases.
#
# Format of a test:
#     test 'command' expected_return_value 'stdin text' 'expected stdout' 'expected stderr'
#
# Some example test cases are given. You should add more test cases.
#
# Sam Scott, McMaster University, 2024


# GLOBALS: tc = test case number, fails = number of failed cases
declare -i tc=0
declare -i fails=0

############################################
# Run a single test. Runs a given command 3 times
# to check the return value, stdout, and stderr
#
# GLOBALS: tc, fails
# PARAMS: $1 = command
#         $2 = expected return value
#         $3 = standard input text to send
#         $4 = expected stdout
#         $5 = expected stderr
# RETURNS: 0 = success, 1 = bad return, 
#          2 = bad stdout, 3 = bad stderr
############################################
test() {
    tc=tc+1

    local COMMAND=$1
    local RETURN=$2
	local STDIN=$3
    local STDOUT=$4
    local STDERR=$5

    # CHECK RETURN VALUE
    $COMMAND <<< "$STDIN" >/dev/null 2>/dev/null
    local A_RETURN=$?

    if [[ "$A_RETURN" != "$RETURN" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected Return: $RETURN"
        echo "   Actual Return: $A_RETURN"
        fails=$fails+1
        return 1
    fi

    # CHECK STDOUT
    local A_STDOUT=$(echo "$STDIN" | $COMMAND 2>/dev/null)

    if [[ "$STDOUT" != "$A_STDOUT" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDOUT: $STDOUT"
        echo "   Actual STDOUT: $A_STDOUT"
        fails=$fails+1
        return 2
    fi

# CHECK STDERR
    local A_STDERR=$(echo "$STDIN" | $COMMAND 2>&1 >/dev/null)

    if [[ "$STDERR" != "$A_STDERR" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDERR: $STDERR"
        echo "   Actual STDERR: $A_STDERR"
        fails=$fails+1
        return 3
    fi
    
    # SUCCESS
    echo "Test $tc Passed"
    return 0
}


# Script 1: date_delete.sh
test './date_delete.sh --help' 0 '' 'Usage: ./date_delete.sh <directory> <days>' ''
test './date_delete.sh a b c' 1 '' 'Invalid number of arguements' ''
# test './date_delete.sh nonexistentDirectory 1' 1 '' 'Error: nonexistentDirectory does not exist' ''
test './date_delete.sh testing 1' 0 '' 'No files found older than 1'

#Script 2: duplicate_delete.sh 
test './duplicate_delete.sh --help' 0 '' 'Usage: ./duplicate_delete.sh <directory>' ''
test './duplicate_delete.sh randomDirectory' 1 '' 'Error: randomDirectory does not exist' ''

test './duplicate_delete.sh testing' 0 'n' "Checking for duplicates in testing
The following duplicate files are being prepared to be deleted (only the first instance of the duplicate is kept): 
testing/test2.txt
testing/test3.txt
Are you sure you want to proceed? (y/n)
Operation cancelled. Exiting Program.
Exited Successfully" ''

test './duplicate_delete.sh testing' 0 '' "Checking for duplicates in testing
The following duplicate files are being prepared to be deleted (only the first instance of the duplicate is kept): 
testing/test2.txt
testing/test3.txt
Are you sure you want to proceed? (y/n)
Operation cancelled. Exiting Program.
Exited Successfully" ''

# Script 3: file_encryptor
test './file_encryptor.sh encrypt nonexistent.txt' 2 '' '' 'Error: Target '\''nonexistent.txt'\'' not found
Usage: ./file_encryptor.sh <encrypt|decrypt> <filename|folder>'

#Script 4: organize.sh

#Script 5: backup.sh and backup2.sh

test './backup.sh --help' 0 '' "Backup Script Help:
Usage: ./backup.sh <backup folder or -na> <input .txt file> 
Arguments:
  <backup folder or -na>: Specify a absolute path to folder for backups or use '-na' to create a default 'BACKUP' folder.
  <input file>: Absolute path to a text file listing absolute path of folders/files to back up (one per line).
  <time interval>: Specify backup frequency as:
    d - daily, w - weekly, m - monthly, or a number (#min) for minutes.
Example:
  ./backup.sh -na file_list.txt"
test './backup2.sh ./BACKUP ./backupFiles.txt' 0 '' 'All files copied successfully. Clearing input file.' ''

# return code
if [[ $fails -eq 0 ]]; then
    echo "All tests passed!"
    exit 0
else
    echo "$fails tests failed."
    exit $fails
fi
