import os
import sys
import subprocess

def is_elf_executable(file_path):
    try:
        result = subprocess.run(['file', file_path], capture_output=True, text=True)
        return 'ELF 64-bit LSB executable' in result.stdout
    except Exception as e:
        print(f"Error checking file type: {e}")
        return False

def create_wrapper_script(executable_path, wrapper_path):
    DIR="a"
    BASH_SOURCE="a"
    script_content = f"""#!/bin/bash
DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# shellcheck source=/dev/null
source "${DIR}/setenv" # type: ignore
exec "{executable_path}" "$@"
"""
    with open(wrapper_path, 'w') as wrapper_file:
        wrapper_file.write(script_content)
    os.chmod(wrapper_path, 0o755)

def main(target_folder):
    current_folder = os.getcwd()
    for root, dirs, files in os.walk(target_folder):
        for file in files:
            file_path = os.path.join(root, file)
            if is_elf_executable(file_path):
                wrapper_path = os.path.join(current_folder, file)
                if not os.path.exists(wrapper_path):
                    create_wrapper_script(file_path, wrapper_path)
                    print(f"Created wrapper for {file_path} at {wrapper_path}")
                    # sys.exit(1)
                else:
                    print(f"Wrapper already exists for {file_path} at {wrapper_path}, skipping.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Error: Exactly one argument (target folder) is required.")
        sys.exit(1)
    
    target_folder = sys.argv[1]

    if not os.path.exists(target_folder):
        print(f"Error: The target folder '{target_folder}' does not exist.")
        sys.exit(1)

    main(target_folder)