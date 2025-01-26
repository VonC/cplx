BEGIN {
    parent = ""
    parent_and_name_matched = 0
}

{

    # A level 2 header has no parent
    if (level == 2) {
        parent_and_name_matched = 1
        exit 0
    }

    # Check if the line contains the target name with a #
    if ($0 ~ "#" name) {
        if (parent != "") {
            parent_and_name_matched = 1
            print parent
        }
        exit 0
    }

    # Match lines starting with at least two # and fewer than 'level' #
    match($0, /^(#{2,})\s+.+?🔗\]\(#([^\)]+)/, arr)
    if (RSTART && RLENGTH) {
        line_level = length(arr[1])
        #print "'" arr[1] "' (length=" line_level "), and '" arr[2] "', for " $0
        if (line_level < level) {
            parent = arr[2]
            #print "=> possible parent: '" parent "'"
        }
    }
}

END {
    # Do nothing if name not found
    if (parent_and_name_matched == 1) {
        #print "parent is '" parent "'"
        exit 0
    }
    exit 1
}