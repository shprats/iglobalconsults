# Android Setup for Flutter on macOS

## Is This Error Critical?

**No!** This error only means you can't develop for Android devices. You can still:
- ✅ Develop for iOS (iPhone/iPad)
- ✅ Develop for macOS
- ✅ Develop for Web
- ✅ Run Flutter commands

If you only need iOS development (which is the priority for this project), you can **skip Android setup** for now.

## If You Want Android Support

### Option 1: Install Android Studio (Recommended)

1. **Download Android Studio:**
   - Go to https://developer.android.com/studio
   - Download the macOS version
   - Open the `.dmg` file and drag Android Studio to Applications

2. **Install Android Studio:**
   - Open Android Studio from Applications
   - Follow the setup wizard
   - It will automatically download and install:
     - Android SDK
     - Android SDK Platform-Tools
     - Android Emulator

3. **Accept Android Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
   - Press `y` to accept each license

4. **Verify Installation:**
   ```bash
   flutter doctor
   ```
   - You should now see ✅ for Android toolchain

### Option 2: Install Android SDK Only (Without Android Studio)

If you don't want the full Android Studio IDE:

1. **Install Android SDK Command Line Tools:**
   ```bash
   # Install via Homebrew
   brew install --cask android-commandlinetools
   ```

2. **Set up SDK:**
   ```bash
   # Create SDK directory
   mkdir -p ~/Library/Android/sdk
   
   # Set environment variables (add to ~/.zshrc)
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/tools/bin
   
   # Reload shell
   source ~/.zshrc
   ```

3. **Install SDK components:**
   ```bash
   sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   ```

4. **Tell Flutter where SDK is:**
   ```bash
   flutter config --android-sdk $ANDROID_HOME
   ```

### Option 3: Skip Android (For iOS-Only Development)

If you only need iOS development:

1. **You can ignore this warning** - it won't affect iOS development
2. **Flutter will still work** for iOS, macOS, and Web
3. **You can always add Android support later**

## Quick Fix Commands

After installing Android Studio:

```bash
# Accept licenses
flutter doctor --android-licenses

# Verify setup
flutter doctor

# If SDK is in custom location, tell Flutter:
flutter config --android-sdk /path/to/android/sdk
```

## Common Issues

### Issue: "Android SDK not found" after installing Android Studio
**Fix:** 
```bash
# Find where Android Studio installed SDK
# Usually: ~/Library/Android/sdk
flutter config --android-sdk ~/Library/Android/sdk
```

### Issue: "Android licenses not accepted"
**Fix:**
```bash
flutter doctor --android-licenses
# Press 'y' for each license
```

### Issue: "Command line tools not found"
**Fix:** Open Android Studio → Tools → SDK Manager → SDK Tools → Check "Android SDK Command-line Tools" → Apply

## Recommended Setup for This Project

Since **mobile is the priority** and you're on macOS:

1. ✅ **Keep iOS development** (already working)
2. ⚠️ **Android setup is optional** - you can add it later when needed
3. ✅ **Focus on iOS first** - get the app working on iPhone/iPad

You can develop and test the entire app on iOS without Android SDK!

## Verify Your Setup

```bash
flutter doctor -v
```

You should see:
- ✅ Flutter (channel stable)
- ✅ Xcode (for iOS)
- ⚠️ Android toolchain (optional)
- ✅ Chrome (for web)
- ✅ VS Code (if installed)

## Next Steps

1. If you want Android: Follow Option 1 above
2. If iOS-only: Continue development - this warning won't affect you
3. Test your Flutter app: `cd mobile && flutter run`

