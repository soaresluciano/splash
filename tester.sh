#!/bin/bash
source ./spla.sh

# recommended: call the function directly using run_autoinput
run_output_contains out "Operation cancelled by user." run_autoinput 'n' prompt_proceed "RESOURCE"
echo $?