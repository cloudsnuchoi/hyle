import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for creating rich progress visualizations and analytics
class ProgressVisualizationService {
  static final ProgressVisualizationService _instance = ProgressVisualizationService._internal();
  factory ProgressVisualizationService() => _instance;
  ProgressVisualizationService._internal();

  /// Generate overall progress dashboard data
  Future<ProgressDashboard> generateProgressDashboard({
    required String userId,
    required DateTimeRange period,
    List<String>? subjects,
  }) async {
    try {
      // Fetch comprehensive progress data
      final progressData = await _fetchProgressData(userId, period, subjects);
      
      // Calculate key metrics
      final overallProgress = _calculateOverallProgress(progressData);
      final subjectProgress = _calculateSubjectProgress(progressData, subjects);
      final skillProgress = _calculateSkillProgress(progressData);
      
      // Generate time-based analytics
      final timeAnalytics = _generateTimeAnalytics(progressData);
      
      // Create trend analysis
      final trends = _analyzeTrends(progressData);
      
      // Generate milestone tracking
      final milestones = await _trackMilestones(userId, progressData);
      
      // Create comparative analysis
      final comparisons = _generateComparisons(progressData);
      
      // Generate insights
      final insights = _generateDashboardInsights(
        overall: overallProgress,
        subjects: subjectProgress,
        trends: trends,
      );
      
      return ProgressDashboard(
        userId: userId,
        period: period,
        overallProgress: overallProgress,
        subjectProgress: subjectProgress,
        skillProgress: skillProgress,
        timeAnalytics: timeAnalytics,
        trends: trends,
        milestones: milestones,
        comparisons: comparisons,
        insights: insights,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error generating progress dashboard: $e');
      rethrow;
    }
  }

  /// Create visual chart data for progress
  Future<ProgressChartData> generateChartData({
    required String userId,
    required ChartType type,
    required DateTimeRange period,
    Map<String, dynamic>? filters,
  }) async {
    try {
      switch (type) {
        case ChartType.lineChart:
          return await _generateLineChartData(userId, period, filters);
          
        case ChartType.barChart:
          return await _generateBarChartData(userId, period, filters);
          
        case ChartType.radarChart:
          return await _generateRadarChartData(userId, period, filters);
          
        case ChartType.heatmap:
          return await _generateHeatmapData(userId, period, filters);
          
        case ChartType.pieChart:
          return await _generatePieChartData(userId, period, filters);
          
        case ChartType.ganttChart:
          return await _generateGanttChartData(userId, period, filters);
      }
    } catch (e) {
      safePrint('Error generating chart data: $e');
      rethrow;
    }
  }

  /// Generate progress report
  Future<ProgressReport> generateProgressReport({
    required String userId,
    required ReportPeriod period,
    required ReportFormat format,
    List<String>? includeMetrics,
  }) async {
    try {
      // Get date range for period
      final dateRange = _getDateRangeForPeriod(period);
      
      // Fetch comprehensive data
      final progressData = await _fetchProgressData(userId, dateRange, null);
      
      // Generate report sections
      final summary = _generateExecutiveSummary(progressData);
      final detailedMetrics = _generateDetailedMetrics(progressData, includeMetrics);
      final achievements = await _generateAchievementsSummary(userId, dateRange);
      final recommendations = _generateRecommendations(progressData);
      
      // Create visualizations
      final visualizations = await _createReportVisualizations(
        progressData,
        format,
      );
      
      // Format report
      final formattedReport = _formatReport(
        summary: summary,
        metrics: detailedMetrics,
        achievements: achievements,
        recommendations: recommendations,
        visualizations: visualizations,
        format: format,
      );
      
      return ProgressReport(
        userId: userId,
        period: period,
        dateRange: dateRange,
        format: format,
        summary: summary,
        detailedMetrics: detailedMetrics,
        achievements: achievements,
        recommendations: recommendations,
        visualizations: visualizations,
        formattedContent: formattedReport,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error generating progress report: $e');
      rethrow;
    }
  }

  /// Create progress animation data
  Future<ProgressAnimation> createProgressAnimation({
    required String userId,
    required String metricId,
    required AnimationType animationType,
    Duration? duration,
  }) async {
    try {
      // Fetch metric history
      final history = await _fetchMetricHistory(userId, metricId);
      
      // Generate animation keyframes
      final keyframes = _generateKeyframes(
        history: history,
        animationType: animationType,
        duration: duration ?? const Duration(seconds: 3),
      );
      
      // Create easing functions
      final easingFunction = _selectEasingFunction(animationType);
      
      // Generate particle effects for achievements
      final particleEffects = _generateParticleEffects(history);
      
      return ProgressAnimation(
        metricId: metricId,
        animationType: animationType,
        duration: duration ?? const Duration(seconds: 3),
        keyframes: keyframes,
        easingFunction: easingFunction,
        particleEffects: particleEffects,
        triggerEvents: _identifyTriggerEvents(history),
      );
    } catch (e) {
      safePrint('Error creating progress animation: $e');
      rethrow;
    }
  }

  /// Generate skill tree visualization
  Future<SkillTreeVisualization> generateSkillTree({
    required String userId,
    required String subject,
  }) async {
    try {
      // Fetch skill data
      final skills = await _fetchUserSkills(userId, subject);
      
      // Build skill hierarchy
      final hierarchy = _buildSkillHierarchy(skills);
      
      // Calculate skill levels and unlocks
      final levels = _calculateSkillLevels(skills);
      final unlocks = _determineUnlocks(skills, hierarchy);
      
      // Create node positions for visualization
      final nodePositions = _calculateNodePositions(hierarchy);
      
      // Generate connections between skills
      final connections = _generateSkillConnections(hierarchy);
      
      // Create visual styling
      final styling = _createSkillTreeStyling(levels, unlocks);
      
      return SkillTreeVisualization(
        userId: userId,
        subject: subject,
        nodes: _createSkillNodes(skills, levels, nodePositions),
        connections: connections,
        styling: styling,
        unlockedSkills: unlocks,
        nextUnlockable: _findNextUnlockable(skills, hierarchy),
        totalProgress: _calculateTreeProgress(skills),
      );
    } catch (e) {
      safePrint('Error generating skill tree: $e');
      rethrow;
    }
  }

  /// Create progress comparison visualization
  Future<ComparisonVisualization> createComparison({
    required String userId,
    required ComparisonType type,
    required List<String> compareWith,
    required List<String> metrics,
  }) async {
    try {
      // Fetch data for all entities
      final allData = await _fetchComparisonData(
        userId: userId,
        type: type,
        compareWith: compareWith,
        metrics: metrics,
      );
      
      // Normalize data for fair comparison
      final normalizedData = _normalizeComparisonData(allData);
      
      // Generate comparison visualizations
      final visualizations = <String, dynamic>{};
      
      for (final metric in metrics) {
        visualizations[metric] = _createMetricComparison(
          metric: metric,
          data: normalizedData,
          type: type,
        );
      }
      
      // Calculate rankings
      final rankings = _calculateRankings(normalizedData, metrics);
      
      // Generate insights
      final insights = _generateComparisonInsights(
        userId: userId,
        rankings: rankings,
        data: normalizedData,
      );
      
      return ComparisonVisualization(
        userId: userId,
        comparisonType: type,
        entities: [userId, ...compareWith],
        metrics: metrics,
        visualizations: visualizations,
        rankings: rankings,
        insights: insights,
        strengths: _identifyStrengths(userId, rankings),
        improvementAreas: _identifyImprovementAreas(userId, rankings),
      );
    } catch (e) {
      safePrint('Error creating comparison: $e');
      rethrow;
    }
  }

  /// Generate learning journey map
  Future<LearningJourneyMap> generateJourneyMap({
    required String userId,
    DateTime? startDate,
  }) async {
    try {
      // Fetch complete learning history
      final history = await _fetchLearningHistory(
        userId: userId,
        startDate: startDate ?? DateTime.now().subtract(Duration(days: 365)),
      );
      
      // Identify key milestones
      final milestones = _identifyJourneyMilestones(history);
      
      // Create journey phases
      final phases = _createJourneyPhases(history, milestones);
      
      // Generate path visualization
      final path = _generateJourneyPath(phases);
      
      // Add achievements and badges
      final achievements = await _fetchAchievements(userId);
      
      // Create interactive elements
      final interactiveElements = _createInteractiveElements(
        milestones: milestones,
        achievements: achievements,
      );
      
      return LearningJourneyMap(
        userId: userId,
        startDate: startDate ?? history.first.date,
        currentPosition: _calculateCurrentPosition(history),
        milestones: milestones,
        phases: phases,
        path: path,
        achievements: achievements,
        interactiveElements: interactiveElements,
        totalDistance: _calculateJourneyDistance(history),
        nextMilestone: _predictNextMilestone(history),
      );
    } catch (e) {
      safePrint('Error generating journey map: $e');
      rethrow;
    }
  }

  /// Create real-time progress indicator
  Stream<RealTimeProgress> createRealTimeProgressStream({
    required String userId,
    required List<String> metrics,
  }) {
    final controller = StreamController<RealTimeProgress>.broadcast();
    
    // Update every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        // Fetch latest metrics
        final currentValues = await _fetchCurrentMetrics(userId, metrics);
        
        // Calculate changes
        final changes = _calculateMetricChanges(currentValues);
        
        // Detect achievements
        final newAchievements = await _checkForNewAchievements(
          userId,
          currentValues,
        );
        
        // Create progress update
        final update = RealTimeProgress(
          timestamp: DateTime.now(),
          metrics: currentValues,
          changes: changes,
          newAchievements: newAchievements,
          motivationalMessage: _generateMotivationalMessage(changes),
        );
        
        controller.add(update);
      } catch (e) {
        safePrint('Error in real-time progress stream: $e');
      }
    });
    
    return controller.stream;
  }

  // Private helper methods

  Future<ProgressData> _fetchProgressData(
    String userId,
    DateTimeRange period,
    List<String>? subjects,
  ) async {
    // Fetch comprehensive progress data
    return ProgressData(
      userId: userId,
      period: period,
      subjects: subjects ?? [],
      dataPoints: [],
    );
  }

  OverallProgress _calculateOverallProgress(ProgressData data) {
    // Calculate overall progress metrics
    return OverallProgress(
      completionRate: 0.75,
      masteryLevel: 0.68,
      consistencyScore: 0.82,
      growthRate: 0.15,
      currentStreak: 12,
    );
  }

  Map<String, SubjectProgress> _calculateSubjectProgress(
    ProgressData data,
    List<String>? subjects,
  ) {
    final progress = <String, SubjectProgress>{};
    
    // Calculate for each subject
    for (final subject in subjects ?? ['Math', 'Science', 'English']) {
      progress[subject] = SubjectProgress(
        subject: subject,
        completion: 0.7 + math.Random().nextDouble() * 0.3,
        mastery: 0.6 + math.Random().nextDouble() * 0.3,
        timeSpent: 120 + math.Random().nextInt(60),
        topicsCompleted: 15 + math.Random().nextInt(10),
        currentLevel: 3 + math.Random().nextInt(2),
      );
    }
    
    return progress;
  }

  Map<String, SkillProgress> _calculateSkillProgress(ProgressData data) {
    return {
      'Problem Solving': SkillProgress(
        skill: 'Problem Solving',
        level: 4,
        experience: 3250,
        nextLevelXP: 5000,
        subSkills: {
          'Logical Reasoning': 0.8,
          'Pattern Recognition': 0.75,
          'Critical Thinking': 0.85,
        },
      ),
      'Memory': SkillProgress(
        skill: 'Memory',
        level: 3,
        experience: 2100,
        nextLevelXP: 3000,
        subSkills: {
          'Short-term': 0.7,
          'Long-term': 0.65,
          'Working Memory': 0.72,
        },
      ),
    };
  }

  TimeAnalytics _generateTimeAnalytics(ProgressData data) {
    return TimeAnalytics(
      totalTime: 4320, // minutes
      dailyAverage: 72,
      weeklyDistribution: {
        'Monday': 80,
        'Tuesday': 75,
        'Wednesday': 90,
        'Thursday': 70,
        'Friday': 65,
        'Saturday': 85,
        'Sunday': 60,
      },
      hourlyDistribution: _generateHourlyDistribution(),
      mostProductiveTime: TimeOfDay(hour: 14, minute: 0),
      consistency: 0.78,
    );
  }

  Map<int, double> _generateHourlyDistribution() {
    final distribution = <int, double>{};
    
    for (int hour = 0; hour < 24; hour++) {
      if (hour >= 9 && hour <= 22) {
        distribution[hour] = 0.3 + math.Random().nextDouble() * 0.7;
      } else {
        distribution[hour] = math.Random().nextDouble() * 0.2;
      }
    }
    
    return distribution;
  }

  TrendAnalysis _analyzeTrends(ProgressData data) {
    return TrendAnalysis(
      overallTrend: TrendDirection.increasing,
      trendStrength: 0.23,
      volatility: 0.12,
      projectedProgress: _projectProgress(data),
      confidenceInterval: [0.18, 0.28],
      seasonalPatterns: {
        'weekday_performance': 0.85,
        'weekend_performance': 0.72,
        'morning_efficiency': 0.68,
        'evening_efficiency': 0.79,
      },
    );
  }

  List<double> _projectProgress(ProgressData data) {
    // Simple linear projection
    final projection = <double>[];
    double current = 0.75;
    
    for (int i = 0; i < 30; i++) {
      current += 0.01;
      projection.add(current.clamp(0.0, 1.0));
    }
    
    return projection;
  }

  Future<List<Milestone>> _trackMilestones(String userId, ProgressData data) async {
    return [
      Milestone(
        id: 'first_100_problems',
        title: '100 Problems Solved',
        description: 'Completed your first 100 practice problems',
        achievedDate: DateTime.now().subtract(Duration(days: 30)),
        category: 'practice',
        significance: 'major',
        reward: '100 XP',
      ),
      Milestone(
        id: 'week_streak',
        title: 'Week Warrior',
        description: '7-day study streak achieved',
        achievedDate: DateTime.now().subtract(Duration(days: 7)),
        category: 'consistency',
        significance: 'medium',
        reward: '50 XP',
      ),
    ];
  }

  ComparativeAnalysis _generateComparisons(ProgressData data) {
    return ComparativeAnalysis(
      selfComparison: SelfComparison(
        currentVsPrevious: 1.15,
        bestPerformance: 0.92,
        averagePerformance: 0.76,
        improvementRate: 0.03,
      ),
      peerComparison: PeerComparison(
        percentile: 78,
        rankInGroup: 12,
        groupSize: 50,
        aboveAverage: true,
      ),
    );
  }

  List<DashboardInsight> _generateDashboardInsights({
    required OverallProgress overall,
    required Map<String, SubjectProgress> subjects,
    required TrendAnalysis trends,
  }) {
    final insights = <DashboardInsight>[];
    
    // Overall progress insight
    if (overall.growthRate > 0.1) {
      insights.add(DashboardInsight(
        type: 'growth',
        title: 'Strong Growth',
        description: 'Your learning rate is ${(overall.growthRate * 100).round()}% this period',
        importance: 'high',
        actionable: 'Keep up the momentum!',
      ));
    }
    
    // Subject-specific insights
    subjects.forEach((subject, progress) {
      if (progress.mastery > 0.8) {
        insights.add(DashboardInsight(
          type: 'mastery',
          title: '$subject Mastery',
          description: 'You\'ve achieved high mastery in $subject',
          importance: 'medium',
          actionable: 'Consider advanced topics',
        ));
      }
    });
    
    // Trend insights
    if (trends.trendStrength > 0.2) {
      insights.add(DashboardInsight(
        type: 'trend',
        title: 'Positive Momentum',
        description: 'Your progress is accelerating',
        importance: 'high',
        actionable: 'This is the perfect time to tackle challenging topics',
      ));
    }
    
    return insights;
  }

  Future<ProgressChartData> _generateLineChartData(
    String userId,
    DateTimeRange period,
    Map<String, dynamic>? filters,
  ) async {
    // Generate line chart data points
    final dataPoints = <ChartDataPoint>[];
    
    final days = period.end.difference(period.start).inDays;
    final startValue = 0.5;
    
    for (int i = 0; i <= days; i++) {
      final date = period.start.add(Duration(days: i));
      final value = startValue + (i / days) * 0.3 + 
          (math.Random().nextDouble() - 0.5) * 0.1;
      
      dataPoints.add(ChartDataPoint(
        x: date.millisecondsSinceEpoch.toDouble(),
        y: value.clamp(0.0, 1.0),
        label: '${date.day}/${date.month}',
      ));
    }
    
    return ProgressChartData(
      type: ChartType.lineChart,
      series: [
        ChartSeries(
          name: 'Progress',
          data: dataPoints,
          color: Colors.blue,
        ),
      ],
      xAxisLabel: 'Date',
      yAxisLabel: 'Progress',
      title: 'Learning Progress Over Time',
    );
  }

  Future<ProgressChartData> _generateBarChartData(
    String userId,
    DateTimeRange period,
    Map<String, dynamic>? filters,
  ) async {
    // Generate bar chart data
    final subjects = ['Math', 'Science', 'English', 'History'];
    final dataPoints = <ChartDataPoint>[];
    
    for (int i = 0; i < subjects.length; i++) {
      dataPoints.add(ChartDataPoint(
        x: i.toDouble(),
        y: 0.5 + math.Random().nextDouble() * 0.5,
        label: subjects[i],
      ));
    }
    
    return ProgressChartData(
      type: ChartType.barChart,
      series: [
        ChartSeries(
          name: 'Subject Progress',
          data: dataPoints,
          color: Colors.green,
        ),
      ],
      xAxisLabel: 'Subject',
      yAxisLabel: 'Mastery Level',
      title: 'Subject Mastery Comparison',
    );
  }

  Future<ProgressChartData> _generateRadarChartData(
    String userId,
    DateTimeRange period,
    Map<String, dynamic>? filters,
  ) async {
    // Generate radar chart data for skills
    final skills = [
      'Problem Solving',
      'Critical Thinking',
      'Memory',
      'Speed',
      'Accuracy',
      'Creativity',
    ];
    
    final dataPoints = <ChartDataPoint>[];
    
    for (int i = 0; i < skills.length; i++) {
      dataPoints.add(ChartDataPoint(
        x: i.toDouble(),
        y: 0.4 + math.Random().nextDouble() * 0.6,
        label: skills[i],
      ));
    }
    
    return ProgressChartData(
      type: ChartType.radarChart,
      series: [
        ChartSeries(
          name: 'Skill Levels',
          data: dataPoints,
          color: Colors.purple,
        ),
      ],
      title: 'Skill Profile',
    );
  }

  Future<ProgressChartData> _generateHeatmapData(
    String userId,
    DateTimeRange period,
    Map<String, dynamic>? filters,
  ) async {
    // Generate heatmap data for daily activity
    final dataPoints = <ChartDataPoint>[];
    
    for (int week = 0; week < 12; week++) {
      for (int day = 0; day < 7; day++) {
        final intensity = math.Random().nextDouble();
        dataPoints.add(ChartDataPoint(
          x: week.toDouble(),
          y: day.toDouble(),
          value: intensity,
          label: 'W${week + 1}D${day + 1}',
        ));
      }
    }
    
    return ProgressChartData(
      type: ChartType.heatmap,
      series: [
        ChartSeries(
          name: 'Activity Heatmap',
          data: dataPoints,
          color: Colors.orange,
        ),
      ],
      title: '12-Week Activity Pattern',
    );
  }

  Future<ProgressChartData> _generatePieChartData(
    String userId,
    DateTimeRange period,
    Map<String, dynamic>? filters,
  ) async {
    // Generate pie chart for time distribution
    final categories = ['Study', 'Practice', 'Review', 'Assessment'];
    final dataPoints = <ChartDataPoint>[];
    
    double total = 0;
    final values = List.generate(categories.length, (_) => 
      math.Random().nextDouble() * 100 + 50);
    total = values.reduce((a, b) => a + b);
    
    for (int i = 0; i < categories.length; i++) {
      dataPoints.add(ChartDataPoint(
        x: i.toDouble(),
        y: values[i] / total,
        label: categories[i],
        value: values[i],
      ));
    }
    
    return ProgressChartData(
      type: ChartType.pieChart,
      series: [
        ChartSeries(
          name: 'Time Distribution',
          data: dataPoints,
          color: Colors.teal,
        ),
      ],
      title: 'Study Time Distribution',
    );
  }

  Future<ProgressChartData> _generateGanttChartData(
    String userId,
    DateTimeRange period,
    Map<String, dynamic>? filters,
  ) async {
    // Generate Gantt chart for learning goals
    final goals = [
      GanttTask(
        name: 'Master Calculus',
        start: period.start,
        end: period.start.add(Duration(days: 30)),
        progress: 0.7,
      ),
      GanttTask(
        name: 'Complete Physics Course',
        start: period.start.add(Duration(days: 15)),
        end: period.start.add(Duration(days: 45)),
        progress: 0.4,
      ),
      GanttTask(
        name: 'Practice Problems Daily',
        start: period.start,
        end: period.end,
        progress: 0.85,
      ),
    ];
    
    return ProgressChartData(
      type: ChartType.ganttChart,
      ganttTasks: goals,
      title: 'Learning Goals Timeline',
    );
  }

  DateTimeRange _getDateRangeForPeriod(ReportPeriod period) {
    final now = DateTime.now();
    
    switch (period) {
      case ReportPeriod.daily:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case ReportPeriod.weekly:
        return DateTimeRange(
          start: now.subtract(Duration(days: 7)),
          end: now,
        );
      case ReportPeriod.monthly:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, now.day),
          end: now,
        );
      case ReportPeriod.quarterly:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 3, now.day),
          end: now,
        );
      case ReportPeriod.yearly:
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, now.day),
          end: now,
        );
    }
  }

  ExecutiveSummary _generateExecutiveSummary(ProgressData data) {
    return ExecutiveSummary(
      headline: 'Strong Progress with Consistent Growth',
      keyMetrics: {
        'Overall Progress': '78%',
        'Weekly Growth': '+5.2%',
        'Study Consistency': '92%',
        'Goal Achievement': '85%',
      },
      highlights: [
        'Achieved personal best in Mathematics',
        'Maintained 14-day study streak',
        'Completed 3 major milestones',
      ],
      areas: [
        'Focus on Science concepts',
        'Increase practice problem variety',
      ],
    );
  }

  DetailedMetrics _generateDetailedMetrics(
    ProgressData data,
    List<String>? includeMetrics,
  ) {
    return DetailedMetrics(
      learning: LearningMetrics(
        totalHours: 156,
        averageSessionLength: 45,
        conceptsMastered: 23,
        problemsSolved: 342,
        accuracy: 0.87,
      ),
      performance: PerformanceMetrics(
        averageScore: 0.82,
        improvement: 0.15,
        consistency: 0.91,
        efficiency: 0.76,
      ),
      engagement: EngagementMetrics(
        activeD
        loginStreak: 14,
        participationRate: 0.95,
        resourceUtilization: 0.73,
      ),
    );
  }

  Future<AchievementsSummary> _generateAchievementsSummary(
    String userId,
    DateTimeRange period,
  ) async {
    return AchievementsSummary(
      totalAchievements: 12,
      newAchievements: 3,
      categories: {
        'Academic': 5,
        'Consistency': 4,
        'Mastery': 3,
      },
      recentAchievements: [
        RecentAchievement(
          name: 'Problem Solver',
          date: DateTime.now().subtract(Duration(days: 2)),
          description: 'Solved 100 problems',
        ),
      ],
    );
  }

  List<Recommendation> _generateRecommendations(ProgressData data) {
    return [
      Recommendation(
        title: 'Increase Study Frequency',
        description: 'Adding one more session per week could boost progress by 20%',
        priority: 'high',
        expectedImpact: 0.2,
      ),
      Recommendation(
        title: 'Focus on Weak Areas',
        description: 'Spend more time on Chemistry concepts',
        priority: 'medium',
        expectedImpact: 0.15,
      ),
    ];
  }

  Future<List<ReportVisualization>> _createReportVisualizations(
    ProgressData data,
    ReportFormat format,
  ) async {
    return [
      ReportVisualization(
        type: 'progress_chart',
        title: 'Overall Progress Trend',
        data: await _generateLineChartData(data.userId, data.period, null),
      ),
      ReportVisualization(
        type: 'skill_radar',
        title: 'Skill Development',
        data: await _generateRadarChartData(data.userId, data.period, null),
      ),
    ];
  }

  String _formatReport({
    required ExecutiveSummary summary,
    required DetailedMetrics metrics,
    required AchievementsSummary achievements,
    required List<Recommendation> recommendations,
    required List<ReportVisualization> visualizations,
    required ReportFormat format,
  }) {
    switch (format) {
      case ReportFormat.pdf:
        return _generatePDFContent(summary, metrics, achievements, recommendations);
      case ReportFormat.html:
        return _generateHTMLContent(summary, metrics, achievements, recommendations);
      case ReportFormat.markdown:
        return _generateMarkdownContent(summary, metrics, achievements, recommendations);
      case ReportFormat.json:
        return _generateJSONContent(summary, metrics, achievements, recommendations);
    }
  }

  String _generateMarkdownContent(
    ExecutiveSummary summary,
    DetailedMetrics metrics,
    AchievementsSummary achievements,
    List<Recommendation> recommendations,
  ) {
    return '''
# Progress Report

## Executive Summary
${summary.headline}

### Key Metrics
${summary.keyMetrics.entries.map((e) => '- **${e.key}**: ${e.value}').join('\n')}

### Highlights
${summary.highlights.map((h) => '- $h').join('\n')}

## Detailed Metrics

### Learning Metrics
- Total Hours: ${metrics.learning.totalHours}
- Problems Solved: ${metrics.learning.problemsSolved}
- Accuracy: ${(metrics.learning.accuracy * 100).round()}%

## Recommendations
${recommendations.map((r) => '### ${r.title}\n${r.description}').join('\n\n')}
''';
  }

  String _generatePDFContent(
    ExecutiveSummary summary,
    DetailedMetrics metrics,
    AchievementsSummary achievements,
    List<Recommendation> recommendations,
  ) {
    // In production, would use a PDF generation library
    return 'PDF content would be generated here';
  }

  String _generateHTMLContent(
    ExecutiveSummary summary,
    DetailedMetrics metrics,
    AchievementsSummary achievements,
    List<Recommendation> recommendations,
  ) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <title>Progress Report</title>
  <style>
    body { font-family: Arial, sans-serif; }
    .metric { display: inline-block; margin: 10px; }
  </style>
</head>
<body>
  <h1>Progress Report</h1>
  <h2>${summary.headline}</h2>
  <!-- Additional HTML content -->
</body>
</html>
''';
  }

  String _generateJSONContent(
    ExecutiveSummary summary,
    DetailedMetrics metrics,
    AchievementsSummary achievements,
    List<Recommendation> recommendations,
  ) {
    return json.encode({
      'summary': summary.toJson(),
      'metrics': metrics.toJson(),
      'achievements': achievements.toJson(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
    });
  }

  Future<List<MetricHistory>> _fetchMetricHistory(
    String userId,
    String metricId,
  ) async {
    // Fetch historical data for metric
    return List.generate(30, (i) => 
      MetricHistory(
        date: DateTime.now().subtract(Duration(days: 30 - i)),
        value: 0.5 + (i / 30) * 0.3 + (math.Random().nextDouble() - 0.5) * 0.1,
      ),
    );
  }

  List<AnimationKeyframe> _generateKeyframes({
    required List<MetricHistory> history,
    required AnimationType animationType,
    required Duration duration,
  }) {
    final keyframes = <AnimationKeyframe>[];
    final frameCount = 60; // 60 FPS
    
    for (int i = 0; i <= frameCount; i++) {
      final progress = i / frameCount;
      final historyIndex = (progress * (history.length - 1)).round();
      
      keyframes.add(AnimationKeyframe(
        time: Duration(milliseconds: (duration.inMilliseconds * progress).round()),
        value: history[historyIndex].value,
        opacity: animationType == AnimationType.fade ? progress : 1.0,
        scale: animationType == AnimationType.scale ? 0.5 + progress * 0.5 : 1.0,
      ));
    }
    
    return keyframes;
  }

  EasingFunction _selectEasingFunction(AnimationType type) {
    switch (type) {
      case AnimationType.bounce:
        return EasingFunction.bounceOut;
      case AnimationType.elastic:
        return EasingFunction.elasticOut;
      case AnimationType.linear:
        return EasingFunction.linear;
      default:
        return EasingFunction.easeInOut;
    }
  }

  List<ParticleEffect> _generateParticleEffects(List<MetricHistory> history) {
    final effects = <ParticleEffect>[];
    
    // Find significant improvements
    for (int i = 1; i < history.length; i++) {
      if (history[i].value - history[i-1].value > 0.1) {
        effects.add(ParticleEffect(
          triggerTime: Duration(milliseconds: (i / history.length * 3000).round()),
          type: ParticleType.sparkle,
          count: 20,
          duration: Duration(seconds: 1),
          color: Colors.amber,
        ));
      }
    }
    
    return effects;
  }

  List<TriggerEvent> _identifyTriggerEvents(List<MetricHistory> history) {
    final events = <TriggerEvent>[];
    
    // Milestone triggers
    for (int i = 0; i < history.length; i++) {
      if (history[i].value >= 0.75 && (i == 0 || history[i-1].value < 0.75)) {
        events.add(TriggerEvent(
          time: Duration(milliseconds: (i / history.length * 3000).round()),
          type: 'milestone',
          action: 'celebrate',
          data: {'milestone': '75% achieved'},
        ));
      }
    }
    
    return events;
  }

  Future<List<UserSkill>> _fetchUserSkills(String userId, String subject) async {
    // Fetch user's skills for subject
    return [
      UserSkill(
        id: 'basic_algebra',
        name: 'Basic Algebra',
        level: 3,
        experience: 750,
        unlocked: true,
        prerequisites: [],
      ),
      UserSkill(
        id: 'advanced_algebra',
        name: 'Advanced Algebra',
        level: 2,
        experience: 450,
        unlocked: true,
        prerequisites: ['basic_algebra'],
      ),
      UserSkill(
        id: 'calculus',
        name: 'Calculus',
        level: 1,
        experience: 120,
        unlocked: true,
        prerequisites: ['advanced_algebra'],
      ),
      UserSkill(
        id: 'differential_equations',
        name: 'Differential Equations',
        level: 0,
        experience: 0,
        unlocked: false,
        prerequisites: ['calculus'],
      ),
    ];
  }

  SkillHierarchy _buildSkillHierarchy(List<UserSkill> skills) {
    return SkillHierarchy(
      root: 'mathematics',
      levels: {
        0: ['basic_algebra'],
        1: ['advanced_algebra'],
        2: ['calculus'],
        3: ['differential_equations'],
      },
      connections: {
        'basic_algebra': ['advanced_algebra'],
        'advanced_algebra': ['calculus'],
        'calculus': ['differential_equations'],
      },
    );
  }

  Map<String, int> _calculateSkillLevels(List<UserSkill> skills) {
    final levels = <String, int>{};
    
    for (final skill in skills) {
      levels[skill.id] = skill.level;
    }
    
    return levels;
  }

  List<String> _determineUnlocks(List<UserSkill> skills, SkillHierarchy hierarchy) {
    return skills.where((s) => s.unlocked).map((s) => s.id).toList();
  }

  Map<String, Offset> _calculateNodePositions(SkillHierarchy hierarchy) {
    final positions = <String, Offset>{};
    
    hierarchy.levels.forEach((level, skills) {
      for (int i = 0; i < skills.length; i++) {
        positions[skills[i]] = Offset(
          (i + 1) * 200.0 / (skills.length + 1),
          level * 150.0 + 100,
        );
      }
    });
    
    return positions;
  }

  List<SkillConnection> _generateSkillConnections(SkillHierarchy hierarchy) {
    final connections = <SkillConnection>[];
    
    hierarchy.connections.forEach((from, toList) {
      for (final to in toList) {
        connections.add(SkillConnection(
          from: from,
          to: to,
          strength: 1.0,
          unlocked: true, // Simplified
        ));
      }
    });
    
    return connections;
  }

  SkillTreeStyling _createSkillTreeStyling(
    Map<String, int> levels,
    List<String> unlocks,
  ) {
    return SkillTreeStyling(
      nodeColors: {
        'locked': Colors.grey,
        'unlocked': Colors.blue,
        'mastered': Colors.gold,
      },
      connectionColors: {
        'locked': Colors.grey.withOpacity(0.3),
        'unlocked': Colors.blue.withOpacity(0.5),
      },
      glowEffects: levels.entries
          .where((e) => e.value >= 3)
          .map((e) => e.key)
          .toList(),
    );
  }

  List<SkillNode> _createSkillNodes(
    List<UserSkill> skills,
    Map<String, int> levels,
    Map<String, Offset> positions,
  ) {
    return skills.map((skill) => SkillNode(
      id: skill.id,
      name: skill.name,
      level: skill.level,
      maxLevel: 5,
      position: positions[skill.id] ?? Offset.zero,
      unlocked: skill.unlocked,
      progress: skill.experience / 1000.0,
      icon: _getSkillIcon(skill.id),
    )).toList();
  }

  IconData _getSkillIcon(String skillId) {
    final iconMap = {
      'basic_algebra': Icons.calculate,
      'advanced_algebra': Icons.functions,
      'calculus': Icons.trending_up,
      'differential_equations': Icons.analytics,
    };
    
    return iconMap[skillId] ?? Icons.school;
  }

  List<String> _findNextUnlockable(List<UserSkill> skills, SkillHierarchy hierarchy) {
    final unlocked = skills.where((s) => s.unlocked).map((s) => s.id).toSet();
    final nextUnlockable = <String>[];
    
    for (final skill in skills.where((s) => !s.unlocked)) {
      if (skill.prerequisites.every((p) => unlocked.contains(p))) {
        nextUnlockable.add(skill.id);
      }
    }
    
    return nextUnlockable;
  }

  double _calculateTreeProgress(List<UserSkill> skills) {
    if (skills.isEmpty) return 0.0;
    
    final totalLevels = skills.length * 5; // Max level is 5
    final currentLevels = skills.fold(0, (sum, skill) => sum + skill.level);
    
    return currentLevels / totalLevels;
  }

  Future<Map<String, Map<String, dynamic>>> _fetchComparisonData({
    required String userId,
    required ComparisonType type,
    required List<String> compareWith,
    required List<String> metrics,
  }) async {
    final data = <String, Map<String, dynamic>>{};
    
    // Fetch data for main user
    data[userId] = await _fetchUserMetrics(userId, metrics);
    
    // Fetch data for comparison entities
    for (final entity in compareWith) {
      data[entity] = await _fetchEntityMetrics(entity, metrics, type);
    }
    
    return data;
  }

  Future<Map<String, dynamic>> _fetchUserMetrics(
    String userId,
    List<String> metrics,
  ) async {
    final userMetrics = <String, dynamic>{};
    
    for (final metric in metrics) {
      userMetrics[metric] = 0.5 + math.Random().nextDouble() * 0.5;
    }
    
    return userMetrics;
  }

  Future<Map<String, dynamic>> _fetchEntityMetrics(
    String entity,
    List<String> metrics,
    ComparisonType type,
  ) async {
    final entityMetrics = <String, dynamic>{};
    
    for (final metric in metrics) {
      entityMetrics[metric] = 0.5 + math.Random().nextDouble() * 0.5;
    }
    
    return entityMetrics;
  }

  Map<String, Map<String, double>> _normalizeComparisonData(
    Map<String, Map<String, dynamic>> data,
  ) {
    final normalized = <String, Map<String, double>>{};
    
    data.forEach((entity, metrics) {
      normalized[entity] = {};
      metrics.forEach((metric, value) {
        normalized[entity]![metric] = (value as num).toDouble();
      });
    });
    
    return normalized;
  }

  dynamic _createMetricComparison({
    required String metric,
    required Map<String, Map<String, double>> data,
    required ComparisonType type,
  }) {
    // Create appropriate visualization for metric comparison
    return {
      'type': type == ComparisonType.individual ? 'bar' : 'grouped_bar',
      'data': data.map((entity, metrics) => 
        MapEntry(entity, metrics[metric] ?? 0.0)),
    };
  }

  Map<String, Map<String, int>> _calculateRankings(
    Map<String, Map<String, double>> data,
    List<String> metrics,
  ) {
    final rankings = <String, Map<String, int>>{};
    
    for (final metric in metrics) {
      // Get all values for this metric
      final values = data.entries
          .map((e) => MapEntry(e.key, e.value[metric] ?? 0.0))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // Assign rankings
      rankings[metric] = {};
      for (int i = 0; i < values.length; i++) {
        rankings[metric]![values[i].key] = i + 1;
      }
    }
    
    return rankings;
  }

  List<ComparisonInsight> _generateComparisonInsights({
    required String userId,
    required Map<String, Map<String, int>> rankings,
    required Map<String, Map<String, double>> data,
  }) {
    final insights = <ComparisonInsight>[];
    
    // Check rankings
    rankings.forEach((metric, ranks) {
      final userRank = ranks[userId] ?? 999;
      
      if (userRank == 1) {
        insights.add(ComparisonInsight(
          type: 'achievement',
          message: 'You\'re leading in $metric!',
          significance: 'high',
        ));
      } else if (userRank <= 3) {
        insights.add(ComparisonInsight(
          type: 'strength',
          message: 'Top 3 performance in $metric',
          significance: 'medium',
        ));
      }
    });
    
    return insights;
  }

  List<String> _identifyStrengths(
    String userId,
    Map<String, Map<String, int>> rankings,
  ) {
    final strengths = <String>[];
    
    rankings.forEach((metric, ranks) {
      if ((ranks[userId] ?? 999) <= 3) {
        strengths.add(metric);
      }
    });
    
    return strengths;
  }

  List<String> _identifyImprovementAreas(
    String userId,
    Map<String, Map<String, int>> rankings,
  ) {
    final improvements = <String>[];
    
    rankings.forEach((metric, ranks) {
      final totalEntities = ranks.length;
      if ((ranks[userId] ?? 999) > totalEntities / 2) {
        improvements.add(metric);
      }
    });
    
    return improvements;
  }

  Future<List<LearningEvent>> _fetchLearningHistory({
    required String userId,
    required DateTime startDate,
  }) async {
    // Fetch complete learning history
    return List.generate(100, (i) => 
      LearningEvent(
        date: startDate.add(Duration(days: i * 3)),
        type: i % 10 == 0 ? 'milestone' : 'progress',
        value: i.toDouble(),
        description: 'Learning event $i',
      ),
    );
  }

  List<JourneyMilestone> _identifyJourneyMilestones(List<LearningEvent> history) {
    return history
        .where((e) => e.type == 'milestone')
        .map((e) => JourneyMilestone(
          date: e.date,
          title: e.description,
          significance: 'major',
          icon: Icons.flag,
        ))
        .toList();
  }

  List<JourneyPhase> _createJourneyPhases(
    List<LearningEvent> history,
    List<JourneyMilestone> milestones,
  ) {
    final phases = <JourneyPhase>[];
    
    // Simple phase creation based on milestones
    for (int i = 0; i < milestones.length - 1; i++) {
      phases.add(JourneyPhase(
        name: 'Phase ${i + 1}',
        startDate: milestones[i].date,
        endDate: milestones[i + 1].date,
        theme: _getPhaseTheme(i),
        progress: 1.0,
      ));
    }
    
    return phases;
  }

  String _getPhaseTheme(int index) {
    final themes = ['Foundation', 'Growth', 'Mastery', 'Excellence'];
    return themes[index % themes.length];
  }

  JourneyPath _generateJourneyPath(List<JourneyPhase> phases) {
    final points = <PathPoint>[];
    
    for (int i = 0; i < phases.length; i++) {
      points.add(PathPoint(
        x: i * 100.0,
        y: 50.0 + math.sin(i * 0.5) * 30,
        phase: i,
      ));
    }
    
    return JourneyPath(points: points);
  }

  Future<List<JourneyAchievement>> _fetchAchievements(String userId) async {
    return [
      JourneyAchievement(
        id: 'first_milestone',
        title: 'First Steps',
        date: DateTime.now().subtract(Duration(days: 90)),
        icon: Icons.star,
        rarity: 'common',
      ),
      JourneyAchievement(
        id: 'consistency_master',
        title: 'Consistency Master',
        date: DateTime.now().subtract(Duration(days: 30)),
        icon: Icons.trending_up,
        rarity: 'rare',
      ),
    ];
  }

  List<InteractiveElement> _createInteractiveElements({
    required List<JourneyMilestone> milestones,
    required List<JourneyAchievement> achievements,
  }) {
    final elements = <InteractiveElement>[];
    
    // Milestone elements
    for (final milestone in milestones) {
      elements.add(InteractiveElement(
        type: 'milestone',
        position: Offset(
          milestones.indexOf(milestone) * 100.0,
          50.0,
        ),
        data: milestone,
        onTap: 'show_milestone_details',
      ));
    }
    
    // Achievement elements
    for (final achievement in achievements) {
      elements.add(InteractiveElement(
        type: 'achievement',
        position: Offset(
          achievements.indexOf(achievement) * 80.0 + 40,
          100.0,
        ),
        data: achievement,
        onTap: 'show_achievement_details',
      ));
    }
    
    return elements;
  }

  double _calculateCurrentPosition(List<LearningEvent> history) {
    if (history.isEmpty) return 0.0;
    
    final totalJourney = history.length.toDouble();
    final currentProgress = history.where((e) => 
      e.date.isBefore(DateTime.now())).length.toDouble();
    
    return currentProgress / totalJourney;
  }

  double _calculateJourneyDistance(List<LearningEvent> history) {
    return history.length * 10.0; // Simplified calculation
  }

  JourneyMilestone? _predictNextMilestone(List<LearningEvent> history) {
    // Predict next milestone based on patterns
    return JourneyMilestone(
      date: DateTime.now().add(Duration(days: 30)),
      title: 'Next Major Achievement',
      significance: 'major',
      icon: Icons.emoji_events,
    );
  }

  Future<Map<String, double>> _fetchCurrentMetrics(
    String userId,
    List<String> metrics,
  ) async {
    final current = <String, double>{};
    
    for (final metric in metrics) {
      current[metric] = 0.5 + math.Random().nextDouble() * 0.5;
    }
    
    return current;
  }

  Map<String, double> _calculateMetricChanges(Map<String, double> current) {
    final changes = <String, double>{};
    
    current.forEach((metric, value) {
      changes[metric] = (math.Random().nextDouble() - 0.5) * 0.1;
    });
    
    return changes;
  }

  Future<List<NewAchievement>> _checkForNewAchievements(
    String userId,
    Map<String, double> metrics,
  ) async {
    final achievements = <NewAchievement>[];
    
    // Check for threshold achievements
    metrics.forEach((metric, value) {
      if (value >= 0.9 && math.Random().nextBool()) {
        achievements.add(NewAchievement(
          id: '${metric}_master',
          title: '$metric Master',
          description: 'Achieved 90% in $metric',
          icon: Icons.emoji_events,
        ));
      }
    });
    
    return achievements;
  }

  String _generateMotivationalMessage(Map<String, double> changes) {
    final improving = changes.values.where((v) => v > 0).length;
    final total = changes.length;
    
    if (improving == total) {
      return 'Amazing! All metrics are improving! 🚀';
    } else if (improving > total / 2) {
      return 'Great progress! Keep pushing forward! 💪';
    } else {
      return 'Stay focused, you\'ve got this! 🎯';
    }
  }
}

// Data models
class ProgressDashboard {
  final String userId;
  final DateTimeRange period;
  final OverallProgress overallProgress;
  final Map<String, SubjectProgress> subjectProgress;
  final Map<String, SkillProgress> skillProgress;
  final TimeAnalytics timeAnalytics;
  final TrendAnalysis trends;
  final List<Milestone> milestones;
  final ComparativeAnalysis comparisons;
  final List<DashboardInsight> insights;
  final DateTime lastUpdated;

  ProgressDashboard({
    required this.userId,
    required this.period,
    required this.overallProgress,
    required this.subjectProgress,
    required this.skillProgress,
    required this.timeAnalytics,
    required this.trends,
    required this.milestones,
    required this.comparisons,
    required this.insights,
    required this.lastUpdated,
  });
}

class OverallProgress {
  final double completionRate;
  final double masteryLevel;
  final double consistencyScore;
  final double growthRate;
  final int currentStreak;

  OverallProgress({
    required this.completionRate,
    required this.masteryLevel,
    required this.consistencyScore,
    required this.growthRate,
    required this.currentStreak,
  });
}

class SubjectProgress {
  final String subject;
  final double completion;
  final double mastery;
  final int timeSpent;
  final int topicsCompleted;
  final int currentLevel;

  SubjectProgress({
    required this.subject,
    required this.completion,
    required this.mastery,
    required this.timeSpent,
    required this.topicsCompleted,
    required this.currentLevel,
  });
}

class SkillProgress {
  final String skill;
  final int level;
  final int experience;
  final int nextLevelXP;
  final Map<String, double> subSkills;

  SkillProgress({
    required this.skill,
    required this.level,
    required this.experience,
    required this.nextLevelXP,
    required this.subSkills,
  });
}

class TimeAnalytics {
  final int totalTime;
  final double dailyAverage;
  final Map<String, int> weeklyDistribution;
  final Map<int, double> hourlyDistribution;
  final TimeOfDay mostProductiveTime;
  final double consistency;

  TimeAnalytics({
    required this.totalTime,
    required this.dailyAverage,
    required this.weeklyDistribution,
    required this.hourlyDistribution,
    required this.mostProductiveTime,
    required this.consistency,
  });
}

class TrendAnalysis {
  final TrendDirection overallTrend;
  final double trendStrength;
  final double volatility;
  final List<double> projectedProgress;
  final List<double> confidenceInterval;
  final Map<String, double> seasonalPatterns;

  TrendAnalysis({
    required this.overallTrend,
    required this.trendStrength,
    required this.volatility,
    required this.projectedProgress,
    required this.confidenceInterval,
    required this.seasonalPatterns,
  });
}

enum TrendDirection { increasing, stable, decreasing }

class Milestone {
  final String id;
  final String title;
  final String description;
  final DateTime achievedDate;
  final String category;
  final String significance;
  final String reward;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.achievedDate,
    required this.category,
    required this.significance,
    required this.reward,
  });
}

class ComparativeAnalysis {
  final SelfComparison selfComparison;
  final PeerComparison peerComparison;

  ComparativeAnalysis({
    required this.selfComparison,
    required this.peerComparison,
  });
}

class SelfComparison {
  final double currentVsPrevious;
  final double bestPerformance;
  final double averagePerformance;
  final double improvementRate;

  SelfComparison({
    required this.currentVsPrevious,
    required this.bestPerformance,
    required this.averagePerformance,
    required this.improvementRate,
  });
}

class PeerComparison {
  final int percentile;
  final int rankInGroup;
  final int groupSize;
  final bool aboveAverage;

  PeerComparison({
    required this.percentile,
    required this.rankInGroup,
    required this.groupSize,
    required this.aboveAverage,
  });
}

class DashboardInsight {
  final String type;
  final String title;
  final String description;
  final String importance;
  final String actionable;

  DashboardInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.importance,
    required this.actionable,
  });
}

class ProgressChartData {
  final ChartType type;
  final List<ChartSeries>? series;
  final List<GanttTask>? ganttTasks;
  final String? xAxisLabel;
  final String? yAxisLabel;
  final String title;

  ProgressChartData({
    required this.type,
    this.series,
    this.ganttTasks,
    this.xAxisLabel,
    this.yAxisLabel,
    required this.title,
  });
}

enum ChartType { lineChart, barChart, radarChart, heatmap, pieChart, ganttChart }

class ChartSeries {
  final String name;
  final List<ChartDataPoint> data;
  final Color color;

  ChartSeries({
    required this.name,
    required this.data,
    required this.color,
  });
}

class ChartDataPoint {
  final double x;
  final double y;
  final String label;
  final double? value;

  ChartDataPoint({
    required this.x,
    required this.y,
    required this.label,
    this.value,
  });
}

class GanttTask {
  final String name;
  final DateTime start;
  final DateTime end;
  final double progress;

  GanttTask({
    required this.name,
    required this.start,
    required this.end,
    required this.progress,
  });
}

class ProgressReport {
  final String userId;
  final ReportPeriod period;
  final DateTimeRange dateRange;
  final ReportFormat format;
  final ExecutiveSummary summary;
  final DetailedMetrics detailedMetrics;
  final AchievementsSummary achievements;
  final List<Recommendation> recommendations;
  final List<ReportVisualization> visualizations;
  final String formattedContent;
  final DateTime generatedAt;

  ProgressReport({
    required this.userId,
    required this.period,
    required this.dateRange,
    required this.format,
    required this.summary,
    required this.detailedMetrics,
    required this.achievements,
    required this.recommendations,
    required this.visualizations,
    required this.formattedContent,
    required this.generatedAt,
  });
}

enum ReportPeriod { daily, weekly, monthly, quarterly, yearly }
enum ReportFormat { pdf, html, markdown, json }

class ExecutiveSummary {
  final String headline;
  final Map<String, String> keyMetrics;
  final List<String> highlights;
  final List<String> areas;

  ExecutiveSummary({
    required this.headline,
    required this.keyMetrics,
    required this.highlights,
    required this.areas,
  });

  Map<String, dynamic> toJson() => {
    'headline': headline,
    'keyMetrics': keyMetrics,
    'highlights': highlights,
    'areas': areas,
  };
}

class DetailedMetrics {
  final LearningMetrics learning;
  final PerformanceMetrics performance;
  final EngagementMetrics engagement;

  DetailedMetrics({
    required this.learning,
    required this.performance,
    required this.engagement,
  });

  Map<String, dynamic> toJson() => {
    'learning': learning.toJson(),
    'performance': performance.toJson(),
    'engagement': engagement.toJson(),
  };
}

class LearningMetrics {
  final int totalHours;
  final int averageSessionLength;
  final int conceptsMastered;
  final int problemsSolved;
  final double accuracy;

  LearningMetrics({
    required this.totalHours,
    required this.averageSessionLength,
    required this.conceptsMastered,
    required this.problemsSolved,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() => {
    'totalHours': totalHours,
    'averageSessionLength': averageSessionLength,
    'conceptsMastered': conceptsMastered,
    'problemsSolved': problemsSolved,
    'accuracy': accuracy,
  };
}

class PerformanceMetrics {
  final double averageScore;
  final double improvement;
  final double consistency;
  final double efficiency;

  PerformanceMetrics({
    required this.averageScore,
    required this.improvement,
    required this.consistency,
    required this.efficiency,
  });

  Map<String, dynamic> toJson() => {
    'averageScore': averageScore,
    'improvement': improvement,
    'consistency': consistency,
    'efficiency': efficiency,
  };
}

class EngagementMetrics {
  final int activeDays;
  final int loginStreak;
  final double participationRate;
  final double resourceUtilization;

  EngagementMetrics({
    required this.activeDays,
    required this.loginStreak,
    required this.participationRate,
    required this.resourceUtilization,
  });

  Map<String, dynamic> toJson() => {
    'activeDays': activeDays,
    'loginStreak': loginStreak,
    'participationRate': participationRate,
    'resourceUtilization': resourceUtilization,
  };
}

class AchievementsSummary {
  final int totalAchievements;
  final int newAchievements;
  final Map<String, int> categories;
  final List<RecentAchievement> recentAchievements;

  AchievementsSummary({
    required this.totalAchievements,
    required this.newAchievements,
    required this.categories,
    required this.recentAchievements,
  });

  Map<String, dynamic> toJson() => {
    'totalAchievements': totalAchievements,
    'newAchievements': newAchievements,
    'categories': categories,
    'recentAchievements': recentAchievements.map((a) => a.toJson()).toList(),
  };
}

class RecentAchievement {
  final String name;
  final DateTime date;
  final String description;

  RecentAchievement({
    required this.name,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
    'description': description,
  };
}

class Recommendation {
  final String title;
  final String description;
  final String priority;
  final double expectedImpact;

  Recommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedImpact,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'priority': priority,
    'expectedImpact': expectedImpact,
  };
}

class ReportVisualization {
  final String type;
  final String title;
  final dynamic data;

  ReportVisualization({
    required this.type,
    required this.title,
    required this.data,
  });
}

class ProgressAnimation {
  final String metricId;
  final AnimationType animationType;
  final Duration duration;
  final List<AnimationKeyframe> keyframes;
  final EasingFunction easingFunction;
  final List<ParticleEffect> particleEffects;
  final List<TriggerEvent> triggerEvents;

  ProgressAnimation({
    required this.metricId,
    required this.animationType,
    required this.duration,
    required this.keyframes,
    required this.easingFunction,
    required this.particleEffects,
    required this.triggerEvents,
  });
}

enum AnimationType { linear, bounce, elastic, fade, scale }
enum EasingFunction { linear, easeIn, easeOut, easeInOut, bounceOut, elasticOut }

class AnimationKeyframe {
  final Duration time;
  final double value;
  final double opacity;
  final double scale;

  AnimationKeyframe({
    required this.time,
    required this.value,
    required this.opacity,
    required this.scale,
  });
}

class ParticleEffect {
  final Duration triggerTime;
  final ParticleType type;
  final int count;
  final Duration duration;
  final Color color;

  ParticleEffect({
    required this.triggerTime,
    required this.type,
    required this.count,
    required this.duration,
    required this.color,
  });
}

enum ParticleType { sparkle, confetti, star, burst }

class TriggerEvent {
  final Duration time;
  final String type;
  final String action;
  final Map<String, dynamic> data;

  TriggerEvent({
    required this.time,
    required this.type,
    required this.action,
    required this.data,
  });
}

class SkillTreeVisualization {
  final String userId;
  final String subject;
  final List<SkillNode> nodes;
  final List<SkillConnection> connections;
  final SkillTreeStyling styling;
  final List<String> unlockedSkills;
  final List<String> nextUnlockable;
  final double totalProgress;

  SkillTreeVisualization({
    required this.userId,
    required this.subject,
    required this.nodes,
    required this.connections,
    required this.styling,
    required this.unlockedSkills,
    required this.nextUnlockable,
    required this.totalProgress,
  });
}

class SkillNode {
  final String id;
  final String name;
  final int level;
  final int maxLevel;
  final Offset position;
  final bool unlocked;
  final double progress;
  final IconData icon;

  SkillNode({
    required this.id,
    required this.name,
    required this.level,
    required this.maxLevel,
    required this.position,
    required this.unlocked,
    required this.progress,
    required this.icon,
  });
}

class SkillConnection {
  final String from;
  final String to;
  final double strength;
  final bool unlocked;

  SkillConnection({
    required this.from,
    required this.to,
    required this.strength,
    required this.unlocked,
  });
}

class SkillTreeStyling {
  final Map<String, Color> nodeColors;
  final Map<String, Color> connectionColors;
  final List<String> glowEffects;

  SkillTreeStyling({
    required this.nodeColors,
    required this.connectionColors,
    required this.glowEffects,
  });
}

class ComparisonVisualization {
  final String userId;
  final ComparisonType comparisonType;
  final List<String> entities;
  final List<String> metrics;
  final Map<String, dynamic> visualizations;
  final Map<String, Map<String, int>> rankings;
  final List<ComparisonInsight> insights;
  final List<String> strengths;
  final List<String> improvementAreas;

  ComparisonVisualization({
    required this.userId,
    required this.comparisonType,
    required this.entities,
    required this.metrics,
    required this.visualizations,
    required this.rankings,
    required this.insights,
    required this.strengths,
    required this.improvementAreas,
  });
}

enum ComparisonType { self, peer, group, historical, goal }

class ComparisonInsight {
  final String type;
  final String message;
  final String significance;

  ComparisonInsight({
    required this.type,
    required this.message,
    required this.significance,
  });
}

class LearningJourneyMap {
  final String userId;
  final DateTime startDate;
  final double currentPosition;
  final List<JourneyMilestone> milestones;
  final List<JourneyPhase> phases;
  final JourneyPath path;
  final List<JourneyAchievement> achievements;
  final List<InteractiveElement> interactiveElements;
  final double totalDistance;
  final JourneyMilestone? nextMilestone;

  LearningJourneyMap({
    required this.userId,
    required this.startDate,
    required this.currentPosition,
    required this.milestones,
    required this.phases,
    required this.path,
    required this.achievements,
    required this.interactiveElements,
    required this.totalDistance,
    this.nextMilestone,
  });
}

class JourneyMilestone {
  final DateTime date;
  final String title;
  final String significance;
  final IconData icon;

  JourneyMilestone({
    required this.date,
    required this.title,
    required this.significance,
    required this.icon,
  });
}

class JourneyPhase {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String theme;
  final double progress;

  JourneyPhase({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.theme,
    required this.progress,
  });
}

class JourneyPath {
  final List<PathPoint> points;

  JourneyPath({required this.points});
}

class PathPoint {
  final double x;
  final double y;
  final int phase;

  PathPoint({
    required this.x,
    required this.y,
    required this.phase,
  });
}

class JourneyAchievement {
  final String id;
  final String title;
  final DateTime date;
  final IconData icon;
  final String rarity;

  JourneyAchievement({
    required this.id,
    required this.title,
    required this.date,
    required this.icon,
    required this.rarity,
  });
}

class InteractiveElement {
  final String type;
  final Offset position;
  final dynamic data;
  final String onTap;

  InteractiveElement({
    required this.type,
    required this.position,
    required this.data,
    required this.onTap,
  });
}

class RealTimeProgress {
  final DateTime timestamp;
  final Map<String, double> metrics;
  final Map<String, double> changes;
  final List<NewAchievement> newAchievements;
  final String motivationalMessage;

  RealTimeProgress({
    required this.timestamp,
    required this.metrics,
    required this.changes,
    required this.newAchievements,
    required this.motivationalMessage,
  });
}

class NewAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  NewAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Supporting classes
class ProgressData {
  final String userId;
  final DateTimeRange period;
  final List<String> subjects;
  final List<dynamic> dataPoints;

  ProgressData({
    required this.userId,
    required this.period,
    required this.subjects,
    required this.dataPoints,
  });
}

class MetricHistory {
  final DateTime date;
  final double value;

  MetricHistory({
    required this.date,
    required this.value,
  });
}

class UserSkill {
  final String id;
  final String name;
  final int level;
  final int experience;
  final bool unlocked;
  final List<String> prerequisites;

  UserSkill({
    required this.id,
    required this.name,
    required this.level,
    required this.experience,
    required this.unlocked,
    required this.prerequisites,
  });
}

class SkillHierarchy {
  final String root;
  final Map<int, List<String>> levels;
  final Map<String, List<String>> connections;

  SkillHierarchy({
    required this.root,
    required this.levels,
    required this.connections,
  });
}

class LearningEvent {
  final DateTime date;
  final String type;
  final double value;
  final String description;

  LearningEvent({
    required this.date,
    required this.type,
    required this.value,
    required this.description,
  });
}