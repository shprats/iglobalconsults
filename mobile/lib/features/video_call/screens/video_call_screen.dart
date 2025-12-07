/// Video Call Screen
/// Agora.io video call interface for consultations

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/agora_service.dart';
import '../../consultations/services/consultation_service.dart';
import '../../../core/network/api_client.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String consultationId;
  final String channelName;
  final String appId;
  final String token;
  final int uid;

  const VideoCallScreen({
    super.key,
    required this.consultationId,
    required this.channelName,
    required this.appId,
    required this.token,
    required this.uid,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late AgoraVideoService _agoraService;
  bool _isInitialized = false;
  bool _isJoined = false;
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isRemoteVideoVisible = false;
  int? _remoteUid;
  String? _error;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  Future<void> _initializeVideoCall() async {
    // Check permissions
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      setState(() {
        _error = 'Camera and microphone permissions are required';
      });
      return;
    }

    _agoraService = AgoraVideoService();

    // Set up callbacks
    _agoraService.onUserJoined = (uid, elapsed) {
      setState(() {
        _remoteUid = uid;
        _isRemoteVideoVisible = true;
      });
    };

    _agoraService.onUserOffline = (uid, reason) {
      setState(() {
        _remoteUid = null;
        _isRemoteVideoVisible = false;
      });
    };

    _agoraService.onUserMuteVideo = (uid, muted) {
      setState(() {
        if (uid == _remoteUid) {
          _isRemoteVideoVisible = !muted;
        }
      });
    };

    // Initialize Agora
    final initialized = await _agoraService.initialize(
      appId: widget.appId,
      onUserJoined: _agoraService.onUserJoined,
      onUserOffline: _agoraService.onUserOffline,
      onUserMuteVideo: _agoraService.onUserMuteVideo,
    );

    if (!initialized) {
      setState(() {
        _error = 'Failed to initialize video call';
      });
      return;
    }

    setState(() {
      _isInitialized = true;
    });

    // Join channel
    final joined = await _agoraService.joinChannel(
      channelName: widget.channelName,
      token: widget.token,
      uid: widget.uid,
    );

    if (!joined) {
      setState(() {
        _error = 'Failed to join video call';
      });
      return;
    }

    setState(() {
      _isJoined = true;
    });
  }

  Future<void> _toggleVideo() async {
    await _agoraService.enableLocalVideo(!_isVideoEnabled);
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  Future<void> _toggleAudio() async {
    await _agoraService.enableLocalAudio(!_isAudioEnabled);
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
  }

  Future<void> _switchCamera() async {
    await _agoraService.switchCamera();
  }

  Future<void> _endCall() async {
    if (_isEnding) return;

    setState(() {
      _isEnding = true;
    });

    // Leave channel
    await _agoraService.leaveChannel();

    // End consultation on backend
    try {
      final consultationService = ConsultationService(ApiClient());
      await consultationService.endConsultation(
        widget.consultationId,
        // Notes can be added later in consultation notes screen
      );
    } catch (e) {
      print('Error ending consultation: $e');
    }

    // Dispose resources
    await _agoraService.dispose();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
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

    if (!_isInitialized || !_isJoined) {
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
                style: TextStyle(color: Colors.white, fontSize: 18),
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
            // Remote video (full screen)
            if (_isRemoteVideoVisible && _remoteUid != null)
              Center(
                child: _agoraService.getRemoteVideoView(_remoteUid!) ??
                    const Center(
                      child: Text(
                        'Waiting for remote video...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              )
            else
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 100, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Waiting for participant...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),

            // Local video (picture-in-picture)
            if (_isVideoEnabled)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _agoraService.getLocalVideoView() ??
                        Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.videocam_off, color: Colors.white),
                          ),
                        ),
                  ),
                ),
              ),

            // Controls overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Toggle Audio
                    _buildControlButton(
                      icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                      label: _isAudioEnabled ? 'Mute' : 'Unmute',
                      onPressed: _toggleAudio,
                      backgroundColor: _isAudioEnabled ? Colors.white24 : Colors.red,
                    ),

                    // Toggle Video
                    _buildControlButton(
                      icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      label: _isVideoEnabled ? 'Video Off' : 'Video On',
                      onPressed: _toggleVideo,
                      backgroundColor: _isVideoEnabled ? Colors.white24 : Colors.red,
                    ),

                    // Switch Camera
                    _buildControlButton(
                      icon: Icons.switch_camera,
                      label: 'Switch',
                      onPressed: _switchCamera,
                      backgroundColor: Colors.white24,
                    ),

                    // End Call
                    _buildControlButton(
                      icon: Icons.call_end,
                      label: 'End',
                      onPressed: _endCall,
                      backgroundColor: Colors.red,
                      isEndButton: true,
                    ),
                  ],
                ),
              ),
            ),

            // Connection status
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Connected',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    bool isEndButton = false,
  }) {
    return Column(
      children: [
        Container(
          width: isEndButton ? 64 : 56,
          height: isEndButton ? 64 : 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: isEndButton ? 28 : 24),
            onPressed: _isEnding ? null : onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

