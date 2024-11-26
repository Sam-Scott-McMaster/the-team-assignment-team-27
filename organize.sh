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

organize_by_type() {
    local target_dir="$1"
    if [ ! -d "$target_dir" ]; then
        echo "Error: Target directory does not exist."
        exit 1
    fi

    # Create folders for each file type
    mkdir -p "$target_dir/Images" "$target_dir/Documents" "$target_dir/Videos" "$target_dir/Others"

    # Move files based on extensions
    for file in "$target_dir"/*; do
        if [ -f "$file" ]; then
            case "${file##*.}" in
                jpg|png|jpeg|gif)
                    mv "$file" "$target_dir/Images/"
                    ;;
                pdf|doc|docx|txt)
                    mv "$file" "$target_dir/Documents/"
                    ;;
                mp4|mkv|avi)
                    mv "$file" "$target_dir/Videos/"
                    ;;
                *)
                    mv "$file" "$target_dir/Others/"
                    ;;
            esac
        fi
    done

    echo "Files have been organized by type."
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

    echo "Files have been organized by size."
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

    echo "Files have been organized by modification date."
}

organize_recursive() {
    local target_dir="$1"
    local criteria="$2"

    for entry in "$target_dir"/*; do
        if [ -d "$entry" ]; then
            # Recursively call organize_recursive for subdirectories
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
}

while getopts "d:c:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        c) criteria="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ -z "$directory" ] || [ -z "$criteria" ]; then
    usage
fi

organize_recursive "$directory" "$criteria"