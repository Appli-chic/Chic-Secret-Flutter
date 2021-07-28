class ApiError {
  final String code;
  final dynamic message;

  ApiError({
    required this.code,
    required this.message,
  });

  /// Transform a JSON error into an [ApiError]
  factory ApiError.fromJson(Map<String, dynamic> jsonMap) {
    return new ApiError(
      code: jsonMap["code"],
      message: jsonMap["error"],
    );
  }
}
