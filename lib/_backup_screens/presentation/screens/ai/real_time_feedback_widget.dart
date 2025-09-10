import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/ai_service_stub.dart';

// Real-time AI Feedback Provider
final realtimeFeedbackProvider = StateNotifierProvider<RealtimeFeedbackNotifier, RealtimeFeedbackState>((ref) {
  return RealtimeFeedbackNotifier(ref.read(aiServiceProvider));
});

class RealtimeFeedbackState {
  final bool isAnalyzing;
  final SessionFeedback? currentFeedback;
  final String? currentAdvice;
  final bool showSuggestion;
  final DateTime? lastFeedbackTime;

  RealtimeFeedbackState({
    this.isAnalyzing = false,
    this.currentFeedback,
    this.currentAdvice,
    this.showSuggestion = false,
    this.lastFeedbackTime,
  });

  RealtimeFeedbackState copyWith({
    bool? isAnalyzing,
    SessionFeedback? currentFeedback,
    String? currentAdvice,
    bool? showSuggestion,
    DateTime? lastFeedbackTime,
  }) {
    return RealtimeFeedbackState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentFeedback: currentFeedback ?? this.currentFeedback,
      currentAdvice: currentAdvice ?? this.currentAdvice,
      showSuggestion: showSuggestion ?? this.showSuggestion,
      lastFeedbackTime: lastFeedbackTime ?? this.lastFeedbackTime,
    );
  }
}

class RealtimeFeedbackNotifier extends StateNotifier<RealtimeFeedbackState> {
  final AIService _aiService;
  Timer? _analysisTimer;
  
  RealtimeFeedbackNotifier(this._aiService) : super(RealtimeFeedbackState());

  void startMonitoring({
    required String sessionId,
    required Duration checkInterval,
  }) {
    _analysisTimer?.cancel();
    
    // Initial analysis after 5 minutes
    Future.delayed(const Duration(minutes: 5), () {
      _analyzeSession(sessionId, SessionMetrics(
        duration: 5 * 60, // Convert minutes to seconds
        pauseCount: 0,
        taskCompletionRate: 0.0,
        timeOfDay: _getTimeOfDay(),
        subject: 'General',
      ));
    });

    // Regular analysis
    _analysisTimer = Timer.periodic(checkInterval, (timer) {
      // TODO: Get actual metrics from timer
      _analyzeSession(sessionId, SessionMetrics(
        duration: timer.tick * checkInterval.inSeconds,
        pauseCount: 0, // Get from timer events
        taskCompletionRate: 0.0, // Calculate from todos
        timeOfDay: _getTimeOfDay(),
        subject: 'General', // Get from current todo
      ));
    });
  }

  void stopMonitoring() {
    _analysisTimer?.cancel();
    state = RealtimeFeedbackState();
  }

  Future<void> _analyzeSession(String sessionId, SessionMetrics metrics) async {
    // Don't analyze too frequently
    if (state.lastFeedbackTime != null) {
      final timeSinceLastFeedback = DateTime.now().difference(state.lastFeedbackTime!);
      if (timeSinceLastFeedback.inMinutes < 10) {
        return;
      }
    }

    state = state.copyWith(isAnalyzing: true);

    try {
      final feedback = await _aiService.analyzeStudySession(
        sessionId: sessionId,
        metrics: metrics,
      );

      state = state.copyWith(
        isAnalyzing: false,
        currentFeedback: feedback,
        showSuggestion: _shouldShowSuggestion(feedback),
        lastFeedbackTime: DateTime.now(),
      );

      // Auto-hide suggestion after 10 seconds
      if (state.showSuggestion) {
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            state = state.copyWith(showSuggestion: false);
          }
        });
      }
    } catch (e) {
      state = state.copyWith(isAnalyzing: false);
    }
  }

  Future<void> getAdvice(String question, StudyContext context) async {
    state = state.copyWith(isAnalyzing: true);

    try {
      final advice = await _aiService.getRealtimeAdvice(
        context: context,
        question: question,
      );

      state = state.copyWith(
        isAnalyzing: false,
        currentAdvice: advice,
        showSuggestion: true,
      );
    } catch (e) {
      state = state.copyWith(isAnalyzing: false);
    }
  }

  void dismissSuggestion() {
    state = state.copyWith(showSuggestion: false);
  }

  bool _shouldShowSuggestion(SessionFeedback feedback) {
    // Show suggestion if:
    // - Break is recommended
    // - Productivity is low
    // - Focus level is poor
    return feedback.breakRecommended ||
           feedback.productivityScore < 0.6 ||
           feedback.focusLevel == 'poor';
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'early_morning';
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }
}

// Real-time Feedback Widget
class RealtimeFeedbackWidget extends ConsumerWidget {
  final String sessionId;
  final VoidCallback? onBreakSuggested;

  const RealtimeFeedbackWidget({
    super.key,
    required this.sessionId,
    this.onBreakSuggested,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(realtimeFeedbackProvider);
    
    // Start monitoring when widget is built
    ref.read(realtimeFeedbackProvider.notifier).startMonitoring(
      sessionId: sessionId,
      checkInterval: const Duration(minutes: 15),
    );

    if (!state.showSuggestion || state.currentFeedback == null) {
      return const SizedBox.shrink();
    }

    return _FeedbackCard(
      feedback: state.currentFeedback!,
      onDismiss: () {
        ref.read(realtimeFeedbackProvider.notifier).dismissSuggestion();
      },
      onBreakAccepted: onBreakSuggested,
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final SessionFeedback feedback;
  final VoidCallback onDismiss;
  final VoidCallback? onBreakAccepted;

  const _FeedbackCard({
    required this.feedback,
    required this.onDismiss,
    this.onBreakAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        child: Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(feedback),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    _getIcon(feedback),
                    color: _getIconColor(feedback),
                  ),
                  AppSpacing.horizontalGapSM,
                  Text(
                    _getTitle(feedback),
                    style: AppTypography.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              AppSpacing.verticalGapMD,
              
              // Productivity Score
              if (feedback.productivityScore > 0)
                _ProductivityIndicator(score: feedback.productivityScore),
              
              AppSpacing.verticalGapMD,
              
              // Suggestions
              ...feedback.suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              )),
              
              // Action buttons
              if (feedback.breakRecommended) ...[
                AppSpacing.verticalGapMD,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        child: const Text('Not Now'),
                      ),
                    ),
                    AppSpacing.horizontalGapMD,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onBreakAccepted?.call();
                          onDismiss();
                        },
                        child: const Text('Take a Break'),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Next best action
              if (feedback.nextBestAction.isNotEmpty) ...[
                AppSpacing.verticalGapMD,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: theme.colorScheme.primary,
                      ),
                      AppSpacing.horizontalGapSM,
                      Expanded(
                        child: Text(
                          feedback.nextBestAction,
                          style: AppTypography.body.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, end: 0)
        .then()
        .shimmer(duration: 1000.ms, delay: 500.ms),
    );
  }

  Color _getBorderColor(SessionFeedback feedback) {
    if (feedback.breakRecommended) return Colors.orange;
    if (feedback.productivityScore < 0.6) return Colors.red;
    if (feedback.productivityScore > 0.8) return Colors.green;
    return Colors.blue;
  }

  IconData _getIcon(SessionFeedback feedback) {
    if (feedback.breakRecommended) return Icons.free_breakfast;
    if (feedback.focusLevel == 'poor') return Icons.warning;
    if (feedback.productivityScore > 0.8) return Icons.trending_up;
    return Icons.insights;
  }

  Color _getIconColor(SessionFeedback feedback) {
    if (feedback.breakRecommended) return Colors.orange;
    if (feedback.focusLevel == 'poor') return Colors.red;
    if (feedback.productivityScore > 0.8) return Colors.green;
    return Colors.blue;
  }

  String _getTitle(SessionFeedback feedback) {
    if (feedback.breakRecommended) return 'Time for a Break!';
    if (feedback.focusLevel == 'poor') return 'Focus Alert';
    if (feedback.productivityScore > 0.8) return 'Great Progress!';
    return 'Study Insight';
  }
}

class _ProductivityIndicator extends StatelessWidget {
  final double score;

  const _ProductivityIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (score * 100).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Productivity Score',
              style: AppTypography.caption,
            ),
            Text(
              '$percentage%',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: _getScoreColor(score),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score < 0.4) return Colors.red;
    if (score < 0.6) return Colors.orange;
    if (score < 0.8) return Colors.amber;
    return Colors.green;
  }
}

// Quick Decision Widget
class QuickDecisionWidget extends ConsumerWidget {
  final String question;
  final StudyContext context;

  const QuickDecisionWidget({
    super.key,
    required this.question,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: Colors.blue),
              AppSpacing.horizontalGapSM,
              Expanded(
                child: Text(
                  question,
                  style: AppTypography.titleSmall,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapMD,
          ElevatedButton(
            onPressed: () {
              ref.read(realtimeFeedbackProvider.notifier).getAdvice(
                question,
                this.context,
              );
            },
            child: const Text('Get AI Advice'),
          ),
        ],
      ),
    );
  }
}