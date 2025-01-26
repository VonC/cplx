BEGIN {
    # Initialize
    matched = 0
}

# Extract the "name" field
/"name":/ {
    # Extract the name value
    if (match($0, /"name":\s*"([^"]+)"/, arr)) {
        name = arr[1]
        
        # Reset matched flag
        matched = 0

        # Check for 'a' or 'b' in the name
        if (name ~ /a/ || name ~ /b/) {
            matched = 0
        }
        # Check for 'rc' in the name
        else if (name ~ /rc/) {
            if (rc == "true") {
                matched = 1
            }
        }
        # Name has no 'a', 'b', or 'rc'
        else {
            matched = 1
        }
    }
}

# Extract the "zipball_url" field
/"zipball_url":/ && matched {
    if (match($0, /"zipball_url":\s*"([^"]+)"/, arr)) {
        print arr[1]
        exit
    }
}

# End of file without finding a matching zipball_url
END {
    # No action needed
}