#!/bin/bash

# Default APK folder base path
APK_BASE="$HOME/Documents/VSCodeProjects/Flutter/Gainz/build/app/outputs"

# Default flavor
FLAVOR="development"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --flavor)
      FLAVOR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--flavor <flavor_name>]"
      exit 1
      ;;
  esac
done

# Set APK folder based on flavor
if [ "$FLAVOR" = "production" ]; then
  APK_FOLDER="$APK_BASE/apk/production/release"
else
  APK_FOLDER="$APK_BASE/apk/development/release"
fi

# Flutter project directory (assuming the script is run from the project root)
FLUTTER_PROJECT_DIR="$PWD"

# Trap the SIGINT signal (Ctrl+C)
trap "echo 'Build cancelled.'; exit 1" INT

# Build the Flutter release APK
echo "Building Flutter release APK with flavor: $FLAVOR..."
flutter build apk --release --flavor "$FLAVOR" -t lib/main_${FLAVOR}.dart --obfuscate --target-platform android-arm64 --obfuscate --split-debug-info=build/debug-info

# Check if the build was successful (not really needed now, trap handles cancellation)
# if [ $? -ne 0 ]; then
#   echo "Error: Flutter build failed."
#   exit 1
# fi

# Check if the APK folder exists
if [ ! -d "$APK_FOLDER" ]; then
  echo "Error: APK folder '$APK_FOLDER' does not exist."
  exit 1
fi

# Open the APK folder
echo "Opening APK folder: $APK_FOLDER"
if command -v xdg-open &> /dev/null; then
  xdg-open "$APK_FOLDER"
elif command -v open &> /dev/null; then
  open "$APK_FOLDER"
else
  echo "Error: No suitable file manager found (xdg-open or open)."
  exit 1
fi

# Add after the build command
echo "Checking for native debug symbols..."
find ./build -name "*-native-debug-symbols.zip" -exec ls -lh {} \;

echo "Checking split debug info..."
ls -lh ./debug-symbols

echo "Done!"