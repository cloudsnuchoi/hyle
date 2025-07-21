import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class BetaAdminScreen extends ConsumerStatefulWidget {
  const BetaAdminScreen({super.key});

  @override
  ConsumerState<BetaAdminScreen> createState() => _BetaAdminScreenState();
}

class _BetaAdminScreenState extends ConsumerState<BetaAdminScreen> {
  // 베타 테스트 계정 목록 (하드코딩)
  final List<Map<String, String>> betaAccounts = [
    {'username': 'beta1', 'email': 'beta1@beta.hyle.test', 'password': 'Beta2025!beta1'},
    {'username': 'beta2', 'email': 'beta2@beta.hyle.test', 'password': 'Beta2025!beta2'},
    {'username': 'beta3', 'email': 'beta3@beta.hyle.test', 'password': 'Beta2025!beta3'},
    {'username': 'tester1', 'email': 'tester1@beta.hyle.test', 'password': 'Beta2025!tester1'},
    {'username': 'tester2', 'email': 'tester2@beta.hyle.test', 'password': 'Beta2025!tester2'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('베타 테스트 계정 관리'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 카드
            Card(
              color: Colors.amber.withOpacity(0.1),
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    AppSpacing.horizontalGapMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AWS Cognito 콘솔 접속 방법',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.verticalGapSM,
                          Text(
                            '1. AWS Console 로그인\n'
                            '2. Cognito → 사용자 풀 선택\n'
                            '3. "사용자" 탭에서 계정 관리\n'
                            '4. 비밀번호 재설정, 계정 삭제 등 가능',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.verticalGapLG,
            
            // 제목
            Text(
              '베타 테스트 계정 목록',
              style: AppTypography.titleLarge,
            ),
            Text(
              '아래 계정으로 로그인 가능합니다',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalGapMD,
            
            // 계정 목록
            Expanded(
              child: ListView.builder(
                itemCount: betaAccounts.length,
                itemBuilder: (context, index) {
                  final account = betaAccounts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          account['username']![0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(account['username']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('이메일: ${account['email']}'),
                          Text(
                            '비밀번호: ${account['password']}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // 클립보드에 복사 (실제 구현시 clipboard 패키지 사용)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${account['username']} 정보가 복사되었습니다'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // AWS 콘솔 링크
            Card(
              color: AppColors.primary.withOpacity(0.1),
              child: InkWell(
                onTap: () {
                  // 실제로는 url_launcher 패키지 사용
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AWS Console: https://console.aws.amazon.com/cognito'),
                    ),
                  );
                },
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.open_in_new, color: AppColors.primary),
                      AppSpacing.horizontalGapSM,
                      Text(
                        'AWS Cognito 콘솔 열기',
                        style: AppTypography.button.copyWith(
                          color: AppColors.primary,
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
}