import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class BetaResetPasswordScreen extends ConsumerStatefulWidget {
  const BetaResetPasswordScreen({super.key});

  @override
  ConsumerState<BetaResetPasswordScreen> createState() => _BetaResetPasswordScreenState();
}

class _BetaResetPasswordScreenState extends ConsumerState<BetaResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _secretCodeController = TextEditingController();
  bool _showNewPassword = false;
  String _newPassword = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _secretCodeController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final secretCode = _secretCodeController.text.trim();
    
    // 베타테스트용 간단한 검증
    // 실제로는 서버에서 처리해야 함
    if (secretCode == 'BETA2025') {
      // 새 비밀번호 생성
      setState(() {
        _newPassword = 'Beta2025!${username}_${DateTime.now().millisecondsSinceEpoch % 1000}';
        _showNewPassword = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('잘못된 시크릿 코드입니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('베타 비밀번호 재설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
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
                    // 아이콘
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 50,
                        color: Colors.orange,
                      ),
                    ),
                    AppSpacing.verticalGapXL,
                    
                    // 안내 메시지
                    Text(
                      '비밀번호 재설정',
                      style: AppTypography.headlineSmall,
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      '베타 테스트 시크릿 코드를 입력하세요',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalGapXL,
                    
                    if (!_showNewPassword) ...[
                      // 사용자명 입력
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: '사용자명',
                          hintText: '가입시 사용한 사용자명',
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
                          return null;
                        },
                      ),
                      AppSpacing.verticalGapMD,
                      
                      // 시크릿 코드 입력
                      TextFormField(
                        controller: _secretCodeController,
                        decoration: InputDecoration(
                          labelText: '시크릿 코드',
                          hintText: '베타 테스트 시크릿 코드',
                          prefixIcon: const Icon(Icons.key),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.gray50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '시크릿 코드를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      AppSpacing.verticalGapSM,
                      
                      // 힌트
                      Text(
                        '💡 힌트: 디스코드나 슬랙에서 확인하세요',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppSpacing.verticalGapXL,
                      
                      // 재설정 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '비밀번호 재설정',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ] else ...[
                      // 새 비밀번호 표시
                      Container(
                        padding: AppSpacing.paddingLG,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            AppSpacing.verticalGapMD,
                            Text(
                              '새 비밀번호가 생성되었습니다!',
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.green,
                              ),
                            ),
                            AppSpacing.verticalGapMD,
                            Container(
                              padding: AppSpacing.paddingMD,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                _newPassword,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            AppSpacing.verticalGapSM,
                            Text(
                              '이 비밀번호를 안전한 곳에 저장하세요',
                              style: AppTypography.caption.copyWith(
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalGapXL,
                      
                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '로그인하러 가기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    
                    AppSpacing.verticalGapMD,
                    
                    // 다른 방법 안내
                    Card(
                      color: Colors.blue.withOpacity(0.1),
                      child: Padding(
                        padding: AppSpacing.paddingMD,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.support_agent, color: Colors.blue, size: 20),
                                AppSpacing.horizontalGapSM,
                                Text(
                                  '다른 방법',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.verticalGapSM,
                            Text(
                              '• 디스코드/슬랙에서 관리자에게 문의\n'
                              '• 새 계정으로 다시 가입 (/beta)\n'
                              '• 관리자가 AWS 콘솔에서 직접 재설정',
                              style: AppTypography.caption.copyWith(
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
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