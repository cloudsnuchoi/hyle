import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for analyzing and identifying learning patterns
class LearningPatternAnalyzer {
  static final LearningPatternAnalyzer _instance = LearningPatternAnalyzer._internal();
  factory LearningPatternAnalyzer() => _instance;
  LearningPatternAnalyzer._internal();

  // Pattern detection thresholds
  static const double _patternConfidenceThreshold = 0.7;
  static const int _minDataPoints = 7;

  /// Analyze comprehensive learning patterns
  Future<LearningPatternAnalysis> analyzeLearningPatterns({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Collect multi-dimensional data
      final studyData = await _collectStudyData(userId, startDate, endDate);
      
      // Analyze different pattern dimensions
      final temporalPatterns = await _analyzeTemporalPatterns(studyData);
      final subjectPatterns = await _analyzeSubjectPatterns(studyData);
      final performancePatterns = await _analyzePerformancePatterns(studyData);
      final behavioralPatterns = await _analyzeBehavioralPatterns(studyData);
      final cognitivePatterns = await _analyzeCognitivePatterns(studyData);
      
      // Identify learning style
      final learningStyle = _identifyLearningStyle(
        temporal: temporalPatterns,
        subject: subjectPatterns,
        behavioral: behavioralPatterns,
      );
      
      // Generate insights
      final insights = _generatePatternInsights(
        temporal: temporalPatterns,
        subject: subjectPatterns,
        performance: performancePatterns,
        behavioral: behavioralPatterns,
        cognitive: cognitivePatterns,
      );
      
      // Create optimization recommendations
      final optimizations = _createOptimizationRecommendations(
        patterns: [temporalPatterns, subjectPatterns, performancePatterns],
        learningStyle: learningStyle,
      );
      
      return LearningPatternAnalysis(
        userId: userId,
        period: DateTimeRange(start: startDate, end: endDate),
        temporalPatterns: temporalPatterns,
        subjectPatterns: subjectPatterns,
        performancePatterns: performancePatterns,
        behavioralPatterns: behavioralPatterns,
        cognitivePatterns: cognitivePatterns,
        learningStyle: learningStyle,
        insights: insights,
        optimizations: optimizations,
        patternStrength: _calculateOverallPatternStrength(
          [temporalPatterns, subjectPatterns, performancePatterns],
        ),
      );
    } catch (e) {
      safePrint('Error analyzing learning patterns: $e');
      rethrow;
    }
  }

  /// Analyze temporal patterns (when user learns best)
  Future<TemporalPatterns> _analyzeTemporalPatterns(StudyData data) async {
    // Analyze by hour of day
    final hourlyPerformance = <int, PerformanceMetrics>{};
    final hourlySessions = <int, int>{};
    
    for (final session in data.sessions) {
      final hour = session.startTime.hour;
      hourlySessions[hour] = (hourlySessions[hour] ?? 0) + 1;
      
      if (!hourlyPerformance.containsKey(hour)) {
        hourlyPerformance[hour] = PerformanceMetrics();
      }
      
      hourlyPerformance[hour]!.addSession(
        performance: session.performance,
        duration: session.duration,
        focus: session.focusScore,
      );
    }
    
    // Find peak performance hours
    final peakHours = _findPeakHours(hourlyPerformance);
    
    // Analyze by day of week
    final weekdayPatterns = _analyzeWeekdayPatterns(data.sessions);
    
    // Analyze session duration preferences
    final durationPreference = _analyzeDurationPreference(data.sessions);
    
    // Analyze consistency patterns
    final consistencyScore = _calculateConsistencyScore(data.sessions);
    
    return TemporalPatterns(
      peakPerformanceHours: peakHours,
      preferredStudyTimes: _identifyPreferredTimes(hourlySessions),
      weekdayDistribution: weekdayPatterns,
      optimalSessionDuration: durationPreference.optimalDuration,
      durationTolerance: durationPreference.tolerance,
      consistencyScore: consistencyScore,
      timeZoneStability: _analyzeTimeZoneStability(data.sessions),
      breakPatterns: _analyzeBreakPatterns(data.sessions),
    );
  }

  /// Analyze subject-specific patterns
  Future<SubjectPatterns> _analyzeSubjectPatterns(StudyData data) async {
    final subjectMetrics = <String, SubjectMetrics>{};
    
    // Group sessions by subject
    for (final session in data.sessions) {
      if (session.subject != null) {
        subjectMetrics[session.subject!] ??= SubjectMetrics();
        subjectMetrics[session.subject!]!.addSession(session);
      }
    }
    
    // Analyze each subject
    final subjectAnalysis = <String, SubjectAnalysis>{};
    
    subjectMetrics.forEach((subject, metrics) {
      subjectAnalysis[subject] = SubjectAnalysis(
        subject: subject,
        averagePerformance: metrics.averagePerformance,
        learningVelocity: metrics.calculateVelocity(),
        preferredTime: metrics.getPreferredTime(),
        optimalSessionLength: metrics.getOptimalDuration(),
        conceptMasteryRate: metrics.masteryRate,
        difficulty: metrics.perceivedDifficulty,
        engagement: metrics.engagementScore,
        switchingPenalty: _calculateSwitchingPenalty(subject, data.sessions),
      );
    });
    
    // Identify subject preferences
    final preferences = _identifySubjectPreferences(subjectAnalysis);
    
    // Analyze interleaving benefits
    final interleavingAnalysis = _analyzeInterleaving(data.sessions);
    
    return SubjectPatterns(
      subjectAnalysis: subjectAnalysis,
      preferences: preferences,
      strongestSubjects: _identifyStrongestSubjects(subjectAnalysis),
      weakestSubjects: _identifyWeakestSubjects(subjectAnalysis),
      optimalSubjectSequence: _findOptimalSequence(subjectAnalysis),
      interleavingBenefit: interleavingAnalysis.benefit,
      subjectSynergyMap: _buildSynergyMap(data.sessions),
    );
  }

  /// Analyze performance patterns
  Future<PerformancePatterns> _analyzePerformancePatterns(StudyData data) async {
    // Analyze performance trends
    final overallTrend = _calculatePerformanceTrend(data.sessions);
    
    // Identify performance cycles
    final cycles = _detectPerformanceCycles(data.sessions);
    
    // Analyze factors affecting performance
    final factors = _analyzePerformanceFactors(data);
    
    // Detect plateaus and breakthroughs
    final plateaus = _detectPlateaus(data.sessions);
    final breakthroughs = _detectBreakthroughs(data.sessions);
    
    // Analyze error patterns
    final errorPatterns = _analyzeErrorPatterns(data.mistakes);
    
    return PerformancePatterns(
      overallTrend: overallTrend,
      performanceCycles: cycles,
      plateaus: plateaus,
      breakthroughs: breakthroughs,
      performanceFactors: factors,
      errorPatterns: errorPatterns,
      improvementRate: _calculateImprovementRate(data.sessions),
      stabilityScore: _calculateStabilityScore(data.sessions),
      adaptabilityScore: _calculateAdaptabilityScore(data.sessions),
    );
  }

  /// Analyze behavioral patterns
  Future<BehavioralPatterns> _analyzeBehavioralPatterns(StudyData data) async {
    return BehavioralPatterns(
      procrastinationScore: _analyzeProcrastination(data),
      persistenceScore: _analyzePersistence(data),
      helpSeekingBehavior: _analyzeHelpSeeking(data),
      resourceUtilization: _analyzeResourceUsage(data),
      taskPrioritization: _analyzeTaskPrioritization(data),
      multitaskingTendency: _analyzeMultitasking(data),
      breakTakingBehavior: _analyzeBreakBehavior(data),
      goalSettingStyle: _analyzeGoalSetting(data),
    );
  }

  /// Analyze cognitive patterns
  Future<CognitivePatterns> _analyzeCognitivePatterns(StudyData data) async {
    return CognitivePatterns(
      workingMemoryCapacity: _estimateWorkingMemory(data),
      attentionSpan: _calculateAttentionSpan(data),
      processingSpeed: _estimateProcessingSpeed(data),
      abstractionLevel: _analyzeAbstractionLevel(data),
      metacognitionScore: _analyzeMetacognition(data),
      transferLearning: _analyzeTransferLearning(data),
      conceptualUnderstanding: _analyzeConceptualDepth(data),
      problemSolvingApproach: _analyzeProblemSolving(data),
    );
  }

  /// Identify learning style based on patterns
  LearningStyle _identifyLearningStyle({
    required TemporalPatterns temporal,
    required SubjectPatterns subject,
    required BehavioralPatterns behavioral,
  }) {
    // Analyze multiple dimensions to determine style
    final scores = <String, double>{
      'visual': 0.0,
      'auditory': 0.0,
      'kinesthetic': 0.0,
      'reading_writing': 0.0,
    };
    
    // Weight different factors
    // Visual learners tend to have better performance with diagrams/charts
    if (behavioral.resourceUtilization['visual_aids'] ?? 0 > 0.7) {
      scores['visual'] = scores['visual']! + 0.3;
    }
    
    // Kinesthetic learners prefer shorter, active sessions
    if (temporal.optimalSessionDuration < 30 && behavioral.breakTakingBehavior > 0.6) {
      scores['kinesthetic'] = scores['kinesthetic']! + 0.3;
    }
    
    // Reading/writing learners spend more time on text-based resources
    if (behavioral.resourceUtilization['text_resources'] ?? 0 > 0.6) {
      scores['reading_writing'] = scores['reading_writing']! + 0.3;
    }
    
    // Find dominant style
    final dominantStyle = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return LearningStyle(
      primary: dominantStyle,
      secondary: _findSecondaryStyle(scores, dominantStyle),
      scores: scores,
      confidence: _calculateStyleConfidence(scores),
    );
  }

  /// Generate insights from patterns
  List<PatternInsight> _generatePatternInsights({
    required TemporalPatterns temporal,
    required SubjectPatterns subject,
    required PerformancePatterns performance,
    required BehavioralPatterns behavioral,
    required CognitivePatterns cognitive,
  }) {
    final insights = <PatternInsight>[];
    
    // Temporal insights
    if (temporal.peakPerformanceHours.isNotEmpty) {
      insights.add(PatternInsight(
        type: InsightType.temporal,
        title: 'Peak Performance Hours',
        description: 'You perform best between ${temporal.peakPerformanceHours.first}:00 and ${temporal.peakPerformanceHours.last}:00',
        actionable: 'Schedule your most challenging tasks during these hours',
        impact: ImpactLevel.high,
      ));
    }
    
    // Subject insights
    if (subject.interleavingBenefit > 0.15) {
      insights.add(PatternInsight(
        type: InsightType.subject,
        title: 'Interleaving Benefits You',
        description: 'Switching between subjects improves your retention by ${(subject.interleavingBenefit * 100).round()}%',
        actionable: 'Mix different subjects in your study sessions',
        impact: ImpactLevel.medium,
      ));
    }
    
    // Performance insights
    if (performance.plateaus.isNotEmpty) {
      insights.add(PatternInsight(
        type: InsightType.performance,
        title: 'Plateau Detected',
        description: 'You\'ve been at a performance plateau for ${performance.plateaus.last.duration} days',
        actionable: 'Try new learning methods or increase difficulty',
        impact: ImpactLevel.high,
      ));
    }
    
    // Behavioral insights
    if (behavioral.procrastinationScore > 0.6) {
      insights.add(PatternInsight(
        type: InsightType.behavioral,
        title: 'Procrastination Pattern',
        description: 'You tend to delay starting tasks by an average of ${(behavioral.procrastinationScore * 60).round()} minutes',
        actionable: 'Use the 2-minute rule to start tasks immediately',
        impact: ImpactLevel.medium,
      ));
    }
    
    // Cognitive insights
    if (cognitive.attentionSpan < 20) {
      insights.add(PatternInsight(
        type: InsightType.cognitive,
        title: 'Short Attention Span',
        description: 'Your effective attention span is around ${cognitive.attentionSpan} minutes',
        actionable: 'Use Pomodoro technique with ${cognitive.attentionSpan}-minute focus periods',
        impact: ImpactLevel.high,
      ));
    }
    
    return insights;
  }

  /// Create optimization recommendations
  List<OptimizationRecommendation> _createOptimizationRecommendations({
    required List<dynamic> patterns,
    required LearningStyle learningStyle,
  }) {
    final recommendations = <OptimizationRecommendation>[];
    
    // Schedule optimization
    recommendations.add(OptimizationRecommendation(
      category: 'Schedule',
      title: 'Optimize Study Schedule',
      description: 'Align your study sessions with peak performance hours',
      expectedImprovement: 0.15,
      implementation: [
        'Move difficult tasks to peak hours',
        'Schedule reviews during moderate performance times',
        'Avoid studying during low-energy periods',
      ],
      priority: 1,
    ));
    
    // Method optimization based on learning style
    recommendations.add(OptimizationRecommendation(
      category: 'Methods',
      title: 'Adapt to Your Learning Style',
      description: 'Use ${learningStyle.primary}-based learning techniques',
      expectedImprovement: 0.20,
      implementation: _getStyleSpecificMethods(learningStyle.primary),
      priority: 2,
    ));
    
    return recommendations;
  }

  // Helper methods

  List<int> _findPeakHours(Map<int, PerformanceMetrics> hourlyPerformance) {
    if (hourlyPerformance.isEmpty) return [];
    
    // Calculate average performance for each hour
    final hourScores = <int, double>{};
    
    hourlyPerformance.forEach((hour, metrics) {
      hourScores[hour] = metrics.averagePerformance * metrics.averageFocus;
    });
    
    // Sort by score
    final sorted = hourScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Return top performing hours
    return sorted
        .take(3)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  Map<String, double> _analyzeWeekdayPatterns(List<PatternStudySession> sessions) {
    final weekdayStats = <int, List<double>>{};
    
    for (final session in sessions) {
      final weekday = session.startTime.weekday;
      weekdayStats[weekday] ??= [];
      weekdayStats[weekday]!.add(session.performance);
    }
    
    final patterns = <String, double>{};
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    for (int i = 1; i <= 7; i++) {
      if (weekdayStats.containsKey(i) && weekdayStats[i]!.isNotEmpty) {
        patterns[weekdays[i - 1]] = 
            weekdayStats[i]!.reduce((a, b) => a + b) / weekdayStats[i]!.length;
      }
    }
    
    return patterns;
  }

  DurationPreference _analyzeDurationPreference(List<PatternStudySession> sessions) {
    // Group sessions by duration buckets
    final durationBuckets = <int, List<double>>{};
    
    for (final session in sessions) {
      final bucket = (session.duration / 15).round() * 15; // 15-minute buckets
      durationBuckets[bucket] ??= [];
      durationBuckets[bucket]!.add(session.performance * session.focusScore);
    }
    
    // Find optimal duration
    int optimalDuration = 45;
    double maxScore = 0;
    
    durationBuckets.forEach((duration, scores) {
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      if (avgScore > maxScore) {
        maxScore = avgScore;
        optimalDuration = duration;
      }
    });
    
    // Calculate tolerance
    final tolerance = _calculateDurationTolerance(durationBuckets, optimalDuration);
    
    return DurationPreference(
      optimalDuration: optimalDuration,
      tolerance: tolerance,
    );
  }

  double _calculateConsistencyScore(List<PatternStudySession> sessions) {
    if (sessions.length < 2) return 0.0;
    
    // Calculate gaps between sessions
    final gaps = <int>[];
    
    for (int i = 1; i < sessions.length; i++) {
      gaps.add(sessions[i].startTime.difference(sessions[i-1].startTime).inDays);
    }
    
    // Calculate consistency based on gap variance
    final avgGap = gaps.reduce((a, b) => a + b) / gaps.length;
    final variance = gaps
        .map((g) => math.pow(g - avgGap, 2))
        .reduce((a, b) => a + b) / gaps.length;
    
    // Convert to 0-1 score (lower variance = higher consistency)
    return 1 / (1 + variance / avgGap);
  }

  double _calculateOverallPatternStrength(List<dynamic> patterns) {
    // Aggregate pattern confidence scores
    double totalStrength = 0;
    int count = 0;
    
    for (final pattern in patterns) {
      if (pattern is TemporalPatterns) {
        totalStrength += pattern.consistencyScore;
        count++;
      }
      // Add other pattern types...
    }
    
    return count > 0 ? totalStrength / count : 0.5;
  }

  List<String> _getStyleSpecificMethods(String style) {
    switch (style) {
      case 'visual':
        return [
          'Use mind maps and diagrams',
          'Create visual flashcards',
          'Watch educational videos',
          'Use color coding for notes',
        ];
      case 'kinesthetic':
        return [
          'Take frequent breaks to move',
          'Use hands-on practice',
          'Walk while reviewing',
          'Build physical models',
        ];
      case 'auditory':
        return [
          'Record and listen to notes',
          'Discuss topics out loud',
          'Use mnemonic devices',
          'Listen to educational podcasts',
        ];
      case 'reading_writing':
        return [
          'Take detailed notes',
          'Rewrite key concepts',
          'Create summaries',
          'Use written practice problems',
        ];
      default:
        return ['Experiment with different methods'];
    }
  }

  Future<StudyData> _collectStudyData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Collect comprehensive study data
    // In production, this would fetch from database
    return StudyData(
      sessions: [],
      mistakes: [],
      resources: [],
      goals: [],
    );
  }

  double _calculateDurationTolerance(
    Map<int, List<double>> buckets,
    int optimal,
  ) {
    // Calculate how performance varies with duration
    double totalVariance = 0;
    int count = 0;
    
    buckets.forEach((duration, scores) {
      if ((duration - optimal).abs() <= 30) {
        final avgScore = scores.reduce((a, b) => a + b) / scores.length;
        totalVariance += (avgScore - 1).abs();
        count++;
      }
    });
    
    return count > 0 ? 1 - (totalVariance / count) : 0.5;
  }

  List<String> _identifyPreferredTimes(Map<int, int> hourlySessions) {
    final sorted = hourlySessions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted
        .take(3)
        .map((e) => '${e.key}:00')
        .toList();
  }

  double _analyzeTimeZoneStability(List<PatternStudySession> sessions) {
    // Check if study times are consistent across days
    return 0.8; // Simplified
  }

  BreakPattern _analyzeBreakPatterns(List<PatternStudySession> sessions) {
    return BreakPattern(
      averageBreakDuration: 10,
      breakFrequency: 45,
      effectivenessScore: 0.8,
    );
  }

  double _calculateSwitchingPenalty(String subject, List<PatternStudySession> sessions) {
    // Analyze performance when switching to/from this subject
    return 0.1; // Simplified
  }

  List<String> _identifyStrongestSubjects(Map<String, SubjectAnalysis> analysis) {
    final sorted = analysis.entries.toList()
      ..sort((a, b) => b.value.averagePerformance.compareTo(a.value.averagePerformance));
    
    return sorted.take(3).map((e) => e.key).toList();
  }

  List<String> _identifyWeakestSubjects(Map<String, SubjectAnalysis> analysis) {
    final sorted = analysis.entries.toList()
      ..sort((a, b) => a.value.averagePerformance.compareTo(b.value.averagePerformance));
    
    return sorted.take(3).map((e) => e.key).toList();
  }

  String _findSecondaryStyle(Map<String, double> scores, String primary) {
    final filtered = Map<String, double>.from(scores)..remove(primary);
    
    if (filtered.isEmpty) return 'mixed';
    
    return filtered.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double _calculateStyleConfidence(Map<String, double> scores) {
    if (scores.isEmpty) return 0.0;
    
    final values = scores.values.toList()..sort((a, b) => b.compareTo(a));
    
    if (values.length < 2) return values.first;
    
    // Confidence based on difference between top two styles
    return (values[0] - values[1]).clamp(0.0, 1.0);
  }

  // Additional helper methods would be implemented here...
  
  PerformanceTrend _calculatePerformanceTrend(List<PatternStudySession> sessions) {
    return PerformanceTrend(
      direction: 'improving',
      strength: 0.15,
      consistency: 0.8,
    );
  }

  List<PerformanceCycle> _detectPerformanceCycles(List<PatternStudySession> sessions) {
    return [];
  }

  Map<String, double> _analyzePerformanceFactors(StudyData data) {
    return {
      'time_of_day': 0.3,
      'subject_difficulty': 0.25,
      'session_duration': 0.2,
      'previous_rest': 0.15,
      'motivation': 0.1,
    };
  }

  List<Plateau> _detectPlateaus(List<PatternStudySession> sessions) {
    return [];
  }

  List<Breakthrough> _detectBreakthroughs(List<PatternStudySession> sessions) {
    return [];
  }

  ErrorPatternAnalysis _analyzeErrorPatterns(List<Mistake> mistakes) {
    return ErrorPatternAnalysis(
      commonErrorTypes: {},
      errorFrequency: {},
      improvementRate: 0.0,
    );
  }

  double _calculateImprovementRate(List<PatternStudySession> sessions) {
    return 0.05;
  }

  double _calculateStabilityScore(List<PatternStudySession> sessions) {
    return 0.75;
  }

  double _calculateAdaptabilityScore(List<PatternStudySession> sessions) {
    return 0.8;
  }

  SubjectPreferences _identifySubjectPreferences(Map<String, SubjectAnalysis> analysis) {
    return SubjectPreferences(
      preferredSubjects: [],
      avoidedSubjects: [],
      optimalMixRatio: {},
    );
  }

  InterleavingAnalysis _analyzeInterleaving(List<PatternStudySession> sessions) {
    return InterleavingAnalysis(benefit: 0.15);
  }

  List<String> _findOptimalSequence(Map<String, SubjectAnalysis> analysis) {
    return analysis.keys.toList();
  }

  Map<String, Map<String, double>> _buildSynergyMap(List<PatternStudySession> sessions) {
    return {};
  }

  double _analyzeProcrastination(StudyData data) {
    return 0.3;
  }

  double _analyzePersistence(StudyData data) {
    return 0.8;
  }

  double _analyzeHelpSeeking(StudyData data) {
    return 0.6;
  }

  Map<String, double> _analyzeResourceUsage(StudyData data) {
    return {
      'visual_aids': 0.7,
      'text_resources': 0.6,
      'practice_problems': 0.8,
      'video_content': 0.5,
    };
  }

  double _analyzeTaskPrioritization(StudyData data) {
    return 0.75;
  }

  double _analyzeMultitasking(StudyData data) {
    return 0.2;
  }

  double _analyzeBreakBehavior(StudyData data) {
    return 0.7;
  }

  String _analyzeGoalSetting(StudyData data) {
    return 'ambitious';
  }

  double _estimateWorkingMemory(StudyData data) {
    return 7.0;
  }

  double _calculateAttentionSpan(StudyData data) {
    return 25.0;
  }

  double _estimateProcessingSpeed(StudyData data) {
    return 0.8;
  }

  double _analyzeAbstractionLevel(StudyData data) {
    return 0.7;
  }

  double _analyzeMetacognition(StudyData data) {
    return 0.75;
  }

  double _analyzeTransferLearning(StudyData data) {
    return 0.6;
  }

  double _analyzeConceptualDepth(StudyData data) {
    return 0.8;
  }

  String _analyzeProblemSolving(StudyData data) {
    return 'systematic';
  }
}

// Data models
class LearningPatternAnalysis {
  final String userId;
  final DateTimeRange period;
  final TemporalPatterns temporalPatterns;
  final SubjectPatterns subjectPatterns;
  final PerformancePatterns performancePatterns;
  final BehavioralPatterns behavioralPatterns;
  final CognitivePatterns cognitivePatterns;
  final LearningStyle learningStyle;
  final List<PatternInsight> insights;
  final List<OptimizationRecommendation> optimizations;
  final double patternStrength;

  LearningPatternAnalysis({
    required this.userId,
    required this.period,
    required this.temporalPatterns,
    required this.subjectPatterns,
    required this.performancePatterns,
    required this.behavioralPatterns,
    required this.cognitivePatterns,
    required this.learningStyle,
    required this.insights,
    required this.optimizations,
    required this.patternStrength,
  });
}

class TemporalPatterns {
  final List<int> peakPerformanceHours;
  final List<String> preferredStudyTimes;
  final Map<String, double> weekdayDistribution;
  final int optimalSessionDuration;
  final double durationTolerance;
  final double consistencyScore;
  final double timeZoneStability;
  final BreakPattern breakPatterns;

  TemporalPatterns({
    required this.peakPerformanceHours,
    required this.preferredStudyTimes,
    required this.weekdayDistribution,
    required this.optimalSessionDuration,
    required this.durationTolerance,
    required this.consistencyScore,
    required this.timeZoneStability,
    required this.breakPatterns,
  });
}

class SubjectPatterns {
  final Map<String, SubjectAnalysis> subjectAnalysis;
  final SubjectPreferences preferences;
  final List<String> strongestSubjects;
  final List<String> weakestSubjects;
  final List<String> optimalSubjectSequence;
  final double interleavingBenefit;
  final Map<String, Map<String, double>> subjectSynergyMap;

  SubjectPatterns({
    required this.subjectAnalysis,
    required this.preferences,
    required this.strongestSubjects,
    required this.weakestSubjects,
    required this.optimalSubjectSequence,
    required this.interleavingBenefit,
    required this.subjectSynergyMap,
  });
}

class PerformancePatterns {
  final PerformanceTrend overallTrend;
  final List<PerformanceCycle> performanceCycles;
  final List<Plateau> plateaus;
  final List<Breakthrough> breakthroughs;
  final Map<String, double> performanceFactors;
  final ErrorPatternAnalysis errorPatterns;
  final double improvementRate;
  final double stabilityScore;
  final double adaptabilityScore;

  PerformancePatterns({
    required this.overallTrend,
    required this.performanceCycles,
    required this.plateaus,
    required this.breakthroughs,
    required this.performanceFactors,
    required this.errorPatterns,
    required this.improvementRate,
    required this.stabilityScore,
    required this.adaptabilityScore,
  });
}

class BehavioralPatterns {
  final double procrastinationScore;
  final double persistenceScore;
  final double helpSeekingBehavior;
  final Map<String, double> resourceUtilization;
  final double taskPrioritization;
  final double multitaskingTendency;
  final double breakTakingBehavior;
  final String goalSettingStyle;

  BehavioralPatterns({
    required this.procrastinationScore,
    required this.persistenceScore,
    required this.helpSeekingBehavior,
    required this.resourceUtilization,
    required this.taskPrioritization,
    required this.multitaskingTendency,
    required this.breakTakingBehavior,
    required this.goalSettingStyle,
  });
}

class CognitivePatterns {
  final double workingMemoryCapacity;
  final double attentionSpan;
  final double processingSpeed;
  final double abstractionLevel;
  final double metacognitionScore;
  final double transferLearning;
  final double conceptualUnderstanding;
  final String problemSolvingApproach;

  CognitivePatterns({
    required this.workingMemoryCapacity,
    required this.attentionSpan,
    required this.processingSpeed,
    required this.abstractionLevel,
    required this.metacognitionScore,
    required this.transferLearning,
    required this.conceptualUnderstanding,
    required this.problemSolvingApproach,
  });
}

class LearningStyle {
  final String primary;
  final String secondary;
  final Map<String, double> scores;
  final double confidence;

  LearningStyle({
    required this.primary,
    required this.secondary,
    required this.scores,
    required this.confidence,
  });
}

class PatternInsight {
  final InsightType type;
  final String title;
  final String description;
  final String actionable;
  final ImpactLevel impact;

  PatternInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.actionable,
    required this.impact,
  });
}

enum InsightType { temporal, subject, performance, behavioral, cognitive }
enum ImpactLevel { low, medium, high }

class OptimizationRecommendation {
  final String category;
  final String title;
  final String description;
  final double expectedImprovement;
  final List<String> implementation;
  final int priority;

  OptimizationRecommendation({
    required this.category,
    required this.title,
    required this.description,
    required this.expectedImprovement,
    required this.implementation,
    required this.priority,
  });
}

// Supporting classes
class StudyData {
  final List<PatternStudySession> sessions;
  final List<Mistake> mistakes;
  final List<Resource> resources;
  final List<Goal> goals;

  StudyData({
    required this.sessions,
    required this.mistakes,
    required this.resources,
    required this.goals,
  });
}

class PatternStudySession {
  final DateTime startTime;
  final int duration;
  final String? subject;
  final double performance;
  final double focusScore;

  PatternStudySession({
    required this.startTime,
    required this.duration,
    this.subject,
    required this.performance,
    required this.focusScore,
  });
}

class PerformanceMetrics {
  final List<double> performances = [];
  final List<int> durations = [];
  final List<double> focusScores = [];

  void addSession({
    required double performance,
    required int duration,
    required double focus,
  }) {
    performances.add(performance);
    durations.add(duration);
    focusScores.add(focus);
  }

  double get averagePerformance =>
      performances.isEmpty ? 0 : performances.reduce((a, b) => a + b) / performances.length;

  double get averageFocus =>
      focusScores.isEmpty ? 0 : focusScores.reduce((a, b) => a + b) / focusScores.length;
}

class SubjectMetrics {
  final List<PatternStudySession> sessions = [];

  void addSession(PatternStudySession session) {
    sessions.add(session);
  }

  double get averagePerformance =>
      sessions.isEmpty ? 0 : sessions.map((s) => s.performance).reduce((a, b) => a + b) / sessions.length;

  double calculateVelocity() {
    if (sessions.length < 2) return 0;
    
    final first = sessions.first.performance;
    final last = sessions.last.performance;
    final days = sessions.last.startTime.difference(sessions.first.startTime).inDays;
    
    return days > 0 ? (last - first) / days : 0;
  }

  String getPreferredTime() {
    if (sessions.isEmpty) return 'Any';
    
    final hourCounts = <int, int>{};
    for (final session in sessions) {
      final hour = session.startTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final preferred = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return '$preferred:00';
  }

  int getOptimalDuration() {
    if (sessions.isEmpty) return 45;
    
    final durations = sessions.map((s) => s.duration).toList();
    durations.sort();
    
    return durations[durations.length ~/ 2]; // Median
  }

  double get masteryRate => 0.7; // Simplified
  double get perceivedDifficulty => 0.6; // Simplified
  double get engagementScore => 0.8; // Simplified
}

class SubjectAnalysis {
  final String subject;
  final double averagePerformance;
  final double learningVelocity;
  final String preferredTime;
  final int optimalSessionLength;
  final double conceptMasteryRate;
  final double difficulty;
  final double engagement;
  final double switchingPenalty;

  SubjectAnalysis({
    required this.subject,
    required this.averagePerformance,
    required this.learningVelocity,
    required this.preferredTime,
    required this.optimalSessionLength,
    required this.conceptMasteryRate,
    required this.difficulty,
    required this.engagement,
    required this.switchingPenalty,
  });
}

class DurationPreference {
  final int optimalDuration;
  final double tolerance;

  DurationPreference({
    required this.optimalDuration,
    required this.tolerance,
  });
}

class BreakPattern {
  final int averageBreakDuration;
  final int breakFrequency;
  final double effectivenessScore;

  BreakPattern({
    required this.averageBreakDuration,
    required this.breakFrequency,
    required this.effectivenessScore,
  });
}

class SubjectPreferences {
  final List<String> preferredSubjects;
  final List<String> avoidedSubjects;
  final Map<String, double> optimalMixRatio;

  SubjectPreferences({
    required this.preferredSubjects,
    required this.avoidedSubjects,
    required this.optimalMixRatio,
  });
}

class InterleavingAnalysis {
  final double benefit;

  InterleavingAnalysis({required this.benefit});
}

class PerformanceTrend {
  final String direction;
  final double strength;
  final double consistency;

  PerformanceTrend({
    required this.direction,
    required this.strength,
    required this.consistency,
  });
}

class PerformanceCycle {
  final int periodDays;
  final double amplitude;
  final String pattern;

  PerformanceCycle({
    required this.periodDays,
    required this.amplitude,
    required this.pattern,
  });
}

class Plateau {
  final DateTime startDate;
  final int duration;
  final double level;

  Plateau({
    required this.startDate,
    required this.duration,
    required this.level,
  });
}

class Breakthrough {
  final DateTime date;
  final double improvement;
  final String trigger;

  Breakthrough({
    required this.date,
    required this.improvement,
    required this.trigger,
  });
}

class ErrorPatternAnalysis {
  final Map<String, int> commonErrorTypes;
  final Map<String, double> errorFrequency;
  final double improvementRate;

  ErrorPatternAnalysis({
    required this.commonErrorTypes,
    required this.errorFrequency,
    required this.improvementRate,
  });
}

class Mistake {
  final String type;
  final String subject;
  final DateTime date;

  Mistake({
    required this.type,
    required this.subject,
    required this.date,
  });
}

class Resource {
  final String type;
  final String name;
  final int usageCount;

  Resource({
    required this.type,
    required this.name,
    required this.usageCount,
  });
}

class Goal {
  final String title;
  final DateTime targetDate;
  final double progress;

  Goal({
    required this.title,
    required this.targetDate,
    required this.progress,
  });
}