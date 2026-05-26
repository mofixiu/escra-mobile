import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';
import '../../data/models/user_model.dart';
import '../../domain/auth_controller.dart';

/// Clean high-contrast sign in / signup screen.
class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _transactionPinController = TextEditingController();

  bool _isSignUp = false;
  UserRole _selectedRole = UserRole.buyer;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _transactionPinController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please accept the Terms of Service to continue.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final authCtrl = GetIt.I<AuthController>();
    bool success;

    if (_isSignUp) {
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
      success = await authCtrl.signUp(
        fullName,
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );
    } else {
      success = await authCtrl.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (mounted) {
      if (success) {
        widget.onAuthSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authCtrl.errorMessage ?? 'Authentication failed.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
    final authCtrl = GetIt.I<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListenableBuilder(
                listenable: authCtrl,
                builder: (context, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Futuristic Premium Shield Icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12, width: 1.5),
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              size: 48,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ESCRA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Trustworthy Escrow Financial Transactions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Form container styled in Light Mode
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isSignUp ? 'Create your ESCRA Account' : 'Authenticate Identity',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (_isSignUp) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _firstNameController,
                                        style: const TextStyle(color: Colors.black, fontSize: 15),
                                        decoration: const InputDecoration(
                                          hintText: 'First Name',
                                          hintStyle: TextStyle(color: Colors.black38),
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        ),
                                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lastNameController,
                                        style: const TextStyle(color: Colors.black, fontSize: 15),
                                        decoration: const InputDecoration(
                                          hintText: 'Last Name',
                                          hintStyle: TextStyle(color: Colors.black38),
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        ),
                                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneController,
                                  style: const TextStyle(color: Colors.black, fontSize: 15),
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    hintText: 'Phone Number',
                                    hintStyle: TextStyle(color: Colors.black38),
                                    prefixIcon: Icon(Icons.phone_outlined, size: 20, color: Colors.black54),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.black, fontSize: 15),
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: TextStyle(color: Colors.black38),
                                  prefixIcon: Icon(Icons.email_outlined, size: 20, color: Colors.black54),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (!v.contains('@')) return 'Invalid email address';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.black, fontSize: 15),
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.black38),
                                  prefixIcon: Icon(Icons.lock_outlined, size: 20, color: Colors.black54),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                ),
                                validator: (v) => v == null || v.length < 4
                                    ? 'PIN must be at least 4 digits'
                                    : null,
                              ),
                              if (_isSignUp) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _transactionPinController,
                                  style: const TextStyle(color: Colors.black, fontSize: 15, letterSpacing: 6),
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  decoration: const InputDecoration(
                                    hintText: '4-Digit Transaction PIN',
                                    hintStyle: TextStyle(color: Colors.black38),
                                    prefixIcon: Icon(Icons.lock_outline, size: 20, color: Colors.black54),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                    counterText: '',
                                  ),
                                  validator: (v) => v == null || v.length != 4 ? 'Enter 4 digits' : null,
                                ),
                              ],
                              const SizedBox(height: 24),

                              if (_isSignUp) ...[
                                const Text(
                                  'Choose Platform Role',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = UserRole.buyer),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _selectedRole == UserRole.buyer
                                                ? Colors.black
                                                : Colors.white,
                                            border: Border.all(
                                              color: _selectedRole == UserRole.buyer
                                                  ? Colors.black
                                                  : Colors.black12,
                                              width: 1.2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'BUYER',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: _selectedRole == UserRole.buyer
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = UserRole.seller),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _selectedRole == UserRole.seller
                                                ? Colors.black
                                                : Colors.white,
                                            border: Border.all(
                                              color: _selectedRole == UserRole.seller
                                                  ? Colors.black
                                                  : Colors.black12,
                                              width: 1.2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'SELLER',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: _selectedRole == UserRole.seller
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: _acceptedTerms,
                                      activeColor: Colors.black,
                                      onChanged: (value) {
                                        setState(() => _acceptedTerms = value ?? false);
                                      },
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: RichText(
                                          text: const TextSpan(
                                            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.3),
                                            children: [
                                              TextSpan(text: 'I agree to the '),
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(text: ' and acknowledge the '),
                                              TextSpan(
                                                text: 'Security Protocol',
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(text: '.'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],

                              if (authCtrl.isLockedOut) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, color: AppColors.error, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Security lockout: Try again in ${authCtrl.lockoutSecondsRemaining}s.',
                                          style: const TextStyle(
                                            color: AppColors.error,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              HighContrastButton(
                                text: _isSignUp ? 'REGISTER & SECURE ACCOUNT' : 'AUTHORISE IDENTITY',
                                onPressed: authCtrl.isLockedOut ? null : _submit,
                                isLoading: authCtrl.isLoading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Switch mode button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _formKey.currentState?.reset();
                              _acceptedTerms = false;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already registered? Authorise here'
                                : "Don't have a secure identity? Register here",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_isSignUp) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Mock Accounts:\n• buyer@escra.com (seeded with ₦750,000)\n• seller@escra.com (starts with ₦0)\nPIN / Password: 1234',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          )
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
