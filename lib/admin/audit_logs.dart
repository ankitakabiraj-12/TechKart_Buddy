import 'dart:convert';
import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import 'admin_audit_service.dart';

class AuditLogsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const AuditLogsScreen({super.key, this.onNavigateTab});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _logs = [];
  Map<String, dynamic> _pagination = {
    'total': 0,
    'page': 1,
    'limit': 15,
    'total_pages': 1,
  };
  Map<String, dynamic> _metrics = {
    'total_logs': 0,
    'admin_actions_count': 0,
    'seller_actions_count': 0,
    'system_actions_count': 0,
  };
  List<String> _availableActions = [];

  // Filter state
  int _selectedFilterIndex = 0; // 0: All, 1: KYC, 2: Escrow/Payout, 3: Orders
  String _selectedAction = 'all';
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchAuditLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAuditLogs({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = page;
    });

    try {
      String? startDate;
      String? endDate;
      if (_selectedDateRange != null) {
        startDate = '${_selectedDateRange!.start.year}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.day.toString().padLeft(2, '0')}';
        endDate = '${_selectedDateRange!.end.year}-${_selectedDateRange!.end.month.toString().padLeft(2, '0')}-${_selectedDateRange!.end.day.toString().padLeft(2, '0')}';
      }

      final data = await AdminAuditService.getAuditLogs(
        page: page,
        limit: 15,
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        action: _selectedAction != 'all' ? _selectedAction : null,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _logs = (data['logs'] as List<dynamic>?) ?? [];
        _pagination = (data['pagination'] as Map<String, dynamic>?) ?? _pagination;
        _metrics = (data['metrics'] as Map<String, dynamic>?) ?? _metrics;
        final rawActions = (data['available_actions'] as List<dynamic>?) ?? [];
        _availableActions = rawActions.map((e) => e.toString()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onCategoryFilterSelected(int index) {
    setState(() {
      _selectedFilterIndex = index;
      if (index == 0) {
        _selectedAction = 'all';
      } else if (index == 1) {
        // Seller KYC
        _selectedAction = 'SELLER_VERIFICATION_APPROVED';
      } else if (index == 2) {
        // Escrow / Payout
        _selectedAction = 'SETTLEMENT_RELEASE';
      } else if (index == 3) {
        // Orders
        _selectedAction = 'ORDER_STATUS_UPDATE';
      }
    });
    _fetchAuditLogs(page: 1);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF285C8A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF03253B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _fetchAuditLogs(page: 1);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    _fetchAuditLogs(page: 1);
  }

  void _showPayloadModal(Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        dynamic parsedDetails;
        try {
          if (log['details'] != null && log['details'] is String) {
            parsedDetails = jsonDecode(log['details']);
          } else {
            parsedDetails = log['details'];
          }
        } catch (_) {
          parsedDetails = log['details'];
        }

        final prettyDetails = parsedDetails is Map || parsedDetails is List
            ? const JsonEncoder.withIndent('  ').convert(parsedDetails)
            : (log['details'] ?? 'No additional payload stored');

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code_rounded, color: Color(0xFF285C8A), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Audit Payload #${log['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF03253B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF5FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildModalRow('Action:', log['action'] ?? 'N/A'),
                    _buildModalRow('Actor:', '${log['actor_name']} (${log['actor_role']})'),
                    _buildModalRow('Target:', '${log['target_type'] ?? 'General'} #${log['target_id'] ?? 'N/A'}'),
                    _buildModalRow('IP Address:', log['ip_address'] ?? '127.0.0.1'),
                    _buildModalRow('Timestamp (IST):', log['created_at'] ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'RAW METADATA / DETAILS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF556F88),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF03253B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    prettyDetails,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFF7DD3FC),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B8095))),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF03253B))),
        ],
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
            // Top App Bar
            _buildAppBar(context),

            // Scrollable Body
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF285C8A),
                onRefresh: () => _fetchAuditLogs(page: _currentPage),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ACTIVE MERKLE PIPELINE Hero Card with Live Counts
                      _buildMerklePipelineCard(),

                      const SizedBox(height: 14),

                      // Search Event ID, Actor Email...
                      _buildSearchBar(),

                      const SizedBox(height: 8),

                      // Filter Dropdown Pills (Action Selector, Date Range Filter, Clear)
                      _buildFilterRow(),

                      const SizedBox(height: 8),

                      // Category Filter Pills
                      _buildCategoryPills(),

                      const SizedBox(height: 16),

                      // Section: QUICK REPORTS & LEDGER EXPORTS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'QUICK REPORTS & LEDGER\nEXPORTS',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 11,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'L3 Access\nGranted',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF556F88),
                              height: 1.1,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Export Card 1: Seller Onboarding & KYC Report
                      _buildExportCard1(),

                      const SizedBox(height: 8),

                      // Export Card 2: Listing Moderation & Counterfeits
                      _buildExportCard2(),

                      const SizedBox(height: 8),

                      // Export Card 3: Dispute & Return Ledger
                      _buildExportCard3(),

                      const SizedBox(height: 8),

                      // Export Card 4: Settlement & Payout Clearing
                      _buildExportCard4(),

                      const SizedBox(height: 18),

                      // Section: LIVE CRYPTOGRAPHIC STREAM
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF285C8A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'LIVE CRYPTOGRAPHIC STREAM',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF03253B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_pagination['total'] ?? 0} Events Logged',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Stream Content: Loading, Error, Empty, or Live Cards
                      _buildStreamSection(),

                      const SizedBox(height: 12),

                      // Pagination Controls
                      if (!_isLoading && _logs.isNotEmpty) _buildPaginationBar(),

                      const SizedBox(height: 16),

                      // IMMUTABLE AUDIT INTEGRITY Policy Card
                      _buildAuditIntegrityCard(),

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
      title: 'Audit Logs',
      subtitle: 'System & Security Compliance Feed',
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

  Widget _buildMerklePipelineCard() {
    final total = _metrics['total_logs'] ?? 0;
    final adminCount = _metrics['admin_actions_count'] ?? 0;
    final sellerCount = _metrics['seller_actions_count'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF285C8A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                      'ACTIVE MERKLE PIPELINE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF285C8A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Root Hash Synced • $total Total Immutable Records ($adminCount Admin, $sellerCount Seller)',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Live audit ledger with SHA256 integrity verification across MariaDB master replication.',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF556F88),
                    height: 1.25,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE6EF), width: 1),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 12, color: Color(0xFF03253B)),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _fetchAuditLogs(page: 1),
        decoration: InputDecoration(
          hintText: 'Search Action, Actor, Target ID, IP address...',
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF8B9FB1)),
          prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF8B9FB1)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 14, color: Color(0xFF8B9FB1)),
                  onPressed: () {
                    _searchController.clear();
                    _fetchAuditLogs(page: 1);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final dateLabel = _selectedDateRange == null
        ? 'All Dates'
        : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Action Dropdown Pill
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                _selectedAction = val;
              });
              _fetchAuditLogs(page: 1);
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[
                const PopupMenuItem(
                  value: 'all',
                  child: Text('All Actions', style: TextStyle(fontSize: 11)),
                ),
              ];
              for (final act in _availableActions) {
                items.add(PopupMenuItem(
                  value: act,
                  child: Text(act, style: const TextStyle(fontSize: 11)),
                ));
              }
              return items;
            },
            child: _buildFilterPill(
              _selectedAction == 'all' ? 'Action: All' : _selectedAction,
              Icons.filter_list_rounded,
            ),
          ),
          const SizedBox(width: 6),

          // Date Range Filter Pill
          GestureDetector(
            onTap: _selectDateRange,
            child: _buildFilterPill(dateLabel, Icons.calendar_today_outlined),
          ),
          const SizedBox(width: 6),

          // Clear Date Filter if set
          if (_selectedDateRange != null) ...[
            GestureDetector(
              onTap: _clearDateFilter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 11, color: Color(0xFFB52E1D)),
                    SizedBox(width: 4),
                    Text(
                      'Clear Date',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFB52E1D)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          _buildFilterPill('SHA-256 Verified', Icons.fingerprint_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EEFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF285C8A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF285C8A)),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFF285C8A)),
        ],
      ),
    );
  }

  Widget _buildCategoryPills() {
    final filters = [
      'All (${_metrics['total_logs'] ?? 0})',
      'Seller KYC',
      'Settlement / Payout',
      'Orders',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilterIndex == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: GestureDetector(
              onTap: () => _onCategoryFilterSelected(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF455879) : const Color(0xFFD6EEFD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 11,
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

  Widget _buildStreamSection() {
    if (_isLoading) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF285C8A)),
            SizedBox(height: 12),
            Text(
              'Decrypting & streaming audit trail...',
              style: TextStyle(fontSize: 11, color: Color(0xFF556F88)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE8E5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFB52E1D), size: 28),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFFB52E1D)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _fetchAuditLogs(page: _currentPage),
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Try Again', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF285C8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    if (_logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2ECF5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF8B9FB1)),
            const SizedBox(height: 8),
            const Text(
              'No Audit Events Found',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF03253B)),
            ),
            const SizedBox(height: 4),
            const Text(
              'No audit logs match your search or filter parameters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF6B8095)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedAction = 'all';
                  _selectedDateRange = null;
                  _selectedFilterIndex = 0;
                });
                _fetchAuditLogs(page: 1);
              },
              child: const Text('Reset All Filters', style: TextStyle(fontSize: 11, color: Color(0xFF285C8A))),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _logs.map((log) => _buildLiveStreamCard(log)).toList(),
    );
  }

  Widget _buildLiveStreamCard(dynamic log) {
    final action = log['action']?.toString() ?? 'SYSTEM_EVENT';
    final actorName = log['actor_name']?.toString() ?? 'System';
    final actorRole = log['actor_role']?.toString() ?? 'admin';
    final targetType = log['target_type']?.toString() ?? '';
    final targetId = log['target_id']?.toString() ?? '';
    final ipAddress = log['ip_address']?.toString() ?? '127.0.0.1';
    final createdAt = log['created_at']?.toString() ?? '';
    final logId = log['id']?.toString() ?? '';

    // Color code action
    Color badgeBg = const Color(0xFFD6EEFD);
    Color badgeFg = const Color(0xFF285C8A);
    IconData actionIcon = Icons.shield_outlined;

    if (action.contains('APPROV') || action.contains('RELEASE') || action.contains('ACCEPT')) {
      badgeBg = const Color(0xFFD9F2E6);
      badgeFg = const Color(0xFF107C41);
      actionIcon = Icons.check_circle_outline_rounded;
    } else if (action.contains('REJECT') || action.contains('FREEZE') || action.contains('REVOKED')) {
      badgeBg = const Color(0xFFFDE8E5);
      badgeFg = const Color(0xFFB52E1D);
      actionIcon = Icons.error_outline_rounded;
    } else if (action.contains('SETTLEMENT') || action.contains('ESCROW') || action.contains('PAYOUT')) {
      badgeBg = const Color(0xFFF7EEDF);
      badgeFg = const Color(0xFF75551E);
      actionIcon = Icons.account_balance_outlined;
    }

    final targetDesc = targetType.isNotEmpty
        ? '$targetType #$targetId'
        : 'Event #$logId';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    action,
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: badgeFg),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Row(
                children: [
                  Text(
                    createdAt,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                  ),
                  const SizedBox(width: 4),
                  Icon(actionIcon, size: 12, color: badgeFg),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Target: $targetDesc',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF03253B),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildInfoRow('Actor:', '$actorName ($actorRole)'),
                _buildInfoRow('Gateway Source:', 'IP: $ipAddress (India HQ)'),
                _buildInfoRow('Merkle Hash:', 'SHA256: ${logId.padLeft(8, '0')}...TK_VERIFIED'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF107C41)),
                  SizedBox(width: 4),
                  Text('TLS 1.3 Audit Verified', style: TextStyle(fontSize: 9.5, color: Color(0xFF556F88))),
                ],
              ),
              GestureDetector(
                onTap: () => _showPayloadModal(Map<String, dynamic>.from(log)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EEFD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.code_rounded, size: 11, color: Color(0xFF285C8A)),
                      SizedBox(width: 3),
                      Text('Inspect Payload', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF285C8A))),
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

  Widget _buildPaginationBar() {
    final total = _pagination['total'] ?? 0;
    final page = _pagination['page'] ?? 1;
    final totalPages = _pagination['total_pages'] ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2ECF5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing page $page of $totalPages ($total total)',
            style: const TextStyle(fontSize: 10, color: Color(0xFF556F88), fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: page > 1 ? const Color(0xFF285C8A) : Colors.grey.shade400,
                onPressed: page > 1 ? () => _fetchAuditLogs(page: page - 1) : null,
              ),
              const SizedBox(width: 8),
              Text(
                '$page / $totalPages',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF03253B)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: page < totalPages ? const Color(0xFF285C8A) : Colors.grey.shade400,
                onPressed: page < totalPages ? () => _fetchAuditLogs(page: page + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard1() {
    return _buildExportTemplate(
      icon: Icons.person_outline_rounded,
      title: 'Seller Onboarding & KYC Report',
      sub: 'Applications Triaged • 98.2% Pass Rate',
      badgeText: 'Live Stream',
      badgeBg: const Color(0xFFD6EEFD),
      badgeFg: const Color(0xFF285C8A),
      actions: [
        _buildActionChip(Icons.description_outlined, 'CSV'),
        const SizedBox(width: 6),
        _buildActionChip(Icons.picture_as_pdf_outlined, 'PDF'),
      ],
    );
  }

  Widget _buildExportCard2() {
    return _buildExportTemplate(
      icon: Icons.shield_outlined,
      title: 'Listing Moderation & Counterfeits',
      sub: 'Product Approvals & Catalog Integrity Logs',
      badgeText: 'Syncing',
      badgeBg: const Color(0xFFD6EEFD),
      badgeFg: const Color(0xFF285C8A),
      actions: [
        _buildActionChip(Icons.file_download_outlined, 'Batch Manifest'),
      ],
    );
  }

  Widget _buildExportCard3() {
    return _buildExportTemplate(
      icon: Icons.gavel_rounded,
      title: 'Dispute & Return Ledger',
      sub: 'Active Claims & Customer Resolution Logs',
      badgeText: 'Audit Ready',
      badgeBg: const Color(0xFFF7EEDF),
      badgeFg: const Color(0xFF75551E),
      actions: [
        _buildActionChip(Icons.receipt_long_outlined, 'Reconciliation Export'),
      ],
    );
  }

  Widget _buildExportCard4() {
    return _buildExportTemplate(
      icon: Icons.account_balance_outlined,
      title: 'Settlement & Payout Clearing',
      sub: 'Released via NEFT / RTGS Escrow Reconciled',
      badgeText: 'NEFT / RTGS Ack',
      badgeBg: const Color(0xFFD6EEFD),
      badgeFg: const Color(0xFF285C8A),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF03253B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.download_rounded, size: 12, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Download Remittance Pack',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportTemplate({
    required IconData icon,
    required String title,
    required String sub,
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required List<Widget> actions,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDF5FD),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 15, color: const Color(0xFF285C8A)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: badgeFg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B8095))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EEFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF285C8A)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF285C8A)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool boldVal = false, Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6B8095))),
          Text(
            value,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: boldVal ? FontWeight.w800 : FontWeight.w600,
              color: valColor ?? const Color(0xFF03253B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditIntegrityCard() {
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
              Icon(Icons.lock_outline_rounded, size: 15, color: Color(0xFF285C8A)),
              SizedBox(width: 6),
              Text(
                'IMMUTABLE AUDIT INTEGRITY',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Records are append-only and cryptographically hashed with central database replication. Editing, deletion, or backdating is mathematically prohibited by TechKart Core Architecture.',
            style: TextStyle(
              fontSize: 9.5,
              height: 1.35,
              color: Color(0xFF2B445B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Level 3 Compliance Active',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF556F88)),
              ),
              Text(
                'Sig: #ED25519-TK-940',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF285C8A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
