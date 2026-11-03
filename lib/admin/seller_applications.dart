import 'package:flutter/material.dart';
import 'seller_applications_details.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';

import '../core/network/api_client.dart';

class SellerApplicationsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const SellerApplicationsScreen({super.key, this.onNavigateTab});

  @override
  State<SellerApplicationsScreen> createState() =>
      _SellerApplicationsScreenState();
}

class _SellerApplicationsScreenState extends State<SellerApplicationsScreen> {
  final ApiClient _apiClient = ApiClient();
  int _selectedFilterIndex = 0;
  List<dynamic> _applications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/buddy/admin/seller-applications');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (res.isSuccess && res.data != null) {
            _applications = res.data['applications'] as List<dynamic>? ?? [];
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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

            // Search Bar & Filter Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F0FC),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF4C6A88),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'App ID, Business Name, Applicant, e-TIN...',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF5A7591),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F0FC),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: Color(0xFF4C6A88),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Pills Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // All Queued 28
                    _buildPillTab(0, 'All Queued', '28'),
                    const SizedBox(width: 8),
                    // Pending Review 16
                    _buildPillTab(1, 'Pending Review', '16'),
                    const SizedBox(width: 8),
                    // Escalated
                    _buildPillTab(2, 'Escalated', null),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // SLA Alerts & Sort Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF1E3245),
                          ),
                          children: [
                            TextSpan(
                              text: '3 SLA Alerts ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: 'today',
                              style: TextStyle(color: Color(0xFF5A6E80)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F0FC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF28557F),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Sort: Urgent SLA <4h',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF28557F),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: Color(0xFF28557F),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Main Application Cards List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchApplications,
                child: _isLoading && _applications.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          if (_applications.isNotEmpty) ...[
                            ..._applications.map((app) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildDynamicApplicationCard(app),
                              );
                            }),
                          ] else ...[
                            // Card 1: Merchant Applicant
                            _buildCard1(context),
                            const SizedBox(height: 12),

                            // Card 2: ElectroNex India
                            _buildCard2(context),
                            const SizedBox(height: 12),

                            // Card 3: SoundCore Premier Audio
                            _buildCard3(context),
                            const SizedBox(height: 12),

                            // Card 4: VoltTech Distribution Ltd
                            _buildCard4(context),
                            const SizedBox(height: 16),
                          ],

                          // Pagination Footer
                          _buildPaginationFooter(),
                          const SizedBox(height: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AdminTopBar(
      title: 'Seller Applications',
      subtitle: 'KYC & Merchant Verification',
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(0); // Go to Home tab
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

  Widget _buildPillTab(int index, String label, String? count) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF455879) : const Color(0xFFE2F0FD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF33506B),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFCFE4F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF264969),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicApplicationCard(Map<String, dynamic> app) {
    final appId = app['application_id']?.toString() ?? 'APP-000';
    final storeName = app['store_name']?.toString() ?? 'Store Applicant';
    final businessType = app['business_type']?.toString() ?? 'Enterprise';
    final contactEmail = app['contact_email']?.toString() ?? 'contact@store.com';
    final status = app['status']?.toString().toUpperCase() ?? 'PENDING';
    final tradeLicense = app['trade_license']?.toString() ?? 'VERIFIED';
    final slaDeadline = app['sla_deadline']?.toString() ?? '24h SLA';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03253B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF28557F), Color(0xFF49658E), Color(0xFF67B5EC)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appId,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3245),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          storeName,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF03253B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: status == 'APPROVED' ? const Color(0xFFE2F8E7) : const Color(0xFFFDE8E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: status == 'APPROVED' ? const Color(0xFF1B6B35) : const Color(0xFFB33020),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.business_center_outlined, size: 13, color: Color(0xFF4C6A88)),
                    const SizedBox(width: 4),
                    Text(
                      '$businessType • Trade Lic: $tradeLicense',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        color: Color(0xFF435A70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contactEmail,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF28557F)),
                      ),
                      Text(
                        'SLA: $slaDeadline',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard1(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03253B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient top accent bar (Red to Blue)
          Container(
            height: 3,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFFBA2D2D), Color(0xFF49658E), Color(0xFF67B5EC)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'TKB-2024-89241',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3245),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Merchant Applicant',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF03253B),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFFB33020),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '1h 38m left',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB33020),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Urgent SLA Breached\nSoon',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC0392B),
                            height: 1.15,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Location / Category
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Color(0xFF4C6A88),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Mumbai Zone A • Computer & Wearables',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        color: Color(0xFF435A70),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Applicant Info Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(
                              Icons.badge_outlined,
                              size: 15,
                              color: Color(0xFF33506B),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Md. Al-Amin (Managing Partner)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF03253B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Aadhaar: Verified',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF234460),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Tags row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildStatusPill(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Trade Lic. ',
                      boldText: 'PASS',
                      bg: const Color(0xFFD8ECFD),
                      fg: const Color(0xFF1D5A8C),
                    ),
                    _buildStatusPill(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'e-TIN ',
                      boldText: 'PASS',
                      bg: const Color(0xFFD8ECFD),
                      fg: const Color(0xFF1D5A8C),
                    ),
                    _buildStatusPill(
                      icon: Icons.receipt_long_outlined,
                      label: 'Cheque Leaf ',
                      boldText: '[Manual Review]',
                      bg: const Color(0xFFF6EEDB),
                      fg: const Color(0xFF75571E),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Footer row: Received 2h ago & Review & Decide Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 14,
                          color: Color(0xFF5C7286),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Received 2h ago',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11,
                            color: Color(0xFF5C7286),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SellerApplicationsDetailsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF435878),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Review & Decide',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14),
                          ],
                        ),
                      ),
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

  Widget _buildCard2(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03253B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: ID & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TKB-2024-89238',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3245),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ElectroNex\nIndia',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 17,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE5E2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Needs\nResubmission',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB52E1D),
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Location / Category
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Color(0xFF4C6A88),
              ),
              SizedBox(width: 4),
              Text(
                'Bengaluru Hub • Mobile Accessories',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  color: Color(0xFF435A70),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Applicant Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.badge_outlined,
                        size: 15,
                        color: Color(0xFF33506B),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Tanvir Ahmed (Proprietor)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Aadhaar: Verified',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF234460),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Tags row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildStatusPill(
                icon: Icons.check_circle_outline_rounded,
                label: 'Trade Lic. ',
                boldText: 'PASS',
                bg: const Color(0xFFD8ECFD),
                fg: const Color(0xFF1D5A8C),
              ),
              _buildStatusPill(
                icon: Icons.flag_outlined,
                label: 'e-TIN ',
                boldText: '[Name Mismatch Flag]',
                bg: const Color(0xFFFDE8E5),
                fg: const Color(0xFFB52E1D),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: Color(0xFFB52E1D),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Spelling differs on TIN certificate',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFFB52E1D),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBEEFE),
                    foregroundColor: const Color(0xFF20486D),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.send_rounded, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Request\nResubmission',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard3(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03253B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: ID & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TKB-2024-89230',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3245),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'SoundCore Premier\nAudio',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 17,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFE8FD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: Color(0xFF1B4E79),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ready for\nApproval',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B4E79),
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Location
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Color(0xFF4C6A88),
              ),
              SizedBox(width: 4),
              Text(
                'Registered Address � Audio & Acoustics',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  color: Color(0xFF435A70),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Applicant Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.badge_outlined,
                        size: 15,
                        color: Color(0xFF33506B),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Farhan Ahmed (Managing Director)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PAN: Verified',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF234460),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Tags row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildStatusPill(
                icon: Icons.verified_user_outlined,
                label: '',
                boldText: 'All 4 Verified (100%)',
                bg: const Color(0xFFD8ECFD),
                fg: const Color(0xFF1D5A8C),
              ),
              _buildSimpleTag('Tax Clearance OK'),
              _buildSimpleTag('Bank Solvency OK'),
            ],
          ),

          const SizedBox(height: 12),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 13,
                    color: Color(0xFF4C6A88),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Desk manual checks cleared',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10.5,
                      color: Color(0xFF435A70),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF435878),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_rounded, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Grant Store Clearance',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard4(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03253B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: ID & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TKB-2024-89219',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3245),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'VoltTech\nDistribution Ltd',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 17,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECE4D2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.balance_rounded,
                      size: 13,
                      color: Color(0xFF6C5427),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Tier-1 Legal\nEscalation',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C5427),
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Location
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Color(0xFF4C6A88),
              ),
              SizedBox(width: 4),
              Text(
                'Registered Address � Chargers & Cables',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  color: Color(0xFF435A70),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Applicant & Legal note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 15,
                      color: Color(0xFF33506B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'K. Rahman ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    Text(
                      '(Authorized Signatory)',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF556F88),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '"Distributor Due Diligence assigned to Legal & Compliance desk"',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontStyle: FontStyle.italic,
                    fontSize: 11.5,
                    color: Color(0xFF2C4358),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 13,
                    color: Color(0xFF4C6A88),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Restricted Auto-approval',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10.5,
                      color: Color(0xFF435A70),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBEEFE),
                    foregroundColor: const Color(0xFF20486D),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.folder_shared_outlined, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'View Dossier',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required IconData icon,
    required String label,
    required String boldText,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 10.5, color: fg),
              children: [
                TextSpan(text: label),
                TextSpan(
                  text: boldText,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E5377),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing 1–4 of 28 applications',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                color: Color(0xFF556F88),
              ),
            ),
            Text(
              'Page 1 of 7',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3245),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPageArrow('< Prev', isEnabled: false),
            const SizedBox(width: 8),
            _buildPageNumber('1', isSelected: true),
            const SizedBox(width: 6),
            _buildPageNumber('2', isSelected: false),
            const SizedBox(width: 6),
            _buildPageNumber('3', isSelected: false),
            const SizedBox(width: 6),
            const Text(
              '...',
              style: TextStyle(color: Color(0xFF6B8095), fontSize: 12),
            ),
            const SizedBox(width: 6),
            _buildPageNumber('7', isSelected: false),
            const SizedBox(width: 8),
            _buildPageArrow('Next >', isEnabled: true),
          ],
        ),
      ],
    );
  }

  Widget _buildPageNumber(String page, {required bool isSelected}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF455879) : const Color(0xFFE2F0FD),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          page,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF284C6F),
          ),
        ),
      ),
    );
  }

  Widget _buildPageArrow(String text, {required bool isEnabled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isEnabled ? const Color(0xFF03253B) : const Color(0xFF88A0B6),
        ),
      ),
    );
  }
}
