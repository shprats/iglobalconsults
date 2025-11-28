# Flutter Installation Guide for macOS

## Quick Install (Recommended)

### Using Homebrew

```bash
# 1. Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Flutter
brew install --cask flutter

# 3. Verify installation
flutter doctor
```

### Manual Installation

```bash
# 1. Download Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# 2. Add to PATH
# Edit ~/.zshrc (or ~/.bash_profile if using bash)
nano ~/.zshrc

# Add this line:
export PATH="$PATH:$HOME/flutter/bin"

# 3. Reload shell
source ~/.zshrc

# 4. Verify
flutter doctor
```

## Post-Installation Setup

### 1. Accept Android Licenses (if developing for Android)

```bash
flutter doctor --android-licenses
```

### 2. Install Xcode Command Line Tools (for iOS development)

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 3. Install CocoaPods (for iOS dependencies)

```bash
sudo gem install cocoapods
```

### 4. Run Flutter Doctor

```bash
flutter doctor -v
```

This will show you what's installed and what's missing. Fix any issues it reports.

## Verify Installation

```bash
# Check Flutter version
flutter --version

# Should show something like:
# Flutter 3.x.x • channel stable
```

## Test Installation

```bash
cd /Users/pratik/Documents/iglobalconsults/mobile

# Get dependencies
flutter pub get

# Run on iOS Simulator (if Xcode is installed)
flutter run

# Or run on Android Emulator (if Android Studio is installed)
flutter run
```

## Common Issues

### Issue: "command not found: flutter"
**Solution:** Make sure Flutter is in your PATH. Check with `echo $PATH` and add Flutter bin directory.

### Issue: "Xcode not found"
**Solution:** Install Xcode from App Store, then run:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Issue: "Android licenses not accepted"
**Solution:** Run `flutter doctor --android-licenses` and accept all licenses.

## Next Steps

1. ✅ Flutter installed
2. ✅ Run `flutter doctor` to verify
3. ✅ Install VS Code/Cursor extensions (see IDE_SETUP_GUIDE.md)
4. ✅ Open project in Cursor
5. 🚀 Start developing!

