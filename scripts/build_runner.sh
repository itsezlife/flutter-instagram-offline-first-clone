#!/bin/bash

# Save current directory
CURRENT_DIR=$(pwd)

# If path is provided, use packages/path, otherwise use current directory
if [ -n "$1" ]; then
    DIR_PATH="$CURRENT_DIR/packages/$1"
else
    DIR_PATH="$CURRENT_DIR"
fi

# Check if the directory exists
if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory '$DIR_PATH' does not exist"
    exit 1
fi

# Change to the target directory
cd "$DIR_PATH"

# Handle clean option
if [ "$2" = "clean" ]; then
    echo "Running build_runner clean in $(pwd)"
    dart run build_runner clean
    cd "$CURRENT_DIR"
    exit 0
fi

# Run the build runner command
if [ "$2" = "watch" ]; then
    echo "Running build_runner watch in $(pwd)"
    dart run build_runner watch --delete-conflicting-outputs
else
    echo "Running build_runner build in $(pwd)"
    dart run build_runner build --delete-conflicting-outputs
fi

# Return to original directory
cd "$CURRENT_DIR"