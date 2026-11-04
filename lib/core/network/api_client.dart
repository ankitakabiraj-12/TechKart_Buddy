import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'token_storage.dart';

class ApiClient {
  final http.Client _httpClient;
  final TokenStorage _tokenStorage;
  final String _baseUrl;

  ApiClient({
    http.Client? httpClient,
    TokenStorage? tokenStorage,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  TokenStorage get tokenStorage => _tokenStorage;
  String get baseUrl => _baseUrl;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final base = _baseUrl.endsWith('/') ? _baseUrl : '$_baseUrl/';
    final fullUrl = '$base$cleanPath';

    final uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map((k, v) => MapEntry(k, v.toString()));
      return uri.replace(queryParameters: {...uri.queryParameters, ...stringParams});
    }
    return uri;
  }

  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? extraHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? connectTimeout,
    Duration? responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final finalHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

    return _executeRequest<T>(
      method: 'GET',
      uri: uri,
      headers: finalHeaders,
      connectTimeout: connectTimeout,
      responseTimeout: responseTimeout,
      fromJsonData: fromJsonData,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? connectTimeout,
    Duration? responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final finalHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

    return _executeRequest<T>(
      method: 'POST',
      uri: uri,
      headers: finalHeaders,
      body: body,
      connectTimeout: connectTimeout,
      responseTimeout: responseTimeout,
      fromJsonData: fromJsonData,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? connectTimeout,
    Duration? responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final finalHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

    return _executeRequest<T>(
      method: 'PUT',
      uri: uri,
      headers: finalHeaders,
      body: body,
      connectTimeout: connectTimeout,
      responseTimeout: responseTimeout,
      fromJsonData: fromJsonData,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? connectTimeout,
    Duration? responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final finalHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

    return _executeRequest<T>(
      method: 'PATCH',
      uri: uri,
      headers: finalHeaders,
      body: body,
      connectTimeout: connectTimeout,
      responseTimeout: responseTimeout,
      fromJsonData: fromJsonData,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? connectTimeout,
    Duration? responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final finalHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

    return _executeRequest<T>(
      method: 'DELETE',
      uri: uri,
      headers: finalHeaders,
      body: body,
      connectTimeout: connectTimeout,
      responseTimeout: responseTimeout,
      fromJsonData: fromJsonData,
    );
  }

  /// Sends a multipart form-data request (for image and file uploads).
  Future<ApiResponse<T>> multipartRequest<T>(
    String path, {
    String method = 'POST',
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration? connectTimeout,
    Duration? responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final authHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);
    // Remove JSON content-type to allow http package to set multipart boundary
    authHeaders.remove('Content-Type');

    final effectiveConnectTimeout = connectTimeout ?? ApiConfig.connectTimeout;
    final effectiveResponseTimeout = responseTimeout ?? ApiConfig.responseTimeout;

    try {
      final request = http.MultipartRequest(method, uri);
      request.headers.addAll(authHeaders);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        request.files.addAll(files);
      }

      final http.StreamedResponse streamedResponse = await _httpClient
          .send(request)
          .timeout(
            effectiveConnectTimeout,
            onTimeout: () => throw const ConnectionTimeoutException(),
          );

      final responseBody = await streamedResponse.stream
          .bytesToString()
          .timeout(
            effectiveResponseTimeout,
            onTimeout: () => throw const ResponseTimeoutException(),
          );

      final httpResponse = http.Response(
        responseBody,
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
      );

      return _handleResponse<T>(httpResponse, fromJsonData: fromJsonData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  /// Sends the HTTP request with separate connection and response timeouts.
  Future<ApiResponse<T>> _executeRequest<T>({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    dynamic body,
    Duration? connectTimeout,
    Duration? responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final effectiveConnectTimeout = connectTimeout ?? ApiConfig.connectTimeout;
    final effectiveResponseTimeout = responseTimeout ?? ApiConfig.responseTimeout;

    try {
      final request = http.Request(method, uri);
      request.headers.addAll(headers);

      if (body != null) {
        request.body = jsonEncode(body);
      }

      // Step 1: Enforce Connection Timeout during socket/handshake initiation
      final http.StreamedResponse streamedResponse = await _httpClient
          .send(request)
          .timeout(
            effectiveConnectTimeout,
            onTimeout: () => throw const ConnectionTimeoutException(),
          );

      // Step 2: Enforce Response Timeout during body streaming & reception
      final responseBody = await streamedResponse.stream
          .bytesToString()
          .timeout(
            effectiveResponseTimeout,
            onTimeout: () => throw const ResponseTimeoutException(),
          );

      final httpResponse = http.Response(
        responseBody,
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
        request: streamedResponse.request,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );

      return _handleResponse<T>(httpResponse, fromJsonData: fromJsonData);
    } on ConnectionTimeoutException {
      final fallback = await _tryLanFallback<T>(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
        connectTimeout: effectiveConnectTimeout,
        responseTimeout: effectiveResponseTimeout,
        fromJsonData: fromJsonData,
      );
      if (fallback != null) return fallback;
      rethrow;
    } on ResponseTimeoutException {
      rethrow;
    } on TimeoutException {
      final fallback = await _tryLanFallback<T>(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
        connectTimeout: effectiveConnectTimeout,
        responseTimeout: effectiveResponseTimeout,
        fromJsonData: fromJsonData,
      );
      if (fallback != null) return fallback;
      throw const ConnectionTimeoutException();
    } on SocketException {
      final fallback = await _tryLanFallback<T>(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
        connectTimeout: effectiveConnectTimeout,
        responseTimeout: effectiveResponseTimeout,
        fromJsonData: fromJsonData,
      );
      if (fallback != null) return fallback;
      throw const NetworkException();
    } on http.ClientException {
      final fallback = await _tryLanFallback<T>(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
        connectTimeout: effectiveConnectTimeout,
        responseTimeout: effectiveResponseTimeout,
        fromJsonData: fromJsonData,
      );
      if (fallback != null) return fallback;
      throw const NetworkException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response, {
    T Function(dynamic data)? fromJsonData,
  }) {
    final statusCode = response.statusCode;
    Map<String, dynamic> jsonBody = {};

    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          jsonBody = decoded;
        } else {
          jsonBody = {'data': decoded};
        }
      }
    } catch (_) {
      jsonBody = {'message': response.body};
    }

    final message = jsonBody['message'] as String? ?? 'Request failed';
    final errors = jsonBody['errors'] ?? jsonBody['error'];

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.fromJson(jsonBody, statusCode, fromJsonData: fromJsonData);
    }

    switch (statusCode) {
      case 400:
        throw ValidationException(message: message, details: errors);
      case 401:
        throw UnauthorizedException(message: message, details: errors);
      case 403:
        throw ForbiddenException(message: message, details: errors);
      case 404:
        throw NotFoundException(message: message, details: errors);
      case 422:
        throw ValidationException(message: message, details: errors);
      case 500:
      default:
        throw ServerException(message: message, statusCode: statusCode, details: errors);
    }
  }

  Future<ApiResponse<T>?> _tryLanFallback<T>({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    dynamic body,
    required Duration connectTimeout,
    required Duration responseTimeout,
    T Function(dynamic data)? fromJsonData,
  }) async {
    final usesLoopback =
        _baseUrl.contains('127.0.0.1') || _baseUrl.contains('localhost');
    if (!Platform.isAndroid || !usesLoopback) return null;

    try {
      final fallbackUri = Uri.parse(
        uri.toString().replaceFirst(_baseUrl, ApiConfig.fallbackBaseUrl),
      );
      final request = http.Request(method, fallbackUri);
      request.headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);

      final streamedResponse = await _httpClient
          .send(request)
          .timeout(connectTimeout);
      final responseBody = await streamedResponse.stream
          .bytesToString()
          .timeout(responseTimeout);
      final response = http.Response(
        responseBody,
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
        request: streamedResponse.request,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );

      ApiConfig.baseUrl = ApiConfig.fallbackBaseUrl;
      return _handleResponse<T>(response, fromJsonData: fromJsonData);
    } on ApiException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  void close() {
    _httpClient.close();
  }
}
