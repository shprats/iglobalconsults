/// Video Call Screen
/// Agora.io video call interface for consultations

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/video_call_service.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../consultations/providers/consultation_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String? agoraToken;
  final String? channelName;
  final String? appId;

  const VideoCallScreen({
    super.key,
    required this.consultationId,
    this.agoraToken,
    this.channelName,
    this.appId,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  RtcEngine? _engine;
  bool _isJoined = false;
  int? _remoteUid;
  bool _localUserMuted = false;
  bool _localVideoEnabled = true;
  bool _isLoading = true;
  String? _error;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _initializeAgora() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    try {
      // Get Agora credentials if not provided
      String? token = widget.agoraToken;
      String? channelName = widget.channelName;
      String? appId = widget.appId;

      if (token == null || channelName == null || appId == null) {
        // Fetch from backend
        final videoService = VideoCallService(ApiClient());
        final credentials = await videoService.getAgoraToken(widget.consultationId);
        token = credentials['agora_token'] as String;
        channelName = credentials['agora_channel_name'] as String;
        appId = credentials['agora_app_id'] as String;
      }

      // Create RtcEngine instance
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            setState(() {
              _isJoined = true;
              _isLoading = false;
            });
            _startCallTimer();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            setState(() {
              _remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            setState(() {
              _remoteUid = null;
            });
          },
          onError: (ErrorCodeType err, String msg) {
            setState(() {
              _error = 'Error: $msg';
              _isLoading = false;
            });
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            setState(() {
              _isJoined = false;
              _remoteUid = null;
            });
          },
        ),
      );

      // Enable video
      await _engine!.enableVideo();
      await _engine!.startPreview();

      // Join channel
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: 0, // Let Agora assign UID
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize video call: $e';
        _isLoading = false;
      });
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  Future<void> _toggleMute() async {
    if (_engine != null) {
      await _engine!.muteLocalAudioStream(!_localUserMuted);
      setState(() {
        _localUserMuted = !_localUserMuted;
      });
    }
  }

  Future<void> _toggleVideo() async {
    if (_engine != null) {
      await _engine!.muteLocalVideoStream(!_localVideoEnabled);
      setState(() {
        _localVideoEnabled = !_localVideoEnabled;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_engine != null) {
      await _engine!.switchCamera();
    }
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();
    await _dispose();
    
    if (mounted) {
      // Navigate back and show notes screen
      Navigator.pop(context);
      
      // Optionally navigate to notes screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ConsultationNotesScreen(
      //       consultationId: widget.consultationId,
      //     ),
      //   ),
      // );
    }
  }

  Future<void> _dispose() async {
    _callTimer?.cancel();
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Connecting...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video views
            _buildVideoViews(),
            
            // Call duration
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Controls
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViews() {
    return Stack(
      children: [
        // Remote video (full screen)
        if (_remoteUid != null)
          SizedBox.expand(
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: const RtcConnection(channelId: ''),
              ),
            ),
          )
        else
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.white54, size: 64),
                SizedBox(height: 16),
                Text(
                  'Waiting for participant...',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),

        // Local video (picture-in-picture)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _localVideoEnabled
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine!,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mute/Unmute
        _buildControlButton(
          icon: _localUserMuted ? Icons.mic_off : Icons.mic,
          onPressed: _toggleMute,
          backgroundColor: _localUserMuted ? Colors.red : Colors.white24,
        ),
        const SizedBox(width: 16),
        
        // Video On/Off
        _buildControlButton(
          icon: _localVideoEnabled ? Icons.videocam : Icons.videocam_off,
          onPressed: _toggleVideo,
          backgroundColor: _localVideoEnabled ? Colors.white24 : Colors.red,
        ),
        const SizedBox(width: 16),
        
        // Switch Camera
        _buildControlButton(
          icon: Icons.switch_camera,
          onPressed: _switchCamera,
          backgroundColor: Colors.white24,
        ),
        const SizedBox(width: 16),
        
        // End Call
        _buildControlButton(
          icon: Icons.call_end,
          onPressed: _endCall,
          backgroundColor: Colors.red,
          size: 64,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double size = 56,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

