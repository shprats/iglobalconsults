/// Available Cases Service
/// Handles viewing and accepting cases for volunteers

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/case.dart';
import '../../../core/config/app_config.dart';

class AvailableCasesService {
  final ApiClient _apiClient;

  AvailableCasesService(this._apiClient);

  /// Get cases available for volunteers (pending cases)
  Future<Map<String, dynamic>> getAvailableCases({
    int page = 1,
    int pageSize = 20,
    String? urgency,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'status': 'pending', // Only show pending cases
      };
      if (urgency != null) {
        queryParams['urgency'] = urgency;
      }

      final response = await _apiClient.get(
        AppConfig.casesBase,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final cases = (data['cases'] as List)
            .map((json) => MedicalCase.fromJson(json))
            .toList();

        return {
          'cases': cases,
          'total': data['total'] as int,
          'page': data['page'] as int,
          'page_size': data['page_size'] as int,
        };
      }
      throw Exception('Failed to fetch available cases');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Accept/assign a case (create consultation)
  Future<Map<String, dynamic>> acceptCase({
    required String caseId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.consultationsBase,
        data: {
          'case_id': caseId,
          'scheduled_start': scheduledStart.toIso8601String(),
          'scheduled_end': scheduledEnd.toIso8601String(),
        },
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to accept case');
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

