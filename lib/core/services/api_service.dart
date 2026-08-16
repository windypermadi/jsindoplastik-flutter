import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.statusCode = 200,
  });
}

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<ApiResponse<dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          isSuccess: true,
          message: body['message'] ?? 'Berhasil',
          data: body['data'] ?? body['content'] ?? body,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: body['message'] ?? 'Gagal memuat data dari server',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Koneksi ke server gagal: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          isSuccess: true,
          message: body['message'] ?? 'Berhasil disimpan',
          data: body['data'] ?? body['content'] ?? body,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: body['message'] ?? 'Gagal memproses data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Koneksi ke server gagal: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          isSuccess: true,
          message: body['message'] ?? 'Berhasil diperbarui',
          data: body['data'] ?? body['content'] ?? body,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: body['message'] ?? 'Gagal memperbarui data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Koneksi ke server gagal: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse(endpoint), headers: headers)
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          isSuccess: true,
          message: body['message'] ?? 'Berhasil dihapus',
          data: body['data'] ?? body['content'] ?? body,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          isSuccess: false,
          message: body['message'] ?? 'Gagal menghapus data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Koneksi ke server gagal: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
