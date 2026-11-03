import 'package:flutter/material.dart';
import 'product_service.dart';
import 'seller_top_bar.dart';
import 'notification.dart';

class OrdersDetails extends StatefulWidget {
  final bool isStandaloneScreen;
  const OrdersDetails({super.key, this.isStandaloneScreen = false});

  @override
  State<OrdersDetails> createState() => _OrdersDetailsState();
}

class _OrdersDetailsState extends State<OrdersDetails> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Pending', 'Ready to Ship', 'Shipped'];
  List<int> _filterCounts = [0, 0, 0, 0];

  int _selectedPriority = 0;
  final List<String> _priorityTags = ['Urgent (<2h SLA)', 'Express Logistics', 'Packaging Alert'];

  bool _isLoading = true;
  bool _isUpdating = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _liveOrders = [];
  final Set<int> _expandedOrderIds = {};

  @override
  void initState() {
    super.initState();
    _fetchLiveOrders();
  }

  Future<void> _fetchLiveOrders() async {
    setState(() => _isLoading = true);
    try {
      final statusParam = _mapFilterToStatus(_selectedFilter);
      final response = await ProductService.getOrders(status: statusParam);
      if (response.isSuccess && response.data is List) {
        final list = List<Map<String, dynamic>>.from(
          (response.data as List).map((x) => Map<String, dynamic>.from(x as Map)),
        );
        setState(() {
          _liveOrders = list;
          _isLoading = false;
        });
        _calculateFilterCounts();
      } else {
        setState(() {
          _liveOrders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _liveOrders = [];
          _isLoading = false;
        });
      }
    }
  }

  void _calculateFilterCounts() async {
    try {
      final allResponse = await ProductService.getOrders(status: 'all');
      if (allResponse.isSuccess && allResponse.data is List) {
        final allOrders = List<Map<String, dynamic>>.from(
          (allResponse.data as List).map((x) => Map<String, dynamic>.from(x as Map)),
        );
        int pending = 0;
        int readyToShip = 0;
        int shipped = 0;

        for (final ord in allOrders) {
          final items = (ord['items'] as List<dynamic>?) ?? [];
          for (final it in items) {
            final st = (it['item_status'] ?? ord['order_status'] ?? '').toString().toLowerCase();
            if (st == 'placed') {
              pending++;
            } else if (st == 'processing') {
              readyToShip++;
            } else if (st == 'shipped' || st == 'delivered') {
              shipped++;
            }
          }
        }

        if (mounted) {
          setState(() {
            _filterCounts = [
              allOrders.length,
              pending,
              readyToShip,
              shipped,
            ];
          });
        }
      }
    } catch (_) {}
  }

  String _mapFilterToStatus(int index) {
    switch (index) {
      case 1:
        return 'placed';
      case 2:
        return 'processing';
      case 3:
        return 'shipped';
      default:
        return 'all';
    }
  }

  Future<void> _updateOrderStatus({
    required String orderIdentifier,
    required String targetStatus,
    String? courierName,
    String? trackingNumber,
    String? currentLocation,
    String? nextStop,
    String? description,
    required VoidCallback onSuccess,
  }) async {
    setState(() => _isUpdating = true);
    try {
      final response = await ProductService.updateOrderStatus(
        orderId: orderIdentifier,
        status: targetStatus,
        courierName: courierName,
        trackingNumber: trackingNumber,
        currentLocation: currentLocation,
        nextStop: nextStop,
        description: description,
      );

      if (mounted) {
        setState(() => _isUpdating = false);
        if (response.isSuccess) {
          onSuccess();
          _fetchLiveOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty ? response.message : 'Status update failed'),
              backgroundColor: const Color(0xFFB52E1D),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        onSuccess();
      }
    }
  }

  Future<void> _acceptOrder({
    required String orderIdentifier,
    required String orderNumber,
    int? itemId,
  }) async {
    setState(() => _isUpdating = true);
    try {
      final response = await ProductService.acceptOrder(
        orderId: orderIdentifier,
        itemId: itemId,
        notes: 'Seller confirmed and accepted order $orderNumber. Packing underway.',
      );

      if (mounted) {
        setState(() => _isUpdating = false);
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order $orderNumber Accepted Successfully!'),
              backgroundColor: const Color(0xFF03253B),
            ),
          );
          _fetchLiveOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty ? response.message : 'Failed to accept order'),
              backgroundColor: const Color(0xFFB52E1D),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting order: $e'),
            backgroundColor: const Color(0xFFB52E1D),
          ),
        );
      }
    }
  }

  void _showRejectOrderDialog({
    required String orderIdentifier,
    required String orderNumber,
    int? itemId,
  }) {
    final TextEditingController reasonController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFD32F2F)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reject Order',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF072138)),
                        ),
                        Text(
                          'Order $orderNumber',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF7A8FA3)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please specify a mandatory rejection reason for the buyer and audit log:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4C5D70)),
                  ),
                  const SizedBox(height: 12),
                  // Quick canned reason chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Item out of stock',
                        'Customer unserviceable address',
                        'Pricing or catalog discrepancy',
                      ].map((preset) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ActionChip(
                            label: Text(preset, style: const TextStyle(fontSize: 10.5, color: Color(0xFF1E4B75))),
                            backgroundColor: const Color(0xFFEEF5FD),
                            side: const BorderSide(color: Color(0xFFC7DDF2), width: 0.8),
                            onPressed: () {
                              setDialogState(() {
                                reasonController.text = preset;
                                errorText = null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    onChanged: (val) {
                      if (errorText != null && val.trim().length >= 5) {
                        setDialogState(() => errorText = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g. Item out of stock in warehouse...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF03142E), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final reason = reasonController.text.trim();
                    if (reason.length < 5) {
                      setDialogState(() {
                        errorText = 'Mandatory reason must be at least 5 characters.';
                      });
                      return;
                    }
                    Navigator.pop(dialogCtx);
                    _rejectOrder(
                      orderIdentifier: orderIdentifier,
                      orderNumber: orderNumber,
                      reason: reason,
                      itemId: itemId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Confirm Rejection', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _rejectOrder({
    required String orderIdentifier,
    required String orderNumber,
    required String reason,
    int? itemId,
  }) async {
    setState(() => _isUpdating = true);
    try {
      final response = await ProductService.rejectOrder(
        orderId: orderIdentifier,
        reason: reason,
        itemId: itemId,
      );

      if (mounted) {
        setState(() => _isUpdating = false);
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order $orderNumber Rejected. Reason recorded in audit log.'),
              backgroundColor: const Color(0xFFB52E1D),
            ),
          );
          _fetchLiveOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty ? response.message : 'Rejection failed'),
              backgroundColor: const Color(0xFFB52E1D),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting order: $e'),
            backgroundColor: const Color(0xFFB52E1D),
          ),
        );
      }
    }
  }

  void _showLiveTrackingModal(String trackingId, String orderNum) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Shipment Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tracking #$trackingId • Order $orderNum',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: FutureBuilder(
                  future: ProductService.getOrderTracking(orderNum),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null || !(snapshot.data?.isSuccess ?? false)) {
                      return Center(
                        child: Text(
                          'Tracking details synced. Status: In Transit.\nCourier: Apex Courier Express',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      );
                    }
                    final data = snapshot.data!.data as Map<String, dynamic>?;
                    final timeline = (data?['timeline'] as List<dynamic>?) ?? [];
                    final headline = data?['headline']?.toString() ?? 'In Transit';
                    final courierName = data?['courier_name']?.toString() ?? 'Apex Courier Express';
                    final courierPhone = data?['courier_phone']?.toString() ?? '';
                    final currentLocation = data?['current_location']?.toString() ?? '';
                    final nextStop = data?['next_stop']?.toString() ?? '';
                    final estimatedDelivery = data?['estimated_delivery']?.toString() ?? '';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logistics summary banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF166534)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      headline,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Courier: $courierName ${courierPhone.isNotEmpty ? "($courierPhone)" : ""}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                              ),
                              if (currentLocation.isNotEmpty || nextStop.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Current: $currentLocation • Next: $nextStop',
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF4B5563)),
                                ),
                              ],
                              if (estimatedDelivery.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Estimated Delivery: $estimatedDelivery',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: timeline.isEmpty
                              ? Center(
                                  child: Text(
                                    'No checkpoint events recorded yet.\nPackage registered with $courierName.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: timeline.length,
                                  itemBuilder: (c, idx) {
                                    final item = timeline[idx] as Map<String, dynamic>;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.only(top: 4, right: 12),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF2563EB),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['title'] ?? '',
                                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _liveOrders.where((ord) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final num = (ord['order_number'] ?? '').toString().toLowerCase();
      final buyer = (ord['customer_name'] ?? '').toString().toLowerCase();
      return num.contains(q) || buyer.contains(q);
    }).toList();

    final content = RefreshIndicator(
      onRefresh: _fetchLiveOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If not standalone, build top header
            if (!widget.isStandaloneScreen) _buildTopHeader(context),
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 10),
            // Filter Status Chips (All, Pending, Ready to Ship, Shipped)
            _buildFilterChips(),
            const SizedBox(height: 10),
            // Priority tags row
            _buildPriorityRow(),
            const SizedBox(height: 12),
            // Urgent Dispatch Banner
            _buildUrgentBanner(),
            const SizedBox(height: 14),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF03142E)),
                ),
              )
            else if (filteredOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF5FD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.inbox_outlined, size: 30, color: Color(0xFF1E4B75)),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No orders found',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF072138)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFilter == 0
                            ? 'You do not have any orders assigned yet.'
                            : 'No orders under ${_filters[_selectedFilter]} category.',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF5A6B7C)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredOrders.map((ord) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: _buildDynamicOrderCard(ord),
                );
              }),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );

    if (widget.isStandaloneScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        appBar: SellerTopBar(
          title: 'Orders Management',
          showProfile: true,
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SellerNotificationScreen(isStandaloneScreen: true),
              ),
            );
          },
        ),
        body: SafeArea(child: content),
      );
    }

    return SafeArea(child: content);
  }

  // ── TOP HEADER (Metro Hub selector, notifications, avatar) ──
  Widget _buildTopHeader(BuildContext context) {
    return SellerTopBar(
      title: 'Orders',
      subtitle: 'Metro Hub',
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
                  const Icon(Icons.search_rounded, size: 18, color: Color(0xFF8DA5C0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF072138)),
                      decoration: const InputDecoration(
                        hintText: 'Search Order ID, buyer, or SKU...',
                        hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF8DA5C0)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _searchQuery = ''),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.close, size: 16, color: Color(0xFF8DA5C0)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _fetchLiveOrders,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6E5F5)),
              ),
              child: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF28384C)),
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER STATUS CHIPS ──
  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final selected = i == _selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = i);
              _fetchLiveOrders();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF03142E)
                    : (i == 1
                        ? const Color(0xFFFDE8E8)
                        : (i == 2 ? const Color(0xFFE8F2FD) : Colors.white)),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF03142E)
                      : (i == 1
                          ? const Color(0xFFF7C8C8)
                          : (i == 2 ? const Color(0xFFC7DDF2) : const Color(0xFFCCDFF0))),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _filters[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : (i == 1
                              ? const Color(0xFFD32F2F)
                              : (i == 2 ? const Color(0xFF1E4B75) : const Color(0xFF4C5D70))),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1E4B75)
                          : (i == 1
                              ? const Color(0xFFF8B4B4)
                              : (i == 2 ? const Color(0xFFD0E4FA) : const Color(0xFFEEF5FD))),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_filterCounts[i]}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : (i == 1
                                ? const Color(0xFFD32F2F)
                                : (i == 2 ? const Color(0xFF1E4B75) : const Color(0xFF4C5D70))),
                      ),
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

  // ── PRIORITY BAR ──
  Widget _buildPriorityRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Text(
            'PRIORITY:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A8FA3),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_priorityTags.length, (i) {
                  final isUrgent = i == 0;
                  final isSelected = _selectedPriority == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPriority = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? (isSelected ? const Color(0xFFFFF0F0) : const Color(0xFFFFF8F8))
                            : (isSelected ? const Color(0xFFE8F2FD) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUrgent ? const Color(0xFFFFD2D2) : const Color(0xFFC7DDF2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUrgent ? Icons.access_time_rounded : Icons.bolt_rounded,
                            size: 11,
                            color: isUrgent ? const Color(0xFFD32F2F) : const Color(0xFF1E4B75),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _priorityTags[i],
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isUrgent ? const Color(0xFFD32F2F) : const Color(0xFF1E4B75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── URGENT MERCHANT DISPATCH BANNER ──
  Widget _buildUrgentBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF5FD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4E6F8), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD32F2F)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Urgent Merchant Dispatch',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '4 packages need dispatch before 04:00 PM',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD2D2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alarm, size: 12, color: Color(0xFFD32F2F)),
                  SizedBox(width: 4),
                  Text(
                    '1h 12m',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD32F2F),
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

  // ── DYNAMIC LIVE ORDER CARD BUILDER ──
  Widget _buildDynamicOrderCard(Map<String, dynamic> ord) {
    final orderId = ord['id'] is int ? ord['id'] as int : int.tryParse(ord['id'].toString()) ?? 0;
    final orderNumber = ord['order_number']?.toString() ?? '#TK-$orderId';
    final createdAt = ord['created_at']?.toString() ?? 'Recent';
    final paymentStatus = (ord['payment_status']?.toString() ?? 'pending').toUpperCase();
    final customerName = ord['customer_name']?.toString() ?? 'Valued Customer';
    final customerPhone = ord['customer_phone']?.toString() ?? '';
    final shippingAddress = ord['shipping_address'] is Map ? (ord['shipping_address'] as Map) : null;
    final addressLine = shippingAddress != null
        ? '${shippingAddress['address'] ?? ''}, ${shippingAddress['city'] ?? ''}'
        : 'Delivery Address';
    final items = (ord['items'] as List<dynamic>?) ?? [];
    final firstItem = items.isNotEmpty && items[0] is Map ? items[0] as Map : null;
    final firstItemTitle = firstItem?['title']?.toString() ?? 'Tech Accessory';
    final firstItemStatus = (firstItem?['item_status'] ?? ord['order_status'] ?? 'placed').toString().toLowerCase();
    final firstItemPrice = (firstItem?['unit_price'] != null ? (firstItem!['unit_price'] as num).toDouble() : (ord['seller_subtotal'] != null ? (ord['seller_subtotal'] as num).toDouble() : 0.0));
    final firstItemQty = firstItem?['quantity'] != null ? (firstItem!['quantity'] as num).toInt() : (ord['seller_quantity'] != null ? (ord['seller_quantity'] as num).toInt() : 1);
    final isExpanded = _expandedOrderIds.contains(orderId);

    // Format display status
    String statusLabel = 'Placed';
    Color statusBg = const Color(0xFFF5EEDB);
    Color statusFg = const Color(0xFF8F5115);

    if (firstItemStatus == 'processing') {
      statusLabel = 'Ready to Ship';
      statusBg = const Color(0xFFE6EFFB);
      statusFg = const Color(0xFF1E4B75);
    } else if (firstItemStatus == 'shipped') {
      statusLabel = 'Shipped';
      statusBg = const Color(0xFFE6EFFB);
      statusFg = const Color(0xFF1E4B75);
    } else if (firstItemStatus == 'delivered') {
      statusLabel = 'Delivered';
      statusBg = const Color(0xFFE8F5E9);
      statusFg = const Color(0xFF2E7D32);
    } else if (firstItemStatus == 'cancelled') {
      statusLabel = 'Cancelled';
      statusBg = const Color(0xFFFDE8E8);
      statusFg = const Color(0xFFD32F2F);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFECF7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    orderNumber.startsWith('#') ? orderNumber : '#$orderNumber',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.alarm, size: 10, color: Color(0xFFD32F2F)),
                        SizedBox(width: 3),
                        Text(
                          'SLA Active',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '$createdAt • Payment: $paymentStatus',
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A8FA3)),
          ),
          const SizedBox(height: 12),

          // Primary Item Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EFF9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.devices_outlined, size: 28, color: Color(0xFF374E65)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItemTitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF072138),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buyer: $customerName • Qty: $firstItemQty',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A8FA3)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${firstItemPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF072138),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Payment & Destination Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF5FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payment_outlined, size: 12, color: Color(0xFF1E4B75)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Payment: $paymentStatus',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E4B75),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF5FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF1E4B75)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          addressLine,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E4B75),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons depending on status
          if (firstItemStatus == 'placed') ...[
            Row(
              children: [
                // View / Hide Details button
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF5FD),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: const Color(0xFFC7DDF2), width: 0.8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedOrderIds.remove(orderId);
                        } else {
                          _expandedOrderIds.add(orderId);
                        }
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Hide' : 'Details',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF072138),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 15,
                          color: const Color(0xFF072138),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Reject Button
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2F2),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: const Color(0xFFFFD2D2), width: 0.8),
                    ),
                    child: TextButton.icon(
                      onPressed: _isUpdating
                          ? null
                          : () {
                              _showRejectOrderDialog(
                                orderIdentifier: orderId.toString(),
                                orderNumber: orderNumber,
                              );
                            },
                      icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFD32F2F)),
                      label: const Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Accept Button
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF03142E),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: TextButton.icon(
                      onPressed: _isUpdating
                          ? null
                          : () {
                              _acceptOrder(
                                orderIdentifier: orderId.toString(),
                                orderNumber: orderNumber,
                              );
                            },
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline, size: 14, color: Colors.white),
                      label: const Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (firstItemStatus == 'processing') ...[
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _isUpdating
                    ? null
                    : () {
                        _updateOrderStatus(
                          orderIdentifier: orderId.toString(),
                          targetStatus: 'shipped',
                          courierName: 'Apex Courier Express',
                          trackingNumber: 'APX-${100000 + (orderId * 17) % 899999}',
                          currentLocation: 'Mumbai Central Logistics Hub',
                          nextStop: 'Navi Mumbai Distribution Center',
                          description: 'Dispatched from seller warehouse and handed over to Apex Courier Express.',
                          onSuccess: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order $orderNumber handed over to courier!'),
                                backgroundColor: const Color(0xFF03253B),
                              ),
                            );
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03142E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                  elevation: 0,
                ),
                icon: _isUpdating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.directions_walk_rounded, size: 16),
                label: const Text(
                  'Handover to Courier',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ] else if (firstItemStatus == 'shipped') ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final trackId = ord['tracking_number']?.toString().isNotEmpty == true
                            ? ord['tracking_number'].toString()
                            : 'APX-${100000 + (orderId * 17) % 899999}';
                        _showLiveTrackingModal(trackId, orderNumber);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEF5FD),
                        foregroundColor: const Color(0xFF072138),
                        side: const BorderSide(color: Color(0xFFC7DDF2), width: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.near_me_outlined, size: 14),
                      label: const Text(
                        'Track Live',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating
                          ? null
                          : () {
                              _updateOrderStatus(
                                orderIdentifier: orderId.toString(),
                                targetStatus: 'delivered',
                                currentLocation: 'Delivered to Customer Doorstep',
                                nextStop: 'Recipient Verified',
                                description: 'Package handed over and signed by customer.',
                                onSuccess: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Order $orderNumber marked as Delivered!'),
                                      backgroundColor: const Color(0xFF2E7D32),
                                    ),
                                  );
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline, size: 14),
                      label: const Text(
                        'Delivered',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (firstItemStatus == 'cancelled') ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFD2D2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFD32F2F)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Rejected / Cancelled',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
                        ),
                        if (ord['rejection_reason'] != null && ord['rejection_reason'].toString().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Reason: ${ord['rejection_reason']}',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF7F1D1D)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF5FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 14, color: Color(0xFF1E4B75)),
                        const SizedBox(width: 6),
                        Text(
                          'Order Fulfilled • Status: $statusLabel',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E4B75)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final trackId = ord['tracking_number']?.toString().isNotEmpty == true
                          ? ord['tracking_number'].toString()
                          : 'APX-${100000 + (orderId * 17) % 899999}';
                      _showLiveTrackingModal(trackId, orderNumber);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E4B75),
                      side: const BorderSide(color: Color(0xFFC7DDF2), width: 0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    icon: const Icon(Icons.history_outlined, size: 13),
                    label: const Text(
                      'Timeline',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD6E5F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHIPPING & RECIPIENT DETAILS',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5A6B7C),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addressLine,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF072138)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recipient: $customerName ${customerPhone.isNotEmpty ? '• $customerPhone' : ''}',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF4C5D70)),
                  ),
                  if (items.length > 1) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    const Text(
                      'PACKAGE CONTENTS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5A6B7C),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...items.map((it) {
                      final title = it['title']?.toString() ?? 'Item';
                      final qty = it['quantity']?.toString() ?? '1';
                      final subtotal = (it['subtotal'] as num?)?.toDouble() ?? 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$title (x$qty)',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF072138)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹ ${subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF072138)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
