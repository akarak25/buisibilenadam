import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/models/auth_response.dart';
import 'package:palm_analysis/models/query.dart';
import 'package:palm_analysis/services/token_service.dart';

/// Main API service for elcizgisi.com backend
class ApiService {
  final TokenService _tokenService = TokenService();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Make a GET request
  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    final response = await http
        .get(uri, headers: headers)
        .timeout(ApiConfig.connectionTimeout);

    return response;
  }

  /// Make a POST request with JSON body
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    final response = await http
        .post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.connectionTimeout);

    return response;
  }

  /// Make a PUT request with JSON body
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    final response = await http
        .put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.connectionTimeout);

    return response;
  }

  /// Make a DELETE request
  Future<http.Response> delete(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth);

    final response = await http
        .delete(uri, headers: headers)
        .timeout(ApiConfig.connectionTimeout);

    return response;
  }

  /// Upload image for palm analysis
  Future<AnalysisResponse> analyzeImage(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.analyzeEndpoint}');
    final token = await _tokenService.getToken();

    final request = http.MultipartRequest('POST', uri);

    // Add auth header if user is logged in
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add image file with proper content type
    final mimeType = _getMimeType(imageFile.path);
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);
      return AnalysisResponse.fromJson(data);
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Save query to database (after analysis)
  Future<Query?> saveQuery({
    required String imageUrl,
    required String question,
    required String response,
  }) async {
    try {
      final result = await post(
        ApiConfig.queriesEndpoint,
        body: {
          'imageUrl': imageUrl,
          'question': question,
          'response': response,
        },
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        final jsonBody = utf8.decode(result.bodyBytes);
        final data = jsonDecode(jsonBody);
        return Query.fromJson(data);
      } else {
        print('Query save failed: ${result.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error saving query: $e');
      return null;
    }
  }

  /// Get all queries for current user
  Future<List<Query>> getQueries() async {
    final response = await get(ApiConfig.queriesEndpoint);

    if (response.statusCode == 200) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);

      if (data is List) {
        return data.map((e) => Query.fromJson(e)).toList();
      } else if (data['queries'] is List) {
        return (data['queries'] as List).map((e) => Query.fromJson(e)).toList();
      }
      return [];
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Get a single query by ID
  Future<Query> getQuery(String queryId) async {
    final response = await get('${ApiConfig.queriesEndpoint}/$queryId');

    if (response.statusCode == 200) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);
      return Query.fromJson(data);
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Delete a query
  Future<void> deleteQuery(String queryId) async {
    final response = await delete('${ApiConfig.queriesEndpoint}/$queryId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Toggle query favorite status
  Future<Query> toggleFavorite(String queryId) async {
    final response = await put('${ApiConfig.queriesEndpoint}/$queryId/favorite');

    if (response.statusCode == 200) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);
      return Query.fromJson(data);
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Get headers with optional auth token
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (requiresAuth) {
      final token = await _tokenService.getToken();
      if (token != null) {
        return ApiConfig.authHeaders(token);
      }
    }
    return ApiConfig.defaultHeaders;
  }

  /// Get MIME type from file path
  String _getMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.png')) {
      return 'image/png';
    } else if (ext.endsWith('.webp')) {
      return 'image/webp';
    } else if (ext.endsWith('.gif')) {
      return 'image/gif';
    } else if (ext.endsWith('.heic') || ext.endsWith('.heif')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }
}
