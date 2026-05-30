import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../../shared/widgets/high_contrast_button.dart';

/// Gorgeous visual Account Settings Screen for both Buyers and Sellers.
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authCtrl = GetIt.I<AuthController>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _countryCtrl;

  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _vaultSettlements = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = _authCtrl.currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: '+234 810 293 8840'); // Prefilled mockup data
    _countryCtrl = TextEditingController(text: 'Nigeria');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Simulate persistent state save
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isSaving = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Profile settings updated successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    });
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
          'Account Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // SECTION 1: PERSONAL INFORMATION
              _buildSectionHeader('PERSONAL PARTICULAR DETAILS'),
              const SizedBox(height: 8),
              _buildCardGroup([
                _buildLabel('FULL ACCOUNT NAME'),
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: _inputDecoration('Full Name'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('EMAIL ADDRESS'),
                TextFormField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: _inputDecoration('Email Address'),
                  validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'Invalid email' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('TELEPHONE NUMBER'),
                TextFormField(
                  controller: _phoneCtrl,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: _inputDecoration('Phone Number'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('COUNTRY / GEOLOCATION'),
                TextFormField(
                  controller: _countryCtrl,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: _inputDecoration('Country'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ]),
              const SizedBox(height: 24),

              // SECTION 2: COMMUNICATIONS
              _buildSectionHeader('SYSTEM COMMUNICATIONS'),
              const SizedBox(height: 8),
              _buildCardGroup([
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Notify about transaction updates instantly',
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 24, color: AppColors.border),
                _buildSwitchTile(
                  title: 'Email Alerts',
                  subtitle: 'Receive settlement confirmations and logs',
                  value: _emailAlerts,
                  onChanged: (val) => setState(() => _emailAlerts = val),
                ),
                const Divider(height: 24, color: AppColors.border),
                _buildSwitchTile(
                  title: 'Vault Status Mails',
                  subtitle: 'Direct notifications for escrow locking and releases',
                  value: _vaultSettlements,
                  onChanged: (val) => setState(() => _vaultSettlements = val),
                ),
              ]),
              const SizedBox(height: 36),

              // SAVE DETAILS ACTION
              if (_isSaving)
                const Center(
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                )
              else
                HighContrastButton(
                  text: 'SAVE PROFILE SETTINGS',
                  icon: Icons.save_outlined,
                  onPressed: _saveSettings,
                ),
              const SizedBox(height: 48),
            ],
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: Colors.black,
          activeTrackColor: Colors.black26,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
