import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dentconnect_app/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _roleLabel =>
      widget.role == 'DENTIST' ? 'Dentist' : 'Clinic Owner';

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          widget.role,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    final state = ref.read(authProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    await ref
        .read(authProvider.notifier)
        .loginWithGoogle(selectedRole: widget.role);
    if (!mounted) return;
    setState(() => _isLoading = false);
    final state = ref.read(authProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red.shade700,
        ),
      );
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
          onPressed: () => context.go('/role-selection'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in as $_roleLabel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Google Sign In
            _SocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Continue with Google',
              onTap: _isLoading ? null : _loginWithGoogle,
            ),
            const SizedBox(height: 12),

            // Phone OTP
            _SocialButton(
              icon: Icons.phone_rounded,
              label: 'Continue with Phone',
              onTap: _isLoading
                  ? null
                  : () => context.go('/otp?role=${widget.role}'),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                const Expanded(child: Divider(color: Colors.white24)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.white24)),
              ],
            ),
            const SizedBox(height: 24),

            // Email/Password Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Password too short';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loginWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () =>
                    context.go('/register?role=${widget.role}'),
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    children: const [
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            suffixIcon: suffixIcon,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
