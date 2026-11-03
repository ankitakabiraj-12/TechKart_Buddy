import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

class AdminSettingsService {
  static final ApiClient _apiClient = ApiClient();

  /// Retrieve system settings and category commission rates from MariaDB
  /// GET /api/v1/buddy/admin/settings
  static Future<Map<String, dynamic>?> getSettings() async {
    try {
      final response = await _apiClient.get('/buddy/admin/settings');
      if (response.isSuccess && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update global platform settings and default rates
  /// PUT /api/v1/buddy/admin/settings
  static Future<ApiResponse> updateSettings({
    double? defaultCommissionRate,
    double? paymentProcessingFeeRate,
    int? returnWindowDays,
    bool? autoRejectDuplicateBin,
    bool? kycTradeLicenseRequired,
    bool? kycTinRequired,
    bool? kycBiometricNidRequired,
    bool? kycBankChequeRequired,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (defaultCommissionRate != null) {
        body['default_commission_rate'] = defaultCommissionRate;
      }
      if (paymentProcessingFeeRate != null) {
        body['payment_processing_fee_rate'] = paymentProcessingFeeRate;
      }
      if (returnWindowDays != null) {
        body['return_window_days'] = returnWindowDays;
      }
      if (autoRejectDuplicateBin != null) {
        body['auto_reject_duplicate_bin'] = autoRejectDuplicateBin;
      }
      if (kycTradeLicenseRequired != null) {
        body['kyc_trade_license_required'] = kycTradeLicenseRequired;
      }
      if (kycTinRequired != null) {
        body['kyc_tin_required'] = kycTinRequired;
      }
      if (kycBiometricNidRequired != null) {
        body['kyc_biometric_nid_required'] = kycBiometricNidRequired;
      }
      if (kycBankChequeRequired != null) {
        body['kyc_bank_cheque_required'] = kycBankChequeRequired;
      }

      final response = await _apiClient.put(
        '/buddy/admin/settings',
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

  /// Update category-specific commission rate
  /// PUT /api/v1/buddy/admin/settings/commissions/{category_id}
  static Future<ApiResponse> updateCategoryCommission({
    required int categoryId,
    required double commissionRate,
    double? minCommission,
    double? maxCommission,
    bool isActive = true,
  }) async {
    try {
      final body = <String, dynamic>{
        'commission_rate': commissionRate,
        'is_active': isActive ? 1 : 0,
      };
      if (minCommission != null) {
        body['min_commission'] = minCommission;
      }
      if (maxCommission != null) {
        body['max_commission'] = maxCommission;
      }

      final response = await _apiClient.put(
        '/buddy/admin/settings/commissions/$categoryId',
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
}
