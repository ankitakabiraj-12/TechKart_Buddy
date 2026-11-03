import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'seller_top_bar.dart';

class ApplicationStatus extends StatelessWidget {
  final String? refNumber;
  final String? businessName;
  final String? submittedAt;

  const ApplicationStatus({
    super.key,
    this.refNumber,
    this.businessName,
    this.submittedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: SellerTopBar(
        title: 'Application Status',
        subtitle: 'Review & Onboarding',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD4E8FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF1E4B75)),
                SizedBox(width: 4),
                Text(
                  '256-bit SSL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E4B75),
                  ),
                ),
              ],
            ),
          ),
        ],
        showProfile: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // REF Tag Row
              Row(
                children: [
                  const Text(
                    'REF: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4C5D70),
                    ),
                  ),
                  Text(
                    refNumber?.isNotEmpty == true ? '#$refNumber' : '#TKB-APP-PENDING',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A2038),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_outlined, size: 14, color: Color(0xFF4C7DA8)),
                ],
              ),
              const SizedBox(height: 12),

              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDD0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDFCE9A), width: 0.8),
                ),
                child: const Text(
                  'IN VERIFICATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF715A1A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Business Name & Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront_outlined, size: 18, color: Color(0xFF0A2038)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                businessName?.isNotEmpty == true ? businessName! : 'Your store name',
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF072138),
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF4C5D70)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                submittedAt?.isNotEmpty == true
                                    ? 'Submitted: $submittedAt'
                                    : 'Submitted on Oct 28, 2024 • 11:30 AM',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF4C5D70),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6ECFD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      size: 22,
                      color: Color(0xFF1E4B75),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Estimated Turnaround
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDDE8F5), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDAEEFD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: Color(0xFF1E4B75),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Estimated Turnaround',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF28384C),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '12 - 24 Hours',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0A2038),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Automated Screening Passed Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCADFFB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Color(0xFF1E4B75),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: const [
                              Text(
                                'Automated Screening Passed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0A2038),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('•', style: TextStyle(color: Color(0xFF4C5D70))),
                              SizedBox(width: 6),
                              Text(
                                'Mumbai Hub Desk',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3B6688),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your trade license and e-TIN have passed automated format checks. Our compliance desk in Mumbai is currently validating your bank cheque leaf. No action required at this moment.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13.5,
                        height: 1.45,
                        color: Color(0xFF2A3E53),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Verification Lifecycle Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verification Lifecycle',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEEEFD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Step 3 of 5',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E4B75),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Steps
              _buildLifecycleStep(
                index: 0,
                icon: Icons.check_rounded,
                iconBgColor: const Color(0xFF2E7D32),
                iconColor: Colors.white,
                title: 'Account Registration & OTP',
                subtitle: 'Phone & email credentials authenticated',
                time: '11:15 AM',
                status: null,
                isActive: false,
                isLocked: false,
              ),
              _buildStepConnector(filled: true),
              _buildLifecycleStep(
                index: 1,
                icon: Icons.check_rounded,
                iconBgColor: const Color(0xFF8DA5C0),
                iconColor: Colors.white,
                title: 'Business & Tax Information',
                subtitle: 'Trade license number and e-TIN matched',
                time: '11:22 AM',
                status: null,
                isActive: false,
                isLocked: false,
              ),
              _buildStepConnector(filled: true),
              _buildLifecycleStep(
                index: 2,
                icon: Icons.hourglass_top_rounded,
                iconBgColor: const Color(0xFF03253B),
                iconColor: Colors.white,
                title: 'Document Verification',
                subtitle: 'Desk review in progress by TechKart\nCompliance Team.',
                time: null,
                status: 'ACTIVE',
                statusColor: const Color(0xFFE3F2FD),
                statusTextColor: const Color(0xFF1565C0),
                slaText: '⏱ SLA Target: Today, before 11:30 PM',
                isActive: true,
                isLocked: false,
              ),
              _buildStepConnector(filled: false),
              _buildLifecycleStep(
                index: 3,
                icon: Icons.account_balance_outlined,
                iconBgColor: const Color(0xFFE5EDF6),
                iconColor: const Color(0xFF8DA5C0),
                title: 'Bank Payout & Settlement Setup',
                subtitle: 'NEFT / RTGS test credit & routing confirmation',
                time: null,
                status: null,
                isActive: false,
                isLocked: true,
              ),
              _buildStepConnector(filled: false),
              _buildLifecycleStep(
                index: 4,
                icon: Icons.rocket_launch_outlined,
                iconBgColor: const Color(0xFFE5EDF6),
                iconColor: const Color(0xFF8DA5C0),
                title: 'Storefront Live & Ready to Sell',
                subtitle: 'Public product catalog publication & seller badge',
                time: null,
                status: null,
                isActive: false,
                isLocked: true,
              ),
              const SizedBox(height: 20),

              // Preview Submitted Details
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFFD4E5F5), width: 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility_outlined, size: 17, color: Color(0xFF28384C)),
                      SizedBox(width: 8),
                      Text(
                        'Preview Submitted Details',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF28384C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Go to Seller Dashboard (locked)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellerBottomNav(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF3FB),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFFCCDFF0), width: 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dashboard_outlined, size: 17, color: Color(0xFF637483)),
                      SizedBox(width: 8),
                      Text(
                        'Go to Seller Dashboard',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF637483),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.lock_outlined, size: 14, color: Color(0xFF8DA5C0)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Unlocks automatically once compliance desk approves all documents',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF4C5D70),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Support Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4E5F5), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD6ECFD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.headset_mic_outlined,
                            size: 16,
                            color: Color(0xFF1E4B75),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Need urgent verification assistance?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0A2038),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our onboarding specialists are available Saturday to Thursday (9:00 AM–7:00 PM BST) to address merchant credential inquiries.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Color(0xFF38495B),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF03142E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone_rounded, size: 14, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  '0800-TECHKART',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEEEFD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.message_outlined,
                                    size: 14, color: Color(0xFF0A2038)),
                                SizedBox(width: 6),
                                Text(
                                  'WhatsApp Desk',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0A2038),
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
              ),
              const SizedBox(height: 14),

              // Update or Replace Documents link
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4E5F5), width: 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.upload_file_outlined,
                              size: 16, color: Color(0xFF374E65)),
                          SizedBox(width: 8),
                          Text(
                            'Update or Replace Uploaded Documents',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374E65),
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: Color(0xFF8DA5C0)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifecycleStep({
    required int index,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? time,
    String? status,
    Color? statusColor,
    Color? statusTextColor,
    String? slaText,
    required bool isActive,
    required bool isLocked,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle Step Icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isLocked ? const Color(0xFF8DA5C0) : const Color(0xFF0A2038),
                      ),
                    ),
                  ),
                  if (time != null)
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4C5D70)),
                    ),
                  if (status != null)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  if (isLocked)
                    const Icon(Icons.lock_outline, size: 14, color: Color(0xFF8DA5C0)),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isLocked ? const Color(0xFFA0B3C8) : const Color(0xFF4C5D70),
                ),
              ),
              if (slaText != null) ...[
                const SizedBox(height: 6),
                Text(
                  slaText,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A6B7C),
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool filled}) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Container(
        width: 2,
        height: 16,
        color: filled ? const Color(0xFF3A6082) : const Color(0xFFCEDEEF),
      ),
    );
  }
}
