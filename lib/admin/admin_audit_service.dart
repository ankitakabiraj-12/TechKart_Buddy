import '../core/network/api_client.dart';

class AdminAuditService {
  static final ApiClient _apiClient = ApiClient();

  /// Retrieve paginated audit logs with action filters, date range, and metrics
  /// GET /api/v1/buddy/admin/audit-logs
  static Future<Map<String, dynamic>> getAuditLogs({
    int page = 1,
    int limit = 15,
    String? search,
    String? action,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (action != null && action.trim().isNotEmpty && action != 'all') {
      queryParams['action'] = action.trim();
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      queryParams['start_date'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      queryParams['end_date'] = endDate.trim();
    }

    final response = await _apiClient.get(
      '/buddy/admin/audit-logs',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch audit logs');
    }
  }
}
