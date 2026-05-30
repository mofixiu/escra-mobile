import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';
import '../../../profile/data/models/merchant_profile_store.dart';
import '../../data/models/user_model.dart';
import '../../domain/auth_controller.dart';

/// State-of-the-art seller verification and document upload screen.
class SellerOnboardingScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String password;
  final VoidCallback onAuthSuccess;

  const SellerOnboardingScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.password,
    required this.onAuthSuccess,
  });

  @override
  State<SellerOnboardingScreen> createState() => _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState extends State<SellerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _rcNumberCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _docType = 'CAC Certificate';
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _uploadComplete = false;
  String? _uploadedFileName;

  @override
  void initState() {
    super.initState();
    // Default pre-fill business name based on owner name
    _businessNameCtrl.text = '${widget.fullName} Enterprises';
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _rcNumberCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _simulateUpload() {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadComplete = false;
      _uploadedFileName = _docType == 'CAC Certificate' ? 'cac_certificate_registration.pdf' : 'passport_verification_page.jpg';
    });

    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _uploadProgress += 0.1;
        if (_uploadProgress >= 1.0) {
          _uploadProgress = 1.0;
          _isUploading = false;
          _uploadComplete = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _submitKYC() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_uploadComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload the required verification document.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final authCtrl = GetIt.I<AuthController>();
    final profileStore = MerchantProfileStore();

    // Call Sign Up
    final success = await authCtrl.signUp(
      widget.fullName,
      widget.email,
      widget.password,
      UserRole.seller,
    );

    if (mounted) {
      if (success) {
        profileStore.updateBusinessDetails(
          name: _businessNameCtrl.text.trim(),
          type: 'Private Limited Company',
          rc: _rcNumberCtrl.text.trim(),
          email: widget.email,
          phone: '',
          web: '',
          addr: _addressCtrl.text.trim(),
          ct: 'Lagos',
        );

        // Pop onboarding screen and call auth success callback
        Navigator.pop(context);
        widget.onAuthSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.errorMessage ?? 'Onboarding registration failed.', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/logos/escralogonobackground.png',
          height: 20,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Merchant Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verify business documents to activate your seller terminal.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // SECTION 1: BUSINESS PARTICULARS
                _buildSectionHeader('BUSINESS PARTICULARS'),
                const SizedBox(height: 8),
                _buildCardGroup([
                  _buildLabel('REGISTERED BUSINESS / TRADE NAME'),
                  TextFormField(
                    controller: _businessNameCtrl,
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputDecoration('e.g. Apex Tech Ltd'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('RC / BUSINESS REGISTRATION NUMBER'),
                  TextFormField(
                    controller: _rcNumberCtrl,
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputDecoration('e.g. RC-1192839'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('CORPORATE HEADQUARTERS ADDRESS'),
                  TextFormField(
                    controller: _addressCtrl,
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    decoration: _inputDecoration('Physical office or operational facility address'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ]),
                const SizedBox(height: 24),

                // SECTION 2: VERIFICATION DOCUMENTATION
                _buildSectionHeader('IDENTITY & CORPORATE FILINGS'),
                const SizedBox(height: 8),
                _buildCardGroup([
                  _buildLabel('VERIFICATION DOCUMENT TYPE'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _docType,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        menuMaxHeight: 300,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                        style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                        items: const [
                          DropdownMenuItem(value: 'CAC Certificate', child: Text('CAC Certificate of Incorporation')),
                          DropdownMenuItem(value: 'Government ID', child: Text('National Passport / NIN ID Card')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _docType = val;
                              _uploadComplete = false;
                              _uploadedFileName = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Interactive uploader widget
                  _buildUploaderWidget(),
                ]),
                const SizedBox(height: 36),

                // SUBMIT GATEWAY
                HighContrastButton(
                  text: 'COMPLETE ONBOARDING',
                  icon: Icons.shield_outlined,
                  onPressed: _submitKYC,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.secondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: AppColors.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
    );
  }

  Widget _buildUploaderWidget() {
    if (_isUploading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              'Uploading document... ${( _uploadProgress * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                color: Colors.black,
                backgroundColor: Colors.black12,
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    }

    if (_uploadComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Successful',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _uploadedFileName ?? 'file_uploaded.pdf',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _uploadComplete = false;
                  _uploadedFileName = null;
                });
              },
              child: const Text('Change', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _simulateUpload,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              'Attach Corporate Filing File',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select PDF, PNG or JPG (Max 15MB)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
