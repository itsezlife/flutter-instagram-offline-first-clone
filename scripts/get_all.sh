#!/bin/bash

# Determine root directory
ROOT_DIR=${GITHUB_WORKSPACE:-$(pwd)}
cd "$ROOT_DIR" || exit 1

# Colors and styles
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)
CHECK="✓"
CROSS="✗"
SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r%s%s %s${RESET}" "${SPINNER[$i]}" "$BLUE" "$1"
        sleep $delay
    done
    printf "\r\e[K" # Clear line
}

# Run command with spinner
run_with_spinner() {
    local msg=$1
    local cmd=$2
    
    if [ "$CI" = "true" ]; then
        # CI mode - show errors on failure
        printf "%s..." "$msg"
        if output=$(eval "$cmd" 2>&1); then
            printf "\r%s%s %s\n" "$CHECK" "$GREEN" "$msg"
        else
            printf "\r%s%s %s\n" "$CROSS" "$RED" "$msg"
            echo "$output" | sed 's/^/    /'  # Indent error output
            return 1
        fi
    else
        # Interactive mode - full spinner
        eval "$cmd" > /dev/null 2>&1 &
        spinner "$msg"
        if wait $!; then
            printf "\r%s%s %s\n" "$CHECK" "$GREEN" "$msg"
        else
            printf "\r%s%s %s\n" "$CROSS" "$RED" "$msg"
        fi
    fi
}

# Main execution
printf "\n%s%s🚀 Installing dependencies...%s\n\n" "${BOLD}" "${GREEN}" "${RESET}"

# Root project
run_with_spinner "Root project" "flutter pub get"

# Root project dart pub get
run_with_spinner "Root project dart pub get" "dart pub get"

# Packages
PACKAGE_DIR="$ROOT_DIR/packages"
if [ -d "$PACKAGE_DIR" ]; then
    while IFS= read -r -d '' dir; do
        if [ -f "${dir}/pubspec.yaml" ]; then
            # Extract package name with path relative to packages directory
            package_path="${dir#$PACKAGE_DIR/}"
            package_path="${package_path//$ROOT_DIR\//}"  # Remove root dir if present
            run_with_spinner "Package: ${BOLD}${package_path}" "cd \"$dir\" && flutter pub get"
        fi
    done < <(find "$PACKAGE_DIR" -type d -print0)
fi

printf "\n%s%s✅ All dependencies installed!%s\n\n" "${BOLD}" "${GREEN}" "${RESET}"