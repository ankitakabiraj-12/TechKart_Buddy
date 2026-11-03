import 'package:flutter/material.dart';
import 'otp_verification.dart';
import 'seller_login.dart';
import 'seller_top_bar.dart';

class SellerRegistrationForm extends StatefulWidget {
  const SellerRegistrationForm({super.key});

  @override
  State<SellerRegistrationForm> createState() => _SellerRegistrationFormState();
}

class _SellerRegistrationFormState extends State<SellerRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  String _passwordStrength = 'None';
  double _passwordStrengthScore = 0.0; // 0.0 to 1.0

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 'None';
        _passwordStrengthScore = 0.0;
      });
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    setState(() {
      if (score <= 1) {
        _passwordStrength = 'Weak';
        _passwordStrengthScore = 0.25;
      } else if (score == 2) {
        _passwordStrength = 'Fair';
        _passwordStrengthScore = 0.5;
      } else if (score == 3) {
        _passwordStrength = 'Good';
        _passwordStrengthScore = 0.75;
      } else {
        _passwordStrength = 'Strong';
        _passwordStrengthScore = 1.0;
      }
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms, SLA, and Privacy Policy'),
          backgroundColor: Color(0xFFC0392B),
        ),
      );
      return;
    }

    final rawPhone = _phoneController.text.trim();
    final formattedPhone = rawPhone.startsWith('+91') ? rawPhone : '+91 $rawPhone';

    // Proceed to Step 2: OTP Verification
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : 'busi****@techmartbd.com',
          phone: rawPhone.isNotEmpty
              ? formattedPhone
              : 'Your phone number',
          registrationData: {
            'full_name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': formattedPhone,
            'password': _passwordController.text.trim(),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFE),
      appBar: const SellerTopBar(
        title: 'Seller Registration',
        subtitle: 'Step 1 of 4',
        showProfile: true,
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
                // Top Step 1 of 3 Card Banner
                _buildStepHeaderCard(),
                const SizedBox(height: 14),

                // 3-Segment Progress Bar
                _buildProgressBar(currentStep: 1),
                const SizedBox(height: 24),

                // Screen Heading: Account Setup
                const Text(
                  'Account Setup',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072138),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'Enter your primary merchant contact details to set up your TechKart Buddy seller profile.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF38495B),
                  ),
                ),
                const SizedBox(height: 24),

                // Field 1: Full Name (Proprietor / Representative)
                _buildFieldLabel(
                  'Full Name',
                  sublabel: '(Proprietor / Representative)',
                ),
                const SizedBox(height: 8),
                _buildTextInputField(
                  controller: _nameController,
                  hintText: 'Your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Field 2: Business Email Address
                _buildFieldLabel('Business Email Address'),
                const SizedBox(height: 8),
                _buildTextInputField(
                  controller: _emailController,
                  hintText: 'seller@business.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF385273),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'OTP verification will be sent here.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF385273),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Field 3: Mobile Phone Number
                _buildFieldLabel('Mobile Phone Number'),
                const SizedBox(height: 8),
                _buildPhoneInputField(),
                const SizedBox(height: 20),

                // Field 4: Password
                _buildFieldLabel('Password'),
                const SizedBox(height: 8),
                _buildPasswordInputField(
                  controller: _passwordController,
                  hintText: 'Min. 8 characters with numbers & s',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onChanged: _checkPasswordStrength,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Security Strength Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Security Strength',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF5A6B7E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _passwordStrength,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _passwordStrength == 'Strong'
                            ? const Color(0xFF2E7D32)
                            : _passwordStrength == 'Good'
                                ? const Color(0xFF1976D2)
                                : const Color(0xFF425265),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildStrengthBar(),
                const SizedBox(height: 20),

                // Field 5: Confirm Password
                _buildFieldLabel('Confirm Password'),
                const SizedBox(height: 8),
                _buildPasswordInputField(
                  controller: _confirmPasswordController,
                  hintText: 'Re-enter password',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // Terms and Conditions Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                        activeColor: const Color(0xFF03253B),
                        side: const BorderSide(color: Color(0xFFCBD6E2), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Color(0xFF3B4A5C),
                          ),
                          children: [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'TechKart Buddy Seller Marketplace Terms',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                color: Color(0xFF0A233A),
                              ),
                            ),
                            TextSpan(text: ', '),
                            TextSpan(
                              text: 'Service Level Agreement (SLA)',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                color: Color(0xFF0A233A),
                              ),
                            ),
                            TextSpan(text: ', and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                color: Color(0xFF0A233A),
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Note Info Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F0FE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFCDE3FA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Color(0xFF24446A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.45,
                              color: Color(0xFF274465),
                            ),
                            children: [
                              TextSpan(
                                text: 'Note: ',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              TextSpan(
                                text:
                                    'Registration creates your merchant login. Store verification & trade license validation occurs in the subsequent onboarding steps.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button: Create Account ->
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
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
                          'Create Account',
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

                // Sign In Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellerLogin(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF38485B),
                        ),
                        children: [
                          TextSpan(text: 'Already a registered seller? '),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF072138),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF03253B),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Step 1 of 3',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                  Text(
                    'Account Credentials',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4C5D70),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD2E8FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: Color(0xFF274465),
                ),
                SizedBox(width: 4),
                Text(
                  '256-bit SSL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF274465),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({required int currentStep}) {
    return Row(
      children: [
        // Step 1 Segment
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF4B5A79),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Step 2 Segment
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFC9E2FA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Step 3 Segment
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFC9E2FA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {String? sublabel}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF072138),
        ),
        children: [
          TextSpan(text: label),
          if (sublabel != null)
            TextSpan(
              text: ' $sublabel',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFF526376),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2EAF2), width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F1E2C)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFA5B4C4),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF4C5D72)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2EAF2), width: 1.2),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 19, color: Color(0xFF4C5D72)),
                SizedBox(width: 8),
                Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF092238),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 24,
            width: 1,
            color: const Color(0xFFD3DFEC),
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
              style: const TextStyle(fontSize: 14, color: Color(0xFF0F1E2C)),
              decoration: const InputDecoration(
                hintText: 'Your 10-digit number',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA5B4C4),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInputField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2EAF2), width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F1E2C)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFA5B4C4),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: Color(0xFF4C5D72),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: const Color(0xFF4C5D72),
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStrengthBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _passwordStrengthScore >= 0.25
                  ? const Color(0xFF759ED5)
                  : const Color(0xFFBCE1FB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _passwordStrengthScore >= 0.5
                  ? const Color(0xFF759ED5)
                  : const Color(0xFFBCE1FB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _passwordStrengthScore >= 0.75
                  ? const Color(0xFF759ED5)
                  : const Color(0xFFBCE1FB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
