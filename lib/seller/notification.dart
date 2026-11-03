import 'package:flutter/material.dart';
import 'seller_top_bar.dart';
import 'orders_details.dart';
import 'earnings.dart';
import 'inventory_management.dart';
import 'seller_profile_service.dart';
import 'product_service.dart';

class SellerNotificationScreen extends StatefulWidget {
  final bool isStandaloneScreen;
  const SellerNotificationScreen({super.key, this.isStandaloneScreen = false});

  @override
  State<SellerNotificationScreen> createState() => _SellerNotificationScreenState();
}

class _SellerNotificationScreenState extends State<SellerNotificationScreen> {
  bool _isOnline = true;
  int _activeTab = 0; // 0: Notifications, 1: Settings
  Map<String, dynamic>? _liveProfile;
  List<dynamic> _liveAlerts = [];
  int _unreadAlertsCount = 0;
  bool _isLoadingAlerts = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAlerts();
  }

  Future<void> _loadProfile() async {
    final profile = await SellerProfileService.getProfile();
    if (mounted) {
      setState(() {
        _liveProfile = profile;
      });
    }
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoadingAlerts = true);
    try {
      final res = await ProductService.getInventoryAlerts(status: 'all');
      if (mounted) {
        setState(() => _isLoadingAlerts = false);
        if (res.isSuccess && res.data != null) {
          final data = res.data as Map<String, dynamic>;
          final alertsList = (data['alerts'] as List<dynamic>?) ?? [];
          final metrics = (data['metrics'] as Map<String, dynamic>?) ?? {};
          setState(() {
            _liveAlerts = alertsList;
            _unreadAlertsCount = (metrics['unread_count'] as num?)?.toInt() ?? 0;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAlerts = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      final res = await ProductService.markAllAlertsRead();
      if (res.isSuccess) {
        setState(() {
          for (var a in _liveAlerts) {
            if (a is Map<String, dynamic>) {
              a['is_read'] = true;
            }
          }
          _unreadAlertsCount = 0;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All alerts marked as read.'),
              backgroundColor: Color(0xFF072138),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _markSingleRead(int alertId) async {
    try {
      await ProductService.markAlertRead(alertId);
      setState(() {
        final match = _liveAlerts.firstWhere((it) => it['id'] == alertId, orElse: () => null);
        if (match != null && match['is_read'] == false) {
          match['is_read'] = true;
          if (_unreadAlertsCount > 0) _unreadAlertsCount--;
        }
      });
    } catch (_) {}
  }

  void _showEditProfileDialog() {
    final user = _liveProfile?['user'] as Map<String, dynamic>?;
    final store = _liveProfile?['store'] as Map<String, dynamic>?;

    final nameController = TextEditingController(text: user?['full_name'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');
    final storeController = TextEditingController(text: store?['store_name'] ?? (user?['full_name'] != null ? "${user!['full_name']}'s Store" : 'My Store'));
    final gstController = TextEditingController(text: store?['gst_number'] ?? '');
    final addressController = TextEditingController(text: store?['address'] ?? '');
    final cityController = TextEditingController(text: store?['city'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manage Store & Profile',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storeController,
                decoration: InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Contact Person / Owner',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gstController,
                decoration: InputDecoration(
                  labelText: 'GST / Trade License',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Store Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updating store profile...')),
                    );
                    final res = await SellerProfileService.updateProfile(
                      fullName: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      storeName: storeController.text.trim(),
                      gstNumber: gstController.text.trim(),
                      address: addressController.text.trim(),
                      city: cityController.text.trim(),
                    );
                    if (res.isSuccess) {
                      await _loadProfile();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Store profile updated successfully!'),
                            backgroundColor: Color(0xFF1E4B75),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.message.isNotEmpty ? res.message : 'Update failed'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF072B44),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header (Metro Hub selector, notifications, avatar)
          if (!widget.isStandaloneScreen) _buildTopHeader(context),
          // Your Store Profile Profile Hero Card
          _buildProfileHeroCard(),
          const SizedBox(height: 12),
          // Notifications (4) & Settings toggle pill buttons
          _buildNotificationSettingsToggle(),
          const SizedBox(height: 14),
          // URGENT ACTIVITY Header & Mark all as read
          _buildUrgentActivityHeader(),
          const SizedBox(height: 10),

          // Live Low-Stock & Inventory Alerts from MariaDB
          if (_isLoadingAlerts) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          ] else if (_liveAlerts.isNotEmpty) ...[
            for (final alert in _liveAlerts) ...[
              _buildLiveAlertCard(alert),
              const SizedBox(height: 12),
            ],
          ] else ...[
            // Notification 2: Low Stock Warning (Fallback if no alert exists)
            _buildNotificationCard(
              icon: Icons.inventory_2_outlined,
              iconBg: const Color(0xFFFFEEEE),
              iconColor: const Color(0xFFD32F2F),
              title: 'Low Stock Warning',
              time: 'Live',
              body: 'All inventory is currently healthy and above replenishment threshold.',
              actionLabel: 'View Inventory',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryManagement(isStandaloneScreen: true),
                  ),
                );
              },
              isPrimaryButton: false,
            ),
            const SizedBox(height: 12),
          ],

          // Notification 1: Express Packing Alert (#TK-88491)
          _buildNotificationCard(
            icon: Icons.local_shipping_outlined,
            iconBg: const Color(0xFFE3F0FB),
            iconColor: const Color(0xFF1E4B75),
            title: 'Express Packing Alert',
            time: '5m ago',
            body:
                'New express order #TK-88491 requires packing before 04:00 PM today.',
            actionLabel: 'View Order',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersDetails(isStandaloneScreen: true),
                ),
              );
            },
            isPrimaryButton: true,
          ),
          const SizedBox(height: 12),
          // Notification 3: Weekly Payout Initiated (₹ 384,920)
          _buildNotificationCard(
            icon: Icons.account_balance_outlined,
            iconBg: const Color(0xFFE8F2FD),
            iconColor: const Color(0xFF1E4B75),
            title: 'Weekly Payout Initiated',
            time: '3h ago',
            body:
                'Weekly settlement of ₹ 384,920 initiated to your registered bank •••• 4092.',
            actionLabel: 'View Settlement',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Earnings(isStandaloneScreen: true),
                ),
              );
            },
            isPrimaryButton: false,
          ),
          const SizedBox(height: 12),
          // Notification 4: E-Commerce Guideline 2024
          _buildNotificationCard(
            icon: Icons.verified_user_outlined,
            iconBg: const Color(0xFFE3F0FB),
            iconColor: const Color(0xFF1E4B75),
            title: 'E-Commerce Guideline 2024',
            time: 'Yesterday',
            body:
                'India National E-Commerce tax compliance reminder. Confirm valid e-TIN upload by end of month.',
            actionLabel: 'Review Mandate',
            onAction: () {},
            isPrimaryButton: false,
          ),
          const SizedBox(height: 36),
        ],
      ),
    );

    if (widget.isStandaloneScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        appBar: const SellerTopBar(
          title: 'Notifications & Alerts',
        ),
        body: SafeArea(child: content),
      );
    }

    return SafeArea(child: content);
  }

  Widget _buildTopHeader(BuildContext context) {
    return const SellerTopBar(
      title: 'Account',
      subtitle: 'Metro Hub',
      showNotification: true,
      showProfile: true,
    );
  }

  // ── LIVE STORE PROFILE HERO CARD ──
  Widget _buildProfileHeroCard() {
    final store = _liveProfile?['store'] as Map<String, dynamic>?;
    final user = _liveProfile?['user'] as Map<String, dynamic>?;
    final stats = _liveProfile?['stats'] as Map<String, dynamic>?;

    final storeName = store?['store_name'] ?? (user?['full_name'] != null ? "${user!['full_name']}'s Store" : 'My Store');
    final isVerified = (store?['is_verified'] == 1 || store?['is_verified'] == true);
    final initials = storeName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();
    final initialsStr = initials.isEmpty ? 'ST' : initials;
    final storeCode = store?['id'] != null ? 'TK-STORE-${store!['id']} • Verified Partner' : 'TK-STORE • Active';
    final rating = stats?['rating'] != null ? '${stats!['rating']} ☆' : 'New Seller';
    final sla = stats?['sla_compliance']?.toString() ?? '100%';
    final cancel = stats?['cancellation_rate']?.toString() ?? '0.0%';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDFECF7), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF072B44),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initialsStr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name, Verified badge, Store code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF072138),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isVerified ? const Color(0xFFE8F3FD) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isVerified ? Icons.verified : Icons.hourglass_top_rounded,
                                size: 11,
                                color: isVerified ? const Color(0xFF1E4B75) : const Color(0xFFE65100),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isVerified ? 'Verified' : 'Pending KYC',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isVerified ? const Color(0xFF1E4B75) : const Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      storeCode,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF5A6B7C)),
                    ),
                  ],
                ),
              ),
              // Edit Profile Button & Online toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF072138),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 24,
                        width: 44,
                        child: Switch(
                          value: _isOnline,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF4C5D80),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFCCDFF0),
                          onChanged: (val) => setState(() => _isOnline = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  InkWell(
                    onTap: _showEditProfileDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_note_rounded, size: 13, color: Color(0xFF1E4B75)),
                          SizedBox(width: 3),
                          Text(
                            'Edit Store',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1E4B75)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Metric Pills: Store Rating, SLA Compliance, Cancellation
          Row(
            children: [
              Expanded(
                child: _buildProfileStatPill(
                  value: rating,
                  label: 'Store Rating',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProfileStatPill(
                  value: sla,
                  label: 'SLA Compliance',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProfileStatPill(
                  value: cancel,
                  label: 'Cancellation',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatPill({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF072138),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF5A6B7C)),
          ),
        ],
      ),
    );
  }

  // ── NOTIFICATIONS & SETTINGS TOGGLE ──
  Widget _buildNotificationSettingsToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF5FD),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            // Notifications (4)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _activeTab == 0 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _activeTab == 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 19,
                        color: _activeTab == 0 ? const Color(0xFF072138) : const Color(0xFF5A6B7C),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _activeTab == 0 ? FontWeight.w800 : FontWeight.w600,
                          color: _activeTab == 0 ? const Color(0xFF072138) : const Color(0xFF5A6B7C),
                        ),
                      ),
                      if (_unreadAlertsCount > 0) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD32F2F),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_unreadAlertsCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Settings
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _activeTab == 1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _activeTab == 1
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 19,
                        color: _activeTab == 1 ? const Color(0xFF072138) : const Color(0xFF5A6B7C),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _activeTab == 1 ? FontWeight.w800 : FontWeight.w600,
                          color: _activeTab == 1 ? const Color(0xFF072138) : const Color(0xFF5A6B7C),
                        ),
                      ),
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

  // ── URGENT ACTIVITY HEADER ──
  Widget _buildUrgentActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'URGENT ACTIVITY & LOW-STOCK ALERTS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5A6B7C),
              letterSpacing: 0.5,
            ),
          ),
          InkWell(
            onTap: _markAllRead,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: const Text(
                'Mark all as read',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E4B75),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── NOTIFICATION CARD BUILDER ──
  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    required String body,
    required String actionLabel,
    required VoidCallback onAction,
    required bool isPrimaryButton,
  }) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF072138),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF7A8FA3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4C5D70),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action Button aligned to the right
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 32,
              child: isPrimaryButton
                  ? ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF072B44),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F2FD),
                        foregroundColor: const Color(0xFF072138),
                        side: const BorderSide(color: Color(0xFFC7DDF2), width: 0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAlertCard(Map<String, dynamic> alert) {
    final alertId = (alert['id'] as num?)?.toInt() ?? 0;
    final title = alert['title'] as String? ?? 'Low Stock Warning';
    final body = alert['message'] as String? ?? 'Product reached threshold.';
    final isRead = alert['is_read'] == true;
    final isCritical = alert['severity'] == 'critical';
    final currentStock = (alert['current_stock'] as num?)?.toInt() ?? 0;
    final threshold = (alert['threshold'] as num?)?.toInt() ?? 5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical 
              ? (isRead ? const Color(0xFFFFD5D5) : const Color(0xFFFF8A8A))
              : (isRead ? const Color(0xFFDFECF7) : const Color(0xFFFFC08A)),
          width: isRead ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCritical ? const Color(0xFFFFE5E5) : const Color(0xFFFFF2E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCritical ? Icons.warning_rounded : Icons.inventory_2_outlined,
                  size: 19,
                  color: isCritical ? const Color(0xFFD32F2F) : const Color(0xFFE65100),
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
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
                              color: const Color(0xFF072138),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD32F2F),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Stock: $currentStock left · Threshold: $threshold',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isCritical ? const Color(0xFFC62828) : const Color(0xFFEF6C00),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4C5D70),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isRead)
                TextButton(
                  onPressed: () => _markSingleRead(alertId),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Mark as read',
                    style: TextStyle(fontSize: 11, color: Color(0xFF5A6B7C)),
                  ),
                )
              else
                const SizedBox.shrink(),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: () {
                    if (!isRead) _markSingleRead(alertId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryManagement(isStandaloneScreen: true),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F2FD),
                    foregroundColor: const Color(0xFF072138),
                    side: const BorderSide(color: Color(0xFFC7DDF2), width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Restock Now',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
