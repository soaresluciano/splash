#!/bin/bash

#==============================================================================
# 💦 SPLA.SH - Shell Utility Library
#==============================================================================
# Author: Luciano Soares
# Repository: https://github.com/soaresluciano/splash
#==============================================================================

# CONSTANTS
#==============================================================================

# Boolean constants using bash convention (0 = _success, 1 = _failure)
_success=0
_failure=1

# COLOR CODES AND FORMATTING
#==============================================================================

# ANSI color codes for terminal output
# Standard colors (30-37) and bright colors (90-97)
declare -A _color_codes=(
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
declare -A _text_formats=(
    ["bold"]="1"
    ["dim"]="2"
    ["underline"]="4"
    ["blink"]="5"
    ["reverse"]="7"
)

# ANSI reset code to clear all formatting
_nc='\033[0m'

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
#   echo -e "$(style red)This is red text${_nc}"
#   echo -e "$(style bold blue)This is bold blue text${_nc}"
#   echo -e "$(style underline bright_red)This is underlined bright red text${_nc}"
#
# Returns: ANSI escape sequence string (e.g., "\033[1;31m" for bold red)
style() {
    local codes=()
    local output=""
    # Process all arguments
    for arg in "$@"; do
        # Check if it's a color
        if is_not_empty "${_color_codes[$arg]}"; then
            codes+=("${_color_codes[$arg]}")
        # Check if it's a format
        elif is_not_empty "${_text_formats[$arg]}"; then
            codes+=("${_text_formats[$arg]}")
        fi
    done
    # Join codes with semicolons and create escape sequence
    if is_greater_than ${#codes[@]} 0; then
        local joined_codes=$(IFS=';'; echo "${codes[*]}")
        echo "\033[${joined_codes}m"
    fi
}

# Convenience function to apply styling and output text in one call
# Automatically handles the reset code, so no need to add ${_nc}
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
    echo -e "$(style "${style_args[@]}")${text}${_nc}"
}

# UI MESSAGES
#==============================================================================

# Shows a main app title
# Usage: show_title "My Application Title"
show_title() {
    styled reverse bold magenta "\n $1 \n"
}

# Shows a process or section header
# Usage: show_header "Processing Data"
show_header() {
    styled underline magenta "\n➔ $1\n"
}

# Shows an error message - for error conditions
# Usage: show_error "File not found"
show_error() {
    styled red "☒ $1"
}

# Shows a warning message - for warning conditions
# Usage: show_warning "This action cannot be undone"
show_warning() {
    styled bright_yellow "⚠ $1"
}

# Shows a success message - for successful operations
# Usage: show_success "Operation completed successfully"
show_success() {
    styled green "☑ $1"
}

# Shows an informational message - for general info
# Usage: show_info "Loading configuration file"
show_info() {
    styled cyan "🛈 $1"
}

# Shows a log message - for less critical info
# Usage: show_log "Connecting to database"
show_log () {
    styled bright_black "▫ $1"
}

# Shows a suggestion message - for tips or suggestions
# Usage: show_suggestion "Consider using --verbose for more details"
show_suggestion () {
    styled yellow "★ $1"
}

# Shows a key: value pair message
# Usage: show_keyvalue "name" "John Doe"
show_keyvalue () {
    local key="$1"
    local value="$2"
    echo -e "▪ $(style cyan) $key${_nc}: $value"
}

# Shows a question with optional answer options
# Usage: show_question "Continue?" "y/N"
# Usage: show_question "Enter your name"
show_question () {
    local question="$1"
    local options="$2"
    if is_not_empty "$options"; then
        styled bold bright_blue "⯑ $question ($options)"
    else
        styled bold bright_blue "⯑ $question"
    fi
}

show_test_result() {
    local description="$1"
    local result="$2"
    local details="${3:-}"
    local fix="${4:-}"

    echo -ne "  $(style blue)🗲${_nc} $description: "
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
    styled blue "\n▶ Press any key to continue...\n"
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
        return $_success
    else
        show_log "Operation cancelled by user."
        return $_failure
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
        return $_success
    else
        show_log "Using existing '$resource_name'."
        return $_failure
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
            menu_line+="$(style bright_black)[${_nc}$(style cyan) $i${_nc}: $option $(style bright_black)]${_nc}  "
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
        return $_failure
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
        return $_failure
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
        return $_failure
    }
    return $_success
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
        return $_failure
    }
    return $_success
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
        return $_failure
    }
    return $_success
}

# Checks if a path is a file
# Returns success if path is a file, failure if it isn't
# Usage: if path_is_file "myfile.txt"; then ... fi
# Parameters:
#   path: Path to check
path_is_file() {
    local path="$1"
    if file_exists "$path" --no-log; then
        return $_success
    fi
    if dir_exists "$path" --no-log; then
        return $_failure
    fi

    # Heuristic: inspect the final path component.
    # - hidden names (start with '.') are treated as not-a-file
    # - otherwise, if the basename contains a dot (e.g. file.txt) we treat it as a file
    local name
    name=$(basename -- "$path")
    [[ "$name" == .* ]] && return $_failure
    [[ "$name" == *.* ]] && return $_success
    return $_failure
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
        return $_failure
    }
    return $_success
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
        return $_failure
    }
    return $_success
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

# Creates the directory path for a given path if it doesn't exist
# Usage: path_create "/path/to/mydirectory" [--sudo]
# Parameters:
#   path: Full path to the directory whose parent directory path should be created
#   --sudo: Use sudo for directory creation - Optional boolean flag
path_create() {
    _parse_common_params "$@"
    local path="${_PARSED_ARGS[0]}"
    if path_is_file "$path"; then
        show_error "The path '$path' is a file. Cannot create directory path for a file."
        return $_failure
    fi

    if ! dir_exists "$path" --no-log; then
        echo "creating directory path '$path'"
        echo "sudo: ${_SUDO_CMD}"
        ${_SUDO_CMD}mkdir -p "$path"
        show_success "Directory path '$path' created."
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
        return $_failure
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
        show_error "Cannot append to the file '$filename'."
        return $_failure
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
        show_error "Cannot modify the file '$filename'."
        return $_failure
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
        return $_failure
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
file_backup() {
    _parse_common_params "$@"
    local filename="${_PARSED_ARGS[0]}"
    _build_args file_exists "$filename" --no-log || {
        show_log "Nothing to backup. The file '$filename' does not exist."
        return $_failure
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
    # _build_args file_is_writable "$filename" || {
    #     show_error "Nothing was written."
    #     return $_failure
    # }
    echo "$content" | ${_SUDO_CMD}tee "$filename" >/dev/null
    local result=$?
    if is_success $result; then
        _log_is_on && show_success "The content was written to $filename."
        return $_success
    else
        _log_is_on && show_error "The content could not be written to $filename."
        return $_failure
    fi
    
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
    if file_exists "$filename" --no-log; then
        if prompt_overwrite "$filename"; then
            if prompt_yesno "Do you want to backup '$filename' first?"; then
                file_backup "$filename"
            fi
        else
            show_log "No changes made. The existing file '$filename' will be used."
            return $_failure
        fi
    fi
    _build_args file_content_write "$filename" "$content"
    local result=$?
    if is_success $result; then
        show_success "The file '$filename' was created."
        return $_success
    else
        show_error "The file '$filename' could not be created."
        return $_failure
    fi
    
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
        return $_failure
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
        return $_failure
    }
    ${_SUDO_CMD}chmod +x "$filename"
    show_success "The file '$filename' is now executable."
}

# Copies a file to a destination, creating the destination path if needed
# Usage: file_copy <source_file> <dest_file> [--sudo]
# Parameters:
#   source_file: Path to the source file to copy
#   destination: Path to the destination file
#   --sudo: Use sudo for the file operation - Optional boolean flag
file_copy() {
    _parse_common_params "$@"
    local source_file="${_PARSED_ARGS[0]}"
    local destination="${_PARSED_ARGS[1]}"
    _build_args file_is_readable "$source_file" || {
        show_error "The file '$source_file' cannot be copied."
        return $_failure
    }
    _build_args path_create "$destination"
    ${_SUDO_CMD}cp "$source_file" "$destination"
    show_success "The file was copied to $destination."
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
        return $_failure
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
        return $_failure
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
        return $_failure
    }
    if _ask_is_on; then
        ! prompt_proceed "You are about to delete the file '$filename'." || {
            show_log "File deletion aborted."
            return $_failure
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
        return $_failure
    }
    if _ask_is_on; then
        ! prompt_proceed "You are about to delete the directory '$dir' and all its contents recursively." || {
            show_log "Directory deletion aborted."
            return $_failure
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
    sudo echo "⚿ Script is running as $(whoami)"
}

# Checks if a command exists in the system
# Returns success if command exists, failure if it doesn't
# Usage: if command_exists "git"; then ... fi
command_exists() {
    run_silent command -v "$1"
    return $?
}

# Sources a file if it exists
# Usage: source_if_exists "myfile.sh"
# Parameters:
#   filename: Path to the file to source
source_if_exists() {
    if file_is_readable "$1"; then
        source "$1"
        return $_success
    else
        show_error "File $1 cannot be sourced"
        return $_failure
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
    are_equal_str "$1" "$_success"
}

# Checks if a value represents failure
# Returns success if the value is equal to failure constant, failure otherwise
# Usage: if is_failure "$variable"; then ... fi
# Parameters:
#   value: Value to check
is_failure() {
    are_equal_str "$1" "$_failure"
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
    regex_match "$string" "$substring"
    return $?
}

# REGULAR EXPRESSIONS
#==============================================================================


# Performs a Perl-compatible regular expression match on a string
# Returns success if the pattern matches the string, failure otherwise
# Usage: if regex_match "Hello, world!" "world"; then ... fi
# Parameters:
#   string: The main string to search within
#   pattern: The Perl-compatible regex pattern to match
regex_match() {
    local string="$1"
    local pattern="$2"

    local grep_args;
    # Detect multiline flag (?s) at start of pattern
    if [[ "$pattern" == '(?s)'* ]]; then
        grep_args="Pzo"
    else
        grep_args="Pq"
    fi

    printf '%s\n' "$string" | grep -"$grep_args" "$pattern" >/dev/null
    return $?
}

# Builds a regex pattern that matches empty strings
# Usage: pattern=$(regex_empty)
# Returns: A regex pattern string
regex_build_empty() {
    printf "^$"
}

# Builds a regex pattern that matches non-empty strings
# Usage: pattern=$(regex_not_empty)
# Returns: A regex pattern string
regex_build_not_empty() {
    printf "^.+$"
}

# Builds a regex pattern that matches strings not containing the specified substring
# Usage: pattern=$(regex_not "forbidden")
# Parameters:
#   str: The substring that should not be present
# Returns: A regex pattern string
regex_build_not() {
    local str="$1"
    printf "(?s)^(?!.*$str).*\$"
}

# Builds a regex pattern that matches strings containing str1 but not str2
# Usage: pattern=$(regex_first_only "required" "forbidden")
# Parameters:
#   str1: The substring that must be present
#   str2: The substring that must not be present
# Returns: A regex pattern string
regex_build_first_only() {
    local str1="$1"
    local str2="$2"
    printf "(?s)(?=.*$str1)(?!.*$str2).*"
}

# Builds a regex pattern that matches strings containing all specified substrings
# Usage: pattern=$(regex_all "first" "second" "third")
# Parameters:
#   strs: Array of substrings that must all be present
# Returns: A regex pattern string
regex_build_all() {
    local IFS=' '
    local pattern=""
    for str in "$@"; do
        pattern+="(?=.*$str)"
    done
    printf "(?s)%s" "$pattern"
}

# Builds a regex pattern that matches strings containing any of the specified substrings
# Usage: pattern=$(regex_any "option1" "option2" "option3")
# Parameters:
#   strs: Array of substrings where at least one must be present
regex_build_any() {
    local IFS='|'
    local pattern=""
    for str in "$@"; do
        pattern+="$str|"
    done
    pattern="${pattern%|}"
    printf "(?s)($pattern)"
}

# Builds a regex pattern that matches strings containing none of the specified substrings
# Usage: pattern=$(regex_none "forbidden1" "forbidden2" "forbidden3")
# Parameters:
#   strs: Array of substrings that must not be present
regex_build_none() {
    local IFS='|'
    local pattern=""
    for str in "$@"; do
        pattern+="$str|"
    done
    pattern="${pattern%|}"
    printf "(?s)^(?!.*($pattern)).*\$"
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
    is_empty "$value" && return $_success || { show_error "$error_message"; return $_failure; }
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
    is_not_empty "$value" && return $_success || { show_error "$error_message"; return $_failure; }
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
    are_equal_str "$str1" "$str2" && return $_success || { show_error "$error_message"; return $_failure; }
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
    are_equal_str_ignore_case "$str1" "$str2" && return $_success || { show_error "$error_message"; return $_failure; }
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
    are_equal_num "$num1" "$num2" && return $success || { show_error "$error_message"; return $_failure; }
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
    is_greater_than "$num1" "$num2" && return $_success || { show_error "$error_message"; return $_failure; }
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
    is_greater_than_or_equal "$num1" "$num2" && return $_success || { show_error "$error_message"; return $_failure; }
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
    is_less_than "$num1" "$num2" && return $_success || { show_error "$error_message"; return $_failure; }
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
    is_less_than_or_equal "$num1" "$num2" && return $_success || { show_error "$error_message"; return $_failure; }
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
                    show_error "The execution of '$step_description' failed."
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

# RUNNERS
#==============================================================================

# Runs a command and suppresses all output
# Usage: run_silent command arg1 arg2
# Parameters:
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
run_silent() {
    "$@" >/dev/null 2>&1
    return $?
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
# Usage: test_run outvar expected_status command arg1 arg2
# Parameters:
#   outvar: Name of variable to receive command output
#   expected_status: Expected exit status (success/failure)
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
# Returns:
#   Populates outvar with command output
#   Returns success if command status matches expected_status, failure otherwise
test_run() {
    local __outvar="$1"
    local expected_status="$2"
    shift 2

    run_cmd_capture result "$@"
    local cmd_status=${result[status]}
    local cmd_output=${result[output]}

    local actual_status=$_failure
    is_success $cmd_status && actual_status=$_success

    local test_result=$_failure
    are_equal_str "$expected_status" "$actual_status" && test_result=$_success

    eval "$__outvar=\"\${cmd_output}\""
    return "$test_result"
}

# Reports the result of a test case and updates counters
# Usage: test_report "Test Name" test_result "Test Details"
# Parameters:
#   test_name: Name of the test case
#   test_result: Result of the test case (success/failure)
#   test_details: Optional details about the test case
test_report() {
    local test_name="$1"
    local test_result="$2"
    local test_details="${3:-}"
    show_test_result "$test_name" "$test_result" "$test_details"
    _test_counter_increase "$test_result"
}

# Runs a test case and checks if the exit status matches expected
# Usage: test_status_is expected_status "Test Name" command arg1 arg2
# Parameters:
#   expected_status: Expected exit status (success/failure)
#   test_name: Name of the test case
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
test_status_is() {
    local expected_status="$1"
    local test_name="$2"
    shift 2
    test_run actual_output "$expected_status" "$@"
    local testrun_result=$?
    test_report "$test_name" "$testrun_result"
}

# Runs a test case and checks if the output matches a regex pattern
# Usage: test_status_output_match expected_status "expected_regex" "Test Name" command arg1 arg2
# Parameters:
#   expected_status: Expected exit status (success/failure)
#   expected_regex: Perl-compatible regex pattern to match against output
#   test_name: Name of the test case
#   command: Command to run
#   arg1, arg2, ...: Arguments to pass to the command
test_status_output_match() {
    local expected_status="$1"
    local expected_regex="$2"
    local test_name="$3"
    shift 3
    test_run actual_output "$expected_status" "$@"
    local testrun_result=$?

    local str_found final_test_result test_details
    regex_match "$actual_output" "$expected_regex" && str_found=$_success || str_found=$_failure
    is_success $str_found && test_details="" || test_details="The expected pattern ($expected_regex) could not be matched in the output."
    is_success $testrun_result && is_success $str_found && final_test_result=$_success || final_test_result=$_failure
    test_report "$test_name" "$final_test_result" "$test_details"
}

# Runs a series of test cases and summarizes results
# Usage: test_fixtures_run <fixture1> <fixture2> ...
# Parameters:
#   fixtures: Array of fixture function names to execute
test_fixtures_run() {
    local title="${1}"
    shift
    _test_counter_reset
    show_title "$title"
    for fixture in "$@"; do
        show_header "Running fixture: $fixture"
        $fixture
    done
    echo
    _test_counter_summary
}

# INTERNAL TEST COUNTERS
#==============================================================================

# Resets the global test counter
_test_counter_reset(){
    _testcase_counter_total_runs=0
    _testcase_counter_total_passed=0
    _testcase_counter_total_failed=0
}

# Increases test counters based on test result
_test_counter_increase(){
    local test_result="$1"
    _testcase_counter_total_runs=$((_testcase_counter_total_runs + 1))
    if is_success "$test_result"; then
        _testcase_counter_total_passed=$((_testcase_counter_total_passed + 1))
    else
        _testcase_counter_total_failed=$((_testcase_counter_total_failed + 1))
    fi
}

# Displays a summary of test case results
_test_counter_summary() {
    show_title "Test Results"
    echo -e "▫️ $(style bright_blue bold) Total Runs:$(style blue) $_testcase_counter_total_runs${_nc}"
    if [ $_testcase_counter_total_runs -eq 0 ]; then
        show_warning "No tests were executed."
        return
    fi
    local pass_percentage=$((_testcase_counter_total_passed * 100 / _testcase_counter_total_runs))
    local fail_percentage=$((_testcase_counter_total_failed * 100 / _testcase_counter_total_runs))
    echo -e "▫️ $(style bright_green bold) Passed:$(style green) $_testcase_counter_total_passed ($pass_percentage%)${_nc}"
    echo -e "▫️ $(style bright_red bold) Failed:$(style red) $_testcase_counter_total_failed ($fail_percentage%)${_nc}"
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
    test_run actual_output "$_success" "$@"
    local testrun_result=$?
    show_test_result "Validating $description" "$testrun_result" "" "$fix_suggestion"
    return $testrun_result
}

# Validates multiple dependencies and exits if any are missing
# Usage: validate_dependencies "git" "curl" "wget"
# Parameters:
#   required_dependencies: Array of command names to validate
validate_dependencies() {
    local required_dependencies=("$@")
    local missing_dependencies=()
    local validation_failed=_failure
    for dep in "${required_dependencies[@]}"; do
        if ! validate_cmd "$dep" command_exists "$dep"; then
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

# TEMPORARY DIRECTORY MANAGEMENT
#==============================================================================

# Global temporary directory variable
_global_temp_dir=""

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
    if is_empty "$_global_temp_dir" || ! dir_exists "$_global_temp_dir" --no-log; then
        trap '_cleanup_temp_dir' EXIT
        _global_temp_dir=$(mktemp -d)
    fi
    echo "$_global_temp_dir"
}

# Internal cleanup function for the global temporary directory
_cleanup_temp_dir() {
    if is_not_empty "$_global_temp_dir" && dir_exists "$_global_temp_dir" --no-log; then
        dir_delete_recursive "$_global_temp_dir"
        _global_temp_dir=""
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
            --sudo) _USE_SUDO=$_success; shift ;;
            --no-sudo) _USE_SUDO=$_failure; shift ;;
            --log) _USE_LOG=$_success; shift ;;
            --no-log) _USE_LOG=$_failure; shift ;;
            --ask) _USE_ASK=$_success; shift ;;
            --no-ask) _USE_ASK=$_failure; shift ;;
            *) args_ref+=("$1"); shift ;;
        esac
    done
}

# Common parameter parsing logic - returns parsed values via global variables
# This is internal and resets state each time to avoid bugs
_parse_common_params() {
    _USE_SUDO=$_failure
    _USE_LOG=$_success
    _USE_ASK=$_failure
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
    are_equal_num "$_USE_SUDO" $_success
}

# Returns success if logging is enabled, failure otherwise
_log_is_on() {
    are_equal_num "$_USE_LOG" $_success
}

# Returns success if sudo is enabled, failure otherwise
_ask_is_on() {
    are_equal_num "$_USE_ASK" $_success
}

#==============================================================================
# END OF SPLA.SH LIBRARY
#==============================================================================