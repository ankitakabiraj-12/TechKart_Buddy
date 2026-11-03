class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;
  final dynamic errors;

  bool get isSuccess => success;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode, {
    T Function(dynamic data)? fromJsonData,
  }) {
    final success = json['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);
    final message = json['message'] as String? ?? '';
    final rawData = json['data'];

    T? parsedData;
    if (rawData != null && fromJsonData != null) {
      parsedData = fromJsonData(rawData);
    } else if (rawData != null) {
      parsedData = rawData as T?;
    }

    return ApiResponse<T>(
      success: success,
      message: message,
      data: parsedData,
      statusCode: statusCode,
      errors: json['errors'] ?? json['error'],
    );
  }
}
