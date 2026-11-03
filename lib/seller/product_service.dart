import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class ProductService {
  static final ApiClient _apiClient = ApiClient();

  /// Create a new product for the authenticated seller (or specified seller if admin)
  /// POST /buddy/products
  static Future<ApiResponse> addProduct({
    required String title,
    int? categoryId,
    int? subcategoryId,
    String? description,
    Map<String, dynamic>? specifications,
    required double price,
    double? mrp,
    int stockQuantity = 0,
    String status = 'published',
    List<dynamic>? images,
    int? sellerId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'price': price,
      'stock_quantity': stockQuantity,
      'status': status,
    };

    if (categoryId != null) {
      body['category_id'] = categoryId;
    }
    if (subcategoryId != null) {
      body['subcategory_id'] = subcategoryId;
    }
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (specifications != null && specifications.isNotEmpty) {
      body['specifications'] = specifications;
    }
    if (mrp != null) {
      body['mrp'] = mrp;
    }
    if (images != null && images.isNotEmpty) {
      body['images'] = images;
    }
    if (sellerId != null) {
      body['seller_id'] = sellerId;
    }

    return await _apiClient.post(
      '/buddy/products',
      body: body,
    );
  }

  /// Get seller products list
  /// GET /buddy/products
  static Future<Map<String, dynamic>?> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    int? sellerId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (sellerId != null) queryParams['seller_id'] = sellerId;

      final res = await _apiClient.get(
        '/buddy/products',
        queryParameters: queryParams,
      );
      if (res.isSuccess && res.data != null) {
        return res.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get single product details
  /// GET /buddy/products/{id}
  static Future<Map<String, dynamic>?> getProduct(int productId) async {
    try {
      final res = await _apiClient.get('/buddy/products/$productId');
      if (res.isSuccess && res.data != null) {
        return res.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Update existing product
  /// PUT /buddy/products/{id}
  static Future<ApiResponse> updateProduct(
    int productId, {
    String? title,
    int? categoryId,
    int? subcategoryId,
    String? description,
    Map<String, dynamic>? specifications,
    double? price,
    double? mrp,
    int? stockQuantity,
    String? status,
    List<dynamic>? images,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (categoryId != null) body['category_id'] = categoryId;
    if (subcategoryId != null) body['subcategory_id'] = subcategoryId;
    if (description != null) body['description'] = description;
    if (specifications != null) body['specifications'] = specifications;
    if (price != null) body['price'] = price;
    if (mrp != null) body['mrp'] = mrp;
    if (stockQuantity != null) body['stock_quantity'] = stockQuantity;
    if (status != null) body['status'] = status;
    if (images != null) body['images'] = images;

    return await _apiClient.put(
      '/buddy/products/$productId',
      body: body,
    );
  }

  /// Delete / Archive existing product
  /// DELETE /buddy/products/{id}
  static Future<ApiResponse> deleteProduct(int productId) async {
    return await _apiClient.delete('/buddy/products/$productId');
  }

  /// Admin review action on a product (Approve, Reject, or Publish)
  /// POST /buddy/products/{id}/review
  static Future<ApiResponse> reviewProduct(
    int productId, {
    required String action, // 'approve' | 'reject' | 'publish'
    String? notes,
    bool autoPublish = false,
  }) async {
    final payload = <String, dynamic>{
      'action': action,
      'auto_publish': autoPublish,
    };
    if (notes != null) {
      payload['notes'] = notes;
    }
    return await _apiClient.post(
      '/buddy/products/$productId/review',
      body: payload,
    );
  }

  /// Upload product images via multipart/form-data
  /// POST /buddy/products/upload-image OR POST /buddy/products/{id}/images
  static Future<ApiResponse> uploadProductImages({
    int? productId,
    required List<List<int>> fileBytesList,
    required List<String> fileNames,
    bool isPrimary = true,
  }) async {
    final path = (productId != null && productId > 0)
        ? '/buddy/products/$productId/images'
        : '/buddy/products/upload-image';

    final multipartFiles = <http.MultipartFile>[];
    for (int i = 0; i < fileBytesList.length; i++) {
      final bytes = fileBytesList[i];
      final name = (i < fileNames.length && fileNames[i].isNotEmpty) ? fileNames[i] : 'product_$i.jpg';
      multipartFiles.add(
        http.MultipartFile.fromBytes('images[]', bytes, filename: name),
      );
    }

    final fields = <String, String>{
      'is_primary': isPrimary ? '1' : '0',
    };
    if (productId != null && productId > 0) {
      fields['product_id'] = productId.toString();
    }

    return await _apiClient.multipartRequest(
      path,
      fields: fields,
      files: multipartFiles,
    );
  }

  /// Get all active product categories
  /// GET /buddy/categories
  static Future<ApiResponse> getCategories() async {
    return await _apiClient.get('/buddy/categories');
  }

  /// Get active subcategories for a given parent category
  /// GET /buddy/categories/{id}/subcategories
  static Future<ApiResponse> getSubcategories(int categoryId) async {
    return await _apiClient.get('/buddy/categories/$categoryId/subcategories');
  }

  /// Get category-specific dynamic specification template
  /// GET /buddy/categories/{id}/specifications
  static Future<ApiResponse> getCategorySpecifications(int categoryId) async {
    return await _apiClient.get('/buddy/categories/$categoryId/specifications');
  }

  /// Get live inventory list with stock metrics
  /// GET /buddy/inventory
  static Future<ApiResponse> getInventory({
    String? status,
    String? search,
    int? categoryId,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (categoryId != null && categoryId > 0) queryParams['category_id'] = categoryId.toString();

    return await _apiClient.get('/buddy/inventory', queryParameters: queryParams);
  }

  /// Update stock quantity for a product and record movement
  /// POST /buddy/inventory/update-stock
  static Future<ApiResponse> updateInventoryStock({
    required int productId,
    int? stockQuantity,
    int? adjustmentDelta,
    String movementType = 'manual_adjustment',
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'product_id': productId,
      'movement_type': movementType,
    };
    if (stockQuantity != null) body['stock_quantity'] = stockQuantity;
    if (adjustmentDelta != null) body['adjustment_delta'] = adjustmentDelta;
    if (reason != null && reason.isNotEmpty) body['reason'] = reason;

    return await _apiClient.post('/buddy/inventory/update-stock', body: body);
  }

  /// Get stock movement audit logs
  /// GET /buddy/inventory/movements
  static Future<ApiResponse> getStockMovements({int? productId, int page = 1, int limit = 20}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (productId != null && productId > 0) queryParams['product_id'] = productId.toString();

    return await _apiClient.get('/buddy/inventory/movements', queryParameters: queryParams);
  }

  /// Get seller or admin orders list
  /// GET /buddy/orders
  static Future<ApiResponse> getOrders({
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    return await _apiClient.get('/buddy/orders', queryParameters: queryParams);
  }

  /// Get specific order details
  /// GET /buddy/orders/{id}
  static Future<ApiResponse> getOrderDetails(dynamic orderId) async {
    return await _apiClient.get('/buddy/orders/$orderId');
  }

  /// Accept order or order item
  /// POST /buddy/orders/{id}/accept
  static Future<ApiResponse> acceptOrder({
    required dynamic orderId,
    int? itemId,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (itemId != null && itemId > 0) body['item_id'] = itemId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    return await _apiClient.post('/buddy/orders/$orderId/accept', body: body);
  }

  /// Reject order or order item with mandatory rejection reason
  /// POST /buddy/orders/{id}/reject
  static Future<ApiResponse> rejectOrder({
    required dynamic orderId,
    required String reason,
    int? itemId,
  }) async {
    final body = <String, dynamic>{
      'reason': reason,
    };
    if (itemId != null && itemId > 0) body['item_id'] = itemId;

    return await _apiClient.post('/buddy/orders/$orderId/reject', body: body);
  }

  /// Update order status
  /// PATCH /buddy/orders/{id}/status
  static Future<ApiResponse> updateOrderStatus({
    required dynamic orderId,
    required String status,
    int? itemId,
    String? courierName,
    String? trackingNumber,
    String? currentLocation,
    String? nextStop,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'status': status,
    };
    if (itemId != null) body['item_id'] = itemId;
    if (courierName != null) body['courier_name'] = courierName;
    if (trackingNumber != null) body['tracking_number'] = trackingNumber;
    if (currentLocation != null) body['current_location'] = currentLocation;
    if (nextStop != null) body['next_stop'] = nextStop;
    if (description != null) body['description'] = description;

    return await _apiClient.patch('/buddy/orders/$orderId/status', body: body);
  }

  /// Get live tracking timeline for an order
  /// GET /buddy/orders/{id}/tracking
  static Future<ApiResponse> getOrderTracking(dynamic orderId) async {
    return await _apiClient.get('/buddy/orders/$orderId/tracking');
  }

  /// Get persistent inventory alerts
  /// GET /buddy/inventory/alerts
  static Future<ApiResponse> getInventoryAlerts({String status = 'active', int limit = 20}) async {
    return await _apiClient.get(
      '/buddy/inventory/alerts',
      queryParameters: {
        'status': status,
        'limit': limit,
      },
    );
  }

  /// Mark specific alert as read
  /// POST /buddy/inventory/alerts/{id}/read
  static Future<ApiResponse> markAlertRead(int alertId) async {
    return await _apiClient.post('/buddy/inventory/alerts/$alertId/read');
  }

  /// Mark all alerts as read
  /// POST /buddy/inventory/alerts/mark-all-read
  static Future<ApiResponse> markAllAlertsRead() async {
    return await _apiClient.post('/buddy/inventory/alerts/mark-all-read');
  }

  /// Update product inventory low stock threshold
  /// POST /buddy/inventory/threshold
  static Future<ApiResponse> updateInventoryThreshold({
    required int productId,
    required int threshold,
  }) async {
    return await _apiClient.post(
      '/buddy/inventory/threshold',
      body: {
        'product_id': productId,
        'threshold': threshold,
      },
    );
  }

  /// Get seller reviews and rating distribution summary
  /// GET /buddy/seller/reviews
  static Future<ApiResponse> getSellerReviews({
    int page = 1,
    int limit = 15,
    int? rating,
    bool? hasReply,
    int? productId,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (rating != null) queryParams['rating'] = rating;
    if (hasReply != null) queryParams['has_reply'] = hasReply;
    if (productId != null) queryParams['product_id'] = productId;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    return await _apiClient.get(
      '/buddy/seller/reviews',
      queryParameters: queryParams,
    );
  }

  /// Submit or update seller reply to customer review
  /// POST /buddy/seller/reviews/{id}/reply
  static Future<ApiResponse> replyToReview({
    required int reviewId,
    required String reply,
  }) async {
    return await _apiClient.post(
      '/buddy/seller/reviews/$reviewId/reply',
      body: {
        'seller_reply': reply,
      },
    );
  }

  /// Admin get marketplace reviews
  /// GET /buddy/admin/reviews
  static Future<ApiResponse> getAdminReviews({
    int page = 1,
    int limit = 20,
    String? status,
    int? sellerId,
    int? rating,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (sellerId != null) queryParams['seller_id'] = sellerId;
    if (rating != null) queryParams['rating'] = rating;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    return await _apiClient.get(
      '/buddy/admin/reviews',
      queryParameters: queryParams,
    );
  }

  /// Admin moderate review status
  /// PUT /buddy/admin/reviews/{id}/moderate
  static Future<ApiResponse> moderateReview({
    required int reviewId,
    required String status,
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'status': status,
    };
    if (reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }

    return await _apiClient.put(
      '/buddy/admin/reviews/$reviewId/moderate',
      body: body,
    );
  }

  /// Get return requests (scoped for seller, marketplace-wide for admin)
  /// GET /buddy/returns
  static Future<ApiResponse> getReturns({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    return await _apiClient.get(
      '/buddy/returns',
      queryParameters: queryParams,
    );
  }

  /// Get return request details
  /// GET /buddy/returns/{id}
  static Future<ApiResponse> getReturnDetails(dynamic returnId) async {
    return await _apiClient.get('/buddy/returns/$returnId');
  }

  /// Update return status / make decision (authorized seller or admin)
  /// PUT /buddy/returns/{id}/decision
  static Future<ApiResponse> updateReturnDecision({
    required dynamic returnId,
    required String status,
    String? decisionReason,
    String? adminNotes,
    double? actualRefund,
  }) async {
    final body = <String, dynamic>{
      'status': status,
    };
    if (decisionReason != null && decisionReason.isNotEmpty) {
      body['decision_reason'] = decisionReason;
    }
    if (adminNotes != null && adminNotes.isNotEmpty) {
      body['admin_notes'] = adminNotes;
    }
    if (actualRefund != null) {
      body['actual_refund'] = actualRefund;
    }

    return await _apiClient.put(
      '/buddy/returns/$returnId/decision',
      body: body,
    );
  }
}




