#!/bin/bash

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
    printf "\r\e[K"
}

# Command runner
run_with_spinner() {
    local msg=$1
    local cmd=$2
    
    if [ "$CI" = "true" ]; then
        printf "%s..." "$msg"
        if eval "$cmd" > /dev/null 2>&1; then
            printf "\r%s%s %s\n" "$CHECK" "$GREEN" "$msg"
        else
            printf "\r%s%s %s\n" "$CROSS" "$RED" "$msg"
            return 1
        fi
    else
        eval "$cmd" > /dev/null 2>&1 &
        spinner "$msg"
        if wait $!; then
            printf "\r%s%s %s\n" "$CHECK" "$GREEN" "$msg"
        else
            printf "\r%s%s %s\n" "$CROSS" "$RED" "$msg"
        fi
    fi
}

check_secrets() {
    local missing=()
    
    # Check required secrets
    [ -z "$SUPABASE_URL" ] && missing+=("SUPABASE_URL")
    [ -z "$SUPABASE_ANON_KEY" ] && missing+=("SUPABASE_ANON_KEY")
    [ -z "$POWERSYNC_URL" ] && missing+=("POWERSYNC_URL")
    [ -z "$GOOGLE_MAPS_API_KEY" ] && missing+=("GOOGLE_MAPS_API_KEY")

    if [ ${#missing[@]} -ne 0 ]; then
        printf "\n%s%sERROR:%s Missing required environment variables:\n" "${BOLD}" "${RED}" "${RESET}"
        for var in "${missing[@]}"; do
            printf "  - %s\n" "$var"
        done
        exit 1
    fi
}

setup_environment() {
    check_secrets  # Validate before proceeding

    local env_dir="${GITHUB_WORKSPACE}/packages/env"
    run_with_spinner "Configuring environment variables" "
        cd '${env_dir}' && \
        echo \"SUPABASE_URL=$SUPABASE_URL\" >> .env.dev && \
        echo \"SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY\" >> .env.dev && \
        echo \"POWERSYNC_URL=$POWERSYNC_URL\" >> .env.dev && \
        echo \"GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY\" >> .env.dev && \
        echo \"SUPABASE_URL=$SUPABASE_URL\" >> .env.prod && \
        echo \"SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY\" >> .env.prod && \
        echo \"POWERSYNC_URL=$POWERSYNC_URL\" >> .env.prod && \
        echo \"GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY\" >> .env.prod && \
        flutter pub get && \
        dart run build_runner clean && \
        dart run build_runner build --delete-conflicting-outputs
    "
}

# Main execution
printf "\n%s%s🚀 Environment Setup...%s\n\n" "${BOLD}" "${GREEN}" "${RESET}"
setup_environment
printf "\n%s%s✅ Environment setup complete!%s\n\n" "${BOLD}" "${GREEN}" "${RESET}" 