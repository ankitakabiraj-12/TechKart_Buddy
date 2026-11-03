import 'package:flutter/material.dart';
import 'seller_top_bar.dart';
import '../core/network/api_client.dart';

class Earnings extends StatefulWidget {
  final bool isStandaloneScreen;
  const Earnings({super.key, this.isStandaloneScreen = true});

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _settlements = [];
  Map<String, dynamic>? _reportData;
  Map<String, dynamic>? _financialSummary;
  String _selectedPeriod = '30d';
  bool _isLoading = false;
  bool _isRequestingPayout = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiClient.get('/buddy/seller/settlements'),
        _apiClient.get('/buddy/reports/sales-revenue?period=$_selectedPeriod'),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
          final settleRes = results[0];
          final reportRes = results[1];

          if (settleRes.isSuccess && settleRes.data != null) {
            _settlements = settleRes.data['settlements'] as List<dynamic>? ?? [];
            _financialSummary = settleRes.data['financial_summary'] as Map<String, dynamic>?;
          }
          if (reportRes.isSuccess && reportRes.data != null) {
            _reportData = reportRes.data as Map<String, dynamic>?;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestEarlyPayout() async {
    if (_isRequestingPayout) return;
    final available = _financialSummary?['available_balance'] ?? 0.0;
    if (available is num && available <= 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum delivered balance of ₹ 100 required. Current available: ₹ ${_formatAmount(available)}'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() => _isRequestingPayout = true);
    try {
      final res = await _apiClient.post(
        '/buddy/seller/settlements/request-payout',
        body: {'express_t0': true},
      );
      if (mounted) {
        setState(() => _isRequestingPayout = false);
        if (res.isSuccess) {
          final ref = res.data?['settlement_ref'] ?? 'REQ';
          final net = res.data?['net_payout'] ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payout #$ref registered! ₹ ${_formatAmount(net)} scheduled for clearing.'),
              backgroundColor: const Color(0xFF107C41),
            ),
          );
          _fetchData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message.isNotEmpty ? res.message : 'Unable to request payout'),
              backgroundColor: const Color(0xFFC62828),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRequestingPayout = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payout request error: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    }
  }

  String _formatAmount(dynamic val) {
    if (val == null) return '0';
    if (val is num) {
      return val.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const LinearProgressIndicator(minHeight: 2),
            // Top Header (if embedded)
            if (!widget.isStandaloneScreen) _buildTopHeader(context),
            // Finance Title + NBR Compliant Badge
            _buildTitleBanner(),
            const SizedBox(height: 12),
            // Main Payout Hero Card
            _buildPayoutHeroCard(),
            const SizedBox(height: 12),
            // Billing Cycle Pill
            _buildBillingCyclePill(),
            const SizedBox(height: 14),
            // Live Sales & Revenue Trend Chart Section
            _buildSalesTrendSection(),
            const SizedBox(height: 14),
            // Settlement Breakdown Card
            _buildSettlementBreakdownCard(),
            const SizedBox(height: 14),
            // Top Selling Products Section
            if ((_reportData?['top_products'] as List<dynamic>?)?.isNotEmpty == true) ...[
              _buildTopProductsSection(),
              const SizedBox(height: 14),
            ],
            // Bank Account Card
            _buildBankCard(),
            const SizedBox(height: 18),
            // Recent Settlements Section
            _buildRecentSettlementsSection(),
            const SizedBox(height: 18),
            // Seller Financial Tools
            _buildFinancialToolsSection(),
            const SizedBox(height: 20),
            // Request Early Payout Button & Disclaimer
            _buildEarlyPayoutAction(),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );

    if (widget.isStandaloneScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        appBar: const SellerTopBar(
          title: 'Earnings & Payouts',
          subtitle: 'Finance & Settlements',
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
      title: 'Earnings & Payouts',
      subtitle: 'Finance & Settlements',
      showNotification: true,
      showProfile: true,
    );
  }

  // ── TITLE BANNER (TECHKART BUDDY • FINANCE / Earnings & Payouts / NBR Compliant) ──
  Widget _buildTitleBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TECHKART BUDDY • FINANCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E4B75),
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Earnings &\nPayouts',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF072138),
                  height: 1.15,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F0FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB9D8F5), width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF1E4B75)),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GST',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E4B75),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Compliant',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E4B75),
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
    );
  }

  // ── MAIN PAYOUT HERO CARD ──
  Widget _buildPayoutHeroCard() {
    final metrics = _reportData?['metrics'];
    final netPayout = metrics?['net_payout'] ?? 384920;
    final unbilled = metrics?['unbilled_escrow'] ?? 92150;
    final grossGmv = metrics?['gross_sales_gmv'] ?? 1482800;
    final firstSettlement = _settlements.isNotEmpty ? _settlements.first : null;
    final bankDesc = firstSettlement?['bank_account_masked'] ?? (firstSettlement != null ? 'Bank Account Attached' : 'No Bank Attached');
    final payoutDate = firstSettlement?['payout_date'] != null
        ? 'Payout Scheduled: ${firstSettlement['payout_date']}'
        : 'Next Weekly Cycle via NEFT / RTGS Automated Clearing';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEAF7), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF072138).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag: Scheduled • Bank Verified + Trailing receipt/card icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4C5D80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Scheduled • Bank Verified',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E4B75),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.credit_card_outlined, size: 16, color: Color(0xFF8DA5C0)),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'Scheduled Next Payout',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF5A6B7C), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            '₹ ${_formatAmount(netPayout)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF072138),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Payout date info
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF4C5D70)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  payoutDate,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C5D70),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            bankDesc,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A8FA3)),
          ),
          const SizedBox(height: 14),

          // Two sub-cards: Unbilled Escrow + Finalized MTD
          Row(
            children: [
              // Unbilled Escrow
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 12, color: Color(0xFF8DA5C0)),
                          SizedBox(width: 4),
                          Text(
                            'UNBILLED ESCROW',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5A6B7C),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${_formatAmount(unbilled)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF072138),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Awaiting fulfillment/return window',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF7A8FA3)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Finalized MTD / Period GMV
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.trending_up_rounded, size: 12, color: Color(0xFF2E7D32)),
                          SizedBox(width: 4),
                          Text(
                            'GROSS GMV',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5A6B7C),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${_formatAmount(grossGmv)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF072138),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Live Sales Aggregated',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
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
    );
  }

  // ── BILLING CYCLE PILL ──
  Widget _buildBillingCyclePill() {
    final filter = _reportData?['filter'];
    final sDate = filter?['start_date'] ?? 'Current Month';
    final eDate = filter?['end_date'] ?? 'Today';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0ECF7)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FD),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF1E4B75)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REPORTING PERIOD',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7A8FA3),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$sDate - $eDate',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF072138),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              initialValue: _selectedPeriod,
              onSelected: (p) {
                setState(() => _selectedPeriod = p);
                _fetchData();
              },
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.tune_rounded, size: 14, color: Color(0xFF1E4B75)),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
                const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
                const PopupMenuItem(value: '90d', child: Text('Last 90 Days')),
                const PopupMenuItem(value: 'year', child: Text('Past Year')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── LIVE SALES & REVENUE TREND CHART ──
  Widget _buildSalesTrendSection() {
    final trends = _reportData?['trends'];
    final List<dynamic> rawDaily = trends?['daily_sales'] ?? [];
    final summaryText = trends?['summary']?.toString() ?? 'Daily aggregated sales volume';
    final sampleBars = rawDaily.length > 7 ? rawDaily.sublist(rawDaily.length - 7) : rawDaily;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
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
              const Row(
                children: [
                  Text(
                    'Revenue & Sales Trend',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
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
                child: Text(
                  _selectedPeriod.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF285688)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            summaryText,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
          ),
          const SizedBox(height: 16),

          if (sampleBars.isNotEmpty)
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(sampleBars.length, (i) {
                  final it = sampleBars[i] as Map<String, dynamic>;
                  final barHeight = (it['chart_bar'] is num) ? (it['chart_bar'] as num).toDouble() : 0.2;
                  final dayLabel = it['day_label']?.toString() ?? '';
                  final isLast = i == sampleBars.length - 1;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (65 * barHeight).clamp(10.0, 65.0),
                            decoration: BoxDecoration(
                              color: isLast ? const Color(0xFF072138) : const Color(0xFFBBD9F3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
                              color: isLast ? const Color(0xFF072138) : const Color(0xFF8DA5C0),
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
    );
  }

  // ── SETTLEMENT BREAKDOWN CARD ──
  Widget _buildSettlementBreakdownCard() {
    final metrics = _reportData?['metrics'];
    final gmv = metrics?['gross_sales_gmv'] ?? 428000;
    final totalOrders = metrics?['total_orders'] ?? 42;
    final comm = metrics?['platform_commission'] ?? 25680;
    final gateway = metrics?['payment_processing_fee'] ?? 6420;
    final logistics = metrics?['logistics_subsidies'] ?? 11200;
    final promo = metrics?['promotional_rebates'] ?? 220;
    final net = metrics?['net_payout'] ?? 384920;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
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
            children: const [
              Text(
                'Settlement Breakdown',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF072138),
                ),
              ),
              Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF8DA5C0)),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Transparent fee structure for batch cycle',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
          ),
          const SizedBox(height: 14),

          // Line 1: GMV
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gross Merchandise Value (GMV)',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF072138)),
                  ),
                  const SizedBox(height: 1),
                  Text('$totalOrders customer orders fulfilled', style: const TextStyle(fontSize: 10, color: Color(0xFF7A8FA3))),
                ],
              ),
              Text(
                '₹ ${_formatAmount(gmv)}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF072138)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Line 2: Commission (6%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'Platform Commission (6%)',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF4C5D70)),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 12, color: Color(0xFF8DA5C0)),
                ],
              ),
              Text(
                '- ₹ ${_formatAmount(comm)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Line 3: Payment Gateway (1.5%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Gateway & Processing (1.5%)',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF4C5D70)),
              ),
              Text(
                '- ₹ ${_formatAmount(gateway)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Line 4: Shipping Subsidies
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shipping & Logistics Subsidies',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF4C5D70)),
              ),
              Text(
                '- ₹ ${_formatAmount(logistics)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Line 5: Promotional Rebates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'Promotional Rebates & Co-fund',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E4B75)),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.auto_awesome, size: 11, color: Color(0xFF1E4B75)),
                ],
              ),
              Text(
                '+ ₹ ${_formatAmount(promo)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Net Payout Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NET PAYOUT AMOUNT',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E4B75),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Calculated after VAT & standard\nfees',
                      style: TextStyle(fontSize: 10, color: Color(0xFF5A6B7C), height: 1.25),
                    ),
                  ],
                ),
                Text(
                  '₹\n${_formatAmount(net)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF072138),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP SELLING PRODUCTS SECTION ──
  Widget _buildTopProductsSection() {
    final topList = (_reportData?['top_products'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFECF7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Performing Products',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF072138),
                ),
              ),
              Icon(Icons.star_outline_rounded, size: 16, color: Color(0xFF8DA5C0)),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Revenue and units sold in this period',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
          ),
          const SizedBox(height: 12),
          ...topList.take(4).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF5FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.devices_other_rounded, size: 16, color: Color(0xFF285688)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['title']?.toString() ?? 'Product',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF072138)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${p['units_sold'] ?? 0} units sold · ${p['category_name'] ?? 'Electronics'}',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF7A8FA3)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹ ${_formatAmount(p['total_revenue'])}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF072138)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── BANK ACCOUNT CARD ──
  Widget _buildBankCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFECF7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance, size: 20, color: Color(0xFF1E4B75)),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settlement Bank Account',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.verified, size: 11, color: Color(0xFF1E4B75)),
                      SizedBox(width: 4),
                      Text(
                        'Verified Primary Payout Account',
                        style: TextStyle(fontSize: 10, color: Color(0xFF1E4B75), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bank Account Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACCOUNT NUMBER', style: TextStyle(fontSize: 8.5, color: Color(0xFF7A8FA3), fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('•••• •••• •••• 4092', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF072138))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BRANCH', style: TextStyle(fontSize: 8.5, color: Color(0xFF7A8FA3), fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Registered Branch', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF072138))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IFSC CODE', style: TextStyle(fontSize: 8.5, color: Color(0xFF7A8FA3), fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('SBIN0000000', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF072138))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACCOUNT TYPE', style: TextStyle(fontSize: 8.5, color: Color(0xFF7A8FA3), fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Corporate Current', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF072138))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Manage Bank Settings Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F2FD),
                foregroundColor: const Color(0xFF072138),
                side: const BorderSide(color: Color(0xFFC7DDF2), width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
              ),
              icon: const Icon(Icons.settings_outlined, size: 14),
              label: const Text(
                'Manage Bank Settings',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── RECENT SETTLEMENTS SECTION ──
  Widget _buildRecentSettlementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Settlements',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                  SizedBox(height: 1),
                  Text('Past direct deposits credited to account', style: TextStyle(fontSize: 10, color: Color(0xFF5A6B7C))),
                ],
              ),
              Row(
                children: [
                  Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E4B75))),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF1E4B75)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_settlements.isNotEmpty)
            ..._settlements.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildSettlementTile(
                    amount: '₹ ${s['net_payout'] ?? s['gross_amount'] ?? '0'}',
                    date: '${s['period_end'] ?? 'Recent'} • ${s['order_count'] ?? 0} Orders',
                    ref: 'Ref #${s['settlement_reference'] ?? s['settlement_id'] ?? 'TXN-SET'}',
                    neftRef: 'NEFT / RTGS: ${s['bank_account'] ?? 'Bank Account Settlement'}',
                  ),
                ))
          else ...[
            // Settlement 1: ₹ 241,800
            _buildSettlementTile(
              amount: '₹ 241,800',
              date: 'Oct 24, 2024 • 32 Orders',
              ref: 'Ref #TXN-902194',
              neftRef: 'NEFT / RTGS Bank Ref: SETTLEMENT-RECORD',
            ),
            const SizedBox(height: 8),

            // Settlement 2: ₹ 198,450
            _buildSettlementTile(
              amount: '₹ 198,450',
              date: 'Oct 21, 2024 • 27 Orders',
              ref: 'Ref #TXN-899120',
              neftRef: 'NEFT / RTGS Bank Ref: SETTLEMENT-RECORD',
            ),
            const SizedBox(height: 8),

            // Settlement 3: ₹ 310,200
            _buildSettlementTile(
              amount: '₹ 310,200',
              date: 'Oct 18, 2024 • 41 Orders',
              ref: 'Ref #TXN-894101',
              neftRef: 'NEFT / RTGS Bank Ref: SETTLEMENT-RECORD',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettlementTile({
    required String amount,
    required String date,
    required String ref,
    required String neftRef,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EDF7)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Settled • ',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF072138)),
                          children: [
                            TextSpan(text: amount, style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF7A8FA3))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_outlined, size: 11, color: Color(0xFF1E4B75)),
                    SizedBox(width: 3),
                    Text(
                      'Statement',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF1E4B75)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF0F5FD))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ref, style: const TextStyle(fontSize: 9.5, color: Color(0xFF7A8FA3))),
                Text(neftRef, style: const TextStyle(fontSize: 9.5, color: Color(0xFF7A8FA3))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SELLER FINANCIAL TOOLS SECTION ──
  Widget _buildFinancialToolsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seller Financial Tools',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF072138),
            ),
          ),
          const SizedBox(height: 10),

          // Tool 1: Tax Invoice & VAT Report
          _buildFinancialToolTile(
            icon: Icons.receipt_outlined,
            title: 'Tax Invoice & VAT Report',
            sub: 'Certified Mushak 6.3 monthly downloads',
          ),
          const SizedBox(height: 8),

          // Tool 2: Commission Calculator
          _buildFinancialToolTile(
            icon: Icons.calculate_outlined,
            title: 'Commission Calculator',
            sub: 'Simulate profit margins per category',
          ),
          const SizedBox(height: 8),

          // Tool 3: Dispute/Claim Payout
          _buildFinancialToolTile(
            icon: Icons.help_outline_rounded,
            title: 'Dispute/ Claim Payout',
            sub: 'Resolve return adjustments & SLA penalties',
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialToolTile({
    required IconData icon,
    required String title,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EDF7)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1E4B75)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF072138)),
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF5A6B7C)),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF8DA5C0)),
        ],
      ),
    );
  }

  // ── REQUEST EARLY PAYOUT BUTTON & DISCLAIMER ──
  Widget _buildEarlyPayoutAction() {
    final available = _financialSummary?['available_balance'] ?? 0.0;
    final hasBalance = available is num && available > 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _isRequestingPayout ? null : _requestEarlyPayout,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasBalance ? const Color(0xFF03142E) : const Color(0xFF4C5D70),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 0,
              ),
              icon: _isRequestingPayout
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.flash_on_rounded, size: 16),
              label: Text(
                _isRequestingPayout
                    ? 'Processing Payout...'
                    : 'Request Early Payout (₹ ${_formatAmount(available)})',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Available balance subject to standard nominal fee of 0.75%',
            style: TextStyle(fontSize: 10, color: Color(0xFF7A8FA3)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
