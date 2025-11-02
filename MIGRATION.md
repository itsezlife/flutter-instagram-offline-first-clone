# Migration Guide: Flutter SDK 3.35.7 Update

This guide provides step-by-step instructions for migrating from older versions of this Flutter Instagram clone to the latest version with Flutter SDK 3.35.7 (as of November 2, 2025).

## ⚠️ Important Notice

This is a **major breaking migration** that includes:

- Flutter SDK upgrade to 3.35.7 (latest)
- All dependencies updated to latest compatible versions
- Deprecated Flutter/Dart code resolved
- Updated `analysis_options.yaml`
- Breaking dependencies removed and bumped
- Latest Android `targetSdk`, `compileSdk`, and AGP versions
- Updated `build_runner`, `freezed`, and `json_annotation` versions

## 🚨 Recommended Approach

**If you have made custom changes to a forked version of this repository:**

It is **strongly recommended** to completely fork this new version and re-apply your changes manually, rather than trying to merge/pull the updates. The number of breaking changes is extensive and would be difficult to resolve individually.

## 📋 Prerequisites

Before starting the migration, ensure you have:

1. **FVM (Flutter Version Management)** - Recommended for managing Flutter SDK versions
2. **Flutter SDK 3.35.7** (will be installed via FVM)
3. **Dart SDK ≥3.9.0** (automatically configured with FVM)
4. **Android Studio** with latest Android SDK
5. **Xcode** (for iOS development)
6. **Git** for version control

## 🛠️ Migration Steps

### Step 1: Backup Your Current Project

```bash
# Create a backup of your current project
cp -r your_project_folder your_project_folder_backup
```

### Step 2: Clean Previous Build Artifacts

```bash
# Navigate to your project root
cd your_project_folder

# Clean Flutter
flutter clean

# Clean build artifacts
rm -rf build/
rm -rf .dart_tool/
rm pubspec.lock
```

### Step 3: Install and Configure FVM (Flutter Version Management)

**FVM is the recommended tool for managing Flutter SDK versions effectively.** It allows you to have distinct global and local Flutter SDK versions, making it perfect for managing multiple Flutter projects.

**Benefits of using FVM:**

- 🔄 Switch between Flutter versions per project
- 🛠️ Automatic Dart SDK configuration with `--setup`
- 📦 No conflicts between different Flutter projects
- 🚀 Easy version management and updates
- 💾 Efficient storage (shared Flutter installations)

#### Install FVM

Refer to the official [FVM documentation](https://fvm.app/) for installation instructions specific to your operating system.

#### Install Flutter SDK 3.35.7 with FVM

```bash
# Install Flutter 3.35.7 with automatic setup
# The --setup flag automatically configures Dart SDK and other configurations
fvm install 3.35.7 --setup
```

#### Configure Flutter SDK for This Project

```bash
# Navigate to your project root
cd your_project_folder

# Use Flutter 3.35.7 locally for this project
fvm use 3.35.7
```

#### Optional: Set Global Flutter Version

```bash
# Set Flutter 3.35.7 as global default (optional)
fvm global 3.35.7
```

#### Verify Installation

```bash
# List all installed Flutter SDK versions
fvm list

# Verify Flutter version for this project
fvm flutter --version
# Should show Flutter 3.35.7

# Or if you set it globally
flutter --version
```

### Step 4: Use Utility Scripts for Package Management

This project includes helpful utility scripts in the `scripts/` folder:

#### Available Scripts:

- `build_runner.sh` - Manages build_runner for code generation
- `get_all.sh` - Installs all dependencies across packages
- `build_and_open_apk.sh` - Builds and opens APK
- `setup_env.sh` - Sets up environment variables

### Step 5: Install Dependencies

```bash
# Use the utility script to get all dependencies
./scripts/get_all.sh

# If using FVM locally, you can also run:
# fvm flutter pub get (for root project)
```

This script will:

- Install root project dependencies
- Install all package dependencies recursively
- Show progress with spinners and status indicators

### Step 6: Clean and Rebuild Code Generation

**Critical:** Due to updated `build_runner`, `freezed`, and `json_annotation` versions, you must clean and rebuild generated code.

#### For Shared Package:

```bash
# Clean build_runner for shared package
./scripts/build_runner.sh shared clean

# Rebuild shared package
./scripts/build_runner.sh shared
```

#### For Insta Blocks Package:

```bash
# Clean build_runner for insta_blocks package
./scripts/build_runner.sh insta_blocks clean

# Rebuild insta_blocks package
./scripts/build_runner.sh insta_blocks
```

#### For Root Project:

```bash
# Clean root project build_runner
dart run build_runner clean

# Rebuild with conflict resolution
dart run build_runner build --delete-conflicting-outputs
```

### Step 7: Generate Localizations

```bash
# Generate localization files
flutter gen-l10n

# If using FVM locally:
# fvm flutter gen-l10n
```

### Step 8: iOS-Specific Steps (if targeting iOS)

```bash
# Navigate to iOS directory
cd ios

# Update CocoaPods
pod update

# Return to project root
cd ..
```

### Step 9: Verify Installation

```bash
# Check for any dependency issues
flutter doctor

# If using FVM locally:
# fvm flutter doctor

# Verify project can build
flutter build apk --debug

# If using FVM locally:
# fvm flutter build apk --debug
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Build Runner Conflicts

```bash
# If you encounter build_runner conflicts
dart run build_runner clean
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### 2. Dependency Version Conflicts

```bash
# Clear pub cache if needed
flutter pub cache clean
flutter pub get

# If using FVM locally:
# fvm flutter pub cache clean
# fvm flutter pub get
```

#### 3. Android Build Issues

- Ensure your `android/app/build.gradle` has updated `compileSdk` and `targetSdk`
- Check that Android Gradle Plugin (AGP) version is compatible
- Clean Android build: `cd android && ./gradlew clean`

#### 4. iOS Build Issues

```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### 5. FVM-Related Issues

```bash
# List all installed Flutter versions
fvm list

# Check which Flutter version is being used locally
fvm flutter --version

# Reinstall Flutter version if corrupted
fvm install 3.35.7 --setup --force

# Remove unused Flutter versions to save space
fvm remove <version>

# Check FVM configuration
fvm doctor
```

## 📱 Building the App

### Development Build

```bash
# Use the utility script
./scripts/build_and_open_apk.sh --flavor development
```

### Production Build

```bash
# Use the utility script
./scripts/build_and_open_apk.sh --flavor production
```

## 🔍 Key Changes in This Migration

### Dependencies Updated

- `build_runner: ^2.6.0`
- `freezed: ^3.2.3`
- `json_annotation: ^4.9.0`
- `json_serializable: ^6.11.1`
- `very_good_analysis: ^9.0.0`
- All Firebase dependencies to latest versions
- Updated UI and utility packages

### Flutter/Dart Changes

- Minimum Dart SDK: `>=3.9.0`
- Minimum Flutter: `>=3.35.7`
- Resolved deprecated API usage
- Updated analysis options

### Android Changes

- Updated `targetSdk` and `compileSdk`
- Latest Android Gradle Plugin (AGP)
- Updated Android dependencies

## 📞 Support

If you encounter issues during migration:

1. Check the troubleshooting section above
2. Ensure all prerequisites are met
3. Verify Flutter and Dart versions
4. Consider the recommended approach of forking the new version

## ✅ Post-Migration Checklist

- [ ] FVM installed and configured
- [ ] Flutter SDK 3.35.7 installed via FVM with `--setup`
- [ ] Local Flutter version set to 3.35.7 for this project (`fvm use 3.35.7`)
- [ ] All dependencies installed successfully
- [ ] Code generation completed without errors
- [ ] Localizations generated
- [ ] iOS pods updated (if applicable)
- [ ] App builds successfully
- [ ] All features working as expected
- [ ] FVM commands working correctly (`fvm list`, `fvm flutter --version`)

---

**Note:** This migration represents a significant update. Take time to test all functionality after migration to ensure everything works correctly with the new versions.
