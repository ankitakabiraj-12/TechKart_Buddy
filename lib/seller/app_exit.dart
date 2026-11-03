import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/network/api_client.dart';
import '../core/network/token_storage.dart';

/// Shows the production-grade TechKart Buddy Exit confirmation dialog.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => const AppExitDialog(),
  );
  return result ?? false;
}

class AppExitDialog extends StatelessWidget {
  const AppExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF072138).withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Power Icon Container
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4F0FB),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 32,
                    color: Color(0xFF071F36),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title: Exit TechKart Buddy?
              const Text(
                'Exit TechKart Buddy?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF072138),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Any active product edits or unsubmitted updates are automatically saved to your merchant draft.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF4C5D70),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Dual Action Buttons: Exit | Stay
              Row(
                children: [
                  // Exit Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await ApiClient().post('/buddy/auth/logout');
                          } catch (_) {}
                          await TokenStorage().clearAuth();
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                          SystemNavigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE7F2FC),
                          foregroundColor: const Color(0xFF072138),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Exit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF072138),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Stay Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF071228),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Stay',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Dismiss Instruction note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13.5,
                    color: Color(0xFF7A8FA3),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Press back or tap outside to dismiss',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7A8FA3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standalone preview/showcase screen matching the reference image layout.
class AppExitScreen extends StatelessWidget {
  const AppExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        body: Stack(
          children: [
            // Background representation of the seller screen
            _buildBackgroundMock(context),
            // Semi-transparent backdrop blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
            // Centered Exit Dialog Card
            const Center(
              child: AppExitDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundMock(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar mock
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'asset/techkart_buddy_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: Color(0xFF072138),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Merchant Account',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF072138),
                      ),
                    ),
                    Text(
                      'Mumbai Central • Live Hub',
                      style: TextStyle(fontSize: 11, color: Color(0xFF4C5D70)),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5EFF9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: Color(0xFF28384C),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFF072B44),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'AG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bottom bar mock
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE4EDF7), width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.home, color: Color(0xFF072138), size: 24),
                Icon(Icons.inventory_2_outlined, color: Color(0xFF8DA5C0), size: 24),
                Icon(Icons.receipt_long_outlined, color: Color(0xFF8DA5C0), size: 24),
                Icon(Icons.person_outline, color: Color(0xFF8DA5C0), size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
