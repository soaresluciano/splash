#!/bin/bash
source ../spla.sh

_target="TEST-TARGET-STRING"

_stub_echo() {
    local result="$1"
    echo "$_target"
    return "$result"
}

_stub_reader() {
    local result="$1"
    read -r input
    echo "$input"
    return "$result"
}

_stub_autoinput() {
    local result="$1"
    run_autoinput "$_target" _stub_reader "$result"
    return $?
}

test_helpers_sanity_check() {
    _sanity_helper()
    {
        local name="$1"
        local expected_status="$2"
        shift 2

        test_run actual_output "$expected_status" "$@"
        local testrun_result=$?
        local test_result
        if is_success $testrun_result && are_equal_str "$_target" "$actual_output"; then
            test_result="$_success"
        else
            test_result="$_failure"
        fi
        local test_name="Sanity check - $name status $expected_status"
        show_test_result "$test_name" "$test_result"
        _test_counter_increase "$test_result"
    }

    _sanity_helper "echo" "$_success" _stub_echo "$_success"
    _sanity_helper "echo" "$_failure" _stub_echo "$_failure"
    _sanity_helper "autoinput" "$_success" _stub_autoinput "$_success"
    _sanity_helper "autoinput" "$_failure" _stub_autoinput "$_failure"
}

test_regex() {
    local single_line_str="The quick brown fox"
    local multi_line_str=$'Lorem ipsum dolor sit amet\nconsectetur adipiscing elit'

    test_status_is "$_success" "regex_match single-line, 1 word pass" regex_match "$single_line_str" "fox"
    test_status_is "$_failure" "regex_match single-line, 1 word fail" regex_match "$single_line_str" "dog"
    test_status_is "$_success" "regex_match multi-line, 1 word pass" regex_match "$multi_line_str" "ipsum"
    test_status_is "$_failure" "regex_match multi-line, 1 word fail" regex_match "$multi_line_str" "dog"

    # regex_build_empty
    test_status_is "$_success" "regex_build_empty pass" regex_match "" "$(regex_build_empty)"
    test_status_is "$_failure" "regex_build_empty fail" regex_match "$single_line_str" "$(regex_build_empty)"

    # regex_build_not_empty
    test_status_is "$_success" "regex_build_not_empty pass" regex_match "$single_line_str" "$(regex_build_not_empty)"
    test_status_is "$_failure" "regex_build_not_empty fail" regex_match "" "$(regex_build_not_empty)"
    test_status_is "$_success" "regex_build_not_empty multi-line pass" regex_match "$multi_line_str" "$(regex_build_not_empty)"
    test_status_is "$_failure" "regex_build_not_empty multi-line fail" regex_match "" "$(regex_build_not_empty)"

    # regex_build_not
    test_status_is "$_success" "regex_build_not single-line, pass" regex_match "$single_line_str" "$(regex_build_not "dog")"
    test_status_is "$_failure" "regex_build_not single-line, fail" regex_match "$single_line_str" "$(regex_build_not "fox")"
    test_status_is "$_success" "regex_build_not multi-line, pass" regex_match "$multi_line_str" "$(regex_build_not "dog")"
    test_status_is "$_failure" "regex_build_not multi-line, fail" regex_match "$multi_line_str" "$(regex_build_not "ipsum")"

    # regex_build_first_only
    test_status_is "$_success" "regex_build_first_only single-line, pass" regex_match "$single_line_str" "$(regex_build_first_only "quick" "dog")"
    test_status_is "$_failure" "regex_build_first_only single-line, fail 1" regex_match "$single_line_str" "$(regex_build_first_only "quick" "fox")"
    test_status_is "$_failure" "regex_build_first_only single-line, fail 2" regex_match "$single_line_str" "$(regex_build_first_only "dog" "cat")"
    test_status_is "$_failure" "regex_build_first_only single-line, fail 3" regex_match "$single_line_str" "$(regex_build_first_only "dog" "fox")"
    test_status_is "$_success" "regex_build_first_only multi-line, pass" regex_match "$multi_line_str" "$(regex_build_first_only "ipsum" "dog")"
    test_status_is "$_failure" "regex_build_first_only multi-line, fail 1" regex_match "$multi_line_str" "$(regex_build_first_only "quick" "ipsum")"
    test_status_is "$_failure" "regex_build_first_only multi-line, fail 2" regex_match "$multi_line_str" "$(regex_build_first_only "dog" "cat")"
    test_status_is "$_failure" "regex_build_first_only multi-line, fail 3" regex_match "$multi_line_str" "$(regex_build_first_only "dog" "fox")"

    # regex_build_all
    test_status_is "$_success" "regex_build_all single-line, pass" regex_match "$single_line_str" "$(regex_build_all "quick" "fox")"
    test_status_is "$_failure" "regex_build_all single-line, fail 1" regex_match "$single_line_str" "$(regex_build_all "quick" "dog")"
    test_status_is "$_failure" "regex_build_all single-line, fail 2" regex_match "$single_line_str" "$(regex_build_all "dog" "cat")"
    test_status_is "$_success" "regex_build_all multi-line, pass" regex_match "$multi_line_str" "$(regex_build_all "ipsum" "elit")"
    test_status_is "$_failure" "regex_build_all multi-line, fail 1" regex_match "$multi_line_str" "$(regex_build_all "ipsum" "dog")"
    test_status_is "$_failure" "regex_build_all multi-line, fail 2" regex_match "$multi_line_str" "$(regex_build_all "dog" "cat")"

    # regex_build_none
    test_status_is "$_success" "regex_build_none single-line, pass" regex_match "$single_line_str" "$(regex_build_none "dog" "cat")"
    test_status_is "$_failure" "regex_build_none single-line, fail 1" regex_match "$single_line_str" "$(regex_build_none "fox" "dog")"
    test_status_is "$_failure" "regex_build_none single-line, fail 2" regex_match "$single_line_str" "$(regex_build_none "quick" "fox")"
    test_status_is "$_success" "regex_build_none multi-line, pass" regex_match "$multi_line_str" "$(regex_build_none "dog" "cat")"
    test_status_is "$_failure" "regex_build_none multi-line, fail 1" regex_match "$multi_line_str" "$(regex_build_none "ipsum" "dog")"
    test_status_is "$_failure" "regex_build_none multi-line, fail 2" regex_match "$multi_line_str" "$(regex_build_none "quick" "ipsum")"

    # regex_build_any
    test_status_is "$_success" "regex_build_any single-line, pass 1" regex_match "$single_line_str" "$(regex_build_any "fox" "dog")"
    test_status_is "$_success" "regex_build_any single-line, pass 2" regex_match "$single_line_str" "$(regex_build_any "cat" "quick")"
    test_status_is "$_success" "regex_build_any single-line, pass 3" regex_match "$single_line_str" "$(regex_build_any "fox" "quick")"
    test_status_is "$_failure" "regex_build_any single-line, fail" regex_match "$single_line_str" "$(regex_build_any "dog" "cat")"
    test_status_is "$_success" "regex_build_any multi-line, pass 1" regex_match "$multi_line_str" "$(regex_build_any "ipsum" "dog")"
    test_status_is "$_success" "regex_build_any multi-line, pass 2" regex_match "$multi_line_str" "$(regex_build_any "cat" "ipsum")"
    test_status_is "$_success" "regex_build_any multi-line, pass 3" regex_match "$multi_line_str" "$(regex_build_any "ipsum" "elit")"
    test_status_is "$_failure" "regex_build_any multi-line, fail" regex_match "$multi_line_str" "$(regex_build_any "dog" "cat")"
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

test_runners() {
    # sanity check for stub functions
    test_status_output_match "$_success" "$_target" "_stub_echo success" _stub_echo "$_success"
    test_status_output_match "$_failure" "$_target" "_stub_echo failure" _stub_echo "$_failure"
    test_status_output_match "$_success" "$_target" "_stub_autoinput success" _stub_autoinput "$_success"
    test_status_output_match "$_failure" "$_target" "_stub_autoinput failure" _stub_autoinput "$_failure"

    # run_cmd_capture
    run_cmd_capture result_0 _stub_echo "$_success"
    local cmd_status_0=${result_0[status]}
    local cmd_output_0=${result_0[output]}
    test_status_is "$_success" "0 - run_cmd_capture status" is_success $cmd_status_0
    test_status_is "$_success" "0 - run_cmd_capture output" are_equal_str "$cmd_output_0" "$_target"

    run_cmd_capture result_1 _stub_echo "$_failure"
    local cmd_status_1=${result_1[status]}
    local cmd_output_1=${result_1[output]}
    test_status_is "$_success" "1 - run_cmd_capture status" is_failure $cmd_status_1
    test_status_is "$_success" "1 - run_cmd_capture output" are_equal_str "$cmd_output_1" "$_target"

    # run_silent
    test_status_output_match "$_success" "$(regex_build_not "$_target")" "run_silent with success" run_silent _stub_echo $_success
    test_status_output_match "$_failure" "$(regex_build_not "$_target")" "run_silent with failure" run_silent _stub_echo $_failure

    # run_autoinput
    test_status_output_match "$_success" "$_target" "run_autoinput with success" run_autoinput "$_target" _stub_echo $_success
    test_status_output_match "$_failure" "$_target" "run_autoinput with failure" run_autoinput "$_target" _stub_echo $_failure

    # run_autoinput_silent
    test_status_output_match "$_success" "$(regex_build_not "$_target")" "run_autoinput_silent with success" run_autoinput_silent "$_target" _stub_echo $_success
    test_status_output_match "$_failure" "$(regex_build_not "$_target")" "run_autoinput_silent with failure" run_autoinput_silent "$_target" _stub_echo $_failure
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
    test_status_output_match "$_success" "$(regex_build_first_only "DETAILS" "SUGGESTION")" "show_test_result (result=true, with suggestion and details)2" show_test_result "description" "$_success" "DETAILS" "SUGGESTION"

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
    # prompt_continue:
    test_status_is "$_success" "prompt_continue: waits for Enter" run_autoinput "" prompt_continue

    # prompt_question
    test_status_output_match "$_success" "$_target" "prompt_question: shows correct message" run_autoinput "" prompt_question "$_target"
    test_status_output_match "$_success" "$(regex_build_all "QUESTION" "OPTIONS")" "prompt_question: shows correct message" run_autoinput "" prompt_question "QUESTION" "OPTIONS"
    test_status_output_match "$_success" "$_target" "prompt_question: returns input" run_autoinput "$_target" prompt_question "QUESTION"
    test_status_output_match "$_success" "ABC" "prompt_question: enforces char limit" run_autoinput "ABCDE" prompt_question "Limited" "" 3

    # prompt_yesno
    test_status_output_match "$_success" "$(regex_build_all "$_target" "[y/N]")" "prompt_yesno: shows correct message" run_autoinput "y" prompt_yesno "$_target"
    test_status_is "$_success" "prompt_yesno: accepts 'y'" run_autoinput "y" prompt_yesno "$_target"
    test_status_is "$_success" "prompt_yesno: accepts 'Y'" run_autoinput "Y" prompt_yesno "$_target"
    test_status_is "$_failure" "prompt_yesno: rejects 'n'" run_autoinput "n" prompt_yesno "$_target"
    test_status_is "$_failure" "prompt_yesno: rejects 'N'" run_autoinput "N" prompt_yesno "$_target"
    test_status_is "$_failure" "prompt_yesno: Enter defaults to no" run_autoinput "" prompt_yesno "$_target"

    # prompt_proceed
    test_status_output_match "$_success" "$(regex_build_all "$_target" "[y/N]")" "prompt_proceed: show correct message" run_autoinput "y" prompt_proceed "$_target"
    test_status_output_match "$_success" "$(regex_build_not "Operation cancelled by user.")" "prompt_proceed: proceed on yes" run_autoinput "y" prompt_proceed "$_target"
    test_status_output_match "$_failure" "Operation cancelled by user." "prompt_proceed: cancel on no" run_autoinput "n" prompt_proceed "$_target"
    test_status_output_match "$_failure" "Operation cancelled by user." "prompt_proceed: Enter defaults to no" run_autoinput "" prompt_proceed "$_target"

    # prompt_overwrite
    test_status_output_match "$_success" "$(regex_build_all "$_target" "[y/N]")" "prompt_overwrite: show correct message" run_autoinput "y" prompt_overwrite "$_target"
    test_status_output_match "$_success" "$(regex_build_not  "Using existing '$_target'")" "prompt_overwrite: show correct message" run_autoinput "y" prompt_overwrite "$_target"
    test_status_output_match "$_failure" "Using existing '$_target'" "prompt_overwrite: keep existing on no" run_autoinput "n" prompt_overwrite "$_target"
    test_status_output_match "$_failure" "Using existing '$_target'" "prompt_overwrite: Enter defaults to no" run_autoinput "" prompt_overwrite "$_target"
}

test_prompt_menu() {
    local menu_options=("Option-A" "Option-B" "Option-C")
    test_status_output_match "$_success" "$(regex_build_all "$_target" "Option-A" "Option-B" "Option-C")" "prompt_menu: shows correct menu" run_autoinput "1" prompt_menu "$_target" "${menu_options[@]}"
    test_status_output_match "$_success" "Invalid choice. Please enter a number between 1 and 3." \
        "prompt_menu: select wrong option" run_autoinput "x\n1" prompt_menu "$_target" "${menu_options[@]}"
    # Last line output matches selected option
    test_status_output_match "$_success" '^Option-A\s*$' "prompt_menu: 1 is selected" run_autoinput "1" prompt_menu "$_target" "${menu_options[@]}"
    test_status_output_match "$_success" '^Option-B\s*$' "prompt_menu: 2 is selected" run_autoinput "2" prompt_menu "$_target" "${menu_options[@]}"
    test_status_output_match "$_success" '^Option-C\s*$' "prompt_menu: 3 is selected" run_autoinput "3" prompt_menu "$_target" "${menu_options[@]}"
}

test_validations() {
    # validate_cmd
    test_status_output_match "$_success" "Validating $_target" "validate_cmd: has the correct title" validate_cmd "$_target" exit $_success
    test_status_output_match "$_success" "OK" "validate_cmd: Shows the correct result" validate_cmd "success" exit $_success
    test_status_output_match "$_failure" "FAIL" "validate_cmd: Shows the correct failure message" validate_cmd "failure" exit $_failure

    # validate_cmd_show_suggestion
    test_status_output_match "$_success" "$(regex_build_first_only "description" "$_target")" "validate_cmd_show_suggestion: Not Shows the suggestion on success" validate_cmd_show_suggestion "description" "$_target" exit $_success
    test_status_output_match "$_failure" "$(regex_build_all "description" "$_target")" "validate_cmd_show_suggestion: Shows the suggestion on fail" validate_cmd_show_suggestion "description" "$_target" exit $_failure

    # validate_dependencies
    test_status_output_match "$_success" "All dependencies are installed" "validate_dependencies: all exists" validate_dependencies "ls" "cd"
    test_status_output_match "$_failure" "Missing dependencies: bad_dep" "validate_dependencies: 1 missing dependency" validate_dependencies "ls" "bad_dep"
    test_status_output_match "$_failure" "Missing dependencies: bad_dep1 bad_dep2" "validate_dependencies: 1+ missing dependency" validate_dependencies "bad_dep1" "bad_dep2"
}

test_file_operations() {
    local current_user=$(whoami)

    local tmp_dir="tmp"
    mkdir -p "$tmp_dir"

    local path_not_exist="path_not_exist"

    #file readable/writable by normal user
    local file664="$tmp_dir/file664"
    touch "$file664"
    chmod 644 "$file664"

    #dir readable/writable by normal user
    local dir755="$tmp_dir/dir755"
    mkdir -p "$dir755"
    chmod 755 "$dir755"

    #file not readable/writable by normal user
    local file600="$tmp_dir/file600"
    touch "$file600"
    chmod 600 "$file600"
    sudo chown root:root "$file600"

    #dir not readable/writable by normal user
    local dir700="$tmp_dir/dir700"
    mkdir -p "$dir700"
    chmod 700 "$dir700"
    sudo chown root:root "$dir700"

    # Error Messages
    local path_not_exist_msg="The path \'$path_not_exist\' does not exist."
    local file_not_exist_msg="The file \'$path_not_exist\' does not exist."
    local dir_not_exist_msg="The directory \'$path_not_exist\' does not exist."
    _path_not_readable_msg() {
        echo "The path \'$1\' is not readable."
    }
    _path_not_writable_msg() {
        echo "The path \'$1\' is not writable."
    }

    # == file_get_owner ==
    ## file exist
    local my_file="${tmp_dir}/my_file"
    touch "$my_file"
    test_status_output_match "$_success" "$current_user" "file_get_owner file exists" file_get_owner "$my_file"
    ## file not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "File \'$path_not_exist\' owner cannot be determined.")" "file_get_owner not exist" file_get_owner "$path_not_exist"

    # == file_get_permissions ==
    ## file exist
    test_status_output_match "$_success" "644" "file_get_permissions file exists" file_get_permissions "$file664"
    ## file not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "File \'$path_not_exist\' permissions cannot be determined.")" "file_get_permissions not exist" file_get_permissions "$path_not_exist"

    # == path_exists ==
    ## dir exist
    test_status_is "$_success" "path_exists dir exist" path_exists "$dir755"
    ## dir not exist, _log_is_on
    test_status_output_match "$_failure" "$path_not_exist_msg" "path_exists dir not exist, _log_is_on" path_exists "$path_not_exist"
    ## dir not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_exists dir not exist, _log_is_off" path_exists "$path_not_exist" --no-log
    ## file exist
    test_status_is "$_success" "path_exists file exist" path_exists "$file664"
    ## file not exist, _log_is_on
    test_status_output_match "$_failure" "$path_not_exist_msg" "path_exists file not exist, _log_is_on" path_exists "$path_not_exist"
    ## file not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_exists file not exist, _log_is_off" path_exists "$path_not_exist" --no-log

    # == path_is_readable ==
    ## dir not exist
    test_status_output_match "$_failure" "$(_path_not_readable_msg $path_not_exist)" "path_is_readable dir not exist, _log_is_on" path_is_readable "$path_not_exist"
    ## dir readable
    test_status_is "$_success" "path_is_readable dir exist" path_is_readable "$dir755"
    ## dir not readable, _log_is_on
    test_status_output_match "$_failure" "$(_path_not_readable_msg $dir700)" "path_is_readable dir not readable, _log_is_on" path_is_readable "$dir700"
    ## dir not readable, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_is_readable dir not readable, _log_is_off" path_is_readable "$dir700" --no-log
    ## file not exist
    test_status_output_match "$_failure" "$(_path_not_readable_msg $path_not_exist)" "path_is_readable file not exist, _log_is_on" path_is_readable "$path_not_exist"
    ## file readable
    test_status_is "$_success" "path_is_readable file exist" path_is_readable "$file664"
    ## file not readable, _log_is_on
    test_status_output_match "$_failure" "$(_path_not_readable_msg $file600)" "path_is_readable file not readable, _log_is_on" path_is_readable "$file600"
    ## file not readable, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_is_readable file not readable, _log_is_off" path_is_readable "$file600" --no-log

    # == path_is_writable ==
    ## dir not exist
    test_status_output_match "$_failure" "$(_path_not_writable_msg $path_not_exist)" "path_is_writable dir not exist, _log_is_on" path_is_writable "$path_not_exist"
    ## dir not writable, _log_is_on
    test_status_output_match "$_failure" "$(_path_not_writable_msg $dir700)" "path_is_writable dir not writable, _log_is_on" path_is_writable "$dir700"
    ## dir not writable, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_is_writable dir not writable, _log_is_off" path_is_writable "$dir700" --no-log
    ## dir writable
    test_status_is "$_success" "path_is_writable dir exist" path_is_writable "$dir755"
    ## file not exist
    test_status_output_match "$_failure" "$(_path_not_writable_msg $path_not_exist)" "path_is_writable file not exist, _log_is_on" path_is_writable "$path_not_exist"
    ## file not writable, _log_is_on
    test_status_output_match "$_failure" "$(_path_not_writable_msg $file600)" "path_is_writable file not writable, _log_is_on" path_is_writable "$file600"
    ## file not writable, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_is_writable file not writable, _log_is_off" path_is_writable "$file600" --no-log
    ## file writable 
    test_status_is "$_success" "path_is_writable file exist" path_is_writable "$file664"

    # == path_is_file ==
    ## file exist
    test_status_is "$_success" "path_is_file file exist" path_is_file "$file664"
    ## dir exist
    test_status_is "$_failure" "path_is_file dir exist" path_is_file "$dir755"
    ## path not exist
    ### file name with extension
    test_status_is "$_success" "path_is_file dir, file name with extension" path_is_file "filename.txt"
    ### dir and file name with extension
    test_status_is "$_success" "path_is_file dir, file name with extension" path_is_file "dir/filename.txt"
    ### current dir and file name with extension
    test_status_is "$_success" "path_is_file current dir, file name with extension" path_is_file "./filename.txt"
    ### dir only
    test_status_is "$_failure" "path_is_file dir only" path_is_file "dir/"
    ### two dirs
    test_status_is "$_failure" "path_is_file two dirs" path_is_file "dir/subdir/"
    ### current dir only
    test_status_is "$_failure" "path_is_file current dir only" path_is_file "./"
    ### parent dir only
    test_status_is "$_failure" "path_is_file parent dir only" path_is_file "../"
    ### empty path
    test_status_is "$_failure" "path_is_file empty path" path_is_file ""
    ### loose file name with extension
    test_status_is "$_failure" "path_is_file loose word" path_is_file "word"
    ### dir and loose word
    test_status_is "$_failure" "path_is_file dir and loose word" path_is_file "dir/word"
    ### loose word starting with dot
    test_status_is "$_failure" "path_is_file loose word starting with dot" path_is_file ".word"

    ## path
    # == file_exists ==
    ## file exist
    test_status_is "$_success" "file_exists file exist" file_exists "$file664"
    ## file not exist, _log_is_on
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_exists file not exist, _log_is_on" file_exists "$path_not_exist"
    ## file not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_exists file not exist, _log_is_off" file_exists "$path_not_exist" --no-log

    # == dir_exists ==
    ## dir exist
    test_status_is "$_success" "dir_exists dir exist" dir_exists "$dir755"
    ## dir not exist, _log_is_on
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_exists dir not exist, _log_is_on" dir_exists "$path_not_exist"
    ## dir not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_exists dir not exist, _log_is_off" dir_exists "$path_not_exist" --no-log

    # == dir_is_readable ==
    ## dir readable
    test_status_is "$_success" "dir_is_readable dir exist" dir_is_readable "$dir755"
    test_status_is "$_success" "dir_is_readable dir exist , sudo" dir_is_readable "$dir755" --sudo
    ## dir not readable
    ### _log_is_on
    test_status_output_match "$_failure" "$(_path_not_readable_msg $dir700)" "dir_is_readable dir not readable, _log_is_on" dir_is_readable "$dir700"
    test_status_is "$_success" "dir_is_readable dir not readable, _log_is_on, sudo" dir_is_readable "$dir700" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_readable dir not readable, _log_is_off" dir_is_readable "$dir700" --no-log
    test_status_is "$_success" "dir_is_readable dir not readable, _log_is_off, sudo" dir_is_readable "$dir700" --no-log --sudo
    ## dir not exist
    ### _log_is_on
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_readable dir not exist, _log_is_on" dir_is_readable "$path_not_exist"
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_readable dir not exist, _log_is_on, sudo" dir_is_readable "$path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_readable dir not exist, _log_is_off" dir_is_readable "$path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_readable dir not exist, _log_is_off, sudo" dir_is_readable "$path_not_exist" --no-log --sudo

    # == dir_is_writable ==
    ## dir writable
    test_status_is "$_success" "dir_is_writable dir exist" dir_is_writable "$dir755"
    test_status_is "$_success" "dir_is_writable dir exist , sudo" dir_is_writable "$dir755" --sudo
    ## dir not writable
    ### _log_is_on
    test_status_output_match "$_failure" "$(_path_not_writable_msg $dir700)" "dir_is_writable dir not writable, _log_is_on" dir_is_writable "$dir700"
    test_status_is "$_success" "dir_is_writable dir not writable, _log_is_on, sudo" dir_is_writable "$dir700" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_writable dir not writable, _log_is_off" dir_is_writable "$dir700" --no-log
    test_status_is "$_success" "dir_is_writable dir not writable, _log_is_off, sudo" dir_is_writable "$dir700" --no-log --sudo
    ## dir not exist
    ### _log_is_on
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_writable dir not exist, _log_is_on" dir_is_writable "$path_not_exist"
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_writable dir not exist, _log_is_on, sudo" dir_is_writable "$path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_writable dir not exist, _log_is_off" dir_is_writable "$path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_writable dir not exist, _log_is_off, sudo" dir_is_writable "$path_not_exist" --no-log --sudo

    # == file_is_readable ==
    ## file readable
    test_status_is "$_success" "file_is_readable file exist" file_is_readable "$file664"
    test_status_is "$_success" "file_is_readable file exist, sudo" file_is_readable "$file664" --sudo
    ## file not readable
    ### _log_is_on
    test_status_output_match "$_failure" "$(_path_not_readable_msg $file600)" "file_is_readable file not readable, _log_is_on" file_is_readable "$file600"
    test_status_is "$_success" "file_is_readable file not readable, _log_is_on, sudo" file_is_readable "$file600" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_readable file not readable, _log_is_off" file_is_readable "$file600" --no-log
    test_status_is "$_success" "file_is_readable file not readable, _log_is_off, sudo" file_is_readable "$file600" --no-log --sudo
    ## file not exist
    ### _log_is_on
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_readable file not exist, _log_is_on" file_is_readable "$path_not_exist"
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_readable file not exist, _log_is_on, sudo" file_is_readable "$path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_readable file not exist, _log_is_off" file_is_readable "$path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_readable file not exist, _log_is_off, sudo" file_is_readable "$path_not_exist" --no-log --sudo

    # == file_is_writable == TODO: sudo
    ## file writable
    test_status_is "$_success" "file_is_writable file exist" file_is_writable "$file664"
    test_status_is "$_success" "file_is_writable file exist, sudo" file_is_writable "$file664" --sudo
    ## file not writable
    ### _log_is_on
    test_status_output_match "$_failure" "$(_path_not_writable_msg $file600)" "file_is_writable file not writable, _log_is_on" file_is_writable "$file600"
    test_status_is "$_success" "file_is_writable file not writable, _log_is_on, sudo" file_is_writable "$file600" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_writable file not writable, _log_is_off" file_is_writable "$file600" --no-log
    test_status_is "$_success" "file_is_writable file not writable, _log_is_off, sudo" file_is_writable "$file600" --no-log --sudo
    ## file not exist
    ### _log_is_on
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_writable file not exist, _log_is_on" file_is_writable "$path_not_exist"
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_writable file not exist, _log_is_on, sudo" file_is_writable "$path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_writable file not exist, _log_is_off" file_is_writable "$path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_writable file not exist, _log_is_off, sudo" file_is_writable "$path_not_exist" --no-log --sudo

    # == path_create (--sudo) ==
    ## dir not exists
    local new_dir="$tmp_dir/path_create"
    test_status_output_match "$_success" "Directory path \'$new_dir\' created." "path_create: dir not exists" path_create "$new_dir"
    ## dir exists
    test_status_output_match "$_success" "$(regex_build_empty)" "path_create: path already exists" path_create "$tmp_dir"
    ##  path is a file
    test_status_output_match "$_failure" "$(regex_build_all "The path \'file.txt\' is a file." "Cannot create directory path for a file.")" "path_create: path is a file" path_create "file.txt"

    # == file_clear  (--sudo) ==
    ## file does not exist
    ## file is not writable
    ## file is writable

    # == file_str_append (--sudo) ==
    ## file does not exist
    ## file is not writable
    ## file is writable

    # == file_str_replace (--sudo) ==

    # == file_str_contains ==
    # TODO: check implementation

    # == file_backup (--sudo) ==
    ## file does not exist
    ## file exists / file is not readable ?

    # == file_content_write (--sudo --no-log) ==
    ## file does not exist
    ## file is not writable
    ## file is writable and blank content
    ## file is writable and non-blank content

    # == file_create_with_content (--sudo) ==
    ## file does not exist
    ## file exists
    ## ?

    # == file_create_empty (--sudo) ==
    ## file does not exist
    ## file exists
    ## ?

    # == file_from_template (--sudo) ==
    ## template does not exist
    ## template is not readable
    ## file does not exist
    ## file exists
    ## ?

    # == file_make_executable (--sudo) ==
    ## file does not exist
    ## file is not writable
    ## file is writable

    # == file_copy (--sudo) ==
    ## file does not exist
    ## file is not readable
    ## file is readable
    ## dest is a file
    ## dest is a dir
    ### dest does not exist
    ### dest is not writable
    ### dest is writable

    # == file_move (--sudo) ==
    ## file does not exist
    ## file is not readable
    ## file is readable
    ## dest is a file
    ## dest is a dir
    ### dest does not exist
    ### dest is not writable
    ### dest is writable

    # == file_overwrite (--sudo) ==
    ## file does not exist
    ## file is not readable
    ## file is readable
    ## dest is a file
    ## dest is a dir
    ### dest does not exist
    ### dest is not writable
    ### dest is writable

    # == file_delete (--sudo --ask) ==
    ## file does not exist
    ## file is not writable ?
    ## file is writable proceed
    ## file is writable cancel

    # == dir_delete_recursive (--sudo --ask) ==
    ## dir does not exist
    ## dir is not writable ?
    ## dir is writable proceed
    ## dir is writable cancel

    rm -rf "$tmp_dir"
}

test_system_operations() {
    echo
    # command_exists
    test_status_is "$_success" "command_exists: existing command" command_exists "ls"
    test_status_is "$_failure" "command_exists: non-existing command" command_exists "badcmd"

    # source_if_exists
    test_status_is "$_success" "source_if_exists: existing file" source_if_exists "data/file_exists"
    test_status_is "$_failure" "source_if_exists: non-existing file" source_if_exists "/path/to/nonexistent/file"
}

test_system_info() {
    echo
    # system_distro_name
    test_status_output_match "$_success" "$(regex_build_not_empty)" "system_distro_name" system_distro_name

    # system_distro_id
    test_status_output_match "$_success" "$(regex_build_not_empty)" "system_distro_id" system_distro_id

    # system_kernel_version
    test_status_output_match "$_success" "$(regex_build_not_empty)" "system_kernel_version" system_kernel_version

    # system_architecture
    test_status_output_match "$_success" "$(regex_build_not_empty)" "system_architecture" system_architecture

    # system_desktop_environment
    test_status_output_match "$_success" "$(regex_build_not_empty)" "system_desktop_environment" system_desktop_environment

    # system_display_server
    test_status_output_match "$_success" "$(regex_build_not_empty)" "system_display_server" system_display_server
}

test_network_operations() {
    echo
    # download_file (--use_sudo)
    ## destination dir does not exist
    ## destination dir not writable
    ## invalid URL
    ## download success with dest defined
    ## download success with dest undefined
}

test_flow() {
    # Helper function for flow tests
    _flow_test_helper() {
        local test_name="$1"
        local input_seq="$2"
        local positive_regex="$3"
        local negative_regex="$4"
        local expected_status="${5:-$_success}"
        local flow_steps="${6:-flow}"
        test_status_output_match "$expected_status" "$positive_regex" "flow_run: $test_name positive" run_autoinput "$input_seq" flow_run $flow_steps
        test_status_output_match "$expected_status" "$negative_regex" "flow_run: $test_name negative" run_autoinput "$input_seq" flow_run $flow_steps
    }

    # flow input keys
    local continue=1
    local skip=2
    local quit=3

    # STEP A definitions
    local stepA_name="Step A"
    local stepA_head_msg="\[1/2] STEP: $stepA_name"
    local stepA_run_msg="Execution of $stepA_name"
    local stepA_executing_message="Executing STEP: $stepA_name"
    local stepA_skipping_message="Skipping STEP: $stepA_name"
    local stepA_completed_message="Step '$stepA_name' completed successfully"

    stepA() {
        echo "$stepA_run_msg"
        return $_success
    }

    # STEP B definitions
    local stepB_name="Step B"
    local stepB_head_msg="\[2/2] STEP: $stepB_name"
    local stepB_run_msg="Execution of $stepB_name"
    local stepB_executing_message="Executing STEP: $stepB_name"
    local stepB_skipping_message="Skipping STEP: $stepB_name"
    local stepB_completed_message="Step '$stepB_name' completed successfully"

    stepB() {
        echo "$stepB_run_msg"
        return $_success
    }

    # FLOW definitions
    local flow_completed_message="Flow execution completed"
    local flow_aborted_message="Aborting the flow execution"

    declare -A flow=(
        [stepA]="Step A"
        [stepB]="Step B"
    )

    ## BASIC CUI
    local basic_cui_items=(
        "Starting flow execution"
        "Please select an option:"
        "Continue"
        "Skip"
        "Quit"
    )
    test_status_output_match "$_success" "$(regex_build_all "${basic_cui_items[@]}")" "flow_run: basic cui" run_autoinput "$quit" flow_run flow

    ## CONTINUE : Continue A, Continue B
    local continue_positive_items=(
        "$stepA_head_msg"
        "$stepA_executing_message"
        "$stepA_run_msg"
        "$stepA_completed_message"
        "$stepB_head_msg"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
        "$flow_completed_message"
    )
    local continue_negative_items=(
        "$stepA_skipping_message"
        "$stepB_skipping_message"
        "$flow_aborted_message"
    )    
    _flow_test_helper "Continue A, Continue B" "$continue$continue" \
        "$(regex_build_all "${continue_positive_items[@]}")" \
        "$(regex_build_none "${continue_negative_items[@]}")"

    ## SKIP : Continue A, Skip B
    local skip_positive_items=(
        "$stepA_head_msg"
        "$stepA_executing_message"
        "$stepA_run_msg"
        "$stepA_completed_message"
        "$stepB_head_msg"
        "$stepB_skipping_message"
        "$flow_completed_message"
    )
    local skip_negative_items=(
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
    )
    _flow_test_helper "Continue A, Skip B" "$continue$skip" \
        "$(regex_build_all "${skip_positive_items[@]}")" \
        "$(regex_build_none "${skip_negative_items[@]}")"

    ## SKIP : Skip A, Continue B
    local skip_positive_items=(
        "$stepA_head_msg"
        "$stepA_skipping_message"
        "$stepB_head_msg"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
        "$flow_completed_message"
    )
    local skip_negative_items=(
        "$stepA_executing_message"
        "$stepA_run_msg"
        "$stepA_completed_message"
    )
    _flow_test_helper "Skip A, Continue B" "$skip$continue" \
        "$(regex_build_all "${skip_positive_items[@]}")" \
        "$(regex_build_none "${skip_negative_items[@]}")"

    ## SKIP : Skip A, Skip B
    local skip_positive_items=(
        "$stepA_head_msg"
        "$stepA_skipping_message"
        "$stepB_head_msg"
        "$stepB_skipping_message"
        "$flow_completed_message"
    )
    local skip_negative_items=(
        "$stepA_executing_message"
        "$stepA_run_msg"
        "$stepA_completed_message"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
    )
    _flow_test_helper "Skip A, Skip B" "$skip$skip" \
        "$(regex_build_all "${skip_positive_items[@]}")" \
        "$(regex_build_none "${skip_negative_items[@]}")"

    ## QUIT : Continue A, Quit on B
    local quit_positive_items=(
        "$stepA_head_msg"
        "$stepA_executing_message"
        "$stepA_run_msg"
        "$stepA_completed_message"
        "$stepB_head_msg"
        "$flow_aborted_message"
    )
    local quit_negative_items=(
        "$stepB_skipping_message"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
        "$flow_completed_message"
    )
    _flow_test_helper "Continue A, Quit on B" "$continue$quit" \
        "$(regex_build_all "${quit_positive_items[@]}")" \
        "$(regex_build_none "${quit_negative_items[@]}")"

    ## QUIT : Skip A, Quit on B
    local quit_positive_items=(
        "$stepA_head_msg"
        "$stepA_skipping_message"
        "$stepB_head_msg"
        "$flow_aborted_message"
    )
    local quit_negative_items=(
        "$stepA_executing_message"
        "$stepA_run_msg"
        "$stepA_completed_message"
        "$stepB_skipping_message"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
        "$flow_completed_message"
    )
    _flow_test_helper "Skip A, Quit on B" "$skip$quit" \
        "$(regex_build_all "${quit_positive_items[@]}")" \
        "$(regex_build_none "${quit_negative_items[@]}")"

    ## QUIT : Quit on A
    local quit_positive_items=(
        "$stepA_head_msg"
        "$flow_aborted_message"
    )
    local quit_negative_items=(
        "$stepA_executing_message"
        "$stepA_run_msg"
        "$stepA_completed_message"
        "$stepB_head_msg"
        "$stepB_skipping_message"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
        "$flow_completed_message"
    )
    _flow_test_helper "Quit on A" "$quit" \
        "$(regex_build_all "${quit_positive_items[@]}")" \
        "$(regex_build_none "${quit_negative_items[@]}")"

    # STEP with failure

    # STEP F definitions
    local stepF_name="Step F"
    local stepF_head_msg="\[1/2] STEP: $stepF_name"
    local stepF_run_msg="Execution of $stepF_name"
    local stepF_executing_message="Executing STEP: $stepF_name"
    local stepF_skipping_message="Skipping STEP: $stepF_name"
    local stepF_completed_message="Step '$stepF_name' completed successfully"
    local stepF_failed_message="The execution of '$stepF_name' failed."

    stepF() {
        echo "$stepF_run_msg"
        return $_failure
    }

    # Flow definitions with failure step
    local flow_resume_on_failure_message="Do you want to continue the flow despite the error?"
    local flow_aborted_on_failure_message="Aborting flow execution due to error"

    declare -A flow_with_fail=(
        [stepF]="$stepF_name"
        [stepB]="$stepB_name"
    )

    # Failure input keys
    local proceed='y'
    local abort='n'

    ## FAILURE: Proceed on F and Continue B
    local positive_items=(
        "$stepF_head_msg"
        "$stepF_executing_message"
        "$stepF_run_msg"
        "$stepF_failed_message"
        "$flow_resume_on_failure_message"
        "$stepB_head_msg"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
        "$flow_completed_message"
    )
    local negative_items=(
        "$stepF_skipping_message"
        "$stepF_completed_message"
        "$flow_aborted_on_failure_message"
    )
    _flow_test_helper "Failure and Proceed" "$continue$proceed$continue" \
        "$(regex_build_all "${positive_items[@]}")" \
        "$(regex_build_none "${negative_items[@]}")" \
        $_success flow_with_fail

    ## FAILURE: Abort on F
    local positive_items=(
        "$stepF_head_msg"
        "$stepF_executing_message"
        "$stepF_run_msg"
        "$stepF_failed_message"
        "$flow_resume_on_failure_message"
        "$flow_aborted_on_failure_message"
    )
    local negative_items=(
        "$stepF_skipping_message"
        "$stepF_completed_message"
        "$stepB_head_msg"
        "$stepB_executing_message"
        "$stepB_run_msg"
        "$stepB_completed_message"
        "$flow_completed_message"
    )
    _flow_test_helper "Failure and Abort" "$continue$abort" \
        "$(regex_build_all "${positive_items[@]}")" \
        "$(regex_build_none "${negative_items[@]}")" \
        $_failure flow_with_fail
}

fixtures=(
    test_helpers_sanity_check
    test_comparisons
    test_assertions
    test_regex
    test_runners
    test_ui_messages
    test_user_interactions
    test_prompt_menu
    test_validations
    test_file_operations
    test_system_operations
    test_network_operations
    test_flow
)

clear
test_fixtures_run "Unit Tests" "${fixtures[@]}"
