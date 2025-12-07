/// Agora Video Call Service
/// Handles Agora RTC engine initialization and video call management

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraVideoService {
  RtcEngine? _engine;
  bool _isInitialized = false;
  int? _localUid;
  String? _channelName;
  String? _token;
  String? _appId;

  // Callbacks
  Function(int uid, int elapsed)? onUserJoined;
  Function(int uid, UserOfflineReasonType reason)? onUserOffline;
  Function(int uid, bool muted)? onUserMuteAudio;
  Function(int uid, bool muted)? onUserMuteVideo;
  Function(RtcConnection connection, int remoteUid, int elapsed)? onRemoteVideoStateChanged;

  /// Initialize Agora RTC Engine
  Future<bool> initialize({
    required String appId,
    Function(int uid, int elapsed)? onUserJoined,
    Function(int uid, UserOfflineReasonType reason)? onUserOffline,
    Function(int uid, bool muted)? onUserMuteAudio,
    Function(int uid, bool muted)? onUserMuteVideo,
    Function(RtcConnection connection, int remoteUid, int elapsed)? onRemoteVideoStateChanged,
  }) async {
    try {
      // Request permissions
      await _requestPermissions();

      // Create engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Set event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _isInitialized = true;
            _localUid = connection.localUid;
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            _isInitialized = false;
            _localUid = null;
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            onUserJoined?.call(remoteUid, elapsed);
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            onUserOffline?.call(remoteUid, reason);
          },
          onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
            onUserMuteAudio?.call(remoteUid, muted);
          },
          onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
            onUserMuteVideo?.call(remoteUid, muted);
          },
          onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
            if (state == RemoteVideoState.remoteVideoStateStarting || state == RemoteVideoState.remoteVideoStateDecoding) {
              onRemoteVideoStateChanged?.call(connection, remoteUid, elapsed);
            }
          },
          onError: (ErrorCodeType err, String msg) {
            print('Agora Error: $err - $msg');
          },
        ),
      );

      // Enable video
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      _appId = appId;
      return true;
    } catch (e) {
      print('Error initializing Agora: $e');
      return false;
    }
  }

  /// Join a video call channel
  Future<bool> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (_engine == null) {
      print('Engine not initialized');
      return false;
    }

    try {
      _channelName = channelName;
      _token = token;

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      return true;
    } catch (e) {
      print('Error joining channel: $e');
      return false;
    }
  }

  /// Leave the video call channel
  Future<void> leaveChannel() async {
    if (_engine == null) return;

    try {
      await _engine!.leaveChannel();
      _channelName = null;
      _token = null;
    } catch (e) {
      print('Error leaving channel: $e');
    }
  }

  /// Enable/disable local video
  Future<void> enableLocalVideo(bool enabled) async {
    if (_engine == null) return;
    await _engine!.muteLocalVideoStream(!enabled);
  }

  /// Enable/disable local audio
  Future<void> enableLocalAudio(bool enabled) async {
    if (_engine == null) return;
    await _engine!.muteLocalAudioStream(!enabled);
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  /// Get local video view widget
  Widget? getLocalVideoView() {
    if (_engine == null || _localUid == null) return null;
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _localUid),
      ),
    );
  }

  /// Get remote video view widget
  Widget? getRemoteVideoView(int remoteUid) {
    if (_engine == null) return null;
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(channelId: _channelName),
      ),
    );
  }

  /// Dispose resources
  Future<void> dispose() async {
    await leaveChannel();
    await _engine?.release();
    _engine = null;
    _isInitialized = false;
    _localUid = null;
  }

  /// Request camera and microphone permissions
  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  bool get isInitialized => _isInitialized;
  int? get localUid => _localUid;
  String? get channelName => _channelName;
  RtcEngine? get engine => _engine;
}

