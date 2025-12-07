/// Video Call Provider
/// Riverpod providers for video call state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/video_call_service.dart';

final videoCallServiceProvider = Provider<VideoCallService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VideoCallService(apiClient);
});

