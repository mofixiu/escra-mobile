import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';
import '../../data/models/merchant_profile_store.dart';

/// Premium interactive Business Details Screen.
/// Supports inline toggles between View and Edit mode with validation and session updates.
class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final _profileStore = MerchantProfileStore();
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _rcController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _webController;
  late TextEditingController _addrController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileStore.businessName);
    _typeController = TextEditingController(text: _profileStore.businessType);
    _rcController = TextEditingController(text: _profileStore.rcNumber);
    _emailController = TextEditingController(text: _profileStore.supportEmail);
    _phoneController = TextEditingController(text: _profileStore.supportPhone);
    _webController = TextEditingController(text: _profileStore.website);
    _addrController = TextEditingController(text: _profileStore.address);
    _cityController = TextEditingController(text: _profileStore.city);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _rcController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _webController.dispose();
    _addrController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Simulate database update
    await Future.delayed(const Duration(milliseconds: 800));

    _profileStore.updateBusinessDetails(
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      rc: _rcController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      web: _webController.text.trim(),
      addr: _addrController.text.trim(),
      ct: _cityController.text.trim(),
    );

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Business Details updated successfully!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Business Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.black, size: 28),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 24),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset field controllers back to original store value
                  _nameController.text = _profileStore.businessName;
                  _typeController.text = _profileStore.businessType;
                  _rcController.text = _profileStore.rcNumber;
                  _emailController.text = _profileStore.supportEmail;
                  _phoneController.text = _profileStore.supportPhone;
                  _webController.text = _profileStore.website;
                  _addrController.text = _profileStore.address;
                  _cityController.text = _profileStore.city;
                });
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Header Info Card with animated editing indicator
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _isEditing ? Icons.edit_note_rounded : Icons.business_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'EDITING DETAILS' : 'BUSINESS PROFILE',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white54,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profileStore.businessName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Card 1: Corporate Details
            _buildSectionHeader('CORPORATE REGISTRATION'),
            const SizedBox(height: 8),
            _buildCardGroup([
              _buildDetailItem(
                label: 'Legal Business Name',
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              _buildDetailItem(
                label: 'Registration Type',
                controller: _typeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              _buildDetailItem(
                label: 'RC Number / ID',
                controller: _rcController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ]),
            const SizedBox(height: 24),

            // Card 2: Contact Details
            _buildSectionHeader('CONTACT INFORMATION'),
            const SizedBox(height: 8),
            _buildCardGroup([
              _buildDetailItem(
                label: 'Primary Support Email',
                controller: _emailController,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!val.contains('@')) return 'Invalid Email';
                  return null;
                },
              ),
              _buildDetailItem(
                label: 'Support Phone',
                controller: _phoneController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              _buildDetailItem(
                label: 'Official Website',
                controller: _webController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ]),
            const SizedBox(height: 24),

            // Card 3: Address Details
            _buildSectionHeader('CORPORATE HEADQUARTERS'),
            const SizedBox(height: 8),
            _buildCardGroup([
              _buildDetailItem(
                label: 'Physical Address',
                controller: _addrController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              _buildDetailItem(
                label: 'City / State',
                controller: _cityController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              _buildDetailItem(
                label: 'Country',
                controller: TextEditingController(text: _profileStore.country),
                enabledOverride: false, // Country is fixed for regulatory compliance
              ),
            ]),
            const SizedBox(height: 36),

            // Animated Save Action Button
            if (_isEditing)
              _isSaving
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    )
                  : HighContrastButton(
                      text: 'SAVE PROFILE CHANGES',
                      onPressed: _handleSave,
                    ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.secondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: AppColors.border),
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool enabledOverride = true,
  }) {
    final showEdit = _isEditing && enabledOverride;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: CrossFadeSwitcher(
        showSecond: showEdit,
        firstChild: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                controller.text,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        secondChild: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppColors.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller,
              validator: validator,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 1.2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple cross-fade utility to switch between View and Edit states elegantly.
class CrossFadeSwitcher extends StatelessWidget {
  final bool showSecond;
  final Widget firstChild;
  final Widget secondChild;

  const CrossFadeSwitcher({
    super.key,
    required this.showSecond,
    required this.firstChild,
    required this.secondChild,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: showSecond ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeIn,
    );
  }
}
