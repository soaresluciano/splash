#!/bin/bash
source ./spla.sh

debugger_enabled=false

TEST_RUNS=0
TEST_PASSES=0
TEST_FAILS=0

_process_test() {
    local test_name="$1"
    local test_result="$2"
    local test_details="${3:-}"

    TEST_RUNS=$((TEST_RUNS + 1))
    if is_success "$test_result"; then
        TEST_PASSES=$((TEST_PASSES + 1))
    else
        TEST_FAILS=$((TEST_FAILS + 1))
    fi

    show_test_result "$test_name" "$test_result" "$test_details"
}

_test_cmd() {
    local __outvar="$1"
    local expected_result="$2"
    shift 2

    run_cmd_capture result "$@"
    local cmd_status=${result[status]}
    local cmd_output=${result[output]}
    eval "$__outvar=\"\${cmd_output}\""

    local actual_result=$FALSE
    is_success $cmd_status && actual_result=$TRUE
    local test_result=$FALSE
    are_equal_str "$expected_result" "$actual_result" && test_result=$TRUE

    if $debugger_enabled; then
        echo "--------------------"
        echo "Method: _test_cmd"
        echo "cmd_status: $cmd_status"
        echo "expected_result: $expected_result"
        echo "actual_result: $actual_result"
        echo "test_result: $test_result"
        echo "--------------------"
    fi
    return "$test_result"
}

_test_cmd_output_contains() {
    local test_name="$1"
    local expected_result="$2"
    local expected_msg="$3"
    shift 3

    local actual_output
    _test_cmd actual_output "$expected_result" "$@"
    local test_result="$?"

    local contains_msg=$FALSE
    is_success $test_result && contains_str "$actual_output" "$expected_msg" && contains_msg=$TRUE

    local test_details=""
    ! is_success $contains_msg && test_details="The expected message ($expected_msg) was not found"

    local final_test_result=$FALSE
    is_success $test_result && is_success $contains_msg && final_test_result=$TRUE

    if $debugger_enabled; then
        echo "--------------------"
        echo "Method: _test_cmd_output_contains"
        echo "test_name: $test_name"
        echo "expected_result: $expected_result"
        echo "expected_msg: $expected_msg"
        echo "test_result: $test_result"
        echo "Final test_result: $final_test_result"
        echo "--------------------"
    fi

    _process_test "$test_name" "$final_test_result" "$test_details"

    return "$test_result"
}

test_pass() {
    local test_name="$1"
    shift
    _test_cmd actual_output $TRUE "$@"
    local test_result="$?"
    _process_test "$test_name" "$test_result"
    return "$test_result"
}

test_fail() {
    local test_name="$1"
    shift
    _test_cmd actual_output $FALSE "$@"
    local test_result="$?"
    # if ! is_success $actual_result; then
    #     test_details="The test succeded unexpectedly"
    # fi
    _process_test "$test_name" "$test_result"
    return "$test_result"
}

test_pass_with_msg() {
    local test_name="$1"
    local expected_msg="$2"
    shift 2
    _test_cmd_output_contains "$test_name" $TRUE "$expected_msg" "$@"
}

test_fail_with_msg() {
    local test_name="$1"
    local expected_msg="$2"
    shift 2

    if $debugger_enabled; then
        echo "--------------------"
        echo "Method: test_fail_with_msg"
        echo "test_name: $test_name"
        echo "expected_msg: $expected_msg"
        echo "--------------------"
    fi

    _test_cmd_output_contains "$test_name" $FALSE "$expected_msg" "$@"
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
    # prompt_continue: simulate pressing Enter (no input)
    test_pass "prompt_continue: waits for Enter" run_autoinput_silent "" prompt_continue

    # prompt_question: returns the user's input
    test_pass_with_msg "prompt_question: returns input" "Alice" run_autoinput "Alice" prompt_question "Enter your name"

    # prompt_question: character limit enforcement (limit=3)
    test_pass_with_msg "prompt_question: enforces char limit" "ABC" run_autoinput "ABCDE" prompt_question "Limited" "" 3

    # prompt_yesno: accept 'y' and 'Y' as true
    test_pass "prompt_yesno: accepts 'y'" run_autoinput "y" prompt_yesno "Continue?"
    test_pass "prompt_yesno: accepts 'Y'" run_autoinput "Y" prompt_yesno "Continue?"

    # prompt_yesno: accepts 'n' and 'N' as false (validate_item should FAIL)
    test_fail "prompt_yesno: rejects 'n'" run_autoinput "n" prompt_yesno "Continue?"
    test_fail "prompt_yesno: rejects 'N'" run_autoinput "N" prompt_yesno "Continue?"

    # prompt_yesno: pressing Enter defaults to no (validate_item should FAIL)
    test_fail "prompt_yesno: Enter defaults to no" run_autoinput "" prompt_yesno "Continue?"

    # prompt_proceed: simulate proceed (yes)
    test_pass "prompt_proceed: proceed on yes" run_autoinput "y" prompt_proceed "This will run."

    # prompt_proceed: simulate cancel (no) -> validate_item should FAIL
    test_fail_with_msg "prompt_proceed: cancel on no" "Operation cancelled by user." run_autoinput "n" prompt_proceed "This will not run."

    # prompt_overwrite: simulate overwrite (yes)
    test_pass "prompt_overwrite: overwrite on yes" run_autoinput "y" prompt_overwrite "file.txt"

    # WITHOUT
    ## prompt_overwrite: do not overwrite on no -> validate_item should FAIL
    # test_fail_with_msg "prompt_overwrite: keep existing on no" "Using existing 'RESOURCE'" run_autoinput "n" prompt_overwrite "RESOURCE"
}

# test_menu() {
#     options=("Option 1" "Option 2" "Option 3" "Quit")
#     selected_option=$(menu "Please choose an option:" "${options[@]}")
# }

# test_file_operations() {
# }

# test_validations() {
#     success_msg="OK"
#     error_msg="FAIL"
#     suggestion_msg="Fix: Suggestion!"
#     # Helper: run a validation test and show result. It accepts the
#     # positional arguments to be forwarded to validate_item (preserving
#     # separate arguments rather than building a single string).
#     run_validate_item_test() {
#         local assert_fn="$1"; shift
#         local expected_msg="$1"; shift
#         local test_name="$1"; shift
#         # Remaining args (if any) are passed to validate_item
#         if $assert_fn "$expected_msg" validate_item "$test_name" "$@"; then
#             show_success "$test_name: PASS"
#         else
#             show_error "$test_name: FAIL"
#         fi
#     }

#     # Basic cases
#     local description="Shows description"
#     run_validate_item_test assert_passes_with "Checking $description..." "$description" "0"
#     run_validate_item_test assert_passes_with "$success_msg" "Receives 0" "0"
#     run_validate_item_test assert_fails_with  "$error_msg"   "Receives garbage" "garbage"

#     # Command-like check expressions
#     run_validate_item_test assert_passes_with "$success_msg" "Receives TRUE" "[ -z '' ]"
#     run_validate_item_test assert_fails_with  "$error_msg"   "Receives FALSE" "[ -z 'data' ]"

#     # Fix suggestion behavior
#     run_validate_item_test assert_fails_with  "$suggestion_msg" "Show fix suggestion on failure (fix printed)" "[ -z 'data' ]" "Suggestion!"
#     run_validate_item_test assert_fails_without "$suggestion_msg" "Do not show fix suggestion on failure (fix not printed)" "[ -z 'data' ]"

#     # Extra edge case: empty string as value (should be treated as blank/OK)
#     run_validate_item_test assert_passes_with "$success_msg" "Receives empty string" ""

# }

# test_network_operations() {
# }

test_comparisons() {
    # is_not_empty
    test_pass "is_not_empty: non-empty" is_not_empty 'data'
    test_fail "is_not_empty: empty (should fail)" is_not_empty ''

    # is_empty
    test_pass "is_empty: empty" is_empty ''
    test_fail "is_empty: non-empty (should fail)" is_empty 'data'

    # are_equal_str
    test_pass "are_equal_str: equal" are_equal_str 'data' 'data'
    test_fail "are_equal_str: different (should fail)" are_equal_str 'data' 'other'

    # are_equal_str_ignore_case
    test_pass "are_equal_str_ignore_case: same case" are_equal_str_ignore_case 'Data' 'Data'
    test_pass "are_equal_str_ignore_case: different case" are_equal_str_ignore_case 'Data' 'data'
    test_fail "are_equal_str_ignore_case: different (should fail)" are_equal_str_ignore_case 'Data' 'other'

    # are_equal_num
    test_pass "are_equal_num: equal" are_equal_num 42 42
    test_fail "are_equal_num: different (should fail)" are_equal_num 1 0

    # is_greater_than
    test_pass "is_greater_than: greater" is_greater_than 2 1
    test_fail "is_greater_than: lesser (should fail)" is_greater_than 1 2

    # is_greater_than_or_equal
    test_pass "is_greater_than_or_equal: greater" is_greater_than_or_equal 2 1
    test_pass "is_greater_than_or_equal: equal" is_greater_than_or_equal 2 2
    test_fail "is_greater_than_or_equal: lesser (should fail)" is_greater_than_or_equal 1 2

    # is_less_than
    test_pass "is_less_than: lesser" is_less_than 1 2
    test_fail "is_less_than: greater (should fail)" is_less_than 2 1

    # is_less_than_or_equal
    test_pass "is_less_than_or_equal: lesser" is_less_than_or_equal 1 2
    test_pass "is_less_than_or_equal: equal" is_less_than_or_equal 2 2
    test_fail "is_less_than_or_equal: greater (should fail)" is_less_than_or_equal 3 2

    # is_integer
    test_pass "is_integer: integer" is_integer 42
    test_pass "is_integer: integer str" is_integer "24"
    test_fail "is_integer: float (should fail)" is_integer 3.14
    test_fail "is_integer: not a number (should fail)" is_integer 'data'

    # is_true
    test_pass "is_true: true" is_true $TRUE
    test_pass "is_true: true string" is_true "0"
    test_fail "is_true: false (should fail)" is_true $FALSE
    test_fail "is_true: false string (should fail)" is_true "1"

    # is_false
    test_pass "is_false: false" is_false $FALSE
    test_pass "is_false: false string" is_false "1"
    test_fail "is_false: true (should fail)" is_false $TRUE
    test_fail "is_false: true string (should fail)" is_false "0"

    # is_success
    test_pass "is_success: success" is_success $TRUE
    test_pass "is_success: success string" is_success "0"
    test_fail "is_success: failure (should fail)" is_success $FALSE
    test_fail "is_success: failure string (should fail)" is_success "1"

    # contains_str
    test_pass "contains_str: contains" contains_str "Hello, world!" "world"
    test_fail "contains_str: does not contain (should fail)" contains_str "Hello, world!" "universe"
    test_fail "contains_str: empty does not contain (should fail)" contains_str "" "world"
}

test_assertions() {
    test_pass "+ assert_is_empty" assert_is_empty ''
    test_pass "+ assert_is_not_empty" assert_is_not_empty 'data'
    test_pass "+ assert_are_equal_str" assert_are_equal_str 'data' 'data'
    test_pass "+ assert_are_equal_str_ignore_case" assert_are_equal_str_ignore_case 'Data' 'data'
    test_pass "+ assert_are_equal_num" assert_are_equal_num 42 42
    test_pass "+ assert_is_greater_than" assert_is_greater_than 2 1
    test_pass "+ assert_is_greater_than_or_equal" assert_is_greater_than_or_equal 2 1
    test_pass "+ A) assert_is_greater_than_or_equal" assert_is_greater_than_or_equal 2 2
    test_pass "+ B) assert_is_less_than" assert_is_less_than 1 2
    test_pass "+ A) assert_is_less_than_or_equal" assert_is_less_than_or_equal 1 2
    test_pass "+ B) assert_is_less_than_or_equal" assert_is_less_than_or_equal 2 2

    local custom_err="Custom error: Value is not empty."
    test_fail_with_msg "- assert_is_empty" "Assertion failed: Expected empty value, but got non-empty." assert_is_empty 'data'
    test_fail_with_msg "- cstm assert_is_empty" "$custom_err" assert_is_empty 'data' "$custom_err"
    test_fail_with_msg "- assert_is_not_empty" "Assertion failed: Expected non-empty value, but got empty." assert_is_not_empty ''
    test_fail_with_msg "- cstm assert_is_not_empty" "$custom_err" assert_is_not_empty '' "$custom_err"
    test_fail_with_msg "- assert_are_equal_str" "Assertion failed: Expected 'data' to equal 'other'." assert_are_equal_str 'data' 'other'
    test_fail_with_msg "- cstm assert_are_equal_str" "$custom_err" assert_are_equal_str 'data' 'other' "$custom_err"
    test_fail_with_msg "- assert_are_equal_str_ignore_case" "Assertion failed: Expected 'Data' to equal 'other' (case-insensitive)." assert_are_equal_str_ignore_case 'Data' 'other'
    test_fail_with_msg "- cstm assert_are_equal_str_ignore_case" "$custom_err" assert_are_equal_str_ignore_case 'Data' 'other' "$custom_err"
    test_fail_with_msg "- assert_are_equal_num" "Assertion failed: Expected '1' to equal '0'." assert_are_equal_num 1 0
    test_fail_with_msg "- cstm assert_are_equal_num" "$custom_err" assert_are_equal_num 1 0 "$custom_err"
    test_fail_with_msg "- assert_is_greater_than" "Assertion failed: Expected '0' to be greater than '1'." assert_is_greater_than 0 1
    test_fail_with_msg "- cstm assert_is_greater_than" "$custom_err" assert_is_greater_than 0 1 "$custom_err"
    test_fail_with_msg "- assert_is_greater_than_or_equal" "Assertion failed: Expected '0' to be greater than or equal to '1'." assert_is_greater_than_or_equal 0 1
    test_fail_with_msg "- cstm assert_is_greater_than_or_equal" "$custom_err" assert_is_greater_than_or_equal 0 1 "$custom_err"
    test_fail_with_msg "- assert_is_less_than" "Assertion failed: Expected '1' to be less than '0'." assert_is_less_than 1 0
    test_fail_with_msg "- cstm assert_is_less_than" "$custom_err" assert_is_less_than 1 0 "$custom_err"
    test_fail_with_msg "- assert_is_less_than_or_equal" "Assertion failed: Expected '1' to be less than or equal to '0'." assert_is_less_than_or_equal 1 0
    test_fail_with_msg "- cstm assert_is_less_than_or_equal" "$custom_err" assert_is_less_than_or_equal 1 0 "$custom_err"
}

report_test_summary() {
    echo
    show_title "Test Summary"
    echo -e "▫️ $(style bright_blue bold) Total Runs:$(style blue) $TEST_RUNS${NC}"
    if [ $TEST_RUNS -eq 0 ]; then
        show_warning "No tests were executed."
        return
    fi
    echo -e "▫️ $(style bright_green bold) Passed:$(style green) $TEST_PASSES ($((TEST_PASSES * 100 / TEST_RUNS))%)${NC}"
    echo -e "▫️ $(style bright_red bold) Failed:$(style red) $TEST_FAILS ($((TEST_FAILS * 100 / TEST_RUNS))%)${NC}"
}

declare -A demos=(
    [demo_utils]="Utility functions"
    [demo_styled]="Styled output"
    [demo_ui_messages]="UI messages"
    [demo_system_info]="System information"
)
#flow_run demos

declare -A tests=(
    [test_user_interactions]="User interaction tests"
    [test_comparisons]="Comparison tests"
    [test_assertions]="Assertion tests"
    [test_validations]="Validation tests"
)
#flow_run tests

test_user_interactions
test_comparisons

# test_assertions

report_test_summary
