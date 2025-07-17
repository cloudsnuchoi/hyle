import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';

// Learning Type Test Provider
final learningTypeTestProvider = StateNotifierProvider<LearningTypeTestNotifier, LearningTypeTestState>((ref) {
  return LearningTypeTestNotifier();
});

class LearningTypeTestState {
  final int currentQuestion;
  final Map<String, String> answers;
  final bool isCompleted;
  final LearningType? result;

  LearningTypeTestState({
    this.currentQuestion = 0,
    this.answers = const {},
    this.isCompleted = false,
    this.result,
  });

  LearningTypeTestState copyWith({
    int? currentQuestion,
    Map<String, String>? answers,
    bool? isCompleted,
    LearningType? result,
  }) {
    return LearningTypeTestState(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
    );
  }
}

class LearningTypeTestNotifier extends StateNotifier<LearningTypeTestState> {
  LearningTypeTestNotifier() : super(LearningTypeTestState());

  void answerQuestion(String dimension, String answer) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[dimension] = answer;
    
    if (state.currentQuestion < questions.length - 1) {
      state = state.copyWith(
        currentQuestion: state.currentQuestion + 1,
        answers: newAnswers,
      );
    } else {
      // Calculate result
      final result = _calculateLearningType(newAnswers);
      state = state.copyWith(
        answers: newAnswers,
        isCompleted: true,
        result: result,
      );
    }
  }

  void previousQuestion() {
    if (state.currentQuestion > 0) {
      state = state.copyWith(currentQuestion: state.currentQuestion - 1);
    }
  }

  void reset() {
    state = LearningTypeTestState();
  }

  LearningType _calculateLearningType(Map<String, String> answers) {
    return LearningType(
      planning: answers['planning1'] == 'A' && answers['planning2'] == 'A' ? 'PLANNED' : 'SPONTANEOUS',
      social: answers['social1'] == 'A' && answers['social2'] == 'A' ? 'INDIVIDUAL' : 'GROUP',
      processing: answers['processing1'] == 'A' && answers['processing2'] == 'A' ? 'VISUAL' : 'AUDITORY',
      approach: answers['approach1'] == 'A' && answers['approach2'] == 'A' ? 'THEORETICAL' : 'PRACTICAL',
    );
  }
}

// Questions data
final questions = [
  TestQuestion(
    dimension: 'planning1',
    question: 'When starting a new study topic, do you prefer to:',
    optionA: 'Create a detailed study plan with specific goals and timelines',
    optionB: 'Dive in and figure things out as you go',
    imageA: '📅',
    imageB: '🏃',
  ),
  TestQuestion(
    dimension: 'planning2',
    question: 'Your ideal study schedule is:',
    optionA: 'Fixed time slots for each subject throughout the week',
    optionB: 'Flexible based on how you feel each day',
    imageA: '⏰',
    imageB: '🌊',
  ),
  TestQuestion(
    dimension: 'social1',
    question: 'You learn best when:',
    optionA: 'Working alone in a quiet environment',
    optionB: 'Discussing ideas with classmates',
    imageA: '🧘',
    imageB: '👥',
  ),
  TestQuestion(
    dimension: 'social2',
    question: 'For exam preparation, you prefer:',
    optionA: 'Creating your own notes and study materials',
    optionB: 'Joining study groups and sharing resources',
    imageA: '📝',
    imageB: '🤝',
  ),
  TestQuestion(
    dimension: 'processing1',
    question: 'When learning new concepts, you prefer:',
    optionA: 'Diagrams, charts, and visual representations',
    optionB: 'Lectures, podcasts, and verbal explanations',
    imageA: '📊',
    imageB: '🎧',
  ),
  TestQuestion(
    dimension: 'processing2',
    question: 'You remember information better through:',
    optionA: 'Color-coded notes and mind maps',
    optionB: 'Recording lectures and listening to them',
    imageA: '🎨',
    imageB: '🎙️',
  ),
  TestQuestion(
    dimension: 'approach1',
    question: 'When studying, you prefer to:',
    optionA: 'Understand the theory and principles first',
    optionB: 'Start with practical examples and exercises',
    imageA: '📚',
    imageB: '🔧',
  ),
  TestQuestion(
    dimension: 'approach2',
    question: 'Your ideal learning method involves:',
    optionA: 'Reading textbooks and research papers',
    optionB: 'Hands-on experiments and real-world applications',
    imageA: '🔬',
    imageB: '🛠️',
  ),
];

class TestQuestion {
  final String dimension;
  final String question;
  final String optionA;
  final String optionB;
  final String imageA;
  final String imageB;

  TestQuestion({
    required this.dimension,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.imageA,
    required this.imageB,
  });
}

class LearningType {
  final String planning;
  final String social;
  final String processing;
  final String approach;

  LearningType({
    required this.planning,
    required this.social,
    required this.processing,
    required this.approach,
  });

  String get code => 
      planning[0] + social[0] + processing[0] + approach[0];
      
  String get fullName {
    final types = {
      'PIVT': 'The Strategic Scholar',
      'PIVA': 'The Methodical Mentor',
      'PGVT': 'The Visual Collaborator',
      'PGVA': 'The Interactive Instructor',
      'PGAT': 'The Discussion Leader',
      'PGAP': 'The Workshop Facilitator',
      'PIVP': 'The Practical Planner',
      'PIAP': 'The Solo Experimenter',
      'SIVT': 'The Flexible Theorist',
      'SIVA': 'The Adaptive Listener',
      'SGVT': 'The Social Visualizer',
      'SGVA': 'The Group Discusser',
      'SGAT': 'The Collaborative Talker',
      'SGAP': 'The Team Builder',
      'SIVP': 'The Independent Doer',
      'SIAP': 'The Hands-on Explorer',
    };
    return types[code] ?? 'The Unique Learner';
  }
}

class LearningTypeTestScreen extends ConsumerWidget {
  const LearningTypeTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(learningTypeTestProvider);
    
    if (state.isCompleted && state.result != null) {
      return _ResultScreen(result: state.result!);
    }
    
    return _QuestionScreen(
      question: questions[state.currentQuestion],
      questionIndex: state.currentQuestion,
      totalQuestions: questions.length,
    );
  }
}

class _QuestionScreen extends ConsumerWidget {
  final TestQuestion question;
  final int questionIndex;
  final int totalQuestions;

  const _QuestionScreen({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = (questionIndex + 1) / totalQuestions;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${questionIndex + 1} of $totalQuestions'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingXL,
              child: Column(
                children: [
                  AppSpacing.verticalGapXL,
                  
                  // Question
                  Text(
                    question.question,
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ).animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                  
                  AppSpacing.verticalGapXL,
                  AppSpacing.verticalGapXL,
                  
                  // Options
                  Row(
                    children: [
                      Expanded(
                        child: _OptionCard(
                          emoji: question.imageA,
                          text: question.optionA,
                          onTap: () {
                            ref.read(learningTypeTestProvider.notifier)
                                .answerQuestion(question.dimension, 'A');
                          },
                        ),
                      ),
                      AppSpacing.horizontalGapLG,
                      Expanded(
                        child: _OptionCard(
                          emoji: question.imageB,
                          text: question.optionB,
                          onTap: () {
                            ref.read(learningTypeTestProvider.notifier)
                                .answerQuestion(question.dimension, 'B');
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.verticalGapXL,
                  
                  // Navigation
                  if (questionIndex > 0)
                    TextButton(
                      onPressed: () {
                        ref.read(learningTypeTestProvider.notifier).previousQuestion();
                      },
                      child: const Text('Previous Question'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String emoji;
  final String text;
  final VoidCallback onTap;

  const _OptionCard({
    required this.emoji,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ).animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
            
            AppSpacing.verticalGapMD,
            
            Text(
              text,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: 0.9, end: 1.0);
  }
}

class _ResultScreen extends ConsumerWidget {
  final LearningType result;

  const _ResultScreen({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingXL,
          child: Column(
            children: [
              AppSpacing.verticalGapXL,
              
              // Celebration animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.white,
                ),
              ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 1500.ms),
              
              AppSpacing.verticalGapXL,
              
              Text(
                'Your Learning Type',
                style: AppTypography.titleMedium,
              ),
              
              AppSpacing.verticalGapSM,
              
              Text(
                result.code,
                style: AppTypography.display.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ).animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0),
              
              AppSpacing.verticalGapMD,
              
              Text(
                result.fullName,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              
              AppSpacing.verticalGapXL,
              
              // Type breakdown
              _TypeBreakdown(type: result),
              
              AppSpacing.verticalGapXL,
              
              // Character (placeholder)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getCharacterEmoji(result.code),
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ).animate()
                .scale(duration: 600.ms, delay: 500.ms, curve: Curves.elasticOut),
              
              AppSpacing.verticalGapXL,
              
              // Study tips
              _StudyTips(type: result),
              
              AppSpacing.verticalGapXL,
              
              // Action buttons
              CustomButton(
                onPressed: () {
                  // TODO: Save learning type to user profile
                  context.go('/home');
                },
                child: const Text('Start Your Journey'),
              ),
              
              AppSpacing.verticalGapMD,
              
              CustomButton(
                onPressed: () {
                  // TODO: Implement share functionality
                },
                variant: ButtonVariant.outline,
                child: const Text('Share Your Type'),
              ),
              
              AppSpacing.verticalGapMD,
              
              TextButton(
                onPressed: () {
                  ref.read(learningTypeTestProvider.notifier).reset();
                },
                child: const Text('Retake Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCharacterEmoji(String code) {
    final characters = {
      'PIVT': '🎯',
      'PIVA': '📖',
      'PGVT': '🎨',
      'PGVA': '🎭',
      'PGAT': '💬',
      'PGAP': '🛠️',
      'PIVP': '⚙️',
      'PIAP': '🔬',
      'SIVT': '🌊',
      'SIVA': '🎧',
      'SGVT': '👁️',
      'SGVA': '🗣️',
      'SGAT': '🤝',
      'SGAP': '🏗️',
      'SIVP': '🎯',
      'SIAP': '🚀',
    };
    return characters[code] ?? '📚';
  }
}

class _TypeBreakdown extends StatelessWidget {
  final LearningType type;

  const _TypeBreakdown({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _DimensionRow(
            label: 'Planning Style',
            value: type.planning,
            icon: type.planning == 'PLANNED' ? Icons.calendar_month : Icons.shuffle,
          ),
          const Divider(),
          _DimensionRow(
            label: 'Social Preference',
            value: type.social,
            icon: type.social == 'INDIVIDUAL' ? Icons.person : Icons.group,
          ),
          const Divider(),
          _DimensionRow(
            label: 'Processing Method',
            value: type.processing,
            icon: type.processing == 'VISUAL' ? Icons.visibility : Icons.hearing,
          ),
          const Divider(),
          _DimensionRow(
            label: 'Learning Approach',
            value: type.approach,
            icon: type.approach == 'THEORETICAL' ? Icons.school : Icons.engineering,
          ),
        ],
      ),
    );
  }
}

class _DimensionRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DimensionRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          AppSpacing.horizontalGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption,
                ),
                Text(
                  value,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyTips extends StatelessWidget {
  final LearningType type;

  const _StudyTips({required this.type});

  @override
  Widget build(BuildContext context) {
    final tips = _getStudyTips(type);
    
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber),
              AppSpacing.horizontalGapSM,
              Text(
                'Personalized Study Tips',
                style: AppTypography.titleMedium,
              ),
            ],
          ),
          AppSpacing.verticalGapMD,
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tip, style: AppTypography.body),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getStudyTips(LearningType type) {
    final tips = <String>[];
    
    // Planning tips
    if (type.planning == 'PLANNED') {
      tips.add('Use detailed study schedules and stick to them');
      tips.add('Set specific goals for each study session');
    } else {
      tips.add('Keep your schedule flexible to maintain motivation');
      tips.add('Use short study bursts when you feel inspired');
    }
    
    // Social tips
    if (type.social == 'INDIVIDUAL') {
      tips.add('Find a quiet study space where you won\'t be disturbed');
      tips.add('Use noise-canceling headphones for better focus');
    } else {
      tips.add('Join study groups to discuss difficult concepts');
      tips.add('Teach others to reinforce your own learning');
    }
    
    // Processing tips
    if (type.processing == 'VISUAL') {
      tips.add('Create mind maps and diagrams to organize information');
      tips.add('Use color-coding in your notes');
    } else {
      tips.add('Record lectures and listen to them while commuting');
      tips.add('Explain concepts out loud to yourself');
    }
    
    // Approach tips
    if (type.approach == 'THEORETICAL') {
      tips.add('Start with understanding the big picture before details');
      tips.add('Read theory sections thoroughly before practicing');
    } else {
      tips.add('Start with examples and work backwards to theory');
      tips.add('Use hands-on projects to understand concepts');
    }
    
    return tips;
  }
}