#!/bin/bash

LOG_FILE="restore.log"

usage() {
    echo "Usage: $0 -d <directory> -c <criteria>"
    echo "       $0 -r"
    echo "       $0 --help"
    echo ""
    echo "Use --help to display detailed information about this script."
    exit 1
}

help() {
    echo "Organize Script"
    echo ""
    echo "This script organizes files in a specified directory based on various criteria."
    echo "It can also restore files to their original locations using a backup log."
    echo ""
    echo "Usage:"
    echo "  $0 -d <directory> -c <criteria>"
    echo "      Organizes files in the specified directory based on the chosen criteria."
    echo "  $0 -r"
    echo "      Restores files to their original locations using the restore log."
    echo "  $0 --help"
    echo "      Displays this help message."
    echo ""
    echo "Options:"
    echo "  -d <directory>  Specify the target directory to organize."
    echo "  -c <criteria>   Choose the organization criteria:"
    echo "                   type  - Organize files by type (e.g., Images, Documents, Videos)."
    echo "                   size  - Organize files by size (e.g., Small, Medium, Large)."
    echo "                   date  - Organize files by modification date (e.g., Year-Month folders)."
    echo "  -r              Restore files to their original locations using the restore log."
    echo ""
    echo "Examples:"
    echo "  $0 -d ~/Downloads -c type"
    echo "      Organizes files in the ~/Downloads folder by file type."
    echo ""
    echo "  $0 -d ~/Documents -c size"
    echo "      Organizes files in the ~/Documents folder into 'Small', 'Medium', and 'Large' subfolders."
    echo ""
    echo "  $0 -d /path/to/folder -c date"
    echo "      Organizes files in the specified folder into subfolders by year and month of last modification."
    echo ""
    echo "  $0 -r"
    echo "      Restores files to their original locations using the restore log."
    echo ""
    echo "Note: The restore feature requires that a restore log (restore.log) exists and contains valid paths."
    echo ""
    exit 0
}

organize_by_type() {
    local target_dir="$1"

    # Backup metadata before organizing
    backup_metadata "$target_dir"

    # Create folders for the new criteria
    mkdir -p "$target_dir/Documents" "$target_dir/Code" "$target_dir/Images" "$target_dir/Other"

    # Move files based on extensions
    for file in "$target_dir"/*; do
        if [ -f "$file" ]; then
            case "${file##*.}" in
                # Documents
                pdf|doc|docx|txt|rtf|odt)
                    mv "$file" "$target_dir/Documents/"
                    ;;
                # Code
                py|java|c|cpp|js|html|css|rb|go|sh|php|swift|rs|kt|ts)
                    mv "$file" "$target_dir/Code/"
                    ;;
                # Images
                jpg|jpeg|png|gif|bmp|tiff|svg|heic|webp)
                    mv "$file" "$target_dir/Images/"
                    ;;
                # Other
                *)
                    mv "$file" "$target_dir/Other/"
                    ;;
            esac
        fi
    done
}

backup_metadata() {
    echo "Backing up file metadata to $LOG_FILE..."
    > "$LOG_FILE"
    for file in "$1"/*; do
        if [ -f "$file" ]; then
            echo "$(realpath "$file")" >> "$LOG_FILE"
        fi
    done
}

restore_files() {
    local target_dir="$1"
    
    if [ ! -f "$LOG_FILE" ]; then
        echo "Error: No restore log found. Cannot restore files."
        exit 1
    fi

    echo "Restoring files to their original locations..."
    while IFS= read -r original_path; do
        file_name=$(basename "$original_path")
        current_path=$(find "$(dirname "$original_path")" -name "$file_name" 2>/dev/null | head -n 1)

        if [ -n "$current_path" ] && [ "$current_path" != "$original_path" ]; then
            mv "$current_path" "$original_path"
        fi
    done < "$LOG_FILE"
    
    for entry in "$target_dir"/*; do
        if [ -d "$entry" ]; then
                # delete directories created
                if [[ "$entry" =~ (Images|Documents|Code|Other|Small|Medium|Large)$ ]]; then
                    rm -r "$entry"
                fi 
                if [[ "$entry" =~ [0-9]{4}-[0-9]{2}$ ]]; then
                    rm -r "$entry"
                fi
        fi
    done
    echo "Restoration complete."
}

organize_by_size() {
    local target_dir="$1"
    mkdir -p "$target_dir/Small" "$target_dir/Medium" "$target_dir/Large"

    for file in "$target_dir"/*; do
        if [ -f "$file" ]; then
            size=$(stat -c%s "$file")
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

organize_by_date() {
    local target_dir="$1"
    for file in "$target_dir"/*; do
        if [ -f "$file" ]; then
            mod_date=$(date -r "$file" +"%Y-%m")
            mkdir -p "$target_dir/$mod_date"
            mv "$file" "$target_dir/$mod_date/"
        fi
    done
}

organize_recursive() {
    local target_dir="$1"
    local criteria="$2"

    for entry in "$target_dir"/*; do
        if [ -d "$entry" ]; then
            # Skip directories created during organization
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
            # Recursively process subdirectories
            organize_recursive "$entry" "$criteria"
        elif [ -f "$entry" ]; then
            # Perform the organization for the current directory
            case "$criteria" in
                type) organize_by_type "$target_dir" ;;
                size) organize_by_size "$target_dir" ;;
                date) organize_by_date "$target_dir" ;;
                *) echo "Invalid criteria"; usage ;;
            esac
            break
        fi
    done

    case "$criteria" in
        type) echo "Files have been organized by type.";;
        size) echo "Files have been organized by size.";;
        date) echo "Files have been organized by modification date.";;
    esac
}

if [[ "$1" == "--help" ]]; then
    help
    exit 0
fi

while getopts "d:c:r" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        c) criteria="$OPTARG" ;;
        r) restore=1 ;;
        *) usage ;;
    esac
done

if [ "$restore" == "1" ]; then
    restore_files
    exit 0
fi

if [ -z "$directory" ] || [ -z "$criteria" ]; then
    usage
fi

backup_metadata
organize_recursive "$directory" "$criteria"