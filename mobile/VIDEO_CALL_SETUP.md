# Video Call Integration Setup Guide

## ✅ Implementation Complete

Video call integration with Agora.io has been implemented in the Flutter app.

## 📁 Files Created

### Flutter App
- `mobile/lib/features/video/services/video_call_service.dart` - Service for getting Agora tokens
- `mobile/lib/features/video/screens/video_call_screen.dart` - Main video call UI
- `mobile/lib/features/video/providers/video_call_provider.dart` - Riverpod providers

### Updated Files
- `mobile/lib/features/consultations/screens/consultation_detail_screen.dart` - Added video call navigation
- `mobile/ios/Runner/Info.plist` - Added camera/microphone permissions

## 🔧 Backend Configuration

The backend already has Agora token generation. You need to configure:

1. **Set Agora Credentials in `.env`:**
```bash
AGORA_APP_ID=your_app_id_here
AGORA_APP_CERTIFICATE=your_app_certificate_here
```

2. **Get Agora Credentials:**
   - Sign up at https://www.agora.io/
   - Create a new project
   - Get your App ID and App Certificate
   - Add them to `backend/.env`

## 📱 Features Implemented

### Video Call Screen
- ✅ Join Agora video channel
- ✅ Display local video (picture-in-picture)
- ✅ Display remote video (full screen)
- ✅ Mute/unmute microphone
- ✅ Enable/disable camera
- ✅ Switch camera (front/back)
- ✅ End call button
- ✅ Call duration timer
- ✅ Waiting for participant state
- ✅ Error handling

### Integration
- ✅ Start consultation → Navigate to video call
- ✅ Join ongoing call from consultation detail
- ✅ End call → Navigate back to consultation
- ✅ Automatic token fetching from backend
- ✅ Permission handling (camera/microphone)

## 🎯 How It Works

1. **Starting a Consultation:**
   - User taps "Start Consultation" in consultation detail
   - Backend generates Agora token and channel name
   - Consultation status changes to "in_progress"
   - App navigates to VideoCallScreen with credentials

2. **Joining a Call:**
   - VideoCallScreen requests camera/microphone permissions
   - Initializes Agora RTC Engine
   - Joins the channel with token
   - Displays local video preview
   - Waits for remote participant

3. **During Call:**
   - Both participants see each other's video
   - Can mute/unmute audio
   - Can enable/disable video
   - Can switch camera
   - See call duration

4. **Ending Call:**
   - User taps "End Call"
   - Leaves Agora channel
   - Releases RTC Engine
   - Navigates back to consultation detail
   - Can add notes/diagnosis

## 🔐 Permissions

### iOS
Added to `Info.plist`:
- `NSCameraUsageDescription` - Camera access for video
- `NSMicrophoneUsageDescription` - Microphone access for audio

### Android
Permissions are automatically requested via `permission_handler` package.

## 🧪 Testing

### Prerequisites
1. Backend running with Agora credentials configured
2. Two test accounts (doctor and volunteer)
3. A scheduled consultation

### Test Flow
1. **As Volunteer:**
   - Login
   - Go to "My Consultations"
   - Open a scheduled consultation
   - Tap "Start Consultation"
   - Video call screen should open
   - Grant camera/microphone permissions
   - See your local video

2. **As Doctor:**
   - Login
   - Go to "My Consultations"
   - Open the same consultation (now "in_progress")
   - Tap "Join Call"
   - Video call screen should open
   - Both should see each other

3. **During Call:**
   - Test mute/unmute
   - Test camera on/off
   - Test switch camera
   - Verify call duration updates

4. **End Call:**
   - Tap "End Call"
   - Should navigate back
   - Consultation should still be "in_progress"
   - Can add notes/diagnosis

## 🐛 Troubleshooting

### "Failed to initialize video call"
- Check Agora credentials in backend `.env`
- Verify backend is running
- Check network connection

### "No video/audio"
- Grant camera/microphone permissions
- Check device permissions in Settings
- Verify Agora token is valid

### "Cannot join channel"
- Check Agora App ID is correct
- Verify token hasn't expired
- Check network connectivity

### Black screen
- Verify camera permissions granted
- Check if camera is being used by another app
- Restart app and try again

## 📝 Next Steps

1. **Configure Agora Account:**
   - Sign up at agora.io
   - Create project
   - Get App ID and Certificate
   - Add to backend `.env`

2. **Test Video Calls:**
   - Use two devices or simulators
   - Test with real network conditions
   - Verify audio/video quality

3. **Optional Enhancements:**
   - Add screen sharing
   - Add chat during call
   - Add call recording (if needed)
   - Add network quality indicators
   - Add participant list

## 🔗 Resources

- [Agora.io Documentation](https://docs.agora.io/)
- [Agora Flutter SDK](https://pub.dev/packages/agora_rtc_engine)
- [Backend Agora Service](../backend/app/services/agora_service.py)

---

**Status:** ✅ Implementation Complete - Ready for Agora Credentials Configuration

