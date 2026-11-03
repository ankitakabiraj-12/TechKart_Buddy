import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class AdminPaymentService {
  static final ApiClient _apiClient = ApiClient();

  /// Retrieve live platform sales & revenue analytics
  /// GET /api/v1/buddy/admin/reports/sales-revenue
  static Future<Map<String, dynamic>?> getSalesRevenueReport({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await _apiClient.get(
        '/buddy/admin/reports/sales-revenue',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.isSuccess && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Retrieve paginated settlement dossiers from MariaDB
  /// GET /api/v1/buddy/admin/settlements
  static Future<Map<String, dynamic>?> getSettlements({
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (status != null && status.trim().isNotEmpty && status != 'all') {
        queryParams['status'] = status.trim().toLowerCase();
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await _apiClient.get(
        '/buddy/admin/settlements',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Release/Authorize a settlement dossier payout
  /// PUT /api/v1/buddy/admin/settlements/{id}/release
  static Future<ApiResponse> releaseSettlement(int settlementId) async {
    try {
      final response = await _apiClient.put(
        '/buddy/admin/settlements/$settlementId/release',
      );
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
