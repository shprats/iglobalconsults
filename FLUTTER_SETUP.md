# Flutter Installation Guide for macOS

## Prerequisites

- macOS (you're on macOS, so ✅)
- Xcode (for iOS development)
- Git (usually pre-installed)

## Installation Methods

### Method 1: Using Flutter SDK (Recommended)

1. **Download Flutter SDK:**
   ```bash
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. **Add Flutter to PATH:**
   
   Edit your shell profile (`.zshrc` for zsh or `.bash_profile` for bash):
   ```bash
   # For zsh (default on macOS)
   nano ~/.zshrc
   
   # Add this line:
   export PATH="$PATH:$HOME/development/flutter/bin"
   
   # Save and reload
   source ~/.zshrc
   ```

3. **Verify Installation:**
   ```bash
   flutter --version
   ```

4. **Run Flutter Doctor:**
   ```bash
   flutter doctor
   ```
   
   This will check your setup and tell you what's missing.

### Method 2: Using Homebrew (Easier)

```bash
# Install Flutter
brew install --cask flutter

# Verify
flutter --version
flutter doctor
```

### Method 3: Using FVM (Flutter Version Management) - Advanced

If you need to manage multiple Flutter versions:

```bash
# Install FVM
dart pub global activate fvm

# Install Flutter via FVM
fvm install stable
fvm use stable

# Add to PATH
export PATH="$PATH:$HOME/fvm/default/bin"
```

## Post-Installation Setup

### 1. Install Xcode (Required for iOS)

1. Install Xcode from App Store (large download, ~12GB)
2. Open Xcode and accept license:
   ```bash
   sudo xcodebuild -license accept
   ```
3. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

### 2. Install CocoaPods (for iOS dependencies)

```bash
sudo gem install cocoapods
```

### 3. Install Android Studio (for Android development)

1. Download from https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio → Configure → SDK Manager
4. Install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device

### 4. Accept Android Licenses

```bash
flutter doctor --android-licenses
```

## Verify Installation

Run Flutter Doctor to check everything:

```bash
flutter doctor -v
```

You should see:
- ✅ Flutter (channel stable)
- ✅ Android toolchain (if Android Studio installed)
- ✅ Xcode (if Xcode installed)
- ✅ Chrome (for web development)
- ✅ VS Code (if installed)

## Common Issues & Fixes

### Issue: "Flutter command not found"
**Fix:** Make sure Flutter is in your PATH. Check with:
```bash
echo $PATH
```

### Issue: "Xcode not found"
**Fix:** Install Xcode from App Store and run:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Issue: "CocoaPods not installed"
**Fix:** 
```bash
sudo gem install cocoapods
```

### Issue: "Android licenses not accepted"
**Fix:**
```bash
flutter doctor --android-licenses
# Press 'y' to accept all licenses
```

## Setup for This Project

Once Flutter is installed:

1. **Navigate to mobile directory:**
   ```bash
   cd /Users/pratik/Documents/iglobalconsults/mobile
   ```

2. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Check if project is valid:**
   ```bash
   flutter doctor
   flutter analyze
   ```

4. **Run the app (iOS Simulator):**
   ```bash
   flutter run
   ```

## Quick Test

Create a simple test to verify Flutter works:

```bash
cd ~
flutter create test_app
cd test_app
flutter run
```

If this works, Flutter is properly installed! 🎉

## Next Steps

1. ✅ Flutter installed
2. ✅ VS Code set up with extensions
3. Open project in VS Code: `code /Users/pratik/Documents/iglobalconsults`
4. Start developing!

