import 'dart:async';
import 'package:flutter/material.dart';
import 'business_details.dart';
import 'seller_top_bar.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String phone;
  final Map<String, dynamic>? registrationData;

  const OtpVerificationScreen({
    super.key,
    this.email = 'busi****@techmartbd.com',
    this.phone = 'Your registered phone',
    this.registrationData,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendCountdown = 46;
  int _expireCountdown = 300; // 5 minutes (05:00)
  final int _attemptsRemaining = 3;
  Timer? _resendTimer;
  Timer? _expireTimer;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    _resendTimer?.cancel();
    _expireTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });

    _expireTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_expireCountdown > 0) {
        setState(() {
          _expireCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatExpireDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String _formatResendDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _verifyAndContinue() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit authentication code'),
          backgroundColor: Color(0xFFC0392B),
        ),
      );
      return;
    }

    // Proceed to Step 2 of 4: Business & Tax Information
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetails(
          registrationData: widget.registrationData,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _expireTimer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFE),
      appBar: const SellerTopBar(
        title: 'OTP Verification',
        subtitle: '2-Step Verification',
        showProfile: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Header: Step 2 of 3 • Identity Verification & 67% Done chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Step 2 of 3 • Identity Verification',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF28384C),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEDFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '67% Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E4B75),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Segmented Bar: 2 segments active (dark blue), 3rd light
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF485676),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF485676),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7E1FA),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 256-Bit SSL Encrypted Verification Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F3FE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6E7FA), width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14.5,
                      color: Color(0xFF274465),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '256-Bit SSL Encrypted Verification',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF274465),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title: Verify Your Identity
              const Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF072138),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              const Text(
                'Enter the 6-digit authentication code sent to your registered merchant account to secure your storefront setup.',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14.5,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF38495B),
                ),
              ),
              const SizedBox(height: 22),

              // Email & Phone info container with "Change" button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FD),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD3E7FA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.email_outlined,
                                  size: 13,
                                  color: Color(0xFF234468),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF072138),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD3E7FA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone_android_outlined,
                                  size: 13,
                                  color: Color(0xFF234468),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.phone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF072138),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E9FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined, size: 13, color: Color(0xFF0B263F)),
                            SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B263F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 6 Circular OTP Pin Boxes (Responsive across phone sizes)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: _buildOtpBox(index),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Attempts Remaining and Timer row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B583E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_attemptsRemaining attempts remaining',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4C5D70),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Color(0xFF4C5D70),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Expires in ${_formatExpireDuration(_expireCountdown)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4C5D70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Resend Card Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF082239).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Didn't receive the authentication token?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF38495B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: Color(0xFF274465),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _resendCountdown > 0
                              ? 'Resend Code in ${_formatResendDuration(_resendCountdown)}'
                              : 'Resend Code Now',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF234468),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F0FE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF475E7B)),
                                SizedBox(width: 6),
                                Text(
                                  'Resend via SMS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475E7B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F0FE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.forum_outlined, size: 14, color: Color(0xFF475E7B)),
                                SizedBox(width: 6),
                                Text(
                                  'Via WhatsApp',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475E7B),
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
              const SizedBox(height: 36),

              // Verify & Continue Button ->
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03253B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shadowColor: const Color(0xFF03253B).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify & Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 17),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Merchant Support Contact Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEEFD),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.headset_mic_outlined,
                        size: 20,
                        color: Color(0xFF274465),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Facing issues with verification?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF072138),
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF38495B),
                              ),
                              children: [
                                TextSpan(text: 'Contact Merchant Support: '),
                                TextSpan(
                                  text: '0800-T...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    color: Color(0xFF072138),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    );
  }

  Widget _buildOtpBox(int index) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x0C051D33),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF072138),
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: '-',
            hintStyle: TextStyle(
              fontSize: 16,
              color: Color(0xFFCFDCE8),
              fontWeight: FontWeight.w400,
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    ),
  ),
);
  }
}
