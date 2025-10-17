#!/bin/bash
set -e
source ./spla.sh

assert_passes_with() {
    local expected_msg="$1"
    shift
    local output status
    # Run the command and capture both stdout and stderr
    output=$("$@" 2>&1)
    status=$?

    # Command must succeed and output must contain the expected message (fixed-string)
    if [[ $status -eq 0 ]]; then
        if printf '%s' "$output" | grep -F -q -- "$expected_msg"; then
            return 0
        else
            # show captured output for debugging
            printf '%s\n' "$output" >&2
            return 1
        fi
    else
        # command failed, print output and return its status
        printf '%s\n' "$output" >&2
        return $status
    fi
}

assert_fails_with() {
    local expected_msg="$1"
    shift
    local output status
    # Run the command and capture both stdout and stderr
    output=$("$@" 2>&1)
    status=$?

    # Command must fail (non-zero) and output must contain the expected message
    if [[ $status -ne 0 ]]; then
        if printf '%s' "$output" | grep -F -q -- "$expected_msg"; then
            return 0
        else
            printf '%s\n' "$output" >&2
            return 1
        fi
    else
        # command succeeded unexpectedly
        printf '%s\n' "$output" >&2
        return 1
    fi
}

# Asserts that a command fails and its output does NOT contain the expected message
assert_fails_without() {
    local forbidden_msg="$1"
    shift
    local output status
    output=$("$@" 2>&1)
    status=$?

    if [[ $status -ne 0 ]]; then
        if printf '%s' "$output" | grep -F -q -- "$forbidden_msg"; then
            # forbidden message found -> fail
                printf '%s\n' "$output" >&2
            return 1
        else
            return 0
        fi
    else
        # command succeeded unexpectedly
            printf '%s\n' "$output" >&2
        return 1
    fi
}

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

test_user_interactions() {
    result=$(prompt_question "Enter your name" <<< "Alice")
    expected="Alice"
    if [[ "$result" == "$expected" ]]; then
        echo "prompt_question test: PASS"
    else
        echo "prompt_question test: FAIL (got '$result', expected '$expected')"
    fi

    # if prompt_yesno "Do you want to continue?"; then
    #     show_success "You chose to continue."
    # else
    #     show_warning "You chose not to continue."
    # fi

    # if prompt_proceed "This action will delete all temporary files."; then
    #     show_success "Proceeding with the action."
    # else
    #     show_warning "Action cancelled."
    # fi

    #prompt_overwrite
}

# test_menu() {
#     options=("Option 1" "Option 2" "Option 3" "Quit")
#     selected_option=$(menu "Please choose an option:" "${options[@]}")
# }

# test_file_operations() {
# }

test_validations() {
    success_msg="OK"
    error_msg="FAIL"
    suggestion_msg="Fix: Suggestion!"
    # Helper: run a validation test and show result. It accepts the
    # positional arguments to be forwarded to validate_item (preserving
    # separate arguments rather than building a single string).
    run_validate_item_test() {
        local assert_fn="$1"; shift
        local expected_msg="$1"; shift
        local test_name="$1"; shift
        # Remaining args (if any) are passed to validate_item
        if $assert_fn "$expected_msg" validate_item "$test_name" "$@"; then
            show_success "$test_name: PASS"
        else
            show_error "$test_name: FAIL"
        fi
    }

    # Basic cases
    local description="Shows description"
    run_validate_item_test assert_passes_with "Checking $description..." "$description" "0"
    run_validate_item_test assert_passes_with "$success_msg" "Receives 0" "0"
    run_validate_item_test assert_fails_with  "$error_msg"   "Receives garbage" "garbage"

    # Command-like check expressions
    run_validate_item_test assert_passes_with "$success_msg" "Receives TRUE" "[ -z '' ]"
    run_validate_item_test assert_fails_with  "$error_msg"   "Receives FALSE" "[ -z 'data' ]"

    # Fix suggestion behavior
    run_validate_item_test assert_fails_with  "$suggestion_msg" "Show fix suggestion on failure (fix printed)" "[ -z 'data' ]" "Suggestion!"
    run_validate_item_test assert_fails_without "$suggestion_msg" "Do not show fix suggestion on failure (fix not printed)" "[ -z 'data' ]"

    # Extra edge case: empty string as value (should be treated as blank/OK)
    run_validate_item_test assert_passes_with "$success_msg" "Receives empty string" ""
}

# test_network_operations() {
# }

# test_comparions() {
# }

test_assertions() {
    # Helper: run a command (or assertion helper) and forward its
    # captured output to validate_item. This preserves calling
    # validate_item with the label and a separate output arg instead of
    # building a single concatenated string.
    run_validate_item_cmd() {
        local label="$1"; shift
        local output
        output=$("$@" 2>&1)
        validate_item "$label" "$output"
    }

    run_validate_item_cmd "+ assert_is_empty" assert_is_empty ''
    run_validate_item_cmd "+ assert_is_not_empty" assert_is_not_empty 'data'
    run_validate_item_cmd "+ assert_are_equal_str" assert_are_equal_str 'data' 'data'
    run_validate_item_cmd "+ assert_are_equal_str_ignore_case" assert_are_equal_str_ignore_case 'Data' 'data'
    run_validate_item_cmd "+ assert_are_equal_num" assert_are_equal_num 42 42
    run_validate_item_cmd "+ assert_is_greater_than" assert_is_greater_than 2 1
    run_validate_item_cmd "+ assert_is_greater_than_or_equal" assert_is_greater_than_or_equal 2 1
    run_validate_item_cmd "+ A) assert_is_greater_than_or_equal" assert_is_greater_than_or_equal 2 2
    run_validate_item_cmd "+ B) assert_is_less_than" assert_is_less_than 1 2
    run_validate_item_cmd "+ A) assert_is_less_than_or_equal" assert_is_less_than_or_equal 1 2
    run_validate_item_cmd "+ B) assert_is_less_than_or_equal" assert_is_less_than_or_equal 2 2

    # Helper to avoid repeating local expected_err declarations.
    # Usage: run_validate_item_fail <label> <expected_msg> <assert_fn> [args...]
    run_validate_item_fail() {
        local label="$1"; shift
        local expected_msg="$1"; shift
        run_validate_item_cmd "$label" assert_fails_with "$expected_msg" "$@"
    }

    local custom_err="Custom error: Value is not empty."
    run_validate_item_fail "- assert_is_empty" "Assertion failed: Expected empty value, but got non-empty." assert_is_empty 'data'
    run_validate_item_fail "- cstm assert_is_empty" "$custom_err" assert_is_empty 'data' "$custom_err"
    run_validate_item_fail "- assert_is_not_empty" "Assertion failed: Expected non-empty value, but got empty." assert_is_not_empty ''
    run_validate_item_fail "- cstm assert_is_not_empty" "$custom_err" assert_is_not_empty '' "$custom_err"
    run_validate_item_fail "- assert_are_equal_str" "Assertion failed: Expected 'data' to equal 'other'." assert_are_equal_str 'data' 'other'
    run_validate_item_fail "- cstm assert_are_equal_str" "$custom_err" assert_are_equal_str 'data' 'other' "$custom_err"
    run_validate_item_fail "- assert_are_equal_str_ignore_case" "Assertion failed: Expected 'Data' to equal 'other' (case-insensitive)." assert_are_equal_str_ignore_case 'Data' 'other'
    run_validate_item_fail "- cstm assert_are_equal_str_ignore_case" "$custom_err" assert_are_equal_str_ignore_case 'Data' 'other' "$custom_err"
    run_validate_item_fail "- assert_are_equal_num" "Assertion failed: Expected '1' to equal '0'." assert_are_equal_num 1 0
    run_validate_item_fail "- cstm assert_are_equal_num" "$custom_err" assert_are_equal_num 1 0 "$custom_err"
    run_validate_item_fail "- assert_is_greater_than" "Assertion failed: Expected '0' to be greater than '1'." assert_is_greater_than 0 1
    run_validate_item_fail "- cstm assert_is_greater_than" "$custom_err" assert_is_greater_than 0 1 "$custom_err"
    run_validate_item_fail "- assert_is_greater_than_or_equal" "Assertion failed: Expected '0' to be greater than or equal to '1'." assert_is_greater_than_or_equal 0 1
    run_validate_item_fail "- cstm assert_is_greater_than_or_equal" "$custom_err" assert_is_greater_than_or_equal 0 1 "$custom_err"
    run_validate_item_fail "- assert_is_less_than" "Assertion failed: Expected '1' to be less than '0'." assert_is_less_than 1 0
    run_validate_item_fail "- cstm assert_is_less_than" "$custom_err" assert_is_less_than 1 0 "$custom_err"
    run_validate_item_fail "- assert_is_less_than_or_equal" "Assertion failed: Expected '1' to be less than or equal to '0'." assert_is_less_than_or_equal 1 0
    run_validate_item_fail "- cstm assert_is_less_than_or_equal" "$custom_err" assert_is_less_than_or_equal 1 0 "$custom_err"
}

declare -A my_workflow=(
    [demo_utils]="Utility functions"
    [demo_styled]="Styled output"
    [demo_ui_messages]="UI messages"
    [demo_system_info]="System information"
    [test_user_interactions]="User interaction tests"
    [test_assertions]="Assertion tests"
    [test_validations]="Validation tests"
)
flow_run my_workflow