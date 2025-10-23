#!/bin/bash

#==============================================================================
# 💦 SPLA.SH - Shell Utility Library
#==============================================================================
# Author: Luciano Soares
# Repository: https://github.com/soaresluciano/splash
#==============================================================================

# CONSTANTS
#==============================================================================

# Boolean constants using bash convention (0 = success, 1 = failure)
success=0
failure=1

# COLOR CODES AND FORMATTING
#==============================================================================

# ANSI color codes for terminal output
# Standard colors (30-37) and bright colors (90-97)
declare -A color_codes=(
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
declare -A format_options=(
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

# Gets the directory of the script that sourced this library
# When this library is sourced from another script, returns the directory of that calling script
# Usage: script_dir=$(get_script_dir)
get_script_dir() {
    local script_path
    script_path=$(readlink -f "${BASH_SOURCE[1]}")
    dirname "$script_path"
}

# Gets the username of the current user
get_current_user() {
    echo "$USER"
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
        if is_not_empty "${color_codes[$arg]}"; then
            codes+=("${color_codes[$arg]}")
        # Check if it's a format
        elif is_not_empty "${format_options[$arg]}"; then
            codes+=("${format_options[$arg]}")
        fi
    done
    # Join codes with semicolons and create escape sequence
    if is_greater_than ${#codes[@]} 0; then
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
    styled bright_black "▪️ $1"
}

# Shows a suggestion message - for tips or suggestions
# Usage: show_suggestion "Consider using --verbose for more details"
show_suggestion () {
    styled yellow "💡 $1"
}

# Shows a key: value pair message
# Usage: show_keyvalue "name" "John Doe"
show_keyvalue () {
    local key="$1"
    local value="$2"
    echo -e "▫️ $(style cyan) $key${NC}: $value"
}

# Shows a question with optional answer options
# Usage: show_question "Continue?" "y/N"
# Usage: show_question "Enter your name"
show_question () {
    local question="$1"
    local options="$2"
    if is_not_empty "$options"; then
        styled bold bright_blue "❔ $question ($options)"
    else
        styled bold bright_blue "❔ $question"
    fi
}

show_test_result() {
    local description="$1"
    local result="$2"
    local details="${3:-}"
    local fix="${4:-}"

    echo -n "🔍 $description: "
    if is_success $result; then
        show_success "OK"
    else
        show_error "FAIL"
        if is_not_empty "$fix"; then
            show_suggestion "$fix"
        fi
    fi

    if is_not_empty "$details"; then
        show_log "$details"
    fi
    return $result
}

# Shows an attention banner - for bringing attention to very important notices
# Usage: banner_attention <message>
# Parameters:
#   message: Optional custom message to display instead of default "ATTENTION"
banner_attention() {
    local message="${1:-ATTENTION}"
    styled reverse bright_yellow "\n ! $message ! \n"
}

# Shows a completed banner - for indicating completion of a process
# Usage: banner_completed <message>
# Parameters:
#   message: Optional custom message to display instead of default "COMPLETED"
banner_completed() {
    local message="${1:-COMPLETED}"
    styled reverse bright_green "\n ✔  $message ✔  \n"
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
    if is_not_empty "$char_limit"; then
        read -s -p "> " -n "$char_limit" input  # silent read to avoid double echo
        echo "$input" >&2  # display the input to stderr (for user feedback, includes newline)
    else
        read -p "> " input
    fi
    echo "$input"  # return the input value to stdout
}

# Prompts user for yes/no confirmation
# Returns success for yes, failure for no
# Usage: if prompt_yesno "Continue?"; then ... fi
prompt_yesno() {
    local question="$1"
    local reply=$(prompt_question "$question" "y/N" 1)
    echo
    [[ $reply =~ ^[Yy]$ ]]
}

# Prompts user to proceed with an operation
# Returns success if user wants to proceed, failure otherwise
# Usage: if prompt_proceed "This will delete all files"; then ... fi
prompt_proceed() {
    local description="$1"
    show_warning "$description"
    if prompt_yesno "Do you want to proceed?"; then
        return $success
    else
        show_log "Operation cancelled by user."
        return $failure
    fi
}

# Prompts user about overwriting an existing resource
# Returns success if user wants to overwrite, failure otherwise
# Usage: if prompt_overwrite "config file"; then ... fi
prompt_overwrite() {
    local resource_name="$1"
    show_warning "The '$resource_name' already exists."
    if prompt_yesno "Do you want to overwrite it?"; then
        show_log "The '$resource_name' will be overwritten."
        return $success
    else
        show_log "Using existing '$resource_name'."
        return $failure
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
        show_question "$prompt" >&2
        local menu_line=""
        local i=1
        for option in "${options[@]}"; do
            menu_line+="$(style bright_black)[${NC}$(style cyan) $i${NC}: $option $(style bright_black)]${NC}  "
            ((i++))
        done
        echo -e "   $menu_line" >&2
    }
    # Capture user input
    local choice
    while true; do
        read -p "> " -n1 choice
        echo >&2  # move to new line after single character input
        if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice >= 1 && choice <= i - 1 )); then
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
file_get_permissions() {
    local filename="$1"
    file_exists "$filename" || {
        show_error "File '$filename' permissions cannot be determined."
        return
    }
    stat -c "%a" "$filename"
}

# Checks if a file or directory exists
# Returns success if path exists, failure if it doesn't
# Usage: if path_exists "/my/path" [-no-log]; then ... fi
# Parameters:
#   path: Path to check
#   --no-log: Suppress error logging - Optional boolean flag
path_exists() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    [ -e "$path" ]  || {
        _log_is_on && show_error "The path '$path' does not exist."
        return $failure
    }
    return $success
}

# Checks if a file or directory is readable
# Returns success if file is readable, failure if it isn't
# Usage: if path_is_readable "myfile.txt" [--no-log]; then ... fi
# Parameters:
#   path: Path to check
#   --no-log: Suppress error logging - Optional boolean flag
path_is_readable() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    [ -r "$path" ]  || {
        _log_is_on && show_error "The path '$path' is not readable."
        return $failure
    }
    return $success
}

# Checks if a file exists and is writable
# Returns success if file exists and is writable, failure if it isn't
# Usage: if path_is_writable "myfile.txt" [--no-log]; then ... fi
# Parameters:
#   path: Path to the file to check
#   --no-log: Suppress error logging - Optional boolean flag
path_is_writable() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    [ -w "$path" ]  || {
        _log_is_on && show_error "The path '$path' is not writable."
        return $failure
    }
    return $success
}

# Checks if a file exists
# Returns success if file exists, failure if it doesn't
# Usage: if file_exists "myfile.txt" [--no-log]; then ... fi
# Parameters:
#   filename: Path to the file to check
#   --no-log: Suppress error logging - Optional boolean flag
file_exists() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    [ -f "$filename" ]  || {
        _log_is_on && show_error "The file '$filename' does not exist."
        return $failure
    }
    return $success
}

# Checks if a directory exists
# Returns success if directory exists, failure if it doesn't
# Usage: if dir_exists "/my/directory" [--no-log]; then ... fi
# Parameters:
#   dir: Path to the directory to check
#   --no-log: Suppress error logging - Optional boolean flag
dir_exists() {
    _parse_common_params "$@"
    local dir="${_PARSED_ARGS[0]}"
    [ -d "$dir" ]  || {
        _log_is_on && show_error "The directory '$dir' does not exist."
        return $failure
    }
    return $success
}

# Checks if a directory exists and is readable
# Returns success if directory exists and is readable, failure if it isn't
# Usage: if dir_is_readable "/my/directory" [--sudo] [--no-log]; then ... fi
# Parameters:
#   dir: Path to the directory to check
#   --sudo: Use sudo for checks (only verifies directory exists) - Optional boolean flag
#   --no-log: Suppress error logging - Optional boolean flag
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
# Returns success if directory exists and is writable, failure if it isn't
# Usage: if dir_is_writable "/my/directory" [--sudo] [--no-log]; then ... fi
# Parameters:
#   dir: Path to the directory to check
#   --sudo: Use sudo for checks (only verifies directory exists) - Optional boolean flag
#   --no-log: Suppress error logging - Optional boolean flag
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
# Returns success if file exists and is readable, failure if it isn't
# Usage: if file_is_readable "myfile.txt" [--sudo] [--no-log]; then ... fi
# Parameters:
#   filename: Path to the file to check
#   --sudo: Use sudo for checks (only verifies file exists) - Optional boolean flag
#   --no-log: Suppress error logging - Optional boolean flag
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
# Returns success if file exists and is writable, failure if it isn't
# Usage: if file_is_writable "myfile.txt" [--sudo] [--no-log]; then ... fi
# Parameters:
#   filename: Path to the file to check
#   --sudo: Use sudo for checks (only verifies file exists) - Optional boolean flag
#   --no-log: Suppress error logging - Optional boolean flag
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
# Usage: path_create "/path/to/myfile.txt" [--sudo]
# Usage: path_create "/path/to/mydirectory" [--sudo]
# Parameters:
#   path: Full path to the file or directory whose parent directory path should be created
#   --sudo: Use sudo for directory creation - Optional boolean flag
path_create() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    local dir
    dir=$(dirname "$path")
    if ! dir_exists "$dir" --no-log; then
        ${_SUDO_CMD}mkdir -p "$dir"
        show_success "Directory path '$dir' created."
    fi
}

# Clears the contents of a file (truncates to zero bytes)
# Usage: file_clear <filename> [--sudo]
# Parameters:
#   filename: Path to the file to clear
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
# Usage: file_str_append <filename> <content> [--sudo]
# Parameters:
#   filename: Path to the file to append to
#   content: String content to append
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
#   --sudo: Use sudo for the file operations - Optional boolean flag
# Examples:
#   file_str_replace "config.txt" "old_value/new_value" "debug=success/debug=false"
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

file_str_contains() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    local substring="${_PARSED_ARGS[1]}"
    _build_args file_is_readable "$filename" || {
        show_error "The file '$filename' cannot be checked."
        return $failure
    }
    ${_SUDO_CMD}grep -qF "$substring" "$filename"
    return $?
}

# Creates a backup copy of a file with .original extension
# Only creates backup if the original file exists
# Usage: file_backup <filename> [--sudo]
# Parameters:
#   filename: Path to the file to backup
#   --sudo: Use sudo for the file operation - Optional boolean flag
file_backup () {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    _build_args file_exists "$filename" --no-log || {
        show_log "Nothing to backup. The file '$filename' does not exist."
        return
    }
    local suffix="bkp-$(date +%Y%m%d%H%M%S)"
    local backup_file="$filename.$suffix"
    ${_SUDO_CMD}cp "$filename" "$backup_file"
    show_success "Backup created: $backup_file"
}

# Overwrites the entire content of a file with specified content
# Usage: file_content_write <filename> <content> [--sudo] [--no-log]
# Parameters:
#   filename: Path to the file to overwrite
#   content: String content to write to the file
#   --sudo: Use sudo for the file operation - Optional boolean flag
#   --no-log: Suppress success logging - Optional boolean flag
file_content_write () {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    local content="${_PARSED_ARGS[1]}"
    _build_args file_is_writable "$filename" || {
        show_error "Nothing was written."
        return
    }
    echo "$content" | ${_SUDO_CMD}tee "$filename" >/dev/null
    _log_is_on && show_success "The content was written to $filename."
}

# Creates a file with specified content or creates an empty file if no content provided
# Prompts for overwrite and backup confirmation if the file already exists
# Usage: file_create_with_content <filename> [content] [--sudo]
# Parameters:
#   filename: Path to the file to create
#   content: Optional string content to write to the file. If omitted, creates an empty file
#   --sudo: Use sudo for the file operation - Optional boolean flag
file_create_with_content () {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    local content="${_PARSED_ARGS[1]:-}"
    if prompt_overwrite "$filename"; then
        if prompt_yesno "Do you want to backup '$filename' first?"; then
            file_backup "$filename"
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
# Usage: file_create_empty <filename> [--sudo]
# Parameters:
#   filename: Path to the file to create
#   --sudo: Use sudo for the file operation - Optional boolean flag
# Examples:
#   file_create_empty "/etc/myapp.conf" --sudo
file_create_empty() {
    _build_args file_create_with_content "$1" ""
}

# Copies a template file to a destination, removing existing destination first
# Usage: file_from_template <template> <destination> [--sudo]
# Parameters:
#   template: Path to the source template file
#   destination: Path where the template should be copied
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
# Usage: file_make_executable <filename> [--sudo]
# Parameters:
#   filename: Path to the file to make executable
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
# Usage: file_copy <source_file> <dest_file> [--sudo]
# Parameters:
#   source_file: Path to the source file to copy
#   dest_file: Path to the destination file
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
# Usage: file_move <source_file> <dest_file> [--sudo]
# Parameters:
#   source_file: Path to the source file to move
#   dest_file: Path to the destination file
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
# Usage: file_overwrite <source_file> <dest_file> [--sudo]
# Parameters:
#   source_file: Path to the source file to copy
#   dest_file: Path to the destination file
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
# Usage: file_delete <filename> [--sudo] [--ask]
# Parameters:
#   filename: Path to the file to delete
#   --ask: Prompt for confirmation before deletion -Optional boolean flag
#   --sudo: Use sudo for the file operation - Optional boolean flag
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
# Usage: dir_delete_recursive <directory> [--sudo] [--ask]
# Parameters:
#   dir: Path to the directory to delete
#   --ask: Prompt for confirmation before deletion - Optional boolean flag
#   --sudo: Use sudo for the file operation - Optional boolean flag
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

# Requests and validates sudo permissions with user feedback
# Usage: sudoing
sudoing () {
    show_warning "Elevated permission is required"
    show_info "Your password is required for elevated privileges"
    sudo echo "Script is running as $(whoami)"
}

# Checks if a command exists in the system
# Returns success if command exists, failure if it doesn't
# Usage: if command_exists "git"; then ... fi
command_exists() {
    echo "$(run_silent command -v "$1")"
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

# NETWORK OPERATIONS
#==============================================================================

# Downloads a file from a URL to a specified destination
# Uses curl or wget if available
# Usage: download_file <url> <destination> [--use_sudo]
# Parameters:
#   url: URL of the file to download
#   dest: Path where the file should be saved
#   --use_sudo: Use sudo for the download operation - Optional boolean flag
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

# COMPARISONS AND CHECKS
#==============================================================================

# Checks if a string is empty
# Usage: if is_empty "$variable"; then ... fi
# Returns success if string is empty, failure if it has content
is_empty() {
    [ -z "$1" ]
}

# Checks if a string is not empty
# Usage: if is_not_empty "$variable"; then ... fi
# Returns success if string is not empty, failure if it is empty
is_not_empty() {
    [ -n "$1" ]
}

# Compares two strings for exact equality
# Performs case-sensitive string comparison
# Returns success if strings are identical, failure otherwise
# Usage: if are_equal_str "hello" "hello"; then ... fi
# Parameters:
#   string1: First string to compare
#   string2: Second string to compare
are_equal_str() {
    [ "$1" == "$2" ]
}

# Compares two strings for equality ignoring case differences
# Converts both strings to lowercase before comparison
# Returns success if strings are equal (case-insensitive), failure otherwise
# Usage: if are_equal_str_ignore_case "Hello" "HELLO"; then ... fi
# Parameters:
#   string1: First string to compare
#   string2: Second string to compare
are_equal_str_ignore_case() {
    [[ "${1,,}" == "${2,,}" ]]
}

# Compares two numbers for arithmetic equality
# Treats both parameters as integers and performs numeric comparison
# Returns success if numbers are mathematically equal, failure otherwise
# Will error if either parameter is not a valid integer
# Usage: if are_equal_num "10" "10"; then ... fi
# Parameters:
#   number1: First number to compare (must be a valid integer)
#   number2: Second number to compare (must be a valid integer)
are_equal_num() {
    [ "$1" -eq "$2" ]
}

# Checks if the first number is arithmetically greater than the second
# Treats both parameters as integers and performs numeric comparison
# Returns success if first number > second number, failure otherwise
# Will error if either parameter is not a valid integer
# Usage: if is_greater_than "15" "10"; then ... fi
# Parameters:
#   number1: First number to compare (must be a valid integer)
#   number2: Second number to compare (must be a valid integer)
is_greater_than() {
    [ "$1" -gt "$2" ]
}

# Checks if the first number is arithmetically greater than or equal to the second
# Treats both parameters as integers and performs numeric comparison
# Returns success if first number >= second number, failure otherwise
# Will error if either parameter is not a valid integer
# Usage: if is_greater_than_or_equal "10" "10"; then ... fi
# Parameters:
#   number1: First number to compare (must be a valid integer)
#   number2: Second number to compare (must be a valid integer)
is_greater_than_or_equal() {
    [ "$1" -ge "$2" ]
}

# Checks if the first number is arithmetically less than the second
# Treats both parameters as integers and performs numeric comparison
# Returns success if first number < second number, failure otherwise
# Will error if either parameter is not a valid integer
# Usage: if is_less_than "5" "10"; then ... fi
# Parameters:
#   number1: First number to compare (must be a valid integer)
#   number2: Second number to compare (must be a valid integer)
is_less_than() {
    [ "$1" -lt "$2" ]
}

# Checks if the first number is arithmetically less than or equal to the second
# Treats both parameters as integers and performs numeric comparison
# Returns success if first number <= second number, failure otherwise
# Will error if either parameter is not a valid integer
# Usage: if is_less_than_or_equal "10" "15"; then ... fi
# Parameters:
#   number1: First number to compare (must be a valid integer)
#   number2: Second number to compare (must be a valid integer)
is_less_than_or_equal() {
    [ "$1" -le "$2" ]
}

# Checks if a string represents a valid integer number
# Returns success if the string is a valid integer, failure otherwise
# Usage: if is_integer "$variable"; then ... fi
# Parameters:
#   value: Value to check
is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

# Checks if a value represents success
# Returns success if the value is equal to success constant, failure otherwise
# Usage: if is_success "$variable"; then ... fi
# Parameters:
#   value: Value to check
is_success() {
    are_equal_str "$1" "$success"
}

# Checks if a value represents failure
# Returns success if the value is equal to failure constant, failure otherwise
# Usage: if is_failure "$variable"; then ... fi
# Parameters:
#   value: Value to check
is_failure() {
    are_equal_str "$1" "$failure"
}

# Checks if a string contains a specified substring
# Returns success if substring is found within the string, failure otherwise
# Usage: if contains_str "Hello, world!" "world"; then ... fi
# Parameters:
#   string: The main string to search within
#   substring: The substring to search for
contains_str() {
    local string="$1"
    local substring="$2"
    printf '%s' "$string" | grep -qF -- "$substring"
    return $?
}

# ASSERTIONS
#===============================================================================

# Asserts that a value is empty and displays an error message if not
# Displays error message using show_error if assertion fails
# Usage: assert_is_empty "$variable" "Custom error message"
# Parameters:
#   value: The value to check for emptiness
#   error_message: Optional custom error message (defaults to generic assertion message)
# Returns: success if value is empty, failure and shows error if not
assert_is_empty() {
    local value="$1"
    local error_message="${2:-Assertion failed: Expected empty value, but got non-empty.}"
    is_empty "$value" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that a value is not empty and displays an error message if it is
# Displays error message using show_error if assertion fails
# Usage: assert_is_not_empty "$variable" "Custom error message"
# Parameters:
#   value: The value to check for content
#   error_message: Optional custom error message (defaults to generic assertion message)
# Returns: success if value is not empty, failure and shows error if empty
assert_is_not_empty() {
    local value="$1"
    local error_message="${2:-Assertion failed: Expected non-empty value, but got empty.}"
    is_not_empty "$value" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that two strings are equal (case-sensitive) and displays an error message if not
# Displays error message using show_error if assertion fails
# Usage: assert_are_equal_str "expected" "actual" "Custom error message"
# Parameters:
#   str1: First string to compare
#   str2: Second string to compare
#   error_message: Optional custom error message (defaults to showing both values)
# Returns: success if strings are equal, failure and shows error if not
assert_are_equal_str() {
    local str1="$1"
    local str2="$2"
    local error_message="${3:-Assertion failed: Expected '$str1' to equal '$str2'.}"
    are_equal_str "$str1" "$str2" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that two strings are equal ignoring case and displays an error message if not
# Displays error message using show_error if assertion fails
# Usage: assert_are_equal_str_ignore_case "Expected" "actual" "Custom error message"
# Parameters:
#   str1: First string to compare
#   str2: Second string to compare
#   error_message: Optional custom error message (defaults to showing both values)
# Returns: success if strings are equal (case-insensitive), failure and shows error if not
assert_are_equal_str_ignore_case() {
    local str1="$1"
    local str2="$2"
    local error_message="${3:-Assertion failed: Expected '$str1' to equal '$str2' (case-insensitive).}"
    are_equal_str_ignore_case "$str1" "$str2" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that two numbers are arithmetically equal and displays an error message if not
# Displays error message using show_error if assertion fails
# Will error if either parameter is not a valid integer
# Usage: assert_are_equal_num "10" "10" "Custom error message"
# Parameters:
#   num1: First number to compare (must be a valid integer)
#   num2: Second number to compare (must be a valid integer)
#   error_message: Optional custom error message (defaults to showing both values)
# Returns: success if numbers are equal, failure and shows error if not
assert_are_equal_num() {
    local num1="$1"
    local num2="$2"
    local error_message="${3:-Assertion failed: Expected '$num1' to equal '$num2'.}"
    are_equal_num "$num1" "$num2" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that first number is greater than second and displays an error message if not
# Displays error message using show_error if assertion fails
# Will error if either parameter is not a valid integer
# Usage: assert_is_greater_than "15" "10" "Custom error message"
# Parameters:
#   num1: First number to compare (must be a valid integer)
#   num2: Second number to compare (must be a valid integer)
#   error_message: Optional custom error message (defaults to showing both values)
# Returns: success if num1 > num2, failure and shows error if not
assert_is_greater_than() {
    local num1="$1"
    local num2="$2"
    local error_message="${3:-Assertion failed: Expected '$num1' to be greater than '$num2'.}"
    is_greater_than "$num1" "$num2" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that first number is greater than or equal to second and displays an error message if not
# Displays error message using show_error if assertion fails
# Will error if either parameter is not a valid integer
# Usage: assert_is_greater_than_or_equal "10" "10" "Custom error message"
# Parameters:
#   num1: First number to compare (must be a valid integer)
#   num2: Second number to compare (must be a valid integer)
#   error_message: Optional custom error message (defaults to showing both values)
# Returns: success if num1 >= num2, failure and shows error if not
assert_is_greater_than_or_equal() {
    local num1="$1"
    local num2="$2"
    local error_message="${3:-Assertion failed: Expected '$num1' to be greater than or equal to '$num2'.}"
    is_greater_than_or_equal "$num1" "$num2" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that first number is less than second and displays an error message if not
# Displays error message using show_error if assertion fails
# Will error if either parameter is not a valid integer
# Usage: assert_is_less_than "5" "10" "Custom error message"
# Parameters:
#   num1: First number to compare (must be a valid integer)
#   num2: Second number to compare (must be a valid integer)
#   error_message: Optional custom error message (defaults to showing both values)
# Returns: success if num1 < num2, failure and shows error if not
assert_is_less_than() {
    local num1="$1"
    local num2="$2"
    local error_message="${3:-Assertion failed: Expected '$num1' to be less than '$num2'.}"
    is_less_than "$num1" "$num2" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that first number is less than or equal to second and displays an error message if not
# Displays error message using show_error if assertion fails
# Will error if either parameter is not a valid integer
# Usage: assert_is_less_than_or_equal "10" "15" "Custom error message"
# Parameters:
#   num1: First number to compare (must be a valid integer)
#   num2: Second number to compare (must be a valid integer)
#   error_message: Optional custom error message (defaults to showing both values)
# Returns: success if num1 <= num2, failure and shows error if not
assert_is_less_than_or_equal() {
    local num1="$1"
    local num2="$2"
    local error_message="${3:-Assertion failed: Expected '$num1' to be less than or equal to '$num2'.}"
    is_less_than_or_equal "$num1" "$num2" && return $success || { show_error "$error_message"; return $failure; }
}

# Asserts that the output of a command contains a given substring and matches expected status
# Usage:
#   assert_output_contains expected_status "expected substring" command arg1 arg2
# Parameters:
#   expected_status: Expected exit status of the command
#   expected_msg: The substring expected to be found in the command output
#   command: The command to run
#   arg1, arg2, ...: Arguments to pass to the command
# Returns:
#   success if the output contains the substring and status matches
#   failure and shows error if not
assert_output_contains() {
    local expected_status="$1"
    local expected_msg="$2"
    shift 2
    local actual_status
    run_output_contains actual_status "$expected_msg" "$@"
    local result=$?
    local error_message="The command returned an unexpected status: $actual_status"
    are_equal_num "$actual_status" "$expected_status" || { show_error "$error_message"; return $failure; }
    return $result
}

# FLOW
#==============================================================================

# Executes a flow using an associative array of steps
# Usage: flow_run flow_steps
# Parameters:
#   flow_steps: Name of associative array where keys are function names 
#               and values are step descriptions
# Example:
#   declare -A my_flow=(
#       [askSudo]="Request sudo privileges"
#       [updateSystem]="Update system packages"
#       [installApps]="Install applications"
#   )
#   flow_run my_flow
flow_run(){
    clear
    echo
    show_info "Starting flow execution"
    local -n flow_ref=$1
    local total_steps=${#flow_ref[@]}
    local step_num=1
    for step_function in "${!flow_ref[@]}"; do
        local step_description="${flow_ref[$step_function]}"
        local title="STEP: $step_description"
        show_header "[$step_num/$total_steps] $title"
        local selected=$(prompt_menu "Please select an option:" "Continue" "Skip" "Quit")
        case $selected in
            "Continue")
                show_log "Executing $title"
                echo
                if "$step_function"; then
                    echo
                    show_success "Step '$step_description' completed successfully"
                else
                    echo
                    show_error "Step '$step_description' failed with exit code $?"
                    prompt_yesno "Do you want to continue the flow despite the error?" || {
                        show_warning "Aborting flow execution due to error"
                        exit 1
                    }
                fi
                ;;
            "Skip")
                show_info "Skipping $title"
                ;;
            "Quit")
                echo
                show_warning "Aborting the flow execution"
                echo
                exit 0
                ;;
        esac
        ((step_num++))
    done
    banner_completed "Flow execution completed"
    exit 0
}

# RUN
#==============================================================================

# Runs a command and suppresses all output
# Usage: run_silent command arg1 arg2
# Parameters:
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
run_silent() {
    "$@" >/dev/null 2>&1
    printf '%s' "$?"
}

# Simulates interactive input for a command by piping predefined input
# Usage: run_autoinput "input1\ninput2\n" command arg1 arg
# Parameters:
#   input: Predefined input string with newline-separated inputs
#   command: Command to run that requires interactive input
#   arg1, arg2, ...: Arguments to pass to the command
run_autoinput() {
    local input="$1"
    shift
    printf '%s\n' "$input" | "$@"
    return "$?"
}

# Simulates interactive input for a command that runs silently
# Suppresses all output and returns only the exit code
# Usage: exit_code=$(run_autoinput_silent "input1\ninput2\n" command arg1 arg2)
# Parameters:
#   input: Predefined input string with newline-separated inputs
#   command: Command to run that requires interactive input
#   arg1, arg2, ...: Arguments to pass to the command
run_autoinput_silent() {
    local input="$1"
    shift
    # suppress output, and print exit code only.
    run_autoinput "$input" "$@" >/dev/null 2>&1
    return "$?"
}

# Runs a command and captures its output and exit status
# Usage: run_cmd_capture resultvar command arg1 arg2
# Parameters:
#   resultvar: Name of the associative array variable to receive output and status
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
# Returns:
#   Populates the associative array with keys 'output' and 'status'
run_cmd_capture() {
    local __resultvar="$1"
    shift

    local __output __status
    __output="$(
        {
            "$@"
        } 2>&1
    )"
    __status=$?

    declare -gA "$__resultvar"
    eval "$__resultvar[output]=\"\$__output\""
    eval "$__resultvar[status]=\"\$__status\""
}

# TESTING HELPERS
#==============================================================================

# Runs a test case command and captures output and status
# Usage: _testcase_run outvar expected_status command arg1 arg2
# Parameters:
#   outvar: Name of variable to receive command output
#   expected_status: Expected exit status (success/failure)
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
# Returns:
#   Populates outvar with command output
#   Returns success if command status matches expected_status, failure otherwise
_testcase_run() {
    local __outvar="$1"
    local expected_status="$2"
    shift 2

    run_cmd_capture result "$@"
    local cmd_status=${result[status]}
    local cmd_output=${result[output]}

    local actual_status=$failure
    is_success $cmd_status && actual_status=$success
    
    local test_result=$failure
    are_equal_str "$expected_status" "$actual_status" && test_result=$success

    eval "$__outvar=\"\${cmd_output}\""
    return "$test_result"
}

# Defines and runs a test case with expected status and optional output matching
# Usage: testcase expected_status "test name" "expected substring" command arg1 arg2
# Parameters:
#   expected_status: Expected exit status (success/failure)
#   test_name: Name/description of the test case
#   expected_str: Optional substring expected to be found in command output
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
# Returns:
#   Displays test result and updates test counters
testcase() {
    local expected_status="$1"
    local test_name="$2"
    local expected_str="${3:-}"
    shift 3

    _testcase_run actual_output "$expected_status" "$@"
    local testrun_result=$?

    local test_details final_test_result

    if is_not_empty "$expected_str"; then
        local str_found=$failure
        contains_str "$actual_output" "$expected_str" && str_found=$success

        test_details=""
        ! is_success $str_found && test_details="The expected string ($expected_str) was not found"

        final_test_result=$failure
        is_success $testrun_result && is_success $str_found && final_test_result=$success
    else
        final_test_result=$testrun_result
        test_details=""
    fi

    show_test_result "$test_name" "$final_test_result" "$test_details"
    _testcase_counter_increase "$final_test_result"

    return $test_result
}

# Convenience wrappers for common test case scenarios

# Defines a test case that is expected to pass
testcase_should_pass() {
    local test_name="$1"
    shift
    testcase $success "$test_name" "" "$@"
}

# Defines a test case that is expected to fail
testcase_should_fail() {
    local test_name="$1"
    shift
    testcase  $failure "$test_name" "" "$@"
}

# Defines a test case that is expected to pass and match a given output substring
testcase_should_pass_and_match() {
    local test_name="$1"
    local expected_msg="$2"
    shift 2
    testcase $success "$test_name" "$expected_msg" "$@"
}

# Defines a test case that is expected to fail and match a given output substring
testcase_should_fail_and_match() {
    local test_name="$1"
    local expected_msg="$2"
    shift 2
    testcase $failure "$test_name" "$expected_msg" "$@"
}

# Runs a series of test cases and summarizes results
# Usage: test_fixtures_run <fixture1> <fixture2> ...
# Parameters:
#   fixtures: Array of fixture function names to execute
test_fixtures_run() {
    local title="${1}"
    shift
    _testcase_counter_reset
    show_title "$title"
    for fixture in "$@"; do
        $fixture
    done
    echo
    _testcase_counter_summary
}

# INTERNAL TEST COUNTERS
#==============================================================================

# Resets the global test counter
_testcase_counter_reset(){
    TEST_RUNS=0
    TEST_PASSES=0
    TEST_FAILS=0
}

# Increases test counters based on test result
_testcase_counter_increase(){
    local test_result="$1"
    TEST_RUNS=$((TEST_RUNS + 1))
    if is_success "$test_result"; then
        TEST_PASSES=$((TEST_PASSES + 1))
    else
        TEST_FAILS=$((TEST_FAILS + 1))
    fi
}

# Displays a summary of test case results
_testcase_counter_summary() {
    show_title "Test Results"
    echo -e "▫️ $(style bright_blue bold) Total Runs:$(style blue) $TEST_RUNS${NC}"
    if [ $TEST_RUNS -eq 0 ]; then
        show_warning "No tests were executed."
        return
    fi
    echo -e "▫️ $(style bright_green bold) Passed:$(style green) $TEST_PASSES ($((TEST_PASSES * 100 / TEST_RUNS))%)${NC}"
    echo -e "▫️ $(style bright_red bold) Failed:$(style red) $TEST_FAILS ($((TEST_FAILS * 100 / TEST_RUNS))%)${NC}"
}

# VALIDATIONS
#==============================================================================

# Validates a single command
# Usage: validate_cmd "Description" command arg1 arg2
# Parameters:
#   description: Description of the command being validated
#   command: Command to run for validation
#   arg1, arg2, ...: Arguments to pass to the command
validate_cmd() {
    local description="$1"
    shift
    validate_cmd_show_suggestion "$description" "" "$@"
    return $?
}

# Validates a single command with a fix suggestion on failure
# Usage: validate_cmd_show_suggestion "Description" "Fix suggestion" command arg1 arg2
# Parameters:
#   description: Description of the command being validated
#   fix_suggestion: Suggestion message to show if validation fails
#   command: Command to run for validation
#   arg1, arg2, ...: Arguments to pass to the command
validate_cmd_show_suggestion() {
    local description="$1"
    local fix_suggestion="$2"
    shift 2
    _testcase_run actual_output "$success" "$@"
    local testrun_result=$?
    show_test_result "Validation: $description" "$testrun_result" "" "$fix_suggestion"
    return $testrun_result
}

# Validates multiple dependencies and exits if any are missing
# Usage: validate_dependencies "git" "curl" "wget"
# Parameters:
#   required_dependencies: Array of command names to validate
validate_dependencies() {
    local required_dependencies=("$@")
    local missing_dependencies=()
    local validation_failed=failure
    show_header "Checking dependencies"
    for dep in "${required_dependencies[@]}"; do
        if ! validate_cmd "$dep" command_exists "$dep"; then
            missing_dependencies+=("$dep")
            validation_failed=success
        fi
    done
    if [ "$validation_failed" = success ]; then
        show_warning "Missing dependencies: ${missing_dependencies[*]}"
        show_error "The script cannot continue without these dependencies."
        show_suggestion "Please install them and re-run the script."
        exit 1
    fi
    show_success "All dependencies are installed"
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
    if is_empty "$_GLOBAL_TEMP_DIR" || ! dir_exists "$_GLOBAL_TEMP_DIR" --no-log; then
        trap '_cleanup_temp_dir' EXIT
        _GLOBAL_TEMP_DIR=$(mktemp -d)
    fi
    echo "$_GLOBAL_TEMP_DIR"
}

# Internal cleanup function for the global temporary directory
_cleanup_temp_dir() {
    if is_not_empty "$_GLOBAL_TEMP_DIR" && dir_exists "$_GLOBAL_TEMP_DIR" --no-log; then
        dir_delete_recursive "$_GLOBAL_TEMP_DIR"
        _GLOBAL_TEMP_DIR=""
    fi
}

# INTERNAL
#==============================================================================

# Core parameter parsing logic - modifies global state and collects non-flag arguments
# Used by both _parse_common_params and _build_args
_parse_flags_and_args() {
    local -n args_ref=$1
    shift
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --sudo) _USE_SUDO=$success; shift ;;
            --no-sudo) _USE_SUDO=$failure; shift ;;
            --log) _USE_LOG=$success; shift ;;
            --no-log) _USE_LOG=$failure; shift ;;
            --ask) _USE_ASK=$success; shift ;;
            --no-ask) _USE_ASK=$failure; shift ;;
            *) args_ref+=("$1"); shift ;;
        esac
    done
}

# Common parameter parsing logic - returns parsed values via global variables
# This is internal and resets state each time to avoid bugs
_parse_common_params() {
    _USE_SUDO=$failure
    _USE_LOG=$success
    _USE_ASK=$failure
    _PARSED_ARGS=()
    _SUDO_CMD=""
    
    _parse_flags_and_args _PARSED_ARGS "$@"
    _SUDO_CMD=${_USE_SUDO:+sudo }
}

# Helper function to build arguments with conditional flags
_build_args() {
    local target_function="$1"
    shift

    # Save current state
    local saved_sudo=$_USE_SUDO
    local saved_log=$_USE_LOG
    local saved_ask=$_USE_ASK
    
    # Parse override flags and collect function arguments
    local args=()
    _parse_flags_and_args args "$@"
    
    # Add conditional flags based on current state (including overrides)
    ! _log_is_on && args+=(--no-log)
    _sudo_is_on && args+=(--sudo)
    _ask_is_on && args+=(--ask)

    # Call the function
    local result
    "$target_function" "${args[@]}"
    result=$?
    
    # Restore original state
    _USE_SUDO=$saved_sudo
    _USE_LOG=$saved_log
    _USE_ASK=$saved_ask
    
    return $result
}

# Returns success if sudo is enabled, failure otherwise
_sudo_is_on() {
    are_equal_num "$_USE_SUDO" $success
}

# Returns success if logging is enabled, failure otherwise
_log_is_on() {
    are_equal_num "$_USE_LOG" $success
}

# Returns success if sudo is enabled, failure otherwise
_ask_is_on() {
    are_equal_num "$_USE_ASK" $success
}

#==============================================================================
# END OF SPLA.SH LIBRARY
#==============================================================================