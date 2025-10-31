## TODO

test -z <> file_is_empty
grep -Fxq <> file_content_is

## verify
- file_str_contains : check implementation

- file_create_with_content: add log and ask

## bugs
workflow:
- steps execute out of order
- auto run flow (like unit tests)

file_content_write: file_is_writable

sudo: tests are using sudo when they should not

prompt_proceed : display is weird

## improve
### file_copy: 
    - dest in not writable
    - error handling
    - log
    - file exists
### file_move:
    - dest in not writable
    - error handling
    - log
    - file exists

## ideas
-dir is empty
- prompt to exit
- all file methods consistent:
    - error handling
    - return status
    - file/dir  exist, readable, writable validations
    - sudo, log, ask
- Loading 
- find a better way to load the lib

### prompt_yesno
 - yesno = yes is default
 - noyes = no is default

### show_selection
 - extact menu logic

### prompt_question
 - individual params?
 - default option:
    - highlight
    - use it
- use prompt_menu always? 

### redirects
 - run on std and log file at same time

### is_connected / can_reach
```
ping -c 1 -W 1 1.1.1.1
```

### print0
```
printf "%s\0" "${myarray[@]}"
```

### str_join
```
( IFS=$delimiter; echo "${sub_strs[*]}" )
```
* If  " " use `arr_to_str`

### arr_to_str
```
echo "$array[*]"
```

### arr_len
```
echo ${#array[@]}
```

### arr_indexes_ordered
```
echo "${!array[@]}"
```

### for each ?
```
for i in ${arr_indexes target_array}; do
printf "$target_array[i]" | cmd
```

### from py
Compression
- untargz
- unzip
- unrar

FileSys
- delete_directory
- copy_files(file_names: list, source_dir: str, dest_dir: str, sudo: bool = False) 
- files_validation(expected_file_names: list, directory: str)
- files_path_validation(expected_paths: list)
- folders_validation(expected_folders: list)
- create_syslink(source, target)
- delete_syslink(target)
- file_is_empty

Sys
- user_has_groups(groups: List[str])

Github
- get_latest_release_info(user: str, repo: str)
- download_latest(user: str, repo: str, target_dir, strip_components=0)

Wine
- run_wine_command_with_env
- run_wine_command
- run_proton_command

Runners
- run_with_env(commands: list, new_env: dict):
- run_and_forget(commands: list): (subprocess)

Notification

def detailed_log(message: str, details: list) -> None:
    info(f":: {message}")
    for detail in details:
        log(f"    - {detail}")

## ICONS

success ✅ "✔" ☑
error = ❌ "✘" ☒
header 🟣 "➔"
warning ⚠️ "⚠"
info ℹ️ "✉" 🛈
suggestion 💡 "" ☞ ★
bullet1 ▫️ "▫"
bullet2 ▪️"▪"
question ❔ "⍰ 🯄" ⯑
continue ▶️ "▶" ▷
checking 🔍 "" 🗲 ⏱ ☘ ⚖ 

sudo ⚿
