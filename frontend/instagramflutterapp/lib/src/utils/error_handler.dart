class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;
    if (error?.response?.data is Map) {
      final data = error.response.data as Map;
      final message = data['message'];
      if (message is String) return message;
      if (message is List) return message.join(', ');
    }

    // Add logic for common exceptions (e.g., DioException if using Dio)
    // For now, basic error message extraction
    try {
      if (error?.message != null) return error.message;
      if (error?.toString() != null) return error.toString();
    } catch (_) {}

    return 'An unexpected error occurred';
  }
}
