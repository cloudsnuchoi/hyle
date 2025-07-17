import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';

// AI Insights Provider
final aiInsightsProvider = StateNotifierProvider<AIInsightsNotifier, AIInsightsState>((ref) {
  return AIInsightsNotifier();
});

class AIInsightsState {
  final LearningAnalysis? analysis;
  final List<AIRecommendation> recommendations;
  final List<PredictedOutcome> predictions;
  final PatternInsights? patterns;
  final bool isLoading;
  final DateTime? lastUpdated;

  AIInsightsState({
    this.analysis,
    this.recommendations = const [],
    this.predictions = const [],
    this.patterns,
    this.isLoading = false,
    this.lastUpdated,
  });

  AIInsightsState copyWith({
    LearningAnalysis? analysis,
    List<AIRecommendation>? recommendations,
    List<PredictedOutcome>? predictions,
    PatternInsights? patterns,
    bool? isLoading,
    DateTime? lastUpdated,
  }) {
    return AIInsightsState(
      analysis: analysis ?? this.analysis,
      recommendations: recommendations ?? this.recommendations,
      predictions: predictions ?? this.predictions,
      patterns: patterns ?? this.patterns,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AIInsightsNotifier extends StateNotifier<AIInsightsState> {
  AIInsightsNotifier() : super(AIInsightsState()) {
    loadInsights();
  }

  void loadInsights() {
    state = state.copyWith(isLoading: true);

    // Mock data - in production, call AI service
    state = state.copyWith(
      analysis: LearningAnalysis(
        overallScore: 85,
        trend: 'improving',
        strengths: [
          'Mathematics - Calculus',
          'Consistent morning study habit',
          'High focus during 2-4 PM',
        ],
        weaknesses: [
          'English vocabulary retention',
          'Late night productivity drop',
          'Frequent context switching',
        ],
        learningVelocity: 1.2,
        retentionRate: 0.78,
        optimalStudyTime: '2:00 PM - 4:00 PM',
      ),
      recommendations: [
        AIRecommendation(
          id: '1',
          title: 'Switch to Spaced Repetition',
          description: 'Your vocabulary retention is 23% below optimal. Try spaced repetition for English.',
          priority: 'high',
          category: 'technique',
          impact: 'Increase retention by 40%',
          icon: '🔄',
          actionSteps: [
            'Review vocabulary every 1, 3, 7, and 14 days',
            'Use flashcards with context sentences',
            'Test yourself before reviewing',
          ],
        ),
        AIRecommendation(
          id: '2',
          title: 'Optimize Study Schedule',
          description: 'You perform 35% better between 2-4 PM. Reschedule difficult topics.',
          priority: 'medium',
          category: 'scheduling',
          impact: 'Save 45 minutes daily',
          icon: '⏰',
          actionSteps: [
            'Move calculus practice to 2-4 PM',
            'Schedule breaks every 45 minutes',
            'Do light review in the evening',
          ],
        ),
        AIRecommendation(
          id: '3',
          title: 'Join Study Group',
          description: 'Students with your profile improve 28% faster in groups.',
          priority: 'medium',
          category: 'social',
          impact: 'Boost motivation by 50%',
          icon: '👥',
          actionSteps: [
            'Join "Math Masters" study group',
            'Participate in weekly challenges',
            'Share your progress daily',
          ],
        ),
      ],
      predictions: [
        PredictedOutcome(
          scenario: 'Current Path',
          examScore: 82,
          readinessDate: DateTime.now().add(const Duration(days: 45)),
          confidence: 0.75,
          factors: [
            'Maintaining current study hours',
            'Following existing schedule',
            'No technique changes',
          ],
        ),
        PredictedOutcome(
          scenario: 'Optimized Path',
          examScore: 91,
          readinessDate: DateTime.now().add(const Duration(days: 38)),
          confidence: 0.82,
          factors: [
            'Implementing AI recommendations',
            'Optimized schedule',
            'Spaced repetition for weak areas',
          ],
        ),
      ],
      patterns: PatternInsights(
        studyPatterns: [
          StudyPattern(
            name: 'Morning Starter',
            frequency: 0.85,
            effectiveness: 0.72,
            description: 'You start 85% of days with study',
          ),
          StudyPattern(
            name: 'Deep Focus Sessions',
            frequency: 0.45,
            effectiveness: 0.91,
            description: '45% of sessions exceed 90 minutes',
          ),
          StudyPattern(
            name: 'Subject Hopping',
            frequency: 0.65,
            effectiveness: 0.48,
            description: 'Switch subjects frequently',
          ),
        ],
        weeklyHeatmap: [
          [0.9, 0.8, 0.7, 0.9, 0.6, 0.3, 0.4], // Week 1
          [0.8, 0.9, 0.8, 0.7, 0.8, 0.5, 0.6], // Week 2
          [0.7, 0.8, 0.9, 0.8, 0.7, 0.6, 0.7], // Week 3
          [0.9, 0.9, 0.8, 0.9, 0.8, 0.7, 0.8], // Week 4
        ],
        focusDistribution: {
          'Mathematics': 0.35,
          'English': 0.25,
          'Science': 0.20,
          'History': 0.15,
          'Other': 0.05,
        },
      ),
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
  }

  void applyRecommendation(String recommendationId) {
    // In production, this would trigger actual changes
    state = state.copyWith(
      recommendations: state.recommendations.map((r) {
        if (r.id == recommendationId) {
          return r.copyWith(isApplied: true);
        }
        return r;
      }).toList(),
    );
  }
}

// Data models
class LearningAnalysis {
  final int overallScore;
  final String trend;
  final List<String> strengths;
  final List<String> weaknesses;
  final double learningVelocity;
  final double retentionRate;
  final String optimalStudyTime;

  LearningAnalysis({
    required this.overallScore,
    required this.trend,
    required this.strengths,
    required this.weaknesses,
    required this.learningVelocity,
    required this.retentionRate,
    required this.optimalStudyTime,
  });
}

class AIRecommendation {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String category;
  final String impact;
  final String icon;
  final List<String> actionSteps;
  final bool isApplied;

  AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.impact,
    required this.icon,
    required this.actionSteps,
    this.isApplied = false,
  });

  AIRecommendation copyWith({bool? isApplied}) {
    return AIRecommendation(
      id: id,
      title: title,
      description: description,
      priority: priority,
      category: category,
      impact: impact,
      icon: icon,
      actionSteps: actionSteps,
      isApplied: isApplied ?? this.isApplied,
    );
  }
}

class PredictedOutcome {
  final String scenario;
  final int examScore;
  final DateTime readinessDate;
  final double confidence;
  final List<String> factors;

  PredictedOutcome({
    required this.scenario,
    required this.examScore,
    required this.readinessDate,
    required this.confidence,
    required this.factors,
  });
}

class PatternInsights {
  final List<StudyPattern> studyPatterns;
  final List<List<double>> weeklyHeatmap;
  final Map<String, double> focusDistribution;

  PatternInsights({
    required this.studyPatterns,
    required this.weeklyHeatmap,
    required this.focusDistribution,
  });
}

class StudyPattern {
  final String name;
  final double frequency;
  final double effectiveness;
  final String description;

  StudyPattern({
    required this.name,
    required this.frequency,
    required this.effectiveness,
    required this.description,
  });
}

class AIInsightsScreen extends ConsumerWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiInsightsProvider);
    final theme = Theme.of(context);

    if (state.isLoading || state.analysis == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(aiInsightsProvider.notifier).loadInsights();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Learning Score Card
            _LearningScoreCard(analysis: state.analysis!),

            AppSpacing.verticalGapXL,

            // AI Recommendations
            _RecommendationsSection(
              recommendations: state.recommendations,
              onApply: (id) {
                ref.read(aiInsightsProvider.notifier).applyRecommendation(id);
              },
            ),

            AppSpacing.verticalGapXL,

            // Predicted Outcomes
            _PredictedOutcomesSection(predictions: state.predictions),

            AppSpacing.verticalGapXL,

            // Study Patterns
            _StudyPatternsSection(patterns: state.patterns!),

            AppSpacing.verticalGapXL,

            // Weekly Heatmap
            _WeeklyHeatmapSection(heatmap: state.patterns!.weeklyHeatmap),

            AppSpacing.verticalGapXL,

            // Subject Distribution
            _SubjectDistributionSection(
              distribution: state.patterns!.focusDistribution,
            ),

            AppSpacing.verticalGapXL,
          ],
        ),
      ),
    );
  }
}

class _LearningScoreCard extends StatelessWidget {
  final LearningAnalysis analysis;

  const _LearningScoreCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: AppSpacing.paddingLG,
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Score',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${analysis.overallScore}',
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Icon(
                          analysis.trend == 'improving'
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CircularProgressIndicator(
                value: analysis.overallScore / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 8,
              ),
            ],
          ),

          AppSpacing.verticalGapMD,

          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _MetricRow(
                  icon: Icons.speed,
                  label: 'Learning Velocity',
                  value: '${analysis.learningVelocity}x',
                ),
                const Divider(color: Colors.white24),
                _MetricRow(
                  icon: Icons.psychology,
                  label: 'Retention Rate',
                  value: '${(analysis.retentionRate * 100).round()}%',
                ),
                const Divider(color: Colors.white24),
                _MetricRow(
                  icon: Icons.access_time,
                  label: 'Optimal Time',
                  value: analysis.optimalStudyTime,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  final List<AIRecommendation> recommendations;
  final Function(String) onApply;

  const _RecommendationsSection({
    required this.recommendations,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Recommendations',
            style: AppTypography.titleLarge,
          ),
          Text(
            'Personalized suggestions to boost your learning',
            style: AppTypography.caption,
          ),

          AppSpacing.verticalGapMD,

          ...recommendations.asMap().entries.map((entry) => 
            _RecommendationCard(
              recommendation: entry.value,
              index: entry.key,
              onApply: onApply,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final AIRecommendation recommendation;
  final int index;
  final Function(String) onApply;

  const _RecommendationCard({
    required this.recommendation,
    required this.index,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: recommendation.isApplied ? null : () => _showDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(recommendation.priority)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        recommendation.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: AppTypography.titleMedium,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(recommendation.priority)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                recommendation.priority.toUpperCase(),
                                style: AppTypography.caption.copyWith(
                                  color: _getPriorityColor(recommendation.priority),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            AppSpacing.horizontalGapSM,
                            Text(
                              recommendation.category,
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (recommendation.isApplied)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                ],
              ),

              AppSpacing.verticalGapMD,

              Text(
                recommendation.description,
                style: AppTypography.body.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),

              AppSpacing.verticalGapSM,

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      recommendation.impact,
                      style: AppTypography.caption.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index))
      .slideX(begin: 0.1, end: 0);
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingXL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          recommendation.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                        AppSpacing.horizontalGapMD,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recommendation.title,
                                style: AppTypography.titleLarge,
                              ),
                              Text(
                                recommendation.impact,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.verticalGapXL,

                    Text(
                      recommendation.description,
                      style: AppTypography.body,
                    ),

                    AppSpacing.verticalGapXL,

                    Text(
                      'Action Steps',
                      style: AppTypography.titleMedium,
                    ),

                    AppSpacing.verticalGapMD,

                    ...recommendation.actionSteps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${recommendation.actionSteps.indexOf(step) + 1}',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.horizontalGapMD,
                          Expanded(
                            child: Text(
                              step,
                              style: AppTypography.body,
                            ),
                          ),
                        ],
                      ),
                    )),

                    AppSpacing.verticalGapXL,

                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () {
                          onApply(recommendation.id);
                          Navigator.pop(context);
                        },
                        child: const Text('Apply Recommendation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictedOutcomesSection extends StatelessWidget {
  final List<PredictedOutcome> predictions;

  const _PredictedOutcomesSection({required this.predictions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predicted Outcomes',
            style: AppTypography.titleLarge,
          ),
          Text(
            'AI projections based on your current trajectory',
            style: AppTypography.caption,
          ),

          AppSpacing.verticalGapMD,

          Row(
            children: predictions.map((prediction) => Expanded(
              child: _PredictionCard(prediction: prediction),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictedOutcome prediction;

  const _PredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOptimized = prediction.scenario.contains('Optimized');

    return Card(
      margin: EdgeInsets.only(
        left: isOptimized ? 8 : 0,
        right: isOptimized ? 0 : 8,
      ),
      elevation: isOptimized ? 8 : 2,
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isOptimized
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOptimized ? Icons.rocket_launch : Icons.timeline,
                  color: isOptimized
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
                AppSpacing.horizontalGapSM,
                Text(
                  prediction.scenario,
                  style: AppTypography.titleSmall,
                ),
              ],
            ),

            AppSpacing.verticalGapMD,

            Text(
              '${prediction.examScore}%',
              style: AppTypography.display.copyWith(
                color: isOptimized
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Predicted Score',
              style: AppTypography.caption,
            ),

            AppSpacing.verticalGapMD,

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ready in ${prediction.readinessDate.difference(DateTime.now()).inDays} days',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalGapSM,

            LinearProgressIndicator(
              value: prediction.confidence,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOptimized ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(prediction.confidence * 100).round()}% confidence',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyPatternsSection extends StatelessWidget {
  final PatternInsights patterns;

  const _StudyPatternsSection({required this.patterns});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Study Patterns',
            style: AppTypography.titleLarge,
          ),

          AppSpacing.verticalGapMD,

          ...patterns.studyPatterns.map((pattern) => _PatternCard(
            pattern: pattern,
          )),
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final StudyPattern pattern;

  const _PatternCard({required this.pattern});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pattern.name,
                style: AppTypography.titleSmall,
              ),
              Row(
                children: [
                  _MiniMetric(
                    label: 'Frequency',
                    value: '${(pattern.frequency * 100).round()}%',
                    color: Colors.blue,
                  ),
                  AppSpacing.horizontalGapMD,
                  _MiniMetric(
                    label: 'Effectiveness',
                    value: '${(pattern.effectiveness * 100).round()}%',
                    color: pattern.effectiveness > 0.7
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.verticalGapSM,
          Text(
            pattern.description,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class _WeeklyHeatmapSection extends StatelessWidget {
  final List<List<double>> heatmap;

  const _WeeklyHeatmapSection({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Activity Heatmap',
            style: AppTypography.titleLarge,
          ),
          Text(
            'Your study consistency over the past 4 weeks',
            style: AppTypography.caption,
          ),

          AppSpacing.verticalGapMD,

          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                // Day labels
                Row(
                  children: [
                    const SizedBox(width: 40),
                    ...days.map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: AppTypography.caption,
                        ),
                      ),
                    )),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Heatmap grid
                ...heatmap.asMap().entries.map((weekEntry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          'W${weekEntry.key + 1}',
                          style: AppTypography.caption,
                        ),
                      ),
                      ...weekEntry.value.map((intensity) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getHeatmapColor(intensity),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )),
                    ],
                  ),
                )),

                AppSpacing.verticalGapMD,

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Less', style: AppTypography.caption),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(index / 4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                    const SizedBox(width: 8),
                    Text('More', style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity < 0.2) return Colors.grey.shade200;
    if (intensity < 0.4) return Colors.green.shade200;
    if (intensity < 0.6) return Colors.green.shade300;
    if (intensity < 0.8) return Colors.green.shade400;
    return Colors.green.shade600;
  }
}

class _SubjectDistributionSection extends StatelessWidget {
  final Map<String, double> distribution;

  const _SubjectDistributionSection({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Focus Distribution',
            style: AppTypography.titleLarge,
          ),

          AppSpacing.verticalGapMD,

          Container(
            height: 200,
            padding: AppSpacing.paddingMD,
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
            child: PieChart(
              PieChartData(
                sections: sortedEntries.map((entry) => PieChartSectionData(
                  value: entry.value,
                  title: '${(entry.value * 100).round()}%',
                  color: _getSubjectColor(entry.key),
                  radius: 80,
                  titleStyle: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),

          AppSpacing.verticalGapMD,

          // Legend
          ...sortedEntries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getSubjectColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.horizontalGapSM,
                Text(entry.key, style: AppTypography.body),
                const Spacer(),
                Text(
                  '${(entry.value * 100).round()}%',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final colors = {
      'Mathematics': Colors.blue,
      'English': Colors.purple,
      'Science': Colors.green,
      'History': Colors.orange,
      'Other': Colors.grey,
    };
    return colors[subject] ?? Colors.grey;
  }
}