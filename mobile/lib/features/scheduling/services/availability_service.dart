/// Availability Service
/// Handles availability block operations for volunteers

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';

class AvailabilityService {
  final ApiClient _apiClient;

  AvailabilityService(this._apiClient);

  /// Create a new availability block
  Future<Map<String, dynamic>> createAvailabilityBlock({
    required DateTime startTime,
    required DateTime endTime,
    required String timezone,
    int slotDurationMinutes = 10,
    bool isRecurring = false,
    Map<String, dynamic>? recurrencePattern,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.schedulingBase}/availability',
        data: {
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'timezone': timezone,
          'slot_duration_minutes': slotDurationMinutes,
          'is_recurring': isRecurring,
          if (recurrencePattern != null) 'recurrence_pattern': recurrencePattern,
        },
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to create availability block');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get list of availability blocks
  Future<List<Map<String, dynamic>>> getAvailabilityBlocks() async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.schedulingBase}/availability',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      }
      throw Exception('Failed to fetch availability blocks');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an availability block
  Future<Map<String, dynamic>> updateAvailabilityBlock({
    required String blockId,
    required DateTime startTime,
    required DateTime endTime,
    required String timezone,
    int slotDurationMinutes = 10,
    bool isRecurring = false,
    Map<String, dynamic>? recurrencePattern,
  }) async {
    try {
      final response = await _apiClient.put(
        '${AppConfig.schedulingBase}/availability/$blockId',
        data: {
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'timezone': timezone,
          'slot_duration_minutes': slotDurationMinutes,
          'is_recurring': isRecurring,
          if (recurrencePattern != null) 'recurrence_pattern': recurrencePattern,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to update availability block');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete an availability block
  Future<void> deleteAvailabilityBlock(String blockId) async {
    try {
      final response = await _apiClient.delete(
        '${AppConfig.schedulingBase}/availability/$blockId',
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete availability block');
      }
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

