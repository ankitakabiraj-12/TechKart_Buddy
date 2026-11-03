import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import 'admin_payment_service.dart';

class PaymentsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const PaymentsScreen({super.key, this.onNavigateTab});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  // Filters: 0: All Batches, 1: Pending / Eligible, 2: Completed, 3: Under Risk Hold
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  // Date Filter State
  String? _startDate;
  String? _endDate;
  String _selectedDatePreset = 'All Time';

  // Loading & Error States
  bool _isLoading = false;
  String? _errorMessage;

  // Data
  Map<String, dynamic>? _salesReport;
  Map<String, dynamic>? _settlementSummary;
  List<dynamic> _settlements = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFinancialData({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String statusParam = 'all';
      if (_selectedFilter == 1) {
        statusParam = 'pending';
      } else if (_selectedFilter == 2) {
        statusParam = 'completed';
      } else if (_selectedFilter == 3) {
        statusParam = 'held';
      }

      final query = _searchController.text.trim();

      // Parallel fetch: Sales & Revenue report + Settlements directory
      final results = await Future.wait([
        AdminPaymentService.getSalesRevenueReport(
          startDate: _startDate,
          endDate: _endDate,
        ),
        AdminPaymentService.getSettlements(
          search: query.isNotEmpty ? query : null,
          status: statusParam,
          startDate: _startDate,
          endDate: _endDate,
          page: page,
          limit: 10,
        ),
      ]);

      if (mounted) {
        final reportData = results[0];
        final settlementData = results[1];

        setState(() {
          _isLoading = false;
          _salesReport = reportData;

          if (settlementData != null) {
            _settlements = settlementData['settlements'] as List<dynamic>? ?? [];
            _settlementSummary = settlementData['financial_summary'] as Map<String, dynamic>?;
            final pagination = settlementData['pagination'] as Map<String, dynamic>?;
            _currentPage = pagination?['page'] ?? 1;
            _totalPages = pagination?['total_pages'] ?? 1;
            _totalCount = pagination?['total'] ?? _settlements.length;
          } else {
            _errorMessage = 'Failed to load settlements from server';
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

  void _onFilterSelected(int index) {
    setState(() {
      _selectedFilter = index;
    });
    _loadFinancialData(page: 1);
  }

  void _setDatePreset(String preset, String? start, String? end) {
    setState(() {
      _selectedDatePreset = preset;
      _startDate = start;
      _endDate = end;
    });
    _loadFinancialData(page: 1);
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: _startDate != null ? DateTime.parse(_startDate!) : now.subtract(const Duration(days: 30)),
        end: _endDate != null ? DateTime.parse(_endDate!) : now,
      ),
    );

    if (picked != null) {
      final sStr = picked.start.toIso8601String().split('T').first;
      final eStr = picked.end.toIso8601String().split('T').first;
      _setDatePreset('$sStr to $eStr', sStr, eStr);
    }
  }

  Future<void> _authorizeRelease(int settlementId, String ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Authorize Settlement Release', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w800, color: Color(0xFF03253B))),
        content: Text('Are you sure you want to authorize NEFT/RTGS release for dossier #$ref?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B8095))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF107C41),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Authorize Payout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await AdminPaymentService.releaseSettlement(settlementId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : 'Settlement payout authorized'),
            backgroundColor: res.isSuccess ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
          ),
        );
        _loadFinancialData(page: _currentPage);
      }
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

            // Main Scrollable Content
            Expanded(
              child: _isLoading && _settlements.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF03253B)))
                  : _errorMessage != null && _settlements.isEmpty
                      ? _buildErrorView()
                      : RefreshIndicator(
                          color: const Color(0xFF03253B),
                          onRefresh: () => _loadFinancialData(page: _currentPage),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Node Status Banner
                                _buildNodeStatusBanner(),

                                const SizedBox(height: 14),

                                // 2x2 Metric Summary Grid
                                _buildMetricsGrid(),

                                const SizedBox(height: 14),

                                // Settlement Date Window Bar
                                _buildDateWindowBar(),

                                const SizedBox(height: 12),

                                // Search Merchant ID / Settlement Ref
                                _buildSearchBar(),

                                const SizedBox(height: 10),

                                // Filter Pills (All Batches, Eligible for Release, Completed, Under Risk Hold)
                                _buildFilterPills(),

                                const SizedBox(height: 16),

                                // Section Title: Settlement Dossiers
                                _buildDossiersSectionHeader(),

                                const SizedBox(height: 12),

                                // Empty view if no settlements found
                                if (_settlements.isEmpty)
                                  _buildEmptyView()
                                else ...[
                                  // Live Dossier Cards List
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _settlements.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      final dossier = _settlements[index];
                                      return _buildLiveDossierCard(dossier);
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  // Pagination Controls
                                  _buildPaginationControls(),
                                ],

                                const SizedBox(height: 16),

                                // Governance & Anti-Duplicate Protection Card
                                _buildGovernanceCard(),

                                const SizedBox(height: 20),
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
    return AdminTopBar(
      title: 'Settlement Treasury',
      subtitle: 'Disbursement Queue & Escrow Reconciliation',
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(0);
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

  Widget _buildNodeStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF107C41),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Node IN-MUM-FIN-01 • NEFT / RTGS & UPI Gateway...',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),
          const Text(
            'IST Live Synced',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF285C8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    // Read from live report and settlement summary
    final grossGmv = (_salesReport?['metrics']?['gross_sales_gmv'] as num?)?.toDouble() ??
        (_settlementSummary?['gross_sales_gmv'] as num?)?.toDouble() ??
        0.0;
    final grossGmvFmt = '₹ ${_formatAmount(grossGmv)}';

    final pendingAmt = (_settlementSummary?['pending_payouts'] as num?)?.toDouble() ?? 0.0;
    final pendingAmtFmt = '₹ ${_formatAmount(pendingAmt)}';

    final unbilledEscrow = (_settlementSummary?['unbilled_escrow'] as num?)?.toDouble() ?? 0.0;
    final unbilledEscrowFmt = '₹ ${_formatAmount(unbilledEscrow)}';

    final heldAmt = (_settlementSummary?['held_payouts'] as num?)?.toDouble() ?? 0.0;
    final heldAmtFmt = '₹ ${_formatAmount(heldAmt)}';

    final totalOrders = (_salesReport?['metrics']?['total_orders'] as num?)?.toInt() ??
        (_settlementSummary?['total_orders'] as num?)?.toInt() ??
        0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'DISBURSEMENT POOL',
                value: pendingAmtFmt,
                sub: 'Ready for NEFT / RTGS',
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFF285C8A),
                cardBg: Colors.white,
                hasDot: true,
                dotColor: const Color(0xFF107C41),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'TOTAL GROSS GMV',
                value: grossGmvFmt,
                sub: '$totalOrders Live Orders',
                icon: Icons.pie_chart_outline_rounded,
                iconColor: const Color(0xFF107C41),
                cardBg: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'ESCROW IN-TRANSIT',
                value: unbilledEscrowFmt,
                sub: 'Held pending delivery',
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF75551E),
                cardBg: Colors.white,
                hasDot: true,
                dotColor: const Color(0xFF75551E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'RISK / HELD PAYOUTS',
                value: heldAmtFmt,
                sub: 'Audit & Compliance Hold',
                icon: Icons.highlight_off_rounded,
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
    Color? valColor,
    Color? subColor,
    bool hasDot = false,
    Color? dotColor,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B8095),
                  letterSpacing: 0.4,
                  height: 1.15,
                ),
              ),
              Icon(icon, size: 15, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valColor ?? const Color(0xFF03253B),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              if (hasDot) ...[
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: dotColor ?? const Color(0xFF285C8A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  sub,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: subColor ?? const Color(0xFF6B8095),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateWindowBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EEFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF285C8A)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SETTLEMENT WINDOW',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF556F88),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    _selectedDatePreset,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              final now = DateTime.now();
              if (val == 'all') {
                _setDatePreset('All Time', null, null);
              } else if (val == '30d') {
                final s = now.subtract(const Duration(days: 30)).toIso8601String().split('T').first;
                final e = now.toIso8601String().split('T').first;
                _setDatePreset('Last 30 Days', s, e);
              } else if (val == '7d') {
                final s = now.subtract(const Duration(days: 7)).toIso8601String().split('T').first;
                final e = now.toIso8601String().split('T').first;
                _setDatePreset('Last 7 Days', s, e);
              } else if (val == 'custom') {
                _selectCustomDateRange();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Time')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
              const PopupMenuItem(value: 'custom', child: Text('Custom Range...')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 12, color: Color(0xFF285C8A)),
                  SizedBox(width: 4),
                  Text(
                    'Filter Date',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF285C8A),
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

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF4C6A88)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadFinancialData(page: 1),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF03253B),
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Search Merchant Name, Settlement Ref, Bank...',
                hintStyle: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF5A7591),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _loadFinancialData(page: 1);
              },
              child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF4C6A88)),
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF285C8A)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _loadFinancialData(page: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = [
      'All Batches ($_totalCount)',
      'Pending / Eligible',
      'Completed',
      'Under Risk Hold',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _onFilterSelected(entry.key),
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

  Widget _buildDossiersSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Settlement\nDossiers',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF03253B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD6EEFD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                'Showing ${_settlements.length} of $_totalCount',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF285C8A),
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF107C41),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'MariaDB\nSynced',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF556F88),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveDossierCard(Map<String, dynamic> d) {
    final settlementId = d['id'] as int;
    final ref = d['settlement_ref']?.toString() ?? 'STL-UNKNOWN';
    final storeName = d['store_name']?.toString() ?? d['contact_person']?.toString() ?? 'Merchant';
    final sellerId = d['seller_id'] ?? 0;
    final grossSales = (d['gross_sales'] as num?)?.toDouble() ?? 0.0;
    final platformComm = (d['platform_commission'] as num?)?.toDouble() ?? 0.0;
    final procFee = (d['payment_processing_fee'] as num?)?.toDouble() ?? 0.0;
    final netPayout = (d['net_payout'] as num?)?.toDouble() ?? 0.0;
    final status = (d['status']?.toString() ?? 'pending').toLowerCase();
    final bankMasked = d['bank_account_masked']?.toString() ?? d['bank_name']?.toString() ?? 'Bank Account';
    final pStart = d['period_start']?.toString() ?? '';
    final pEnd = d['period_end']?.toString() ?? '';

    final isCompleted = status == 'completed';
    final isHeld = status == 'held';

    Color pillBg = const Color(0xFFD6EEFD);
    Color pillFg = const Color(0xFF285C8A);
    String pillText = 'Ready for NEFT / RTGS';
    if (isCompleted) {
      pillBg = const Color(0xFFE8F5E9);
      pillFg = const Color(0xFF107C41);
      pillText = 'Disbursed / Completed';
    } else if (isHeld) {
      pillBg = const Color(0xFFFDE8E5);
      pillFg = const Color(0xFFB52E1D);
      pillText = 'Risk Withheld';
    }

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
                  _buildCodeTag('#$ref'),
                  const SizedBox(width: 6),
                  _buildStatusPill(pillText, pillBg, pillFg, dot: true),
                ],
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F0FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_outline_rounded : (isHeld ? Icons.shield_outlined : Icons.account_balance_rounded),
                  size: 16,
                  color: pillFg,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            storeName,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF03253B),
            ),
          ),
          Text(
            'Merchant ID: TK-SLR-$sellerId • Window: $pStart to $pEnd',
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
          ),

          const SizedBox(height: 10),

          // Financial Breakdown box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildAmountRow('Gross Sales GMV', '₹ ${_formatAmount(grossSales)}'),
                _buildAmountRow('Platform Commission', '-₹ ${_formatAmount(platformComm)}', isNegative: true),
                _buildAmountRow('Payment Processing Fee', '-₹ ${_formatAmount(procFee)}', isNegative: true),
                const Divider(height: 14, color: Color(0xFFE2ECF5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Net Payable Payout',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF03253B)),
                    ),
                    Text(
                      '₹ ${_formatAmount(netPayout)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF03253B)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Bank Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_outlined, size: 13, color: Color(0xFF285C8A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    bankMasked,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF285C8A), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Authorize Release Button (only if not completed)
          if (!isCompleted)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => _authorizeRelease(settlementId, ref),
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
                            'Authorize NEFT / RTGS Release',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: const [
                Icon(Icons.verified_rounded, size: 13, color: Color(0xFF107C41)),
                SizedBox(width: 4),
                Text(
                  'Settlement disbursed & archived to immutable ledger.',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF107C41), fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCodeTag(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD6EEFD), width: 1),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF285C8A),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, Color bg, Color fg, {bool dot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF556F88)),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isNegative ? const Color(0xFFB52E1D) : const Color(0xFF03253B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentPage > 1
                ? () => _loadFinancialData(page: _currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 16),
            label: const Text('Previous', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCFD8DC),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF03253B),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _currentPage < _totalPages
                ? () => _loadFinancialData(page: _currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 16),
            label: const Text('Next', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCFD8DC),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernanceCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, size: 15, color: Color(0xFF285C8A)),
              SizedBox(width: 6),
              Text(
                'DUAL-AUTHORIZATION DISBURSEMENT GATEWAY',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Batch releases > ₹ 100,000 require Secondary Officer approval. Payouts trigger webhook confirmation, update seller ledger, and record immutable audit logs.',
            style: TextStyle(
              fontSize: 9.5,
              height: 1.35,
              color: Color(0xFF2B445B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 48, color: Color(0xFF90A4AE)),
          const SizedBox(height: 12),
          const Text(
            'No Settlement Dossiers Found',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF03253B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No settlement records match your filters or search query.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Color(0xFF556F88)),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _setDatePreset('All Time', null, null);
              _onFilterSelected(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Clear Filters & Search', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFB52E1D)),
            const SizedBox(height: 12),
            const Text(
              'Failed to Load Financial Settlements',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF03253B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF556F88)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadFinancialData(page: _currentPage),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03253B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
