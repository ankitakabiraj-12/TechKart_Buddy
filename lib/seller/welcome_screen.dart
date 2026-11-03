import 'package:flutter/material.dart';
import 'seller_registration_form.dart';
import 'seller_login.dart';
import '../admin/admin_login.dart';
import 'seller_top_bar.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFE),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 28).clamp(0.0, double.infinity),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Header, Badges, Title & Subtitle, Stats, and Value Prop Cards
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Bar: Logo + Brand Name + Lang toggle + Help icon
                        _buildHeader(context),
                        const SizedBox(height: 22),

                        // Pill badge: MERCHANT PORTAL INDIA
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6EEDB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE9DCBA),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 14.5,
                                color: Color(0xFF947230),
                              ),
                              SizedBox(width: 4.5),
                              Text(
                                'MERCHANT PORTAL INDIA',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7E6023),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Headline
                        const Text(
                          'Start Selling on\nTechKart',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 33,
                            height: 1.16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF072138),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description paragraph
                        const Text(
                          'Join thousands of verified electronics merchants across India. Reach millions of active tech buyers, manage multi-hub inventory, and enjoy predictable payouts with zero onboarding friction.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14.5,
                            height: 1.48,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF384759),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Three Column Metrics Card
                        _buildMetricsCard(),
                        const SizedBox(height: 28),

                        // Section Header: WHY PARTNER WITH US
                        const Text(
                          'WHY PARTNER WITH US',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4B5A6A),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Feature Card 1: Direct Marketplace Reach
                        _buildFeatureCard(
                          icon: Icons.storefront_outlined,
                          title: 'Direct Marketplace Reach',
                          description:
                              'Immediate visibility across flagship gadgets, computing hardware, audio gear, and spare accessories with high-intent traffic.',
                        ),
                        const SizedBox(height: 12),

                        // Feature Card 2: Guaranteed & Timely Settlements
                        _buildFeatureCard(
                          icon: Icons.verified_user_outlined,
                          title: 'Guaranteed & Timely Settlements',
                          description:
                              'Automated weekly bank settlements and UPI / Razorpay merchant payouts with transparent, tier-based 6% platform commission.',
                        ),
                        const SizedBox(height: 12),

                        // Feature Card 3: Seamless Express Fulfillment
                        _buildFeatureCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Seamless Express Fulfillment',
                          description:
                              'Instant doorstep pickup via Blue Dart, Delhivery and TechKart Logistics with automated digital waybill generation.',
                        ),
                      ],
                    ),

                    // Bottom Section: Action buttons, compliance statement, footer links
                    Padding(
                      padding: const EdgeInsets.only(top: 26.0, bottom: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Primary Button: Create Seller Account ->
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SellerRegistrationForm(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF03253B),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: const Color(0xFF03253B).withValues(alpha: 0.35),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create Seller Account',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 17),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Secondary Button: Sign In to Existing Account ->
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SellerLogin(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD3EAFB),
                              foregroundColor: const Color(0xFF08273F),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign In to Existing Account',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                    color: Color(0xFF08273F),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.login_rounded, size: 17, color: Color(0xFF08273F)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Admin Portal Access Button
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminLogin(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF03253B),
                              side: const BorderSide(color: Color(0xFFBED8F3), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.admin_panel_settings_outlined, size: 17, color: Color(0xFF03253B)),
                                SizedBox(width: 8),
                                Text(
                                  'Admin Console Portal',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: Color(0xFF03253B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // India Directive compliance text with lock icon
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 15,
                                  color: const Color(0xFF38495F).withValues(alpha: 0.9),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Licensed under India e-Commerce Digital Commerce Directives',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: Color(0xFF4B5A6C),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Footer Links (Seller Agreement, Privacy Policy, Seller FAQ & Support)
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 4,
                              children: [
                                _buildTextLink(context, 'Seller Agreement'),
                                _buildBulletSeparator(),
                                _buildTextLink(context, 'Privacy Policy'),
                                _buildBulletSeparator(),
                                _buildTextLink(context, 'Seller FAQ & Support'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SellerTopBar(
      title: 'TechKart Merchant Portal',
      subtitle: 'India Directives',
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F0FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.translate_rounded,
                size: 15,
                color: Color(0xFF1B3B60),
              ),
              SizedBox(width: 5),
              Text(
                'EN | বাং',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16375C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFE5EDF6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.help_outline_rounded,
              size: 19,
              color: Color(0xFF36485E),
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEFF3F8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A223B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem('14k+', 'ACTIVE STORES'),
          ),
          Container(
            height: 28,
            width: 1,
            color: const Color(0xFFB8DAF7),
          ),
          Expanded(
            child: _buildMetricItem('64 Dist.', 'DELIVERY REACH'),
          ),
          Container(
            height: 28,
            width: 1,
            color: const Color(0xFFB8DAF7),
          ),
          Expanded(
            child: _buildMetricItem('7-Day', 'BANK PAYOUTS'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF082239),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9.2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF556678),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2EFFC),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF2E486D),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF09243C),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.2,
                    height: 1.42,
                    color: Color(0xFF4C5D70),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLink(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF47586B),
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF47586B),
        ),
      ),
    );
  }

  Widget _buildBulletSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF889BB0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
