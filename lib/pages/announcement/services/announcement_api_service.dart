import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/models/announcement.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

class AnnouncementApiService {
  static final AnnouncementApiService instance =
      AnnouncementApiService._internal();
  final Dio _dio = DioClient.instance;

  AnnouncementApiService._internal();

  /// Get all announcements
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      final response = await _dio.get(
        announcementEndpoint,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;

        if (jsonData['status'] == true && jsonData['data'] != null) {
          final List<dynamic> announcementsData = jsonData['data'];

          return announcementsData.map((announcementJson) {
            return Announcement.fromJson(announcementJson);
          }).toList();
        }

        return [];
      } else {
        throw ApiException(
          'Failed to load announcements: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      print('Error fetching announcements: $e');
      throw ApiException('Failed to fetch announcements: ${e.toString()}');
    }
  }

  /// Get announcement by ID
  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      final response = await _dio.get(
        '$announcementEndpoint/$id',
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;

        if (jsonData['status'] == true && jsonData['data'] != null) {
          return Announcement.fromJson(jsonData['data']);
        }

        return null;
      } else {
        throw ApiException(
          'Failed to load announcement: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      print('Error fetching announcement by ID: $e');
      return null;
    }
  }

  /// Create new announcement
  Future<Announcement> createAnnouncement({
    required String title,
    required String description,
    required String content,
    required DateTime date,
    List<String>? imageUrls,
    List<String>? pdfUrls,
    // required String sendTo,
    List<String>? selectedSocieties,
  }) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "title": title.trim(),
        "description": description.trim(),
        "content": content.trim(),
        "date": date.toIso8601String().split('T')[0], // YYYY-MM-DD format
        // "sendTo": sendTo,
      };

      // Add images if provided
      if (imageUrls != null && imageUrls.isNotEmpty) {
        requestBody["image"] = imageUrls;
      }

      // Add PDFs if provided
      if (pdfUrls != null && pdfUrls.isNotEmpty) {
        requestBody["pdf"] = pdfUrls;
      }

      // Add selected societies if sendTo is specific_society
      // if (sendTo == "specific_society" &&
      //     selectedSocieties != null &&
      //     selectedSocieties.isNotEmpty) {
      //   requestBody["selectedSocieties"] = selectedSocieties;
      // }

      final response = await _dio.post(
        announcementEndpoint,
        data: requestBody,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = response.data;

        if (jsonData['status'] == true && jsonData['data'] != null) {
          return Announcement.fromJson(jsonData['data']);
        } else {
          throw ApiException(
            jsonData['message'] ?? 'Failed to create announcement',
          );
        }
      } else {
        throw ApiException(
          'Failed to create announcement: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      print('Error creating announcement: $e');
      throw ApiException('Failed to create announcement: ${e.toString()}');
    }
  }

  /// Update announcement
  Future<Announcement> updateAnnouncement({
    required String id,
    required String title,
    required String description,
    required String content,
    required DateTime date,
    List<String>? imageUrls,
    List<String>? pdfUrls,
    required String sendTo,
    List<String>? selectedSocieties,
  }) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      final Map<String, dynamic> requestBody = {
        "title": title.trim(),
        "description": description.trim(),
        "content": content.trim(),
        "date": date.toIso8601String().split('T')[0],
        "sendTo": sendTo,
      };

      if (imageUrls != null && imageUrls.isNotEmpty) {
        requestBody["image"] = imageUrls;
      }

      if (pdfUrls != null && pdfUrls.isNotEmpty) {
        requestBody["pdf"] = pdfUrls;
      }

      if (sendTo == "specific_society" &&
          selectedSocieties != null &&
          selectedSocieties.isNotEmpty) {
        requestBody["selectedSocieties"] = selectedSocieties;
      }

      final response = await _dio.put(
        '$announcementEndpoint/$id',
        data: requestBody,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;

        if (jsonData['status'] == true && jsonData['data'] != null) {
          return Announcement.fromJson(jsonData['data']);
        } else {
          throw ApiException(
            jsonData['message'] ?? 'Failed to update announcement',
          );
        }
      } else {
        throw ApiException(
          'Failed to update announcement: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      print('Error updating announcement: $e');
      throw ApiException('Failed to update announcement: ${e.toString()}');
    }
  }

  /// Delete announcement
  Future<void> deleteAnnouncement(String id) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      final response = await _dio.delete(
        '$announcementEndpoint/$id',
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          'Failed to delete announcement: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      print('Error deleting announcement: $e');
      throw ApiException('Failed to delete announcement: ${e.toString()}');
    }
  }

  /// Upload a single file and return its public URL (as returned by the server).
  /// Assumes your backend upload endpoint returns something like { status: true, data: { url: "https://..." } }
  Future<String> uploadFile(File file) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await _dio.post(
        uploadEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final list = data['data'];

          if (list is List && list.isNotEmpty) {
            final first = list[0];

            if (first is Map<String, dynamic>) {
              final url = first['url'] ?? first['filePath'];
              if (url != null && url.toString().isNotEmpty) {
                return url.toString();
              }
            }
          }
        }

        throw ApiException('Invalid upload response format');
      }

      throw ApiException('Upload failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Helper method to handle Dio errors
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Connection timeout. Please check your internet connection.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          return AuthenticationException(
            _extractErrorMessage(data) ?? 'Authentication failed',
            statusCode: statusCode,
            originalError: error,
          );
        } else if (statusCode == 403) {
          return AuthorizationException(
            _extractErrorMessage(data) ?? 'Access denied',
            statusCode: statusCode,
            originalError: error,
          );
        } else if (statusCode == 400 || statusCode == 422) {
          return ValidationException(
            _extractErrorMessage(data) ?? 'Validation failed',
            errors: _extractErrors(data),
            statusCode: statusCode,
            originalError: error,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            _extractErrorMessage(data) ??
                'Server error. Please try again later.',
            statusCode: statusCode,
            originalError: error,
          );
        } else {
          return ApiException(
            _extractErrorMessage(data) ?? 'An error occurred',
            statusCode: statusCode,
            originalError: error,
          );
        }
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', originalError: error);
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') == true) {
          return NetworkException(
            'No internet connection. Please check your network settings.',
            originalError: error,
          );
        }
        return UnknownException(
          'An unexpected error occurred',
          originalError: error,
        );
      default:
        return UnknownException(
          'An unexpected error occurred: ${error.message}',
          originalError: error,
        );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

  Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['errors'] as Map<String, dynamic>?;
    }
    return null;
  }
}
