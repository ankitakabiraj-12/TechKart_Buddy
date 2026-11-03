import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class AdminCustomerService {
  static final ApiClient _apiClient = ApiClient();

  /// Retrieve paginated customer directory with metrics, order summaries, and review statistics
  /// GET /api/v1/buddy/admin/customers
  static Future<Map<String, dynamic>?> getCustomersDirectory({
    String? search,
    String? status,
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

      final response = await _apiClient.get(
        '/buddy/admin/customers',
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

  /// Retrieve full customer profile details including address book, orders, and reviews
  /// GET /api/v1/buddy/admin/customers/{id}
  static Future<Map<String, dynamic>?> getCustomerDetails(int customerId) async {
    try {
      final response = await _apiClient.get('/buddy/admin/customers/$customerId');
      if (response.isSuccess && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Toggle or update customer active/suspended status
  /// PUT /api/v1/buddy/admin/customers/{id}/status
  static Future<ApiResponse> updateCustomerStatus({
    required int customerId,
    required bool isActive,
  }) async {
    try {
      final response = await _apiClient.put(
        '/buddy/admin/customers/$customerId/status',
        body: {'is_active': isActive ? 1 : 0},
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
