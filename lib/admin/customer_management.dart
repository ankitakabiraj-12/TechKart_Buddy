import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import 'admin_customer_service.dart';

class CustomerManagementScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const CustomerManagementScreen({super.key, this.onNavigateTab});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  // Filters: 0: All Customers, 1: Active Accounts, 2: Suspended
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replyController = TextEditingController(
    text: 'Compose secure reply with customer and seller cc\'d...',
  );

  // Pagination & Loading States
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _customers = [];
  Map<String, dynamic>? _metrics;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  // Selected customer for showcase card (defaults to index 0)
  int _selectedCustomerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String statusParam = 'all';
      if (_selectedFilter == 1) {
        statusParam = 'active';
      } else if (_selectedFilter == 2) {
        statusParam = 'inactive';
      }

      final query = _searchController.text.trim();
      final data = await AdminCustomerService.getCustomersDirectory(
        search: query.isNotEmpty ? query : null,
        status: statusParam,
        page: page,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (data != null) {
            _customers = data['customers'] as List<dynamic>? ?? [];
            _metrics = data['metrics'] as Map<String, dynamic>?;
            final pagination = data['pagination'] as Map<String, dynamic>?;
            _currentPage = pagination?['page'] ?? 1;
            _totalPages = pagination?['total_pages'] ?? 1;
            _totalCount = pagination?['total'] ?? _customers.length;
            if (_selectedCustomerIndex >= _customers.length) {
              _selectedCustomerIndex = 0;
            }
          } else {
            _errorMessage = 'Failed to load customers from server';
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
    _loadCustomers(page: 1);
  }

  Future<void> _toggleCustomerStatus(Map<String, dynamic> customer) async {
    final customerId = customer['user_id'] as int? ?? customer['id'] as int? ?? 0;
    if (customerId <= 0) return;

    final currentStatus = (customer['is_active'] ?? 1) == 1;
    final newStatus = !currentStatus;

    final res = await AdminCustomerService.updateCustomerStatus(
      customerId: customerId,
      isActive: newStatus,
    );

    if (mounted) {
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty
                ? res.message
                : (newStatus ? 'Customer activated' : 'Customer suspended')),
            backgroundColor: newStatus ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
          ),
        );
        _loadCustomers(page: _currentPage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : 'Action failed'),
            backgroundColor: Colors.red,
          ),
        );
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

            // Main Body Content
            Expanded(
              child: _isLoading && _customers.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF03253B),
                      ),
                    )
                  : _errorMessage != null && _customers.isEmpty
                      ? _buildErrorView()
                      : RefreshIndicator(
                          color: const Color(0xFF03253B),
                          onRefresh: () => _loadCustomers(page: _currentPage),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // LIVE DISPATCH Hero Card (Header Box)
                                _buildHeroDispatchCard(),

                                const SizedBox(height: 12),

                                // Search Customer Name, Email, Phone, City...
                                _buildSearchBar(),

                                const SizedBox(height: 10),

                                // Filter Pills (All Customers, Active Accounts, Suspended)
                                _buildFilterPills(),

                                const SizedBox(height: 14),

                                // Empty State if no customers found
                                if (_customers.isEmpty)
                                  _buildEmptyView()
                                else ...[
                                  // Selected Showcase Customer Card
                                  _buildShowcaseCustomerCard(),

                                  const SizedBox(height: 18),

                                  // Section Header: Active Customer Roster
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Active Customer Roster',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF03253B),
                                        ),
                                      ),
                                      Text(
                                        'Viewing ${_customers.length} of $_totalCount',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6B8095),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // List of Customer Stream Cards
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _customers.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = _customers[index];
                                      final isSelected =
                                          index == _selectedCustomerIndex;
                                      return _buildCustomerItemCard(
                                        item,
                                        index,
                                        isSelected,
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  // Pagination Controls
                                  _buildPaginationControls(),
                                ],

                                const SizedBox(height: 16),

                                // Compliance Banner: DATA COMPLIANCE & INFORMATION TECHNOLOGY ACT 2000
                                _buildComplianceCard(),

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
      title: 'Customer Directory',
      subtitle: 'Buyer Accounts & Customer Dispute Oversight',
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

  Widget _buildHeroDispatchCard() {
    final activeAgents = _metrics?['active_support_agents']?.toString() ?? '18';
    final avgSla = _metrics?['average_sla']?.toString() ?? '4.2m SLA';
    final totalSpentFmt = _metrics?['total_spent_fmt']?.toString() ?? '₹ 0.00';
    final totalCustomersCount = _metrics?['total_customers']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF05172A),
        borderRadius: BorderRadius.circular(20),
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
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF107C41),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE DISPATCH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    ' • Customer Care Desk',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'REGISTERED: $totalCustomersCount',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF81D4FA),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Two dark cards: Active Support Agents & Gross Revenue / SLA
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C243B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACTIVE\nSUPPORT\nAGENTS',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8197A9),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$activeAgents On-\nDuty',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C243B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BUYER\nLIFETIME\nVOLUME',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8197A9),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalSpentFmt,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF69F0AE),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              avgSla,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF81D4FA),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: Colors.white,
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

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF4C6A88)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadCustomers(page: 1),
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF03253B),
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Search customer name, email, phone or city...',
                hintStyle: TextStyle(
                  fontSize: 12,
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
                _loadCustomers(page: 1);
              },
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Color(0xFF4C6A88)),
            ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded,
                size: 18, color: Color(0xFF285C8A)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _loadCustomers(page: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = [
      'All Customers (${_metrics?['total_customers'] ?? _totalCount})',
      'Active (${_metrics?['active_customers'] ?? 0})',
      'Suspended',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF03253B)
                      : const Color(0xFFE4F0FC),
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

  Widget _buildShowcaseCustomerCard() {
    if (_customers.isEmpty) return const SizedBox.shrink();

    final c = _customers[_selectedCustomerIndex];
    final fullName = c['full_name']?.toString() ?? 'Customer';
    final email = c['email']?.toString() ?? 'N/A';
    final phone = c['phone']?.toString() ?? 'N/A';
    final isActive = (c['is_active'] ?? 1) == 1;
    final totalSpentFmt = c['total_spent_fmt']?.toString() ?? '₹ 0.00';
    final totalOrders = c['total_orders']?.toString() ?? '0';
    final totalReviews = c['total_reviews']?.toString() ?? '0';
    final avgRating = c['avg_review_rating']?.toString() ?? '0.0';
    final city = c['city']?.toString() ?? '';
    final state = c['state']?.toString() ?? '';
    final location = (city.isNotEmpty && state.isNotEmpty)
        ? '$city, $state'
        : (city.isNotEmpty ? city : 'India');

    final initials = fullName.isNotEmpty
        ? fullName
            .split(' ')
            .take(2)
            .map((s) => s.isNotEmpty ? s[0] : '')
            .join()
            .toUpperCase()
        : 'CU';

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
          // Header: CUSTOMER ACCOUNT #ID, SLA BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'CUSTOMER #TCK-${c['user_id']}',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFDE8E5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE BUYER' : 'SUSPENDED',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? const Color(0xFF107C41)
                            : const Color(0xFFB52E1D),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EEFD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: Color(0xFF285C8A)),
                    const SizedBox(width: 3),
                    Text(
                      '$avgRating ★ ($totalReviews reviews)',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '$fullName • Lifetime Spend $totalSpentFmt',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF03253B),
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          // User info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFF03253B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF03253B),
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF556F88),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive
                                ? Icons.shield_outlined
                                : Icons.block_outlined,
                            size: 12,
                            color: isActive
                                ? const Color(0xFF107C41)
                                : const Color(0xFFB52E1D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Verified' : 'Locked',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? const Color(0xFF107C41)
                                  : const Color(0xFFB52E1D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '📍 $location • Phone: $phone',
                    style: const TextStyle(
                        fontSize: 10.5, color: Color(0xFF556F88)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL ORDERS',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B8095)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$totalOrders Placed',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF03253B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIFETIME REVENUE',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B8095)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              totalSpentFmt,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF107C41)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action row: Status toggle, View Details
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleCustomerStatus(c),
                  child: _buildFooterBtn(
                    isActive
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_rounded,
                    isActive ? 'Suspend Account' : 'Activate Account',
                    isActive ? const Color(0xFFFDE8E5) : const Color(0xFFE8F5E9),
                    isActive ? const Color(0xFFB52E1D) : const Color(0xFF107C41),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Customer: $fullName | Orders: $totalOrders | Spent: $totalSpentFmt'),
                      ),
                    );
                  },
                  child: _buildFooterBtn(
                    Icons.history_rounded,
                    'View Order Ledger',
                    const Color(0xFFD6EEFD),
                    const Color(0xFF285C8A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerItemCard(
      Map<String, dynamic> item, int index, bool isSelected) {
    final customerId = item['user_id'] ?? item['id'] ?? 0;
    final fullName = item['full_name']?.toString() ?? 'Customer';
    final email = item['email']?.toString() ?? 'N/A';
    final phone = item['phone']?.toString() ?? 'N/A';
    final isActive = (item['is_active'] ?? 1) == 1;
    final totalSpentFmt = item['total_spent_fmt']?.toString() ?? '₹ 0.00';
    final totalOrders = item['total_orders']?.toString() ?? '0';
    final totalReviews = item['total_reviews']?.toString() ?? '0';
    final avgRating = item['avg_review_rating']?.toString() ?? '0.0';
    final city = item['city']?.toString() ?? '';
    final state = item['state']?.toString() ?? '';
    final location = (city.isNotEmpty && state.isNotEmpty)
        ? '$city, $state'
        : (city.isNotEmpty ? city : 'India');

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCustomerIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF03253B) : const Color(0xFFE2ECF5),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '#TCK-$customerId',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFDE8E5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'SUSPENDED',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? const Color(0xFF107C41)
                              : const Color(0xFFB52E1D),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  totalSpentFmt,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF107C41),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              fullName,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF03253B),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$email • $phone',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF556F88),
                    ),
                  ),
                ),
                Text(
                  '📍 $location',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF556F88),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF5FD),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          size: 11, color: Color(0xFF285C8A)),
                      const SizedBox(width: 4),
                      Text(
                        'Orders: $totalOrders placed',
                        style: const TextStyle(
                            fontSize: 9.5, color: Color(0xFF285C8A)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: Color(0xFF9E5E14)),
                      const SizedBox(width: 3),
                      Text(
                        '$avgRating ★ ($totalReviews rev)',
                        style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E5E14)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                ? () => _loadCustomers(page: _currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 16),
            label: const Text('Previous', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCFD8DC),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
                ? () => _loadCustomers(page: _currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 16),
            label: const Text('Next', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCFD8DC),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBtn(IconData icon, String label, Color bg, Color fg) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w700, color: fg),
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
          const Icon(Icons.people_outline_rounded,
              size: 48, color: Color(0xFF90A4AE)),
          const SizedBox(height: 12),
          const Text(
            'No Customers Found',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF03253B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No customer records match your filter or search query.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Color(0xFF556F88)),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _onFilterSelected(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Clear Filters & Search',
                style: TextStyle(fontSize: 12)),
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
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Color(0xFFB52E1D)),
            const SizedBox(height: 12),
            const Text(
              'Failed to Load Customer Directory',
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
              onPressed: () => _loadCustomers(page: _currentPage),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03253B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceCard() {
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
                'DATA COMPLIANCE & INFORMATION\nTECHNOLOGY ACT 2000',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Customer phone numbers and payment instrument identifiers are masked. Voice interactions and chat transcripts are immutably archived for 180 days for audit readiness and dispute arbitration.',
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
}
