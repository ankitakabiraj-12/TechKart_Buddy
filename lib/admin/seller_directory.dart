import 'package:flutter/material.dart';
import 'seller_applications_details.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import '../seller/seller_profile_service.dart';

class SellerDirectoryScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const SellerDirectoryScreen({super.key, this.onNavigateTab});

  @override
  State<SellerDirectoryScreen> createState() => _SellerDirectoryScreenState();
}

class _SellerDirectoryScreenState extends State<SellerDirectoryScreen> {
  // Filters: 0 -> All, 1 -> Verified, 2 -> Unverified, 3 -> Active
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  // Collapsible showcase state
  bool _isBusinessDetailsExpanded = true;
  bool _isInventoryExpanded = false;

  // Pagination & Loading States
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _sellers = [];
  Map<String, dynamic>? _metrics;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDirectory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDirectory({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String statusParam = 'all';
      if (_selectedFilter == 1) {
        statusParam = 'verified';
      } else if (_selectedFilter == 2) {
        statusParam = 'unverified';
      } else if (_selectedFilter == 3) {
        statusParam = 'active';
      }

      final query = _searchController.text.trim();
      final data = await SellerProfileService.getSellersDirectory(
        search: query.isNotEmpty ? query : null,
        status: statusParam,
        page: page,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (data != null) {
            _sellers = data['sellers'] as List<dynamic>? ?? [];
            _metrics = data['metrics'] as Map<String, dynamic>?;
            final pagination = data['pagination'] as Map<String, dynamic>?;
            _currentPage = pagination?['page'] ?? 1;
            _totalPages = pagination?['total_pages'] ?? 1;
            _totalCount = pagination?['total'] ?? _sellers.length;
          } else {
            _errorMessage = 'Failed to load seller directory from server';
          }
        });
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

  void _onFilterSelected(int index) {
    setState(() {
      _selectedFilter = index;
    });
    _loadDirectory(page: 1);
  }

  void _onSearchSubmitted(String _) {
    _loadDirectory(page: 1);
  }

  Future<void> _toggleSellerVerification(Map<String, dynamic> seller) async {
    final sellerId = (seller['user_id'] as num?)?.toInt() ?? 0;
    final currentStatus = seller['is_verified'] == 1 || seller['is_verified'] == true;
    final newStatus = !currentStatus;
    final storeName = seller['store_name'] ?? seller['contact_person'] ?? 'Seller';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus ? 'Approve Verification' : 'Revoke Verification'),
        content: Text('Update KYC verification for $storeName (ID: $sellerId)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03253B)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await SellerProfileService.updateVerificationStatus(sellerId, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.isSuccess ? 'Verification updated successfully!' : res.message),
          backgroundColor: res.isSuccess ? const Color(0xFF16A34A) : const Color(0xFFB33020),
        ),
      );
      if (res.isSuccess) {
        _loadDirectory(page: _currentPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine showcase seller (first seller in list) and others
    final showcaseSeller = _sellers.isNotEmpty ? (_sellers.first as Map<String, dynamic>) : null;
    final otherSellers = _sellers.length > 1 ? _sellers.sublist(1) : <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            // Main Scrollable Area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadDirectory(page: 1),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar + Filter Icon
                      _buildSearchBar(),

                      const SizedBox(height: 10),

                      // Filter Tabs (All, Verified, Unverified, Active)
                      _buildFilterTabs(),

                      const SizedBox(height: 14),

                      // 3 KPI Metric Summary Cards
                      _buildMetricsRow(),

                      const SizedBox(height: 16),

                      if (_isLoading && _sellers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_errorMessage != null && _sellers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 36, color: Color(0xFFEF4444)),
                                const SizedBox(height: 8),
                                Text(_errorMessage!, style: const TextStyle(color: Color(0xFF6B8095))),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () => _loadDirectory(page: 1),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_sellers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.storefront_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                const Text(
                                  'No merchants found',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF03253B)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Try adjusting your search keywords or filter tab.',
                                  style: TextStyle(fontSize: 11.5, color: Color(0xFF6B8095)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        // Showcase Top / Featured Merchant Card
                        if (showcaseSeller != null)
                          _buildShowcaseMerchantCard(showcaseSeller),

                        const SizedBox(height: 20),

                        // Section: Other Registered Merchants
                        _buildOtherMerchantsHeader(otherSellers.length),

                        const SizedBox(height: 10),

                        // Live Merchant Cards
                        for (final s in otherSellers)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _buildLiveMerchantCard(s as Map<String, dynamic>),
                          ),

                        const SizedBox(height: 16),

                        // Pagination Control
                        _buildPagination(),

                        const SizedBox(height: 12),

                        // Role Notice Container
                        _buildRoleNotice(),

                        const SizedBox(height: 16),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return AdminTopBar(
      title: 'Seller Directory',
      subtitle: 'Registered Merchants & Status',
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(0); // Return to Home tab
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F0FC),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 18, color: Color(0xFF4C6A88)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearchSubmitted,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF03253B)),
                    decoration: const InputDecoration(
                      hintText: 'Search by Seller ID, Business Name, GST...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF5A7591)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _loadDirectory(page: 1);
                    },
                    child: const Icon(Icons.clear, size: 16, color: Color(0xFF4C6A88)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _loadDirectory(page: 1),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFD6EEFD),
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(Icons.search, size: 18, color: Color(0xFF285C8A)),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      'All ($_totalCount)',
      'Verified',
      'Unverified',
      'Active',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _onFilterSelected(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF455879) : const Color(0xFFD8ECFD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF28547C),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricsRow() {
    final totalMerchants = _metrics?['total_merchants']?.toString() ?? '$_totalCount';
    final compliance = _metrics?['compliance_rate']?.toString() ?? '98.2%';
    final escrow = _metrics?['escrow_volume_fmt']?.toString() ?? '₹ 42.8M';

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Total Merchants',
            value: totalMerchants,
            sub: 'Verified pool',
            valColor: const Color(0xFF03253B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'Compliance',
            value: compliance,
            sub: '+0.4% target',
            valColor: const Color(0xFF285C8A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'Escrow Volume',
            value: escrow,
            sub: 'Secured vault',
            valColor: const Color(0xFF03253B),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String sub,
    required Color valColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: valColor),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500, color: Color(0xFF6B8095)),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseMerchantCard(Map<String, dynamic> s) {
    final storeName = s['store_name'] ?? s['contact_person'] ?? 'Seller Store';
    final sellerId = (s['user_id'] as num?)?.toInt() ?? 0;
    final isVerified = s['is_verified'] == 1 || s['is_verified'] == true;
    final gst = s['gst_number'] ?? 'GST-IN-Pending';
    final city = s['city'] ?? 'Mumbai';
    final state = s['state'] ?? 'Maharashtra';
    final address = s['address'] ?? '$city, $state';
    final email = s['email'] ?? 'contact@techkart.com';
    final phone = s['phone'] ?? 'Phone not provided';
    final productsCount = s['total_products']?.toString() ?? '0';
    final ordersCount = s['total_orders']?.toString() ?? '0';
    final rev = double.tryParse(s['total_revenue']?.toString() ?? '0') ?? 0.0;
    final joined = s['created_at'] != null ? s['created_at'].toString().split(' ').first : '2024';

    // Initials
    final initials = storeName.toString().trim().isNotEmpty
        ? storeName.toString().trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'ST';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name, Joined, 3-dots
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6EEFD),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF285C8A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeName.toString(),
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'TK-SLR-$sellerId • Joined $joined',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF556F88)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF556F88)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _toggleSellerVerification(s),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Badges: Active & Verified
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified ? Icons.check_circle_outline_rounded : Icons.hourglass_top_rounded,
                            size: 11,
                            color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified ? 'Active & Verified' : 'Under KYC Review',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EDFD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.military_tech_outlined, size: 12, color: Color(0xFF384DA5)),
                          SizedBox(width: 4),
                          Text(
                            'Live Merchant',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF384DA5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 2x2 Inner Metric Grid
                Row(
                  children: [
                    Expanded(child: _buildInnerStat('Active Listings', productsCount, 'SKUs published')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInnerStat('Total Orders', ordersCount, 'Platform orders')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInnerStat('Location', city, state)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInnerStat('Gross Volume', '₹ ${rev.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', 'Completed')),
                  ],
                ),

                const SizedBox(height: 10),

                // Available Escrow Settlement Row
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF5FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Escrow Settlement', style: TextStyle(fontSize: 10, color: Color(0xFF6B8095))),
                          const SizedBox(height: 2),
                          Text(
                            '₹ ${rev.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF03253B)),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SellerApplicationsDetailsScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF03253B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Manage Store', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Collapsible 1: Business Details
          _buildCollapsibleSection(
            title: 'Business & KYC Details',
            icon: Icons.business_outlined,
            isExpanded: _isBusinessDetailsExpanded,
            onToggle: () => setState(() => _isBusinessDetailsExpanded = !_isBusinessDetailsExpanded),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildDetailRow('Store Name', storeName),
                  _buildDetailRow('GSTIN / Tax ID', gst),
                  _buildDetailRow('Contact Person', s['contact_person'] ?? 'Manager'),
                  _buildDetailRow('Registered Address', address),
                  _buildDetailRow('Support Email', email),
                  _buildDetailRow('Support Phone', phone),
                ],
              ),
            ),
          ),

          // Collapsible 2: Operational Triage Actions
          _buildCollapsibleSection(
            title: 'Quick Merchant Controls',
            icon: Icons.tune_rounded,
            isExpanded: _isInventoryExpanded,
            onToggle: () => setState(() => _isInventoryExpanded = !_isInventoryExpanded),
            content: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionBtn(
                      icon: isVerified ? Icons.remove_moderator_outlined : Icons.verified_user_outlined,
                      label: isVerified ? 'Revoke KYC' : 'Verify KYC',
                      bg: const Color(0xFFD6EEFD),
                      fg: const Color(0xFF285C8A),
                      onTap: () => _toggleSellerVerification(s),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionBtn(
                      icon: Icons.inventory_2_outlined,
                      label: 'View Catalog',
                      bg: const Color(0xFFEDF5FD),
                      fg: const Color(0xFF03253B),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Viewing products for $storeName')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerStat(String title, String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF6B8095))),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                val,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF03253B)),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  sub,
                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B8095), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2ECF5), width: 0.8)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: const Color(0xFF4C647C)),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF03253B)),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: const Color(0xFF6B8095),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) content,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B8095))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF03253B)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMerchantsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Other Registered Merchants ($count)',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF03253B),
          ),
        ),
        const Text(
          'Sorted by ID',
          style: TextStyle(fontSize: 10.5, color: Color(0xFF6B8095)),
        ),
      ],
    );
  }

  Widget _buildLiveMerchantCard(Map<String, dynamic> s) {
    final storeName = s['store_name'] ?? s['contact_person'] ?? 'Seller Store';
    final sellerId = (s['user_id'] as num?)?.toInt() ?? 0;
    final isVerified = s['is_verified'] == 1 || s['is_verified'] == true;
    final city = s['city'] ?? 'Mumbai';
    final productCount = s['total_products']?.toString() ?? '0';
    final rev = double.tryParse(s['total_revenue']?.toString() ?? '0') ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    storeName.toString(),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EEFD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'TK-SLR-$sellerId',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _toggleSellerVerification(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVerified ? Icons.verified : Icons.hourglass_top_rounded,
                        size: 11,
                        color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isVerified ? 'Verified' : 'Unverified',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$city • $productCount Published SKUs • ${s['email'] ?? ''}',
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF556F88)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume: ₹ ${rev.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF03253B)),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellerApplicationsDetailsScreen(),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF03253B)),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF03253B)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 22, color: Color(0xFF285C8A)),
          onPressed: _currentPage > 1 ? () => _loadDirectory(page: _currentPage - 1) : null,
        ),
        const SizedBox(width: 8),
        Text(
          'Page $_currentPage of $_totalPages',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF03253B)),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF285C8A)),
          onPressed: _currentPage < _totalPages ? () => _loadDirectory(page: _currentPage + 1) : null,
        ),
      ],
    );
  }

  Widget _buildRoleNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF556F88)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Displaying page $_currentPage of $_totalPages ($_totalCount live merchant records). Role: Administrator (Full Directory & KYC Verification Control).',
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF556F88), height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}
