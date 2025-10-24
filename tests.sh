#!/bin/bash
source ./spla.sh

_target="TEST-TARGET-STRING"

test_regex() {
    local main_str="The quick brown fox"
    test_status_is "$_success" "regex_match 1 word pass" regex_match "$main_str" "fox"
    test_status_is "$_failure" "regex_match 1 word fail" regex_match "$main_str" "dog"

    # regex_build_not
    test_status_is "$_success" "regex_build_not pass" regex_match "$main_str" "$(regex_build_not "dog")"
    test_status_is "$_failure" "regex_build_not fail" regex_match "$main_str" "$(regex_build_not "fox")"

    # regex_build_first_only
    test_status_is "$_success" "regex_build_first_only pass" regex_match "$main_str" "$(regex_build_first_only "quick" "dog")"
    test_status_is "$_failure" "regex_build_first_only fail 1" regex_match "$main_str" "$(regex_build_first_only "quick" "fox")"
    test_status_is "$_failure" "regex_build_first_only fail 2" regex_match "$main_str" "$(regex_build_first_only "dog" "cat")"

    # regex_build_all
    test_status_is "$_success" "regex_build_all pass" regex_match "$main_str" "$(regex_build_all "quick" "fox")"
    test_status_is "$_failure" "regex_build_all fail 1" regex_match "$main_str" "$(regex_build_all "quick" "dog")"
    test_status_is "$_failure" "regex_build_all fail 2" regex_match "$main_str" "$(regex_build_all "dog" "cat")"

    # regex_build_none
    test_status_is "$_success" "regex_build_none pass" regex_match "$main_str" "$(regex_build_none "dog" "cat")"
    test_status_is "$_failure" "regex_build_none fail 1" regex_match "$main_str" "$(regex_build_none "fox" "dog")"
    test_status_is "$_failure" "regex_build_none fail 2" regex_match "$main_str" "$(regex_build_none "quick" "fox")"

    # regex_build_any
    test_status_is "$_success" "regex_build_any pass 1" regex_match "$main_str" "$(regex_build_any "fox" "dog")"
    test_status_is "$_success" "regex_build_any pass 2" regex_match "$main_str" "$(regex_build_any "cat" "quick")"
    test_status_is "$_success" "regex_build_any pass 3" regex_match "$main_str" "$(regex_build_any "fox" "quick")"
    test_status_is "$_failure" "regex_build_any fail" regex_match "$main_str" "$(regex_build_any "dog" "cat")"
}

test_ui_messages() {
    # show_title
    test_status_output_match "$_success" "$_target" "show_title" show_title "$_target"

    # show_header
    test_status_output_match "$_success" "$_target" "show_header" show_header "$_target"

    # show_error
    test_status_output_match "$_success" "$_target" "show_error" show_error "$_target"

    # show_warning
    test_status_output_match "$_success" "$_target" "show_warning" show_warning "$_target"

    # show_success
    test_status_output_match "$_success" "$_target" "show_success" show_success "$_target"

    # show_info
    test_status_output_match "$_success" "$_target" "show_info" show_info "$_target"

    # show_log
    test_status_output_match "$_success" "$_target" "show_log" show_log "$_target"

    # show_suggestion
    test_status_output_match "$_success" "$_target" "show_suggestion" show_suggestion "$_target"

    # show_keyvalue
    test_status_output_match "$_success" "$(regex_build_all "Key" "Value")" "show_keyvalue" show_keyvalue "Key" "Value"

    # show_question (no options)
    test_status_output_match "$_success" "$_target" "show_question (no options)" show_question "$_target"

    # show_question (with options)
    test_status_output_match "$_success" "OPTIONS" "show_question (with options)" show_question "question" "OPTIONS"

    # show_test_result (result = true, description)
    test_status_output_match "$_success" "$(regex_build_all "DESCRIPTION" "OK")" "show_test_result (result = true, description)" show_test_result "DESCRIPTION" "$_success"

    # show_test_result (result=true, details)
    test_status_output_match "$_success" "DETAILS" "show_test_result (result=true, details)" show_test_result "description" "$_success" "DETAILS"

    # show_test_result (result= true, with suggestion)
    test_status_output_match "$_success" "$(regex_build_not "SUGGESTION")" "show_test_result (result=true, with suggestion)" show_test_result "description" "$_success" "" "SUGGESTION"

    # show_test_result (result=true, with suggestion and details)
    test_status_output_match "$_success" "DETAILS" "show_test_result (result=true, with suggestion and details)1" show_test_result "description" "$_success" "DETAILS" "SUGGESTION"
    test_status_output_match "$_success" "$(regex_build_not "SUGGESTION")" "show_test_result (result=true, with suggestion and details)2" show_test_result "description" "$_success" "DETAILS" "SUGGESTION"

    # show_test_result (description, result = false)
    test_status_output_match "$_failure" "$(regex_build_all "DESCRIPTION" "FAIL")" "show_test_result (result=false)" show_test_result "DESCRIPTION" "$_failure"

    # show_test_result (result = false, details)
    test_status_output_match "$_failure" "DETAILS" "show_test_result (result=false, details)" show_test_result "description" "$_failure" "DETAILS"

    # show_test_result (result = false, suggestion)
    test_status_output_match "$_failure" "SUGGESTION" "show_test_result (result=false, with suggestion)" show_test_result "description" "$_failure" "" "SUGGESTION"

    # show_test_result (result = false,suggestion and details)
    test_status_output_match "$_failure" "$(regex_build_all "SUGGESTION" "DETAILS")" "show_test_result (result=false, with suggestion and details)" show_test_result "description" "$_failure" "DETAILS" "SUGGESTION"

    # banner_attention (default)
    test_status_output_match "$_success" "ATTENTION" "banner_attention (default)" banner_attention

    # banner_attention (custom message)
    test_status_output_match "$_success" "$_target" "banner_attention (custom message)" banner_attention "$_target"

    # banner_completed (default)
    test_status_output_match "$_success" "COMPLETED" "banner_completed (default)" banner_completed

    # banner_completed (custom message)
    test_status_output_match "$_success" "$_target" "banner_completed (custom message)" banner_completed "$_target"
}

test_user_interactions() {
    # prompt_continue: simulate pressing Enter (no input)
    test_status_is "$_success" "prompt_continue: waits for Enter" run_autoinput "" prompt_continue

    # prompt_question: returns the user's input
    test_status_output_match "$_success" "$_target" "prompt_question: returns input" run_autoinput "$_target" prompt_question "Enter your name"

    # prompt_question: character limit enforcement (limit=3)
    test_status_output_match "$_success" "ABC" "prompt_question: enforces char limit" run_autoinput "ABCDE" prompt_question "Limited" "" 3

    # prompt_yesno: accept 'y' and 'Y' as true
    test_status_is "$_success" "prompt_yesno: accepts 'y'" run_autoinput "y" prompt_yesno "Continue?"
    test_status_is "$_success" "prompt_yesno: accepts 'Y'" run_autoinput "Y" prompt_yesno "Continue?"

    # prompt_yesno: accepts 'n' and 'N' as false (validate_item should FAIL)
    test_status_is "$_failure" "prompt_yesno: rejects 'n'" run_autoinput "n" prompt_yesno "Continue?"
    test_status_is "$_failure" "prompt_yesno: rejects 'N'" run_autoinput "N" prompt_yesno "Continue?"

    # prompt_yesno: pressing Enter defaults to no (validate_item should FAIL)
    test_status_is "$_failure" "prompt_yesno: Enter defaults to no" run_autoinput "" prompt_yesno "Continue?"

    # prompt_proceed: simulate proceed (yes)
    test_status_is "$_success" "prompt_proceed: proceed on yes" run_autoinput "y" prompt_proceed "This will run."

    # prompt_proceed: simulate cancel (no) -> validate_item should FAIL
    test_status_output_match "$_failure" "Operation cancelled by user." "prompt_proceed: cancel on no" run_autoinput "n" prompt_proceed "This will not run."

    # prompt_overwrite: simulate overwrite (yes)
    test_status_is "$_success" "prompt_overwrite: overwrite on yes" run_autoinput "y" prompt_overwrite "file.txt"

    # WITHOUT
    ## prompt_overwrite: do not overwrite on no -> validate_item should FAIL
    test_status_output_match "$_failure" "Using existing 'RESOURCE'" "prompt_overwrite: keep existing on no" run_autoinput "n" prompt_overwrite "RESOURCE"
}

# test_menu() {
#     options=("Option 1" "Option 2" "Option 3" "Quit")
#     selected_option=$(menu "Please choose an option:" "${options[@]}")
# }

test_validations() {
    # validate_cmd
    test_status_output_match "$_success" "Validating $_target" "validate_cmd: has the correct title" validate_cmd "$_target" exit $_success
    test_status_output_match "$_success" "OK" "validate_cmd: Shows the correct result" validate_cmd "success" exit $_success
    test_status_output_match "$_failure" "FAIL" "validate_cmd: Shows the correct failure message" validate_cmd "failure" exit $_failure

    # validate_cmd_show_suggestion
    test_status_output_match "$_success" "$(regex_build_not "SUGGESTION")" "validate_cmd_show_suggestion: Not Shows the suggestion on success" validate_cmd_show_suggestion "success" "SUGGESTION" exit $_success
    test_status_output_match "$_failure" "$_target" "validate_cmd_show_suggestion: Shows the suggestion on fail" validate_cmd_show_suggestion "failure" "$_target" exit $_failure

    # validate_dependencies
    test_status_output_match "$_success" "All dependencies are installed" "validate_dependencies: all exists" validate_dependencies "ls" "cd"
    test_status_output_match "$_failure" "Missing dependencies: bad_dep" "validate_dependencies: 1 missing dependency" validate_dependencies "ls" "bad_dep"
    test_status_output_match "$_failure" "Missing dependencies: bad_dep1 bad_dep2" "validate_dependencies: 1+ missing dependency" validate_dependencies "bad_dep1" "bad_dep2"
}

test_comparisons() {
    # is_empty
    test_status_is "$_success" "is_empty: empty" is_empty ''
    test_status_is "$_failure" "is_empty: non-empty (should fail)" is_empty 'data'

    # is_not_empty
    test_status_is "$_success" "is_not_empty: non-empty" is_not_empty 'data'
    test_status_is "$_failure" "is_not_empty: empty (should fail)" is_not_empty ''

    # are_equal_str
    test_status_is "$_success" "are_equal_str: equal" are_equal_str 'data' 'data'
    test_status_is "$_failure" "are_equal_str: different (should fail)" are_equal_str 'data' 'other'

    # are_equal_str_ignore_case
    test_status_is "$_success" "are_equal_str_ignore_case: same case" are_equal_str_ignore_case 'Data' 'Data'
    test_status_is "$_success" "are_equal_str_ignore_case: different case" are_equal_str_ignore_case 'Data' 'data'
    test_status_is "$_failure" "are_equal_str_ignore_case: different (should fail)" are_equal_str_ignore_case 'Data' 'other'

    # are_equal_num
    test_status_is "$_success" "are_equal_num: equal" are_equal_num 42 42
    test_status_is "$_failure" "are_equal_num: different (should fail)" are_equal_num 1 0

    # is_greater_than
    test_status_is "$_success" "is_greater_than: greater" is_greater_than 2 1
    test_status_is "$_failure" "is_greater_than: lesser (should fail)" is_greater_than 1 2

    # is_greater_than_or_equal
    test_status_is "$_success" "is_greater_than_or_equal: greater" is_greater_than_or_equal 2 1
    test_status_is "$_success" "is_greater_than_or_equal: equal" is_greater_than_or_equal 2 2
    test_status_is "$_failure" "is_greater_than_or_equal: lesser (should fail)" is_greater_than_or_equal 1 2

    # is_less_than
    test_status_is "$_success" "is_less_than: lesser" is_less_than 1 2
    test_status_is "$_failure" "is_less_than: greater (should fail)" is_less_than 2 1

    # is_less_than_or_equal
    test_status_is "$_success" "is_less_than_or_equal: lesser" is_less_than_or_equal 1 2
    test_status_is "$_success" "is_less_than_or_equal: equal" is_less_than_or_equal 2 2
    test_status_is "$_failure" "is_less_than_or_equal: greater (should fail)" is_less_than_or_equal 3 2

    # is_integer
    test_status_is "$_success" "is_integer: integer" is_integer 42
    test_status_is "$_success" "is_integer: integer str" is_integer "24"
    test_status_is "$_failure" "is_integer: float (should fail)" is_integer 3.14
    test_status_is "$_failure" "is_integer: not a number (should fail)" is_integer 'data'

    # is_success
    test_status_is "$_success" "is_success: success" is_success $_success
    test_status_is "$_success" "is_success: 0 string" is_success "0"
    test_status_is "$_failure" "is_success: _failure (should fail)" is_success $_failure
    test_status_is "$_failure" "is_success: 1 string (should fail)" is_success "1"

    # is_failure
    test_status_is "$_success" "is_failure: failure" is_failure $_failure
    test_status_is "$_success" "is_failure: 1 string" is_failure "1"
    test_status_is "$_failure" "is_failure: success (should fail)" is_failure $_success
    test_status_is "$_failure" "is_failure: 0 string (should fail)" is_failure "0"

    # contains_str
    test_status_is "$_success" "contains_str: contains" contains_str "Hello, world!" "world"
    test_status_is "$_failure" "contains_str: does not contain (should fail)" contains_str "Hello, world!" "universe"
    test_status_is "$_failure" "contains_str: empty does not contain (should fail)" contains_str "" "world"
}

test_assertions() {
    # assert_is_empty
    test_status_is "$_success" "assert_is_empty pass" assert_is_empty ''
    test_status_output_match "$_failure" "Assertion failed: Expected empty value, but got non-empty." "assert_is_empty fails" assert_is_empty 'data'
    test_status_output_match "$_failure" "$_target" "assert_is_empty custom error" assert_is_empty 'data' "$_target"

    # assert_is_not_empty
    test_status_is "$_success" "assert_is_not_empty pass" assert_is_not_empty 'data'
    test_status_output_match "$_failure" "Assertion failed: Expected non-empty value, but got empty." "assert_is_not_empty fails" assert_is_not_empty ''
    test_status_output_match "$_failure" "$_target" "assert_is_not_empty custom error" assert_is_not_empty '' "$_target"

    # assert_are_equal_str
    test_status_is "$_success" "assert_are_equal_str pass" assert_are_equal_str 'data' 'data'
    test_status_output_match "$_failure" "Assertion failed: Expected 'data' to equal 'other'." "assert_are_equal_str fails" assert_are_equal_str 'data' 'other'
    test_status_output_match "$_failure" "$_target" "assert_are_equal_str custom error" assert_are_equal_str 'data' 'other' "$_target"

    # assert_are_equal_str_ignore_case
    test_status_is "$_success" "assert_are_equal_str_ignore_case pass 1" assert_are_equal_str_ignore_case 'data' 'data'
    test_status_is "$_success" "assert_are_equal_str_ignore_case pass 2" assert_are_equal_str_ignore_case 'Data' 'data'
    test_status_output_match "$_failure" "Assertion failed: Expected 'Data' to equal 'other'." "assert_are_equal_str_ignore_case fails" assert_are_equal_str_ignore_case 'Data' 'other'
    test_status_output_match "$_failure" "$_target" "assert_are_equal_str_ignore_case custom error" assert_are_equal_str_ignore_case 'Data' 'other' "$_target"

    # assert_are_equal_num
    test_status_is "$_success" "assert_are_equal_num pass" assert_are_equal_num 42 42
    test_status_output_match "$_failure" "Assertion failed: Expected '1' to equal '0'." "assert_are_equal_num fails" assert_are_equal_num 1 0
    test_status_output_match "$_failure" "$_target" "assert_are_equal_num custom error" assert_are_equal_num 1 0 "$_target"

    # assert_is_greater_than
    test_status_is "$_success" "assert_is_greater_than pass" assert_is_greater_than 2 1
    test_status_output_match "$_failure" "Assertion failed: Expected '0' to be greater than '1'." "assert_is_greater_than fails" assert_is_greater_than 0 1
    test_status_output_match "$_failure" "$_target" "assert_is_greater_than custom error" assert_is_greater_than 0 1 "$_target"

    # assert_is_greater_than_or_equal
    test_status_is "$_success" "assert_is_greater_than_or_equal pass 1" assert_is_greater_than_or_equal 2 1
    test_status_is "$_success" "assert_is_greater_than_or_equal pass 2" assert_is_greater_than_or_equal 2 2
    test_status_output_match "$_failure" "Assertion failed: Expected '0' to be greater than or equal to '1'." "assert_is_greater_than_or_equal fails" assert_is_greater_than_or_equal 0 1
    test_status_output_match "$_failure" "$_target" "assert_is_greater_than_or_equal custom error" assert_is_greater_than_or_equal 0 1 "$_target"

    # assert_is_less_than
    test_status_is "$_success" "assert_is_less_than pass" assert_is_less_than 1 2
    test_status_output_match "$_failure" "Assertion failed: Expected '1' to be less than '0'." "assert_is_less_than fails" assert_is_less_than 1 0
    test_status_output_match "$_failure" "$_target" "assert_is_less_than custom error" assert_is_less_than 1 0 "$_target"

    # assert_is_less_than_or_equal
    test_status_is "$_success" "assert_is_less_than_or_equal pass 1" assert_is_less_than_or_equal 1 2
    test_status_is "$_success" "assert_is_less_than_or_equal pass 2" assert_is_less_than_or_equal 2 2
    test_status_output_match "$_failure" "Assertion failed: Expected '1' to be less than or equal to '0'." "assert_is_less_than_or_equal fails" assert_is_less_than_or_equal 1 0
    test_status_output_match "$_failure" "$_target" "assert_is_less_than_or_equal custom error" assert_is_less_than_or_equal 1 0 "$_target"
}

fixtures=(
    test_ui_messages
    test_user_interactions
    test_comparisons
    test_assertions
    test_validations
    test_regex
)

clear
test_fixtures_run "Unit Tests" "${fixtures[@]}"