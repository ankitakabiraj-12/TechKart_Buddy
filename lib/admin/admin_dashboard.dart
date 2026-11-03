import 'package:flutter/material.dart';
import 'seller_applications.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import 'seller_directory.dart';
import 'product_catalog.dart';
import 'marketplace_order_management.dart';
import 'payments.dart';
import 'retuns.dart';
import 'audit_logs.dart';
import 'category_management.dart';
import 'inventory_oversight.dart';
import 'customer_management.dart';
import 'staff_roles.dart';
import '../core/network/api_client.dart';
import 'system_settings.dart';

class AdminDashboard extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const AdminDashboard({super.key, this.onNavigateTab});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _adminData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminDashboard();
  }

  Future<void> _fetchAdminDashboard() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/buddy/admin/dashboard');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (res.isSuccess && res.data != null) {
            _adminData = res.data as Map<String, dynamic>;
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
        child: RefreshIndicator(
          onRefresh: _fetchAdminDashboard,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              if (_isLoading)
                const LinearProgressIndicator(minHeight: 2),
              // Header Row: Logo + TECHKART ADMIN + Notification + Profile
              _buildHeader(context),

              const SizedBox(height: 12),

              // Filter & Sync Status Bar
              _buildSyncBar(),

              const SizedBox(height: 14),

              // 2x3 Metric Cards Grid
              _buildMetricGrid(context),

              const SizedBox(height: 16),

              // 7-DAY GMV PERFORMANCE Card
              _buildGmvPerformanceCard(),

              const SizedBox(height: 16),

              // PRIORITIZED ACTION QUEUES Section
              _buildPrioritizedActionQueues(context),

              const SizedBox(height: 16),

              // PLATFORM OPERATIONS & CONTROLS
              _buildPlatformModules(context),

              const SizedBox(height: 16),

              // SYSTEM AUDIT FEED Section
              _buildSystemAuditFeed(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    return AdminTopBar(
      title: 'TechKart Buddy',
      isHome: true,
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
        );
      },
    );
  }

  Widget _buildSyncBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date Picker Dropdown Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Color(0xFF254B70),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Today, Oct 29',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3C5B),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF1E3C5B),
                  ),
                ],
              ),
            ),

            // Core 99.98% + Sync Refresh Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9ECFD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF386494),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Core 99.98%',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF25486B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F0FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: Color(0xFF254B70),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Subtext: Engine 12ms latency ... PostgreSQL Replica: Synced 14s ago
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.bolt_rounded, size: 13, color: Color(0xFF556F88)),
                SizedBox(width: 2),
                Text(
                  'Engine 12ms latency',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF556F88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              'PostgreSQL Replica: Synced 14s ago',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFF556F88),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricGrid(BuildContext context) {
    final kpis = _adminData?['kpis'];
    final activeSellers = kpis?['active_sellers'] ?? 1420;
    final pendingApps = kpis?['pending_applications'] ?? 28;
    final activeListings = kpis?['active_listings'] ?? 38400;
    final pendingOrders = kpis?['pending_orders'] ?? 842;
    final openDisputes = kpis?['open_disputes'] ?? 14;
    final escrowExceptions = kpis?['escrow_exceptions'] ?? 6;

    return Column(
      children: [
        // Row 1: Active Sellers & Pending Apps
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Active Sellers',
                value: '$activeSellers',
                subtext: '↗ +14 this week',
                subtextColor: const Color(0xFF255E91),
                icon: Icons.storefront_outlined,
                iconBg: const Color(0xFFE2F0FD),
                iconColor: const Color(0xFF28649E),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellerDirectoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Pending Apps',
                value: '$pendingApps',
                subtext: '!  4 SLA alert <4h',
                subtextColor: const Color(0xFFB52E1D),
                icon: Icons.shield_outlined,
                iconBg: const Color(0xFFFDE8E5),
                iconColor: const Color(0xFFB52E1D),
                onTap: () {
                  if (widget.onNavigateTab != null) {
                    widget.onNavigateTab!(1); // Go to Sellers tab
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerApplicationsScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Active Listings & Pending Orders
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Active Listings',
                value: activeListings >= 1000 ? '${(activeListings / 1000).toStringAsFixed(1)}k' : '$activeListings',
                subtext: '12 active categories',
                subtextColor: const Color(0xFF556F88),
                icon: Icons.inventory_2_outlined,
                iconBg: const Color(0xFFE2F0FD),
                iconColor: const Color(0xFF28649E),
                onTap: () {
                  if (widget.onNavigateTab != null) {
                    widget.onNavigateTab!(2); // Go to Products tab
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductCatalogScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Pending Orders',
                value: '$pendingOrders',
                subtext: 'Mumbai & regional hub',
                subtextColor: const Color(0xFF556F88),
                icon: Icons.local_shipping_outlined,
                iconBg: const Color(0xFFE2F0FD),
                iconColor: const Color(0xFF28649E),
                onTap: () {
                  if (widget.onNavigateTab != null) {
                    widget.onNavigateTab!(3); // Go to Orders tab
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MarketplaceOrderManagementScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 3: Open Disputes & Escrow Exceptions
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Open Disputes',
                value: '$openDisputes',
                subtext: '8 refunds, 6 logistic',
                subtextColor: const Color(0xFF556F88),
                icon: Icons.balance_outlined,
                iconBg: const Color(0xFFE2F0FD),
                iconColor: const Color(0xFF28649E),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReturnsAndDisputesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Escrow Exceptions',
                value: '$escrowExceptions active',
                subtext: '3 holds audit check',
                subtextColor: const Color(0xFF556F88),
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFFF6EEDB),
                iconColor: const Color(0xFF75571E),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtext,
    required Color subtextColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF03253B).withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF556F88),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGmvPerformanceCard() {
    final days = [
      {'day': 'Wed', 'height': 38.0, 'isHighlight': false},
      {'day': 'Thu', 'height': 52.0, 'isHighlight': false},
      {'day': 'Fri', 'height': 46.0, 'isHighlight': false},
      {'day': 'Sat', 'height': 56.0, 'isHighlight': false},
      {'day': 'Sun', 'height': 54.0, 'isHighlight': false},
      {'day': 'Mon', 'height': 52.0, 'isHighlight': false},
      {'day': 'Tue', 'height': 64.0, 'isHighlight': true},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '7-DAY GMV PERFORMANCE',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B8095),
                  letterSpacing: 0.8,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Weekly Average',
                    style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
                  ),
                  Text(
                    '₹ 4.1M / day',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3245),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '₹ 5.1M',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+16.4% WoW',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D5A8C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart with rounded capsule bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              final isHighlight = d['isHighlight'] as bool;
              final height = d['height'] as double;
              final day = d['day'] as String;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: height,
                    decoration: BoxDecoration(
                      color: isHighlight
                          ? const Color(0xFF4C5D7D)
                          : const Color(0xFFD4E8FB),
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      fontWeight:
                          isHighlight ? FontWeight.w800 : FontWeight.w500,
                      color: isHighlight
                          ? const Color(0xFF03253B)
                          : const Color(0xFF6B8095),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Footnote: Oct 23: ₹ 3.8M ... Peak Today: ₹ 5.12M
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Oct 23: ₹ 3.8M',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF6B8095),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Peak Today: ₹ 5.12M',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF263C4F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritizedActionQueues(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PRIORITIZED ACTION QUEUES',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B8095),
                letterSpacing: 0.8,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '3 Actionable',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB52E1D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Queue item 1: Seller Onboarding Queue
        _buildQueueCard(
          icon: Icons.person_add_alt_1_outlined,
          iconBg: const Color(0xFFD4E8FB),
          iconColor: const Color(0xFF225B8E),
          title: 'Seller Onboarding Queue',
          description: '28 pending applications—8 high-GMV ...',
          actionText: 'Review →',
          actionColor: const Color(0xFF225B8E),
          onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(1);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerApplicationsScreen(),
                ),
              );
            }
          },
        ),

        const SizedBox(height: 8),

        // Queue item 2: Escrow Settlement Audit
        _buildQueueCard(
          icon: Icons.verified_outlined,
          iconBg: const Color(0xFFF6EEDB),
          iconColor: const Color(0xFF75571E),
          title: 'Escrow Settlement Audit',
          description: '₹ 384,920 payout batch pending final adm...',
          actionText: 'Audit →',
          actionColor: const Color(0xFF225B8E),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentsScreen()),
            );
          },
        ),

        const SizedBox(height: 8),

        // Queue item 3: Compliance & Prohibited Flag
        _buildQueueCard(
          icon: Icons.flag_outlined,
          iconBg: const Color(0xFFFDE8E5),
          iconColor: const Color(0xFFB52E1D),
          title: 'Compliance & Prohibited Flag',
          description: '2 listings reported for copyright/MAP v...',
          actionText: 'Inspect →',
          actionColor: const Color(0xFFB52E1D),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReturnsAndDisputesScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQueueCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required String actionText,
    required Color actionColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF03253B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF556F88),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTap,
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: actionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformModules(BuildContext context) {
    final modules = [
      {
        'title': 'Taxonomy',
        'subtitle': 'Categories & Trees',
        'icon': Icons.category_outlined,
        'color': const Color(0xFF1D5A92),
        'bg': const Color(0xFFE2F0FD),
        'target': const CategoryManagementScreen(),
      },
      {
        'title': 'Escalations',
        'subtitle': 'Customer Inquiries',
        'icon': Icons.headset_mic_outlined,
        'color': const Color(0xFF9E5E14),
        'bg': const Color(0xFFFBF0DC),
        'target': const CustomerManagementScreen(),
      },
      {
        'title': 'Staff Roles',
        'subtitle': 'Access & Security',
        'icon': Icons.admin_panel_settings_outlined,
        'color': const Color(0xFF2C6B4E),
        'bg': const Color(0xFFE4F6EB),
        'target': const StaffRolesScreen(),
      },
      {
        'title': 'Settings',
        'subtitle': 'System & Configs',
        'icon': Icons.tune_rounded,
        'color': const Color(0xFF4C566A),
        'bg': const Color(0xFFEDEFF3),
        'target': const SystemSettingsScreen(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'PLATFORM OPERATIONS & MODULES',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B8095),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Direct Access',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D5A92),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final mod = modules[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => mod['target'] as Widget,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: mod['bg'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          mod['icon'] as IconData,
                          size: 18,
                          color: mod['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mod['title'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF03253B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              mod['subtitle'] as String,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF6B8095),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemAuditFeed(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SYSTEM AUDIT FEED',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B8095),
                letterSpacing: 0.8,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuditLogsScreen()),
                );
              },
              child: const Text(
                'Live Feed →',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF225B8E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Feed Item 1: Trade License Verified
        _buildAuditItem(
          icon: Icons.badge_outlined,
          iconBg: const Color(0xFFE2F0FD),
          iconColor: const Color(0xFF28649E),
          title: 'Trade License Verified',
          time: '3m ago',
          subtitle: 'Mumbai Gadget Hub (SL-9081) KYC verified by Mod_3',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AuditLogsScreen()),
            );
          },
        ),

        const SizedBox(height: 8),

        // Feed Item 2: Refund Auto-Confirmed
        _buildAuditItem(
          icon: Icons.attach_money_rounded,
          iconBg: const Color(0xFFF6EEDB),
          iconColor: const Color(0xFF75571E),
          title: 'Refund Auto-Confirmed',
          time: '12m ago',
          subtitle: '₹ 4,200 credited to Buyer #8490 (RMA courier deliver...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReturnsAndDisputesScreen()),
            );
          },
        ),

        const SizedBox(height: 8),

        // Feed Item 3: Inventory Sync Burst
        _buildAuditItem(
          icon: Icons.sync_alt_rounded,
          iconBg: const Color(0xFFE2F0FD),
          iconColor: const Color(0xFF28649E),
          title: 'Inventory Sync Burst',
          time: '27m ago',
          subtitle: 'Apex Mobile Ltd updated 310 SKUs across 4 warehou...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryOversightScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuditItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF7A8E9F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF556F88),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
