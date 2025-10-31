#!/bin/bash
source ../spla.sh

_path_not_exist="path_not_exist"
_target_file="data/target_file"
_target="TEST-TARGET-STRING"

_file_contains_line() {
    # usage: file_contains_line <file> <exact-line>
    # returns 0 if the exact line exists in file, non-zero otherwise
    local file="$1"
    local line="$2"
    # suppress grep errors (e.g. file missing) and preserve exit code
    grep -Fxq "$line" "$file" 2>/dev/null
}

_file_is_empty() {
    local file="$1"
    # behave like the inline test used previously
    test -z "$(<"$file")"
}

_file_is_executable() {
    local file="$1"
    # behave like the inline test used previously
    test -x "$file"
}

_files_equal() {
    # usage: _files_equal <expected_file> <actual_file>
    # returns 0 if files are identical, non-zero otherwise
    local expected="$1"
    local actual="$2"
    diff -q "$expected" "$actual" >/dev/null 2>&1
}

_make_test_file() {
    local file_path="$1"
    touch "$file_path"
    echo "$file_path"
}

_copy_target_file() {
    local dest_path="$1"
    cp "$_target_file" "$dest_path"
    echo "$dest_path"
}

_make_test_dir() {
    local dir_path="$1"
    mkdir -p "$dir_path"
    echo "$dir_path"
}

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

validate_script() {
    show_header "Validating script syntax..."
    bash -n ../spla.sh
    if [ $? -ne 0 ]; then
        show_error "Script validation failed."
        exit 1
    else
        show_success "Script validation passed."
    fi
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
    #TODO: use splash tmp dir for tests
    cleanup() {
        sudo rm -rf "$tmp_dir"
    }

    cleanup

    local current_user=$(whoami)

    local tmp_dir="tmp"
    mkdir -p "$tmp_dir"

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
    local path_not_exist_msg="The path \'$_path_not_exist\' does not exist."
    local file_not_exist_msg="The file \'$_path_not_exist\' does not exist."
    local dir_not_exist_msg="The directory \'$_path_not_exist\' does not exist."
    _path_not_readable_msg() {
        echo "The path \'$1\' is not readable."
    }
    _path_not_writable_msg() {
        echo "The path \'$1\' is not writable."
    }

    # == file_get_owner ==
    ## file exist
    local my_file=$(_make_test_file "${tmp_dir}/my_file")
    test_status_output_match "$_success" "$current_user" "file_get_owner file exists" file_get_owner "$my_file"
    ## file not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "File \'$_path_not_exist\' owner cannot be determined.")" "file_get_owner not exist" file_get_owner "$_path_not_exist"

    # == file_get_permissions ==
    ## file exist
    test_status_output_match "$_success" "644" "file_get_permissions file exists" file_get_permissions "$file664"
    ## file not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "File \'$_path_not_exist\' permissions cannot be determined.")" "file_get_permissions not exist" file_get_permissions "$_path_not_exist"

    # == path_exists ==
    ## dir exist
    test_status_is "$_success" "path_exists dir exist" path_exists "$dir755"
    ## dir not exist, _log_is_on
    test_status_output_match "$_failure" "$_path_not_exist_msg" "path_exists dir not exist, _log_is_on" path_exists "$_path_not_exist"
    ## dir not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_exists dir not exist, _log_is_off" path_exists "$_path_not_exist" --no-log
    ## file exist
    test_status_is "$_success" "path_exists file exist" path_exists "$file664"
    ## file not exist, _log_is_on
    test_status_output_match "$_failure" "$_path_not_exist_msg" "path_exists file not exist, _log_is_on" path_exists "$_path_not_exist"
    ## file not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_exists file not exist, _log_is_off" path_exists "$_path_not_exist" --no-log

    # == path_is_readable ==
    ## dir not exist
    test_status_output_match "$_failure" "$(_path_not_readable_msg $_path_not_exist)" "path_is_readable dir not exist, _log_is_on" path_is_readable "$_path_not_exist"
    ## dir readable
    test_status_is "$_success" "path_is_readable dir exist" path_is_readable "$dir755"
    ## dir not readable, _log_is_on
    test_status_output_match "$_failure" "$(_path_not_readable_msg $dir700)" "path_is_readable dir not readable, _log_is_on" path_is_readable "$dir700"
    ## dir not readable, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_is_readable dir not readable, _log_is_off" path_is_readable "$dir700" --no-log
    ## file not exist
    test_status_output_match "$_failure" "$(_path_not_readable_msg $_path_not_exist)" "path_is_readable file not exist, _log_is_on" path_is_readable "$_path_not_exist"
    ## file readable
    test_status_is "$_success" "path_is_readable file exist" path_is_readable "$file664"
    ## file not readable, _log_is_on
    test_status_output_match "$_failure" "$(_path_not_readable_msg $file600)" "path_is_readable file not readable, _log_is_on" path_is_readable "$file600"
    ## file not readable, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_is_readable file not readable, _log_is_off" path_is_readable "$file600" --no-log

    # == path_is_writable ==
    ## dir not exist
    test_status_output_match "$_failure" "$(_path_not_writable_msg $_path_not_exist)" "path_is_writable dir not exist, _log_is_on" path_is_writable "$_path_not_exist"
    ## dir not writable, _log_is_on
    test_status_output_match "$_failure" "$(_path_not_writable_msg $dir700)" "path_is_writable dir not writable, _log_is_on" path_is_writable "$dir700"
    ## dir not writable, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "path_is_writable dir not writable, _log_is_off" path_is_writable "$dir700" --no-log
    ## dir writable
    test_status_is "$_success" "path_is_writable dir exist" path_is_writable "$dir755"
    ## file not exist
    test_status_output_match "$_failure" "$(_path_not_writable_msg $_path_not_exist)" "path_is_writable file not exist, _log_is_on" path_is_writable "$_path_not_exist"
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

    # == file_exists ==
    ## file exist
    test_status_is "$_success" "file_exists file exist" file_exists "$file664"
    ## file not exist, _log_is_on
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_exists file not exist, _log_is_on" file_exists "$_path_not_exist"
    ## file not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_exists file not exist, _log_is_off" file_exists "$_path_not_exist" --no-log

    # == dir_exists ==
    ## dir exist
    test_status_is "$_success" "dir_exists dir exist" dir_exists "$dir755"
    ## dir not exist, _log_is_on
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_exists dir not exist, _log_is_on" dir_exists "$_path_not_exist"
    ## dir not exist, _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_exists dir not exist, _log_is_off" dir_exists "$_path_not_exist" --no-log

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
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_readable dir not exist, _log_is_on" dir_is_readable "$_path_not_exist"
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_readable dir not exist, _log_is_on, sudo" dir_is_readable "$_path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_readable dir not exist, _log_is_off" dir_is_readable "$_path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_readable dir not exist, _log_is_off, sudo" dir_is_readable "$_path_not_exist" --no-log --sudo

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
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_writable dir not exist, _log_is_on" dir_is_writable "$_path_not_exist"
    test_status_output_match "$_failure" "$dir_not_exist_msg" "dir_is_writable dir not exist, _log_is_on, sudo" dir_is_writable "$_path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_writable dir not exist, _log_is_off" dir_is_writable "$_path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "dir_is_writable dir not exist, _log_is_off, sudo" dir_is_writable "$_path_not_exist" --no-log --sudo

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
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_readable file not exist, _log_is_on" file_is_readable "$_path_not_exist"
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_readable file not exist, _log_is_on, sudo" file_is_readable "$_path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_readable file not exist, _log_is_off" file_is_readable "$_path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_readable file not exist, _log_is_off, sudo" file_is_readable "$_path_not_exist" --no-log --sudo

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
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_writable file not exist, _log_is_on" file_is_writable "$_path_not_exist"
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_is_writable file not exist, _log_is_on, sudo" file_is_writable "$_path_not_exist" --sudo
    ### _log_is_off
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_writable file not exist, _log_is_off" file_is_writable "$_path_not_exist" --no-log
    test_status_output_match "$_failure" "$(regex_build_empty)" "file_is_writable file not exist, _log_is_off, sudo" file_is_writable "$_path_not_exist" --no-log --sudo

    # == file_is_empty ==
    ## file not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "The file '$_path_not_exist' cannot be checked for emptiness.")" "file_is_empty file not exist" file_is_empty "$_path_not_exist"

    ## file exist and is empty
    local empty_file=$(_make_test_file "$tmp_dir/empty_file")
    test_status_is "$_success" "file_is_empty file exist and is empty" file_is_empty "$empty_file"
    ## file is not readable and empty
    test_status_is "$_success" "file_is_empty file exist and is empty" file_is_empty "$file600"
    ## file exist and is not empty
    test_status_is "$_failure" "file_is_empty file exist and is not empty" file_is_empty "$_target_file"


    # == path_create == TODO: sudo
    ## dir exists
    test_status_output_match "$_success" "$(regex_build_empty)" "path_create: path already exists" path_create "$tmp_dir"
    ## dir not exists
    local new_dir="$tmp_dir/path_create1"
    test_status_output_match "$_success" "Directory path \'$new_dir\' created." "path_create: dir without trailing slash not exists" path_create "$new_dir"
    test_status_is "$_success" "path_create: dir without trailing slash created" dir_exists "$new_dir"
    ## dir not exists
    local new_dir="$tmp_dir/path_create2/"
    test_status_output_match "$_success" "Directory path \'$new_dir\' created." "path_create: dir with trailing slash not exists" path_create "$new_dir"
    test_status_is "$_success" "path_create: dir with trailing slash created" dir_exists "$new_dir"
    ##  path is a file
    local new_dir="$tmp_dir/path_create3"
    local file_path="${new_dir}/some_file.txt"
    test_status_output_match "$_success" "Directory path \'$new_dir\' created." "path_create: path is a file" path_create "$file_path"
    test_status_is "$_success" "path_create: path is a file - dir created" dir_exists "$new_dir"

    # == file_content_clear == TODO: sudo
    # sad path tests
    ## file does not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "Cannot clear the file \'$_path_not_exist\'.")" "file_content_clear: file does not exist" file_content_clear "$_path_not_exist"
    ## file is not writable
    test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_writable_msg $file600)" "Cannot clear the file \'$file600\'.")" "file_content_clear: file is not writable" file_content_clear "$file600"
    
    # happy path tests
    ## file is writable
    local new_file=$(_copy_target_file "$tmp_dir/file_content_clear")
    test_status_is "$_success" "file_content_clear: file is writable" file_content_clear "$new_file"
    test_status_is "$_success" "file_content_clear: file is empty" _file_is_empty "$new_file"

    # == file_content_append == TODO: sudo
    # sad path tests
    ## file does not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "Cannot append to the file \'$_path_not_exist\'.")" "file_content_append: file does not exist" file_content_append "$_path_not_exist" "Some content"

    # happy path tests
    ## file is not writable
    test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_writable_msg $file600)" "Cannot append to the file \'$file600\'.")" "file_content_append: file is not writable" file_content_append "$file600" "Some content"
    ## file is writable
    local new_file=$(_copy_target_file "$tmp_dir/file_content_append")
    test_status_output_match "$_success" "The content was appended to $new_file." "file_content_append: file is writable" file_content_append "$new_file" "$_target"
    test_status_is "$_success" "file_content_append: file content correct" _file_contains_line "$new_file" "$_target$_target"

    # == file_content_replace == TODO: sudo
    # sad path tests
    ## file does not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "Cannot modify the file \'$_path_not_exist\'.")" "file_content_replace: file does not exist" file_content_replace "$_path_not_exist" "old/new"
    ## file is not writable
    test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_writable_msg $file600)" "Cannot modify the file \'$file600\'.")" "file_content_replace: file is not writable" file_content_replace "$file600" "old/new"
    
    # happy path tests
    ## file is writable
    local expectation_file="data/str_replace_expected"
    local template_file="data/str_replace"
    local new_file="$tmp_dir/file_content_replace"
    cp "$template_file" "$new_file"
    local pairs=("OLD1/NEW1" "OLD2/NEW2" "OLD3/NEW3" "OLD4/NEW4")
    test_status_output_match "$_success" "The $new_file was processed with ${#pairs[@]} replacements." "file_content_replace: file is writable" file_content_replace "$new_file" "${pairs[@]}"
    test_status_is "$_success" "file_content_replace: file content correct" _files_equal "$expectation_file" "$new_file"

    # == file_content_is == TODO: sudo
    #TODO

    # == file_content_matches == TODO: sudo
    #TODO

    # == file_backup == TODO: sudo
    ## file does not exist
    test_status_output_match "$_failure" "Nothing to backup. The file \'$_path_not_exist\' does not exist." "file_backup: file does not exist" file_backup "$_path_not_exist"
    #TODO: find a way to match the backup file was not created
    ## file is not readable
    # BUG: backup is created with sudo
    #test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_readable_msg $file600)" "Cannot backup the file \'$file600\'.")" "file_backup: file is not readable" file_backup "$file600"
    ##  file exists and readable
    test_status_output_match "$_success" "Backup created: $file664.bkp-" "file_backup: file exists and readable" file_backup "$file664"
    #TODO: find a way to match the backup file created
    #test_status_is "$_success" "file_backup: backup file created" path_exists "${file664}.bkp-*"

    # == file_content_write (--no-log) == TODO: sudo
    # sad path test
    ## file is not writable
    # TODO: implement

    # happy path tests
    ## file not exist - non-blank content
    local new_file="$tmp_dir/file_content_write.1"
    test_status_output_match "$_success" "The content was written to $new_file." "file_content_write: file not exist - non-blank content" file_content_write "$new_file" "$_target"
    test_status_is "$_success" "file_content_write: file not exist - non-blank content, file content correct" _file_contains_line "$new_file" "$_target"
    ## file not exist - blank content
    local new_file="$tmp_dir/file_content_write.2"
    test_status_output_match "$_success" "The content was written to $new_file." "file_content_write: file not exist - blank content" file_content_write "$new_file" ""
    test_status_is "$_success" "file_content_write: file not exist - blank content, file is empty" _file_is_empty "$new_file"
    ## file exists - non-blank content
    local content="Lorem ipsum dolor sit amet"
    local new_file=$(_copy_target_file "$tmp_dir/file_content_write.3")
    test_status_output_match "$_success" "The content was written to $new_file." "file_content_write: file exists - non-blank content" file_content_write "$new_file" "$content"
    test_status_is "$_success" "file_content_write: file exists - non-blank content, file content correct" _file_contains_line "$new_file" "$content"
    ## file exists - blank content
    local new_file=$(_copy_target_file "$tmp_dir/file_content_write.4")
    test_status_output_match "$_success" "The content was written to $new_file." "file_content_write: file exists - blank content" file_content_write "$new_file" ""
    test_status_is "$_success" "file_content_write: file exists - blank content, file is empty" _file_is_empty "$new_file"

    # == file_create_with_content == TODO: sudo
    ## file does not exist
    local new_file="$tmp_dir/file_create_with_content"
    test_status_output_match "$_success" "The file \'$new_file\' was created." "file_create_with_content: file does not exist" file_create_with_content "$new_file" "$_target"
    test_status_is "$_success" "file_create_with_content: file content correct" _file_contains_line "$new_file" "$_target"

    # == file_create_empty ==  TODO: sudo
    ## file does not exist
    local empty_file="$tmp_dir/file_create_empty"
    test_status_output_match "$_success" "The file \'$empty_file\' was created." "file_create_empty: file does not exist" file_create_empty "$empty_file"
    test_status_is "$_success" "file_create_empty: file is empty" _file_is_empty "$empty_file"

    # == file_from_template ==  TODO: sudo
    # sad path tests
    ## template does not exist
    local destination="$tmp_dir/not.created"
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "The template file \'$_path_not_exist\' cannot be used to create files.")" "file_from_template: template does not exist" file_from_template "$_path_not_exist" "$destination"
    test_status_is "$_failure" "file_from_template: template does not exist, target file not created" path_exists "$destination"
    ## template is not readable
    local destination="$tmp_dir/not.created"
    test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_readable_msg $file600)" "The template file \'$file600\' cannot be used to create files.")" "file_from_template: template is not readable" file_from_template "$file600" "$destination"
    test_status_is "$_failure" "file_from_template: template does not exist, target file not created" path_exists "$destination"
    
    # happy path tests
    ## file does not exist
    local new_file="$tmp_dir/file_from_template.test"
    test_status_output_match "$_success" "The file \'$new_file\' was created." "file_from_template: file does not exist" file_from_template "$_target_file" "$new_file"
    test_status_is "$_success" "file_create_with_content: file content correct" _file_contains_line "$new_file" "$_target"

    # == file_make_executable == TODO: sudo
    # sad path tests
    ## file does not exist
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "The file '$_path_not_exist' cannot be made executable.")" "file_make_executable: file does not exist" file_make_executable "$_path_not_exist"
    ## file is not writable
    test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_writable_msg $file600)" "The file '$file600' cannot be made executable.")" "file_make_executable: file is not writable" file_make_executable "$file600"
    test_status_is "$_failure" "file_make_executable: file is executable" _file_is_executable "$file600"
    
    # happy path tests
    ## file is writable
    local new_file=$(_make_test_file "$tmp_dir/file_make_executable")
    test_status_output_match "$_success" "The file '$new_file' is now executable." "file_make_executable: file is writable" file_make_executable "$new_file"
    test_status_is "$_success" "file_make_executable: file is executable" _file_is_executable "$new_file"

    # == file_copy == TODO: sudo
    # sad path tests
    ## file does not exist
    local destination="$tmp_dir/not.copied"
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "The file '$_path_not_exist' cannot be copied.")" "file_copy: file does not exist" file_copy "$_path_not_exist" "$destination"
    test_status_is "$_failure" "file_copy: file does not exist, file not copied" path_exists "$destination"
    ## file is not readable
    local destination="$tmp_dir/not.copied"
    test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_readable_msg $file600)" "The file '$file600' cannot be copied.")" "file_copy: file is not readable" file_copy "$file600" "$destination"
    test_status_is "$_failure" "file_copy: file is not readable, file not copied" path_exists "$destination"
    ## dest is not writable
    #TODO: implement

    # happy path tests
    ### dest is a dir that not exist
    local filename=$(basename "$_target_file")
    local destination="$tmp_dir/file_copy1/"
    test_status_output_match "$_success" "The file was copied to $destination." "file_copy: dest is a dir that not exist" file_copy "$_target_file" "$destination"
    test_status_is "$_success" "file_copy: dest is a dir that not exist, file copied" path_exists "${destination}${filename}"
    ### dest is a dir that exists
    local filename=$(basename "$_target_file")
    local destination=$(_make_test_dir "$tmp_dir/file_copy2/")
    test_status_output_match "$_success" "The file was copied to $destination." "file_copy: dest is a dir that exists" file_copy "$_target_file" "$destination"
    test_status_is "$_success" "file_copy: dest is a dir that exists, file copied" path_exists "${destination}${filename}"
    ## dest is a file and parent dir does not exist
    local destination="$tmp_dir/file_copy3/file_copy3.test"
    test_status_output_match "$_success" "The file was copied to $destination." "file_copy: dest is a file and parent dir does not exist" file_copy "$_target_file" "$destination"
    test_status_is "$_success" "file_copy: dest is a file and parent dir does not exist, file copied" path_exists "$destination"
    ## dest is a file and parent dir exists
    local destination="$tmp_dir/file_copy4.test"
    test_status_output_match "$_success" "The file was copied to $destination." "file_copy: dest is a file and parent dir exists" file_copy "$_target_file" "$destination"
    test_status_is "$_success" "file_copy: dest is a file and parent dir exists, file copied" path_exists "$destination"

    # == file_move == TODO: sudo
    # sad path tests
    ## file does not exist
    local destination="$tmp_dir/not_moved.test"
    test_status_output_match "$_failure" "$(regex_build_all "$file_not_exist_msg" "The file '$_path_not_exist' cannot be moved.")" "file_move: file does not exist" file_move "$_path_not_exist" "$destination"
    test_status_is "$_failure" "file_move: file does not exist, dest file not exist" path_exists "$destination"
    ## file is not readable
    local destination="$tmp_dir/not_moved.test"
    test_status_output_match "$_failure" "$(regex_build_all "$(_path_not_readable_msg $file600)" "The file '$file600' cannot be moved.")" "file_move: file is not readable" file_move "$file600" "$destination"
    test_status_is "$_failure" "file_move: file is not readable, dest file not exist" path_exists "$destination"
    test_status_is "$_success" "file_move: original file exist" path_exists "$file600"
    ### dest is not writable
    #TODO: implement

    # happy path tests
    ## dest is a dir that does not exist
    local original_file=$(_make_test_file "$tmp_dir/move1.test")
    local destination="$tmp_dir/file_move1/"
    test_status_output_match "$_success" "The file was moved to $destination." "file_move: dest is a dir that does not exist" file_move "$original_file" "$destination"
    test_status_is "$_success" "file_move: dest is a dir that does not exist, dest file exist" path_exists "${destination}move1.test"
    test_status_is "$_failure" "file_move: dest is a dir that does not exist, original file not exist" path_exists "$original_file"
    ## dest is a dir that exists
    local original_file=$(_make_test_file "$tmp_dir/move2.test")
    local filename=$(basename "$original_file")
    local destination=$(_make_test_dir "$tmp_dir/file_move2/")
    test_status_output_match "$_success" "The file was moved to $destination." "file_move: dest is a dir that exists" file_move "$original_file" "$destination"
    test_status_is "$_success" "file_move: dest is a dir that exists, dest file exists" path_exists "${destination}${filename}"
    test_status_is "$_failure" "file_move: dest is a dir that exists, original file not exist" path_exists "$original_file"
    ## dest is a file and parent dir does not exist
    local original_file=$(_make_test_file "$tmp_dir/move3.test")
    local dest_dir=$(_make_test_dir "$tmp_dir/file_move3/")
    local destination="${dest_dir}move3.test"
    test_status_output_match "$_success" "The file was moved to $destination." "file_move: dest is a file and parent dir does not exist" file_move "$original_file" "$destination"
    test_status_is "$_success" "file_move: dest is a file and parent dir does not exist, dest file exists" path_exists "$destination"
    test_status_is "$_failure" "file_move: dest is a file and parent dir does not exist, original file not exist" path_exists "$original_file"
    ### dest is a file and parent dir and it exists
    local destination="$tmp_dir/move2b.test"
    local original_file=$(_make_test_file "$tmp_dir/move2.test")
    test_status_output_match "$_success" "The file was moved to $destination." "file_move: dest is a file and parent dir and it exists" file_move "$original_file" "$destination"
    test_status_is "$_success" "file_move: dest is a file and parent dir and it exists, dest file exists" path_exists "$destination"
    test_status_is "$_failure" "file_move: dest is a file and parent dir and it exists, original file not exist" path_exists "$original_file"
    
    # == file_overwrite == TODO: sudo
    # sad path tests
    ## file does not exist
    local new_file="$tmp_dir/file_overwrite.1"
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_overwrite: file does not exist" file_overwrite "$_path_not_exist" "$new_file"
    ## file is not readable
    local new_file="$tmp_dir/file_overwrite.2"
    test_status_output_match "$_failure" "$(_path_not_readable_msg $file600)" "file_overwrite: file is not readable" file_overwrite "$file600" "$new_file"
    test_status_is "$_failure" "file_overwrite: file is not readable, target file not created" path_exists "$new_file"
    ## dest file is not writable
    #TODO: implement
    ## dest dir is not writable
    #TODO: implement

    # happy path tests
    ## dest is a dir that does not exist
    local new_file="$tmp_dir/file_overwrite1/file_overwrite.1"
    test_status_output_match "$_success" "The file was copied to $new_file." "file_overwrite: dest is a dir that does not exist" file_overwrite "$_target_file" "$new_file"
    test_status_is "$_success" "file_overwrite: dest is a dir that does not exist, now file exists" file_exists "$new_file"
    ## dest is a dir that exists
    local filename=$(basename "$_target_file")
    local new_dir=$(_make_test_dir "$tmp_dir/file_overwrite2/")
    test_status_output_match "$_success" "The file was copied to $new_dir" "file_overwrite: dest is a dir that exists" file_overwrite "$_target_file" "$new_dir"
    test_status_is "$_success" "file_overwrite: dest is a dir that exists, target file exists" file_exists "${new_dir}${filename}"
    ## dest is a file in a dir that does not exist
    local new_file="$tmp_dir/file_overwrite3/file_overwrite.3"
    test_status_output_match "$_success" "The file was copied to $new_file." "file_overwrite: dest is a file in a dir that does not exist" file_overwrite "$_target_file" "$new_file"
    test_status_is "$_success" "file_overwrite: dest is a file in a dir that does not exist, now file exists" file_exists "$new_file"
    ## dest is a file that does not exist
    local new_file="$tmp_dir/file_overwrite.4"
    test_status_output_match "$_success" "The file was copied to $new_file." "file_overwrite: dest is a file that does not exist" file_overwrite "$_target_file" "$new_file"
    test_status_is "$_success" "file_overwrite: dest is a file that does not exist, now file exists" file_exists "$new_file"
    ## dest is a file that exists
    local new_file=$(_make_test_file "$tmp_dir/file_overwrite.5")
    test_status_output_match "$_success" "The file was copied to $new_file." "file_overwrite: dest is a file that exists" file_overwrite "$_target_file" "$new_file"
    test_status_is "$_success" "file_overwrite: dest is a file that exists, target file content correct" _file_contains_line "$new_file" "$_target"

    # == file_delete == TODO: sudo
    # sad path tests
    ## file does not exist
    test_status_output_match "$_failure" "$file_not_exist_msg" "file_delete: file does not exist" file_delete "$_path_not_exist"
    ## file is not writable
    #TODO: implement

    # happy path tests
    ## no ask
    local target=$(_make_test_file "$tmp_dir/file_delete_no_ask.test")
    test_status_is "$_success" "file_delete: no ask" file_delete "$target"
    test_status_is "$_failure" "file_delete: no ask, file not exist" path_exists "$target"
    ## ask - proceed
    local target=$(_make_test_file "$tmp_dir/file_delete_ask_proceed.test")
    test_status_output_match "$_success" "$(regex_build_all "Do you want to proceed\? \(y\/N\)" "The file \'$target\' was deleted.")" "file_delete: ask proceed" run_autoinput "y" file_delete "$target" --ask
    test_status_is "$_failure" "file_delete: ask proceed, file not exist" path_exists "$target"
    ## ask - cancel
    local target=$(_make_test_file "$tmp_dir/file_delete_ask_cancel.test")
    test_status_output_match "$_failure" "$(regex_build_all "Do you want to proceed\? \(y\/N\)" "Operation cancelled by user." "File deletion aborted.")" "file_delete: ask cancel" run_autoinput "n" file_delete "$target" --ask
    test_status_is "$_success" "file_delete: ask cancel, file exist" path_exists "$target"

    # == dir_delete_recursive == TODO: sudo
    build_sample_dir_structure() {
        local dir="$1"
        local subtarget="$dir/subdir1/subsubdir1"
        mkdir -p "$subtarget"
        touch "$subtarget/file1"
    }

    # sad path tests
    ## dir does not exist
    test_status_output_match "$_failure" "Nothing to delete. The directory '$_path_not_exist' does not exist." "dir_delete: dir does not exist" dir_delete_recursive "$_path_not_exist"
    ## dir is not writable
    #TODO: Implement

    # happy path tests
    ## no ask
    local target="$tmp_dir/dir_delete_no_ask1"
    build_sample_dir_structure "$target"
    test_status_is "$_success" "dir_delete_recursive: no ask" dir_delete_recursive "$target"
    test_status_is "$_failure" "dir_delete_recursive: no ask, dir not exist" path_exists "$target"
    ## ask - proceed
    local target="$tmp_dir/dir_delete_ask_proceed"
    build_sample_dir_structure "$target"
    test_status_output_match "$_success" "$(regex_build_all "Do you want to proceed\? \(y\/N\)" "The directory \'$target\' was deleted.")" "dir_delete_recursive: ask proceed" run_autoinput "y" dir_delete_recursive "$target" --ask
    test_status_is "$_failure" "dir_delete_recursive: ask proceed, dir not exist" path_exists "$target"
    ## ask - cancel
    local target="$tmp_dir/dir_delete_ask_cancel"
    build_sample_dir_structure "$target"
    test_status_output_match "$_failure" "$(regex_build_all "Do you want to proceed\? \(y\/N\)" "Operation cancelled by user." "Directory deletion aborted.")" "dir_delete_recursive: ask cancel" run_autoinput "n" dir_delete_recursive "$target" --ask
    test_status_is "$_success" "dir_delete_recursive: ask cancel, dir exist" path_exists "$target"

    # Cleanup
    cleanup
}

test_system_operations() {
    echo
    # command_exists
    test_status_is "$_success" "command_exists: existing command" command_exists "ls"
    test_status_is "$_failure" "command_exists: non-existing command" command_exists "badcmd"

    # source_if_exists
    test_status_is "$_success" "source_if_exists: existing file" source_if_exists "$_target_file"
    test_status_is "$_failure" "source_if_exists: non-existing file" source_if_exists "$_path_not_exist"
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
    validate_script
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