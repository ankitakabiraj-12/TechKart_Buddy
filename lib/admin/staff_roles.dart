import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';

class StaffRolesScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const StaffRolesScreen({super.key, this.onNavigateTab});

  @override
  State<StaffRolesScreen> createState() => _StaffRolesScreenState();
}

class _StaffRolesScreenState extends State<StaffRolesScreen> {
  int _selectedFilter = 0; // 0: All Staff (34), 1: SuperAdmin (2), 2: Compliance Desk (12), 3: Finance

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
                    // RBAC • ISO-27001 COMPLIANT Banner
                    _buildComplianceHeaderBanner(),

                    const SizedBox(height: 14),

                    // Title & Subtitle
                    const Text(
                      'Staff Roles & Permissions',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Granular authorization policy and access control audit directory',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        color: Color(0xFF556F88),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // + Invite Staff Member Button
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03253B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_1_outlined, size: 16),
                            SizedBox(width: 8),
                            Text(
                              '+ Invite Staff Member',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2x2 Metric Cards Grid
                    _buildMetricsGrid(),

                    const SizedBox(height: 14),

                    // Search Staff Bar
                    _buildSearchBar(),

                    const SizedBox(height: 10),

                    // Filter Pills
                    _buildFilterPills(),

                    const SizedBox(height: 14),

                    // Staff Card 1: Operations Lead (SuperAdmin / Lead Ops)
                    _buildStaffCard1(),

                    const SizedBox(height: 12),

                    // Staff Card 2: Compliance Officer (Compliance Officer L2)
                    _buildStaffCard2(),

                    const SizedBox(height: 12),

                    // Staff Card 3: Finance Lead (Finance Officer L3)
                    _buildStaffCard3(),

                    const SizedBox(height: 12),

                    // Staff Card 4: Dispute Lead (Dispute Resolution Lead)
                    _buildStaffCard4(),

                    const SizedBox(height: 12),

                    // Pending Onboarding Card: S. K. Mahbub
                    _buildPendingOnboardingCard(),

                    const SizedBox(height: 18),

                    // RBAC Capability Matrix
                    _buildRbacMatrix(),

                    const SizedBox(height: 20),
                  ],
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
      title: 'Staff Roles & Access',
      subtitle: 'Internal RBAC Directory & Clearance',
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

  Widget _buildComplianceHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EEDF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF75551E)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RBAC • ISO-27001 COMPLIANT',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Dual-Key Auth',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF75551E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Security & Principle of Least Privilege: Information Technology Act 2000. Self-elevation disabled; role escalation requires 2-Person dual sign-off.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    color: Color(0xFF4C647C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Active Staff',
                value: '34',
                sub: 'Verified',
                icon: Icons.people_outline_rounded,
                progressColor: const Color(0xFF03253B),
                progressValue: 0.85,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Pending Invites',
                value: '3',
                sub: 'Awaiting accept',
                icon: Icons.mark_email_unread_outlined,
                progressColor: const Color(0xFF75551E),
                progressValue: 0.35,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'SuperAdmins',
                value: '2',
                sub: 'Dual Signers',
                icon: Icons.vpn_key_outlined,
                footerText: 'Root Key Vault',
                hasDot: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Hardware MFA',
                value: '100%',
                sub: 'Enforced',
                icon: Icons.shield_outlined,
                progressColor: const Color(0xFF03253B),
                progressValue: 1.0,
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
    double? progressValue,
    Color? progressColor,
    String? footerText,
    bool hasDot = false,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF556F88),
                ),
              ),
              Icon(icon, size: 14, color: const Color(0xFF285C8A)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF6B8095),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (progressValue != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 3,
                backgroundColor: const Color(0xFFE2ECF5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? const Color(0xFF03253B),
                ),
              ),
            ),
          if (footerText != null)
            Row(
              children: [
                if (hasDot) ...[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF285C8A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  footerText,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF556F88),
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
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: Color(0xFF4C6A88)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search by name, email, or employee ID...',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF5A7591),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['All Staff (34)', 'SuperAdmin (2)', 'Compliance Desk (12)', 'Finance'];
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

  Widget _buildStaffCard1() {
    return _buildStaffTemplate(
      initials: 'AR',
      name: 'Alex Rahm...',
      tag: 'TK-001',
      tagBg: const Color(0xFFF7EEDF),
      tagFg: const Color(0xFF75551E),
      mfaText: 'FIDO2 Hardware MFA',
      mfaIcon: Icons.security_rounded,
      email: 'alex.r@techkart.internal',
      scopes:
          'Full Marketplace Authority, Dual Signer Root Vault, DB Read/Write, Staff Escalation Privilege.',
      roleBadgeIcon: Icons.lock_outline_rounded,
      roleBadgeText: 'SuperAdmin / Lead Ops',
      isOnline: true,
    );
  }

  Widget _buildStaffCard2() {
    return _buildStaffTemplate(
      initials: 'NJ',
      name: 'Compliance Officer',
      tag: 'TK-042',
      tagBg: const Color(0xFFF7EEDF),
      tagFg: const Color(0xFF75551E),
      mfaText: 'Authenticator MFA',
      mfaIcon: Icons.phone_android_rounded,
      email: 'nusrat.j@techkart.internal',
      scopes:
          'Merchant Trade License Verification, Escrow Freeze Flagging, National ID KYC Validation.',
      policySubtext: 'Policy: No self-escalation authority',
      roleBadgeText: 'Compliance Officer L2',
      isOnline: true,
    );
  }

  Widget _buildStaffCard3() {
    return _buildStaffTemplate(
      initials: 'TH',
      name: 'Tanvir Has...',
      tag: 'TK-018',
      tagBg: const Color(0xFFF7EEDF),
      tagFg: const Color(0xFF75551E),
      mfaText: 'FIDO2 Hardware MFA',
      mfaIcon: Icons.security_rounded,
      email: 'tanvir.h@techkart.internal',
      scopes:
          'NEFT / RTGS / RTGS Bulk Batching, Merchant Payout Arbitration, Escrow Release Sign-off. Read-only for Catalog & Staff.',
      roleBadgeText: 'Finance Officer (L3)',
      isOnline: true,
    );
  }

  Widget _buildStaffCard4() {
    return _buildStaffTemplate(
      initials: 'FA',
      name: 'Dispute Lead',
      tag: 'TK-112',
      tagBg: const Color(0xFFF7EEDF),
      tagFg: const Color(0xFF75551E),
      mfaText: 'Authenticator MFA',
      mfaIcon: Icons.phone_android_rounded,
      email: 'farzana.a@techkart.internal',
      scopes:
          'Buyer Dispute Triage, Return Processing, Instant Refund Discretion (capped at ₹ 10,000 threshold).',
      roleBadgeText: 'Dispute Resolution Lead',
      isOnline: true,
    );
  }

  Widget _buildStaffTemplate({
    required String initials,
    required String name,
    required String tag,
    required Color tagBg,
    required Color tagFg,
    required String mfaText,
    required IconData mfaIcon,
    required String email,
    required String scopes,
    String? policySubtext,
    IconData? roleBadgeIcon,
    required String roleBadgeText,
    required bool isOnline,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                  Stack(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6EEFD),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF285C8A),
                            ),
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF107C41),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: tagBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: tagFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EEFD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mfaIcon, size: 10, color: const Color(0xFF285C8A)),
                    const SizedBox(width: 3),
                    Text(
                      mfaText,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // AUTHORIZED SCOPES
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield_outlined, size: 12, color: Color(0xFF285C8A)),
                    SizedBox(width: 4),
                    Text(
                      'AUTHORIZED SCOPES',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF285C8A),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  scopes,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF03253B),
                  ),
                ),
                if (policySubtext != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    policySubtext,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF556F88),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Footer row: role label & Edit Scopes + Id Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (roleBadgeIcon != null) ...[
                    Icon(roleBadgeIcon, size: 11, color: const Color(0xFF556F88)),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    roleBadgeText,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF556F88)),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EEFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Edit Scopes',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF285C8A)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF5FD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF285C8A)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOnboardingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EEDF),
        borderRadius: BorderRadius.circular(16),
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
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'SM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF75551E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'S. K. Mahbub',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECE4D2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Invited',
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF75551E)),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'mahbub.ops@techkart.internal',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 10, color: Color(0xFF75551E)),
                    SizedBox(width: 3),
                    Text(
                      'Token: 21h left',
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF75551E)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 10.5, color: Color(0xFF3B4F60)),
              children: [
                TextSpan(text: 'Proposed Role: '),
                TextSpan(
                  text: 'Logistics Hub Coordinator. ',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF03253B)),
                ),
                TextSpan(text: 'Invitation dispatched 2h ago by Lead Ops.'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending Onboarding',
                style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF03253B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Resend',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Revoke',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB52E1D)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRbacMatrix() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 14, color: Color(0xFF285C8A)),
                    SizedBox(width: 6),
                    Text(
                      'RBAC Capability Matrix',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF03253B),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Updated 3h ago',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFFEDF5FD),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Privilege / Action',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF556F88)),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'SuperAdmin',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF556F88)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Compliance',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF556F88)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          _buildMatrixRow(Icons.badge_outlined, 'Seller KYC Approval', true, true),
          _buildMatrixRow(Icons.block_rounded, 'Catalog Delisting', true, true),
          _buildMatrixRow(Icons.account_balance_wallet_outlined, 'Escrow Release', true, false),
          _buildMatrixRow(Icons.sync_rounded, 'Refund Issuance', true, false),
          _buildMatrixRow(Icons.people_outline_rounded, 'Staff Management', true, false),
          _buildMatrixRow(Icons.history_rounded, 'Audit Log Export', true, true, isLast: true),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(IconData icon, String title, bool superAdmin, bool compliance, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE2ECF5), width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Icon(icon, size: 13, color: const Color(0xFF285C8A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF03253B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: superAdmin
                  ? const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF107C41))
                  : const Text('—', style: TextStyle(color: Color(0xFF90A4AE))),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: compliance
                  ? const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF107C41))
                  : const Text('—', style: TextStyle(color: Color(0xFF90A4AE))),
            ),
          ),
        ],
      ),
    );
  }
}
