import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dentconnect_app/features/auth/providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String role;

  const OtpScreen({super.key, required this.role});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;
  String? _verificationId;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _verifyAndLogin(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message ?? 'Verification failed';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6 || _verificationId == null) {
      setState(() => _errorMessage = 'Enter the 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    await _verifyAndLogin(credential);
  }

  Future<void> _verifyAndLogin(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final token = await userCredential.user!.getIdToken();

      await ref.read(authProvider.notifier).loginWithFirebaseToken(
            token!,
            role: widget.role,
            phone: _phoneController.text.trim(),
          );

      if (!mounted) return;
      final state = ref.read(authProvider);
      if (state.error != null) {
        setState(() {
          _isLoading = false;
          _errorMessage = state.error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone Verification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _codeSent
                  ? 'Enter the 6-digit code sent to your phone'
                  : 'Enter your phone number to receive an OTP',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 36),
            if (!_codeSent) ...[
              _buildLabel('Phone Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('+91 9876543210'),
              ),
              const SizedBox(height: 24),
              _buildPrimaryButton(
                label: 'Send OTP',
                onPressed: _isLoading ? null : _sendOtp,
              ),
            ] else ...[
              _buildLabel('6-Digit OTP'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: Colors.white,
                  letterSpacing: 8,
                  fontSize: 20,
                ),
                decoration: _inputDecoration('000000'),
              ),
              const SizedBox(height: 24),
              _buildPrimaryButton(
                label: 'Verify OTP',
                onPressed: _isLoading ? null : _verifyOtp,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _codeSent = false),
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                ),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF2196F3)),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3)),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
