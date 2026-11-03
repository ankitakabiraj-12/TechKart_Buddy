import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';

class InventoryOversightScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const InventoryOversightScreen({super.key, this.onNavigateTab});

  @override
  State<InventoryOversightScreen> createState() =>
      _InventoryOversightScreenState();
}

class _InventoryOversightScreenState extends State<InventoryOversightScreen> {
  int _selectedFilter = 0; // 0: All Stock 38.4k, 1: Low Stock Alert 148, 2: Out of Stock
  final String _selectedFacility =
      'All Facilities (Mumbai Hub A, Bengaluru, Delhi)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            // Main Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LIVE SYNC • MULTI-NODE Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6EEFD),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF285C8A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'LIVE SYNC • MULTI-NODE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF285C8A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title & Download Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'Inventory & Stock\nOversight',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 26,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                            ),
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

                    const SizedBox(height: 6),

                    // Subtitle
                    const Text(
                      'Cross-facility reserve tracking, real-time escrow buffers, and SLA breach monitors across all authorized merchants.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF556F88),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2x2 Metric Cards Grid
                    _buildMetricsGrid(),

                    const SizedBox(height: 14),

                    // Search SKU Input
                    _buildSearchBar(),

                    const SizedBox(height: 10),

                    // Facility Selector Pill Bar
                    _buildFacilitySelector(),

                    const SizedBox(height: 10),

                    // Stock Filter Tabs (All Stock 38.4k, Low Stock Alert 148, Out of...)
                    _buildStockFilterPills(),

                    const SizedBox(height: 14),

                    // Card 1: Chronos Ultra 2 Titanium... (Healthy Stock)
                    _buildStockCard1(),

                    const SizedBox(height: 12),

                    // Card 2: VoltFast 65W GaN Dual... (4 Units Left)
                    _buildStockCard2(),

                    const SizedBox(height: 12),

                    // Card 3: QuantumSound ANC... (0 Available)
                    _buildStockCard3(),

                    const SizedBox(height: 12),

                    // Card 4: MagCharge 15W Qi2... (Healthy Stock)
                    _buildStockCard4(),

                    const SizedBox(height: 14),

                    // Blue Policy Card: AUTHORIZED STOCK CORRECTION PROTOCOL
                    _buildPolicyCard(),

                    const SizedBox(height: 16),

                    // Pagination Footer (< Previous   Page 1 of 9,605   Next >)
                    _buildPagination(),

                    const SizedBox(height: 8),

                    // Footer text
                    const Center(
                      child: Text(
                        'Showing 1–4 of 38,420 monitored SKUs across all regions',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B8095),
                        ),
                      ),
                    ),

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
      title: 'Inventory Oversight',
      subtitle: 'Stock Levels & Multi-Facility Warehousing',
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(2); // Go to Products tab
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
                title: 'Monitored SKUs',
                value: '38,420',
                sub: '1,420 active merchants',
                icon: Icons.account_tree_outlined,
                iconColor: const Color(0xFF556F88),
                valueColor: const Color(0xFF03253B),
                cardBg: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Low / Depleted',
                value: '148 SKUs',
                sub: '< 5 units critical alert',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFB52E1D),
                valueColor: const Color(0xFFB52E1D),
                subColor: const Color(0xFFB52E1D),
                cardBg: const Color(0xFFFDE8E5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Cart / Escrow Buffer',
                value: '2,314',
                sub: 'Holding buffer (15m TTL)',
                icon: Icons.shopping_basket_outlined,
                iconColor: const Color(0xFF285C8A),
                valueColor: const Color(0xFF03253B),
                cardBg: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'In-Transit Units',
                value: '5,820',
                sub: 'Mumbai Hub & Regions',
                icon: Icons.local_shipping_outlined,
                iconColor: const Color(0xFF556F88),
                valueColor: const Color(0xFF03253B),
                cardBg: Colors.white,
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
    required Color valueColor,
    Color? subColor,
    required Color cardBg,
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
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF556F88),
                ),
              ),
              Icon(icon, size: 15, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: subColor ?? const Color(0xFF6B8095),
            ),
          ),
        ],
      ),
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
            child: const Row(
              children: [
                Icon(Icons.search_rounded, size: 18, color: Color(0xFF4C6A88)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search SKU, Product title, or Seller ID...',
                    style: TextStyle(
                      fontSize: 12,
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFD6EEFD),
            borderRadius: BorderRadius.circular(21),
          ),
          child: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF285C8A)),
        ),
      ],
    );
  }

  Widget _buildFacilitySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warehouse_outlined,
                size: 14,
                color: Color(0xFF285C8A),
              ),
              const SizedBox(width: 6),
              const Text(
                'Facility: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF285C8A),
                ),
              ),
              Text(
                _selectedFacility,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Color(0xFF285C8A),
          ),
        ],
      ),
    );
  }

  Widget _buildStockFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPillItem(0, 'All Stock', '38.4k'),
          const SizedBox(width: 8),
          _buildPillItem(1, 'Low Stock Alert', '148', hasDot: true),
          const SizedBox(width: 8),
          _buildPillItem(2, 'Out of Stock', '32', hasDot: true, dotColor: const Color(0xFFB52E1D)),
        ],
      ),
    );
  }

  Widget _buildPillItem(int index, String label, String count,
      {bool hasDot = false, Color? dotColor}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF455879) : const Color(0xFFE4F0FC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor ?? (isSelected ? Colors.white : const Color(0xFF75551E)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF28547C),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFCFE4F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF264969),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard1() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF03253B),
                  borderRadius: BorderRadius.circular(22),
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
                      'Chronos Ultra 2 Tita...',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Text(
                          'TK-WRS-8901',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF285C8A),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('•', style: TextStyle(color: Color(0xFF7A8D9F))),
                        SizedBox(width: 6),
                        Text(
                          'Apex Gea...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF556F88),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EEDF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF75551E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Healthy Stock',
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

          const SizedBox(height: 12),

          // 3 Quantity Cells (AVAILABLE: 48, RESERVED: 12, SAFETY BUFFER: 10)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildQuantityCell('AVAILABLE', '48', const Color(0xFF03253B)),
                _buildQuantityCell('RESERVED', '12', const Color(0xFF03253B)),
                _buildQuantityCell('SAFETY BUFFER', '10', const Color(0xFF03253B)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subtext: AR sync 2m ago • Auto threshold: 15     Mumbai Hub A
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.sync_rounded, size: 12, color: Color(0xFF6B8095)),
                  SizedBox(width: 4),
                  Text(
                    'AR sync 2m ago • Auto threshold: 15',
                    style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
                  ),
                ],
              ),
              Text(
                'Mumbai Hub A',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Action buttons: Inventory History & Audit Log
          Row(
            children: [
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Inventory History',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Audit Log',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  Widget _buildStockCard2() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(22),
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
                      'VoltFast 65W GaN Du...',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Text(
                          'TK-PWR-3312',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF285C8A),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('•', style: TextStyle(color: Color(0xFF7A8D9F))),
                        SizedBox(width: 6),
                        Text(
                          'SoundCore P...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF556F88),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EEDF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 11,
                      color: Color(0xFF75551E),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '4 Units Left',
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

          const SizedBox(height: 12),

          // 3 Quantity Cells (AVAILABLE: 4 (Red), RESERVED: 18, RE-ORDER PT: 25)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF4EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildQuantityCell('AVAILABLE', '4', const Color(0xFFB52E1D)),
                _buildQuantityCell('RESERVED', '18', const Color(0xFF03253B)),
                _buildQuantityCell('RE-ORDER PT', '25', const Color(0xFF03253B)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Runway alert banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.av_timer_rounded,
                  size: 13,
                  color: Color(0xFF285C8A),
                ),
                const SizedBox(width: 6),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 10, color: Color(0xFF285C8A)),
                    children: [
                      TextSpan(text: 'Runway: '),
                      TextSpan(
                        text: '~1.2 days ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: 'based on burn velocity (15 units/day)'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subtext: Banani Facility (TK-SLR-10928) ... SLA Level: Priority 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Banani Facility (TK-SLR-10928)',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
              ),
              Text(
                'SLA Level: Priority 1',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Notify Merchant & Inspect History
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF62594D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_active_outlined, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Notify Merchant',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Inspect History',
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

  Widget _buildStockCard3() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(22),
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
                      'QuantumSound ANC ...',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Text(
                          'TK-AUD-8821',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF285C8A),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('•', style: TextStyle(color: Color(0xFF7A8D9F))),
                        SizedBox(width: 6),
                        Text(
                          'ElectroNex...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF556F88),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 11,
                      color: Color(0xFFB52E1D),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '0 Available',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB52E1D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3 Quantity Cells (AVAILABLE: 0 (Red), RESERVED: 3 (Cancel), RE-ORDER PT: 20)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildQuantityCell('AVAILABLE', '0', const Color(0xFFB52E1D)),
                _buildQuantityCell('RESERVED', '3 (Cancel)', const Color(0xFF03253B)),
                _buildQuantityCell('RE-ORDER PT', '20', const Color(0xFF03253B)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Auto-paused notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: Color(0xFFB52E1D),
                ),
                const SizedBox(width: 6),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 10, color: Color(0xFF285C8A)),
                    children: [
                      TextSpan(text: 'Marketplace listing '),
                      TextSpan(
                        text: 'auto-paused ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: 'to prevent overselling SLA breach.'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subtext: Bengaluru Regional Hub ... Pending Stock Audit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Bengaluru Regional Hub',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
              ),
              Text(
                'Pending Stock Audit',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB52E1D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // View Stock Discrepancy & Audit Trail
          Row(
            children: [
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'View Stock Discrepancy',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6EEFD),
                      foregroundColor: const Color(0xFF285C8A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Audit Trail',
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

  Widget _buildStockCard4() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2ECF5)),
                ),
                child: const Center(
                  child: Icon(Icons.charging_station_rounded, size: 24, color: Color(0xFF03253B)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MagCharge 15W Qi2...',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Text(
                          'TK-PWR-7814',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF285C8A),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('•', style: TextStyle(color: Color(0xFF7A8D9F))),
                        SizedBox(width: 6),
                        Text(
                          'GadgetPla...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF556F88),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EEDF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF75551E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Healthy Stock',
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

          const SizedBox(height: 12),

          // 3 Quantity Cells (AVAILABLE: 112, RESERVED: 8, SAFETY BUFFER: 20)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildQuantityCell('AVAILABLE', '112', const Color(0xFF03253B)),
                _buildQuantityCell('RESERVED', '8', const Color(0xFF03253B)),
                _buildQuantityCell('SAFETY BUFFER', '20', const Color(0xFF03253B)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Mumbai Hub B • Dock Bay 04 ... Updated 14m ago
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.warehouse_outlined, size: 12, color: Color(0xFF6B8095)),
                  SizedBox(width: 4),
                  Text(
                    'Mumbai Hub B • Dock Bay 04',
                    style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
                  ),
                ],
              ),
              Text(
                'Updated 14m ago',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Inventory History & Warehouse Ledger
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6EEFD),
                foregroundColor: const Color(0xFF285C8A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: const Text(
                'Inventory History & Warehouse Ledger',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCell(String title, String val, Color valColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B8095),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            val,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, size: 16, color: Color(0xFF285C8A)),
              SizedBox(width: 8),
              Text(
                'AUTHORIZED STOCK CORRECTION\nPROTOCOL',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11.5,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'All physical count reconciliations, cycle write-offs, and virtual allocations require Level-2 Admin authorization and mandatory reason code logging under TechKart Marketplace Governance. Zero unlogged inventory adjustments permitted.',
            style: TextStyle(
              fontSize: 10.5,
              height: 1.4,
              color: Color(0xFF2B445B),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Compliance SLA: 24h',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF556F88),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Read Governance Charter',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF285C8A),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF285C8A)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE4F0FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.arrow_back_rounded, size: 13, color: Color(0xFF6B8095)),
              SizedBox(width: 4),
              Text(
                'Previous',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B8095),
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Page 1 of 9,605',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF03253B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF455879),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Text(
                'Next',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
