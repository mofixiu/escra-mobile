import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';

/// Gorgeous high-fidelity Security and PIN Management Screen.
class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  bool _faceIdEnabled = true;
  bool _pinOnStartup = false;
  bool _isSavingPin = false;

  void _updatePin() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSavingPin = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isSavingPin = false;
        _currentPinCtrl.clear();
        _newPinCtrl.clear();
        _confirmPinCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Transaction PIN updated successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _currentPinCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
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
          'Security & PIN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // SECTION 1: CHANGE TRANSACTION PIN
            _buildSectionHeader('TRANSACTION VAULT SECURITY PIN'),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: _buildCardGroup([
                _buildLabel('CURRENT 4-DIGIT PIN'),
                TextFormField(
                  controller: _currentPinCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 8),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: _inputDecoration('••••'),
                  validator: (v) => (v == null || v.length != 4) ? 'Must be 4 digits' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('NEW 4-DIGIT PIN'),
                TextFormField(
                  controller: _newPinCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 8),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: _inputDecoration('••••'),
                  validator: (v) => (v == null || v.length != 4) ? 'Must be 4 digits' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('CONFIRM NEW 4-DIGIT PIN'),
                TextFormField(
                  controller: _confirmPinCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 8),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: _inputDecoration('••••'),
                  validator: (v) {
                    if (v == null || v.length != 4) return 'Must be 4 digits';
                    if (v != _newPinCtrl.text) return 'PINs do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_isSavingPin)
                  const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                else
                  HighContrastButton(
                    text: 'UPDATE TRANSACTION PIN',
                    icon: Icons.lock_open_rounded,
                    onPressed: _updatePin,
                  ),
              ]),
            ),
            const SizedBox(height: 28),

            // SECTION 2: BIOMETRICS & STARTUP
            _buildSectionHeader('BIOMETRICS & HARDWARE SIGN-IN'),
            const SizedBox(height: 8),
            _buildCardGroup([
              _buildSwitchTile(
                title: 'Face ID / Touch ID Biometrics',
                subtitle: 'Unlock and approve transactions instantly',
                value: _faceIdEnabled,
                onChanged: (val) => setState(() => _faceIdEnabled = val),
              ),
              const Divider(height: 24, color: AppColors.border),
              _buildSwitchTile(
                title: 'PIN on Application Startup',
                subtitle: 'Mandatory escrow shield lock on launch',
                value: _pinOnStartup,
                onChanged: (val) => setState(() => _pinOnStartup = val),
              ),
            ]),
            const SizedBox(height: 28),

            // SECTION 3: DEVICE SESSIONS
            _buildSectionHeader('ACTIVE SYSTEM AUTHORIZED SESSIONS'),
            const SizedBox(height: 8),
            _buildCardGroup([
              _buildDeviceSessionTile(
                icon: Icons.phone_android_rounded,
                deviceName: 'Apple iPhone 15 Pro Max',
                location: 'Lagos, Nigeria • Active Now',
                isCurrent: true,
              ),
              const Divider(height: 20, color: AppColors.border),
              _buildDeviceSessionTile(
                icon: Icons.laptop_mac_rounded,
                deviceName: 'MacBook Pro 16" (Safari)',
                location: 'London, UK • 2 hours ago',
                isCurrent: false,
              ),
              const Divider(height: 20, color: AppColors.border),
              _buildDeviceSessionTile(
                icon: Icons.language_rounded,
                deviceName: 'ESCRA Desktop Merchant API Portal',
                location: 'Paris, France • May 28, 2026',
                isCurrent: false,
              ),
            ]),
            const SizedBox(height: 48),
          ],
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
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 16, letterSpacing: 8),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      counterText: '',
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
          activeThumbColor: Colors.black,
          activeTrackColor: Colors.black26,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDeviceSessionTile({
    required IconData icon,
    required String deviceName,
    required String location,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: TextStyle(
                  fontSize: 11,
                  color: isCurrent ? Colors.green.shade700 : AppColors.secondary,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (!isCurrent)
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
            onPressed: () {},
          ),
      ],
    );
  }
}
