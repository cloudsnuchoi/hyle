import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/learning_type_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../models/learning_type_models.dart';

class LearningTypeTestScreen extends ConsumerWidget {
  const LearningTypeTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(learningTypeTestProvider);
    
    if (testState.isCompleted && testState.result != null) {
      return _TestResultScreen(result: testState.result!);
    }
    
    return _TestScreen();
  }
}

class _TestScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(learningTypeTestProvider);
    final testNotifier = ref.read(learningTypeTestProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 유형 테스트'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: testNotifier.canGoPrevious
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: testNotifier.previousQuestion,
            )
          : null,
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${testState.currentQuestionIndex + 1}/8',
                      style: AppTypography.caption,
                    ),
                    Text(
                      '${(testState.progress * 100).toInt()}%',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                AppSpacing.verticalGapSM,
                LinearProgressIndicator(
                  value: testState.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Question Content
          Expanded(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: _QuestionCard(
                question: testNotifier.currentQuestion,
                selectedAnswer: testNotifier.currentAnswer,
                onAnswerSelected: (answerId) {
                  testNotifier.answerQuestion(
                    testNotifier.currentQuestion.id,
                    answerId,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final TestQuestion question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;
  
  const _QuestionCard({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Situation
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20),
                  AppSpacing.horizontalGapSM,
                  Expanded(
                    child: Text(
                      question.situation,
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // Question
            Text(
              question.question,
              style: AppTypography.titleMedium,
            ),
            
            AppSpacing.verticalGapLG,
            
            // Answers
            Expanded(
              child: ListView.builder(
                itemCount: question.answers.length,
                itemBuilder: (context, index) {
                  final answer = question.answers[index];
                  final isSelected = selectedAnswer == answer.id;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AnswerOption(
                      answer: answer,
                      isSelected: isSelected,
                      onTap: () => onAnswerSelected(answer.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.1, end: 0, duration: 400.ms);
  }
}

class _AnswerOption extends StatelessWidget {
  final TestAnswer answer;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _AnswerOption({
    required this.answer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected 
        ? Theme.of(context).primaryColor.withOpacity(0.1)
        : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected 
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
              ),
              AppSpacing.horizontalGapMD,
              Expanded(
                child: Text(
                  answer.text,
                  style: AppTypography.body.copyWith(
                    color: isSelected 
                      ? Theme.of(context).primaryColor
                      : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestResultScreen extends ConsumerWidget {
  final TestResult result;
  
  const _TestResultScreen({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningType = result.learningType;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 유형 결과'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(learningTypeTestProvider.notifier).retakeTest();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          children: [
            // Result Header
            _ResultHeader(learningType: learningType),
            
            AppSpacing.verticalGapLG,
            
            // Type Details
            _TypeDetails(learningType: learningType),
            
            AppSpacing.verticalGapLG,
            
            // Study Tips
            _StudyTipsCard(learningType: learningType),
            
            AppSpacing.verticalGapLG,
            
            // Strengths & Challenges
            _StrengthsChallengesCard(learningType: learningType),
            
            AppSpacing.verticalGapLG,
            
            // Action Buttons
            _ActionButtons(result: result),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final LearningType learningType;
  
  const _ResultHeader({required this.learningType});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          children: [
            Text(
              learningType.character,
              style: const TextStyle(fontSize: 80),
            ),
            AppSpacing.verticalGapMD,
            Text(
              learningType.name,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalGapSM,
            Text(
              learningType.id,
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalGapMD,
            Text(
              learningType.description,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(begin: const Offset(0.8, 0.8), duration: 600.ms);
  }
}

class _TypeDetails extends StatelessWidget {
  final LearningType learningType;
  
  const _TypeDetails({required this.learningType});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('당신의 학습 특성', style: AppTypography.titleMedium),
            AppSpacing.verticalGapMD,
            _DimensionItem(
              title: '계획 스타일',
              value: learningType.planning == PlanningType.planned ? '계획적' : '즉흥적',
              icon: learningType.planning == PlanningType.planned ? Icons.schedule : Icons.flash_on,
            ),
            _DimensionItem(
              title: '학습 환경',
              value: learningType.social == SocialType.individual ? '개인형' : '그룹형',
              icon: learningType.social == SocialType.individual ? Icons.person : Icons.group,
            ),
            _DimensionItem(
              title: '정보 처리',
              value: learningType.processing == ProcessingType.visual ? '시각형' : '청각형',
              icon: learningType.processing == ProcessingType.visual ? Icons.visibility : Icons.hearing,
            ),
            _DimensionItem(
              title: '접근 방식',
              value: learningType.approach == ApproachType.theoretical ? '이론형' : '실무형',
              icon: learningType.approach == ApproachType.theoretical ? Icons.book : Icons.build,
            ),
          ],
        ),
      ),
    );
  }
}

class _DimensionItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  
  const _DimensionItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          AppSpacing.horizontalGapMD,
          Expanded(
            child: Text(title, style: AppTypography.body),
          ),
          Text(
            value,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyTipsCard extends StatelessWidget {
  final LearningType learningType;
  
  const _StudyTipsCard({required this.learningType});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                AppSpacing.horizontalGapSM,
                Text('맞춤형 학습 팁', style: AppTypography.titleMedium),
              ],
            ),
            AppSpacing.verticalGapMD,
            ...learningType.studyTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, 
                    size: 16, 
                    color: Colors.green,
                  ),
                  AppSpacing.horizontalGapSM,
                  Expanded(
                    child: Text(tip, style: AppTypography.body),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StrengthsChallengesCard extends StatelessWidget {
  final LearningType learningType;
  
  const _StrengthsChallengesCard({required this.learningType});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Strengths
            Row(
              children: [
                Icon(Icons.star, color: Colors.green),
                AppSpacing.horizontalGapSM,
                Text('강점', style: AppTypography.titleMedium),
              ],
            ),
            AppSpacing.verticalGapSM,
            ...learningType.strengths.map((strength) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.add, size: 16, color: Colors.green),
                  AppSpacing.horizontalGapSM,
                  Expanded(
                    child: Text(strength, style: AppTypography.body),
                  ),
                ],
              ),
            )),
            
            AppSpacing.verticalGapMD,
            
            // Challenges
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                AppSpacing.horizontalGapSM,
                Text('주의할 점', style: AppTypography.titleMedium),
              ],
            ),
            AppSpacing.verticalGapSM,
            ...learningType.challenges.map((challenge) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.remove, size: 16, color: Colors.orange),
                  AppSpacing.horizontalGapSM,
                  Expanded(
                    child: Text(challenge, style: AppTypography.body),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final TestResult result;
  
  const _ActionButtons({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Motivational Quote
        Card(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                Icon(Icons.format_quote, 
                  color: Theme.of(context).primaryColor,
                ),
                AppSpacing.horizontalGapSM,
                Expanded(
                  child: Text(
                    result.learningType.motivationalQuote,
                    style: AppTypography.body.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        AppSpacing.verticalGapMD,
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: '다시 테스트하기',
                onPressed: () {
                  ref.read(learningTypeTestProvider.notifier).retakeTest();
                },
                isOutlined: true,
              ),
            ),
            AppSpacing.horizontalGapMD,
            Expanded(
              child: CustomButton(
                text: '학습 시작하기',
                onPressed: () {
                  // Add XP for completing the test
                  ref.read(userStatsProvider.notifier).addXP(100);
                  
                  // Navigate back to home
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}