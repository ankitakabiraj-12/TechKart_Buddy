import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import '../seller/product_service.dart';

class ReturnsAndDisputesScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const ReturnsAndDisputesScreen({super.key, this.onNavigateTab});

  @override
  State<ReturnsAndDisputesScreen> createState() =>
      _ReturnsAndDisputesScreenState();
}

class _ReturnsAndDisputesScreenState extends State<ReturnsAndDisputesScreen> {
  int _selectedFilter = 0; // 0: All Disputes, 1: Inspection / Pending, 2: Approved / Refunded
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _returns = [];
  double _totalEscrowLocked = 0.0;
  int _totalCases = 0;

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? statusParam;
      if (_selectedFilter == 1) {
        statusParam = 'pending';
      } else if (_selectedFilter == 2) {
        statusParam = 'approved';
      }

      final res = await ProductService.getReturns(status: statusParam);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (res.isSuccess && res.data != null) {
            final data = res.data as Map<String, dynamic>;
            _returns = data['returns'] as List<dynamic>? ?? [];
            _totalCases = _returns.length;
            _totalEscrowLocked = _returns.fold<double>(
              0.0,
              (sum, item) => sum + (double.tryParse(item['estimated_refund']?.toString() ?? '0') ?? 0.0),
            );
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

  Future<void> _executeAdminRuling(Map<String, dynamic> item, String rulingStatus) async {
    final scaffold = ScaffoldMessenger.of(context);
    final returnId = item['id'];
    final returnNum = item['return_number'] ?? 'RMA';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(rulingStatus == 'refund_released' ? 'Execute Rule & Refund' : 'Reject Buyer Claim'),
        content: Text(
          rulingStatus == 'refund_released'
              ? 'Are you sure you want to approve and release ₹ ${item['estimated_refund']} refund for $returnNum?'
              : 'Are you sure you want to reject return claim $returnNum?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: rulingStatus == 'refund_released' ? const Color(0xFF03253B) : const Color(0xFFB52E1D),
            ),
            child: Text(
              rulingStatus == 'refund_released' ? 'Release Refund' : 'Reject Claim',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await ProductService.updateReturnDecision(
      returnId: returnId,
      status: rulingStatus,
      decisionReason: rulingStatus == 'refund_released'
          ? 'Admin dispute resolution: Item condition confirmed defective. Refund released.'
          : 'Admin dispute resolution: Item does not meet return eligibility criteria.',
    );

    if (res.isSuccess) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(rulingStatus == 'refund_released' ? 'Refund successfully released!' : 'Claim rejected.'),
          backgroundColor: rulingStatus == 'refund_released' ? const Color(0xFF16A34A) : const Color(0xFFB52E1D),
        ),
      );
      _loadDisputes();
    } else {
      scaffold.showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }

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
              child: RefreshIndicator(
                onRefresh: _loadDisputes,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LIVE DISPUTE QUEUE Banner
                      _buildLiveQueueBanner(),

                      const SizedBox(height: 12),

                      // 2x1 Metric Cards
                      _buildTopMetricsRow(),

                      const SizedBox(height: 10),

                      // IMMINENT SLA BREACH Alert Banner
                      _buildSlaBreachAlert(),

                      const SizedBox(height: 12),

                      // Dispute Filter Pills
                      _buildFilterPills(),

                      const SizedBox(height: 14),

                      if (_isLoading && _returns.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_errorMessage != null && _returns.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 36, color: Color(0xFFEF4444)),
                                const SizedBox(height: 8),
                                Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B))),
                                const SizedBox(height: 10),
                                ElevatedButton(onPressed: _loadDisputes, child: const Text('Retry')),
                              ],
                            ),
                          ),
                        )
                      else if (_returns.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.verified_user_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                const Text(
                                  'Dispute Queue Clear',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2B445B)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'All customer returns and disputes have been resolved.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6B8299)),
                                ),
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
                            return _buildDisputeCard(item);
                          },
                        ),

                      const SizedBox(height: 14),

                      // Protocol Notice Card
                      _buildProtocolNoticeCard(),

                      const SizedBox(height: 24),
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: AdminTopBar(
        title: 'Disputes & Returns',
        subtitle: 'Marketplace Escalation Queue',
        onBack: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else if (widget.onNavigateTab != null) {
            widget.onNavigateTab!(0);
          }
        },
        onNotificationTap: () {},
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
          );
        },
      ),
    );
  }

  Widget _buildLiveQueueBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC7DEFA), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1E88E5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'LIVE DISPUTE QUEUE',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFF1E5B94),
            ),
          ),
          const Spacer(),
          Text(
            'Auto-sync: IST Active',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDFECF7), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL IN QUEUE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B8299),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_totalCases Cases',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Escalation Triage',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDFECF7), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESCROW LOCKED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B8299),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹ ${_totalEscrowLocked.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Protected In Escrow',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlaBreachAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD8BF), width: 1),
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time_rounded, size: 16, color: Color(0xFFD84A00)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'National e-Commerce policy mandates dispute resolution within 48h of return pickup.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E3600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['All Disputes ($_totalCases)', 'Pending / Inspection', 'Approved / Refunded'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = entry.key;
                });
                _loadDisputes();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF03253B) : const Color(0xFFE4F0FC),
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

  Widget _buildDisputeCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? 'pending').toString();
    final returnNum = item['return_number'] ?? 'RMA';
    final product = item['product_name'] ?? 'Product';
    final customer = item['customer_name'] ?? 'Customer';
    final email = item['customer_email'] ?? '';
    final reason = item['reason'] ?? 'Defective';
    final refund = item['estimated_refund'] ?? '0.00';
    final courier = item['courier_partner'] ?? 'Delhivery';
    final tracking = item['tracking_number'] ?? '';
    final isFinalized = status == 'refund_released' || status == 'completed' || status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(
                'CASE #$returnNum',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status == 'refund_released' || status == 'approved'
                      ? const Color(0xFFDCFCE7)
                      : (status == 'rejected' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: status == 'refund_released' || status == 'approved'
                        ? const Color(0xFF16A34A)
                        : (status == 'rejected' ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Text(
            'Buyer: $customer ($email) • Order #${item['order_number'] ?? ''}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            'Claim Reason: $reason',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
          ),
          if (tracking.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  Text(
                    'Logistic: $courier ($tracking)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Refund Escrow', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  Text(
                    '₹ $refund',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF03253B)),
                  ),
                ],
              ),
              if (!isFinalized)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _executeAdminRuling(item, 'rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFB52E1D),
                        side: const BorderSide(color: Color(0xFFFBD0CA)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text('Reject Claim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _executeAdminRuling(item, 'refund_released'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03253B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text('Rule & Refund', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'Dispute Adjudicated',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolNoticeCard() {
    return Container(
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
                'STATUTORY COMPLIANCE & PROTOCOL\nNOTICE',
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
            'Governed pursuant to the Information Technology Act 2000 & national digital e-commerce escrow policies. Dispute payouts and refunds are dispatched exclusively via cryptographically validated merchant gateway protocols (Razorpay, UPI / Razorpay, NEFT / RTGS). Admin manual releases without cryptographic provider receipt are prohibited.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: Color(0xFF2B445B),
            ),
          ),
        ],
      ),
    );
  }
}
