import 'package:flutter/material.dart';
import 'application_status.dart';
import 'seller_top_bar.dart';
import '../core/network/api_client.dart';
import '../core/network/token_storage.dart';

class DocumentVerification extends StatefulWidget {
  final Map<String, dynamic>? registrationData;

  const DocumentVerification({
    super.key,
    this.registrationData,
  });

  @override
  State<DocumentVerification> createState() => _DocumentVerificationState();
}

class _DocumentVerificationState extends State<DocumentVerification> {
  final ApiClient _apiClient = ApiClient();
  bool _isSubmitting = false;

  // Simulated upload states
  bool _tradeLicenseUploaded = true;
  bool _nationalIdUploaded = true;
  bool _bankProofUploaded = false;

  Future<void> _submitApplication() async {
    if (_isSubmitting) return;

    final regData = widget.registrationData;
    if (regData != null && regData.isNotEmpty) {
      setState(() => _isSubmitting = true);
      try {
        final res = await _apiClient.post(
          '/buddy/auth/register-seller',
          body: {
            'full_name': regData['full_name'] ?? 'Your name',
            'email': regData['email'] ?? 'Your seller email',
            'password': regData['password'] ?? '',
            'store_name': regData['store_name'] ?? 'Your store name',
            'phone': regData['phone'] ?? 'Your phone number',
            'category': regData['category'] ?? 'Consumer Electronics & Tech Accessories',
            'trade_license': regData['trade_license'] ?? '',
            'tin_number': regData['tin_number'] ?? '',
            'address': regData['address'] ?? 'Your business address',
            'city': regData['city'] ?? 'Mumbai',
            'pincode': regData['pincode'] ?? '',
          },
        );

        if (mounted) {
          setState(() => _isSubmitting = false);
          if (res.isSuccess && res.data != null) {
            final data = res.data as Map<String, dynamic>;
            final token = data['token'] as String?;
            if (token != null && token.isNotEmpty) {
              await TokenStorage().saveToken(token);
            }

            final appRef = data['application']?['app_number']?.toString() ?? 'TKB-APP-LIVE';
            final store = data['store']?['store_name']?.toString() ?? regData['store_name']?.toString();

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApplicationStatus(
                  refNumber: appRef,
                  businessName: store,
                  submittedAt: 'Just now',
                ),
              ),
            );
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res.message.isNotEmpty ? res.message : 'Registration error. Continuing to status view.'),
                backgroundColor: const Color(0xFFC0392B),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationStatus(
          refNumber: regData?['app_number']?.toString() ?? 'TKB-APP-2024-89241',
          businessName: regData?['store_name']?.toString() ?? 'Your store name',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFE),
      appBar: SellerTopBar(
        title: 'Document Verification',
        subtitle: 'Step 3 of 4',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'STEP 3 OF 4 • DOCUMENT\nVERIFICATION',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF28384C),
                        letterSpacing: 0.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6ECFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '75%\nComplete',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E4B75),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar — 3 of 4 filled
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B5070),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B5070),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B5070),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
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
              const SizedBox(height: 22),

              // Title: Verify Business Documents
              const Text(
                'Verify Business\nDocuments',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF072138),
                  letterSpacing: -0.3,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Upload clear credentials to expedite merchant clearance within 24 hours under the India Digital Commerce Directives (2021).',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF38495B),
                ),
              ),
              const SizedBox(height: 20),

              // Accepted Formats Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD2E8FB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Color(0xFF1E4B75),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accepted Formats: PDF, JPG, PNG (Max 5MB)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A2038),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ensure all four corners of the document are visible. Text, seal, and authorized signatures must remain sharp and free of screen glare.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFF3D5269),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // DOCUMENT 1: Valid Trade License *Required
              _buildDocumentCard(
                icon: Icons.description_outlined,
                label: 'Valid Trade Lic...',
                required: true,
                statusLabel: 'Verified Format',
                statusColor: const Color(0xFF2E7D32),
                statusBgColor: const Color(0xFFE8F5E9),
                isUploaded: _tradeLicenseUploaded,
                filename: 'Trade_License_GSTIN.pdf',
                fileSize: '1.8 MB • Uploaded',
                sublabel: 'City Corporation / ...',
                onReplace: () {},
                showViewButton: true,
                onUpload: () {
                  setState(() {
                    _tradeLicenseUploaded = true;
                  });
                },
              ),
              const SizedBox(height: 14),

              // DOCUMENT 2: National ID / *Required
              _buildDocumentCard(
                icon: Icons.badge_outlined,
                label: 'Aadhaar / PAN Card',
                required: true,
                statusLabel: 'Uploaded',
                statusColor: const Color(0xFF1565C0),
                statusBgColor: const Color(0xFFE3F2FD),
                isUploaded: _nationalIdUploaded,
                filename: 'Identity_Document_Aadhaar_PAN.pdf',
                fileSize: '2.4 MB • Ready',
                sublabel: 'Authorized Signatory',
                progressLabel: '100% Upload Complete',
                progressTrailingLabel: 'Enquiry Verified',
                onReplace: () {},
                showViewButton: false,
                onUpload: () {
                  setState(() {
                    _nationalIdUploaded = true;
                  });
                },
              ),
              const SizedBox(height: 14),

              // DOCUMENT 3: Bank Account Proof *Required — Pending Action
              _buildDocumentCard(
                icon: Icons.account_balance_outlined,
                label: 'Bank Account Proof',
                required: true,
                statusLabel: 'Pending Action',
                statusColor: const Color(0xFF7B4B00),
                statusBgColor: const Color(0xFFFFF3E0),
                isUploaded: _bankProofUploaded,
                sublabel: 'Cancelled Cheque or 3...',
                onReplace: null,
                showViewButton: false,
                uploadHintTitle: 'Upload Bank Verification Document',
                uploadHintBody:
                    'Cheque leaf or statement displaying Account Name, Account Number, and 11-character IFSC Code.',
                uploadHintTrailing: 'Tap to browse or drop file (Max 5MB)',
                onUpload: () {
                  setState(() {
                    _bankProofUploaded = true;
                  });
                },
              ),
              const SizedBox(height: 14),

              // DOCUMENT 4: GSTIN / PAN Tax Registration (Optional) — Auto-Linked
              _buildEtinCard(),
              const SizedBox(height: 20),

              // AES-256 Encryption notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCCE3FA), width: 0.8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF1E4B75)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Documents are encrypted with AES-256 and stored in compliance with local India banking regulations and ICT Security Directives.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: Color(0xFF274465),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Review & Submit Application ->
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03142E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Review & Submit Application',
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
              const SizedBox(height: 14),

              // Save Draft & Exit
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Draft saved. You can continue later.'),
                        backgroundColor: Color(0xFF03253B),
                      ),
                    );
                  },
                  child: const Text(
                    'Save Draft & Exit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF38495B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required String label,
    required bool required,
    required String statusLabel,
    required Color statusColor,
    required Color statusBgColor,
    required bool isUploaded,
    String? filename,
    String? fileSize,
    required String sublabel,
    String? progressLabel,
    String? progressTrailingLabel,
    VoidCallback? onReplace,
    required bool showViewButton,
    String? uploadHintTitle,
    String? uploadHintBody,
    String? uploadHintTrailing,
    required VoidCallback onUpload,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E8F7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 17, color: const Color(0xFF3A4E65)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A2038),
                              ),
                            ),
                            if (required)
                              const Text(
                                ' *Required',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          sublabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5A6B7C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Uploaded File Row
          if (isUploaded && filename != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4E5F8), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 18, color: Color(0xFF3A4E65)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filename,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A2038),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            fileSize ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5A6B7C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showViewButton)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCEDFD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A3F66),
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Color(0xFF5A6B7C)),
                  ],
                ),
              ),
            ),
            if (progressLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressLabel,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF5A6B7C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (progressTrailingLabel != null)
                      Text(
                        progressTrailingLabel,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF285688),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
          ],

          // Upload zone (when not uploaded)
          if (!isUploaded && uploadHintTitle != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: onUpload,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFB0CDE7),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.upload_file_outlined,
                          size: 26, color: Color(0xFF4C7DA8)),
                      const SizedBox(height: 8),
                      Text(
                        uploadHintTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A2038),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        uploadHintBody ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: Color(0xFF4C5D70),
                        ),
                      ),
                      if (uploadHintTrailing != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 12, color: Color(0xFF3A7FA8)),
                            const SizedBox(width: 4),
                            Text(
                              uploadHintTrailing,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF3A7FA8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Replace Document link
          if (onReplace != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 12),
              child: GestureDetector(
                onTap: onReplace,
                child: const Row(
                  children: [
                    Icon(Icons.replay_rounded, size: 13, color: Color(0xFF285688)),
                    SizedBox(width: 4),
                    Text(
                      'Replace Document',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF285688),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 12),
              child: GestureDetector(
                onTap: onUpload,
                child: const Row(
                  children: [
                    Icon(Icons.replay_rounded, size: 13, color: Color(0xFF285688)),
                    SizedBox(width: 4),
                    Text(
                      'Replace Document',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF285688),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEtinCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E8F7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.article_outlined, size: 17, color: Color(0xFF3A4E65)),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GSTIN / PAN Tax Registration',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A2038),
                        ),
                      ),
                      Text(
                        'Optional',
                        style: TextStyle(fontSize: 11, color: Color(0xFF5A6B7C)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Auto-Linked',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Unlocks Tier-1 Unlim...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A2038),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.verified_outlined, size: 14, color: Color(0xFF1E4B75)),
              SizedBox(width: 6),
              Text(
                'GST Central Records: Verified',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF374E65)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF2E7D32)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Matched with Trade License holder',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF374E65)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285688),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF285688),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
