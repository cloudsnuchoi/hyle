import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gap.dart';
import '../../../providers/auth_provider.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const ConfirmationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authStateProvider);
      final success = await authState.confirmSignUp(
        widget.email,
        _codeController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email confirmed! Please sign in.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error ?? 'Confirmation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement resend code functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirmation code resent!'),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gap.lg,
                Text(
                  'Confirm Your Email',
                  style: AppTypography.displaySmall.copyWith(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.md,
                Text(
                  'We sent a confirmation code to',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.xs,
                Text(
                  widget.email,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.xxl,
                CustomTextField(
                  controller: _codeController,
                  label: 'Confirmation Code',
                  hint: 'Enter 6-digit code',
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the confirmation code';
                    }
                    if (value.length != 6) {
                      return 'Code must be 6 digits';
                    }
                    return null;
                  },
                ),
                Gap.xl,
                CustomButton(
                  text: 'Confirm Email',
                  onPressed: _isLoading ? null : _confirmSignUp,
                  isLoading: _isLoading,
                ),
                Gap.md,
                TextButton(
                  onPressed: _isLoading ? null : _resendCode,
                  child: Text(
                    'Resend Code',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
                Gap.xxl,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Wrong email? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Go Back',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}