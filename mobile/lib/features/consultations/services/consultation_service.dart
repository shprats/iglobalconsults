/// Consultation Service
/// Handles consultation operations

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';

class ConsultationService {
  final ApiClient _apiClient;

  ConsultationService(this._apiClient);

  /// Get list of consultations
  Future<Map<String, dynamic>> getConsultations({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        AppConfig.consultationsBase,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'consultations': data['consultations'] as List,
          'total': data['total'] as int,
          'page': data['page'] as int,
          'page_size': data['page_size'] as int,
        };
      }
      throw Exception('Failed to fetch consultations');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get consultation by ID
  Future<Map<String, dynamic>> getConsultationById(String consultationId) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.consultationsBase}/$consultationId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch consultation');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Start a consultation and get Agora token
  Future<Map<String, dynamic>> startConsultation(String consultationId) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.consultationsBase}/$consultationId/start',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // The backend returns agora_token and agora_channel_name in the response
        return data;
      }
      throw Exception('Failed to start consultation');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// End a consultation
  Future<Map<String, dynamic>> endConsultation(
    String consultationId, {
    String? diagnosis,
    String? treatmentPlan,
    String? volunteerNotes,
    bool? followUpRequired,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (diagnosis != null) data['diagnosis'] = diagnosis;
      if (treatmentPlan != null) data['treatment_plan'] = treatmentPlan;
      if (volunteerNotes != null) data['volunteer_notes'] = volunteerNotes;
      if (followUpRequired != null) data['follow_up_required'] = followUpRequired;

      final response = await _apiClient.post(
        '${AppConfig.consultationsBase}/$consultationId/end',
        data: data.isEmpty ? null : data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to end consultation');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update consultation
  Future<Map<String, dynamic>> updateConsultation(
    String consultationId, {
    String? diagnosis,
    String? treatmentPlan,
    String? volunteerNotes,
    bool? followUpRequired,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (diagnosis != null) data['diagnosis'] = diagnosis;
      if (treatmentPlan != null) data['treatment_plan'] = treatmentPlan;
      if (volunteerNotes != null) data['volunteer_notes'] = volunteerNotes;
      if (followUpRequired != null) data['follow_up_required'] = followUpRequired;

      final response = await _apiClient.put(
        '${AppConfig.consultationsBase}/$consultationId',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to update consultation');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get upcoming consultations
  Future<List<Map<String, dynamic>>> getUpcomingConsultations({
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.consultationsBase}/upcoming/list',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      }
      throw Exception('Failed to fetch upcoming consultations');
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

