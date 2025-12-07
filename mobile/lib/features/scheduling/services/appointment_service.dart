/// Appointment Service
/// Handles appointment slot operations for doctors

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';

class AppointmentService {
  final ApiClient _apiClient;

  AppointmentService(this._apiClient);

  /// Get available appointment slots
  Future<Map<String, dynamic>> getAvailableSlots({
    String? volunteerId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (volunteerId != null) {
        queryParams['volunteer_id'] = volunteerId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '${AppConfig.schedulingBase}/slots',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'slots': data['slots'] as List,
          'total': data['total'] as int,
          'page': data['page'] as int,
          'page_size': data['page_size'] as int,
        };
      }
      throw Exception('Failed to fetch available slots');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Book an appointment
  Future<Map<String, dynamic>> bookAppointment({
    required String slotId,
    required String caseId,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.schedulingBase}/appointments',
        data: {
          'slot_id': slotId,
          'case_id': caseId,
        },
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to book appointment');
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

