#!/bin/bash
set -e
source ./spla.sh

demo_ui_functions() {
    show_title "🖥️  UI FUNCTIONS DEMONSTRATION"
    show_header "This is a header message"
    show_error "This is an error message"
    show_warning "This is a warning message"
    show_success "This is a success message"
    show_question "This is a question"
    show_info "This is an info message"
    show_log "This is a log message"
    attention_banner
    # press_continue
    # sudoing
    # yesno "This is a yes/no question"
    input1=$(ask "This is an input question with a character limit" "y/N" 1)
    show_log "You entered: $input1"
    echo "This is a regular echo message"
    input2=$(ask "This is an input question without a character limit" "y/N")
    show_log "You entered: $input2"
    echo "This is a regular echo message"
}

demo_menu() {
    show_title "📋 MENU DEMONSTRATION"
    options=("Option 1" "Option 2" "Option 3" "Quit")
    selected_option=$(menu "Please choose an option:" "${options[@]}")
    show_log "You selected: $selected_option"
}

#demo_ui_functions

demo_menu