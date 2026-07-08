# Package list URLs

<img src="../../../wiki/assets/logo-cplx-download-transparent.png" alt="" height="90" align="right">

VonC: I need for download_packages_list to be able to parse the "${arch/\./_}_pkgs_url" for "," as URL separator. In other words, its value is no longer just one URL, but possibly one or more than one. Refactor the method to empty the target file '{SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt', and to apply the already implemented filtering, appending the result on '{SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt'. Define a method for one URL and keep download_packages_list to iterate over the possible URLs

GitHub Copilot: # URL Parsing Refactoring for Package Download

I'll refactor the `download_packages_list` function to handle multiple URLs separated by commas, by extracting the URL processing logic into a separate function and iterating through all URLs.

Here's the implementation:

````bash
// ...existing code...

download_packages_list() {
    if step_is_done "download_packages_list"; then
        ok "download_packages_list is already done"
        return 0
    fi
    local arch="$1"
    local packages_file="${SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt"
    
    if [[ -f "${packages_file}" ]]; then
        if [[ -z "${CPLX_RELOAD_PACKAGES}" ]]; then
            ok "File '${packages_file}' already downloaded"
            return 0
        fi
        task "Must refresh/reload File '${packages_file}' (CPLX_RELOAD_PACKAGES env var set)"
    fi

    # Empty the target file at the beginning
    > "${packages_file}"

    # Get the comma-separated URLs from property
    pkgs_url_name="${arch/\./_}_pkgs_url"
    get_property "${pkgs_url_name}"
    url_list=${!pkgs_url_name}
    info "URL list for arch='${arch}': ${url_list}"

    # Split by comma and process each URL
    IFS=',' read -ra urls <<< "$url_list"
    for url in "${urls[@]}"; do
        # Trim whitespace
        url=$(echo "$url" | xargs)
        info "Processing URL: '${url}' for arch='${arch}'"
        process_packages_url "$url" "$arch" "$packages_file"
    done

    if ! step_done "download_packages_list"; then
        fatal "Could not mark download_packages_list as done" 6
    fi
    ok "All URLs processed and filtered packages saved to '${packages_file}'"
}

process_packages_url() {
    local url="$1"
    local arch="$2"
    local packages_file="$3"
    local temp_file="${SETUP_PKGS_DIR}/pkgs/urls_temp.txt"

    # Fetch the HTML content using curl
    html_content=$(curl -kLs "$url")

    # Count the number of lines in html_content
    line_count=$(echo "$html_content" | wc -l)
    info "HTML content line count: ${line_count} for '${url}'"

    if [ "$line_count" -lt 50 ]; then
        warning "HTML content has only ${line_count} lines (<50), skipping URL: ${url}"
        return 0
    fi

    # Extract URLs from the table rows using grep
    # Define an array of grep pipelines (as strings) to extract URLs
    grep_pipelines=(
        'grep -oP '"'"'<tr class="(even|odd)">.*?<a href="\K[^"]+'"'"' | grep -v "^\.\./$" | grep "x86_64"' # https://vault.centos.org/8-stream/BaseOS/x86_64/os/Packages/
        'grep -oP '"'"'<a href="\K[^"]*x86_64[^"]*'"'"' | grep -v "^../$"' # https://dl.rockylinux.org/vault/centos/7.9.2009/updates/x86_64/Packages/
        'grep -oP '"'"'<a href="\K[^"]+'"'"' | grep "x86_64"' # https://mirror.chpc.utah.edu/pub/centos/7/os/x86_64/Packages/
    )
    # Print the size of the grep_pipelines array
    info "grep_pipelines array size: ${#grep_pipelines[@]}"
    output=""
    for pipeline in "${grep_pipelines[@]}"; do
        # Use eval to run the pipeline on html_content
        output=$(echo "$html_content" | eval "$pipeline")
        # shellcheck disable=SC2181
        if [ $? -eq 0 ] && [ -n "$output" ]; then
            info "Pipeline '${pipeline}' has succeeded"
            echo "$output" > "$temp_file"
            break
        fi
    done
    if [ -z "$output" ]; then
        warning "Failed to extract URLs from the HTML content for URL: ${url}"
        return 0
    fi

    # Process the URLs to keep only the last entry for each common prefix
    # and append to the packages file
    awk -F'-[0-9]' '{
        if ($0 !~ /^\//) {  # Ignore entries starting with /
            prefix = $1;        # Extract the common prefix (everything before -[0-9])
            map[prefix] = $0;   # Store the latest entry for each prefix
        }
    }
    END {
        # Sort the prefixes alphabetically
        n = asorti(map, sorted_prefixes);
        for (i = 1; i <= n; i++) {
            print map[sorted_prefixes[i]]; # Print the latest entry for each prefix
        }
    }' "$temp_file" >> "$packages_file"
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        warning "Failed to process the URLs for URL: ${url}"
        return 0
    fi

    ok "Processed URLs from '${url}' and appended to '${packages_file}'"
}

// ...existing code...
````

## Explanation of Changes

1. **Refactored `download_packages_list`**:
   - Now empties the target file at the beginning
   - Parses the comma-separated URL list
   - Iterates through each URL and calls `process_packages_url`
   - Handles step completion after all URLs are processed

2. **Created new `process_packages_url` function**:
   - Takes a URL, architecture, and output file as parameters
   - Contains the HTML fetching and parsing logic from the original function
   - Appends results to the packages file instead of overwriting
   - Uses warnings instead of fatal errors for individual URL failures, allowing the process to continue with other URLs

3. **Error Handling Improvements**:
   - If one URL fails, the process continues with the next URL
   - Only reports warnings for individual URL failures, not fatal errors

This refactoring maintains the existing functionality while adding support for multiple source URLs.

VonC: `>"${packages_file}"` says:  This redirection doesn't have a command. Move to its command (or use 'true' as no-op).

`local urls="${!pkgs_url_name}"` says: Variable was used as an array but is now assigned a string., and

`read -ra url_list <<<"$urls"` says: Expanding an array without an index only gives the first element.

GitHub Copilot: # Fixing Shell Syntax Issues in setup_packages.sh

I'll address the three syntax issues mentioned in your prompt:

````bash
// ...existing code...

download_packages_list() {
    if step_is_done "download_packages_list"; then
        ok "download_packages_list is already done"
        return 0
    fi
    local arch="$1"
    local packages_file="${SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt"
    
    if [[ -f "${packages_file}" ]]; then
        if [[ -z "${CPLX_RELOAD_PACKAGES}" ]]; then
            ok "File '${packages_file}' already downloaded"
            return 0
        fi
        task "Must refresh/reload File '${packages_file}' (CPLX_RELOAD_PACKAGES env var set)"
    fi

    # Empty the target file at the beginning - using true command with redirection
    true > "${packages_file}"

    # Get the comma-separated URLs from property
    pkgs_url_name="${arch/\./_}_pkgs_url"
    get_property "${pkgs_url_name}"
    local url_value="${!pkgs_url_name}"
    info "URL list for arch='${arch}': ${url_value}"

    # Split by comma and process each URL
    IFS=',' read -ra url_list <<<"$url_value"
    for url in "${url_list[@]}"; do
        # Trim whitespace
        url=$(echo "$url" | xargs)
        info "Processing URL: '${url}' for arch='${arch}'"
        process_packages_url "$url" "$arch" "$packages_file"
    done

    if ! step_done "download_packages_list"; then
        fatal "Could not mark download_packages_list as done" 6
    fi
    ok "All URLs processed and filtered packages saved to '${packages_file}'"
}

// ...existing code...

download_package() {
    local arch="$1"
    local pkg_name="$2"

    local package_file_name="${SETUP_PKGS_DIR}/pkgs/${arch}/${pkg_name}"
    local package_file_size
    package_file_size=$(stat -c%s "${package_file_name}" 2>/dev/null || echo 0)
    local min_pkg_size=9
    local package_file_size_limit=$((min_pkg_size * 1024)) # 9KB

    # Check if package already exists and is valid
    if [[ -e "${package_file_name}" ]]; then
        if [[ "${package_file_size}" -lt "${package_file_size_limit}" ]]; then
            mv "${package_file_name}" "${package_file_name}._to_delete"
            echo "File renamed to ${package_file_name}._to_delete because its size is ${package_file_size} bytes."
            fatal "Package '${package_file_name}' is only ${package_file_size} bytes (<${min_pkg_size}KB), something went wrong" 4
        fi
        ok "Package '${pkg_name}' already downloaded in '${SETUP_PKGS_DIR}/pkgs/${arch}'"
        return 0
    fi

    # Get URLs from property
    local pkgs_url_name="${arch/\./_}_pkgs_url"
    get_property "${pkgs_url_name}"
    if [[ "${!pkgs_url_name}" == "" ]]; then
        fatal "Property '${pkgs_url_name}' not found in file '${properties_file}'" 7
    fi

    # Split comma-separated URLs and try each one
    local url_value="${!pkgs_url_name}"
    local IFS=','
    read -ra url_list <<<"$url_value"
    local last_url_index=$((${#url_list[@]} - 1))

    for i in "${!url_list[@]}"; do
        local url="${url_list[$i]}/${pkg_name}"
        url="${url//\/\//\/}" # Replace double slashes with single slash

        # Replace [l] with the first letter of pkg_name in lowercase
        if [[ "$url" == *"[l]"* ]]; then
            local first_letter="${pkg_name:0:1}"
            first_letter="${first_letter,,}" # Convert to lowercase
            url="${url//\[l\]/$first_letter}"
        fi

        # Check if this is the last URL to try
        if [[ $i -eq $last_url_index ]]; then
            # Last URL - fatal on failure
            try_download_package "${arch}" "${pkg_name}" "${url}" 1
            return 0 # This will only be reached if the download succeeds
        else
            # Not the last URL - just error on failure and try the next URL
            if try_download_package "${arch}" "${pkg_name}" "${url}" 0; then
                return 0 # Download succeeded, exit the loop
            fi
            # If we reach here, the download failed but we'll try the next URL
            warning "Failed with URL ${i+1}/${#url_list[@]}, trying next mirror..."
        fi
    done

    # This should never be reached as the last URL will either succeed or fatal
    fatal "No URLs worked for downloading package '${pkg_name}'" 3
}
````

## Changes Made

1. **Fixed empty redirection issue**:
   - Changed `>"${packages_file}"` to `true > "${packages_file}"`
   - This explicitly uses the `true` command with redirection instead of a standalone redirection

2. **Fixed variable naming for clarity**:
   - Changed `url_list=${!pkgs_url_name}` to `local url_value="${!pkgs_url_name}"`
   - This clarifies that we're dealing with a string value, not an array

3. **Fixed array access**:
   - Updated `read -ra url_list <<<"$url_list"` to `read -ra url_list <<<"$url_value"`
   - Used `"${url_list[@]}"` when iterating to properly access all array elements
   - Made the same changes in both `download_packages_list` and `download_package` functions

These changes maintain the existing functionality while fixing the shell syntax issues and improving code clarity.

VonC: Make sure the end result, once all urls are processed, is in alphabetical order, without duplication

GitHub Copilot: # Ensuring Alphabetical Sorting and Deduplication for Packages

I'll modify the `download_packages_list` and `process_packages_url` functions to ensure that the final package list is both alphabetically sorted and deduplicated across all URLs.

````bash
download_packages_list() {
    if step_is_done "download_packages_list"; then
        ok "download_packages_list is already done"
        return 0
    fi
    local arch="$1"
    local packages_file="${SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt"
    local temp_dir="${SETUP_PKGS_DIR}/pkgs/temp_${arch}"
    
    if [[ -f "${packages_file}" ]]; then
        if [[ -z "${CPLX_RELOAD_PACKAGES}" ]]; then
            ok "File '${packages_file}' already downloaded"
            return 0
        fi
        task "Must refresh/reload File '${packages_file}' (CPLX_RELOAD_PACKAGES env var set)"
    fi

    # Create temp directory for URL results
    rm -rf "${temp_dir}" 2>/dev/null
    mkdir -p "${temp_dir}"
    
    # Get the comma-separated URLs from property
    pkgs_url_name="${arch/\./_}_pkgs_url"
    get_property "${pkgs_url_name}"
    local url_value="${!pkgs_url_name}"
    info "URL list for arch='${arch}': ${url_value}"

    # Split by comma and process each URL
    IFS=',' read -ra url_list <<<"$url_value"
    for i in "${!url_list[@]}"; do
        # Trim whitespace
        url=$(echo "${url_list[$i]}" | xargs)
        info "Processing URL ${i+1}/${#url_list[@]}: '${url}' for arch='${arch}'"
        process_packages_url "$url" "$arch" "${temp_dir}/url_${i}.txt"
    done

    # Combine all URL results, remove duplicates, and sort alphabetically
    info "Combining results from all URLs, removing duplicates, and sorting"
    > "${packages_file}"  # Empty the target file
    
    if [ -n "$(ls -A "${temp_dir}" 2>/dev/null)" ]; then
        # Use awk to process all files, keeping only the latest version of each package
        cat "${temp_dir}"/*.txt 2>/dev/null | awk -F'-[0-9]' '{
            if ($0 !~ /^\//) {  # Ignore entries starting with /
                prefix = $1;     # Extract the common prefix (everything before -[0-9])
                map[prefix] = $0;  # Store the latest entry for each prefix
            }
        }
        END {
            # Sort the prefixes alphabetically
            n = asorti(map, sorted_prefixes);
            for (i = 1; i <= n; i++) {
                print map[sorted_prefixes[i]];  # Print the latest entry for each prefix
            }
        }' > "${packages_file}"
        
        # Count the number of packages
        local pkg_count=$(wc -l < "${packages_file}")
        ok "Final package list contains ${pkg_count} unique packages"
    else
        warning "No packages were found from any of the URLs"
    fi
    
    # Clean up temp directory
    rm -rf "${temp_dir}"

    if ! step_done "download_packages_list"; then
        fatal "Could not mark download_packages_list as done" 6
    fi
    ok "All URLs processed and filtered packages saved to '${packages_file}'"
}

process_packages_url() {
    local url="$1"
    local arch="$2"
    local output_file="$3"
    local temp_file="${SETUP_PKGS_DIR}/pkgs/url_temp.txt"

    # Fetch the HTML content using curl
    html_content=$(curl -kLs "$url")

    # Count the number of lines in html_content
    line_count=$(echo "$html_content" | wc -l)
    info "HTML content line count: ${line_count} for '${url}'"

    if [ "$line_count" -lt 50 ]; then
        warning "HTML content has only ${line_count} lines (<50), skipping URL: ${url}"
        return 0
    fi

    # Extract URLs from the table rows using grep
    # Define an array of grep pipelines (as strings) to extract URLs
    grep_pipelines=(
        'grep -oP '"'"'<tr class="(even|odd)">.*?<a href="\K[^"]+'"'"' | grep -v "^\.\./$" | grep "x86_64"' # https://vault.centos.org/8-stream/BaseOS/x86_64/os/Packages/
        'grep -oP '"'"'<a href="\K[^"]*x86_64[^"]*'"'"' | grep -v "^../$"'                                  # https://dl.rockylinux.org/vault/centos/7.9.2009/updates/x86_64/Packages/
        'grep -oP '"'"'<a href="\K[^"]+'"'"' | grep "x86_64"'                                               # https://mirror.chpc.utah.edu/pub/centos/7/os/x86_64/Packages/
    )
    # Print the size of the grep_pipelines array
    info "grep_pipelines array size: ${#grep_pipelines[@]}"
    output=""
    for pipeline in "${grep_pipelines[@]}"; do
        # Use eval to run the pipeline on html_content
        output=$(echo "$html_content" | eval "$pipeline")
        # shellcheck disable=SC2181
        if [ $? -eq 0 ] && [ -n "$output" ]; then
            info "Pipeline '${pipeline}' has succeeded"
            echo "$output" >"$temp_file"
            break
        fi
    done
    if [ -z "$output" ]; then
        warning "Failed to extract URLs from the HTML content for URL: ${url}"
        return 0
    fi

    # Process the URLs to keep only the last entry for each common prefix
    # but only for this specific URL
    awk -F'-[0-9]' '{
        if ($0 !~ /^\//) {  # Ignore entries starting with /
            prefix = $1;        # Extract the common prefix (everything before -[0-9])
            map[prefix] = $0;   # Store the latest entry for each prefix
        }
    }
    END {
        # Sort the prefixes alphabetically
        n = asorti(map, sorted_prefixes);
        for (i = 1; i <= n; i++) {
            print map[sorted_prefixes[i]]; # Print the latest entry for each prefix
        }
    }' "$temp_file" > "$output_file"
    
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        warning "Failed to process the URLs for URL: ${url}"
        return 0
    fi

    local pkg_count=$(wc -l < "$output_file")
    ok "Processed URLs from '${url}' and found ${pkg_count} packages"
}
````

## What's Changed

1. **Created a New Approach for Combining Results**:
   - Added a temporary directory to store results from each URL separately
   - Each URL's packages are processed and saved to a unique file in this directory

2. **Implemented Final Deduplication and Sorting**:
   - After all URLs are processed, combine all temporary files
   - Use awk to remove duplicates across all URLs, keeping only the latest version of each package
   - Sort the final list alphabetically before writing to the packages file

3. **Added More Informative Output**:
   - Added package counts for each URL and the final combined list
   - Improved progress indicators showing which URL is being processed (x/total)

4. **Improved Cleanup**:
   - Added cleanup of temporary files and directories
   - Used proper error handling for cases where no packages are found

This implementation ensures that even if multiple URLs contain the same package with different versions, the final list will contain only the latest version of each package in alphabetical order.

VonC: Make sure that if process_packages_url has any issue, it fatal. Any warning should be a fatal exit, using the fatal function, with a unique exit code.

GitHub Copilot: # Converting Warnings to Fatal Errors in process_packages_url

I'll modify the `process_packages_url` function to handle errors as fatal instead of warnings, with unique exit codes for each error case.

````bash
process_packages_url() {
    local url="$1"
    local arch="$2"
    local packages_file="$3"
    local temp_file="${SETUP_PKGS_DIR}/pkgs/urls_temp.txt"

    # Fetch the HTML content using curl
    html_content=$(curl -kLs "$url")

    # Count the number of lines in html_content
    line_count=$(echo "$html_content" | wc -l)
    info "HTML content line count: ${line_count} for '${url}'"

    if [ "$line_count" -lt 50 ]; then
        fatal "HTML content has only ${line_count} lines (<50) for URL: ${url}" 401
    fi

    # Extract URLs from the table rows using grep
    # Define an array of grep pipelines (as strings) to extract URLs
    grep_pipelines=(
        'grep -oP '"'"'<tr class="(even|odd)">.*?<a href="\K[^"]+'"'"' | grep -v "^\.\./$" | grep "x86_64"' # https://vault.centos.org/8-stream/BaseOS/x86_64/os/Packages/
        'grep -oP '"'"'<a href="\K[^"]*x86_64[^"]*'"'"' | grep -v "^../$"'                                  # https://dl.rockylinux.org/vault/centos/7.9.2009/updates/x86_64/Packages/
        'grep -oP '"'"'<a href="\K[^"]+'"'"' | grep "x86_64"'                                               # https://mirror.chpc.utah.edu/pub/centos/7/os/x86_64/Packages/
    )
    # Print the size of the grep_pipelines array
    info "grep_pipelines array size: ${#grep_pipelines[@]}"
    output=""
    for pipeline in "${grep_pipelines[@]}"; do
        # Use eval to run the pipeline on html_content
        output=$(echo "$html_content" | eval "$pipeline")
        # shellcheck disable=SC2181
        if [ $? -eq 0 ] && [ -n "$output" ]; then
            info "Pipeline '${pipeline}' has succeeded"
            echo "$output" >"$temp_file"
            break
        fi
    done
    if [ -z "$output" ]; then
        fatal "Failed to extract URLs from the HTML content for URL: ${url}" 402
    fi

    # Process the URLs to keep only the last entry for each common prefix
    # and append to the packages file
    awk -F'-[0-9]' '{
        if ($0 !~ /^\//) {  # Ignore entries starting with /
            prefix = $1;        # Extract the common prefix (everything before -[0-9])
            map[prefix] = $0;   # Store the latest entry for each prefix
        }
    }
    END {
        # Sort the prefixes alphabetically
        n = asorti(map, sorted_prefixes);
        for (i = 1; i <= n; i++) {
            print map[sorted_prefixes[i]]; # Print the latest entry for each prefix
        }
    }' "$temp_file" >>"$packages_file"
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        fatal "Failed to process the URLs for URL: ${url}" 403
    fi

    ok "Processed URLs from '${url}' and appended to '${packages_file}'"
}
````

## Changes Made for Fatal Error Handling

I've replaced all `warning` statements with `fatal` calls and added unique exit codes:

1. **HTML Content Check** (Exit Code 401):
   - If the HTML content has fewer than 50 lines, now exits with a fatal error
   - This ensures we don't proceed with potentially incomplete data

2. **URL Extraction Check** (Exit Code 402):
   - If no URLs could be extracted from any of the grep pipelines, now exits with a fatal error
   - This catches cases where the HTML format might have changed or the URL is invalid

3. **AWK Processing Check** (Exit Code 403):
   - If the AWK command to process and sort the package entries fails, now exits with a fatal error
   - This ensures the package list is properly formatted and sorted

These changes ensure that any issue during package URL processing is treated as a critical error, stopping the script and requiring user intervention rather than silently continuing.
