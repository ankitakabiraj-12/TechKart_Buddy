import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';

class SellerApplicationsDetailsScreen extends StatefulWidget {
  const SellerApplicationsDetailsScreen({super.key});

  @override
  State<SellerApplicationsDetailsScreen> createState() =>
      _SellerApplicationsDetailsScreenState();
}

class _SellerApplicationsDetailsScreenState
    extends State<SellerApplicationsDetailsScreen> {
  int _selectedTab = 0;
  bool _signoff1 = true;
  bool _signoff2 = true;
  bool _signoff3 = false;
  final TextEditingController _noteController = TextEditingController(
    text: 'Document numbers cross-matched with official city registry...',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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

            // Content ScrollView
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Status & Meta
                    _buildHeaderMeta(),

                    const SizedBox(height: 10),

                    // Title & Risk Rating
                    _buildTitleAndRisk(),

                    const SizedBox(height: 14),

                    // Pill Tabs Row
                    _buildPillTabs(),

                    const SizedBox(height: 14),

                    // Section: Legal Entity Profile Card
                    _buildLegalEntityProfile(),

                    const SizedBox(height: 18),

                    // Section: Automated KYC Gateways
                    _buildKycGatewaysHeader(),
                    const SizedBox(height: 10),
                    _buildKycCard1(),
                    const SizedBox(height: 10),
                    _buildKycCard2(),
                    const SizedBox(height: 10),
                    _buildKycCard3(),
                    const SizedBox(height: 10),
                    _buildKycCard4(),

                    const SizedBox(height: 18),

                    // Section: Compliance Dossier
                    _buildDossierHeader(),
                    const SizedBox(height: 10),
                    _buildDossierCard1(),
                    const SizedBox(height: 10),
                    _buildDossierCard2(),
                    const SizedBox(height: 10),
                    _buildDossierCard3(),
                    const SizedBox(height: 10),
                    _buildDossierCard4(),

                    const SizedBox(height: 18),

                    // Section: Reviewer Audit Thread
                    _buildReviewerAuditThread(),

                    const SizedBox(height: 14),

                    // Mandatory Pre-decision Sign-off Card
                    _buildPreDecisionSignoff(),

                    const SizedBox(height: 12),

                    // Auditor Session ID
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 12,
                            color: Color(0xFF6B8095),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Auditor Session ID: OP-891-DAC-24 • Logged to Central TechKart Ledger',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF6B8095),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AdminTopBar(
      title: 'Application Details',
      subtitle: 'KYC & Verification Sign-off',
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
        );
      },
    );
  }

  Widget _buildHeaderMeta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: const [
            Text(
              'TKB-2024-89241',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3245),
              ),
            ),
            SizedBox(width: 8),
            Text('•', style: TextStyle(color: Color(0xFF7A8D9F))),
            SizedBox(width: 8),
            Text(
              'Submitted 22h ago',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF5A6E82),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFDE8E5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 12,
                color: Color(0xFFB33020),
              ),
              SizedBox(width: 4),
              Text(
                '1h 38m left (Urgent SLA)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB33020),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndRisk() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Merchant Applicant',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(
                    Icons.storefront_outlined,
                    size: 13,
                    color: Color(0xFF4C6A88),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Mumbai Zone A • Computer & Gaming Hardware',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        color: Color(0xFF435A70),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD6EEFD),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RISK RATING',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A597E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF107C41),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Low',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              const Text(
                '(14/100)',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF204565),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillTabs() {
    final tabs = ['Overview & Docs', 'Verification Checks (4)', 'Audit Trail'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTab == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = entry.key;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF455879)
                      : const Color(0xFFD8ECFD),
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

  Widget _buildLegalEntityProfile() {
    return Container(
      width: double.infinity,
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
                children: const [
                  Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: Color(0xFF285C8A),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Legal Entity Profile',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4ECE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Partnership',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF75551E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // REGISTERED LEGAL NAME
          _buildInfoField(
            label: 'REGISTERED LEGAL NAME',
            value: 'Applicant Entity',
            isBold: true,
          ),
          const SizedBox(height: 8),

          // BIN / VAT REG & DSCC ZONE
          Row(
            children: [
              Expanded(
                child: _buildInfoField(
                  label: 'BIN / VAT REG',
                  value: '002941049-0102',
                  isBold: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoField(
                  label: 'DSCC ZONE',
                  value: 'Zone 01 (Elephant Rd)',
                  isBold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // REGISTERED COMMERCIAL ADDRESS
          _buildInfoField(
            label: 'REGISTERED COMMERCIAL ADDRESS',
            value:
                'Suite 402, Level 4, Multiplan Center, 69-71 New Elephant Road, Mumbai-1205',
            isBold: true,
          ),
          const SizedBox(height: 8),

          // PRIMARY SIGNATORY
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'PRIMARY SIGNATORY',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF556F88),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 11,
                          color: Color(0xFF2A5E8A),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'OTP Authenticated',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A5E8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      color: Color(0xFF03253B),
                    ),
                    children: [
                      TextSpan(
                        text: 'Md. Al-Amin ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: '(Managing Partner)',
                        style: TextStyle(color: Color(0xFF556F88)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                      Icons.phone_outlined,
                      size: 11,
                      color: Color(0xFF556F88),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+91 98XXXXXXXX',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF334F69)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 11,
                      color: Color(0xFF556F88),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ops@apexgearbd.com',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF334F69)),
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

  Widget _buildInfoField({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B8095),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 11.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF03253B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycGatewaysHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Automated KYC Gateways',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF03253B),
          ),
        ),
        Text(
          '3 of 4 Clear',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF556F88),
          ),
        ),
      ],
    );
  }

  Widget _buildKycCard1() {
    return _buildKycCardTemplate(
      icon: Icons.badge_outlined,
      iconBg: const Color(0xFFE2F0FD),
      iconColor: const Color(0xFF285C8A),
      title: 'UIDAI & NSDL Verification (Aadhaar/PAN)',
      tagText: 'PASS',
      tagBg: const Color(0xFFE6F5EC),
      tagFg: const Color(0xFF107C41),
      content:
          'Aadhaar: XXXX-XXXX-••••••129 • Biometric photo confidence: 98.4%\nElection Commission India Server • Instant Match',
    );
  }

  Widget _buildKycCard2() {
    return _buildKycCardTemplate(
      icon: Icons.verified_outlined,
      iconBg: const Color(0xFFE2F0FD),
      iconColor: const Color(0xFF285C8A),
      title: 'Trade License Validity',
      tagText: 'PASS',
      tagBg: const Color(0xFFE6F5EC),
      tagFg: const Color(0xFF107C41),
      content:
          'Mumbai South City Corporation (DSCC) • FY 2024-2025\nStatus: Active & Renewed through 30 June 2025',
    );
  }

  Widget _buildKycCard3() {
    return _buildKycCardTemplate(
      icon: Icons.receipt_long_outlined,
      iconBg: const Color(0xFFE2F0FD),
      iconColor: const Color(0xFF285C8A),
      title: 'NBR e-TIN Server Check',
      tagText: 'PASS',
      tagBg: const Color(0xFFE6F5EC),
      tagFg: const Color(0xFF107C41),
      content:
          '12-Digit Tax Identifier: 4819••••8912\nTax Circle: 112, Taxes Zone 05, Mumbai',
    );
  }

  Widget _buildKycCard4() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7EEDF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                      color: Color(0xFF75551E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Settlement Bank &\nCheque Leaf',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12.5,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9EEDD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 10, color: Color(0xFF75551E)),
                    SizedBox(width: 3),
                    Text(
                      'MANUAL',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF75551E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Dutch-Bangla Bank Ltd • Principal Branch (Routing 090272312)',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E465D),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Micro-deposit confirmed. Operator leaf title comparison required.',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB52E1D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycCardTemplate({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String tagText,
    required Color tagBg,
    required Color tagFg,
    required String content,
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF03253B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 11,
                      color: tagFg,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      tagText,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: tagFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.35,
              color: Color(0xFF4C647C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Compliance Dossier',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF03253B),
          ),
        ),
        Text(
          '4 Attached Files',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF556F88),
          ),
        ),
      ],
    );
  }

  Widget _buildDossierCard1() {
    return _buildDossierCardTemplate(
      type: 'PDF',
      typeBg: const Color(0xFFD6EEFD),
      typeFg: const Color(0xFF285C8A),
      filename: 'Trade_License_2024-25.pdf',
      filesize: '2.4 MB • Uploaded 22h ago',
      actionText: 'Inspect Document',
      showVerifyIcon: true,
      badgeText: null,
      badgeBg: null,
      badgeFg: null,
    );
  }

  Widget _buildDossierCard2() {
    return _buildDossierCardTemplate(
      type: 'SCAN',
      typeBg: const Color(0xFFD6EEFD),
      typeFg: const Color(0xFF285C8A),
      filename: 'Managing_Partner_PAN_Aadhaar...',
      filesize: '3.1 MB • Both sides signed',
      actionText: 'Inspect Document',
      showVerifyIcon: true,
      badgeText: null,
      badgeBg: null,
      badgeFg: null,
    );
  }

  Widget _buildDossierCard3() {
    return _buildDossierCardTemplate(
      type: 'PDF',
      typeBg: const Color(0xFFD6EEFD),
      typeFg: const Color(0xFF285C8A),
      filename: 'NBR_TIN_Certificate_ApexGear.pdf',
      filesize: '840 KB • Certified digital signature',
      actionText: 'Inspect Document',
      showVerifyIcon: true,
      badgeText: null,
      badgeBg: null,
      badgeFg: null,
    );
  }

  Widget _buildDossierCard4() {
    return _buildDossierCardTemplate(
      type: 'JPEG',
      typeBg: const Color(0xFFF7EEDF),
      typeFg: const Color(0xFF75551E),
      filename: 'Cheque_Leaf_DBBL_Principal...',
      filesize: '1.9 MB • Awaiting visual match',
      actionText: 'Inspect & Compare Title',
      showVerifyIcon: false,
      badgeText: 'AUDIT',
      badgeBg: const Color(0xFFF9EEDD),
      badgeFg: const Color(0xFF75551E),
    );
  }

  Widget _buildDossierCardTemplate({
    required String type,
    required Color typeBg,
    required Color typeFg,
    required String filename,
    required String filesize,
    required String actionText,
    required bool showVerifyIcon,
    String? badgeText,
    Color? badgeBg,
    Color? badgeFg,
  }) {
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: typeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: typeFg,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        filename,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF03253B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showVerifyIcon) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: Color(0xFF107C41),
                      ),
                    ],
                    if (badgeText != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg ?? const Color(0xFFF9EEDD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: badgeFg ?? const Color(0xFF75551E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  filesize,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B8095),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 12,
                      color: Color(0xFF285C8A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
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

  Widget _buildReviewerAuditThread() {
    return Container(
      width: double.infinity,
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
            children: const [
              Text(
                'Reviewer Audit\nThread',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
              Text(
                'ISO 27001\nLogged',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B8095),
                  height: 1.15,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // SysAdmin / Auto Bot message block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SysAdmin / Auto Bot',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF03253B),
                      ),
                    ),
                    Text(
                      'Today, 09:15 AM',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF6B8095),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '"Automated KYC checks cleared. Cheque leaf account title match vs registered trade name \'Merchant Applicant\'. Pending clearance from senior compliance officer."',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF294158),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Add Compliance Finding / Internal Note
          const Text(
            'Add Compliance Finding / Internal Note',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4C647C),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                color: Color(0xFF294158),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreDecisionSignoff() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EEFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.check_box_outlined,
                size: 16,
                color: Color(0xFF285C8A),
              ),
              SizedBox(width: 8),
              Text(
                'Mandatory Pre-decision Sign-off',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Checkbox 1
          _buildCheckItem(
            value: _signoff1,
            label: 'Business identity validated via NBR & DSCC portals',
            onChanged: (val) => setState(() => _signoff1 = val ?? false),
          ),
          const SizedBox(height: 6),

          // Checkbox 2
          _buildCheckItem(
            value: _signoff2,
            label: 'Managing partner PAN & Aadhaar authenticity confirmed',
            onChanged: (val) => setState(() => _signoff2 = val ?? false),
          ),
          const SizedBox(height: 6),

          // Checkbox 3
          _buildCheckItem(
            value: _signoff3,
            label: 'Bank account title verified against trade license',
            onChanged: (val) => setState(() => _signoff3 = val ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFF455879),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF223C54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2ECF5), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Approve Application
          Expanded(
            flex: 4,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application Approved Successfully!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF455879),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Approve\nApplication',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Query
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Query dispatched to merchant.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6EEFD),
                foregroundColor: const Color(0xFF285C8A),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline_rounded, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Query',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reject
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application Rejected.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDE8E5),
                foregroundColor: const Color(0xFFB33020),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
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
}
