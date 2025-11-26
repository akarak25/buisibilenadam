import 'user.dart';

/// Authentication response from login/register endpoints
class AuthResponse {
  final User user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'] ?? '',
    );
  }
}

/// Analysis response from /api/analyze endpoint
class AnalysisResponse {
  final String analysis;
  final bool isPremium;
  final String imageDetail;
  final TokenUsage? tokenUsage;

  AnalysisResponse({
    required this.analysis,
    required this.isPremium,
    required this.imageDetail,
    this.tokenUsage,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      analysis: json['analysis'] ?? '',
      isPremium: json['isPremium'] ?? false,
      imageDetail: json['imageDetail'] ?? 'low',
      tokenUsage: json['tokenUsage'] != null
          ? TokenUsage.fromJson(json['tokenUsage'])
          : null,
    );
  }
}

/// Token usage info from OpenAI API
class TokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      promptTokens: json['prompt_tokens'] ?? 0,
      completionTokens: json['completion_tokens'] ?? 0,
      totalTokens: json['total_tokens'] ?? 0,
    );
  }
}

/// API error response
class ApiError {
  final String error;
  final String? details;
  final int statusCode;

  ApiError({
    required this.error,
    this.details,
    this.statusCode = 500,
  });

  factory ApiError.fromJson(Map<String, dynamic> json, int statusCode) {
    return ApiError(
      error: json['error'] ?? 'Bilinmeyen hata',
      details: json['details'],
      statusCode: statusCode,
    );
  }

  @override
  String toString() => error;
}
