# Firebase Setup Guide for Push Notifications

This guide walks you through setting up Firebase Cloud Messaging (FCM) for push notifications in GlobalHealth Connect.

## Prerequisites

- A Google account
- Access to Firebase Console (https://console.firebase.google.com)
- Your iOS Bundle ID (e.g., `com.globalhealthconnect.app`)
- Your Android Package Name (e.g., `com.globalhealthconnect.app`)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `GlobalHealth Connect` (or your preferred name)
4. (Optional) Enable Google Analytics
5. Click **"Create project"**
6. Wait for project creation to complete
7. Click **"Continue"**

## Step 2: Add iOS App

1. In Firebase Console, click the **iOS icon** (or **"Add app"** → **iOS**)
2. Enter iOS Bundle ID:
   - Example: `com.globalhealthconnect.app`
   - **Important**: This must match your Flutter app's iOS bundle ID
3. (Optional) Enter App nickname and App Store ID
4. Click **"Register app"**
5. Download `GoogleService-Info.plist`:
   - Click **"Download GoogleService-Info.plist"**
   - **Save this file** - you'll need it in Step 4

## Step 3: Add Android App

1. In Firebase Console, click the **Android icon** (or **"Add app"** → **Android**)
2. Enter Android package name:
   - Example: `com.globalhealthconnect.app`
   - **Important**: This must match your Flutter app's Android package name
3. (Optional) Enter App nickname and Debug signing certificate SHA-1
4. Click **"Register app"**
5. Download `google-services.json`:
   - Click **"Download google-services.json"**
   - **Save this file** - you'll need it in Step 4

## Step 4: Add Configuration Files to Flutter Project

### iOS Configuration

1. Open Xcode:
   ```bash
   cd mobile/ios
   open Runner.xcworkspace
   ```

2. In Xcode:
   - Right-click on `Runner` folder in Project Navigator
   - Select **"Add Files to Runner..."**
   - Select the downloaded `GoogleService-Info.plist`
   - Make sure **"Copy items if needed"** is checked
   - Click **"Add"**

3. Verify the file is in:
   ```
   mobile/ios/Runner/GoogleService-Info.plist
   ```

### Android Configuration

1. Copy `google-services.json` to:
   ```
   mobile/android/app/google-services.json
   ```

2. Update `mobile/android/build.gradle`:
   ```gradle
   buildscript {
       dependencies {
           // Add this line
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

3. Update `mobile/android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.android.application'
   apply plugin: 'kotlin-android'
   // Add this line at the bottom
   apply plugin: 'com.google.gms.google-services'
   ```

## Step 5: Enable Cloud Messaging API

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Click on **"Cloud Messaging"** tab
3. If not enabled, click **"Enable"** for Cloud Messaging API
4. Note your **Server Key** (you'll need this for backend)

## Step 6: Get Firebase Credentials for Backend

### Option A: Server Key (Simple, but less secure)

1. In Firebase Console → **Project Settings** → **Cloud Messaging**
2. Under **"Cloud Messaging API (Legacy)"**, find **"Server key"**
3. Copy this key - you'll add it to backend `.env`

### Option B: Service Account (Recommended for production)

1. In Firebase Console → **Project Settings** → **Service accounts**
2. Click **"Generate new private key"**
3. Download the JSON file
4. Save it securely (e.g., `backend/firebase-service-account.json`)
5. **Never commit this file to Git!**

## Step 7: Configure Backend Environment

Add to `backend/.env`:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVER_KEY=your-server-key  # If using Option A
# OR
FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json  # If using Option B
```

**Important**: Add `firebase-service-account.json` to `.gitignore`:
```
backend/.gitignore
firebase-service-account.json
```

## Step 8: Install Backend Dependencies

Add Firebase Admin SDK to `backend/requirements.txt`:

```txt
firebase-admin>=6.0.0
```

Then install:
```bash
cd backend
pip install -r requirements.txt
```

## Step 9: Update Backend Notification Service

Create `backend/app/services/fcm_service.py`:

```python
"""
Firebase Cloud Messaging Service
Sends push notifications via FCM
"""

import os
from typing import Optional, Dict, Any
from app.core.config import settings

try:
    import firebase_admin
    from firebase_admin import credentials, messaging
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    print("Warning: Firebase Admin SDK not installed. Push notifications disabled.")


class FCMService:
    """Service for sending FCM push notifications"""
    
    _initialized = False
    
    @classmethod
    def initialize(cls):
        """Initialize Firebase Admin SDK"""
        if not FIREBASE_AVAILABLE:
            return False
        
        if cls._initialized:
            return True
        
        try:
            # Option 1: Use service account file
            if settings.FIREBASE_CREDENTIALS_PATH and os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred)
            # Option 2: Use default credentials (for Cloud Run, etc.)
            else:
                firebase_admin.initialize_app()
            
            cls._initialized = True
            return True
        except Exception as e:
            print(f"Failed to initialize Firebase: {e}")
            return False
    
    @classmethod
    def send_notification(
        cls,
        device_token: str,
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None
    ) -> bool:
        """Send a push notification to a device"""
        if not cls._initialized:
            if not cls.initialize():
                return False
        
        try:
            message = messaging.Message(
                token=device_token,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
            )
            
            response = messaging.send(message)
            print(f"Successfully sent message: {response}")
            return True
        except Exception as e:
            print(f"Error sending notification: {e}")
            return False
    
    @classmethod
    def send_multicast(
        cls,
        device_tokens: list[str],
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Send notification to multiple devices"""
        if not cls._initialized:
            if not cls.initialize():
                return {"success": 0, "failure": len(device_tokens)}
        
        try:
            message = messaging.MulticastMessage(
                tokens=device_tokens,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
            )
            
            response = messaging.send_multicast(message)
            return {
                "success": response.success_count,
                "failure": response.failure_count,
            }
        except Exception as e:
            print(f"Error sending multicast notification: {e}")
            return {"success": 0, "failure": len(device_tokens)}
```

## Step 10: Update Backend Config

Add to `backend/app/core/config.py`:

```python
class Settings(BaseSettings):
    # ... existing settings ...
    
    # Firebase
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_SERVER_KEY: str = ""  # Legacy API key
    FIREBASE_CREDENTIALS_PATH: str = ""  # Service account JSON path
```

## Step 11: Test Push Notifications

### Test from Backend

Create a test script `backend/test_fcm.py`:

```python
from app.services.fcm_service import FCMService

# Initialize
FCMService.initialize()

# Send test notification
# Replace with actual device token from your app
device_token = "YOUR_DEVICE_TOKEN_FROM_APP"
FCMService.send_notification(
    device_token=device_token,
    title="Test Notification",
    body="This is a test push notification!",
    data={"type": "test", "case_id": "123"}
)
```

### Get Device Token from App

1. Run the Flutter app
2. After login, check console logs for:
   ```
   FCM Token: <your-token-here>
   ```
3. Use this token in the test script

## Step 12: iOS Additional Setup

### Enable Push Notifications Capability

1. Open `mobile/ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **"Signing & Capabilities"** tab
4. Click **"+ Capability"**
5. Add **"Push Notifications"**
6. Add **"Background Modes"** and check:
   - ✅ Remote notifications

### Update AppDelegate (if needed)

The Flutter Firebase plugin should handle this automatically, but verify:

`mobile/ios/Runner/AppDelegate.swift` should have:
```swift
import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 13: Android Additional Setup

### Update AndroidManifest.xml

Verify `mobile/android/app/src/main/AndroidManifest.xml` has:

```xml
<manifest>
    <application>
        <!-- ... existing content ... -->
        
        <!-- Firebase Cloud Messaging -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
    </application>
</manifest>
```

The Flutter Firebase plugin should add this automatically.

## Step 14: Verify Setup

### Checklist

- [ ] Firebase project created
- [ ] iOS app added to Firebase
- [ ] Android app added to Firebase
- [ ] `GoogleService-Info.plist` added to iOS project
- [ ] `google-services.json` added to Android project
- [ ] Firebase credentials configured in backend
- [ ] Backend FCM service created
- [ ] Device token registration working
- [ ] Test notification sent successfully

## Troubleshooting

### iOS: "No valid 'aps-environment' entitlement"

- Ensure Push Notifications capability is enabled in Xcode
- Check that your Apple Developer account has push notification certificates

### Android: "Default FirebaseApp is not initialized"

- Verify `google-services.json` is in `android/app/`
- Check that `apply plugin: 'com.google.gms.google-services'` is in `app/build.gradle`
- Run `flutter clean` and rebuild

### Backend: "Firebase Admin SDK not initialized"

- Check that `FIREBASE_CREDENTIALS_PATH` points to valid service account JSON
- Verify the JSON file has correct permissions
- Check that `firebase-admin` is installed

### No notifications received

1. Verify device token is registered (check backend logs)
2. Check Firebase Console → Cloud Messaging → Reports
3. Verify app has notification permissions
4. Check device is connected to internet
5. For iOS: Ensure app is built with proper provisioning profile

## Next Steps

After setup is complete:

1. **Integrate notification triggers**: Update case/consultation services to send notifications
2. **Add deep linking**: Handle notification data to navigate to specific screens
3. **Add notification preferences**: Let users control notification types
4. **Monitor**: Set up Firebase Analytics to track notification delivery

## Security Notes

- **Never commit** `GoogleService-Info.plist`, `google-services.json`, or service account JSON to Git
- Use environment variables for sensitive keys
- Rotate service account keys periodically
- Use Firebase App Check for additional security in production

## Resources

- [Firebase Console](https://console.firebase.google.com)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

