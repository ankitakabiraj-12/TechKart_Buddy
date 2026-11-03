import 'package:flutter/material.dart';
import 'seller_top_bar.dart';
import 'product_service.dart';

class InventoryManagement extends StatefulWidget {
  final bool isStandaloneScreen;
  const InventoryManagement({super.key, this.isStandaloneScreen = true});

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {
  int _filterIndex = 0;
  List<String> _filters = [
    'All Inventory',
    'Low Stock',
    'Out of Stock',
  ];

  bool _isLoading = false;
  final TextEditingController _searchCtrl = TextEditingController();

  // Metrics from API
  int _totalSkus = 0;
  int _availableUnits = 0;
  int _lowStockCount = 0;
  int _outOfStockCount = 0;
  int _reservedUnits = 0;

  // Editable stock counts for items
  List<_InventoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveInventory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveInventory() async {
    setState(() => _isLoading = true);
    String? statusParam;
    if (_filterIndex == 1) statusParam = 'low_stock';
    if (_filterIndex == 2) statusParam = 'out_of_stock';

    try {
      final res = await ProductService.getInventory(
        status: statusParam,
        search: _searchCtrl.text.trim().isNotEmpty ? _searchCtrl.text.trim() : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (res.isSuccess && res.data != null) {
          final data = res.data as Map<String, dynamic>;
          final metrics = data['metrics'] as Map<String, dynamic>? ?? {};
          final rawItems = data['items'] as List<dynamic>? ?? [];

          setState(() {
            _totalSkus = (metrics['total_items'] as num?)?.toInt() ?? rawItems.length;
            _availableUnits = (metrics['total_vault_units'] as num?)?.toInt() ?? 0;
            _lowStockCount = (metrics['low_stock_count'] as num?)?.toInt() ?? 0;
            _outOfStockCount = (metrics['out_of_stock_count'] as num?)?.toInt() ?? 0;
            _reservedUnits = (metrics['reserved_units'] as num?)?.toInt() ?? 0;

            _filters = [
              'All Inventory ($_totalSkus)',
              'Low Stock ($_lowStockCount)',
              'Out of Stock ($_outOfStockCount)',
            ];

            _items = rawItems.map((p) {
              final id = p['id'].toString();
              final name = (p['title'] as String?) ?? 'TechKart Product';
              final available = (p['available_stock'] as num?)?.toInt() ?? 0;
              final reserved = (p['reserved_stock'] as num?)?.toInt() ?? 0;
              final totalVault = (p['total_vault_units'] as num?)?.toInt() ?? (available + reserved);
              final sku = (p['sku'] as String?) ?? ('TK-SKU-$id');
              final statusTypeStr = (p['status_type'] as String?) ?? 'healthy';
              final imgUrl = p['image_url'] as String?;

              final threshold = (p['low_stock_threshold'] as num?)?.toInt() ?? (p['threshold'] as num?)?.toInt() ?? 5;

              _StockStatus sStatus = _StockStatus.healthy;
              _ItemActionType action = _ItemActionType.quickAdjustSecondary;
              if (statusTypeStr == 'out_of_stock' || available == 0) {
                sStatus = _StockStatus.outOfStock;
                action = _ItemActionType.quickRestockBrown;
              } else if (statusTypeStr == 'low_stock' || available <= threshold) {
                sStatus = _StockStatus.lowStock;
                action = _ItemActionType.updateStockPrimary;
              }

              IconData icon = Icons.devices_other_outlined;
              final lower = name.toLowerCase();
              if (lower.contains('watch') || lower.contains('chronos')) {
                icon = Icons.watch_outlined;
              } else if (lower.contains('charger') || lower.contains('power')) {
                icon = Icons.power_outlined;
              } else if (lower.contains('headphone') || lower.contains('sound') || lower.contains('audio')) {
                icon = Icons.headphones_outlined;
              } else if (lower.contains('keyboard')) {
                icon = Icons.keyboard_outlined;
              }

              return _InventoryItem(
                id: id,
                name: name.length > 32 ? '${name.substring(0, 29)}...' : name,
                fullName: name,
                sku: sku,
                icon: icon,
                imageUrl: imgUrl,
                available: available,
                reserved: reserved,
                reservedLabel: reserved > 0 ? '$reserved Reserved (Packing)' : '0 Reserved',
                statusType: sStatus,
                statusBadgeText: '$available Available',
                totalVaultText: 'Total Vault: $totalVault Units',
                thresholdText: available <= threshold ? 'Threshold: $threshold units' : 'Threshold: $threshold units · Healthy',
                warningBannerText: available == 0 ? 'Direct Buyer Search Suspended' : null,
                warningLossText: available == 0 ? 'Loss: ~\$420/day' : null,
                actionType: action,
                currentCount: available,
              );
            }).toList();
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUpdateStock(_InventoryItem item, {int? newCount, int? delta}) async {
    final prodId = int.tryParse(item.id);
    if (prodId == null) return;

    final targetCount = newCount ?? (item.currentCount + (delta ?? 0));
    if (targetCount < 0) return;

    setState(() => _isLoading = true);

    try {
      final res = await ProductService.updateInventoryStock(
        productId: prodId,
        stockQuantity: targetCount,
        movementType: targetCount > item.available ? 'restock' : 'manual_adjustment',
        reason: targetCount > item.available
            ? 'Warehouse stock replenishment of +${targetCount - item.available} units'
            : 'Manual stock adjustment to $targetCount units',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock for "${item.name}" updated to $targetCount units.'),
            backgroundColor: const Color(0xFF03253B),
            duration: const Duration(seconds: 2),
          ),
        );
        _fetchLiveInventory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : 'Failed to update stock.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar (only if not standalone with AppBar, or show custom top bar)
          if (!widget.isStandaloneScreen) _buildTopHeader(context),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2.5,
              backgroundColor: Color(0xFFD3E4F6),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF285688)),
            ),
          // Hub sync status banner
          _buildLiveSyncBanner(),
          const SizedBox(height: 12),
          // 4 Key inventory metrics cards (2x2 grid)
          _buildMetricsGrid(),
          const SizedBox(height: 14),
          // Bulk CSV Upload & Scan In action buttons
          _buildActionButtonsRow(),
          const SizedBox(height: 12),
          // Search Bar + Filter Tune Button
          _buildSearchBar(),
          const SizedBox(height: 12),
          // Filter Tabs (All Inventory, Low Stock, Out of Stock)
          _buildFilterTabs(),
          const SizedBox(height: 14),
          // Inventory Product Cards
          ..._items.map((item) => _buildInventoryCard(item)),
          const SizedBox(height: 10),
          // Compliance Card
          _buildComplianceCard(),
          const SizedBox(height: 32),
        ],
      ),
    );

    if (widget.isStandaloneScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        appBar: const SellerTopBar(
          title: 'Inventory Management',
          subtitle: 'Stock Control',
          showProfile: true,
        ),
        body: SafeArea(child: content),
      );
    }

    return SafeArea(child: content);
  }

  // ── TOP HEADER ──
  Widget _buildTopHeader(BuildContext context) {
    return const SellerTopBar(
      title: 'Inventory Management',
      subtitle: 'Your store name',
      showNotification: true,
      showProfile: true,
    );
  }

  // ── LIVE SYNC BANNER ──
  Widget _buildLiveSyncBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF5FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD3E4F6), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 16,
                color: Color(0xFF2A5989),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mumbai Central Hub Live Sync',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A2038),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _reservedUnits > 0
                        ? '$_reservedUnits units currently reserved for incoming orders.'
                        : 'All changes reflect across consumer catalog in real time.',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF5A6B7C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCCDFF0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: 12,
                    color: Color(0xFF285688),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Sync',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF285688),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2x2 METRICS GRID ──
  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'Total SKUs',
                  value: '$_totalSkus',
                  badgeText: 'Active',
                  badgeColor: const Color(0xFFF0F5FD),
                  badgeTextColor: const Color(0xFF4C5D70),
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFF8DA5C0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  label: 'Available Units',
                  value: '$_availableUnits',
                  badgeText: 'In Vault',
                  badgeColor: const Color(0xFFF0F5FD),
                  badgeTextColor: const Color(0xFF4C5D70),
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'Low Stock (<5)',
                  value: '$_lowStockCount',
                  badgeText: 'Reorder',
                  badgeColor: const Color(0xFFFBF1E2),
                  badgeTextColor: const Color(0xFF8F5115),
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFF8F5115),
                  valueColor: const Color(0xFF072138),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  label: 'Out of Stock',
                  value: '$_outOfStockCount',
                  badgeText: 'Urgent',
                  badgeColor: const Color(0xFFFDE8E8),
                  badgeTextColor: const Color(0xFFD32F2F),
                  icon: Icons.error_outline_rounded,
                  iconColor: const Color(0xFFD32F2F),
                  valueColor: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5A6B7C),
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? const Color(0xFF072138),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ACTION BUTTONS: Bulk CSV Upload & Scan In ──
  Widget _buildActionButtonsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0FB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFB9D8F5), width: 0.8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 15,
                    color: Color(0xFF1E4B75),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Bulk CSV Upload',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E4B75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0FB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFB9D8F5), width: 0.8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 15,
                    color: Color(0xFF1E4B75),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Scan In',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E4B75),
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

  // ── SEARCH BAR ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD6E5F5)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF8DA5C0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onSubmitted: (_) => _fetchLiveInventory(),
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF072138)),
                      decoration: const InputDecoration(
                        hintText: 'Search SKU, item name, barcode...',
                        hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF8DA5C0)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Color(0xFF8DA5C0)),
                      onPressed: () {
                        _searchCtrl.clear();
                        _fetchLiveInventory();
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _fetchLiveInventory,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6E5F5)),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 20,
                color: Color(0xFF28384C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER TABS ──
  Widget _buildFilterTabs() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final selected = i == _filterIndex;
          Color dotColor = Colors.transparent;
          if (i == 1) dotColor = const Color(0xFF8F5115);
          if (i == 2) dotColor = const Color(0xFFD32F2F);

          return GestureDetector(
            onTap: () {
              setState(() => _filterIndex = i);
              _fetchLiveInventory();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF4C5D80) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF4C5D80)
                      : const Color(0xFFCCDFF0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dotColor != Colors.transparent) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _filters[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : (i == 2
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF4C5D70)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── INVENTORY CARD ──
  Widget _buildInventoryCard(_InventoryItem item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFECF7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with image thumbnail and title/sku/badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Thumbnail
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE4EDF7)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(item.icon, size: 34, color: const Color(0xFF6B829E)),
                        )
                      : Icon(item.icon, size: 34, color: const Color(0xFF6B829E)),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF072138),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'SKU:  ${item.sku}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF7A8FA3),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badge + Reserved row
                    Row(
                      children: [
                        _buildStatusBadge(item),
                        const SizedBox(width: 8),
                        Text(
                          item.reservedLabel,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF5A6B7C),
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

          // Vault Banner / Threshold row OR Warning banner
          if (item.warningBannerText != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFD7D7), width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.store_mall_directory_outlined,
                        size: 13,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.warningBannerText!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                  if (item.warningLossText != null)
                    Text(
                      item.warningLossText!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 13,
                        color: Color(0xFF374E65),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.totalVaultText ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF072138),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.thresholdText ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4C5D70),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Stepper + Action button row
          if (item.actionType == _ItemActionType.quickRestockBrown)
            // Single full-width brown restock button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleUpdateStock(item, delta: 10),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A584F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text(
                  '+ Quick Restock (Add 10 Units)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            Row(
              children: [
                // Stepper (- count +)
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2FD),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16, color: Color(0xFF1E4B75)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (item.currentCount > 0) {
                            setState(() => item.currentCount--);
                          }
                        },
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 26),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.currentCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF072138),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF1E4B75)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() => item.currentCount++);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Right Action Button
                Expanded(
                  child: _buildItemActionButton(item),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(_InventoryItem item) {
    Color bg = const Color(0xFFEEF5FD);
    Color fg = const Color(0xFF1E4B75);
    IconData icon = Icons.check_circle_outline_rounded;

    if (item.statusType == _StockStatus.lowStock) {
      bg = const Color(0xFFFBF1E2);
      fg = const Color(0xFF8F5115);
      icon = Icons.warning_amber_rounded;
    } else if (item.statusType == _StockStatus.outOfStock) {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFFD32F2F);
      icon = Icons.error_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            item.statusBadgeText,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemActionButton(_InventoryItem item) {
    if (item.actionType == _ItemActionType.updateStockPrimary) {
      return ElevatedButton.icon(
        onPressed: () => _handleUpdateStock(item, newCount: item.currentCount),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C5D80),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.tune_rounded, size: 14),
        label: const Text(
          'Update Stock',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
    } else if (item.actionType == _ItemActionType.quickAdjustSecondary) {
      return OutlinedButton.icon(
        onPressed: () => _handleUpdateStock(item, newCount: item.currentCount),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFE8F2FD),
          foregroundColor: const Color(0xFF1E4B75),
          side: const BorderSide(color: Color(0xFFB8D8F5), width: 0.8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        icon: const Icon(Icons.sync_alt_rounded, size: 14),
        label: const Text(
          'Quick Adjust',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      // updateStockLight
      return OutlinedButton.icon(
        onPressed: () => _handleUpdateStock(item, newCount: item.currentCount),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFE8F2FD),
          foregroundColor: const Color(0xFF1E4B75),
          side: const BorderSide(color: Color(0xFFB8D8F5), width: 0.8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        icon: const Icon(Icons.tune_rounded, size: 14),
        label: const Text(
          'Save Stock',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
    }
  }

  // ── SELLER VAULT OPERATIONS COMPLIANCE CARD ──
  Widget _buildComplianceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4E6F8), width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 18,
            color: Color(0xFF2E639A),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller Vault Operations Compliance',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072138),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stock counts cannot be negative. Updates sync immediately to Mumbai Hub Fulfillment & live buyer search. Audit logs are permanently retained.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF4C5D70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StockStatus { healthy, lowStock, outOfStock }

enum _ItemActionType {
  updateStockPrimary,
  quickAdjustSecondary,
  quickRestockBrown,
}

class _InventoryItem {
  final String id;
  final String name;
  final String? fullName;
  final String sku;
  final IconData icon;
  final String? imageUrl;
  final int available;
  final int reserved;
  final String reservedLabel;
  final _StockStatus statusType;
  final String statusBadgeText;
  final String? totalVaultText;
  final String? thresholdText;
  final String? warningBannerText;
  final String? warningLossText;
  final _ItemActionType actionType;
  int currentCount;

  _InventoryItem({
    required this.id,
    required this.name,
    this.fullName,
    required this.sku,
    required this.icon,
    this.imageUrl,
    required this.available,
    required this.reserved,
    required this.reservedLabel,
    required this.statusType,
    required this.statusBadgeText,
    this.totalVaultText,
    this.thresholdText,
    this.warningBannerText,
    this.warningLossText,
    required this.actionType,
    required this.currentCount,
  });
}