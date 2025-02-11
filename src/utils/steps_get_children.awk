BEGIN {
    found_target = 0
}
{
    # print target " " found_target " for line '" $0 "'"
    # When we have not yet found the target step.
    if (!found_target) {
        # Look for the target anchor in the line, e.g. [🔗](#xxx)
        if ($0 ~ "\\[.\\]\\(#" target "\\)") {
            # Get the header level by matching the leading '#' characters.
            if (match($0, /^\s*(#+)/, m)) {
                base_level = length(m[1])
            } else {
                base_level = 0
            }
            found_target = 1
        }
    }
    else {
        # Process lines after the target is found.
        if (match($0, /^\s*(#+)/, r)) {
            current_level = length(r[1])
            if (current_level <= base_level) {
                exit 0
            }
            # For lines with a level greater than the target, try to extract the anchor.
            if (match($0, /\[🔗\]\(#([^)]+)\)/, arr)) {
                print arr[1]
            }
        }
    }
}