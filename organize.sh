#!/bin/bash

LOG_FILE="restore.log"

###########################
# Display usage information
# Globals: None
# Arguments: None
# Outputs: Displays usage string on stderr
# Returns: None
###########################
usage() {
    echo "Usage: $0 -d <directory> -c <criteria>"
    echo "       $0 -d <directory> -r"
    echo "       $0 --help"
    echo ""
    echo "Use --help to display detailed information about this script."
    exit 1
}

###########################
# Display help information
# Globals: LOG_FILE
# Arguments: None
# Outputs: Displays help string on stdout
# Returns: None
###########################
help() {
    echo "Organize Script"
    echo ""
    echo "This script organizes files in a specified directory based on various criteria."
    echo "It can also restore files to their original locations using a backup log."
    echo ""
    echo "Usage:"
    echo "  $0 -d <directory> -c <criteria>"
    echo "      Organizes files in the specified directory based on the chosen criteria."
    echo "  $0 -d <directory> -r"
    echo "      Restores files to their original locations using the restore log."
    echo "  $0 --help"
    echo "      Displays this help message."
    echo ""
    echo "Options:"
    echo "  -d <directory>  Specify the target directory to organize or restore."
    echo "  -c <criteria>   Choose the organization criteria:"
    echo "                   type  - Organize files by type (e.g., Images, Documents, Code)."
    echo "                   size  - Organize files by size (e.g., Small, Medium, Large)."
    echo "                   date  - Organize files by modification date (e.g., Year-Month folders)."
    echo "  -r              Restore files to their original locations using the restore log."
    echo ""
    echo "Examples:"
    echo "  $0 -d ~/Downloads -c type"
    echo "      Organizes files in the ~/Downloads folder by file type into subfolders."
    echo ""
    echo "  $0 -d ~/Documents -c size"
    echo "      Organizes files in the ~/Documents folder into 'Small', 'Medium', and 'Large' subfolders."
    echo ""
    echo "  $0 -d /path/to/folder -c date"
    echo "      Organizes files in the specified folder into subfolders by year and month of last modification."
    echo ""
    echo "  $0 -d /path/to/folder -r"
    echo "      Restores files to their original locations using the restore log."
    echo ""
    echo "Note:"
    echo "  - The restore feature requires that a restore log ($LOG_FILE) exists and contains valid paths."
    echo "  - The specified directory must be the same as the one used during the organization step."
    echo ""

    exit 0  # Ensure successful exit
}

# Parse options and arguments
while getopts "d:c:r" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;  # Store directory argument
        c) criteria="$OPTARG" ;;   # Store criteria argument
        r) restore=1 ;;            # Set restore flag
        *) usage ;;
    esac
done

# Validate arguments for restore mode
if [ "$restore" == "1" ] && [ -z "$directory" ]; then
    echo "Error: Directory must be specified with -d when using -r."
    usage
fi

###########################
# Organize files by type
# Globals: None
# Arguments:
#   $1 - Target directory to organize
# Outputs:
#   Moves files into subdirectories (Documents, Code, Images, Other) based on file type
# Returns: None
###########################
organize_by_type() {
    local target_dir="$1"
    mkdir -p "$target_dir/Documents" "$target_dir/Code" "$target_dir/Images" "$target_dir/Other"

    for file in "$target_dir"/*; do
        if [ -f "$file" ]; then
            # Use file extension to determine type
            case "${file##*.}" in
                pdf|doc|docx|txt|rtf|odt) mv "$file" "$target_dir/Documents/" ;;
                py|java|c|cpp|js|html|css|rb|go|sh|php|swift|rs|kt|ts) mv "$file" "$target_dir/Code/" ;;
                jpg|jpeg|png|gif|bmp|tiff|svg|heic|webp) mv "$file" "$target_dir/Images/" ;;
                *) mv "$file" "$target_dir/Other/" ;;
            esac
        fi
    done
}

###########################
# Backup file metadata
# Globals:
#   LOG_FILE - File to store backup metadata
# Arguments:
#   $1 - Target directory to back up
# Outputs:
#   Writes full file paths to the LOG_FILE
# Returns: None
###########################
backup_metadata() {
    echo "Backing up file metadata to $LOG_FILE..."
    > "$LOG_FILE" # Truncate the log file before writing
    for file in "$1"/*; do
        if [ -f "$file" ]; then
            echo "$(realpath "$file")" >> "$LOG_FILE" # Record absolute file paths
        fi
    done
    echo "Backup complete."
}

###########################
# Restore files to original locations
# Globals:
#   LOG_FILE - File containing original file paths
# Arguments: None
# Outputs:
#   Moves files back to their original locations and removes organizational directories
# Returns:
#   Exits with error if LOG_FILE or target directory is missing
###########################
restore_files() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "Error: No restore log found. Cannot restore files."
        exit 1
    fi

    if [ ! -d "$directory" ]; then
        echo "Error: Specified directory '$directory' does not exist."
        exit 1
    fi

    echo "Restoring files to their original locations..."

    while IFS= read -r original_path; do
        file_name=$(basename "$original_path")
        # Find the current location of the file
        current_path=$(find "$directory" -name "$file_name" 2>/dev/null | head -n 1)

        if [ -n "$current_path" ]; then
            mv "$current_path" "$original_path"
        else
            echo "Warning: File '$file_name' not found in '$directory'. Skipping."
        fi
    done < "$LOG_FILE"

    echo "Extracting complete. Removing organizational directories..."
    rm -rf "$directory/Images" "$directory/Documents" "$directory/Code" "$directory/Other"
    rm -rf "$directory/Small" "$directory/Medium" "$directory/Large"
    find "$directory" -type d -name "[0-9][0-9][0-9][0-9]-[0-9][0-9]" -exec rm -rf {} +

    echo "Restoration complete. Organizational directories have been removed."
}

###########################
# Organize files by size
# Globals: None
# Arguments:
#   $1 - Target directory to organize
# Outputs:
#   Moves files into subdirectories (Small, Medium, Large) based on file size
# Returns: None
###########################
organize_by_size() {
    local target_dir="$1"
    mkdir -p "$target_dir/Small" "$target_dir/Medium" "$target_dir/Large"

    for file in "$target_dir"/*; do
        if [ -f "$file" ]; then
            size=$(stat -c%s "$file") # Get file size in bytes
            if [ "$size" -lt 1000000 ]; then
                mv "$file" "$target_dir/Small/"
            elif [ "$size" -lt 10000000 ]; then
                mv "$file" "$target_dir/Medium/"
            else
                mv "$file" "$target_dir/Large/"
            fi
        fi
    done
}

###########################
# Organize files by date
# Globals: None
# Arguments:
#   $1 - Target directory to organize
# Outputs:
#   Moves files into subdirectories based on modification date (e.g., YYYY-MM)
# Returns: None
###########################
organize_by_date() {
    local target_dir="$1"
    for file in "$target_dir"/*; do
        if [ -f "$file" ]; then
            mod_date=$(date -r "$file" +"%Y-%m") # Get modification date
            mkdir -p "$target_dir/$mod_date"
            mv "$file" "$target_dir/$mod_date/"
        fi
    done
}

###########################
# Recursively organize files
# Globals: None
# Arguments:
#   $1 - Target directory
#   $2 - Organization criteria (type, size, date)
# Outputs:
#   Organizes files in the directory and its subdirectories
#   Skips already organized folders to avoid reprocessing
# Returns: None
###########################
organize_recursive() {
    local target_dir="$1"
    local criteria="$2"

    echo "Organizing files in $target_dir..."

    # Call the appropriate organization function for the current directory
    case "$criteria" in
        type) organize_by_type "$target_dir" ;;
        size) organize_by_size "$target_dir" ;;
        date) organize_by_date "$target_dir" ;;
        *) echo "Invalid criteria"; usage ;;
    esac

    # Recurse into subdirectories
    for entry in "$target_dir"/*; do
        if [ -d "$entry" ]; then
            case "$criteria" in
                type) 
                    if [[ "$entry" =~ (Images|Documents|Code|Other)$ ]]; then
                        continue
                    fi
                    ;;
                size) 
                    if [[ "$entry" =~ (Small|Medium|Large)$ ]]; then
                        continue
                    fi
                    ;;
                date) 
                    if [[ "$entry" =~ [0-9]{4}-[0-9]{2}$ ]]; then
                        continue
                    fi
                    ;;
            esac
            organize_recursive "$entry" "$criteria"
        fi
    done

    # Display success message once per directory
    case "$criteria" in
        type) echo "Files have been organized by type." ;;
        size) echo "Files have been organized by size." ;;
        date) echo "Files have been organized by modification date." ;;
    esac
}

# Check if the user requested help
if [[ "$1" == "--help" ]]; then
    help
    exit 0
fi

# Ensure mandatory arguments are provided
if [ -z "$directory" ] || [ -z "$criteria" ]; then
    usage
fi

# Validate the directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Specified directory '$directory' does not exist."
    exit 1
fi

# Validate criteria input
if [[ "$criteria" != "type" && "$criteria" != "size" && "$criteria" != "date" ]]; then
    echo "Error: Invalid criteria '$criteria'."
    echo "Valid criteria are: type, size, date."
    exit 1
fi

# Perform restore if the restore flag is set
if [ "$restore" == "1" ]; then
    restore_files
    exit 0
fi

# Ensure mandatory arguments are provided
if [ -z "$directory" ] || [ -z "$criteria" ]; then
    usage
fi

# Backup metadata and start the recursive organization
backup_metadata "$directory"
organize_recursive "$directory" "$criteria"