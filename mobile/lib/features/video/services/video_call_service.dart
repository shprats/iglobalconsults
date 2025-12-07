/// Video Call Service
/// Handles Agora video call operations

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';

class VideoCallService {
  final ApiClient _apiClient;

  VideoCallService(this._apiClient);

  /// Get Agora token for a consultation
  /// This is called when starting a consultation
  Future<Map<String, dynamic>> getAgoraToken(String consultationId) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.consultationsBase}/$consultationId/start',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'agora_token': data['agora_token'] as String,
          'agora_channel_name': data['agora_channel_name'] as String,
          'agora_app_id': data['agora_app_id'] as String,
        };
      }
      throw Exception('Failed to get Agora token');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Error: ${error.response?.statusCode}';
    }
    return error.message ?? 'Network error';
  }
}

