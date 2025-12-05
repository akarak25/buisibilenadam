import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/models/auth_response.dart';
import 'package:palm_analysis/models/query.dart';
import 'package:palm_analysis/services/token_service.dart';

/// Custom exception for compatibility analysis errors
class CompatibilityException implements Exception {
  final String message;
  final String errorCode;
  final bool isSamePerson;

  CompatibilityException(
    this.message, {
    required this.errorCode,
    this.isSamePerson = false,
  });

  @override
  String toString() => message;
}

/// Custom exception for evolution analysis errors
class EvolutionException implements Exception {
  final String message;
  final String errorCode;
  final bool isDifferentPerson;

  EvolutionException(
    this.message, {
    required this.errorCode,
    this.isDifferentPerson = false,
  });

  @override
  String toString() => message;
}

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
  /// [language] should be 'tr' for Turkish or 'en' for English
  Future<AnalysisResponse> analyzeImage(File imageFile, {String language = 'tr'}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.analyzeEndpoint}');
    final token = await _tokenService.getToken();

    final request = http.MultipartRequest('POST', uri);

    // Add auth header if user is logged in
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add language field
    request.fields['language'] = language;

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
        debugPrint('Query save failed: ${result.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error saving query: $e');
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
    final response = await delete('${ApiConfig.queriesEndpoint}?id=$queryId');

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

  /// Send chat message with analysis context
  Future<String> sendChatMessage({
    required String message,
    required String analysisContext,
    String? queryId,
    String language = 'tr',
  }) async {
    try {
      final response = await post(
        ApiConfig.chatEndpoint,
        body: {
          'message': message,
          'analysisContext': analysisContext,
          'language': language,
          if (queryId != null) 'queryId': queryId,
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(jsonBody);
        return data['response'] ?? data['message'] ?? '';
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        final errorData = jsonDecode(errorBody);
        throw ApiError.fromJson(errorData, response.statusCode);
      }
    } catch (e) {
      debugPrint('Chat error: $e');
      rethrow;
    }
  }

  /// Compress and encode image to Base64 for API
  /// Max dimension: 1024px, Quality: 75%
  Future<String> _compressAndEncodeImage(File imageFile) async {
    try {
      // Read file as bytes
      final Uint8List originalBytes = await imageFile.readAsBytes();

      // Compress the image
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: 1024,
        minHeight: 1024,
        quality: 75,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null || compressedBytes.isEmpty) {
        // Fallback to original if compression fails
        debugPrint('Image compression failed, using original');
        final base64 = base64Encode(originalBytes);
        return 'data:image/jpeg;base64,$base64';
      }

      debugPrint('Image compressed: ${originalBytes.length} -> ${compressedBytes.length} bytes');

      // Convert to Base64 with data URL prefix
      final base64 = base64Encode(compressedBytes);
      return 'data:image/jpeg;base64,$base64';
    } catch (e) {
      debugPrint('Image compression error: $e');
      // Fallback: read and encode original
      final bytes = await imageFile.readAsBytes();
      final base64 = base64Encode(bytes);
      final mimeType = _getMimeType(imageFile.path);
      return 'data:$mimeType;base64,$base64';
    }
  }

  /// Analyze compatibility between two palm images (Visual Comparison)
  /// Uses Gemini multimodal to analyze both images simultaneously
  /// Throws CompatibilityException if same person detected or other errors
  Future<String> analyzeCompatibility({
    required File image1File,
    required File image2File,
    String language = 'tr',
  }) async {
    try {
      // Compress and encode both images
      debugPrint('Compressing images for compatibility analysis...');
      final image1Base64 = await _compressAndEncodeImage(image1File);
      final image2Base64 = await _compressAndEncodeImage(image2File);

      final response = await post(
        ApiConfig.compatibilityEndpoint,
        body: {
          'image1Base64': image1Base64,
          'image2Base64': image2Base64,
          'language': language,
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(jsonBody);
        return data['compatibility'] ?? data['result'] ?? data['response'] ?? '';
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        final errorData = jsonDecode(errorBody);

        // Check for specific error codes
        final errorCode = errorData['errorCode'] ?? 'UNKNOWN_ERROR';
        final isSamePerson = errorData['isSamePerson'] == true;
        final errorMessage = errorData['error'] ?? 'Analysis failed';

        throw CompatibilityException(
          errorMessage,
          errorCode: errorCode,
          isSamePerson: isSamePerson,
        );
      }
    } on CompatibilityException {
      rethrow;
    } catch (e) {
      debugPrint('Compatibility analysis error: $e');
      if (e is ApiError) {
        throw CompatibilityException(
          e.error,
          errorCode: 'API_ERROR',
        );
      }
      throw CompatibilityException(
        e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Analyze evolution of palm lines over time (Visual Comparison)
  /// Uses Gemini multimodal to compare palm images from different dates
  /// Throws EvolutionException if different person detected or other errors
  Future<String> analyzeEvolution({
    required File olderImageFile,
    required File newerImageFile,
    required String olderDate,
    required String newerDate,
    String language = 'tr',
  }) async {
    try {
      // Compress and encode both images
      debugPrint('Compressing images for evolution analysis...');
      final olderImageBase64 = await _compressAndEncodeImage(olderImageFile);
      final newerImageBase64 = await _compressAndEncodeImage(newerImageFile);

      final response = await post(
        ApiConfig.evolutionEndpoint,
        body: {
          'olderImageBase64': olderImageBase64,
          'newerImageBase64': newerImageBase64,
          'olderDate': olderDate,
          'newerDate': newerDate,
          'language': language,
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(jsonBody);
        return data['evolution'] ?? data['result'] ?? data['response'] ?? '';
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        final errorData = jsonDecode(errorBody);

        // Check for specific error codes
        final errorCode = errorData['errorCode'] ?? 'UNKNOWN_ERROR';
        final isDifferentPerson = errorData['isDifferentPerson'] == true;
        final errorMessage = errorData['error'] ?? 'Analysis failed';

        throw EvolutionException(
          errorMessage,
          errorCode: errorCode,
          isDifferentPerson: isDifferentPerson,
        );
      }
    } on EvolutionException {
      rethrow;
    } catch (e) {
      debugPrint('Evolution analysis error: $e');
      if (e is ApiError) {
        throw EvolutionException(
          e.error,
          errorCode: 'API_ERROR',
        );
      }
      throw EvolutionException(
        e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
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
