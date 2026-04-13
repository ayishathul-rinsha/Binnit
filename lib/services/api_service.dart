import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
}

/// Base API Service with mock responses
class ApiService {
  static String? _authToken;

  /// Set auth token for API calls
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear auth token on logout
  static void clearAuthToken() {
    _authToken = null;
  }

  /// Get headers with auth token
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Generic GET request
  static Future<ApiResponse<Map<String, dynamic>>> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Generic POST request
  static Future<ApiResponse<Map<String, dynamic>>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Generic PUT request
  static Future<ApiResponse<Map<String, dynamic>>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Generic DELETE request
  static Future<ApiResponse<Map<String, dynamic>>> delete(String url) async {
    try {
      final response = await http.delete(Uri.parse(url), headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Handle HTTP response
  static ApiResponse<Map<String, dynamic>> _handleResponse(
    http.Response response,
  ) {
    final statusCode = response.statusCode;
    Map<String, dynamic>? data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (e) {
      // Response is not JSON
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(success: true, data: data, statusCode: statusCode);
    } else {
      return ApiResponse(
        success: false,
        data: data,
        message: data?['message'] ?? 'Request failed',
        statusCode: statusCode,
      );
    }
  }
}
