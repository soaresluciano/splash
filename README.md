# 💦 SPLA.SH - Shell Utility Library

A comprehensive bash utility library providing styled output, user interaction, system operations, and file manipulation functions.

## Features

- 🎨 Dynamic color and formatting system with ANSI escape codes
- 💬 User interface functions for titles, headers, messages, and prompts
- 🔄 Interactive menus and yes/no prompts
- 📁 File operations with optional sudo support
- ⚙️ System utility functions
- 🌊 Workflow management system
- 📂 Temporary directory management

## Installation

1. Download the `spla.sh` file to your project directory
2. Source it in your bash script:

```bash
#!/bin/bash
source ./spla.sh

# Now you can use all the library functions
show_success "Library loaded successfully!"
```

## Constants

The library provides boolean constants following bash conventions:
- `TRUE=0` (bash true value)
- `FALSE=1` (bash false value)

## Color and Formatting System

### Available Colors
- **Standard colors**: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
- **Bright colors**: `bright_black`, `bright_red`, `bright_green`, `bright_yellow`, `bright_blue`, `bright_magenta`, `bright_cyan`, `bright_white`

### Available Formats
- `bold`, `dim`, `underline`, `blink`, `reverse`

### Styling Functions

#### `style [color] [format1] [format2] ...`
Composes colors and formatting into ANSI escape sequences.

```bash
echo -e "$(style red)This is red text${NC}"
echo -e "$(style bold blue)This is bold blue text${NC}"
echo -e "$(style underline bright_red)This is underlined bright red text${NC}"
```

#### `styled [color] [format1] [format2] ... "text"`
Applies styling and outputs text in one call (automatically handles reset).

```bash
styled red "This is red text"
styled bold blue "This is bold blue text"
styled underline bright_red "This is underlined bright red text"
```

## Utility Functions

#### `is_empty "string"`
Checks if a string is empty.

```bash
if is_empty "$variable"; then
    echo "Variable is empty"
fi
```

#### `is_not_empty "string"`
Checks if a string is not empty.

```bash
if is_not_empty "$variable"; then
    echo "Variable has content"
fi
```

#### `get_script_dir`
Gets the directory of the script that sourced this library.

```bash
script_dir=$(get_script_dir)
echo "Script directory: $script_dir"
```

## UI Messages

#### `show_title "title"`
Shows a main application title.

```bash
show_title "My Application"
```

#### `show_header "header"`
Shows a process or section header.

```bash
show_header "Processing Data"
```

#### `show_error "message"`
Shows an error message with ❌ icon.

```bash
show_error "File not found"
```

#### `show_warning "message"`
Shows a warning message with ⚠️ icon.

```bash
show_warning "This action cannot be undone"
```

#### `show_success "message"`
Shows a success message with ✅ icon.

```bash
show_success "Operation completed successfully"
```

#### `show_info "message"`
Shows an informational message with ℹ️ icon.

```bash
show_info "Loading configuration file"
```

#### `show_log "message"`
Shows a log message with ▫️ icon.

```bash
show_log "Connecting to database"
```

#### `show_suggestion "message"`
Shows a suggestion message with 💡 icon.

```bash
show_suggestion "Consider using --verbose for more details"
```

#### `show_question "question" ["options"]`
Shows a question with optional answer options.

```bash
show_question "Continue?" "y/N"
show_question "Enter your name"
```

## UI Banners

#### `banner_attention`
Shows an attention banner for very important notices.

```bash
banner_attention
```

## User Interactions

#### `prompt_continue`
Displays a message and waits for user input to continue.

```bash
prompt_continue
```

#### `prompt_question "question" ["options"] [char_limit]`
Prompts user for input with optional character limit.

```bash
result=$(prompt_question "Enter your name")
result=$(prompt_question "Choose option" "1-3" 1)
```

#### `prompt_yesno "question"`
Prompts user for yes/no confirmation. Returns 0 for yes, 1 for no.

```bash
if prompt_yesno "Continue?"; then
    echo "User said yes"
fi
```

#### `prompt_proceed "description"`
Shows a warning and asks if user wants to proceed.

```bash
if prompt_proceed "This will delete all files"; then
    echo "User confirmed"
fi
```

#### `prompt_overwrite "resource_name"`
Prompts user about overwriting an existing resource.

```bash
if prompt_overwrite "config file"; then
    echo "User wants to overwrite"
fi
```

#### `prompt_menu "prompt" "option1" "option2" ...`
Displays a numbered menu and returns the selected option.

```bash
selected=$(prompt_menu "Choose an option" "Option 1" "Option 2" "Option 3")
echo "You selected: $selected"
```

## File System Operations

### Path Operations

#### `path_exists "path" [log]`
Checks if a file or directory exists.

```bash
if path_exists "/my/path"; then
    echo "Path exists"
fi

# Disable error logging
if path_exists "/my/path" $FALSE; then
    echo "Path exists (no error message if missing)"
fi
```

#### `path_is_readable "path" [log]`
Checks if a path is readable.

```bash
if path_is_readable "myfile.txt"; then
    echo "File is readable"
fi
```

#### `path_is_writable "path" [log]`
Checks if a path is writable.

```bash
if path_is_writable "myfile.txt"; then
    echo "File is writable"
fi
```

#### `path_create "filepath" [use_sudo]`
Creates the directory path for a given file or directory.

```bash
path_create "/path/to/myfile.txt"
path_create "/path/to/myfile.txt" $TRUE  # with sudo
```

#### `path_create_sudo "filepath"`
Convenience function to create path with sudo.

```bash
path_create_sudo "/etc/myapp/config.txt"
```

### Directory Operations

#### `dir_exists "directory" [log]`
Checks if a directory exists.

```bash
if dir_exists "/my/directory"; then
    echo "Directory exists"
fi
```

#### `dir_is_readable "directory" [use_sudo] [log]`
Checks if a directory is readable.

```bash
if dir_is_readable "/my/directory"; then
    echo "Directory is readable"
fi

# With sudo
if dir_is_readable "/root/private" $TRUE; then
    echo "Directory is readable with sudo"
fi
```

#### `dir_is_writable "directory" [use_sudo] [log]`
Checks if a directory is writable.

```bash
if dir_is_writable "/my/directory"; then
    echo "Directory is writable"
fi
```

#### `dir_delete_recursive "directory" [ask_confirmation] [use_sudo]`
Recursively deletes a directory and all its contents.

⚠️ **WARNING**: This operation is irreversible!

```bash
dir_delete_recursive "temp_folder"
dir_delete_recursive "/var/cache/myapp" $TRUE  # with confirmation
dir_delete_recursive "/var/cache/myapp" $TRUE $TRUE  # with confirmation and sudo
```

#### `dir_delete_recursive_sudo "directory"`
Convenience function to delete directory with sudo (always asks for confirmation).

```bash
dir_delete_recursive_sudo "/opt/old-application"
```

### File Operations

#### `file_exists "filename" [log]`
Checks if a file exists.

```bash
if file_exists "myfile.txt"; then
    echo "File exists"
fi
```

#### `file_is_readable "filename" [use_sudo] [log]`
Checks if a file is readable.

```bash
if file_is_readable "myfile.txt"; then
    echo "File is readable"
fi
```

#### `file_is_writable "filename" [use_sudo] [log]`
Checks if a file is writable.

```bash
if file_is_writable "myfile.txt"; then
    echo "File is writable"
fi
```

#### `file_get_owner "filename"`
Gets the owner (username) of a file.

```bash
owner=$(file_get_owner "/etc/passwd")
echo "File owner: $owner"
```

#### `file_get_permissions "filename"`
Gets the octal permissions of a file.

```bash
perms=$(file_get_permissions "script.sh")
echo "Permissions: $perms"
```

#### `file_clear "filename" [use_sudo]`
Clears the contents of a file (truncates to zero bytes).

```bash
file_clear "logfile.txt"
file_clear "/var/log/app.log" $TRUE  # with sudo
```

#### `file_clear_sudo "filename"`
Convenience function to clear file with sudo.

```bash
file_clear_sudo "/var/log/system.log"
```

#### `file_str_append "filename" "content" [use_sudo]`
Appends a string to the end of a file.

```bash
file_str_append "config.txt" "new_setting=value"
file_str_append "/etc/hosts" "127.0.0.1 myhost" $TRUE
```

#### `file_str_append_sudo "filename" "content"`
Convenience function to append with sudo.

```bash
file_str_append_sudo "/etc/hosts" "127.0.0.1 myhost"
```

#### `file_str_replace "filename" "search/replace" ["search2/replace2"] ...`
Replaces multiple search-replace pairs in a file using sed.

```bash
file_str_replace "config.txt" "old_value/new_value" "debug=true/debug=false"
file_str_replace "system.conf" "localhost/production.server" "port=3000/port=8080"
```

#### `file_str_replace_sudo "filename" "search/replace" ...`
Convenience function to replace strings with sudo.

```bash
file_str_replace_sudo "/etc/config" "old/new"
```

#### `file_backup "filename" [use_sudo]`
Creates a backup copy of a file with timestamp extension.

```bash
file_backup "important.conf"
file_backup "/etc/nginx.conf" $TRUE
```

#### `file_backup_sudo "filename"`
Convenience function to backup with sudo.

```bash
file_backup_sudo "/etc/important.conf"
```

#### `file_content_write "filename" "content" [use_sudo] [log_success]`
Overwrites the entire content of a file.

```bash
file_content_write "config.txt" "debug=true"
file_content_write "/etc/app.conf" "server=localhost" $TRUE
```

#### `file_content_write_sudo "filename" "content"`
Convenience function to write content with sudo.

```bash
file_content_write_sudo "/etc/app.conf" "server=localhost"
```

#### `file_create_with_content "filename" ["content"] [use_sudo]`
Creates a file with specified content (prompts for overwrite if exists).

```bash
file_create_with_content "config.txt" "debug=true"
file_create_with_content "empty.txt"  # creates empty file
file_create_with_content "/etc/myapp.conf" "server=localhost" $TRUE
```

#### `file_create_with_content_sudo "filename" ["content"]`
Convenience function to create file with content using sudo.

```bash
file_create_with_content_sudo "/etc/system.conf" "enabled=true"
```

#### `file_create_empty "filename" [use_sudo]`
Creates an empty file.

```bash
file_create_empty "config.txt"
file_create_empty "/etc/myapp.conf" $TRUE
```

#### `file_create_empty_sudo "filename"`
Convenience function to create empty file with sudo.

```bash
file_create_empty_sudo "/etc/system.conf"
```

#### `file_from_template "template" "destination" [use_sudo]`
Copies a template file to a destination.

```bash
file_from_template "template.conf" "config.conf"
file_from_template "/usr/share/templates/app.conf" "/etc/app.conf" $TRUE
```

#### `file_from_template_sudo "template" "destination"`
Convenience function to copy from template with sudo.

```bash
file_from_template_sudo "template.conf" "/etc/config.conf"
```

#### `file_make_executable "filename" [use_sudo]`
Makes a file executable by adding execute permissions.

```bash
file_make_executable "script.sh"
file_make_executable "/usr/local/bin/myapp" $TRUE
```

#### `file_make_executable_sudo "filename"`
Convenience function to make file executable with sudo.

```bash
file_make_executable_sudo "/usr/local/bin/myapp"
```

#### `file_copy "source_file" "dest_file" [use_sudo]`
Copies a file to a destination.

```bash
file_copy "source.txt" "destination.txt"
file_copy "app.conf" "/etc/app.conf" $TRUE
```

#### `file_copy_sudo "source_file" "dest_file"`
Convenience function to copy file with sudo.

```bash
file_copy_sudo "app.conf" "/etc/app.conf"
```

#### `file_move "source_file" "dest_file" [use_sudo]`
Moves a file to a destination.

```bash
file_move "temp.txt" "permanent.txt"
file_move "app.conf" "/etc/app.conf" $TRUE
```

#### `file_move_sudo "source_file" "dest_file"`
Convenience function to move file with sudo.

```bash
file_move_sudo "app.conf" "/etc/app.conf"
```

#### `file_overwrite "source_file" "dest_file" [use_sudo]`
Overwrites a file by copying source to destination (without asking).

```bash
file_overwrite "new_config.txt" "config.txt"
file_overwrite "new_config.txt" "/etc/config.txt" $TRUE
```

#### `file_overwrite_sudo "source_file" "dest_file"`
Convenience function to overwrite file with sudo.

```bash
file_overwrite_sudo "new_config.txt" "/etc/config.txt"
```

#### `file_delete "filename" [ask_confirmation] [use_sudo]`
Deletes a file from the filesystem.

```bash
file_delete "temp.txt"
file_delete "important.txt" $TRUE  # asks for confirmation
file_delete "/var/log/app.log" $TRUE $TRUE  # confirmation and sudo
```

#### `file_delete_sudo "filename"`
Convenience function to delete file with sudo (always asks for confirmation).

```bash
file_delete_sudo "/etc/old-config.conf"
```

## System Operations

#### `sudoing`
Requests and validates sudo permissions with user feedback.

```bash
sudoing
```

#### `command_exists "command"`
Checks if a command exists in the system.

```bash
if command_exists "git"; then
    echo "Git is installed"
fi
```

#### `source_if_exists "filename"`
Sources a file if it exists and is readable.

```bash
source_if_exists "config.sh"
source_if_exists "$HOME/.bashrc"
```

## System Information

#### `system_distro_name`
Gets the human-readable distribution name.

```bash
distro=$(system_distro_name)
echo "Distribution: $distro"  # Output: "Ubuntu 22.04.3 LTS"
```

#### `system_distro_id`
Gets the distribution identifier (short name).

```bash
distro_id=$(system_distro_id)
echo "Distro ID: $distro_id"  # Output: "ubuntu"
```

#### `system_kernel_version`
Gets the kernel version of the running system.

```bash
kernel=$(system_kernel_version)
echo "Kernel: $kernel"  # Output: "6.2.0-26-generic"
```

#### `system_architecture`
Gets the system architecture.

```bash
arch=$(system_architecture)
echo "Architecture: $arch"  # Output: "x86_64"
```

#### `system_desktop_environment`
Detects the current desktop environment.

```bash
desktop=$(system_desktop_environment)
echo "Desktop: $desktop"  # Output: "GNOME"
```

#### `system_display_server`
Detects the current display server protocol.

```bash
display=$(system_display_server)
echo "Display server: $display"  # Output: "X11" or "Wayland"
```

## Validation Functions

#### `validate_item "description" "validation_command" "fix_suggestion"`
Validates a single item and shows results.

```bash
validate_item "Git installation" "command_exists git" "Install git package"
```

#### `validate_dependencies "dependency1" "dependency2" ...`
Validates multiple dependencies and exits if any are missing.

```bash
validate_dependencies "git" "curl" "wget"
```

## Network Operations

#### `download_file "url" "destination" [use_sudo]`
Downloads a file from a URL using curl or wget.

```bash
download_file "https://example.com/file.txt" "local_file.txt"
download_file "https://example.com/config" "/etc/config" $TRUE
```

#### `download_file_sudo "url" "destination"`
Convenience function to download file with sudo.

```bash
download_file_sudo "https://example.com/config" "/etc/config"
```

## Workflow Management

#### `flow_run workflow_array`
Executes a workflow using an associative array of steps.

```bash
# Define workflow steps
declare -A my_workflow=(
    [askSudo]="Request sudo privileges"
    [updateSystem]="Update system packages"
    [installApps]="Install applications"
)

# Define the functions
askSudo() {
    sudoing
}

updateSystem() {
    sudo apt update && sudo apt upgrade -y
}

installApps() {
    sudo apt install -y git curl
}

# Run the workflow
flow_run my_workflow
```

## Temporary Directory Management

#### `temp_dir_get`
Gets or creates the global temporary directory (automatically cleaned up on exit).

```bash
temp_dir=$(temp_dir_get)
mkdir -p "$temp_dir/subdir"
echo "data" > "$temp_dir/file.txt"
# Directory will be automatically cleaned up when script exits
```

## Examples

### Basic Usage Example

```bash
#!/bin/bash
source ./spla.sh

show_title "My Application"
show_info "Starting application..."

if prompt_yesno "Do you want to continue?"; then
    show_success "User confirmed, proceeding..."
    
    # Create a config file
    file_create_with_content "app.conf" "debug=true"
    file_make_executable "app.conf"
    
    show_success "Application setup complete!"
else
    show_warning "Operation cancelled by user"
fi
```

### Menu Example

```bash
#!/bin/bash
source ./spla.sh

show_title "System Management Tool"

while true; do
    selected=$(prompt_menu "Choose an action:" \
        "Show system info" \
        "Check dependencies" \
        "Create backup" \
        "Quit")
    
    case "$selected" in
        "Show system info")
            show_header "System Information"
            show_info "Distribution: $(system_distro_name)"
            show_info "Kernel: $(system_kernel_version)"
            show_info "Architecture: $(system_architecture)"
            ;;
        "Check dependencies")
            validate_dependencies "git" "curl" "wget"
            ;;
        "Create backup")
            if file_exists "important.conf"; then
                file_backup "important.conf"
            fi
            ;;
        "Quit")
            show_success "Goodbye!"
            exit 0
            ;;
    esac
    
    prompt_continue
done
```

### Workflow Example

```bash
#!/bin/bash
source ./spla.sh

# Define workflow functions
setup_environment() {
    show_info "Setting up environment..."
    path_create "/opt/myapp"
    return 0
}

install_dependencies() {
    validate_dependencies "git" "curl"
    return 0
}

configure_application() {
    file_create_with_content "/opt/myapp/config.ini" "debug=false"
    return 0
}

# Define workflow
declare -A installation_workflow=(
    [setup_environment]="Setup application environment"
    [install_dependencies]="Install required dependencies"
    [configure_application]="Configure application"
)

# Run workflow
flow_run installation_workflow
```

## License

This project is open source. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## Author

Luciano Soares - [GitHub Repository](https://github.com/soaresluciano/splash)

## TODO

- find a better way to load the lib
