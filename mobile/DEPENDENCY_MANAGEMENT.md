# Dependency Management Guide

## ⚠️ Important: Avoiding Dependency Hell

This document tracks our dependency strategy to avoid CocoaPods and dependency issues that can block development.

## Current Strategy: Minimal Native Dependencies

### ✅ What We Keep (Essential Only)
1. **agora_rtc_engine** - Video calls (required for consultations)
2. **image_picker** - Camera/photo selection (required for medical images)
3. **permission_handler** - Device permissions (required for camera/storage)

### ❌ What We Removed
- **Firebase** - Using our own backend API instead
- **Google Sign-In** - Can add later if needed, using backend auth for now

## Dependency Rules

### 🚫 NEVER Add Without Checking
Before adding any new dependency, check:

1. **Does it require CocoaPods?**
   - Check: Does it have native iOS/Android code?
   - If yes: Is it absolutely necessary?
   - Alternative: Can we use a pure Dart package instead?

2. **Version Conflicts**
   - Check: Does it conflict with existing packages?
   - Use: `flutter pub outdated` to check versions
   - Test: Run `flutter pub get` after adding

3. **Maintenance Status**
   - Check: Is the package actively maintained?
   - Check: Last update date on pub.dev
   - Avoid: Packages with no updates in 6+ months

### ✅ Safe to Add (Pure Dart)
These don't require CocoaPods:
- `http`, `dio` - HTTP clients
- `shared_preferences` - Local storage
- `intl` - Internationalization
- `uuid` - UUID generation
- Most state management packages (Riverpod, Provider)

### ⚠️ Use With Caution (Requires Native Code)
These require CocoaPods:
- Camera/Media packages
- Push notification packages
- Social login packages
- Video/audio packages

## Current Dependencies Status

### Core (Safe)
- ✅ `flutter_riverpod` - State management
- ✅ `dio` - HTTP client
- ✅ `shared_preferences` - Token storage
- ✅ `sqflite`, `hive` - Local database

### Native (Minimal)
- ⚠️ `agora_rtc_engine` - Video calls (required)
- ⚠️ `image_picker` - Camera (required)
- ⚠️ `permission_handler` - Permissions (required)
- ⚠️ `workmanager` - Background tasks (optional, can remove if issues)

### Removed (Avoid)
- ❌ `firebase_core`, `firebase_auth` - Using backend API
- ❌ `google_sign_in` - Can add later if needed
- ❌ `firebase_messaging` - Can use backend push notifications

## Troubleshooting

### If CocoaPods Fails
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### If Build Fails
1. Check Xcode version compatibility
2. Check iOS deployment target (should be 13.0+)
3. Check for conflicting package versions
4. Try removing problematic package temporarily

### If Dependency Conflicts
1. Check `pubspec.lock` for version conflicts
2. Use `flutter pub upgrade --major-versions` carefully
3. Consider removing conflicting package
4. Check package's GitHub issues

## Future Additions Checklist

Before adding ANY new package:

- [ ] Check if it requires native code
- [ ] Check pub.dev for recent updates
- [ ] Check GitHub for open issues
- [ ] Test in a branch first
- [ ] Verify CocoaPods installs successfully
- [ ] Test on both iOS and Android
- [ ] Document why it's needed

## Monitoring

### Regular Checks
- Run `flutter pub outdated` monthly
- Check for security vulnerabilities
- Review package updates before upgrading
- Keep dependencies minimal

### Warning Signs
- ⚠️ CocoaPods takes > 5 minutes
- ⚠️ Multiple version conflicts
- ⚠️ Build errors after adding package
- ⚠️ Package hasn't updated in 6+ months

## Best Practices

1. **Prefer Pure Dart Packages**
   - Less complexity
   - Faster builds
   - Fewer conflicts

2. **Test Before Committing**
   - Always test `flutter pub get`
   - Always test build after adding package
   - Test on both platforms

3. **Document Decisions**
   - Why we added a package
   - What alternatives we considered
   - Any known issues

4. **Keep Dependencies Updated**
   - But test thoroughly before upgrading
   - Read changelogs
   - Check breaking changes

## Current Status: ✅ Minimal & Stable

We have the minimum required native dependencies. All are well-maintained packages. This setup should be stable for development.

---

**Remember**: Every new dependency is a potential source of problems. Add only what's absolutely necessary.

