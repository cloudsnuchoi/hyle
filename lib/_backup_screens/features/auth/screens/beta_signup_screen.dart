import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class BetaSignupScreen extends ConsumerStatefulWidget {
  const BetaSignupScreen({super.key});

  @override
  ConsumerState<BetaSignupScreen> createState() => _BetaSignupScreenState();
}

class _BetaSignupScreenState extends ConsumerState<BetaSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _createBetaAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      // 베타테스트용 임시 이메일과 비밀번호 생성
      final email = '$username@beta.hyle.test';
      final password = 'Beta2025!$username';

      // TODO: Replace with Supabase auth
      // For now, use Supabase auth directly
      final supabase = SupabaseService().client;
      
      // Sign up with Supabase
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      // Sign in
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$username님 환영합니다! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingXL,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.rocket_launch,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpacing.verticalGapXL,
                    
                    // 타이틀
                    Text(
                      'Hyle Beta',
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      '베타 테스트에 오신 것을 환영합니다!',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.verticalGapXL,
                    
                    // 사용자명 입력
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: '사용자명',
                        hintText: '원하는 닉네임을 입력하세요',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.gray50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '사용자명을 입력해주세요';
                        }
                        if (value.length < 3) {
                          return '3자 이상 입력해주세요';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                          return '영문, 숫자, 언더바만 사용 가능합니다';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.verticalGapLG,
                    
                    // 베타 안내
                    Container(
                      padding: AppSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          AppSpacing.horizontalGapSM,
                          Expanded(
                            child: Text(
                              '베타 테스트 계정은 임시 계정입니다.\n정식 출시 시 데이터가 초기화될 수 있습니다.',
                              style: AppTypography.caption.copyWith(
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.verticalGapXL,
                    
                    // 시작 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createBetaAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                '베타 테스트 시작하기',
                                style: AppTypography.button.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    AppSpacing.verticalGapMD,
                    
                    // 기존 계정 로그인
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        '이미 계정이 있으신가요?',
                        style: AppTypography.body.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}