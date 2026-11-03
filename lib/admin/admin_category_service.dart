import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class AdminCategoryService {
  static final ApiClient _apiClient = ApiClient();

  /// Retrieve paginated categories directory with metrics, product counts, and subcategories
  /// GET /api/v1/buddy/admin/categories
  static Future<Map<String, dynamic>?> getCategories({
    String? search,
    String? status,
    String? parentId,
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

      if (parentId != null && parentId.trim().isNotEmpty) {
        queryParams['parent_id'] = parentId.trim();
      }

      final response = await _apiClient.get(
        '/buddy/admin/categories',
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

  /// Create a new category node
  /// POST /api/v1/buddy/admin/categories
  static Future<ApiResponse> createCategory({
    required String name,
    String? slug,
    int? parentId,
    String? imageUrl,
    bool isActive = true,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name.trim(),
        'is_active': isActive ? 1 : 0,
      };
      if (slug != null && slug.trim().isNotEmpty) {
        body['slug'] = slug.trim();
      }
      if (parentId != null && parentId > 0) {
        body['parent_id'] = parentId;
      }
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        body['image_url'] = imageUrl.trim();
      }

      final response = await _apiClient.post(
        '/buddy/admin/categories',
        body: body,
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

  /// Update an existing category
  /// PUT /api/v1/buddy/admin/categories/{id}
  static Future<ApiResponse> updateCategory({
    required int id,
    required String name,
    String? slug,
    int? parentId,
    String? imageUrl,
    required bool isActive,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name.trim(),
        'is_active': isActive ? 1 : 0,
        'parent_id': parentId,
      };
      if (slug != null && slug.trim().isNotEmpty) {
        body['slug'] = slug.trim();
      }
      if (imageUrl != null) {
        body['image_url'] = imageUrl.trim();
      }

      final response = await _apiClient.put(
        '/buddy/admin/categories/$id',
        body: body,
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

  /// Delete a category
  /// DELETE /api/v1/buddy/admin/categories/{id}
  static Future<ApiResponse> deleteCategory(int id) async {
    try {
      final response = await _apiClient.delete(
        '/buddy/admin/categories/$id',
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
