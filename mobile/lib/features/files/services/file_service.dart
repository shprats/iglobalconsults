/// File Service
/// Handles file upload and management

import 'package:dio/dio.dart';
import 'package:tus_client/tus_client.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';
import 'dart:io';

class FileService {
  final ApiClient _apiClient;

  FileService(this._apiClient);

  /// Create TUS upload session
  Future<String> createUploadSession({
    required int fileSize,
    required String fileName,
    required String fileType,
    required String caseId,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.filesBase}/upload',
        options: Options(
          headers: {
            'Upload-Length': fileSize.toString(),
            'Upload-Metadata': _encodeMetadata({
              'filename': fileName,
              'filetype': fileType,
              'case_id': caseId,
            }),
          },
        ),
      );

      if (response.statusCode == 201) {
        final location = response.headers.value('location');
        if (location != null) {
          // Extract upload ID from location
          final parts = location.split('/');
          return parts.last;
        }
        throw Exception('No location header in response');
      }
      throw Exception('Failed to create upload session');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file using TUS protocol
  Future<void> uploadFile({
    required String uploadId,
    required File file,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();
      final fileSize = fileBytes.length;
      int offset = 0;
      const chunkSize = 1024 * 1024; // 1MB chunks

      while (offset < fileSize) {
        final end = (offset + chunkSize < fileSize)
            ? offset + chunkSize
            : fileSize;
        final chunk = fileBytes.sublist(offset, end);

        final response = await _apiClient.patch(
          '${AppConfig.filesBase}/upload/$uploadId',
          data: chunk,
          options: Options(
            headers: {
              'Upload-Offset': offset.toString(),
              'Content-Type': 'application/offset+octet-stream',
            },
          ),
        );

        if (response.statusCode == 204) {
          final newOffset = int.tryParse(
                response.headers.value('upload-offset') ?? '0',
              ) ??
              0;
          offset = newOffset;
          onProgress?.call(offset, fileSize);
        } else {
          throw Exception('Upload failed');
        }
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get files for a case
  Future<List<Map<String, dynamic>>> getCaseFiles(String caseId) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.filesBase}/case/$caseId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      }
      throw Exception('Failed to fetch files');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _encodeMetadata(Map<String, String> metadata) {
    return metadata.entries
        .map((e) => '${e.key} ${_base64Encode(e.value)}')
        .join(',');
  }

  String _base64Encode(String value) {
    // Simple base64 encoding
    return Uri.encodeComponent(value);
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

