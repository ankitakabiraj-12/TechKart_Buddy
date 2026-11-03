import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import '../seller/product_service.dart';

class ProductCatalogScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const ProductCatalogScreen({super.key, this.onNavigateTab});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  int _selectedFilter = 1; // 0: All 38.4k, 1: Queue 42, 2: Flagged 6
  int _selectedCategory = 0; // 0: Wearables, 1: Audio & Sound, 2: Chargers & Power

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
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
                    // Queue Priority Alert Banner
                    _buildPriorityAlertBanner(),

                    const SizedBox(height: 12),

                    // Search Bar
                    _buildSearchBar(),

                    const SizedBox(height: 10),

                    // Filter Pills (All 38.4k, Queue 42, Flagged 6)
                    _buildFilterPills(),

                    const SizedBox(height: 10),

                    // Category Filter Pills (CATEGORY: Wearables, Audio & Sound, Chargers & Power)
                    _buildCategoryPills(),

                    const SizedBox(height: 14),

                    // Card 1: Chronos Ultra 2... (Pending Verification)
                    _buildProductCard1(context),

                    const SizedBox(height: 14),

                    // Card 2: AirPods Pro 2nd Gen... (Counterfeit Report Flag)
                    _buildProductCard2(context),

                    const SizedBox(height: 14),

                    // Card 3: VoltFast 65W GaN... (Active & In Stock)
                    _buildProductCard3(context),

                    const SizedBox(height: 14),

                    // Moderation Activity Log Banner
                    _buildModerationLogBanner(),

                    const SizedBox(height: 14),

                    // Pagination (Showing 1–3 of 42 pending   <-  Next Page ->)
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
      title: 'Product Catalog',
      subtitle: 'Listing & Verification Queue',
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

  Widget _buildPriorityAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFB52E1D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Queue Priority Alert',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Action Required',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB52E1D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2B445B),
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(
                        text: '42 listings ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: 'awaiting clearance • '),
                      TextSpan(
                        text: '6 listings flagged ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB52E1D),
                        ),
                      ),
                      TextSpan(
                        text: 'for brand counterfeit or policy violation.',
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
                    'Search SKU, Product Title, Brand, or Merc...',
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

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPillItem(0, 'All', '38.4k'),
          const SizedBox(width: 8),
          _buildPillItem(1, 'Queue', '42', hasIcon: Icons.inventory_2_outlined),
          const SizedBox(width: 8),
          _buildPillItem(2, 'Flagged', '6', hasIcon: Icons.flag_outlined),
        ],
      ),
    );
  }

  Widget _buildPillItem(int index, String label, String count,
      {IconData? hasIcon}) {
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
            if (hasIcon != null) ...[
              Icon(
                hasIcon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xFF28547C),
              ),
              const SizedBox(width: 4),
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

  Widget _buildCategoryPills() {
    final categories = ['Wearables', 'Audio & Sound', 'Chargers & Power'];
    return Row(
      children: [
        const Text(
          'CATEGORY: ',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B8095),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.asMap().entries.map((entry) {
                final isSelected = _selectedCategory == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = entry.key;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF7EEDF)
                            : const Color(0xFFE4F0FC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF75551E)
                              : const Color(0xFF28547C),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard1(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          // Header: Pending Verification & SKU
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EEFD),
                  borderRadius: BorderRadius.circular(10),
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
                    const SizedBox(width: 4),
                    const Text(
                      'Pending Verification',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'SKU: TK-WRS-8901',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B8095),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Thumbnail + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Watch thumbnail
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF03253B),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.watch_rounded,
                        size: 38,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '49mm',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEARABLES & SMARTWATCHES',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Chronos\nUltra 2...',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(
                          Icons.storefront_outlined,
                          size: 11,
                          color: Color(0xFF6B8095),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Verified Merchant ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Text(
                          '(TK-SLR-11042)',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF6B8095),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text(
                          '₹ 42,900',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '₹ 45,000\nMSRP',
                          style: TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFF6B8095),
                            decoration: TextDecoration.lineThrough,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Verification checklist rows
          _buildSpecRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Serial Authentication Verified',
            trailingText: 'PASSED',
            trailingColor: const Color(0xFF107C41),
          ),
          const SizedBox(height: 4),
          _buildSpecRow(
            icon: Icons.description_outlined,
            label: 'Brand Authorization Document',
            trailingText: 'Pass (PDF) ↗',
            trailingColor: const Color(0xFF285C8A),
            isLink: true,
          ),
          const SizedBox(height: 4),
          _buildSpecRow(
            icon: Icons.fact_check_outlined,
            label: 'Spec Sheet Compliance',
            trailingText: '100% Match',
            trailingColor: const Color(0xFF03253B),
          ),

          const SizedBox(height: 12),

          // Full-width Approve Listing Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  // Connect to Product ID 27 (Pending review demo product) or generic queue
                  final res = await ProductService.reviewProduct(
                    27,
                    action: 'approve',
                    autoPublish: true,
                    notes: 'Compliance clearance passed. Product approved for TechKart marketplace.',
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(res.isSuccess ? 'Listing Approved & Published to Marketplace!' : res.message),
                      backgroundColor: res.isSuccess ? const Color(0xFF107C41) : Colors.redAccent,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03253B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Approve Listing',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Request Spec Edit & Reject Listing Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final res = await ProductService.reviewProduct(
                          27,
                          action: 'reject',
                          notes: 'Specification edit requested: Please verify battery capacity and official trade warranty certificate.',
                        );
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(res.isSuccess ? 'Specification edit requested from merchant.' : res.message),
                            backgroundColor: const Color(0xFF285C8A),
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
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
                      'Request Spec Edit',
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
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final res = await ProductService.reviewProduct(
                          27,
                          action: 'reject',
                          notes: 'Rejected by Compliance Desk: Missing valid trade license and authorized brand distribution contract.',
                        );
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(res.isSuccess ? 'Listing Rejected. Seller notified with feedback.' : res.message),
                            backgroundColor: const Color(0xFFB33020),
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDE8E5),
                      foregroundColor: const Color(0xFFB33020),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Reject Listing',
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

  Widget _buildProductCard2(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          // Header: Counterfeit Report Flag & SKU
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 11,
                      color: Color(0xFFB52E1D),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Counterfeit Report Flag',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB52E1D),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'SKU: TK-AUD-4421',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B8095),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Thumbnail + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Earbuds thumbnail
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: const Color(0xFFE2ECF5)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.headphones_rounded,
                        size: 38,
                        color: Color(0xFF6B8095),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB52E1D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ALERT',
                        style: TextStyle(
                          fontSize: 7.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AUDIO & EARBUDS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'AirPods Pro\n2nd Gen...',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(
                          Icons.storefront_outlined,
                          size: 11,
                          color: Color(0xFF6B8095),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'ElectroNex Bangla... ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Text(
                          '(TK-SLR-10392)',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF6B8095),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '₹ 4,500',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB52E1D),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '₹ 28,500\nMSRP',
                          style: TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFF6B8095),
                            decoration: TextDecoration.lineThrough,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '(-84%)',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB52E1D),
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

          const SizedBox(height: 10),

          // Critical Risk Assessment Warning Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: Color(0xFFB52E1D),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Critical Risk Assessment',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB52E1D),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'High Risk: Suspected Counterfeit reported by brand copyright holder. Unauthorized distributor using trademarked assets. Listed price is 80%+ under MAP.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    color: Color(0xFF334B5E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Delist & Ban SKU Button (Red)
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final res = await ProductService.reviewProduct(
                    28,
                    action: 'reject',
                    notes: 'Delisted & Suspended: Suspected counterfeit reported by brand copyright holder. Trademark violation.',
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(res.isSuccess ? 'SKU Delisted & Suspended from Marketplace.' : res.message),
                      backgroundColor: const Color(0xFFBA2818),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA2818),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block_rounded, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Delist & Ban SKU',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Inspect Evidence & Request Invoice
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
                        Icon(Icons.visibility_outlined, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Inspect Evidence',
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
                        Icon(Icons.receipt_long_outlined, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Request Invoice',
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

  Widget _buildProductCard3(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          // Header: Active & In Stock (84 units) & SKU
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EEDF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      size: 11,
                      color: Color(0xFF75551E),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Active & In Stock (84 units)',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF75551E),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'SKU: TK-PWR-3312',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B8095),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Thumbnail + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Charger thumbnail
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: const Color(0xFFE2ECF5)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.power_rounded,
                        size: 38,
                        color: Color(0xFF03253B),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'GaN 65W',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'POWER & CHARGERS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'VoltFast\n65W GaN...',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(
                          Icons.storefront_outlined,
                          size: 11,
                          color: Color(0xFF6B8095),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'SoundCore Premie... ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Text(
                          '(TK-SLR-10928)',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF6B8095),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '₹ 3,250',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EEFD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BSTI\nCertified',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF285C8A),
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Actions: View Live Listing & Audit History
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
                        Icon(Icons.visibility_outlined, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'View Live Listing',
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
                        Icon(Icons.history_rounded, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Audit History',
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

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String trailingText,
    required Color trailingColor,
    bool isLink = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: const Color(0xFF556F88)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF556F88)),
            ),
          ],
        ),
        Text(
          trailingText,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: trailingColor,
            decoration: isLink ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildModerationLogBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFCFE8FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 16,
              color: Color(0xFF285C8A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Moderation Activity Log',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF03253B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '118 items reviewed in past 24h by Compliance Desk',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF556F88),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Color(0xFF556F88),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Showing 1–3 of 42 pending',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 11,
            color: Color(0xFF556F88),
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.arrow_back_rounded,
              size: 14,
              color: Color(0xFFB0C4D6),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2ECF5)),
              ),
              child: const Row(
                children: [
                  Text(
                    'Next Page',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: Color(0xFF03253B),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
