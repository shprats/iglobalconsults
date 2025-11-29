# Fix: Android Command-Line Tools Missing

## Problem
Android SDK is installed, but `cmdline-tools` component is missing. This is needed to accept licenses and use Flutter with Android.

## Solution: Install Command-Line Tools

### Method 1: Via Android Studio (Easiest)

1. **Open Android Studio**
2. **Go to:** Tools → SDK Manager (or Android Studio → Settings → Appearance & Behavior → System Settings → Android SDK)
3. **Click on "SDK Tools" tab**
4. **Check the box:** "Android SDK Command-line Tools (latest)"
5. **Click "Apply"** - it will download and install
6. **Wait for installation to complete**

### Method 2: Via Command Line

1. **Find your Android SDK location:**
   ```bash
   # Usually one of these:
   echo $ANDROID_HOME
   # Or
   ls ~/Library/Android/sdk
   ```

2. **Set ANDROID_HOME if not set:**
   ```bash
   # Add to ~/.zshrc
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   
   # Reload
   source ~/.zshrc
   ```

3. **Install cmdline-tools:**
   ```bash
   # Create directory
   mkdir -p $ANDROID_HOME/cmdline-tools
   
   # Download and extract (replace with latest version)
   cd $ANDROID_HOME/cmdline-tools
   curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
   unzip cmdline-tools.zip
   mv cmdline-tools latest
   rm cmdline-tools.zip
   ```

4. **Install SDK components:**
   ```bash
   $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

### Method 3: Use sdkmanager (If Already Installed)

If you have sdkmanager somewhere:

```bash
# Find sdkmanager
which sdkmanager

# Or use the one in Android Studio
/Applications/Android\ Studio.app/Contents/jbr/Contents/Home/bin/java -jar \
  ~/Library/Android/sdk/cmdline-tools/latest/lib/sdkmanager.jar \
  "cmdline-tools;latest"
```

## After Installing cmdline-tools

1. **Accept licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
   - Press `y` for each license

2. **Verify:**
   ```bash
   flutter doctor
   ```

You should now see ✅ for Android toolchain!

## Quick Fix Script

Run this to set up everything:

```bash
#!/bin/bash

# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Library/Android/sdk

# Add to PATH
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Check if cmdline-tools exists
if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo "Installing cmdline-tools..."
    mkdir -p $ANDROID_HOME/cmdline-tools
    cd $ANDROID_HOME/cmdline-tools
    curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
    unzip -q cmdline-tools.zip
    mv cmdline-tools latest
    rm cmdline-tools.zip
    echo "✅ cmdline-tools installed"
else
    echo "✅ cmdline-tools already installed"
fi

# Accept licenses
echo "Accepting Android licenses..."
yes | flutter doctor --android-licenses

# Verify
flutter doctor
```

## Troubleshooting

### Issue: "sdkmanager not found"
**Fix:** Make sure `cmdline-tools/latest/bin` is in your PATH:
```bash
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
```

### Issue: "Permission denied"
**Fix:** Make sure the directory is writable:
```bash
chmod -R 755 $ANDROID_HOME
```

### Issue: "Java not found"
**Fix:** Android Studio includes Java. Use it:
```bash
export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jbr/Contents/Home
```

## Verify Installation

```bash
# Check if cmdline-tools is installed
ls -la ~/Library/Android/sdk/cmdline-tools/latest/bin/

# Should see: sdkmanager, avdmanager, etc.

# Check Flutter
flutter doctor
```

## Note

If you're only developing for iOS, you can skip this. The Android toolchain warning won't affect iOS development.

