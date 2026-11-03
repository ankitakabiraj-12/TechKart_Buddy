import 'package:flutter/material.dart';
import 'seller_top_bar.dart';
import 'add_product.dart';
import 'notification.dart';
import 'product_service.dart';

import '../core/network/api_client.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  int _filterIndex = 0;
  List<String> _filterTabs = ['All (142)', 'Active (128)', 'Under Review (9)', 'Draft (3)'];
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  List<_ProductItem> _products = const [
    _ProductItem(
      name: 'Chronos Ultra 2 (49mm GPS Ti...',
      sku: 'TK-WAT-ULT2-TI',
      price: '₹ 42,900',
      originalPrice: '₹ 49,900',
      stock: 4,
      stockLabel: 'Low Stock • 4 units',
      status: 'Active • Winning Buy Box',
      statusType: _StatusType.activeBuyBox,
      icon: Icons.watch_outlined,
    ),
    _ProductItem(
      name: 'VoltFast 65W GaN Dual USB-C ...',
      sku: 'TK-CHG-65W-WHT',
      price: '₹ 3,900',
      stock: 68,
      stockLabel: 'Healthy Stock • 68 units',
      status: 'Active',
      statusType: _StatusType.active,
      icon: Icons.power_outlined,
    ),
    _ProductItem(
      name: 'Pro Ergo Mechanical Tactile Ke...',
      sku: 'TK-ACC-KB90-BLK',
      price: '₹ 12,500',
      stock: 0,
      stockLabel: '0 units left',
      status: 'Paused / Out of Stock',
      statusType: _StatusType.paused,
      icon: Icons.keyboard_outlined,
      needsRestock: true,
    ),
    _ProductItem(
      name: 'SoundPulse Horizon ANC Head...',
      sku: 'TK-AUD-HP10-SLV',
      price: '₹ 8,450',
      stock: 15,
      stockLabel: 'Pending catalog approval',
      status: 'Under Review',
      statusType: _StatusType.underReview,
      icon: Icons.headphones_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveProducts();
  }

  Future<void> _handleEditProduct(_ProductItem product) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProduct(
          productId: product.id,
          editingSku: product.sku,
          initialTitle: product.name,
          initialPrice: product.rawPrice,
          initialMrp: product.rawMrp,
          initialStock: product.stock,
          initialDescription: product.description,
          initialCategoryId: product.categoryId,
          initialSpecifications: product.specifications,
        ),
      ),
    );

    if (updated == true && mounted) {
      _fetchLiveProducts();
    }
  }

  Future<void> _confirmDeleteProduct(_ProductItem product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F), size: 22),
            SizedBox(width: 8),
            Text(
              'Delete Product',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF072138),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${product.name}"? If this item has existing customer order history, it will be safely archived to preserve financial records.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4C5D70), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF5A6B7C), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (product.id == null) {
        setState(() {
          _products.removeWhere((p) => p.sku == product.sku);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed.'), backgroundColor: Color(0xFF072138)),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final res = await ProductService.deleteProduct(product.id!);
        if (mounted) {
          setState(() => _isLoading = false);
          if (res.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res.message.isNotEmpty ? res.message : 'Product removed successfully.'),
                backgroundColor: const Color(0xFF072138),
              ),
            );
            _fetchLiveProducts();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res.message.isNotEmpty ? res.message : 'Failed to delete product.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Future<void> _fetchLiveProducts() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/buddy/products');
      if (mounted) {
        setState(() => _isLoading = false);
        if (res.isSuccess && res.data != null) {
          final List<dynamic> rawList;
          if (res.data is List) {
            rawList = res.data as List<dynamic>;
          } else if (res.data is Map && (res.data as Map).containsKey('products')) {
            rawList = (res.data as Map)['products'] as List<dynamic>? ?? [];
          } else {
            rawList = [];
          }

          if (rawList.isNotEmpty) {
            setState(() {
              int activeCount = 0;
              int reviewCount = 0;
              int draftCount = 0;

              _products = rawList.map((p) {
                final pid = (p['id'] as num?)?.toInt();
                final stock = (p['stock_quantity'] as num?)?.toInt() ?? 0;
                final title = (p['title'] as String?) ?? 'TechKart Product';
                final desc = (p['description'] as String?);
                final price = (p['price'] as num?)?.toDouble() ?? 0.0;
                final mrp = (p['mrp'] as num?)?.toDouble();
                final sku = (p['sku'] as String?) ?? 'TK-SKU-${pid ?? ''}';
                final statusRaw = (p['status'] as String?) ?? 'published';
                final reviewNotes = (p['review_notes'] as String?);
                final reviewerName = (p['reviewer_name'] as String?);

                _StatusType sType = _StatusType.active;
                String statusLabel = 'Active';

                if (statusRaw == 'draft') {
                  sType = _StatusType.draft;
                  statusLabel = 'Draft';
                  draftCount++;
                } else if (statusRaw == 'pending_review') {
                  sType = _StatusType.underReview;
                  statusLabel = 'Under Review';
                  reviewCount++;
                } else if (statusRaw == 'approved') {
                  sType = _StatusType.approved;
                  statusLabel = 'Approved • Ready to Publish';
                  reviewCount++;
                } else if (statusRaw == 'rejected') {
                  sType = _StatusType.rejected;
                  statusLabel = 'Rejected • Action Required';
                  reviewCount++;
                } else if (statusRaw == 'archived') {
                  sType = _StatusType.paused;
                  statusLabel = 'Archived';
                } else if (stock == 0) {
                  sType = _StatusType.paused;
                  statusLabel = 'Paused / Out of Stock';
                  activeCount++;
                } else if (stock <= 5) {
                  sType = _StatusType.activeBuyBox;
                  statusLabel = 'Active • Winning Buy Box';
                  activeCount++;
                } else {
                  activeCount++;
                }

                IconData icon = Icons.devices_other_outlined;
                final lower = title.toLowerCase();
                if (lower.contains('watch') || lower.contains('chronos')) {
                  icon = Icons.watch_outlined;
                } else if (lower.contains('charger') || lower.contains('power')) {
                  icon = Icons.power_outlined;
                } else if (lower.contains('headphone') || lower.contains('sound') || lower.contains('anc')) {
                  icon = Icons.headphones_outlined;
                } else if (lower.contains('keyboard')) {
                  icon = Icons.keyboard_outlined;
                }

                final categoryId = p['category_id'] != null ? (p['category_id'] as num).toInt() : null;
                final specs = p['specifications'] is Map ? Map<String, dynamic>.from(p['specifications'] as Map) : null;

                return _ProductItem(
                  id: pid,
                  name: title,
                  sku: sku,
                  price: '₹ ${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  rawPrice: price,
                  originalPrice: mrp != null ? '₹ ${mrp.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}' : null,
                  rawMrp: mrp,
                  stock: stock,
                  stockLabel: stock == 0 ? '0 units left' : (stock <= 5 ? 'Low Stock • $stock units' : 'Healthy Stock • $stock units'),
                  status: statusLabel,
                  statusType: sType,
                  icon: icon,
                  needsRestock: stock == 0,
                  description: desc,
                  categoryId: categoryId,
                  specifications: specs,
                  reviewNotes: reviewNotes,
                  reviewerName: reviewerName,
                  rawStatus: statusRaw,
                );
              }).toList();

              _filterTabs = [
                'All (${_products.length})',
                'Active ($activeCount)',
                'Under Review ($reviewCount)',
                'Draft ($draftCount)',
              ];
            });
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── TOP BAR ──
          _buildTopBar(context),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 2),
          // ── SEARCH BAR ──
          _buildSearchBar(),
          // ── Listings + Add Button ──
          _buildListingsRow(context),
          // ── FILTER TABS ──
          _buildFilterTabs(),
          const SizedBox(height: 4),
          // ── PRODUCT LIST ──
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 20),
              itemCount: _products.length,
              separatorBuilder: (_, _) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: const Color(0xFFE8EFF7),
              ),
              itemBuilder: (context, i) => _buildProductCard(_products[i], context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SellerTopBar(
      title: 'My Products',
      subtitle: 'Your store name',
      showNotification: true,
      showProfile: true,
      onNotificationTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SellerNotificationScreen(isStandaloneScreen: true),
          ),
        );
      },
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SellerNotificationScreen(isStandaloneScreen: true),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
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
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search_rounded, size: 18, color: Color(0xFF8DA5C0)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search products by name, SKU, or tag...',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8DA5C0)),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6E5F5)),
            ),
            child: const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF28384C)),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4C5D80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_products.length} Listings',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF072138),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '•',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4C5D80),
                    ),
                  ),
                ),
                const Text(
                  '98.4% Buy Box',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B5998),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final added = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const AddProduct()),
              );
              if (added == true && mounted) {
                _fetchLiveProducts();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF03142E),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 13,
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
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _filterTabs.length,
        itemBuilder: (context, i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF03142E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? const Color(0xFF03142E) : const Color(0xFFCCDFF0),
                ),
              ),
              child: Text(
                _filterTabs[i],
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF4C5D70),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(_ProductItem product, BuildContext context) {
    return GestureDetector(
      onTap: () => _handleEditProduct(product),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStatusDot(product.statusType),
                    const SizedBox(width: 5),
                    Text(
                      product.status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(product.statusType),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF8DA5C0)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 120),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _handleEditProduct(product);
                    } else if (value == 'delete') {
                      _confirmDeleteProduct(product);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      height: 38,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16, color: Color(0xFF072138)),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      height: 38,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFD32F2F)),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Product Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF5FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(product.icon, size: 36, color: const Color(0xFF8DA5C0)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF072138),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${product.sku}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7A8FA3),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF072138),
                            ),
                          ),
                          if (product.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              product.originalPrice!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF9AB0C6),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Row: stock label + action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stock badge / label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _stockBadgeColor(product),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.stockLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _stockTextColor(product),
                    ),
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    if (product.needsRestock)
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF03142E),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add_box_outlined, size: 14, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Restock',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCCDFF0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF374E65)),
                              const SizedBox(width: 5),
                              Text(
                                product.statusType == _StatusType.underReview
                                    ? '${product.stock} Units'
                                    : 'Stock',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374E65)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _handleEditProduct(product),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCCDFF0)),
                        ),
                        child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF374E65)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (product.reviewNotes != null && product.reviewNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: product.statusType == _StatusType.rejected
                      ? const Color(0xFFFDE8E5)
                      : const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: product.statusType == _StatusType.rejected
                        ? const Color(0xFFF5B7B1)
                        : const Color(0xFFBCE0FD),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      product.statusType == _StatusType.rejected
                          ? Icons.error_outline_rounded
                          : Icons.verified_user_outlined,
                      size: 15,
                      color: product.statusType == _StatusType.rejected
                          ? const Color(0xFFB33020)
                          : const Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.statusType == _StatusType.rejected
                                ? 'Admin Compliance Feedback'
                                : 'Compliance Clearance Note',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: product.statusType == _StatusType.rejected
                                  ? const Color(0xFFB33020)
                                  : const Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.reviewNotes!,
                            style: TextStyle(
                              fontSize: 11,
                              color: product.statusType == _StatusType.rejected
                                  ? const Color(0xFF78281F)
                                  : const Color(0xFF0D47A1),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(_StatusType type) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _statusColor(type),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _statusColor(_StatusType type) {
    switch (type) {
      case _StatusType.activeBuyBox:
        return const Color(0xFF2E7D32);
      case _StatusType.active:
        return const Color(0xFF2E7D32);
      case _StatusType.approved:
        return const Color(0xFF1565C0);
      case _StatusType.paused:
        return const Color(0xFFD32F2F);
      case _StatusType.underReview:
        return const Color(0xFFEF6C00);
      case _StatusType.rejected:
        return const Color(0xFFB71C1C);
      case _StatusType.draft:
        return const Color(0xFF546E7A);
    }
  }

  Color _stockBadgeColor(_ProductItem p) {
    if (p.statusType == _StatusType.rejected) return const Color(0xFFFFEBEE);
    if (p.statusType == _StatusType.approved) return const Color(0xFFE3F2FD);
    if (p.statusType == _StatusType.underReview) return const Color(0xFFF0EBE1);
    if (p.statusType == _StatusType.draft) return const Color(0xFFECEFF1);
    if (p.stock == 0) return const Color(0xFFFFEBEE);
    if (p.stock <= 5) return const Color(0xFFFDE8E8);
    return const Color(0xFFE8F2FD);
  }

  Color _stockTextColor(_ProductItem p) {
    if (p.statusType == _StatusType.rejected) return const Color(0xFFB71C1C);
    if (p.statusType == _StatusType.approved) return const Color(0xFF1565C0);
    if (p.statusType == _StatusType.underReview) return const Color(0xFF7A684C);
    if (p.statusType == _StatusType.draft) return const Color(0xFF455A64);
    if (p.stock == 0) return const Color(0xFFD32F2F);
    if (p.stock <= 5) return const Color(0xFFD32F2F);
    return const Color(0xFF1E4B75);
  }
}

enum _StatusType { activeBuyBox, active, paused, underReview, approved, rejected, draft }

class _ProductItem {
  final int? id;
  final String name;
  final String sku;
  final String price;
  final double? rawPrice;
  final String? originalPrice;
  final double? rawMrp;
  final int stock;
  final String stockLabel;
  final String status;
  final _StatusType statusType;
  final IconData icon;
  final bool needsRestock;
  final String? description;
  final int? categoryId;
  final Map<String, dynamic>? specifications;
  final String? reviewNotes;
  final String? reviewerName;
  final String rawStatus;

  const _ProductItem({
    this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.rawPrice,
    this.originalPrice,
    this.rawMrp,
    required this.stock,
    required this.stockLabel,
    required this.status,
    required this.statusType,
    required this.icon,
    this.needsRestock = false,
    this.description,
    this.categoryId,
    this.specifications,
    this.reviewNotes,
    this.reviewerName,
    this.rawStatus = 'published',
  });
}
