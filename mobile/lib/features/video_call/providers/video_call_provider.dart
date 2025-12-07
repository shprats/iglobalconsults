/// Video Call Provider
/// Riverpod provider for Agora video call state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

final videoCallProvider =
    StateNotifierProvider<VideoCallNotifier, VideoCallState>((ref) {
  return VideoCallNotifier();
});

class VideoCallState {
  final RtcEngine? engine;
  final int? remoteUid;
  final bool isConnected;
  final String? error;

  VideoCallState({
    this.engine,
    this.remoteUid,
    this.isConnected = false,
    this.error,
  });

  VideoCallState copyWith({
    RtcEngine? engine,
    int? remoteUid,
    bool? isConnected,
    String? error,
  }) {
    return VideoCallState(
      engine: engine ?? this.engine,
      remoteUid: remoteUid ?? this.remoteUid,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
    );
  }
}

class VideoCallNotifier extends StateNotifier<VideoCallState> {
  VideoCallNotifier() : super(VideoCallState());

  Future<void> initializeCall({
    required String appId,
    required String channelName,
    required String token,
    required int uid,
  }) async {
    try {
      // Create RTC engine instance
      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Enable video
      await engine.enableVideo();
      await engine.startPreview();

      // Set up event handlers
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            state = state.copyWith(isConnected: true);
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            state = state.copyWith(remoteUid: remoteUid);
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            state = state.copyWith(remoteUid: null);
          },
          onError: (ErrorCodeType err, String msg) {
            state = state.copyWith(error: msg);
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            state = state.copyWith(
              isConnected: false,
              remoteUid: null,
            );
          },
        ),
      );

      // Join channel
      await engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      state = state.copyWith(engine: engine);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> leaveCall() async {
    if (state.engine != null) {
      await state.engine!.leaveChannel();
      await state.engine!.release();
      state = VideoCallState();
    }
  }

  void toggleMute(bool muted) {
    if (state.engine != null) {
      state.engine!.muteLocalAudioStream(muted);
    }
  }

  void toggleVideo(bool enabled) {
    if (state.engine != null) {
      state.engine!.muteLocalVideoStream(!enabled);
      if (enabled) {
        state.engine!.startPreview();
      } else {
        state.engine!.stopPreview();
      }
    }
  }

  void toggleSpeaker(bool enabled) {
    if (state.engine != null) {
      state.engine!.setEnableSpeakerphone(enabled);
    }
  }

  @override
  void dispose() {
    leaveCall();
    super.dispose();
  }
}

