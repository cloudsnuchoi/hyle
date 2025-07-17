import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate login
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.verticalGapXL,
                
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                
                AppSpacing.verticalGapXL,
                
                // Title
                Text(
                  'Welcome Back!',
                  style: AppTypography.display,
                ).animate().fadeIn(delay: 200.ms),
                
                AppSpacing.verticalGapSM,
                
                Text(
                  'Log in to continue your learning journey',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                
                AppSpacing.verticalGapXL,
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
                
                AppSpacing.verticalGapMD,
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible 
                        ? Icons.visibility_off_outlined 
                        : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),
                
                AppSpacing.verticalGapSM,
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password reset coming soon!')),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                AppSpacing.verticalGapLG,
                
                // Login Button
                CustomButton(
                  text: 'Log In',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                
                AppSpacing.verticalGapXL,
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/signup');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}