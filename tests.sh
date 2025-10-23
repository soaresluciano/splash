#!/bin/bash
source ./spla.sh

debugger_enabled=false

test_user_interactions() {
    # prompt_continue: simulate pressing Enter (no input)
    testcase_should_pass "prompt_continue: waits for Enter" run_autoinput "" prompt_continue

    # prompt_question: returns the user's input
    testcase_should_pass_and_match "prompt_question: returns input" "Alice" run_autoinput "Alice" prompt_question "Enter your name"

    # prompt_question: character limit enforcement (limit=3)
    testcase_should_pass_and_match "prompt_question: enforces char limit" "ABC" run_autoinput "ABCDE" prompt_question "Limited" "" 3

    # prompt_yesno: accept 'y' and 'Y' as true
    testcase_should_pass "prompt_yesno: accepts 'y'" run_autoinput "y" prompt_yesno "Continue?"
    testcase_should_pass "prompt_yesno: accepts 'Y'" run_autoinput "Y" prompt_yesno "Continue?"

    # prompt_yesno: accepts 'n' and 'N' as false (validate_item should FAIL)
    testcase_should_fail "prompt_yesno: rejects 'n'" run_autoinput "n" prompt_yesno "Continue?"
    testcase_should_fail "prompt_yesno: rejects 'N'" run_autoinput "N" prompt_yesno "Continue?"

    # prompt_yesno: pressing Enter defaults to no (validate_item should FAIL)
    testcase_should_fail "prompt_yesno: Enter defaults to no" run_autoinput "" prompt_yesno "Continue?"

    # prompt_proceed: simulate proceed (yes)
    testcase_should_pass "prompt_proceed: proceed on yes" run_autoinput "y" prompt_proceed "This will run."

    # prompt_proceed: simulate cancel (no) -> validate_item should FAIL
    testcase_should_fail_and_match "prompt_proceed: cancel on no" "Operation cancelled by user." run_autoinput "n" prompt_proceed "This will not run."

    # prompt_overwrite: simulate overwrite (yes)
    testcase_should_pass "prompt_overwrite: overwrite on yes" run_autoinput "y" prompt_overwrite "file.txt"

    # WITHOUT
    ## prompt_overwrite: do not overwrite on no -> validate_item should FAIL
    # testcase_should_fail_and_match "prompt_overwrite: keep existing on no" "Using existing 'RESOURCE'" run_autoinput "n" prompt_overwrite "RESOURCE"
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
    testcase_should_pass "is_not_empty: non-empty" is_not_empty 'data'
    testcase_should_fail "is_not_empty: empty (should fail)" is_not_empty ''

    # is_empty
    testcase_should_pass "is_empty: empty" is_empty ''
    testcase_should_fail "is_empty: non-empty (should fail)" is_empty 'data'

    # are_equal_str
    testcase_should_pass "are_equal_str: equal" are_equal_str 'data' 'data'
    testcase_should_fail "are_equal_str: different (should fail)" are_equal_str 'data' 'other'

    # are_equal_str_ignore_case
    testcase_should_pass "are_equal_str_ignore_case: same case" are_equal_str_ignore_case 'Data' 'Data'
    testcase_should_pass "are_equal_str_ignore_case: different case" are_equal_str_ignore_case 'Data' 'data'
    testcase_should_fail "are_equal_str_ignore_case: different (should fail)" are_equal_str_ignore_case 'Data' 'other'

    # are_equal_num
    testcase_should_pass "are_equal_num: equal" are_equal_num 42 42
    testcase_should_fail "are_equal_num: different (should fail)" are_equal_num 1 0

    # is_greater_than
    testcase_should_pass "is_greater_than: greater" is_greater_than 2 1
    testcase_should_fail "is_greater_than: lesser (should fail)" is_greater_than 1 2

    # is_greater_than_or_equal
    testcase_should_pass "is_greater_than_or_equal: greater" is_greater_than_or_equal 2 1
    testcase_should_pass "is_greater_than_or_equal: equal" is_greater_than_or_equal 2 2
    testcase_should_fail "is_greater_than_or_equal: lesser (should fail)" is_greater_than_or_equal 1 2

    # is_less_than
    testcase_should_pass "is_less_than: lesser" is_less_than 1 2
    testcase_should_fail "is_less_than: greater (should fail)" is_less_than 2 1

    # is_less_than_or_equal
    testcase_should_pass "is_less_than_or_equal: lesser" is_less_than_or_equal 1 2
    testcase_should_pass "is_less_than_or_equal: equal" is_less_than_or_equal 2 2
    testcase_should_fail "is_less_than_or_equal: greater (should fail)" is_less_than_or_equal 3 2

    # is_integer
    testcase_should_pass "is_integer: integer" is_integer 42
    testcase_should_pass "is_integer: integer str" is_integer "24"
    testcase_should_fail "is_integer: float (should fail)" is_integer 3.14
    testcase_should_fail "is_integer: not a number (should fail)" is_integer 'data'

    # is_true
    testcase_should_pass "is_true: true" is_true $TRUE
    testcase_should_pass "is_true: true string" is_true "0"
    testcase_should_fail "is_true: false (should fail)" is_true $FALSE
    testcase_should_fail "is_true: false string (should fail)" is_true "1"

    # is_false
    testcase_should_pass "is_false: false" is_false $FALSE
    testcase_should_pass "is_false: false string" is_false "1"
    testcase_should_fail "is_false: true (should fail)" is_false $TRUE
    testcase_should_fail "is_false: true string (should fail)" is_false "0"

    # is_success
    testcase_should_pass "is_success: success" is_success $TRUE
    testcase_should_pass "is_success: success string" is_success "0"
    testcase_should_fail "is_success: failure (should fail)" is_success $FALSE
    testcase_should_fail "is_success: failure string (should fail)" is_success "1"

    # contains_str
    testcase_should_pass "contains_str: contains" contains_str "Hello, world!" "world"
    testcase_should_fail "contains_str: does not contain (should fail)" contains_str "Hello, world!" "universe"
    testcase_should_fail "contains_str: empty does not contain (should fail)" contains_str "" "world"
}

test_assertions() {
    testcase_should_pass "+ assert_is_empty" assert_is_empty ''
    testcase_should_pass "+ assert_is_not_empty" assert_is_not_empty 'data'
    testcase_should_pass "+ assert_are_equal_str" assert_are_equal_str 'data' 'data'
    testcase_should_pass "+ assert_are_equal_str_ignore_case" assert_are_equal_str_ignore_case 'Data' 'data'
    testcase_should_pass "+ assert_are_equal_num" assert_are_equal_num 42 42
    testcase_should_pass "+ assert_is_greater_than" assert_is_greater_than 2 1
    testcase_should_pass "+ assert_is_greater_than_or_equal" assert_is_greater_than_or_equal 2 1
    testcase_should_pass "+ A) assert_is_greater_than_or_equal" assert_is_greater_than_or_equal 2 2
    testcase_should_pass "+ B) assert_is_less_than" assert_is_less_than 1 2
    testcase_should_pass "+ A) assert_is_less_than_or_equal" assert_is_less_than_or_equal 1 2
    testcase_should_pass "+ B) assert_is_less_than_or_equal" assert_is_less_than_or_equal 2 2

    local custom_err="Custom error: Value is not empty."
    testcase_should_fail_and_match "- assert_is_empty" "Assertion failed: Expected empty value, but got non-empty." assert_is_empty 'data'
    testcase_should_fail_and_match "- cstm assert_is_empty" "$custom_err" assert_is_empty 'data' "$custom_err"
    testcase_should_fail_and_match "- assert_is_not_empty" "Assertion failed: Expected non-empty value, but got empty." assert_is_not_empty ''
    testcase_should_fail_and_match "- cstm assert_is_not_empty" "$custom_err" assert_is_not_empty '' "$custom_err"
    testcase_should_fail_and_match "- assert_are_equal_str" "Assertion failed: Expected 'data' to equal 'other'." assert_are_equal_str 'data' 'other'
    testcase_should_fail_and_match "- cstm assert_are_equal_str" "$custom_err" assert_are_equal_str 'data' 'other' "$custom_err"
    testcase_should_fail_and_match "- assert_are_equal_str_ignore_case" "Assertion failed: Expected 'Data' to equal 'other' (case-insensitive)." assert_are_equal_str_ignore_case 'Data' 'other'
    testcase_should_fail_and_match "- cstm assert_are_equal_str_ignore_case" "$custom_err" assert_are_equal_str_ignore_case 'Data' 'other' "$custom_err"
    testcase_should_fail_and_match "- assert_are_equal_num" "Assertion failed: Expected '1' to equal '0'." assert_are_equal_num 1 0
    testcase_should_fail_and_match "- cstm assert_are_equal_num" "$custom_err" assert_are_equal_num 1 0 "$custom_err"
    testcase_should_fail_and_match "- assert_is_greater_than" "Assertion failed: Expected '0' to be greater than '1'." assert_is_greater_than 0 1
    testcase_should_fail_and_match "- cstm assert_is_greater_than" "$custom_err" assert_is_greater_than 0 1 "$custom_err"
    testcase_should_fail_and_match "- assert_is_greater_than_or_equal" "Assertion failed: Expected '0' to be greater than or equal to '1'." assert_is_greater_than_or_equal 0 1
    testcase_should_fail_and_match "- cstm assert_is_greater_than_or_equal" "$custom_err" assert_is_greater_than_or_equal 0 1 "$custom_err"
    testcase_should_fail_and_match "- assert_is_less_than" "Assertion failed: Expected '1' to be less than '0'." assert_is_less_than 1 0
    testcase_should_fail_and_match "- cstm assert_is_less_than" "$custom_err" assert_is_less_than 1 0 "$custom_err"
    testcase_should_fail_and_match "- assert_is_less_than_or_equal" "Assertion failed: Expected '1' to be less than or equal to '0'." assert_is_less_than_or_equal 1 0
    testcase_should_fail_and_match "- cstm assert_is_less_than_or_equal" "$custom_err" assert_is_less_than_or_equal 1 0 "$custom_err"
}

fixture=(
    test_user_interactions
    test_comparisons
    test_assertions
)

test_fixture_run "Unit Tests" "${fixture[@]}"