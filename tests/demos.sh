#!/bin/bash
source ../spla.sh

demo_utils() {
    show_keyvalue "get_script_dir" "$(get_script_dir)"
    show_keyvalue "get_current_user" "$(get_current_user)"
}

demo_styled() {
    styled black "Black"
    styled red "Red"
    styled green "Green"
    styled yellow "Yellow"
    styled blue "Blue"
    styled magenta "Magenta"
    styled cyan "Cyan"
    styled white "White"

    styled bright_black "Bright Black"
    styled bright_red "Bright Red"
    styled bright_green "Bright Green"
    styled bright_yellow "Bright Yellow"
    styled bright_blue "Bright Blue"
    styled bright_magenta "Bright Magenta"
    styled bright_cyan "Bright Cyan"
    styled bright_white "Bright White"

    styled bold "Bold"
    styled dim "Dim"
    styled underline "Underlined"
    styled blink "Blinking"
    styled reverse "Reversed"

    styled bold yellow "Bold Yellow"
    styled dim blue "Dim Blue"
    styled underline green "Underlined Green"
    styled blink magenta "Blinking Magenta"
    styled reverse cyan "Reversed Cyan"

    styled bold underline reverse white "Bold Underlined Reversed White"
}

demo_ui_messages() {
    show_title "This is a Title"
    show_header "This is a Header"
    show_error "This is an error message"
    show_warning "This is a warning message"
    show_success "This is a success message"
    show_info "This is an info message"
    show_log "This is a log message"
    show_suggestion "This is a suggestion message"
    show_question "This is a question"
    banner_attention
    banner_attention "CUSTOM ATTENTION"
    banner_completed
    banner_completed "CUSTOM COMPLETED"
}

demo_system_info() {
    show_keyvalue "Distro Name" "$(system_distro_name)"
    show_keyvalue "Distro ID" "$(system_distro_id)"
    show_keyvalue "Kernel Version" "$(system_kernel_version)"
    show_keyvalue "Architecture" "$(system_architecture)"
    show_keyvalue "Desktop Environment" "$(system_desktop_environment)"
    show_keyvalue "Display Server" "$(system_display_server)"
}

declare -A demos=(
    [demo_utils]="Utility functions"
    [demo_styled]="Styled output"
    [demo_ui_messages]="UI messages"
    [demo_system_info]="System information"
)

flow_run demos
