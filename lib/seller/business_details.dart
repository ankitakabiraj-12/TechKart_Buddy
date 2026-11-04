import 'package:flutter/material.dart';
import 'document_verification.dart';
import 'seller_top_bar.dart';

class BusinessDetails extends StatefulWidget {
  final Map<String, dynamic>? registrationData;

  const BusinessDetails({
    super.key,
    this.registrationData,
  });

  @override
  State<BusinessDetails> createState() => _BusinessDetailsState();
}

class _BusinessDetailsState extends State<BusinessDetails> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late final TextEditingController _legalNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final TextEditingController _addressController = TextEditingController(
      text: '');
  final TextEditingController _postalCodeController =
      TextEditingController(text: '');
  final TextEditingController _tradeLicenseController =
      TextEditingController(text: '');
  final TextEditingController _tinController =
      TextEditingController(text: '');
  final TextEditingController _binController =
      TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    final d = widget.registrationData;
    _legalNameController = TextEditingController(
      text: (d?['store_name'] as String?)?.isNotEmpty == true
          ? d!['store_name']
          : '',
    );
    _emailController = TextEditingController(
      text: (d?['email'] as String?)?.isNotEmpty == true
          ? d!['email']
          : '',
    );
    _phoneController = TextEditingController(
      text: (d?['phone'] as String?)?.isNotEmpty == true
          ? d!['phone'].toString().replaceAll(RegExp(r'[^0-9]'), '')
          : '',
    );
  }

  // Business Structure selection
  String _selectedStructure = 'Proprietorship';

  // Category & dropdowns
  String _selectedCategory = 'Consumer Electronics & Tech Accessories';
  String _selectedDivision = 'Maharashtra';
  String _selectedDistrict = 'Mumbai City';

  final List<String> _subcategories = ['Smart Audio', 'GaN Chargers'];
  bool _isBinRegistered = true;

  @override
  void dispose() {
    _legalNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _tradeLicenseController.dispose();
    _tinController.dispose();
    _binController.dispose();
    super.dispose();
  }

  void _continueToVerification() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentData = Map<String, dynamic>.from(widget.registrationData ?? {});
    currentData['store_name'] = _legalNameController.text.trim();
    currentData['email'] = _emailController.text.trim();
    currentData['phone'] = _phoneController.text.trim();
    currentData['address'] = _addressController.text.trim();
    currentData['pincode'] = _postalCodeController.text.trim();
    currentData['trade_license'] = _tradeLicenseController.text.trim();
    currentData['tin_number'] = _tinController.text.trim();
    currentData['category'] = _selectedCategory;
    currentData['city'] = _selectedDistrict;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentVerification(
          registrationData: currentData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFE),
      appBar: const SellerTopBar(
        title: 'Business Details',
        subtitle: 'Step 2 of 4',
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
                // Top Step Header: Step 2 of 4 • Business Details & 256-bit SSL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F0FD),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Color(0xFF0C243B),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Step 2 of 4 • Business Details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF072138),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: Color(0xFF4C5D70),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '256-bit SSL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4C5D70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Solid Progress line (Blue active on first half, pale remainder)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B70BC),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7E1FA),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title: Business & Tax Information
                const Text(
                  'Business & Tax\nInformation',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072138),
                    letterSpacing: -0.3,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'Provide your legal entity and operational details for merchant verification and automated payouts.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF38495B),
                  ),
                ),
                const SizedBox(height: 20),

                // CARD 1: Entity & Marketplace Category
                _buildCardSection(
                  icon: Icons.storefront_outlined,
                  title: 'Entity & Marketplace Category',
                  children: [
                    // Legal Business Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRequiredLabel('Legal Business Name'),
                        const Text(
                          'As per Trade License',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6C7D90),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _legalNameController,
                      suffixIcon: Icons.verified_user_outlined,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Must strictly match your official corporate bank account name.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4C5D70),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Business Structure 2x2 grid
                    _buildRequiredLabel('Business Structure'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStructureTile(
                            icon: Icons.person_outline,
                            title: 'Proprietorship',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStructureTile(
                            icon: Icons.groups_outlined,
                            title: 'Partnership',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStructureTile(
                            icon: Icons.apartment_outlined,
                            title: 'Private Ltd.',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStructureTile(
                            icon: Icons.domain_outlined,
                            title: 'Public Ltd.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Primary Business Category
                    _buildRequiredLabel('Primary Business Category'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD8E4F0), width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF4C5D70)),
                          items: [
                            'Consumer Electronics & Tech Accessories',
                            'Computing & Laptops',
                            'Smartphones & Tablets',
                            'Audio & Wearables',
                          ].map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF0A223B),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Chips: Smart Audio x, GaN Chargers x
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._subcategories.map(
                          (sub) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEEDFD),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sub,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E436C),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _subcategories.remove(sub);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 13,
                                    color: Color(0xFF1E436C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // + Add Sub-category pill button
                    GestureDetector(
                      onTap: () {
                        // Demo add tag
                        setState(() {
                          _subcategories.add('Wearable Gadgets');
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7E3FB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '+ Add Sub-category',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF163E66),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // CARD 2: Contact & Operational Presence
                _buildCardSection(
                  icon: Icons.contact_mail_outlined,
                  title: 'Contact & Operational Presence',
                  children: [
                    _buildRequiredLabel('Official Business Email'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _emailController,
                      suffixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Invoices, settlement digests, and dispute notices will route here.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4C5D70),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildRequiredLabel('Customer Support Hotline'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD8E4F0), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            child: const Row(
                              children: [
                                Text('🇧🇩 ', style: TextStyle(fontSize: 14)),
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF072138),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: const Color(0xFFDCE6F0),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF072138),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildRequiredLabel('Registered Business Address'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _addressController,
                      maxLines: 2,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),

                    // Division & District / Area row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRequiredLabel('State / Region'),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFD8E4F0), width: 1),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedDivision,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                        size: 18, color: Color(0xFF4C5D70)),
                                    items: [
                                      'Maharashtra',
                                      'Karnataka',
                                      'Delhi',
                                      'Tamil Nadu',
                                      'Gujarat',
                                      'Uttar Pradesh',
                                      'West Bengal',
                                      'Telangana',
                                    ]
                                        .map((d) => DropdownMenuItem(
                                              value: d,
                                              child: Text(
                                                d,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF0A223B),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedDivision = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRequiredLabel('District / Area'),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFD8E4F0), width: 1),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedDistrict,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                        size: 18, color: Color(0xFF4C5D70)),
                                    items: [
                                      'Mumbai City',
                                      'Mumbai Suburban',
                                      'Thane',
                                      'Pune',
                                    ]
                                        .map((d) => DropdownMenuItem(
                                              value: d,
                                              child: Text(
                                                d,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: Color(0xFF0A223B),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedDistrict = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildRequiredLabel('Postal Code'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required field' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // CARD 3: Tax & Regulatory Identifiers (with GST & PAN badge)
                _buildCardSection(
                  icon: Icons.badge_outlined,
                  title: 'Tax & Regulatory Identifiers',
                  badge: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8D2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'GST & PAN',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF755B27),
                      ),
                    ),
                  ),
                  children: [
                    _buildRequiredLabel('Trade License Number'),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _tradeLicenseController,
                      suffixIcon: Icons.description_outlined,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Issued by respective City Corporation / Union Parishad.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4C5D70),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRequiredLabel('e-TIN (12-Digit Tax Identifier)'),
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 13, color: Color(0xFF285688)),
                            SizedBox(width: 4),
                            Text(
                              'Auto-verified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF285688),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: _tinController,
                      suffixIcon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),

                    // GSTIN Registered toggle card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD8E4F0), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GSTIN Registered',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF072138),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Business Identification Number',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF55697F),
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isBinRegistered,
                                onChanged: (val) {
                                  setState(() {
                                    _isBinRegistered = val;
                                  });
                                },
                                activeThumbColor: Colors.white,
                                activeTrackColor: const Color(0xFF465677),
                              ),
                            ],
                          ),
                          if (_isBinRegistered) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF3FC),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextFormField(
                                controller: _binController,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF072138),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          const Text(
                            'Required for B2B enterprise tier and automated corporate deduction certificates.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF55697F),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Note banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F0FE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDE3FA), width: 1),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Color(0xFF24446A),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your draft is automatically synchronized with your seller vault. Merchant screening is executed strictly adhering to India Digital Commerce Operation Guidelines 2021.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.45,
                            color: Color(0xFF274465),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Primary Button: Continue to Document Verification ->
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueToVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03142E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shadowColor: const Color(0xFF03142E).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue to Document Verification',
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
                ),
                const SizedBox(height: 14),

                // Secondary Button: Save Draft & Complete Later
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Draft saved successfully to seller vault'),
                          backgroundColor: Color(0xFF03253B),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bookmark_border_rounded,
                      size: 16,
                      color: Color(0xFF072138),
                    ),
                    label: const Text(
                      'Save Draft & Complete Later',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF072138),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required IconData icon,
    required String title,
    Widget? badge,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2EDF8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF072138)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072138),
                  ),
                ),
              ),
              ?badge,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF072138),
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureTile({
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = _selectedStructure == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStructure = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B70BC) : const Color(0xFFD8E4F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF4C5D70)),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF072138),
                  ),
                ),
              ],
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 16,
              color: isSelected ? const Color(0xFF3B5B84) : const Color(0xFF90A3B5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    IconData? suffixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD8E4F0), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF072138),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, size: 18, color: const Color(0xFF4C5D70))
              : null,
        ),
      ),
    );
  }
}
