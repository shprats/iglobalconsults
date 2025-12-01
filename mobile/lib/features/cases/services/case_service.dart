/// Case Service
/// Handles case management operations

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/case.dart';
import '../../../core/config/app_config.dart';

class CaseService {
  final ApiClient _apiClient;

  CaseService(this._apiClient);

  /// Get list of cases
  Future<Map<String, dynamic>> getCases({
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
      throw Exception('Failed to fetch cases');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get case by ID
  Future<MedicalCase> getCaseById(String caseId) async {
    try {
      final response = await _apiClient.get('${AppConfig.casesBase}/$caseId');

      if (response.statusCode == 200) {
        return MedicalCase.fromJson(response.data);
      }
      throw Exception('Failed to fetch case');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new case
  Future<MedicalCase> createCase({
    required String title,
    required String chiefComplaint,
    required String urgency,
    String? description,
    String? patientHistory,
    String? currentMedications,
    String? allergies,
    String? vitalSigns,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.casesBase,
        data: {
          'title': title,
          'chief_complaint': chiefComplaint,
          'urgency': urgency,
          'description': description,
          'patient_history': patientHistory,
          'current_medications': currentMedications,
          'allergies': allergies,
          'vital_signs': vitalSigns,
        },
      );

      if (response.statusCode == 201) {
        return MedicalCase.fromJson(response.data);
      }
      throw Exception('Failed to create case');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update a case
  Future<MedicalCase> updateCase(
    String caseId, {
    String? title,
    String? chiefComplaint,
    String? urgency,
    String? status,
    String? description,
    String? patientHistory,
    String? currentMedications,
    String? allergies,
    String? vitalSigns,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (chiefComplaint != null) data['chief_complaint'] = chiefComplaint;
      if (urgency != null) data['urgency'] = urgency;
      if (status != null) data['status'] = status;
      if (description != null) data['description'] = description;
      if (patientHistory != null) data['patient_history'] = patientHistory;
      if (currentMedications != null) {
        data['current_medications'] = currentMedications;
      }
      if (allergies != null) data['allergies'] = allergies;
      if (vitalSigns != null) data['vital_signs'] = vitalSigns;

      final response = await _apiClient.put(
        '${AppConfig.casesBase}/$caseId',
        data: data,
      );

      if (response.statusCode == 200) {
        return MedicalCase.fromJson(response.data);
      }
      throw Exception('Failed to update case');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a case
  Future<void> deleteCase(String caseId) async {
    try {
      final response = await _apiClient.delete('${AppConfig.casesBase}/$caseId');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete case');
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

