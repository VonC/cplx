#!/bin/bash

input_file="${1}"
temp_file="${input_file}.tmp"

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ $line =~ ^(#+[[:space:]]+)([^\[]+)\[🔗\]\(#([^\)]*)\)([[:space:]]+\(done:\ ✅\))? ]]; then
        hashes="${BASH_REMATCH[1]}"
        title="${BASH_REMATCH[2]}"
        done_part="${BASH_REMATCH[4]}"
        # Transform title
        new_anchor=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | sed 's/^_*\|_*$//g')
        # Reconstruct line
        if [[ -n $done_part ]]; then
            echo "${hashes}${title}[🔗](#${new_anchor})${done_part}"
        else
            echo "${hashes}${title}[🔗](#${new_anchor})"
        fi
    else
        echo "$line"
    fi
done < "$input_file" > "$temp_file"

mv "$temp_file" "$input_file"