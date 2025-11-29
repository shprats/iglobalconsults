# Fix: Android Studio Architecture Mismatch Error

## Problem
You installed the **Intel (x86_64)** version of Android Studio, but your Mac needs the **Apple Silicon (arm64)** version.

Error: `mach-o file, but is an incompatible architecture (have 'x86_64', need 'arm64e' or 'arm64')`

## Solution: Install Apple Silicon Version

### Step 1: Remove Current Android Studio

```bash
# Remove Android Studio application
rm -rf /Applications/Android\ Studio.app

# Remove Android Studio configuration and cache
rm -rf ~/Library/Application\ Support/Google/AndroidStudio*
rm -rf ~/Library/Preferences/com.google.android.studio*
rm -rf ~/Library/Caches/Google/AndroidStudio*
rm -rf ~/Library/Logs/Google/AndroidStudio*
```

### Step 2: Download Apple Silicon Version

1. **Go to Android Studio download page:**
   - Visit: https://developer.android.com/studio
   - **IMPORTANT:** Make sure you download the **Apple Silicon** version
   - Look for "Mac (Apple Silicon)" or "Mac (arm64)" in the download button

2. **Or download directly:**
   ```bash
   # Download Apple Silicon version
   curl -L -o ~/Downloads/android-studio-arm64.dmg \
     "https://redirector.gvt1.com/edgedl/android/studio/install/2024.1.1.12/android-studio-2024.1.1.12-mac_arm.dmg"
   ```

### Step 3: Install Apple Silicon Version

1. **Open the downloaded .dmg file**
2. **Drag Android Studio to Applications folder**
3. **Open Android Studio from Applications**
   - Right-click → Open (first time only, to bypass Gatekeeper)
   - Or: `xattr -d com.apple.quarantine /Applications/Android\ Studio.app`

### Step 4: Complete Setup

1. **Follow Android Studio setup wizard**
2. **It will automatically download Android SDK**
3. **Accept licenses:**
   ```bash
   flutter doctor --android-licenses
   ```

### Step 5: Verify

```bash
flutter doctor
```

You should now see ✅ for Android toolchain.

## Quick Fix (If You Just Downloaded)

If you just downloaded and haven't set up yet:

1. **Delete the Intel version:**
   ```bash
   rm -rf /Applications/Android\ Studio.app
   ```

2. **Download Apple Silicon version:**
   - Go to https://developer.android.com/studio
   - Click "Download Android Studio"
   - **Make sure it says "Mac (Apple Silicon)" or "Mac (arm64)"**
   - NOT "Mac (Intel)"

3. **Install the new version**

## How to Tell Which Version You Have

**Before installing:**
- Check the download page - it should say "Mac (Apple Silicon)" or "Mac (arm64)"
- File size: Apple Silicon version is usually slightly different

**After installing:**
```bash
# Check the architecture
file /Applications/Android\ Studio.app/Contents/jbr/Contents/Home/lib/libjli.dylib
```

Should show: `arm64` or `arm64e` (NOT `x86_64`)

## Alternative: Use Homebrew (Easier)

```bash
# Remove old version
rm -rf /Applications/Android\ Studio.app

# Install via Homebrew (automatically gets correct architecture)
brew install --cask android-studio

# Open Android Studio
open -a "Android Studio"
```

## After Installation

1. **Open Android Studio**
2. **Complete setup wizard** (it will download Android SDK)
3. **Accept licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
4. **Verify:**
   ```bash
   flutter doctor
   ```

## Still Having Issues?

If you continue to have problems:

1. **Check your Mac architecture:**
   ```bash
   uname -m
   ```
   Should show: `arm64` (Apple Silicon) or `x86_64` (Intel Mac)

2. **If you have Intel Mac:**
   - You need the Intel version (x86_64)
   - The error suggests you have Apple Silicon Mac

3. **If you have Apple Silicon Mac:**
   - You MUST use Apple Silicon version
   - Intel version won't work

## Note

Remember: **Android SDK is optional** for this project. You can continue developing for iOS without it!

