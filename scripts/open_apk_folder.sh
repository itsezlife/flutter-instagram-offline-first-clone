#!/bin/bash

# Define the default APK folder path
APK_FOLDER="$HOME/Documents/VSCodeProjects/Flutter/Gainz/build/app/outputs/apk/release"

# Check if a custom path is provided as an argument
if [ -n "$1" ]; then
  APK_FOLDER="$1"
fi

# Check if the APK folder exists
if [ ! -d "$APK_FOLDER" ]; then
  echo "Error: APK folder '$APK_FOLDER' does not exist."
  exit 1
fi

# Open the APK folder using the default file manager
if command -v xdg-open &> /dev/null; then
  xdg-open "$APK_FOLDER"
elif command -v open &> /dev/null; then
  open "$APK_FOLDER"
else
  echo "Error: No suitable file manager found (xdg-open or open)."
  exit 1
fi

echo "Opening APK folder: $APK_FOLDER"