/// Video Call Screen
/// Agora.io video call interface for consultations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/video_call_provider.dart';
import '../../consultations/providers/consultation_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String channelName;
  final String agoraToken;
  final String agoraAppId;
  final int userId;

  const VideoCallScreen({
    super.key,
    required this.consultationId,
    required this.channelName,
    required this.agoraToken,
    required this.agoraAppId,
    required this.userId,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isEndingCall = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  Future<void> _initializeVideoCall() async {
    // Request camera and microphone permissions
    await [Permission.camera, Permission.microphone].request();

    // Initialize video call
    ref.read(videoCallProvider.notifier).initializeCall(
          appId: widget.agoraAppId,
          channelName: widget.channelName,
          token: widget.agoraToken,
          uid: widget.userId,
        );
  }

  @override
  void dispose() {
    ref.read(videoCallProvider.notifier).dispose();
    super.dispose();
  }

  Future<void> _handleEndCall() async {
    if (_isEndingCall) return;

    setState(() => _isEndingCall = true);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Consultation'),
        content: const Text('Are you sure you want to end this consultation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Call'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // End consultation via backend
      await ref
          .read(consultationsListProvider.notifier)
          .endConsultation(widget.consultationId);

      // Leave video call
      ref.read(videoCallProvider.notifier).leaveCall();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation ended'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => _isEndingCall = false);
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    ref.read(videoCallProvider.notifier).toggleMute(_isMuted);
  }

  void _toggleVideo() {
    setState(() => _isVideoEnabled = !_isVideoEnabled);
    ref.read(videoCallProvider.notifier).toggleVideo(_isVideoEnabled);
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerEnabled = !_isSpeakerEnabled);
    ref.read(videoCallProvider.notifier).toggleSpeaker(_isSpeakerEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final videoCallState = ref.watch(videoCallProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video views
            _buildVideoViews(videoCallState),
            // Controls overlay
            _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViews(VideoCallState state) {
    return Stack(
      children: [
        // Remote video (full screen)
        state.remoteUid != null && state.engine != null
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: state.engine!,
                  canvas: VideoCanvas(uid: state.remoteUid),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Waiting for participant...',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
        // Local video (picture-in-picture)
        if (_isVideoEnabled && state.engine != null)
          Positioned(
            bottom: 100,
            right: 16,
            child: SizedBox(
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: state.engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
            // Mute button
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              label: _isMuted ? 'Unmute' : 'Mute',
              onPressed: _toggleMute,
              color: _isMuted ? Colors.red : Colors.white,
            ),
            // Video toggle
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              label: _isVideoEnabled ? 'Video On' : 'Video Off',
              onPressed: _toggleVideo,
              color: _isVideoEnabled ? Colors.white : Colors.red,
            ),
            // Speaker toggle
            _buildControlButton(
              icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
              label: _isSpeakerEnabled ? 'Speaker' : 'Mute',
              onPressed: _toggleSpeaker,
              color: Colors.white,
            ),
            // End call button
            _buildControlButton(
              icon: Icons.call_end,
              label: 'End',
              onPressed: _handleEndCall,
              color: Colors.red,
              size: 56,
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
    required Color color,
    double size = 48,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
            iconSize: size * 0.5,
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
