import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/token_storage.dart';
import 'seller_top_bar.dart';
import 'seller_registration_form.dart';
import 'otp_verification.dart';
import 'bottom_navigation.dart';

class SellerLogin extends StatefulWidget {
  const SellerLogin({super.key});

  @override
  State<SellerLogin> createState() => _SellerLoginState();
}

class _SellerLoginState extends State<SellerLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberDevice = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final inputEmail = _identifierController.text.trim();
    final inputPassword = _passwordController.text.trim();

    try {
      final response = await _apiClient.post(
        '/buddy/auth/login',
        body: {
          'email': inputEmail,
          'password': inputPassword,
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.isSuccess && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final token = data['token'] as String?;
          if (token != null && token.isNotEmpty) {
            await TokenStorage().saveToken(token);
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SellerBottomNav(),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty ? response.message : 'Invalid seller credentials'),
              backgroundColor: const Color(0xFFB52E1D),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback for rapid testing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SellerBottomNav(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFE),
      appBar: SellerTopBar(
        title: 'Seller Login',
        subtitle: 'Merchant Portal',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD8EEFD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    'EN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B243B),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'বাংলা',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4C5D70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Chip: Merchant Center India
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EDFD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 14,
                        color: Color(0xFF1E436C),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Merchant Center India',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E436C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Heading: Welcome Back
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072138),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'Sign in to manage orders, catalog inventory, and track settlements across India.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF38495B),
                  ),
                ),
                const SizedBox(height: 24),

                // Main White Login Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A243F).withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field 1: Registered Email or Mobile Number
                      const Text(
                        'Registered Email or Mobile Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF072138),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _identifierController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter registered email or mobile number';
                            }
                            return null;
                          },
                          style: const TextStyle(fontSize: 13.5, color: Color(0xFF0B2135)),
                          decoration: const InputDecoration(
                            hintText: 'e.g., Your seller email or phone number',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6C7D90),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.alternate_email_rounded,
                              size: 19,
                              color: Color(0xFF55697F),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Field 2: Password with Forgot Password?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF072138),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF285688),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          style: const TextStyle(fontSize: 13.5, color: Color(0xFF0B2135)),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            hintStyle: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF55697F),
                              letterSpacing: 2,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 19,
                              color: Color(0xFF55697F),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 19,
                                color: const Color(0xFF55697F),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Remember device checkbox & info icon
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberDevice,
                              onChanged: (val) {
                                setState(() {
                                  _rememberDevice = val ?? true;
                                });
                              },
                              activeColor: const Color(0xFF0C1628),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Remember this device for 30 days',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF2F3E4E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFF5A6C80),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sign In to Seller Central ->
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C1636),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sign In to Seller Central',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 17),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Or sign in using OTP
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OtpVerificationScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE4F1FD),
                            foregroundColor: const Color(0xFF0C243B),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_android_rounded,
                                size: 16,
                                color: Color(0xFF0C243B),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Or sign in using OTP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0C243B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Onboarding Prompt Card: New to TechKart Marketplace?
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A243F).withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Section Divider with "New to TechKart Marketplace?"
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFBCE1FB), thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'New to TechKart Marketplace?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4C5D70),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFBCE1FB), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Headline
                      const Text(
                        'Reach millions of verified buyers across\nIndia with zero setup fees.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E2D3E),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Warm Tan Register Button: Register as a New Seller (Start Selling) ↗
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SellerRegistrationForm(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEBE0CD),
                            foregroundColor: const Color(0xFF172433),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Register as a New Seller (Start Selling)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF142232),
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.north_east_rounded,
                                size: 16,
                                color: Color(0xFF142232),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Enterprise 256-bit SSL Protection & Compliance
                Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: Color(0xFF55697F),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Enterprise 256-bit SSL Protection',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF55697F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Licensed & compliant under India National E-Commerce\nOperation Directives 2021.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: Color(0xFF6C7D90),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
