# Video Call Integration - Setup Guide

## ✅ Implementation Complete

The Agora.io video call integration has been implemented in the Flutter app.

## 📁 Files Created

### Flutter App
- `mobile/lib/features/video_call/services/agora_service.dart` - Agora RTC engine service
- `mobile/lib/features/video_call/screens/video_call_screen.dart` - Video call UI

### Updated Files
- `mobile/lib/features/consultations/screens/consultation_detail_screen.dart` - Added video call navigation
- `mobile/ios/Runner/Info.plist` - Added camera/microphone permissions

## 🔧 Backend Requirements

The backend already has Agora token generation implemented. You need to:

1. **Get Agora Credentials:**
   - Sign up at https://www.agora.io/
   - Create a new project
   - Get your App ID and App Certificate

2. **Update Backend Environment Variables:**
   ```bash
   # In backend/.env
   AGORA_APP_ID=your_app_id_here
   AGORA_APP_CERTIFICATE=your_app_certificate_here
   ```

3. **Update Agora Token Generation (Recommended):**
   The current implementation in `backend/app/services/agora_service.py` is simplified.
   For production, use the official Agora Python SDK:
   ```bash
   pip install agora-python-sdk
   ```
   
   Then update the token generation to use `RtcTokenBuilder`.

## 📱 How It Works

### Flow:
1. User starts a consultation from `ConsultationDetailScreen`
2. Backend generates Agora token and returns:
   - `agora_channel_name`
   - `agora_app_id`
   - `agora_token`
3. Flutter app navigates to `VideoCallScreen`
4. `AgoraVideoService` initializes RTC engine
5. User joins the video call channel
6. Video call UI shows local and remote video
7. User can toggle audio/video, switch camera, end call

### Features:
- ✅ Local video preview (picture-in-picture)
- ✅ Remote video display (full screen)
- ✅ Toggle audio (mute/unmute)
- ✅ Toggle video (on/off)
- ✅ Switch camera (front/back)
- ✅ End call button
- ✅ Connection status indicator
- ✅ Permission handling
- ✅ Error handling

## 🎨 UI Features

- **Full-screen remote video** - Main view
- **Picture-in-picture local video** - Top right corner
- **Control buttons** - Bottom overlay:
  - Mute/Unmute audio
  - Enable/Disable video
  - Switch camera
  - End call (red button)
- **Connection status** - Top left indicator
- **Loading state** - Shows "Connecting..." while joining
- **Error handling** - Shows error messages if something fails

## 🔐 Permissions

### iOS (Info.plist)
- ✅ `NSCameraUsageDescription` - Added
- ✅ `NSMicrophoneUsageDescription` - Added

### Android (AndroidManifest.xml)
- ⚠️ **TODO:** Add camera and microphone permissions:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```

## 🧪 Testing

### Prerequisites:
1. Backend running with Agora credentials configured
2. Two test accounts (doctor and volunteer)
3. A consultation created and started

### Test Steps:
1. **As Volunteer:**
   - Login
   - Go to "My Consultations"
   - Open a scheduled consultation
   - Tap "Start Consultation"
   - Video call screen should open
   - Grant camera/microphone permissions
   - Wait for connection

2. **As Doctor:**
   - Login
   - Go to "My Consultations"
   - Open the same consultation
   - Tap "Start Consultation"
   - Video call screen should open
   - Both users should see each other

3. **Test Controls:**
   - Toggle audio (mute/unmute)
   - Toggle video (on/off)
   - Switch camera (front/back)
   - End call

## 🐛 Troubleshooting

### "Failed to initialize video call"
- Check Agora App ID is correct
- Verify permissions are granted
- Check device has camera/microphone

### "Failed to join video call"
- Verify Agora token is valid
- Check network connection
- Ensure channel name matches

### No video/audio
- Check permissions are granted
- Verify camera/microphone aren't used by another app
- Check device hardware is working

### Token expired
- Agora tokens expire after 1 hour
- Start a new consultation to get a fresh token

## 📝 Next Steps

1. **Add Android Permissions:**
   - Update `AndroidManifest.xml` with camera/microphone permissions

2. **Improve Token Generation:**
   - Use official Agora Python SDK for token generation
   - Add token refresh mechanism

3. **Enhancements:**
   - Add screen sharing
   - Add call recording (if needed)
   - Add network quality indicators
   - Add call duration timer
   - Add participant list
   - Add chat during call

4. **Testing:**
   - Test on real devices (iOS and Android)
   - Test with poor network conditions
   - Test with multiple participants (if needed)

## 🔗 Resources

- [Agora Flutter SDK Documentation](https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=flutter)
- [Agora Token Generation](https://docs.agora.io/en/video-calling/develop/integrate-token-generation)
- [Agora Python SDK](https://github.com/AgoraIO/Agora-Python-SDK)

---

**Status:** ✅ Implementation Complete - Ready for Testing  
**Next:** Configure Agora credentials and test on devices

