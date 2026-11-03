import 'package:flutter/material.dart';
import 'admin_logout.dart';
import 'admin_top_bar.dart';

class AdminProfileScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const AdminProfileScreen({super.key, this.onNavigateTab});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  int _selectedAlertFilter = 0; // 0: All (8), 1: Security (3), 2: SLA Breaches (3), 3: System

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Administrator Profile Card (Hero)
                    _buildProfileHeroCard(),

                    const SizedBox(height: 16),

                    // Section: Administrative Alerts
                    _buildAdministrativeAlertsHeader(),

                    const SizedBox(height: 10),

                    // Alert Filter Pills
                    _buildAlertFilterPills(),

                    const SizedBox(height: 12),

                    // Alert Item 1: Counterfeit Escalation
                    _buildAlertCard(
                      icon: Icons.warning_amber_rounded,
                      iconBg: const Color(0xFFFDE8E5),
                      iconColor: const Color(0xFFB52E1D),
                      tag: 'ACTION REQUIRED',
                      tagColor: const Color(0xFFB52E1D),
                      time: '4m ago',
                      title: 'Counterfeit Escalation: #TK...',
                      subtitle: 'ElectroNex BD flagged for -84%...',
                    ),

                    const SizedBox(height: 10),

                    // Alert Item 2: NEFT / RTGS Batch #STL-1031 Sig...
                    _buildAlertCard(
                      icon: Icons.hourglass_bottom_rounded,
                      iconBg: const Color(0xFFF7EEDF),
                      iconColor: const Color(0xFF75571E),
                      tag: '2H REMAINING',
                      tagColor: const Color(0xFF75571E),
                      time: '22m ago',
                      title: 'NEFT / RTGS Batch #STL-1031 Sig...',
                      subtitle: 'Awaiting secondary cryptographi...',
                    ),

                    const SizedBox(height: 10),

                    // Alert Item 3: Hardware Key Attestation
                    _buildAlertCard(
                      icon: Icons.vpn_key_outlined,
                      iconBg: const Color(0xFFD6EEFD),
                      iconColor: const Color(0xFF285C8A),
                      tag: 'LOGGED',
                      tagColor: const Color(0xFF285C8A),
                      time: '1h ago',
                      title: 'Hardware Key Attestation',
                      subtitle: 'Verified on terminal node node-...',
                    ),

                    const SizedBox(height: 10),

                    // Manage notification channels Banner
                    _buildNotificationChannelsBanner(),

                    const SizedBox(height: 16),

                    // Section: Security & Access Profile Card
                    _buildSecurityAccessProfileCard(),

                    const SizedBox(height: 16),

                    // Section: Active Operator Sessions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.devices_outlined, size: 18, color: Color(0xFF285C8A)),
                            SizedBox(width: 8),
                            Text(
                              'Active Operator\nSessions',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF03253B),
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '2 Active\nTerminals',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 10,
                            color: Color(0xFF556F88),
                            height: 1.15,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Session Device 1: iPhone 15 Pro
                    _buildSessionDevice1(),

                    const SizedBox(height: 10),

                    // Session Device 2: MacBook Pro M3 Max
                    _buildSessionDevice2(),

                    const SizedBox(height: 16),

                    // Terminate Operator Session Button (Red pill)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLogoutScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDE8E5),
                          foregroundColor: const Color(0xFFB52E1D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.power_settings_new_rounded, size: 18, color: Color(0xFFB52E1D)),
                            SizedBox(width: 8),
                            Text(
                              'Terminate Operator Session',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB52E1D),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFB52E1D)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sign Out Ledger Notice Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF5FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.lock_clock_outlined, size: 15, color: Color(0xFF285C8A)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sign out clears client keystore, revokes temporary JWT access tokens, and emits a cryptographic SESSION_TERMINATED record to the Merkle audit trail.',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 9.5,
                                color: Color(0xFF556F88),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Top App Bar ---
  Widget _buildAppBar(BuildContext context) {
    return AdminTopBar(
      title: 'Settings & Profile',
      subtitle: 'Operator Security & Terminals',
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(0);
        }
      },
      showProfile: false,
    );
  }

  // --- Administrator Profile Hero Card ---
  Widget _buildProfileHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03253B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with subtle blue outline
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD6EEFD), width: 2),
                      color: const Color(0xFFEDF5FD),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFF1E3A5F),
                        child: const Icon(Icons.person, size: 40, color: Colors.white70),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF285C8A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.vpn_key_rounded, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administrator',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF03253B),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF5FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF285C8A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EEFD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'TK-001',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF285C8A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'op-8924@techkart.internal',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 10.5,
                        color: Color(0xFF556F88),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF285C8A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Expanded(
                          child: Text(
                            'FIDO2 YUBIKEY 5C NFC ACTIVE',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF285C8A),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // SuperAdmin / Lead Ops pill box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xFF285C8A)),
                    SizedBox(width: 8),
                    Text(
                      'SuperAdmin / Lead\nOps',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EEFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Dual-Signer Root\nVault',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF285C8A),
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Clearance Level 3
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 15, color: Color(0xFF556F88)),
                    SizedBox(width: 8),
                    Text(
                      'Clearance Level 3',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF03253B),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Cyber Act 2023 • ISO-27001',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF556F88)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Role modifications require dual-officer notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EEDF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF6B4826)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Role modifications require dual-officer consensus via ADM-14; self-elevation disabled.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 9.5,
                      color: Color(0xFF5D4732),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Administrative Alerts Header ---
  Widget _buildAdministrativeAlertsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.notifications_active_outlined, size: 18, color: Color(0xFF285C8A)),
            SizedBox(width: 8),
            Text(
              'Administrative Alerts',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF03253B),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Mark all read',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF285C8A),
            ),
          ),
        ),
      ],
    );
  }

  // --- Alert Filter Pills ---
  Widget _buildAlertFilterPills() {
    final filters = ['All (8)', 'Security (3)', 'SLA Breaches (3)', 'System'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedAlertFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedAlertFilter = index;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4C5D7D) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected ? null : Border.all(color: const Color(0xFFD6EEFD), width: 1),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF556F88),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- Alert Card ---
  Widget _buildAlertCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String tag,
    required Color tagColor,
    required String time,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: tagColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF7A8E9F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF556F88),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF6B8095)),
        ],
      ),
    );
  }

  // --- Manage Notification Channels Banner ---
  Widget _buildNotificationChannelsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(Icons.cell_tower_rounded, size: 16, color: Color(0xFF285C8A)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Manage notification channels (SMS, Signal,\nWebhook)',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
                color: Color(0xFF556F88),
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Icon(Icons.tune_rounded, size: 16, color: Color(0xFF285C8A)),
        ],
      ),
    );
  }

  // --- Section: Security & Access Profile Card ---
  Widget _buildSecurityAccessProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.fingerprint_rounded, size: 18, color: Color(0xFF285C8A)),
              SizedBox(width: 8),
              Text(
                'Security & Access Profile',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Multi-Factor Authentication
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Multi-Factor Authentication',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hardware Key (Primary) + TOTP (Secondary)',
                      style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF285C8A)),
            ],
          ),

          const Divider(height: 18, color: Color(0xFFE2ECF5)),

          // Session Auto-Lock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Session Auto-Lock',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Enforced after 15 minutes idle time',
                    style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EEFD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '15 min',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285C8A),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 18, color: Color(0xFFE2ECF5)),

          // IP Whitelist & VPN Shield
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'IP Whitelist & VPN Shield',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mumbai HQ Gateway (103.114.98.0/24)',
                    style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EEFD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Restricted',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285C8A),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 18, color: Color(0xFFE2ECF5)),

          // Cryptographic Signer Certificate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Cryptographic Signer Certificate',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'RSA-4096 / SHA-256 • Exp: Oct 2026',
                    style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                  ),
                ],
              ),
              const Text(
                'Valid',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10.5,
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

  // --- Session Device 1: iPhone 15 Pro ---
  Widget _buildSessionDevice1() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD6EEFD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.phone_iphone_rounded, color: Color(0xFF285C8A), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'iPhone 15 Pro • iOS 17.5',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C5D7D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'THIS DEVICE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'TechKart Admin App • Node DHK-04',
                  style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Active now • Merkle Ledger synchronized',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 9.5,
                    color: Color(0xFF556F88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Session Device 2: MacBook Pro M3 Max ---
  Widget _buildSessionDevice2() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD6EEFD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.laptop_mac_rounded, color: Color(0xFF285C8A), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MacBook Pro M3 Max',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session revoked for MacBook Pro M3 Max')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF5FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Revoke',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB52E1D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Chrome 129 • TLS 1.3 VPN (Mumbai Ops Room)',
                  style: TextStyle(fontSize: 10, color: Color(0xFF556F88)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Last active 18m ago',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 9.5,
                    color: Color(0xFF556F88),
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
