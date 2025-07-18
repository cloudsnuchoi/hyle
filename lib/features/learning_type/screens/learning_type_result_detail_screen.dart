import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/learning_type_models.dart';
import '../../../providers/learning_type_provider.dart';
import 'learning_type_test_screen.dart';

class LearningTypeResultDetailScreen extends ConsumerWidget {
  const LearningTypeResultDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningType = ref.watch(currentLearningTypeProvider);
    
    if (learningType == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('학습 유형 상세')),
        body: const Center(
          child: Text('학습 유형 테스트를 먼저 진행해주세요.'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 학습 유형'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 카드
            Card(
              child: Padding(
                padding: AppSpacing.paddingLG,
                child: Column(
                  children: [
                    Text(
                      learningType.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    AppSpacing.verticalGapMD,
                    Text(
                      learningType.name,
                      style: AppTypography.headlineMedium.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalGapSM,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        learningType.id,
                        style: AppTypography.caption.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AppSpacing.verticalGapLG,
                    Text(
                      learningType.description,
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 4가지 차원
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('나의 학습 성향', style: AppTypography.titleMedium),
                    AppSpacing.verticalGapMD,
                    _buildDimensionRow(
                      '계획성',
                      learningType.planning == PlanningType.planned ? '계획적 (P)' : '즉흥적 (S)',
                      learningType.planning == PlanningType.planned ? Colors.blue : Colors.orange,
                    ),
                    _buildDimensionRow(
                      '학습 환경',
                      learningType.social == SocialType.individual ? '개인형 (I)' : '그룹형 (G)',
                      learningType.social == SocialType.individual ? Colors.purple : Colors.green,
                    ),
                    _buildDimensionRow(
                      '정보 처리',
                      learningType.processing == ProcessingType.visual ? '시각형 (V)' : '청각형 (A)',
                      learningType.processing == ProcessingType.visual ? Colors.pink : Colors.teal,
                    ),
                    _buildDimensionRow(
                      '학습 접근',
                      learningType.approach == ApproachType.theoretical ? '이론형 (T)' : '실무형 (P)',
                      learningType.approach == ApproachType.theoretical ? Colors.indigo : Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 강점
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        AppSpacing.horizontalGapSM,
                        Text('나의 강점', style: AppTypography.titleMedium),
                      ],
                    ),
                    AppSpacing.verticalGapMD,
                    ...learningType.strengths.map((strength) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            AppSpacing.horizontalGapSM,
                            Expanded(child: Text(strength, style: AppTypography.body)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 도전 과제
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.orange),
                        AppSpacing.horizontalGapSM,
                        Text('성장 포인트', style: AppTypography.titleMedium),
                      ],
                    ),
                    AppSpacing.verticalGapMD,
                    ...learningType.challenges.map((challenge) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward, color: Colors.orange, size: 20),
                            AppSpacing.horizontalGapSM,
                            Expanded(child: Text(challenge, style: AppTypography.body)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 학습 팁
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.yellow.shade700),
                        AppSpacing.horizontalGapSM,
                        Text('맞춤 학습 팁', style: AppTypography.titleMedium),
                      ],
                    ),
                    AppSpacing.verticalGapMD,
                    ...learningType.studyTips.map((tip) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          padding: AppSpacing.paddingMD,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.tips_and_updates, color: Theme.of(context).primaryColor, size: 20),
                              AppSpacing.horizontalGapSM,
                              Expanded(child: Text(tip, style: AppTypography.body)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 동기부여 문구
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: AppSpacing.paddingLG,
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    AppSpacing.verticalGapMD,
                    Text(
                      learningType.motivationalQuote,
                      style: AppTypography.titleMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 재검사 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LearningTypeTestScreen(),
                    ),
                  );
                },
                child: const Text('다시 테스트하기'),
              ),
            ),
            
            AppSpacing.verticalGapXL,
          ],
        ),
      ),
    );
  }
  
  Widget _buildDimensionRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSpacing.horizontalGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                Text(value, style: AppTypography.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}