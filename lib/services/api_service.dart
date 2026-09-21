import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hydroalert_reports/core/constants/app_constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}

class ApiService {
  String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConstants.baseUrl,
        _client = client ?? http.Client();

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$cleanBase$cleanEndpoint';
    final uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return uri;
  }

  Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String errorMessage = 'HTTP error ${response.statusCode}';
    if (body is Map) {
      if (body.containsKey('detail')) {
        errorMessage = body['detail'].toString();
      } else if (body.containsKey('message')) {
        errorMessage = body['message'].toString();
      } else if (body.containsKey('error')) {
        errorMessage = body['error'].toString();
      }
    } else if (body is String && body.isNotEmpty) {
      errorMessage = body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      details: body,
    );
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client.get(
        uri,
        headers: _buildHeaders(headers),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Network connection error: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'HTTP Client Exception: ${e.message}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      String? encodedBody;
      if (body != null) {
        encodedBody = body is String ? body : jsonEncode(body);
      }
      final response = await _client.post(
        uri,
        headers: _buildHeaders(headers),
        body: encodedBody,
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Network connection error: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'HTTP Client Exception: ${e.message}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      String? encodedBody;
      if (body != null) {
        encodedBody = body is String ? body : jsonEncode(body);
      }
      final response = await _client.patch(
        uri,
        headers: _buildHeaders(headers),
        body: encodedBody,
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Network connection error: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'HTTP Client Exception: ${e.message}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      String? encodedBody;
      if (body != null) {
        encodedBody = body is String ? body : jsonEncode(body);
      }
      final response = await _client.put(
        uri,
        headers: _buildHeaders(headers),
        body: encodedBody,
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Network connection error: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'HTTP Client Exception: ${e.message}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client.delete(
        uri,
        headers: _buildHeaders(headers),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 503,
        message: 'Network connection error: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'HTTP Client Exception: ${e.message}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  void close() {
    _client.close();
  }
}
