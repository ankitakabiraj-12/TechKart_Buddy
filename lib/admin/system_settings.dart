import 'package:flutter/material.dart';
import 'admin_profile.dart';
import 'admin_top_bar.dart';
import 'admin_settings_service.dart';

class SystemSettingsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const SystemSettingsScreen({super.key, this.onNavigateTab});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  // Loading & Error States
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Platform Commission & Fee Engine State
  double _defaultCommissionRate = 6.0;
  double _paymentProcessingFeeRate = 1.5;
  List<dynamic> _categoryCommissions = [];

  // Return window days stepper
  int _returnWindowDays = 7;

  // KYC verification checkboxes
  bool _kycTradeLicense = true;
  bool _kycTIN = true;
  bool _kycBiometricNID = true;
  bool _kycBankCheque = true;

  // Auto-reject switch
  bool _autoRejectDuplicateBin = true;

  // Accordion expansion states
  bool _marketplacePoliciesExpanded = true;
  bool _kycRulesExpanded = true;
  bool _commissionExpanded = true;
  bool _logisticsExpanded = false;
  bool _securityExpanded = false;
  bool _smsGatewayExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AdminSettingsService.getSettings();
      if (mounted) {
        if (data != null) {
          setState(() {
            _isLoading = false;
            _defaultCommissionRate = (data['default_commission_rate'] as num?)?.toDouble() ?? 6.0;
            _paymentProcessingFeeRate = (data['payment_processing_fee_rate'] as num?)?.toDouble() ?? 1.5;
            _returnWindowDays = (data['return_window_days'] as num?)?.toInt() ?? 7;
            _autoRejectDuplicateBin = data['auto_reject_duplicate_bin'] as bool? ?? true;

            final kyc = data['kyc_rules'] as Map<String, dynamic>?;
            if (kyc != null) {
              _kycTradeLicense = kyc['trade_license'] as bool? ?? true;
              _kycTIN = kyc['tin'] as bool? ?? true;
              _kycBiometricNID = kyc['biometric_nid'] as bool? ?? true;
              _kycBankCheque = kyc['bank_cheque'] as bool? ?? true;
            }

            _categoryCommissions = data['category_commission_rates'] as List<dynamic>? ?? [];
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load system settings from server.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _saveAllSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final res = await AdminSettingsService.updateSettings(
        defaultCommissionRate: _defaultCommissionRate,
        paymentProcessingFeeRate: _paymentProcessingFeeRate,
        returnWindowDays: _returnWindowDays,
        autoRejectDuplicateBin: _autoRejectDuplicateBin,
        kycTradeLicenseRequired: _kycTradeLicense,
        kycTinRequired: _kycTIN,
        kycBiometricNidRequired: _kycBiometricNID,
        kycBankChequeRequired: _kycBankCheque,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.isSuccess ? 'System settings persisted to MariaDB!' : 'Error saving settings: ${res.message}'),
            backgroundColor: res.isSuccess ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: const Color(0xFFB52E1D),
          ),
        );
      }
    }
  }

  Future<void> _editCategoryCommissionDialog(Map<String, dynamic> cat) async {
    final catId = cat['category_id'] as int? ?? cat['id'] as int;
    final catName = cat['category_name']?.toString() ?? 'Category';
    final currentRate = (cat['commission_rate'] as num?)?.toDouble() ?? 6.0;
    final currentMin = (cat['min_commission'] as num?)?.toDouble() ?? 10.0;

    final rateCtrl = TextEditingController(text: currentRate.toString());
    final minCtrl = TextEditingController(text: currentMin.toString());

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Commission Rate: $catName',
          style: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF03253B)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform Take Rate (%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B8095))),
            const SizedBox(height: 4),
            TextField(
              controller: rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                suffixText: '%',
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF4F8FE),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD6EEFD))),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Floor / Minimum Fee (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B8095))),
            const SizedBox(height: 4),
            TextField(
              controller: minCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '₹ ',
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF4F8FE),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD6EEFD))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B8095))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newRate = double.tryParse(rateCtrl.text.trim());
              final newMin = double.tryParse(minCtrl.text.trim());
              if (newRate == null || newRate < 0 || newRate > 50) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid rate between 0% and 50%')),
                );
                return;
              }

              Navigator.pop(ctx);

              final res = await AdminSettingsService.updateCategoryCommission(
                categoryId: catId,
                commissionRate: newRate,
                minCommission: newMin ?? 0.0,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.message.isNotEmpty ? res.message : 'Category commission updated'),
                    backgroundColor: res.isSuccess ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
                  ),
                );
                _fetchSettings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Update Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            // Main Scrollable Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF03253B)),
                    )
                  : _errorMessage != null
                      ? _buildErrorView()
                      : RefreshIndicator(
                          color: const Color(0xFF03253B),
                          onRefresh: _fetchSettings,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Platform Governance Header & Version
                                _buildGovernanceHeader(),

                                const SizedBox(height: 10),

                                // Node Status Box
                                _buildNodeStatusBox(),

                                const SizedBox(height: 14),

                                // Section: Commission & Fee Engine (Expanded)
                                _buildCommissionEngineSection(),

                                const SizedBox(height: 14),

                                // Section 1: Marketplace Policies & Thresholds (Accordion)
                                _buildMarketplacePoliciesSection(),

                                const SizedBox(height: 14),

                                // Section 2: Seller Onboarding KYC Rules (Accordion)
                                _buildKycRulesSection(),

                                const SizedBox(height: 12),

                                // Collapsed Section: Logistics & Courier Routing
                                _buildCollapsedSection(
                                  title: 'Logistics & Courier Routing',
                                  icon: Icons.local_shipping_outlined,
                                  isExpanded: _logisticsExpanded,
                                  onToggle: () {
                                    setState(() {
                                      _logisticsExpanded = !_logisticsExpanded;
                                    });
                                  },
                                ),

                                const SizedBox(height: 10),

                                // Collapsed Section: Security & Console Access
                                _buildCollapsedSection(
                                  title: 'Security & Console Access',
                                  icon: Icons.security_rounded,
                                  isExpanded: _securityExpanded,
                                  onToggle: () {
                                    setState(() {
                                      _securityExpanded = !_securityExpanded;
                                    });
                                  },
                                ),

                                const SizedBox(height: 10),

                                // Collapsed Section: SMS Gateway & Triggers
                                _buildCollapsedSection(
                                  title: 'SMS Gateway & Triggers',
                                  icon: Icons.chat_bubble_outline_rounded,
                                  isExpanded: _smsGatewayExpanded,
                                  onToggle: () {
                                    setState(() {
                                      _smsGatewayExpanded = !_smsGatewayExpanded;
                                    });
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Dual-Officer Warning Card
                                _buildDualOfficerBanner(),

                                const SizedBox(height: 18),

                                // Action Buttons (Discard Changes & Save Configuration)
                                _buildBottomActionButtons(),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Top App Bar ---
  Widget _buildAppBar(BuildContext context) {
    return AdminTopBar(
      title: 'System Settings',
      subtitle: 'Platform Governance & Policies',
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(0);
        }
      },
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
        );
      },
    );
  }

  // --- Platform Governance Header & Version ---
  Widget _buildGovernanceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text(
            'PLATFORM GOVERNANCE & CORE\nPOLICIES',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF03253B),
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD6EEFD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF107C41),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'v4.2.1\nStable',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF285C8A),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Node Status Box ---
  Widget _buildNodeStatusBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6EEFD), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF03253B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.dns_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'NODE-CENTRAL-01',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6EEFD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRIMARY',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF285C8A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'India (Mumbai / IN-MUM-01) • MariaDB Synced',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF556F88),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EEFD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF285C8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Commission & Fee Engine Section ---
  Widget _buildCommissionEngineSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tile
          InkWell(
            onTap: () {
              setState(() {
                _commissionExpanded = !_commissionExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF5FD),
                borderRadius: _commissionExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18, color: Color(0xFF285C8A)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Commission & Fee Engine',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EEFD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'DEFAULT: ${_defaultCommissionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF285C8A)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _commissionExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: const Color(0xFF03253B),
                  ),
                ],
              ),
            ),
          ),

          if (_commissionExpanded)
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Global baseline commission slider & stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Baseline Platform Commission',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF03253B),
                        ),
                      ),
                      Text(
                        '${_defaultCommissionRate.toStringAsFixed(1)}% of order subtotal',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF107C41), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF5FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.percent_rounded, size: 16, color: Color(0xFF285C8A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF03253B),
                              inactiveTrackColor: const Color(0xFFD6EEFD),
                              thumbColor: const Color(0xFF03253B),
                              trackHeight: 3.0,
                            ),
                            child: Slider(
                              value: _defaultCommissionRate,
                              min: 0.0,
                              max: 20.0,
                              divisions: 40,
                              label: '${_defaultCommissionRate.toStringAsFixed(1)}%',
                              onChanged: (val) {
                                setState(() {
                                  _defaultCommissionRate = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD6EEFD)),
                          ),
                          child: Text(
                            '${_defaultCommissionRate.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF03253B)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Payment Processing Fee
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gateway Settlement & Processing Fee',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF03253B),
                        ),
                      ),
                      Text(
                        '${_paymentProcessingFeeRate.toStringAsFixed(1)}% flat',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF285C8A), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF5FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFF285C8A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF285C8A),
                              inactiveTrackColor: const Color(0xFFD6EEFD),
                              thumbColor: const Color(0xFF285C8A),
                              trackHeight: 3.0,
                            ),
                            child: Slider(
                              value: _paymentProcessingFeeRate,
                              min: 0.0,
                              max: 5.0,
                              divisions: 20,
                              label: '${_paymentProcessingFeeRate.toStringAsFixed(1)}%',
                              onChanged: (val) {
                                setState(() {
                                  _paymentProcessingFeeRate = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD6EEFD)),
                          ),
                          child: Text(
                            '${_paymentProcessingFeeRate.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF285C8A)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Category Commission Tiers Sub-list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category-Specific Override Tiers',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF03253B),
                        ),
                      ),
                      Text(
                        '${_categoryCommissions.length} Categories',
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2ECF5)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categoryCommissions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2ECF5)),
                      itemBuilder: (context, index) {
                        final cat = _categoryCommissions[index];
                        final catName = cat['category_name']?.toString() ?? 'Category';
                        final rate = (cat['commission_rate'] as num?)?.toDouble() ?? 6.0;
                        final minComm = (cat['min_commission'] as num?)?.toDouble() ?? 10.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    catName,
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF03253B)),
                                  ),
                                  Text(
                                    'Min fee floor: ₹ ${minComm.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD6EEFD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${rate.toStringAsFixed(1)}%',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF03253B)),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF285C8A)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _editCategoryCommissionDialog(cat),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- Section 1: Marketplace Policies & Thresholds ---
  Widget _buildMarketplacePoliciesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tile
          InkWell(
            onTap: () {
              setState(() {
                _marketplacePoliciesExpanded = !_marketplacePoliciesExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF5FD),
                borderRadius: _marketplacePoliciesExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF285C8A)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Marketplace Policies & Thresholds',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                  ),
                  Icon(
                    _marketplacePoliciesExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: const Color(0xFF03253B),
                  ),
                ],
              ),
            ),
          ),

          if (_marketplacePoliciesExpanded)
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Return Window Grace Period
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Return Window Grace Period',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF03253B),
                        ),
                      ),
                      Text(
                        'Post-delivery',
                        style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF5FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF285C8A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_returnWindowDays Calendar Days',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                            ),
                          ),
                        ),
                        // Stepper Minus Button
                        InkWell(
                          onTap: () {
                            if (_returnWindowDays > 1) {
                              setState(() {
                                _returnWindowDays--;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD6EEFD), width: 1),
                            ),
                            child: const Icon(Icons.remove, size: 15, color: Color(0xFF556F88)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Stepper Plus Button
                        InkWell(
                          onTap: () {
                            if (_returnWindowDays < 90) {
                              setState(() {
                                _returnWindowDays++;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD6EEFD), width: 1),
                            ),
                            child: const Icon(Icons.add, size: 15, color: Color(0xFF556F88)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Dispute Escalation SLA
                  const Text(
                    'Dispute Escalation SLA',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF5FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.hourglass_top_rounded, size: 18, color: Color(0xFFB52E1D)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '24 Hours Merchant Response',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF03253B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Auto-escrow freeze occurs if merchant fails to submit inspection report within statutory window.',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: Color(0xFF556F88),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Auto-reject Duplicate BIN Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Auto-reject Duplicate BIN / Tax IDs',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                        ),
                      ),
                      Switch(
                        value: _autoRejectDuplicateBin,
                        activeThumbColor: const Color(0xFF107C41),
                        onChanged: (val) {
                          setState(() {
                            _autoRejectDuplicateBin = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- Section 2: Seller Onboarding KYC Rules ---
  Widget _buildKycRulesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tile
          InkWell(
            onTap: () {
              setState(() {
                _kycRulesExpanded = !_kycRulesExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF5FD),
                borderRadius: _kycRulesExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 18, color: Color(0xFF285C8A)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Seller Onboarding KYC Rules',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                  ),
                  Icon(
                    _kycRulesExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: const Color(0xFF03253B),
                  ),
                ],
              ),
            ),
          ),

          if (_kycRulesExpanded)
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mandatory Verification Dossier (India Trade Compliance)',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10.5,
                      color: Color(0xFF556F88),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Item 1: Valid Municipal Trade License
                  _buildKycCheckItem(
                    title: 'Valid Municipal Trade License (City Corp / Union)',
                    isChecked: _kycTradeLicense,
                    onChanged: (val) {
                      setState(() {
                        _kycTradeLicense = val ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Item 2: 12-Digit e-TIN / GSTIN Certificate Verification
                  _buildKycCheckItem(
                    title: '15-Digit GSTIN / PAN Certificate Verification',
                    isChecked: _kycTIN,
                    onChanged: (val) {
                      setState(() {
                        _kycTIN = val ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Item 3: Biometric Smart Card / Aadhaar verification
                  _buildKycCheckItem(
                    title: 'Biometric Aadhaar / National ID Verification',
                    isChecked: _kycBiometricNID,
                    onChanged: (val) {
                      setState(() {
                        _kycBiometricNID = val ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Item 4: Bank Cheque Leaf / Micro-deposit Validation
                  _buildKycCheckItem(
                    title: 'Bank Cheque Leaf / Penny Drop Account Validation',
                    isChecked: _kycBankCheque,
                    onChanged: (val) {
                      setState(() {
                        _kycBankCheque = val ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- KYC Check Item Builder ---
  Widget _buildKycCheckItem({
    required String title,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: const Color(0xFF03253B),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF03253B),
              ),
            ),
          ),
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: Color(0xFF556F88),
          ),
        ],
      ),
    );
  }

  // --- Collapsed Accordion Section Builder ---
  Widget _buildCollapsedSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6EEFD), width: 0.8),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF285C8A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: const Color(0xFF03253B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dual-Officer Approval Warning Banner ---
  Widget _buildDualOfficerBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EEDF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADBCE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE7D8C4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Color(0xFF6B4826),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'DUAL-OFFICER APPROVAL ENFORCED',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A341E),
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Modifications trigger cryptographic audit logging and persist directly into MariaDB platform settings.',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF6B4826),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom Action Buttons ---
  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        // Discard Changes Button
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: _fetchSettings,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD6EEFD), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              child: const Text(
                'Discard',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF556F88),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Save Configuration Button
        Expanded(
          flex: 6,
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAllSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03253B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Save Configuration',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFB52E1D)),
            const SizedBox(height: 12),
            const Text(
              'Failed to Load Settings',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF03253B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF556F88)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchSettings,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03253B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
