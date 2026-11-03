import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final Widget? nextScreen;
  final String? portalBadgeText;
  final String? syncText;

  const SplashScreen({
    super.key,
    this.nextScreen,
    this.portalBadgeText,
    this.syncText,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.05, end: 0.52).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _animController.forward();
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secondaryAnim) =>
            widget.nextScreen ?? const WelcomeScreen(),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF5FD), // soft sky blue top
              Color(0xFFF9FBFE), // soft middle
              Color(0xFFEDF4FD), // slight deeper soft blue bottom
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Subtle ambient background glow circles
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD9ECFB).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: -50,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2F0FD).withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                  // Scrollable responsive content container
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),

                            // Center branding content
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Logo Card with soft shadow & rounded squircle
                                    Container(
                                      width: 130,
                                      height: 130,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0F2644).withValues(alpha: 0.07),
                                            blurRadius: 28,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF285688).withValues(alpha: 0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'asset/techkart_buddy_logo.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 60,
                                            color: Color(0xFF082238),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // Main Title in Serif
                                    const Text(
                                      'TechKart Buddy',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF072138),
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Subtitle tagline
                                    const Text(
                                      'Your Business. Your Growth.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF3B4856),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    // Official Merchant & Seller Portal Pill Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 7.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5F1FC),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: const Color(0xFFCFE4F9),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.verified_outlined,
                                            size: 15,
                                            color: Color(0xFF2B4D73),
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            widget.portalBadgeText ??
                                                'Official Merchant & Seller Portal',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF234468),
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Bottom section: Get Started button, Progress bar, sync text, SSL lock
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Get Started Button
                                GestureDetector(
                                  onTap: _navigateToNext,
                                  child: Container(
                                    width: double.infinity,
                                    constraints: const BoxConstraints(maxWidth: 320),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF03142E), Color(0xFF0F325A)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF03142E).withValues(alpha: 0.25),
                                          blurRadius: 14,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get Started',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Progress bar
                                AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return SizedBox(
                                      width: 145,
                                      height: 4,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: Stack(
                                          children: [
                                            Container(
                                              color: const Color(0xFFCADDF7),
                                            ),
                                            FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: _progressAnimation.value,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF384766),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Loading sync text
                                Text(
                                  widget.syncText ?? 'Syncing active store inventory...',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7E93),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // SSL lock badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 13,
                                      color: const Color(0xFF889BB0).withValues(alpha: 0.95),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'ENTERPRISE LEVEL 256-BIT SSL',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8598AD),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
