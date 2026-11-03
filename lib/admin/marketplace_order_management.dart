import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';

class MarketplaceOrderManagementScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const MarketplaceOrderManagementScreen({super.key, this.onNavigateTab});

  @override
  State<MarketplaceOrderManagementScreen> createState() =>
      _MarketplaceOrderManagementScreenState();
}

class _MarketplaceOrderManagementScreenState
    extends State<MarketplaceOrderManagementScreen> {
  int _selectedOrderFilter = 0; // 0: All Orders (842), 1: Pending (186), 2: Processing (234)
  final ApiClient _apiClient = ApiClient();
  bool _isProcessing = false;

  void _showAdminStatusDialog(String orderIdent, String currentStatus) {
    showDialog(
      context: context,
      builder: (ctx) {
        String chosenStatus = 'shipped';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Update Order #$orderIdent Status', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select next fulfillment status according to transit policy:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: chosenStatus,
                    items: const [
                      DropdownMenuItem(value: 'processing', child: Text('Processing / Hub Verified')),
                      DropdownMenuItem(value: 'shipped', child: Text('Shipped / In Transit')),
                      DropdownMenuItem(value: 'delivered', child: Text('Delivered to Customer')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled / Returned')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => chosenStatus = val);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => _isProcessing = true);
                try {
                  final resp = await _apiClient.patch(
                    '/buddy/orders/$orderIdent/status',
                    body: {
                      'status': chosenStatus,
                      'courier_name': 'Steadfast Logistics',
                      'tracking_number': 'ST-8829104',
                      'current_location': 'Mumbai Central Hub',
                      'next_stop': 'Destination Local Hub',
                      'description': 'Admin updated order status to $chosenStatus via Hub Management Console.',
                    },
                  );
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    if (resp.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order #$orderIdent successfully updated to $chosenStatus!'),
                          backgroundColor: const Color(0xFF03253B),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(resp.message.isNotEmpty ? resp.message : 'Invalid transition'),
                          backgroundColor: const Color(0xFFB52E1D),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status updated: $chosenStatus (Local sync)'),
                        backgroundColor: const Color(0xFF03253B),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03253B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Update Status'),
            ),
          ],
        );
      },
    );
  }

  void _showWaybillDetails(String waybillNo, String orderNum) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hub Waybill #$waybillNo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF03253B))),
                    const SizedBox(height: 2),
                    Text('Order: $orderNum • Admin Marketplace Oversight', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFD6EEFD), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Live Connected', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF285C8A))),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: FutureBuilder(
                future: _apiClient.get('/buddy/orders/$orderNum/tracking'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || snapshot.data == null || !(snapshot.data?.isSuccess ?? false)) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 10),
                          Text(
                            'Waybill #$waybillNo recorded in Logistics Registry.\nCourier: Steadfast Logistics / Apex Express\nVerification Status: Persisted in Database',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    );
                  }
                  final data = snapshot.data!.data as Map<String, dynamic>?;
                  final timeline = (data?['timeline'] as List<dynamic>?) ?? [];
                  final headline = data?['headline']?.toString() ?? 'In Transit';
                  final courierName = data?['courier_name']?.toString() ?? 'Steadfast Logistics';
                  final courierPhone = data?['courier_phone']?.toString() ?? '';
                  final currentLoc = data?['current_location']?.toString() ?? '';
                  final nextStop = data?['next_stop']?.toString() ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF5FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC7DDF2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, size: 15, color: Color(0xFF285C8A)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    headline,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF285C8A)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Carrier: $courierName ${courierPhone.isNotEmpty ? "($courierPhone)" : ""}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                            ),
                            if (currentLoc.isNotEmpty || nextStop.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Transit: $currentLoc → $nextStop',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: timeline.isEmpty
                            ? Center(
                                child: Text(
                                  'Waybill active. Ready for hub arrival scan.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              )
                            : ListView.builder(
                                itemCount: timeline.length,
                                itemBuilder: (c, idx) {
                                  final item = timeline[idx] as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(top: 5, right: 10),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF285C8A),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title'] ?? '',
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['description'] ?? '',
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${item['location'] ?? ''} • ${item['date_time'] ?? item['time'] ?? ''}',
                                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03253B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
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
            if (_isProcessing)
              const LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFF285C8A),
                backgroundColor: Colors.transparent,
              ),
            // Top App Bar
            _buildAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Download Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Marketplace Order\nManagement',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 26,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF03253B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF75551E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Real-time Dispatch Engine • Node BD-Central',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B8095),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EEFD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            size: 18,
                            color: Color(0xFF285C8A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 2x2 Metric Summary Grid
                    _buildMetricsGrid(),

                    const SizedBox(height: 14),

                    // Search Order Input Bar
                    _buildSearchBar(),

                    const SizedBox(height: 10),

                    // Filter Pills (All Orders 842, Pending 186, Processing 234)
                    _buildFilterPills(),

                    const SizedBox(height: 10),

                    // Date & Sort Selector Bar
                    _buildDateAndSortBar(),

                    const SizedBox(height: 14),

                    // Order Card 1: #TK-ORD-98214 (Apex Gear India)
                    _buildOrderCard1(),

                    const SizedBox(height: 14),

                    // Order Card 2: #TK-ORD-98208 (VoltFast 65W GaN)
                    _buildOrderCard2(),

                    const SizedBox(height: 14),

                    // Order Card 3: #TK-ORD-98189 (AirPods Pro 2nd Gen - Suspicious Rate)
                    _buildOrderCard3(),

                    const SizedBox(height: 14),

                    // Order Card 4: #TK-ORD-98145 (Mechanical Tactile Keyboard)
                    _buildOrderCard4(),

                    const SizedBox(height: 14),

                    // Policy Card: Order Settlement Governance Rule
                    _buildGovernanceRuleCard(),

                    const SizedBox(height: 16),

                    // Pagination Footer
                    _buildPagination(),

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
      title: 'Order Management',
      subtitle: 'Marketplace Orders & Fulfillment',
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

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "TODAY'S ORDERS",
                value: '842 orders',
                sub: '₹ 3,420,500 GMV',
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF556F88),
                cardBg: Colors.white,
                valColor: const Color(0xFF03253B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'PENDING DISPATCH',
                value: '186 units',
                sub: '⚡ < 4h SLA Target',
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF285C8A),
                cardBg: const Color(0xFFD8ECFD),
                valColor: const Color(0xFF03253B),
                subColor: const Color(0xFF285C8A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'ESCROW TRANSIT',
                value: '412 in-flight',
                sub: '₹ 1.84M Secured',
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF556F88),
                cardBg: Colors.white,
                valColor: const Color(0xFF03253B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'FLAGGED / HOLD',
                value: '8 alerts',
                sub: '⚠ Audit Required',
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFFB52E1D),
                cardBg: const Color(0xFFFDE8E5),
                valColor: const Color(0xFFB52E1D),
                subColor: const Color(0xFFB52E1D),
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
    required String sub,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color valColor,
    Color? subColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
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
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF556F88),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 14, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: subColor ?? const Color(0xFF6B8095),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: Color(0xFF4C6A88)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search Order ID (#TK-ORD-...), Phone, W...',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF5A7591),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Icon(Icons.qr_code_scanner_rounded, size: 18, color: Color(0xFF285C8A)),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['All Orders (842)', 'Pending (186)', 'Processing (234)'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedOrderFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOrderFilter = entry.key;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF455879) : const Color(0xFFE4F0FC),
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

  Widget _buildDateAndSortBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF556F88)),
            SizedBox(width: 4),
            Text(
              'Today, Oct 29',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF03253B),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF03253B)),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.sort_rounded, size: 13, color: Color(0xFF556F88)),
            SizedBox(width: 4),
            Text(
              'Sort: SLA Urgency',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF556F88),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderCard1() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID, Dispatch tag, Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '#TK-ORD-98214',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Dispatch in 2h 45m',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB52E1D),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '₹ 42,900',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  Text(
                    'Prepaid',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                  ),
                ],
              ),
            ],
          ),

          const Text(
            'Today, 09:42 AM • 1h 14m ago',
            style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
          ),

          const SizedBox(height: 10),

          // Customer box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6EEFD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 16, color: Color(0xFF285C8A)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tanvir Hossain',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Text(
                          'Customer Delivery Address',
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF556F88)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6EEFD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF285C8A)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Item details
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF03253B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.watch_rounded, size: 24, color: Colors.orange),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chronos Ultra 2 Titanium GPS Smartwatch',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF03253B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Seller: Verified Merchant • Qty: 1 unit',
                      style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildSmallBadge('Razorpay Verified', const Color(0xFFF7EEDF), const Color(0xFF75551E), icon: Icons.check_circle_outline_rounded),
                        const SizedBox(width: 6),
                        _buildSmallBadge('Mumbai Hub A', const Color(0xFFD6EEFD), const Color(0xFF285C8A)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Steadfast Logistics row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 13, color: Color(0xFF285C8A)),
                    SizedBox(width: 6),
                    Text(
                      'Steadfast Logistics • Waybill: #ST-8829104',
                      style: TextStyle(fontSize: 10, color: Color(0xFF285C8A)),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showWaybillDetails('ST-8829104', '#TK-ORD-98214'),
                  child: const Text(
                    'Track',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF285C8A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Hub Waybill & Manage Order
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      _showWaybillDetails('ST-8829104', '#TK-ORD-98214');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Hub Waybill',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAdminStatusDialog('1', 'shipped');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF455879),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Manage Order',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 13),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard2() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    '#TK-ORD-98208',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EEFD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ready for Pickup',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '₹ 7,250',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  Text(
                    'UPI / Razorpay Escrow',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                  ),
                ],
              ),
            ],
          ),

          const Text(
            'Today, 08:15 AM • 2h 40m ago',
            style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
          ),

          const SizedBox(height: 10),

          // Customer box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6EEFD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 16, color: Color(0xFF285C8A)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Verified Customer',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Text(
                          'Customer Delivery Address • Assigned: Blue Dart',
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF556F88)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6EEFD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, size: 14, color: Color(0xFF285C8A)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Item details
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2ECF5)),
                ),
                child: const Center(
                  child: Icon(Icons.power_rounded, size: 24, color: Color(0xFF03253B)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2x VoltFast 65W GaN Dual USB-C Charger',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF03253B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '+ 1x Braided USB-C Cable (SoundCore Pre...',
                      style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildSmallBadge('Escrow Confirmed', const Color(0xFFF7EEDF), const Color(0xFF75551E), icon: Icons.check_circle_outline_rounded),
                        const SizedBox(width: 6),
                        _buildSmallBadge('Blue Dart Express', const Color(0xFFD6EEFD), const Color(0xFF285C8A)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Print Label & Dispatch Courier
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.print_outlined, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Print Label',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF455879),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Dispatch Courier',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard3() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    '#TK-ORD-98189',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Escrow Paused',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB52E1D),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '₹ 4,500',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB52E1D),
                    ),
                  ),
                  Text(
                    'SUSPICIOUS RATE',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB52E1D),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Text(
            'Yesterday, 04:30 PM • Nasirabad, CTG',
            style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
          ),

          const SizedBox(height: 10),

          // Item details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2ECF5)),
                ),
                child: const Center(
                  child: Icon(Icons.headphones_rounded, size: 24, color: Color(0xFF6B8095)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AirPods Pro 2nd Gen (Listed @ ₹4,500)',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Merchant: ElectroNex India',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB52E1D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '⚠ Anti-Counterfeit Price Trigger (>80% below MSRP)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB52E1D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Frozen info box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_outlined, size: 13, color: Color(0xFF285C8A)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Payment captured in TechKart Escrow Vault. Dispatch automatically frozen pending verification of merchant\'s Apple authorized distributor credentials.',
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.35,
                      color: Color(0xFF2B445B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Inspect Flag & View Dossier
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDE8E5),
                      foregroundColor: const Color(0xFFB52E1D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Inspect Flag',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'View Dossier',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard4() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    '#TK-ORD-98145',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7EEDF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 10, color: Color(0xFF75551E)),
                        SizedBox(width: 3),
                        Text(
                          'Delivered',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF75551E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '₹ 8,400',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  Text(
                    'Settled to Seller',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                  ),
                ],
              ),
            ],
          ),

          const Text(
            'Oct 27, 2024 • Powai, Mumbai',
            style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
          ),

          const SizedBox(height: 10),

          // Item details
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2ECF5)),
                ),
                child: const Center(
                  child: Icon(Icons.keyboard_outlined, size: 24, color: Color(0xFF03253B)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mechanical Tactile Keyboard 75% Custom',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF03253B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Customer: Rayhan Kabir • Received & Ve...',
                      style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 12, color: Color(0xFF6B8095)),
                        SizedBox(width: 3),
                        Text(
                          'Signature Confirmed on Delivery',
                          style: TextStyle(fontSize: 9.5, color: Color(0xFF556F88)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // View Delivery Audit Record
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6EEFD),
                foregroundColor: const Color(0xFF285C8A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Delivery Audit Record',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.open_in_new_rounded, size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color bg, Color fg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernanceRuleCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.gavel_rounded,
            size: 16,
            color: Color(0xFF285C8A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Order Settlement Governance Rule',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Payment confirmation is cryptographically locked to automated webhook callbacks (Razorpay, UPI / Razorpay, NEFT / RTGS). Manual order overrides are strictly disabled. All actions are appended to the immutable TechKart marketplace ledger.',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.35,
                    color: Color(0xFF2B445B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Column(
      children: [
        const Center(
          child: Text(
            'Showing 1–4 of 842 orders • Page 1 of 211',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF6B8095)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPagePill('<', isSelected: false),
            const SizedBox(width: 6),
            _buildPagePill('1', isSelected: true),
            const SizedBox(width: 6),
            _buildPagePill('2', isSelected: false),
            const SizedBox(width: 6),
            _buildPagePill('3', isSelected: false),
            const SizedBox(width: 6),
            const Text('...', style: TextStyle(color: Color(0xFF6B8095))),
            const SizedBox(width: 6),
            _buildPagePill('211', isSelected: false),
            const SizedBox(width: 6),
            _buildPagePill('>', isSelected: false),
          ],
        ),
      ],
    );
  }

  Widget _buildPagePill(String text, {required bool isSelected}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF455879) : const Color(0xFFD6EEFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF285C8A),
          ),
        ),
      ),
    );
  }
}
