#!/bin/bash
# Literal, identity-scoped package progress. No setup IO occurs on sourcing.

package_progress_entries() {
    local source=$1 line trimmed
    local -n progress_entries=$2 progress_comments=$3
    progress_entries=(); progress_comments=()
    [[ -f $source && -r $source ]] || return 9
    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        # Only the comment check trims whitespace; package expressions stay literal.
        trimmed=${line#"${line%%[![:space:]]*}"}
        if [[ $trimmed == \#* ]]; then
            progress_comments+=("$trimmed")
        elif [[ -n $line ]]; then
            progress_entries+=("$line")
        fi
    done < "$source"
}

package_progress_read() {
    local source=$1 bytes line field
    local -a record=()
    local -n progress_record=$2
    progress_record=()
    [[ -f $source && -r $source ]] || return 1
    # Read until EOF; a successful NUL-delimited read indicates invalid data.
    if IFS= read -r -d '' bytes < "$source"; then return 1; fi
    for ((field=0; field<4; field++)); do
        [[ $bytes == *$'\n'* ]] || return 1
        line=${bytes%%$'\n'*}; bytes=${bytes#*$'\n'}
        line=${line%$'\r'}
        [[ $line != *$'\r'* ]] || return 1
        record+=("$line")
    done
    [[ -z $bytes && ${record[0]} == cplx-package-progress-v1 &&
        ${record[1]} == architecture=?* && ${record[2]} == list=?* &&
        ${record[3]} == last=* ]] || return 1
    progress_record[architecture]=${record[1]#architecture=}
    progress_record[list]=${record[2]#list=}
    # Result is read through the caller's associative-array nameref.
    # shellcheck disable=SC2034
    progress_record[last]=${record[3]#last=}
}

package_progress_write() {
    local destination=$1 architecture=$2 list=$3 last=$4 candidate value
    for value in "$architecture" "$list" "$last"; do
        [[ $value != *$'\n'* && $value != *$'\r'* ]] || return 116
    done
    [[ -n $architecture && -n $list ]] || return 116
    candidate=$(mktemp "${destination%/*}/.cplx-progress-XXXXXXXX") || return 116
    if ! printf 'cplx-package-progress-v1\narchitecture=%s\nlist=%s\nlast=%s\n' \
        "$architecture" "$list" "$last" > "$candidate" ||
        ! mv -fT -- "$candidate" "$destination"; then
        rm -f -- "$candidate"
        return 116
    fi
}

package_progress_prepare() {
    local destination=$1 architecture=$2 list=$3 reset=$5 after=${6%$'\r'} repeat=$7
    local cursor='' entry found=0 index=0
    local -n active_entries=$4 progress_state=$8
    local -A stored=()
    progress_state=([start]=0 [reason]='' [resume]='')
    if [[ $reset == 1 ]]; then
        cursor=$after
        # Explicit operator intent is validated before any record is replaced.
        if [[ -n $cursor ]]; then
            for entry in "${active_entries[@]}"; do
                if [[ $entry == "$cursor" ]]; then found=1; break; fi
            done
            [[ $found == 1 ]] || return 117
        fi
        package_progress_write "$destination" "$architecture" "$list" "$cursor" || return $?
        repeat=''
    elif [[ -e $destination || -L $destination ]]; then
        if ! package_progress_read "$destination" stored; then
            progress_state[reason]='legacy or malformed progress'
        elif [[ ${stored[architecture]} != "$architecture" || ${stored[list]} != "$list" ]]; then
            progress_state[reason]='architecture or selected list changed'
        else
            cursor=${stored[last]}
            if [[ -n $cursor ]]; then
                for entry in "${active_entries[@]}"; do
                    if [[ $entry == "$cursor" ]]; then found=1; break; fi
                done
                if [[ $found == 0 ]]; then
                    progress_state[reason]='stored entry is no longer active'
                    cursor=''
                fi
            fi
        fi
        if [[ -n ${progress_state[reason]} ]]; then
            # Commit the discarded cursor before the first synchronization can run.
            package_progress_write "$destination" "$architecture" "$list" '' || return $?
        fi
    else
        # A first selection also has a durable empty cursor before package IO.
        package_progress_write "$destination" "$architecture" "$list" '' || return $?
    fi
    [[ -n $cursor ]] || return 0
    for entry in "${active_entries[@]}"; do
        index=$((index + 1))
        if [[ $entry == "$cursor" || ( -n $repeat && $entry == "$repeat" ) ]]; then
            progress_state[start]=$index
            progress_state[resume]=$entry
            break
        fi
    done
}
