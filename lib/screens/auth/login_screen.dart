/// Login / Sign-up screen with Google and email authentication.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../utils/security.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithGoogle();
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      if (_isLogin) {
        await auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await auth.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (e) {
      setState(() {
        _error = _isLogin
            ? 'Invalid email or password.'
            : 'Registration failed. Try a different email.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email first.');
      return;
    }
    try {
      await ref.read(authServiceProvider).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (e) {
      setState(() => _error = 'Could not send reset email.');
    }
  }

  /// Skip login — use demo mode with local-only data
  void _skipLogin() {
    ref.read(authSkippedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo & title
              Icon(Icons.fitness_center,
                  size: 56, color: AppColors.accent),
              const SizedBox(height: 16),
              Text('FitAI Coach',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.accent,
                    fontSize: 36,
                  )),
              const SizedBox(height: 8),
              Text('AI-powered personal fitness trainer',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 48),

              // Google sign-in
              _GoogleSignInButton(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: AppTextStyles.bodySmall),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 16),

              // Email form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      style: AppTextStyles.body,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter email';
                        if (!InputSanitizer.isValidEmail(v.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                      ),
                      style: AppTextStyles.body,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        if (v.length < 6) return 'Min 6 characters';
                        if (v.length > 128) return 'Max 128 characters';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (_isLogin) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handlePasswordReset,
                    child: Text('Forgot password?',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.accent)),
                  ),
                ),
              ] else
                const SizedBox(height: 16),

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Text(_error!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 12),
              ],

              // Submit button
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: AppColors.accent),
                      ))
                  : AccentButton(
                      label: _isLogin ? 'Sign In' : 'Create Account',
                      onPressed: _handleEmailAuth,
                    ),
              const SizedBox(height: 12),

              // Toggle login / signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Don't have an account?"
                        : 'Already have an account?',
                    style: AppTextStyles.bodySmall,
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                      _error = null;
                    }),
                    child: Text(
                      _isLogin ? 'Sign Up' : 'Sign In',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Skip login
              TextButton(
                onPressed: _skipLogin,
                child: Text('Skip — try with demo data',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiary)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _GoogleSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.g_mobiledata, size: 28, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text('Continue with Google',
              style: AppTextStyles.body),
        ],
      ),
    );
  }
}
