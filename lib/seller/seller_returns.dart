import 'package:flutter/material.dart';
import 'product_service.dart';

class SellerReturnsScreen extends StatefulWidget {
  final bool isStandaloneScreen;
  const SellerReturnsScreen({super.key, this.isStandaloneScreen = true});

  @override
  State<SellerReturnsScreen> createState() => _SellerReturnsScreenState();
}

class _SellerReturnsScreenState extends State<SellerReturnsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _returns = [];
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ProductService.getReturns(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (res.isSuccess && res.data != null) {
            final data = res.data as Map<String, dynamic>;
            _returns = data['returns'] as List<dynamic>? ?? [];
          } else {
            _errorMessage = res.message;
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

  void _showDecisionDialog(Map<String, dynamic> item) {
    String newStatus = 'approved';
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Decision: ${item['return_number']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product_name'] ?? 'Product',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estimated Refund: ₹ ${item['estimated_refund']}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Select Action / Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: newStatus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'quality_inspection', child: Text('Quality Inspection')),
                      DropdownMenuItem(value: 'approved', child: Text('Approve Return')),
                      DropdownMenuItem(value: 'refund_released', child: Text('Release Refund')),
                      DropdownMenuItem(value: 'rejected', child: Text('Reject Return')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => newStatus = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Reason / Remarks:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Notes for customer / record...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);
                          final scaffold = ScaffoldMessenger.of(context);
                          final res = await ProductService.updateReturnDecision(
                            returnId: item['id'],
                            status: newStatus,
                            decisionReason: reasonController.text.trim(),
                          );

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }

                          if (res.isSuccess) {
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text('Return updated to $newStatus'),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                            _loadReturns();
                          } else {
                            scaffold.showSnackBar(
                              SnackBar(content: Text(res.message)),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm Decision', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Returns & Refunds',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.isStandaloneScreen
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            onPressed: _loadReturns,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReturns,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(),
              const SizedBox(height: 16),
              if (_isLoading && _returns.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (_errorMessage != null && _returns.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: Color(0xFFEF4444)),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: _loadReturns, child: const Text('Try Again')),
                    ],
                  ),
                )
              else if (_returns.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_return_outlined, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No return requests in queue', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        const Text('New return or refund requests from buyers will appear here.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _returns.length,
                  itemBuilder: (context, index) {
                    final item = _returns[index] as Map<String, dynamic>;
                    return _buildReturnCard(item);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All Cases'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'quality_inspection', 'label': 'Inspection'},
      {'key': 'approved', 'label': 'Approved'},
      {'key': 'refund_released', 'label': 'Refunded'},
      {'key': 'rejected', 'label': 'Rejected'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStatus == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              onSelected: (_) {
                setState(() => _selectedStatus = f['key']!);
                _loadReturns();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReturnCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? 'pending').toString();
    final returnNum = item['return_number'] ?? 'RMA-Unknown';
    final customer = item['customer_name'] ?? 'Buyer';
    final orderNum = item['order_number'] ?? '';
    final reason = item['reason'] ?? 'Defective';
    final estRefund = item['estimated_refund'] ?? '0.00';
    final courier = item['courier_partner'] ?? 'Delhivery';
    final tracking = item['tracking_number'] ?? '';

    Color statusColor = const Color(0xFFE2E8F0);
    Color statusTextColor = const Color(0xFF475569);
    if (status == 'approved' || status == 'refund_released') {
      statusColor = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF16A34A);
    } else if (status == 'rejected') {
      statusColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    } else if (status == 'quality_inspection' || status == 'pending') {
      statusColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                returnNum,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['product_name'] ?? 'Product',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Order: $orderNum', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(width: 8),
              Text('•  Buyer: $customer', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reason: $reason',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
          ),
          if (tracking.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 13, color: Color(0xFF0284C7)),
                const SizedBox(width: 4),
                Text(
                  '$courier: $tracking',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                ),
              ],
            ),
          ],
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Refund Value', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  Text(
                    '₹ $estRefund',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showDecisionDialog(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('Take Decision', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

