import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class SellerProfileService {
  static final ApiClient _apiClient = ApiClient();

  /// Fetch seller profile and store details from live API
  /// GET /buddy/seller/profile
  static Future<Map<String, dynamic>?> getProfile({int? sellerId}) async {
    try {
      final queryParams = sellerId != null ? {'seller_id': sellerId} : null;
      final response = await _apiClient.get(
        '/buddy/seller/profile',
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

  /// Update seller profile contact and store details
  /// PUT /buddy/seller/profile
  static Future<ApiResponse> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? storeName,
    String? gstNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    int? sellerId,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (storeName != null) body['store_name'] = storeName;
    if (gstNumber != null) body['gst_number'] = gstNumber;
    if (address != null) body['address'] = address;
    if (city != null) body['city'] = city;
    if (state != null) body['state'] = state;
    if (pincode != null) body['pincode'] = pincode;
    if (sellerId != null) body['seller_id'] = sellerId;

    return await _apiClient.put(
      '/buddy/seller/profile',
      body: body,
    );
  }

  /// Admin: Fetch registered merchants directory
  /// GET /buddy/admin/sellers
  static Future<Map<String, dynamic>?> getSellersDirectory({
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
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _apiClient.get(
        '/buddy/admin/sellers',
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

  /// Admin: Update merchant verification status
  /// PUT /buddy/admin/sellers/{id}/verification
  static Future<ApiResponse> updateVerificationStatus(int sellerId, bool isVerified, {String? notes}) async {
    final body = <String, dynamic>{
      'is_verified': isVerified ? 1 : 0,
    };
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }
    return await _apiClient.put(
      '/buddy/admin/sellers/$sellerId/verification',
      body: body,
    );
  }
}
