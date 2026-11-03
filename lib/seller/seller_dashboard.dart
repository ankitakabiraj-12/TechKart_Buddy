import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import 'seller_top_bar.dart';
import 'add_product.dart';
import 'inventory_management.dart';
import 'earnings.dart';
import 'notification.dart';
import 'seller_reviews.dart';
import 'seller_returns.dart';



// SellerDashboard shell removed — navigation is now handled by SellerBottomNav
// in bottom_navigation.dart, which hosts SellerHomeTab as tab 0.

// ─────────────────────────── HOME TAB ───────────────────────────

class SellerHomeTab extends StatefulWidget {
  final void Function(int) onNavigate;
  const SellerHomeTab({super.key, required this.onNavigate});

  @override
  State<SellerHomeTab> createState() => _SellerHomeTabState();
}

class _SellerHomeTabState extends State<SellerHomeTab> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/buddy/seller/dashboard');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (res.isSuccess && res.data != null) {
            _dashboardData = res.data as Map<String, dynamic>;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamList = (_dashboardData?['dispatch_stream'] as List<dynamic>?) ?? [];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchDashboard,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar(context)),
            if (_isLoading)
              const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2)),
            SliverToBoxAdapter(child: _buildStoreRow()),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildDispatchAlert()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildMetricsGrid()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildCatalogSettlement(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildOperationsHub(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildWeeklyPerformance()),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildPriorityDispatchHeader()),
            if (streamList.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDFECF7), width: 1),
                    ),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF8DA5C0)),
                          SizedBox(height: 8),
                          Text(
                            'All current orders dispatched!',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF072138)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'New customer orders will stream into priority dispatch automatically.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = streamList[index] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildDynamicOrderStreamCard(item, index),
                    );
                  },
                  childCount: streamList.length,
                ),
              ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final storeName = _dashboardData?['store']?['store_name'] ?? 'My Store';
    final metrics = _dashboardData?['metrics'] as Map<String, dynamic>?;
    final unreadAlerts = (metrics?['unread_alerts_count'] as num?)?.toInt() ?? 0;

    return SellerTopBar(
      title: 'TechKart Buddy',
      subtitle: '$storeName · Live',
      isHome: true,
      showNotification: true,
      showProfile: true,
      notificationCount: unreadAlerts,
      onNotificationTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SellerNotificationScreen(isStandaloneScreen: true),
          ),
        );
        _fetchDashboard();
      },
      onProfileTap: () => widget.onNavigate(3),
    );
  }

  Widget _buildStoreRow() {
    final storeName = _dashboardData?['store']?['store_name'] ?? 'My Store';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Store Status
          Row(
            children: [
              Text(
                storeName,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF072138),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF4C5D70)),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EFF9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Color(0xFF28384C)),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchAlert() {
    final metrics = _dashboardData?['metrics'];
    final urgentCount = metrics?['urgent_orders_count'] ?? metrics?['pending_confirmation'] ?? 3;
    final streamList = (_dashboardData?['dispatch_stream'] as List<dynamic>?) ?? [];
    final sampleOrderNums = streamList.take(3).map((it) => '#${it['order_number']}').join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFD99A), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE8A3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF7B4B00)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dispatch Cut-off Alert',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3B2200),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$urgentCount orders require packing and handover verification before daily cutoff.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: Color(0xFF5A3800),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sampleOrderNums.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Orders: $sampleOrderNums',
                      style: TextStyle(fontSize: 10.5, color: Colors.brown.shade600),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '06:00 PM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => widget.onNavigate(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF03142E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Pack Now →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = _dashboardData?['metrics'];
    final todaysOrders = metrics?['todays_orders'] ?? 0;
    final totalOrders = metrics?['total_orders'] ?? 0;
    final pendingOrders = metrics?['pending_confirmation'] ?? 0;
    final readyOrders = metrics?['ready_to_ship'] ?? 0;
    final grossRevenue = metrics?['gross_revenue'] ?? 0.0;
    final units = metrics?['delivered_units'] ?? 0;
    final topProduct = metrics?['top_selling_product']?.toString() ?? 'Chronos Ultra';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricTile(
              label: "Today's Orders",
              icon: Icons.local_shipping_outlined,
              value: '$todaysOrders Orders',
              sub: '$pendingOrders Pending • $readyOrders Ready',
              trending: '$totalOrders All-Time Orders',
              trendUp: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMetricTile(
              label: 'Gross Revenue',
              icon: Icons.attach_money_rounded,
              value: '₹ ${grossRevenue is num ? grossRevenue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') : grossRevenue}',
              sub: '$units units delivered',
              trending: '↑ Top: $topProduct',
              trendUp: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required IconData icon,
    required String value,
    required String sub,
    required String trending,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDFECF7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4C5D70),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 16, color: const Color(0xFF8DA5C0)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF072138),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 13,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  trending,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogSettlement(BuildContext context) {
    final metrics = _dashboardData?['metrics'];
    final active = metrics?['catalog_active'] ?? 0;
    final underReview = metrics?['under_review_count'] ?? 0;
    final lowStock = metrics?['low_stock_count'] ?? 0;
    final settlement = metrics?['next_settlement'] ?? 0;
    final bank = metrics?['bank_account'] ?? 'No Bank Attached';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onNavigate(1),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDFECF7), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Catalog Health',
                          style: TextStyle(fontSize: 11, color: Color(0xFF4C5D70)),
                        ),
                        Icon(Icons.inventory_2_outlined, size: 15, color: Color(0xFF8DA5C0)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$active Active',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF072138),
                      ),
                    ),
                    Text(
                      '$underReview under review',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFEF6C00)),
                        const SizedBox(width: 4),
                        Text(
                          '$lowStock Low stock alert',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFFEF6C00), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Earnings(isStandaloneScreen: true)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDFECF7), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Next Settlement',
                          style: TextStyle(fontSize: 11, color: Color(0xFF4C5D70)),
                        ),
                        Icon(Icons.account_balance_outlined, size: 15, color: Color(0xFF8DA5C0)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹ ${settlement is num ? settlement.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') : settlement}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF072138),
                      ),
                    ),
                    Text(
                      bank,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Direct Transfer',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsHub(BuildContext context) {
    final metrics = _dashboardData?['metrics'];
    final pendingCount = metrics?['pending_confirmation'] ?? metrics?['todays_orders'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDFECF7), width: 1),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Operations Hub',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072138),
                  ),
                ),
                Text(
                  'Shortcuts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF285688),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHubShortcut(
                  icon: Icons.add_box_outlined,
                  label: 'Add Product',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddProduct()),
                    );
                  },
                ),
                _buildHubShortcut(
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders ($pendingCount)',
                  badge: pendingCount > 0 ? pendingCount : null,
                  onTap: () => widget.onNavigate(2),
                ),
                _buildHubShortcut(
                  icon: Icons.warehouse_outlined,
                  label: 'Inventory',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InventoryManagement(isStandaloneScreen: true)),
                    );
                  },
                ),
                _buildHubShortcut(
                  icon: Icons.payments_outlined,
                  label: 'Earnings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Earnings(isStandaloneScreen: true)),
                    );
                  },
                ),
                _buildHubShortcut(
                  icon: Icons.rate_review_outlined,
                  label: 'Reviews',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellerReviewsScreen(isStandaloneScreen: true)),
                    );
                  },
                ),
                _buildHubShortcut(
                  icon: Icons.assignment_return_outlined,
                  label: 'Returns',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellerReturnsScreen(isStandaloneScreen: true)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubShortcut({
    required IconData icon,
    required String label,
    int? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF28384C)),
              ),
              if (badge != null)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374E65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPerformance() {
    final weekly = _dashboardData?['weekly_performance'] as Map<String, dynamic>?;
    final List<dynamic> rawBars = weekly?['chart_bars'] ?? [0.25, 0.35, 0.30, 0.45, 0.60, 0.70, 0.85];
    final List<double> values = rawBars.map((v) => (v is num) ? v.toDouble() : 0.30).toList();
    final List<dynamic> rawDays = weekly?['days'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Today'];
    final List<String> days = rawDays.map((d) => d.toString()).toList();
    final summaryText = weekly?['summary']?.toString() ?? 'Weekly sales volume aggregated live';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDFECF7), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      'Weekly Performance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF072138),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF2E7D32)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EFF8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '7 Days',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF285688)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              summaryText,
              style: const TextStyle(fontSize: 11, color: Color(0xFF4C5D70)),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (i) {
                  final isToday = i == days.length - 1;
                  final barHeight = i < values.length ? values[i] : 0.3;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 60 * barHeight.clamp(0.12, 1.0),
                            decoration: BoxDecoration(
                              color: isToday ? const Color(0xFF03142E) : const Color(0xFFBBD9F3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            days[i],
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                              color: isToday ? const Color(0xFF03142E) : const Color(0xFF8DA5C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDispatchHeader() {
    final metrics = _dashboardData?['metrics'];
    final urgentCount = metrics?['urgent_orders_count'] ?? metrics?['pending_confirmation'] ?? 0;
    final totalOrders = metrics?['total_orders'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Priority Dispatch Stream',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF072138),
            ),
          ),
          GestureDetector(
            onTap: () => widget.onNavigate(2),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                if (urgentCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$urgentCount\nUrgent',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD32F2F),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  'View all\n$totalOrders',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF285688),
                    height: 1.25,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF285688)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicOrderStreamCard(Map<String, dynamic> item, int index) {
    final orderNum = item['order_number']?.toString() ?? 'TK-00000';
    final paymentMethod = item['payment_method']?.toString().toUpperCase() ?? 'PREPAID';
    final status = (item['status']?.toString() ?? 'pending').toLowerCase();
    final urgentTag = item['urgent_tag']?.toString() ?? 'Priority Handling';
    final isUrgent = item['is_urgent'] == true;
    final title = item['title']?.toString() ?? 'TechKart Product';
    final variantDesc = item['variant_desc']?.toString() ?? 'Standard · Qty: 1';
    final qty = item['quantity'] ?? 1;
    final price = item['price'] ?? 0.0;
    final imageUrl = item['image_url']?.toString() ?? '';
    final courierName = item['courier_name']?.toString() ?? 'Standard Courier';
    final nextAction = item['next_action']?.toString() ?? 'Process Order';

    Color badgeBg;
    Color badgeTextColor;
    if (status == 'delivered') {
      badgeBg = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF2E7D32);
    } else if (status == 'shipped') {
      badgeBg = const Color(0xFFE1F5FE);
      badgeTextColor = const Color(0xFF0288D1);
    } else if (status == 'processing') {
      badgeBg = const Color(0xFFFFF3E0);
      badgeTextColor = const Color(0xFFE65100);
    } else {
      badgeBg = const Color(0xFFE3F2FD);
      badgeTextColor = const Color(0xFF1565C0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUrgent ? const Color(0xFFFFCDD2) : const Color(0xFFDFECF7),
            width: isUrgent ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$orderNum',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072138),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$paymentMethod · ${status.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFFD32F2F)),
                      const SizedBox(width: 3),
                      Text(
                        urgentTag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Product info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFEFF5FD),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Icon(
                              Icons.devices_other_rounded,
                              size: 28,
                              color: Color(0xFF8DA5C0),
                            ),
                          )
                        : const Icon(
                            Icons.devices_other_rounded,
                            size: 28,
                            color: Color(0xFF8DA5C0),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A2038),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$variantDesc · Qty: $qty',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF5A6B7C)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${price is num ? price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') : price}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF072138),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Courier & Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 13, color: Color(0xFF4C7DA8)),
                    const SizedBox(width: 4),
                    Text(
                      courierName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4C7DA8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => widget.onNavigate(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF03142E),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          nextAction,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }
}
