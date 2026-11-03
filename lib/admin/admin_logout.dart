import 'package:flutter/material.dart';
import 'admin_auth_service.dart';
import 'admin_login.dart';
import 'admin_top_bar.dart';

class AdminLogoutScreen extends StatelessWidget {
  const AdminLogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: const AdminTopBar(
        title: 'Logout Confirmation',
        subtitle: 'Operator Session Termination',
        showNotifications: false,
        showProfile: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF03253B).withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Subtle watermark shield in top-right
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Opacity(
                      opacity: 0.06,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF285C8A),
                          borderRadius: BorderRadius.circular(70),
                        ),
                        child: const Icon(Icons.verified_outlined, size: 90, color: Color(0xFF03253B)),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 6),

                        // Red Circle Icon with Refresh Lock & Red Dot Badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB52E1D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB52E1D),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Title
                        const Text(
                          'Sign out of\nTechKart Admin?',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF03253B),
                            height: 1.18,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Description paragraph
                        const Text(
                          'Are you sure you want to end your administrative session? Signing out will instantly invalidate your session token, clear cached client credentials and cryptographic authorization keys from this device, and log an audit trail event.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            color: Color(0xFF4B6074),
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 18),

                        // Active Session Diagnostics Card
                        _buildDiagnosticsCard(),

                        const SizedBox(height: 14),

                        // Compliance Protocol Box
                        _buildComplianceProtocolBox(),

                        const SizedBox(height: 20),

                        // Red Sign Out Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await AdminAuthService.logout();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AdminLogin()),
                                  (route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB52E1D),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 17, color: Colors.white),
                            label: const Text(
                              'Sign Out & Invalidate Session',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Cancel & Return to Console Button
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFEDF5FD),
                              foregroundColor: const Color(0xFF03253B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Cancel & Return to Console',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF03253B),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Token ID Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.shield_outlined, size: 12, color: Color(0xFF6B8095)),
                            SizedBox(width: 5),
                            Text(
                              'Secure Session Token ID: TK-ADM-9842X-09B',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 10,
                                color: Color(0xFF6B8095),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6EEFD), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF285C8A)),
                  SizedBox(width: 6),
                  Text(
                    'Active Session\nDiagnostics',
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
                  'TLS 1.3\nActive',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285C8A),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDiagRow('Operator', 'Administrator (op-8924)'),
          const SizedBox(height: 4),
          _buildDiagRow('Access Tier', 'SuperAdmin (Level 3 Clearance)', bullet: true),
          const SizedBox(height: 4),
          _buildDiagRow('Active Node', 'Mumbai Central Hub (BOM-01)', icon: Icons.dns_outlined),
          const SizedBox(height: 4),
          _buildDiagRow('Queue Status', '2 Dual-Sign Batches queued', icon: Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _buildDiagRow(String label, String value, {bool bullet = false, IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 10.5,
            color: Color(0xFF556F88),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bullet) ...[
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
            if (icon != null) ...[
              Icon(icon, size: 12, color: const Color(0xFF03253B)),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF03253B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplianceProtocolBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EEDF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEADBCE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.assignment_outlined, size: 16, color: Color(0xFF5D4732)),
          SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Compliance Protocol: ',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4A341E),
                ),
                children: [
                  TextSpan(
                    text:
                        'In accordance with ISO-27001 & Information Technology Act, simply closing the browser window or app does not replace cryptographically signing out.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF5D4732),
                      height: 1.3,
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
