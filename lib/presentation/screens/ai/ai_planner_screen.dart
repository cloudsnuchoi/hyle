import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/services/ai_service.dart';

// AI Planner Provider
final aiPlannerProvider = StateNotifierProvider<AIPlannerNotifier, AIPlannerState>((ref) {
  return AIPlannerNotifier(ref.read(aiServiceProvider));
});

class AIPlannerState {
  final bool isLoading;
  final StudyPlan? currentPlan;
  final String? error;
  final List<String> recentPrompts;

  AIPlannerState({
    this.isLoading = false,
    this.currentPlan,
    this.error,
    this.recentPrompts = const [],
  });

  AIPlannerState copyWith({
    bool? isLoading,
    StudyPlan? currentPlan,
    String? error,
    List<String>? recentPrompts,
  }) {
    return AIPlannerState(
      isLoading: isLoading ?? this.isLoading,
      currentPlan: currentPlan ?? this.currentPlan,
      error: error,
      recentPrompts: recentPrompts ?? this.recentPrompts,
    );
  }
}

class AIPlannerNotifier extends StateNotifier<AIPlannerState> {
  final AIService _aiService;

  AIPlannerNotifier(this._aiService) : super(AIPlannerState());

  Future<void> generatePlan(String prompt, UserContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final plan = await _aiService.generateStudyPlan(
        userPrompt: prompt,
        context: context,
      );
      
      state = state.copyWith(
        isLoading: false,
        currentPlan: plan,
        recentPrompts: [prompt, ...state.recentPrompts.take(4)],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate plan: $e',
      );
    }
  }
}

class AIPlannerScreen extends ConsumerStatefulWidget {
  const AIPlannerScreen({super.key});

  @override
  ConsumerState<AIPlannerScreen> createState() => _AIPlannerScreenState();
}

class _AIPlannerScreenState extends ConsumerState<AIPlannerScreen> {
  final _promptController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _promptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(aiPlannerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Planner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // AI Assistant Header
          Container(
            padding: AppSpacing.paddingXL,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              children: [
                // AI Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 40,
                    color: Colors.white,
                  ),
                ).animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 2000.ms, delay: 1000.ms),
                
                AppSpacing.verticalGapMD,
                
                Text(
                  'AI Study Assistant',
                  style: AppTypography.titleLarge,
                ),
                AppSpacing.verticalGapSM,
                Text(
                  'Tell me what you need to study and I\'ll create the perfect plan for you',
                  style: AppTypography.body.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: state.currentPlan != null
                ? _PlanView(plan: state.currentPlan!)
                : _PromptView(
                    promptController: _promptController,
                    focusNode: _focusNode,
                    recentPrompts: state.recentPrompts,
                    isLoading: state.isLoading,
                    error: state.error,
                    onSubmit: _handleSubmit,
                  ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;
    
    // TODO: Get actual user context
    final context = UserContext(
      level: 15,
      learningType: 'PIVT', // Example
      availableHours: 4.0,
      subjects: ['Math', 'Science', 'English'],
      examDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    ref.read(aiPlannerProvider.notifier).generatePlan(prompt, context);
    _promptController.clear();
    _focusNode.unfocus();
  }
}

class _PromptView extends StatelessWidget {
  final TextEditingController promptController;
  final FocusNode focusNode;
  final List<String> recentPrompts;
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;

  const _PromptView({
    required this.promptController,
    required this.focusNode,
    required this.recentPrompts,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Example prompts
          if (recentPrompts.isEmpty) ...[
            Text(
              'Try these examples:',
              style: AppTypography.titleMedium,
            ),
            AppSpacing.verticalGapMD,
            _ExamplePrompt(
              icon: Icons.school,
              text: '내일 수학 시험 준비해줘',
              onTap: () {
                promptController.text = '내일 수학 시험 준비해줘';
                onSubmit();
              },
            ),
            AppSpacing.verticalGapSM,
            _ExamplePrompt(
              icon: Icons.calendar_month,
              text: '이번 주 과학 프로젝트 계획 짜줘',
              onTap: () {
                promptController.text = '이번 주 과학 프로젝트 계획 짜줘';
                onSubmit();
              },
            ),
            AppSpacing.verticalGapSM,
            _ExamplePrompt(
              icon: Icons.timer,
              text: '오늘 4시간 공부 계획 만들어줘',
              onTap: () {
                promptController.text = '오늘 4시간 공부 계획 만들어줘';
                onSubmit();
              },
            ),
          ],
          
          // Recent prompts
          if (recentPrompts.isNotEmpty) ...[
            Text(
              'Recent requests:',
              style: AppTypography.titleMedium,
            ),
            AppSpacing.verticalGapMD,
            ...recentPrompts.map((prompt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RecentPrompt(
                text: prompt,
                onTap: () {
                  promptController.text = prompt;
                  onSubmit();
                },
              ),
            )),
          ],
          
          AppSpacing.verticalGapXL,
          
          // Input field
          Container(
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
            child: TextField(
              controller: promptController,
              focusNode: focusNode,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What do you need help studying?',
                hintStyle: AppTypography.body.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: AppSpacing.paddingLG,
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          
          AppSpacing.verticalGapMD,
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: isLoading ? null : onSubmit,
              text: 'Generate Study Plan',
              isLoading: isLoading,
            ),
          ),
          
          // Error message
          if (error != null) ...[
            AppSpacing.verticalGapMD,
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  AppSpacing.horizontalGapSM,
                  Expanded(
                    child: Text(
                      error!,
                      style: AppTypography.caption.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExamplePrompt extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ExamplePrompt({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            AppSpacing.horizontalGapMD,
            Expanded(
              child: Text(
                text,
                style: AppTypography.body,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.1, end: 0);
  }
}

class _RecentPrompt extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _RecentPrompt({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanView extends ConsumerWidget {
  final StudyPlan plan;

  const _PlanView({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Plan header
        Container(
          padding: AppSpacing.paddingLG,
          color: theme.colorScheme.primary.withOpacity(0.05),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
              AppSpacing.horizontalGapMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Study Plan is Ready!',
                      style: AppTypography.titleMedium,
                    ),
                    Text(
                      '${plan.totalHours.toStringAsFixed(1)} hours total',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(aiPlannerProvider.notifier).state = AIPlannerState();
                },
                child: const Text('New Plan'),
              ),
            ],
          ),
        ),
        
        // Plan tasks
        Expanded(
          child: ListView.builder(
            padding: AppSpacing.paddingLG,
            itemCount: plan.tasks.length + 1,
            itemBuilder: (context, index) {
              if (index == plan.tasks.length) {
                // Recommendations section
                return _RecommendationsCard(
                  recommendations: plan.recommendations,
                );
              }
              
              final task = plan.tasks[index];
              return _TaskCard(
                task: task,
                index: index,
              );
            },
          ),
        ),
        
        // Action buttons
        Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    // TODO: Add all tasks to todo list
                  },
                  isOutlined: true,
                  text: 'Add to Todo List',
                ),
              ),
              AppSpacing.horizontalGapMD,
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    // TODO: Start first task
                  },
                  text: 'Start Now',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final PlannedTask task;
  final int index;

  const _TaskCard({
    required this.task,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(task.priority).withOpacity(0.2),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: _getPriorityColor(task.priority),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(task.title),
        subtitle: Row(
          children: [
            Icon(Icons.subject, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text(task.subject),
            AppSpacing.horizontalGapMD,
            Icon(Icons.timer, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text('${task.estimatedMinutes} min'),
          ],
        ),
        trailing: task.suggestedTime != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${task.suggestedTime!.hour}:${task.suggestedTime!.minute.toString().padLeft(2, '0')}',
                  style: AppTypography.caption.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : null,
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index))
      .slideY(begin: 0.2, end: 0);
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _RecommendationsCard extends StatelessWidget {
  final List<String> recommendations;

  const _RecommendationsCard({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                ),
                AppSpacing.horizontalGapSM,
                Text(
                  'AI Recommendations',
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
            AppSpacing.verticalGapMD,
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }
}