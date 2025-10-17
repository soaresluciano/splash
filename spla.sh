#!/bin/bash

#==============================================================================
# SPLA.SH - Shell Utility Library
#==============================================================================
# A comprehensive bash utility library providing styled output, user interaction,
# system operations, and file manipulation functions.
#
# Features:
# - Dynamic color and formatting system with ANSI escape codes
# - User interface functions for titles, headers, messages, and prompts
# - Interactive menus and yes/no prompts
# - File operations with optional sudo support
# - System utility functions
#
# Author: Luciano Soares
# Repository: https://github.com/soaresluciano/splash
#==============================================================================

# CONSTANTS
#==============================================================================

# Boolean constants using bash convention (0 = true, 1 = false)
TRUE=0
FALSE=1

# COLOR CODES AND FORMATTING
#==============================================================================

# ANSI color codes for terminal output
# Standard colors (30-37) and bright colors (90-97)
declare -A COLORS=(
    ["black"]="30"
    ["red"]="31"
    ["green"]="32"
    ["yellow"]="33"
    ["blue"]="34"
    ["magenta"]="35"
    ["cyan"]="36"
    ["white"]="37"
    ["bright_black"]="90"
    ["bright_red"]="91"
    ["bright_green"]="92"
    ["bright_yellow"]="93"
    ["bright_blue"]="94"
    ["bright_magenta"]="95"
    ["bright_cyan"]="96"
    ["bright_white"]="97"
)

# ANSI formatting codes for text decoration
declare -A FORMATS=(
    ["bold"]="1"
    ["dim"]="2"
    ["underline"]="4"
    ["blink"]="5"
    ["reverse"]="7"
)

# ANSI reset code to clear all formatting
NC='\033[0m'

# UTILS
#==============================================================================

# Checks if a string is empty
# Usage: if is_empty "$variable"; then ... fi
# Returns TRUE if string is empty, FALSE if it has content
is_empty() {
    [ -z "$1" ]
}

# Checks if a string is not empty
# Usage: if is_not_empty "$variable"; then ... fi
# Returns TRUE if string is not empty, FALSE if it is empty
is_not_empty() {
    [ -n "$1" ]
}

# Gets the directory of the script that sourced this library
# When this library is sourced from another script, returns the directory of that calling script
# Usage: script_dir=$(get_script_dir)
get_script_dir() {
    local script_path
    script_path=$(readlink -f "${BASH_SOURCE[1]}")
    dirname "$script_path"
}

# STYLING FUNCTIONS
#==============================================================================

# Function to compose colors and formatting dynamically
# Combines any number of colors and formatting attributes into a single ANSI escape sequence
# 
# Usage: style [color] [format1] [format2] ...
# 
# Available colors:
#   black, red, green, yellow, blue, magenta, cyan, white
#   bright_black, bright_red, bright_green, bright_yellow, bright_blue, bright_magenta, bright_cyan, bright_white
# 
# Available formats:
#   bold, dim, underline, blink, reverse
# 
# Examples:
#   echo -e "$(style red)This is red text${NC}"
#   echo -e "$(style bold blue)This is bold blue text${NC}"
#   echo -e "$(style underline bright_red)This is underlined bright red text${NC}"
#
# Returns: ANSI escape sequence string (e.g., "\033[1;31m" for bold red)
style() {
    local codes=()
    local output=""
    
    # Process all arguments
    for arg in "$@"; do
        # Check if it's a color
        if [[ -n "${COLORS[$arg]}" ]]; then
            codes+=("${COLORS[$arg]}")
        # Check if it's a format
        elif [[ -n "${FORMATS[$arg]}" ]]; then
            codes+=("${FORMATS[$arg]}")
        fi
    done
    
    # Join codes with semicolons and create escape sequence
    if [[ ${#codes[@]} -gt 0 ]]; then
        local joined_codes=$(IFS=';'; echo "${codes[*]}")
        echo "\033[${joined_codes}m"
    fi
}

# Convenience function to apply styling and output text in one call
# Automatically handles the reset code, so no need to add ${NC}
# 
# Usage: styled [color] [format1] [format2] ... "text to display"
# 
# Available colors and formats: same as style() function
# 
# Examples:
#   styled red "This is red text"
#   styled bold blue "This is a bold blue text"
#   styled underline bright_red "This is an underlined bright red text"
styled() {
    local text="${@: -1}"  # Last argument is the text
    local style_args=("${@:1:$#-1}")  # All but last argument are style parameters
    
    echo -e "$(style "${style_args[@]}")${text}${NC}"
}

# UI MESSAGES
#==============================================================================

# Shows a main app title
# Usage: show_title "My Application Title"
show_title() {
    styled reverse bold magenta "\n$1\n"
}

# Shows a process or section header
# Usage: show_header "Processing Data"
show_header() {
    styled underline magenta "\n🟣 $1\n"
}

# Shows an error message - for error conditions
# Usage: show_error "File not found"
show_error() {
    styled red "❌ $1"
}

# Shows a warning message - for warning conditions
# Usage: show_warning "This action cannot be undone"
show_warning() {
    styled bright_yellow "⚠️ $1"
}

# Shows a success message - for successful operations
# Usage: show_success "Operation completed successfully"
show_success() {
    styled green "✅ $1"
}

# Shows an informational message - for general info
# Usage: show_info "Loading configuration file"
show_info() {
    styled cyan "ℹ️ $1"
}

# Shows a log message - for less critical info
# Usage: show_log "Connecting to database"
show_log () {
    styled bright_black "▫️ $1"
}

# Shows a suggestion message - for tips or suggestions
# Usage: show_suggestion "Consider using --verbose for more details"
show_suggestion () {
    styled yellow "💡 $1"
}

# Shows a question with optional answer options
# Usage: show_question "Continue?" "y/N"
# Usage: show_question "Enter your name"
show_question () {
    local question="$1"
    local options="$2"
    if [ -n "$options" ]; then
        styled blue "❔ $question ($options)"
    else
        styled blue "❔ $question"
    fi
}

# UI BANNERS
#==============================================================================

# Shows an attention banner - for bringing attention to very important notices
# Usage: banner_attention
banner_attention() {
    styled reverse bright_yellow "\n ! ATTENTION ! \n"
}

# USER INTERACTIONS
#==============================================================================

# Interactive functions for user input and prompts

# Displays a message and waits for user input to continue
# Usage: prompt_continue
prompt_continue() {
    styled blue "\n▶️ Press any key to continue...\n"
    echo
    read -r
}

# Prompts user for input with optional character limit
# Returns the user's input to stdout
# Usage: result=$(prompt_question "Enter your name")
# Usage: result=$(prompt_question "Choose option" "1-3" 1)
prompt_question() {
    local question="$1"
    local options="$2"
    local char_limit="$3"
    show_question "$question" "$options" >&2
    
    if [ -n "$char_limit" ]; then
        read -s -p "> " -n "$char_limit" input  # silent read to avoid double echo
        echo "$input" >&2  # display the input to stderr (for user feedback, includes newline)
    else
        read -p "> " input
    fi
    echo "$input"  # return the input value to stdout
}

# Prompts user for yes/no confirmation
# Returns TRUE for yes, FALSE for no
# Usage: if prompt_yesno "Continue?"; then ... fi
prompt_yesno() {
    local question="$1"
    local reply=$(prompt_question "$question" "y/N" 1)
    echo
    [[ $reply =~ ^[Yy]$ ]]
}

prompt_proceed() {
    local description="$1"
    warning "$description"
    if yesno "Do you want to proceed?"; then
        return $TRUE
    else
        show_log "Operation cancelled by user."
        return $FALSE
    fi
}

# Prompts user about overwriting an existing resource
# Returns TRUE if user wants to overwrite, FALSE otherwise
# Usage: if prompt_overwrite "config file"; then ... fi
prompt_overwrite() {
    local resource_name="$1"
    show_warning "The '$resource_name' already exists."
    if prompt_yesno "Do you want to overwrite it?"; then
        show_log "The '$resource_name' will be overwritten."
        return $TRUE
    else
        show_log "Using existing '$resource_name'."
        return $FALSE
    fi
}

# Displays a numbered menu and returns the selected option
# Usage: selected=$(prompt_menu "Choose an option" "Option 1" "Option 2" "Option 3")
prompt_menu() {
    local prompt="$1"
    shift
    local options=("$@")
    
    # Menu display
    {
        echo
        show_question "$prompt"
        
        local i=1
        for option in "${options[@]}"; do
            echo "   $i) $option"
            ((i++))
        done
    } >&2

    # Capture user input
    local choice
    while true; do
        read -p "> " -n1 choice
        echo >&2  # move to new line after single character input
        if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice >= 1 && choice < i )); then
            echo "${options[$((choice-1))]}"
            return 0
        else
            show_error "Invalid choice. Please enter a number between 1 and $((i-1))." >&2
        fi
    done
}

# FILE OPERATIONS
#==============================================================================

# Gets the owner (username) of a file
# Returns the username of the file owner, or nothing if file doesn't exist
# Usage: owner=$(file_get_owner "myfile.txt")
# Parameters:
#   filename: Path to the file to check
# Example:
#   owner=$(file_get_owner "/etc/passwd")
#   echo "File owner: $owner"  # Output: "File owner: root"
file_get_owner() {
    local filename="$1"
    file_exists "$filename" || {
        show_error "File '$filename' owner cannot be determined."
        return
    }
    stat -c "%U" "$filename"
}

# Gets the octal permissions of a file
# Returns the file permissions in octal format (e.g., "644", "755"), or nothing if file doesn't exist
# Usage: perms=$(file_get_permissions "myfile.txt")
# Parameters:
#   filename: Path to the file to check
# Examples:
#   perms=$(file_get_permissions "script.sh")
#   echo "Permissions: $perms"  # Output: "Permissions: 755"
#   
#   if [ "$(file_get_permissions "config.txt")" = "600" ]; then
#       echo "File has secure permissions"
#   fi
file_get_permissions() {
    local filename="$1"
    file_exists "$filename" || {
        show_error "File '$filename' permissions cannot be determined."
        return
    }
    stat -c "%a" "$filename"
}

# Checks if a file or directory exists
# Returns TRUE if path exists, FALSE if it doesn't
# Usage: if path_exists "/my/path"; then ... fi
# Parameters:
#   path: Path to check
#   log: Show error log - Optional boolean (TRUE/FALSE), defaults to TRUE
path_exists() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    [ -e "$path" ]  || {
        _log_is_on && show_error "The path '$path' does not exist."
        return $FALSE
    }
    return $TRUE
}

# Checks if a file or directory is readable
# Returns TRUE if file is readable, FALSE if it isn't
# Usage: if path_is_readable "myfile.txt"; then ... fi
# Parameters:
#   path: Path to check
#   log: Show error log - Optional boolean (TRUE/FALSE), defaults to TRUE
path_is_readable() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    [ -r "$path" ]  || {
        _log_is_on && show_error "The path '$path' is not readable."
        return $FALSE
    }
    return $TRUE
}

# Checks if a file exists and is writable
# Returns TRUE if file exists and is writable, FALSE if it isn't
# Usage: if path_is_writable "myfile.txt"; then ... fi
# Parameters:
#   path: Path to the file to check
#   log: Show error log - Optional boolean (TRUE/FALSE), defaults to TRUE
path_is_writable() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    [ -w "$path" ]  || {
        _log_is_on && show_error "The path '$path' is not writable."
        return $FALSE
    }
    return $TRUE
}

# Checks if a file exists
# Returns TRUE if file exists, FALSE if it doesn't
# Usage: if file_exists "myfile.txt"; then ... fi
# Parameters:
#   filename: Path to the file to check
#   log: Show error log - Optional boolean (TRUE/FALSE), defaults to TRUE
file_exists() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    [ -f "$filename" ]  || {
        _log_is_on && show_error "The file '$filename' does not exist."
        return $FALSE
    }
    return $TRUE
}

# Checks if a directory exists
# Returns TRUE if directory exists, FALSE if it doesn't
# Usage: if dir_exists "/my/directory"; then ... fi
# Parameters:
#   dir: Path to the directory to check
#   log: Show error log - Optional boolean (TRUE/FALSE), defaults to TRUE
dir_exists() {
    _parse_common_params "$@"
    local dir="${_PARSED_ARGS[0]}"
    [ -d "$dir" ]  || {
        _log_is_on && show_error "The directory '$dir' does not exist."
        return $FALSE
    }
    return $TRUE
}

# Checks if a directory exists and is readable
# Returns TRUE if directory exists and is readable, FALSE if it isn't
# Usage: if dir_is_readable "/my/directory" --sudo --no-log; then ... fi
# Parameters:
#   dir: Path to the directory to check
#   --sudo: Use sudo for checks (only verifies directory exists)
#   --no-log: Suppress error logging
dir_is_readable() {
    _parse_common_params "$@"
    local dir="${_PARSED_ARGS[0]}"
    if _sudo_is_on; then
        _build_args dir_exists "$dir" # sudo can read
    else
        _build_args dir_exists "$dir" && _build_args path_is_readable "$dir"
    fi
}

# Checks if a directory exists and is writable
# Returns TRUE if directory exists and is writable, FALSE if it isn't
# Usage: if dir_is_writable "/my/directory" --sudo --ask; then ... fi
# Parameters:
#   dir: Path to the directory to check
#   --sudo: Use sudo for checks (only verifies directory exists)
#   --no-log: Suppress error logging
dir_is_writable() {
    _parse_common_params "$@"
    local dir="${_PARSED_ARGS[0]}"
    if _sudo_is_on; then
        _build_args dir_exists "$dir" # sudo can write
    else
        _build_args dir_exists "$dir" && _build_args path_is_writable "$dir"
    fi
}

# Checks if a file exists and is readable
# Returns TRUE if file exists and is readable, FALSE if it isn't
# Usage: if file_is_readable "myfile.txt" --sudo --no-log; then ... fi
# Parameters:
#   filename: Path to the file to check
#   --sudo: Use sudo for checks (only verifies file exists)
#   --no-log: Suppress error logging
file_is_readable() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    if _sudo_is_on; then
        _build_args file_exists "$filename" # sudo can read
    else
        _build_args file_exists "$filename" && _build_args path_is_readable "$filename"
    fi
}

# Checks if a file exists and is writable
# Returns TRUE if file exists and is writable, FALSE if it isn't
# Usage: if file_is_writable "myfile.txt" --ask --sudo; then ... fi
# Parameters:
#   filename: Path to the file to check
#   --sudo: Use sudo for checks (only verifies file exists)
#   --no-log: Suppress error logging
file_is_writable() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    if _sudo_is_on; then
        _build_args file_exists "$filename" # sudo can write
    else
        _build_args file_exists "$filename" && _build_args path_is_writable "$filename"
    fi
}

# Creates the directory path for a given file or directory if it doesn't exist
# Usage: path_create "/path/to/myfile.txt" [use_sudo]
# Usage: path_create "/path/to/mydirectory" [use_sudo]
# Parameters:
#   filepath: Full path to the file or directory whose parent directory path should be created
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
path_create() {
    _parse_common_params "$@"
    local filepath="${_PARSED_ARGS[0]}"
    local dir
    dir=$(dirname "$filepath")
    if ! dir_exists "$dir" --no-log; then
        ${_SUDO_CMD}mkdir -p "$dir"
        show_success "Directory path '$dir' created."
    fi
}

# Clears the contents of a file (truncates to zero bytes)
# Usage: file_clear <filename> [use_sudo]
# Usage: file_clear_sudo <filename>
# Parameters:
#   filename: Path to the file to clear
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
file_clear() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    _build_args file_is_writable "$filename" || {
        show_error "Cannot clear the file '$filename'."
        return
    }
    ${_SUDO_CMD}truncate -s 0 "$filename"
}

# Appends a string to the end of a file
# Usage: file_str_append <filename> <content> [use_sudo]
# Usage: file_str_append_sudo <filename> <content>
# Parameters:
#   filename: Path to the file to append to
#   content: String content to append
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
file_str_append() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    local content="${_PARSED_ARGS[1]}"
    _build_args file_is_writable "$filename" || {
        show_error "Nothing was appended."
        return
    }

    echo "$content" | ${_SUDO_CMD}tee -a "$filename"
    show_success "The content was appended to $filename."
}

# Replaces multiple search-replace pairs in a file using sed
# Usage: file_str_replace <filename> <pair1> [pair2] [pair3] ... [--sudo]
# Parameters:
#   filename: Path to the file to modify
#   pairs: Array of strings in format "search/replace" (slash-separated)
#   --sudo: Use sudo for file operations - Optional boolean flag
# Examples:
#   file_str_replace "config.txt" "old_value/new_value" "debug=true/debug=false"
#   file_str_replace "system.conf" "localhost/production.server" "port=3000/port=8080"
#   file_str_replace "/etc/hosts" "127.0.0.1/192.168.1.1" --sudo
file_str_replace() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    local pairs=("${_PARSED_ARGS[@]:1}")
    _build_args file_is_writable "$filename" || {
        show_error "No replacements made."
        return
    }
    for pair in "${pairs[@]}"; do
        ${_SUDO_CMD}sed -i "s/$pair/" "$filename"
    done
    show_success "The $filename was processed with ${#pairs[@]} replacements."
}

# Creates a backup copy of a file with .original extension
# Only creates backup if the original file exists
# Usage: file_backup <filename> [use_sudo]
# Usage: file_backup_sudo <filename>
# Parameters:
#   filename: Path to the file to backup
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
file_backup () {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    # TODO: how to override _build_args specifically for this call?
    _build_args file_exists "$filename" --no-log || {
        show_log "Nothing to backup. The file '$filename' does not exist."
        return
    }
    # How about after the override? What happens with the original values?
    local suffix="bkp-$(date +%Y%m%d%H%M%S)"
    local backup_file="$filename.$suffix"
    ${_SUDO_CMD}cp "$filename" "$backup_file"
    show_success "Backup created: $backup_file"
}

# Overwrites the entire content of a file with specified content
# Usage: file_content_write <filename> <content> [use_sudo]
# Usage: file_content_write <filename> <content>
# Parameters:
#   filename: Path to the file to overwrite
#   content: String content to write to the file
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
#   log_success: Optional boolean (TRUE/FALSE), defaults to TRUE
file_content_write () {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    local content="${_PARSED_ARGS[1]}"
    _build_args file_is_writable "$filename" || {
        show_error "Nothing was written."
        return
    }
    echo "$content" | ${_SUDO_CMD}tee "$filename" >/dev/null
    _log_is_on show_success "The content was written to $filename."
}

# Creates a file with specified content or creates an empty file if no content provided
# Prompts for overwrite and backup confirmation if the file already exists
# Usage: file_create_with_content <filename> [content] [use_sudo]
# Usage: file_create_with_content_sudo <filename> [content]
# Parameters:
#   filename: Path to the file to create
#   content: Optional string content to write to the file. If omitted, creates an empty file
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
# Examples:
#   file_create_with_content "config.txt" "debug=true"
#   file_create_with_content "empty.txt"
#   file_create_with_content "/etc/myapp.conf" "server=localhost" $TRUE
file_create_with_content () {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    local content="${_PARSED_ARGS[1]:-}"
    if prompt_overwrite "$filename"; then
        if prompt_yesno "Do you want to backup '$filename' first?"; then
            backup "$filename"
        fi
    else
        show_log "No changes made. The existing file '$filename' will be used."
        return
    fi
    _build_args file_content_write "$filename" "$content"
    show_success "The file '$filename' was created."
}

# Creates an empty file at the specified path
# Prompts for overwrite confirmation if the file already exists
# Usage: file_create_empty <filename> [use_sudo]
# Parameters:
#   filename: Path to the file to create
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
# Examples:
#   file_create_empty "config.txt"
#   file_create_empty "/etc/myapp.conf" $TRUE
file_create_empty() {
    _build_args file_create_with_content "$1" ""
}

# Copies a template file to a destination, removing existing destination first
# Usage: file_from_template <template> <destination> [use_sudo]
# Usage: file_from_template_sudo <template> <destination>
# Parameters:
#   template: Path to the source template file
#   destination: Path where the template should be copied
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
file_from_template () {
    _parse_common_params "$@"
    local template="${_PARSED_ARGS[0]}"
    local destination="${_PARSED_ARGS[1]}"
    _build_args file_is_readable "$template"|| {
        show_error "The template file '$template' cannot be used to create files."
        return
    }
    local template_content=$(${_SUDO_CMD}cat "$template")
    _build_args file_create_with_content "$destination" "$template_content"
}

# Makes a file executable by adding execute permissions
# Usage: file_make_executable <filename> [use_sudo]
# Usage: file_make_executable_sudo <filename>
# Parameters:
#   filename: Path to the file to make executable
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
file_make_executable() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    _build_args file_is_writable "$filename" || {
        show_error "The file '$filename' cannot be made executable."
        return
    }
    ${_SUDO_CMD}chmod +x "$filename"
    show_success "The file '$filename' is now executable."
}

# Copies a file to a destination, creating the destination path if needed
# Usage: file_copy <source_file> <dest_file> [use_sudo]
# Usage: file_copy_sudo <source_file> <dest_file>
# Parameters:
#   source_file: Path to the source file to copy
#   dest_file: Path to the destination file
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
file_copy() {
    _parse_common_params "$@"
    local source_file="${_PARSED_ARGS[0]}"
    local dest_file="${_PARSED_ARGS[1]}"
    _build_args file_is_readable "$source_file" || {
        show_error "The file '$source_file' cannot be copied."
        return
    }
    _build_args path_create "$dest_file"
    ${_SUDO_CMD}cp "$source_file" "$dest_file"
    show_success "The file was copied to $dest_file."
}

# Moves a file to a destination, creating the destination path if needed
# Usage: file_move <source_file> <dest_file> [use_sudo]
# Usage: file_move_sudo <source_file> <dest_file>
# Parameters:
#   source_file: Path to the source file to move
#   dest_file: Path to the destination file
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
file_move() {
    _parse_common_params "$@"
    local source_file="${_PARSED_ARGS[0]}"
    local dest_file="${_PARSED_ARGS[1]}"
    _build_args file_is_readable "$source_file" || {
        show_error "The file '$source_file' cannot be moved."
        return
    }
    _build_args path_create "$dest_file"
    ${_SUDO_CMD}mv "$source_file" "$dest_file"
    show_success "The file was moved to $dest_file."
}

# Overwrites a file by copying a source file to a destination, creating the destination path if needed
# Prompts for overwrite confirmation if the destination file already exists
# Usage: file_overwrite <source_file> <dest_file> [use_sudo]
# Usage: file_overwrite_sudo <source_file> <dest_file>
# Parameters:
#   source_file: Path to the source file to copy
#   dest_file: Path to the destination file
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE 
file_overwrite() {
    _parse_common_params "$@"
    local source_file="${_PARSED_ARGS[0]}"
    local dest_file="${_PARSED_ARGS[1]}"
    _build_args file_is_readable "$source_file" || {
        show_error "The file '$source_file' cannot be copied."
        return
    }
    _build_args path_create "$dest_file"
    yes | ${_SUDO_CMD}cp "$source_file" "$dest_file"
    show_success "The file was copied to $dest_file."
}

# Deletes a file from the filesystem
# Only attempts deletion if the file exists
# Usage: file_delete <filename> [use_sudo]
# Parameters:
#   filename: Path to the file to delete
#   ask_confirmation: Prompt for confirmation before deletion - Optional boolean (TRUE/FALSE), defaults to FALSE
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
# Examples:
#   file_delete "temp.txt"
#   file_delete "/var/log/app.log" $TRUE
file_delete() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    _build_args file_exists "$filename" || {
        show_log "Nothing to delete. The file '$filename' does not exist."
        return
    }
    if _ask_is_on; then
        ! prompt_proceed "You are about to delete the file '$filename'." || {
            show_log "File deletion aborted."
            return
        }
    fi
    ${_SUDO_CMD}rm -f "$filename"
    show_success "The file '$filename' was deleted."
}

# Recursively deletes a directory and all its contents
# Only attempts deletion if the directory exists
# WARNING: This operation is irreversible and will delete all subdirectories and files
# Usage: dir_delete_recursive <directory> [use_sudo]
# Parameters:
#   dir: Path to the directory to delete
#   ask_confirmation: Prompt for confirmation before deletion - Optional boolean (TRUE/FALSE), defaults to FALSE
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
# Examples:
#   dir_delete_recursive "temp_folder"
#   dir_delete_recursive "/var/cache/myapp" $TRUE
dir_delete_recursive() {
    _parse_common_params "$@"
    local dir="${_PARSED_ARGS[0]}"
    _build_args dir_exists "$dir" || {
        show_log "Nothing to delete. The directory '$dir' does not exist."
        return
    }
    if _ask_is_on; then
        ! prompt_proceed "You are about to delete the directory '$dir' and all its contents recursively." || {
            show_log "Directory deletion aborted."
            return
        }
    fi
    ${_SUDO_CMD}rm -rf "$dir"
    show_success "The directory '$dir' was deleted."
}

# SYSTEM OPERATIONS
#==============================================================================

# System utility functions

# Requests and validates sudo permissions with user feedback
# Usage: sudoing
sudoing () {
    show_warning "Elevated permission is required"
    show_info "Your password is required for elevated privileges"
    sudo echo "Script is running as $(whoami)"
}

# Checks if a command exists in the system
# Returns TRUE if command exists, FALSE if it doesn't
# Usage: if command_exists "git"; then ... fi
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Sources a file if it exists
# Usage: source_if_exists "myfile.sh"
# Parameters:
#   filename: Path to the file to source
source_if_exists() {
    if file_is_readable "$1"; then
        source "$1"
    else
        show_error "File $1 cannot be sourced"
    fi
}

# SYSTEM INFO
#==============================================================================

# Gets the human-readable distribution name
# Returns the pretty name of the Linux distribution (e.g., "Ubuntu 22.04.3 LTS")
# Falls back to LSB release info if os-release is not available
# Usage: distro_name=$(system_distro_name)
# Example output: "Ubuntu 22.04.3 LTS", "Fedora Linux 38", "Arch Linux"
system_distro_name() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo "$DISTRIB_DESCRIPTION"
    else
        echo "Unknown"
    fi
}

# Gets the distribution identifier (short name)
# Returns the ID of the Linux distribution (e.g., "ubuntu", "fedora", "arch")
# Falls back to LSB release info if os-release is not available
# Usage: distro_id=$(system_distro_id)
# Example output: "ubuntu", "fedora", "arch", "debian"
system_distro_id() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo "$DISTRIB_ID"
    else
        echo "unknown"
    fi
}

# Gets the kernel version of the running system
# Returns the kernel release version string
# Usage: kernel_ver=$(system_kernel_version)
# Example output: "6.2.0-26-generic", "6.4.11-arch2-1"
system_kernel_version() {
    uname -r
}

# Gets the system architecture
# Returns the machine hardware architecture
# Usage: arch=$(system_architecture)
# Example output: "x86_64", "aarch64", "armv7l", "i686"
system_architecture() {
    uname -m
}

# Detects the current desktop environment
# Returns the name of the desktop environment or window manager
# Checks environment variables first, then falls back to process detection
# Usage: desktop=$(system_desktop_environment)
# Example output: "GNOME", "KDE", "XFCE", "MATE", "Cinnamon", "LXDE", "Unknown"
system_desktop_environment() {
    if is_not_empty "$XDG_CURRENT_DESKTOP"; then
        echo "$XDG_CURRENT_DESKTOP"
    elif is_not_empty "$DESKTOP_SESSION"; then
        echo "$DESKTOP_SESSION"
    elif is_not_empty "$GDMSESSION"; then
        echo "$GDMSESSION"
    elif pgrep -x "gnome-session" > /dev/null; then
        echo "GNOME"
    elif pgrep -x "startkde" > /dev/null; then
        echo "KDE"
    elif pgrep -x "xfce4-session" > /dev/null; then
        echo "XFCE"
    elif pgrep -x "lxsession" > /dev/null; then
        echo "LXDE"
    elif pgrep -x "mate-session" > /dev/null; then
        echo "MATE"
    elif pgrep -x "cinnamon-session" > /dev/null; then
        echo "Cinnamon"
    else
        echo "Unknown"
    fi
}

# Detects the current display server protocol
# Returns "X11", "Wayland", or "Unknown"
# Usage: display_server=$(system_display_server)
system_display_server() {
    if is_not_empty "$XDG_SESSION_TYPE"; then
        echo "$XDG_SESSION_TYPE"
    elif is_not_empty "$WAYLAND_DISPLAY"; then
        echo "Wayland"
    elif is_not_empty "$DISPLAY"; then
        echo "X11"
    else
        echo "Unknown"
    fi
}

# VALIDATIONS

validate_item() {
    local description="$1"
    local validation_command="$2"
    local fix_suggestion="$3"
    
    echo -n "🔍 Checking $description... "

    if eval "$validation_command" &>/dev/null; then
        show_success "OK"
        return 0
    else
        show_error "FAIL"
        if is_not_empty "$fix_suggestion"; then
            show_suggestion "Fix: $fix_suggestion"
        fi
        return 1
    fi
}

validate_dependencies() {
    local required_dependencies=("$@")
    local missing_dependencies=()
    local validation_failed=false

    show_header "Checking dependencies"

    for dep in "${required_dependencies[@]}"; do
        if ! validate_item "$dep" "command_exists $dep" "Install '$dep'"; then
            missing_dependencies+=("$dep")
            validation_failed=true
        fi
    done
    
    if [ "$validation_failed" = true ]; then
        show_warning "Missing dependencies: ${missing_dependencies[*]}"
        show_error "The script cannot continue without these dependencies."
        show_suggestion "Please install them and re-run the script."
        exit 1
    fi

    show_success "All dependencies are installed"
}

# NETWORK OPERATIONS
#==============================================================================

# Downloads a file from a URL to a specified destination
# Uses curl or wget if available
# Usage: download_file <url> <destination> [use_sudo]
# Parameters:
#   url: URL of the file to download
#   dest: Path where the file should be saved
#   use_sudo: Optional boolean (TRUE/FALSE), defaults to FALSE
download_file() {
    _parse_common_params "$@"
    local url="${_PARSED_ARGS[0]}"
    local dest="${_PARSED_ARGS[1]}"

    if command_exists "wget"; then
        ${_SUDO_CMD}wget -O "$dest" "$url"
    elif command_exists "curl"; then
        ${_SUDO_CMD}curl -L -o "$dest" "$url"
    else
        show_error "Neither curl nor wget is installed. Cannot download file."
        return 1
    fi
    show_success "File downloaded to $dest"
}

# WORKFLOW
#==============================================================================

# Executes a workflow using an associative array of steps
# Usage: flow_run workflow_steps
# Parameters:
#   workflow_steps: Name of associative array where keys are function names 
#                  and values are step descriptions
# 
# Example:
#   declare -A my_workflow=(
#       [askSudo]="Request sudo privileges"
#       [updateSystem]="Update system packages"
#       [installApps]="Install applications"
#   )
#   flow_run my_workflow
flow_run(){
    clear
    echo
    show_info "Starting workflow execution"
    
    # This function expects an associative array passed by reference
    local -n workflow_ref=$1
    local total_steps=${#workflow_ref[@]}
    local step_num=0

    for step_function in "${!workflow_ref[@]}"; do
        local step_description="${workflow_ref[$step_function]}"
        local title="STEP: $step_description"
        
        show_header "[$step_num/$total_steps] $title"

        local selected=$(prompt_menu "Please select an option:" "Continue" "Skip" "Quit")
        case $selected in
            "Continue")
                show_info "Executing $title"
                echo
                if "$step_function"; then
                    show_success "Step '$step_description' completed successfully"
                    echo
                else
                    show_error "Step '$step_description' failed with exit code $?"
                    show_warning "Workflow execution stopped due to error"
                    exit 1
                fi
                ;;
            "Skip")
                show_info "Skipping $title"
                echo
                ;;
            "Quit")
                echo
                show_warning "Aborting the script execution"
                echo
                exit 0
                ;;
        esac
        ((step_num++))
    done
    
    echo
    show_success "Workflow execution completed"
    echo
    exit 0
}

# TEMPORARY DIRECTORY MANAGEMENT
#==============================================================================

# Global temporary directory variable
_GLOBAL_TEMP_DIR=""

# Gets or creates the global temporary directory
# Creates the directory on first call, returns existing path on subsequent calls
# Automatically sets up cleanup trap on first call
# Usage: temp_dir=$(temp_dir_get)
# Returns: Path to the global temporary directory
# Example:
#   temp_dir=$(temp_dir_get)
#   mkdir -p "$temp_dir/subdir"
#   echo "data" > "$temp_dir/file.txt"
temp_dir_get() {
    if is_empty "$_GLOBAL_TEMP_DIR" || [ ! -d "$_GLOBAL_TEMP_DIR" ]; then
        trap '_cleanup_temp_dir' EXIT
        _GLOBAL_TEMP_DIR=$(mktemp -d)
    fi
    echo "$_GLOBAL_TEMP_DIR"
}

# Internal cleanup function for the global temporary directory
_cleanup_temp_dir() {
    if is_not_empty "$_GLOBAL_TEMP_DIR" && [ -d "$_GLOBAL_TEMP_DIR" ]; then
        dir_delete_recursive "$_GLOBAL_TEMP_DIR"
        _GLOBAL_TEMP_DIR=""
    fi
}

# INTERNAL
#==============================================================================

# Common parameter parsing logic - returns parsed values via global variables
# This is internal and resets state each time to avoid bugs
_parse_common_params() {
    # Reset state every time to avoid bugs
    _USE_SUDO=$FALSE
    _USE_LOG=$TRUE
    _USE_ASK=$FALSE
    _PARSED_ARGS=()
    _SUDO_CMD=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --sudo) _USE_SUDO=$TRUE; shift ;;
            --no-log) _USE_LOG=$FALSE; shift ;;
            --ask) _USE_ASK=$TRUE; shift ;;
            *) _PARSED_ARGS+=("$1"); shift ;;
        esac
    done
    
    # Set sudo command based on parsed flag
    _SUDO_CMD=${_USE_SUDO:+sudo }
}

# Helper function to build arguments with conditional flags
_build_args() {
    local target_function="$1"
    shift
    local args=("$@")
    
    # Add conditional flags based on parsed state
    [ "$_USE_LOG" -eq $FALSE ] && args+=(--no-log)
    [ "$_USE_SUDO" -eq $TRUE ] && args+=(--sudo)
    [ "$_USE_ASK" -eq $TRUE ] && args+=(--ask)

    "$target_function" "${args[@]}"
}

# Returns TRUE if sudo is enabled, FALSE otherwise
_sudo_is_on() {
    [ "$_USE_SUDO" -eq $TRUE ]
}

# Returns TRUE if logging is enabled, FALSE otherwise
_logs_is_on() {
    [ "$_USE_LOG" -eq $TRUE ]
}

# Returns TRUE if sudo is enabled, FALSE otherwise
_ask_is_on() {
    [ "$_USE_ASK" -eq $TRUE ]
}

#==============================================================================
# END OF SPLA.SH LIBRARY
#==============================================================================