# Video Call Integration - Agora.io

## ✅ Implementation Complete

Video call integration using Agora.io SDK has been successfully implemented for GlobalHealth Connect.

## 📱 Features Implemented

### 1. Video Call Screen
- ✅ Full-screen video call interface
- ✅ Local video view (picture-in-picture)
- ✅ Remote video view (full screen)
- ✅ Waiting state when remote participant hasn't joined
- ✅ Black background for professional appearance

### 2. Video Call Controls
- ✅ **Mute/Unmute** - Toggle microphone
- ✅ **Video On/Off** - Toggle camera
- ✅ **Speaker Toggle** - Switch between speaker and earpiece
- ✅ **End Call** - End consultation with confirmation dialog

### 3. Integration with Consultations
- ✅ Start consultation triggers video call
- ✅ Agora token generation from backend
- ✅ Channel name generation
- ✅ Automatic navigation to video call screen
- ✅ End consultation from video call screen
- ✅ Consultation status updates (scheduled → in_progress → completed)

### 4. Permissions
- ✅ Camera permission request
- ✅ Microphone permission request
- ✅ Handled via `permission_handler` package

### 5. State Management
- ✅ Riverpod provider for video call state
- ✅ RTC engine lifecycle management
- ✅ Connection state tracking
- ✅ Remote user join/leave handling

## 🔧 Technical Implementation

### Files Created

1. **Video Call Service**
   - `mobile/lib/features/video_call/services/video_call_service.dart`
   - Handles Agora token retrieval from backend

2. **Video Call Provider**
   - `mobile/lib/features/video_call/providers/video_call_provider.dart`
   - Riverpod state management for video call
   - RTC engine initialization and lifecycle
   - Event handlers for join/leave/error

3. **Video Call Screen**
   - `mobile/lib/features/video_call/screens/video_call_screen.dart`
   - Full video call UI
   - Controls overlay
   - Video views layout

### Backend Integration

The backend already has:
- ✅ Agora token generation (`AgoraService`)
- ✅ Consultation start endpoint returns Agora credentials
- ✅ Channel name generation
- ✅ Token expiration handling

**Backend Response Format:**
```json
{
  "consultation_id": "uuid",
  "agora_channel_name": "consultation_uuid",
  "agora_app_id": "your_app_id",
  "agora_token": "generated_token"
}
```

## 🚀 Usage Flow

### Starting a Video Call

1. User views consultation details
2. Taps "Start Consultation" button
3. Confirmation dialog appears
4. Backend generates Agora token
5. App navigates to video call screen
6. Camera/microphone permissions requested
7. RTC engine initializes
8. User joins Agora channel
9. Video call begins

### During Video Call

- User can toggle mute/video/speaker
- Local video shown in picture-in-picture
- Remote video shown full screen
- Waiting state if remote participant hasn't joined

### Ending a Video Call

1. User taps "End Call" button
2. Confirmation dialog appears
3. Consultation ended via backend API
4. RTC engine leaves channel and releases
5. User navigated back to consultation list
6. Consultation status updated to "completed"

## 📋 Configuration Required

### 1. Agora.io Account Setup

1. Create account at [Agora.io](https://www.agora.io)
2. Create a new project
3. Get your App ID and App Certificate
4. Add to backend `.env`:
   ```
   AGORA_APP_ID=your_app_id
   AGORA_APP_CERTIFICATE=your_app_certificate
   ```

### 2. iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera for video consultations</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for video consultations</string>
```

### 3. Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

## 🧪 Testing

### Test Video Call Flow

1. **As Volunteer:**
   - Accept a case
   - View consultation details
   - Start consultation
   - Video call screen should appear
   - Test controls (mute, video, speaker)
   - End call

2. **As Doctor:**
   - View consultation details
   - Start consultation (when volunteer has started)
   - Video call screen should appear
   - Both participants should see each other
   - Test controls
   - End call

### Expected Behavior

- ✅ Video call screen appears after starting consultation
- ✅ Camera and microphone permissions requested
- ✅ Local video shows in bottom-right corner
- ✅ Remote video shows full screen when participant joins
- ✅ Controls work (mute, video, speaker, end)
- ✅ Ending call updates consultation status
- ✅ Navigation back to consultation list works

## 🔍 Troubleshooting

### Common Issues

1. **No video showing:**
   - Check camera permissions
   - Verify Agora App ID is set correctly
   - Check token generation in backend

2. **Can't hear audio:**
   - Check microphone permissions
   - Verify speaker toggle state
   - Check device volume

3. **Connection issues:**
   - Verify network connection
   - Check Agora token expiration
   - Ensure channel name matches

4. **Remote participant not showing:**
   - Both users must start consultation
   - Verify both have valid tokens
   - Check channel name matches

## 📝 Next Steps (Future Enhancements)

1. **Connection Quality Indicators**
   - Show network quality
   - Display connection status
   - Handle poor connection gracefully

2. **Recording**
   - Enable call recording
   - Store recordings in S3
   - Add recording consent

3. **Screen Sharing**
   - Allow screen sharing during calls
   - Useful for showing medical images

4. **Chat During Call**
   - Text messaging during video call
   - Share files/images

5. **Call History**
   - View past call recordings
   - Download recordings

## ✅ Status

**Video call integration is complete and ready for testing!**

All core functionality is implemented:
- ✅ Video call screen
- ✅ Controls (mute, video, speaker, end)
- ✅ Backend integration
- ✅ Consultation flow integration
- ✅ Permissions handling
- ✅ State management

**Next:** Configure Agora.io credentials and test with two devices.

