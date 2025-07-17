import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for optimizing intervention timing
class InterventionTimingOptimizer {
  static final InterventionTimingOptimizer _instance = InterventionTimingOptimizer._internal();
  factory InterventionTimingOptimizer() => _instance;
  InterventionTimingOptimizer._internal();

  // Timing models and patterns
  final Map<String, UserTimingModel> _userModels = {};
  final Map<String, List<InterventionRecord>> _interventionHistory = {};
  final Map<String, StreamController<TimingInsight>> _insightStreams = {};
  
  // Real-time monitoring
  final Map<String, UserActivityMonitor> _activityMonitors = {};
  final Map<String, InterventionQueue> _interventionQueues = {};
  
  // ML models for prediction
  final Map<String, TimingPredictionModel> _predictionModels = {};

  /// Initialize timing optimizer
  Future<void> initialize() async {
    try {
      // Load historical intervention data
      await _loadHistoricalData();
      
      // Initialize prediction models
      await _initializePredictionModels();
      
      // Set up activity monitoring
      await _setupActivityMonitoring();
      
      safePrint('Intervention timing optimizer initialized');
    } catch (e) {
      safePrint('Error initializing timing optimizer: $e');
    }
  }

  /// Calculate optimal intervention time
  Future<OptimalTiming> calculateOptimalTiming({
    required String userId,
    required InterventionType type,
    required InterventionContext context,
    TimingConstraints? constraints,
  }) async {
    try {
      // Get user timing model
      final model = await _getUserTimingModel(userId);
      
      // Analyze current context
      final contextAnalysis = await _analyzeContext(userId, context);
      
      // Get activity patterns
      final activityPatterns = await _getActivityPatterns(userId);
      
      // Predict receptivity windows
      final receptivityWindows = await _predictReceptivityWindows(
        userId: userId,
        type: type,
        patterns: activityPatterns,
      );
      
      // Apply constraints
      final constrainedWindows = constraints != null
          ? _applyConstraints(receptivityWindows, constraints)
          : receptivityWindows;
      
      // Select optimal window
      final optimalWindow = _selectOptimalWindow(
        windows: constrainedWindows,
        type: type,
        context: context,
        model: model,
      );
      
      // Calculate specific timing
      final specificTiming = _calculateSpecificTiming(
        window: optimalWindow,
        type: type,
        userPreferences: model.preferences,
      );
      
      // Generate timing rationale
      final rationale = _generateTimingRationale(
        timing: specificTiming,
        window: optimalWindow,
        analysis: contextAnalysis,
      );
      
      return OptimalTiming(
        recommendedTime: specificTiming,
        window: optimalWindow,
        confidence: optimalWindow.confidence,
        alternativeTimes: _generateAlternatives(optimalWindow, constraints),
        rationale: rationale,
        adaptiveAdjustments: _calculateAdaptiveAdjustments(model, type),
      );
    } catch (e) {
      safePrint('Error calculating optimal timing: $e');
      rethrow;
    }
  }

  /// Monitor real-time intervention opportunities
  Stream<InterventionOpportunity> monitorOpportunities(String userId) {
    final controller = StreamController<InterventionOpportunity>.broadcast();
    
    // Get or create activity monitor
    _activityMonitors[userId] ??= UserActivityMonitor(userId: userId);
    final monitor = _activityMonitors[userId]!;
    
    // Monitor activity changes
    monitor.activityStream.listen((activity) async {
      // Check for intervention opportunities
      final opportunities = await _detectOpportunities(
        userId: userId,
        activity: activity,
      );
      
      for (final opportunity in opportunities) {
        // Validate opportunity
        if (await _validateOpportunity(userId, opportunity)) {
          controller.add(opportunity);
        }
      }
    });
    
    return controller.stream;
  }

  /// Schedule intervention for optimal time
  Future<ScheduledIntervention> scheduleIntervention({
    required String userId,
    required Intervention intervention,
    SchedulingStrategy? strategy,
  }) async {
    try {
      strategy ??= SchedulingStrategy.adaptive;
      
      // Calculate optimal timing
      final timing = await calculateOptimalTiming(
        userId: userId,
        type: intervention.type,
        context: intervention.context,
        constraints: intervention.constraints,
      );
      
      // Create scheduled intervention
      final scheduled = ScheduledIntervention(
        id: _generateInterventionId(),
        userId: userId,
        intervention: intervention,
        scheduledTime: timing.recommendedTime,
        window: timing.window,
        strategy: strategy,
        priority: _calculatePriority(intervention),
        createdAt: DateTime.now(),
      );
      
      // Add to queue
      _interventionQueues[userId] ??= InterventionQueue();
      _interventionQueues[userId]!.add(scheduled);
      
      // Set up delivery
      await _setupInterventionDelivery(scheduled);
      
      // Track scheduling
      await _trackScheduling(scheduled);
      
      return scheduled;
    } catch (e) {
      safePrint('Error scheduling intervention: $e');
      rethrow;
    }
  }

  /// Analyze intervention timing effectiveness
  Future<TimingEffectivenessReport> analyzeTimingEffectiveness({
    required String userId,
    required DateTimeRange period,
    InterventionType? type,
  }) async {
    try {
      // Get intervention history
      final history = _interventionHistory[userId] ?? [];
      
      // Filter by period and type
      final relevantInterventions = history.where((record) {
        final inPeriod = record.deliveredAt.isAfter(period.start) &&
                        record.deliveredAt.isBefore(period.end);
        final matchesType = type == null || record.type == type;
        return inPeriod && matchesType;
      }).toList();
      
      // Calculate engagement rates by time
      final engagementByTime = _calculateEngagementByTime(relevantInterventions);
      
      // Analyze response patterns
      final responsePatterns = _analyzeResponsePatterns(relevantInterventions);
      
      // Identify optimal time slots
      final optimalSlots = _identifyOptimalTimeSlots(
        interventions: relevantInterventions,
        engagementData: engagementByTime,
      );
      
      // Calculate timing accuracy
      final timingAccuracy = _calculateTimingAccuracy(relevantInterventions);
      
      // Analyze missed opportunities
      final missedOpportunities = await _analyzeMissedOpportunities(
        userId: userId,
        period: period,
      );
      
      // Generate insights
      final insights = _generateTimingInsights(
        engagementByTime: engagementByTime,
        responsePatterns: responsePatterns,
        optimalSlots: optimalSlots,
        accuracy: timingAccuracy,
      );
      
      // Create recommendations
      final recommendations = _generateTimingRecommendations(
        insights: insights,
        missedOpportunities: missedOpportunities,
      );
      
      return TimingEffectivenessReport(
        userId: userId,
        period: period,
        totalInterventions: relevantInterventions.length,
        engagementByTime: engagementByTime,
        responsePatterns: responsePatterns,
        optimalTimeSlots: optimalSlots,
        timingAccuracy: timingAccuracy,
        missedOpportunities: missedOpportunities,
        insights: insights,
        recommendations: recommendations,
      );
    } catch (e) {
      safePrint('Error analyzing timing effectiveness: $e');
      rethrow;
    }
  }

  /// Optimize intervention frequency
  Future<FrequencyOptimization> optimizeFrequency({
    required String userId,
    required InterventionType type,
    required OptimizationGoal goal,
  }) async {
    try {
      // Get historical performance
      final history = await _getInterventionHistory(userId, type);
      
      // Analyze frequency impact
      final frequencyImpact = _analyzeFrequencyImpact(history);
      
      // Calculate fatigue curve
      final fatigueCurve = _calculateFatigueCurve(history);
      
      // Determine optimal frequency
      final optimalFrequency = _determineOptimalFrequency(
        impact: frequencyImpact,
        fatigue: fatigueCurve,
        goal: goal,
      );
      
      // Create frequency schedule
      final schedule = _createFrequencySchedule(
        baseFrequency: optimalFrequency,
        adaptiveFactors: _getAdaptiveFactors(userId),
      );
      
      // Generate frequency rules
      final rules = _generateFrequencyRules(
        frequency: optimalFrequency,
        fatigue: fatigueCurve,
      );
      
      return FrequencyOptimization(
        userId: userId,
        type: type,
        currentFrequency: _getCurrentFrequency(history),
        optimalFrequency: optimalFrequency,
        schedule: schedule,
        rules: rules,
        expectedImprovement: _calculateExpectedImprovement(
          current: _getCurrentFrequency(history),
          optimal: optimalFrequency,
        ),
      );
    } catch (e) {
      safePrint('Error optimizing frequency: $e');
      rethrow;
    }
  }

  /// Get timing predictions
  Future<TimingPredictions> getTimingPredictions({
    required String userId,
    required DateTime targetDate,
    List<InterventionType>? types,
  }) async {
    try {
      // Get user model
      final model = await _getUserTimingModel(userId);
      
      // Predict activity patterns
      final predictedActivity = await _predictActivityPatterns(
        userId: userId,
        date: targetDate,
      );
      
      // Predict receptivity
      final receptivityPredictions = <InterventionType, List<ReceptivityPrediction>>{};
      
      for (final type in types ?? InterventionType.values) {
        receptivityPredictions[type] = await _predictReceptivity(
          userId: userId,
          type: type,
          date: targetDate,
          activity: predictedActivity,
        );
      }
      
      // Predict optimal windows
      final optimalWindows = _predictOptimalWindows(
        receptivity: receptivityPredictions,
        userModel: model,
      );
      
      // Generate confidence scores
      final confidence = _calculatePredictionConfidence(
        model: model,
        targetDate: targetDate,
      );
      
      return TimingPredictions(
        userId: userId,
        targetDate: targetDate,
        predictedActivity: predictedActivity,
        receptivityByType: receptivityPredictions,
        optimalWindows: optimalWindows,
        confidence: confidence,
        factors: _identifyInfluencingFactors(model, targetDate),
      );
    } catch (e) {
      safePrint('Error getting timing predictions: $e');
      rethrow;
    }
  }

  /// Adapt timing based on feedback
  Future<void> adaptTiming({
    required String interventionId,
    required TimingFeedback feedback,
  }) async {
    try {
      // Find intervention record
      final record = await _findInterventionRecord(interventionId);
      if (record == null) return;
      
      // Update record with feedback
      record.feedback = feedback;
      
      // Get user model
      final model = await _getUserTimingModel(record.userId);
      
      // Update model based on feedback
      await _updateTimingModel(
        model: model,
        record: record,
        feedback: feedback,
      );
      
      // Adjust future interventions
      await _adjustFutureInterventions(
        userId: record.userId,
        basedOn: record,
        feedback: feedback,
      );
      
      // Emit timing insight
      _insightStreams[record.userId]?.add(TimingInsight(
        type: InsightType.feedbackReceived,
        content: _generateFeedbackInsight(feedback),
        impact: _assessFeedbackImpact(feedback),
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      safePrint('Error adapting timing: $e');
    }
  }

  /// Get personalized timing insights
  Future<List<TimingInsight>> getTimingInsights({
    required String userId,
    InsightCategory? category,
  }) async {
    try {
      final insights = <TimingInsight>[];
      
      // Analyze recent patterns
      final recentPatterns = await _analyzeRecentPatterns(userId);
      insights.addAll(_generatePatternInsights(recentPatterns));
      
      // Identify timing opportunities
      final opportunities = await _identifyTimingOpportunities(userId);
      insights.addAll(_generateOpportunityInsights(opportunities));
      
      // Analyze effectiveness trends
      final trends = await _analyzeEffectivenessTrends(userId);
      insights.addAll(_generateTrendInsights(trends));
      
      // Get predictive insights
      final predictions = await _generatePredictiveInsights(userId);
      insights.addAll(predictions);
      
      // Filter by category if specified
      if (category != null) {
        return insights.where((i) => i.category == category).toList();
      }
      
      // Sort by relevance
      insights.sort((a, b) => b.relevance.compareTo(a.relevance));
      
      return insights.take(10).toList(); // Top 10 insights
    } catch (e) {
      safePrint('Error getting timing insights: $e');
      return [];
    }
  }

  // Private helper methods
  Future<void> _loadHistoricalData() async {
    // Load historical intervention data
  }

  Future<void> _initializePredictionModels() async {
    // Initialize ML models for timing prediction
  }

  Future<void> _setupActivityMonitoring() async {
    // Set up real-time activity monitoring
  }

  Future<UserTimingModel> _getUserTimingModel(String userId) async {
    if (_userModels.containsKey(userId)) {
      return _userModels[userId]!;
    }
    
    // Create new model
    final model = UserTimingModel(
      userId: userId,
      preferences: TimingPreferences.defaults(),
      patterns: [],
      effectiveness: {},
    );
    
    _userModels[userId] = model;
    return model;
  }

  Future<ContextAnalysis> _analyzeContext(
    String userId,
    InterventionContext context,
  ) async {
    // Analyze intervention context
    return ContextAnalysis(
      urgency: context.urgency ?? 0.5,
      relevance: 0.8,
      userState: await _assessUserState(userId),
    );
  }

  Future<List<ActivityPattern>> _getActivityPatterns(String userId) async {
    // Get user's activity patterns
    return [];
  }

  Future<List<ReceptivityWindow>> _predictReceptivityWindows({
    required String userId,
    required InterventionType type,
    required List<ActivityPattern> patterns,
  }) async {
    // Predict when user will be receptive
    final windows = <ReceptivityWindow>[];
    
    // Morning window
    windows.add(ReceptivityWindow(
      start: DateTime.now().add(const Duration(hours: 1)),
      end: DateTime.now().add(const Duration(hours: 3)),
      confidence: 0.8,
      factors: ['활동 패턴', '과거 반응률'],
    ));
    
    // Evening window
    windows.add(ReceptivityWindow(
      start: DateTime.now().add(const Duration(hours: 10)),
      end: DateTime.now().add(const Duration(hours: 12)),
      confidence: 0.7,
      factors: ['저녁 학습 패턴'],
    ));
    
    return windows;
  }

  List<ReceptivityWindow> _applyConstraints(
    List<ReceptivityWindow> windows,
    TimingConstraints constraints,
  ) {
    return windows.where((window) {
      // Check time range constraints
      if (constraints.earliestTime != null && 
          window.start.isBefore(constraints.earliestTime!)) {
        return false;
      }
      
      if (constraints.latestTime != null && 
          window.end.isAfter(constraints.latestTime!)) {
        return false;
      }
      
      // Check blackout periods
      for (final blackout in constraints.blackoutPeriods) {
        if (_overlapsWithPeriod(window, blackout)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  bool _overlapsWithPeriod(ReceptivityWindow window, DateTimeRange period) {
    return window.start.isBefore(period.end) && window.end.isAfter(period.start);
  }

  ReceptivityWindow _selectOptimalWindow({
    required List<ReceptivityWindow> windows,
    required InterventionType type,
    required InterventionContext context,
    required UserTimingModel model,
  }) {
    if (windows.isEmpty) {
      // Return default window if no windows available
      final now = DateTime.now();
      return ReceptivityWindow(
        start: now.add(const Duration(hours: 1)),
        end: now.add(const Duration(hours: 2)),
        confidence: 0.5,
        factors: ['기본 설정'],
      );
    }
    
    // Score each window
    final scoredWindows = windows.map((window) {
      double score = window.confidence;
      
      // Adjust based on effectiveness history
      final effectiveness = model.effectiveness[type] ?? {};
      final hourOfDay = window.start.hour;
      score *= effectiveness[hourOfDay] ?? 1.0;
      
      // Adjust based on context urgency
      if (context.urgency != null && context.urgency! > 0.7) {
        // Prefer earlier windows for urgent interventions
        score *= (1.0 - (windows.indexOf(window) / windows.length) * 0.3);
      }
      
      return MapEntry(window, score);
    }).toList();
    
    // Sort by score and return best window
    scoredWindows.sort((a, b) => b.value.compareTo(a.value));
    return scoredWindows.first.key;
  }

  DateTime _calculateSpecificTiming({
    required ReceptivityWindow window,
    required InterventionType type,
    required TimingPreferences userPreferences,
  }) {
    // Calculate specific time within window
    final windowDuration = window.end.difference(window.start);
    
    // Default to middle of window
    var offset = windowDuration ~/ 2;
    
    // Adjust based on preferences
    if (userPreferences.preferEarlyInWindow) {
      offset = windowDuration ~/ 4;
    } else if (userPreferences.preferLateInWindow) {
      offset = (windowDuration.inMinutes * 0.75).round();
    }
    
    return window.start.add(Duration(minutes: offset));
  }

  TimingRationale _generateTimingRationale({
    required DateTime timing,
    required ReceptivityWindow window,
    required ContextAnalysis analysis,
  }) {
    return TimingRationale(
      mainReason: '이 시간대에 가장 높은 참여율을 보입니다',
      supportingFactors: window.factors,
      confidenceExplanation: '과거 데이터 기반 ${(window.confidence * 100).toStringAsFixed(0)}% 확신',
    );
  }

  List<DateTime> _generateAlternatives(
    ReceptivityWindow window,
    TimingConstraints? constraints,
  ) {
    final alternatives = <DateTime>[];
    
    // Add times before and after optimal
    final optimal = _calculateSpecificTiming(
      window: window,
      type: InterventionType.general,
      userPreferences: TimingPreferences.defaults(),
    );
    
    alternatives.add(optimal.subtract(const Duration(hours: 1)));
    alternatives.add(optimal.add(const Duration(hours: 1)));
    
    return alternatives;
  }

  AdaptiveAdjustments _calculateAdaptiveAdjustments(
    UserTimingModel model,
    InterventionType type,
  ) {
    return AdaptiveAdjustments(
      enabled: true,
      maxAdjustment: const Duration(hours: 2),
      triggers: ['사용자 활동 감지', '참여율 변화'],
    );
  }

  Future<List<InterventionOpportunity>> _detectOpportunities({
    required String userId,
    required UserActivity activity,
  }) async {
    final opportunities = <InterventionOpportunity>[];
    
    // Check for learning momentum opportunity
    if (activity.type == ActivityType.studying && 
        activity.duration > const Duration(minutes: 20)) {
      opportunities.add(InterventionOpportunity(
        type: OpportunityType.momentum,
        trigger: '학습 모멘텀 감지',
        relevance: 0.9,
        timeWindow: Duration(minutes: 5),
      ));
    }
    
    // Check for break opportunity
    if (activity.type == ActivityType.studying && 
        activity.duration > const Duration(minutes: 45)) {
      opportunities.add(InterventionOpportunity(
        type: OpportunityType.break_,
        trigger: '휴식 필요 감지',
        relevance: 0.85,
        timeWindow: Duration(minutes: 10),
      ));
    }
    
    return opportunities;
  }

  Future<bool> _validateOpportunity(
    String userId,
    InterventionOpportunity opportunity,
  ) async {
    // Validate if opportunity is still relevant
    
    // Check if not too frequent
    final recentInterventions = await _getRecentInterventions(userId);
    if (recentInterventions.length > 3) {
      return false; // Too many recent interventions
    }
    
    return true;
  }

  String _generateInterventionId() {
    return 'int_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  double _calculatePriority(Intervention intervention) {
    double priority = 0.5;
    
    // Adjust based on type
    switch (intervention.type) {
      case InterventionType.critical:
        priority = 0.9;
        break;
      case InterventionType.reminder:
        priority = 0.5;
        break;
      case InterventionType.motivational:
        priority = 0.6;
        break;
      default:
        priority = 0.5;
    }
    
    // Adjust based on context
    if (intervention.context.urgency != null) {
      priority = math.max(priority, intervention.context.urgency!);
    }
    
    return priority;
  }

  Future<void> _setupInterventionDelivery(ScheduledIntervention scheduled) async {
    // Set up actual delivery mechanism
    final delay = scheduled.scheduledTime.difference(DateTime.now());
    
    if (delay.isNegative) {
      // Deliver immediately if past time
      await _deliverIntervention(scheduled);
    } else {
      // Schedule for future
      Timer(delay, () async {
        await _deliverIntervention(scheduled);
      });
    }
  }

  Future<void> _deliverIntervention(ScheduledIntervention scheduled) async {
    // Deliver the intervention
    safePrint('Delivering intervention: ${scheduled.intervention.content}');
    
    // Record delivery
    await _recordInterventionDelivery(scheduled);
  }

  Future<void> _trackScheduling(ScheduledIntervention scheduled) async {
    // Track scheduling for analytics
  }

  Future<void> _recordInterventionDelivery(ScheduledIntervention scheduled) async {
    final record = InterventionRecord(
      id: scheduled.id,
      userId: scheduled.userId,
      type: scheduled.intervention.type,
      scheduledTime: scheduled.scheduledTime,
      deliveredAt: DateTime.now(),
      window: scheduled.window,
    );
    
    _interventionHistory[scheduled.userId] ??= [];
    _interventionHistory[scheduled.userId]!.add(record);
  }

  Map<int, double> _calculateEngagementByTime(List<InterventionRecord> interventions) {
    final engagementByHour = <int, List<double>>{};
    
    for (final intervention in interventions) {
      final hour = intervention.deliveredAt.hour;
      engagementByHour[hour] ??= [];
      engagementByHour[hour]!.add(intervention.engagementRate ?? 0.0);
    }
    
    // Calculate average engagement by hour
    final averageEngagement = <int, double>{};
    engagementByHour.forEach((hour, rates) {
      if (rates.isNotEmpty) {
        averageEngagement[hour] = rates.reduce((a, b) => a + b) / rates.length;
      }
    });
    
    return averageEngagement;
  }

  List<ResponsePattern> _analyzeResponsePatterns(List<InterventionRecord> interventions) {
    // Analyze patterns in intervention responses
    return [];
  }

  List<TimeSlot> _identifyOptimalTimeSlots({
    required List<InterventionRecord> interventions,
    required Map<int, double> engagementData,
  }) {
    final slots = <TimeSlot>[];
    
    // Sort hours by engagement
    final sortedHours = engagementData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Create time slots from top hours
    for (final entry in sortedHours.take(3)) {
      slots.add(TimeSlot(
        hour: entry.key,
        engagementRate: entry.value,
        sampleSize: interventions.where((i) => i.deliveredAt.hour == entry.key).length,
      ));
    }
    
    return slots;
  }

  double _calculateTimingAccuracy(List<InterventionRecord> interventions) {
    if (interventions.isEmpty) return 0.0;
    
    int accurateCount = 0;
    for (final intervention in interventions) {
      final scheduled = intervention.scheduledTime;
      final delivered = intervention.deliveredAt;
      
      // Consider accurate if delivered within 5 minutes of scheduled time
      if (delivered.difference(scheduled).abs() <= const Duration(minutes: 5)) {
        accurateCount++;
      }
    }
    
    return accurateCount / interventions.length;
  }

  Future<List<MissedOpportunity>> _analyzeMissedOpportunities({
    required String userId,
    required DateTimeRange period,
  }) async {
    // Analyze missed intervention opportunities
    return [];
  }

  List<String> _generateTimingInsights({
    required Map<int, double> engagementByTime,
    required List<ResponsePattern> responsePatterns,
    required List<TimeSlot> optimalSlots,
    required double accuracy,
  }) {
    final insights = <String>[];
    
    // Best time insight
    if (optimalSlots.isNotEmpty) {
      final best = optimalSlots.first;
      insights.add('${best.hour}시에 가장 높은 참여율(${(best.engagementRate * 100).toStringAsFixed(0)}%)을 보입니다');
    }
    
    // Accuracy insight
    if (accuracy > 0.9) {
      insights.add('개입 시간 예측이 매우 정확합니다');
    } else if (accuracy < 0.6) {
      insights.add('개입 시간 예측 정확도를 개선할 필요가 있습니다');
    }
    
    return insights;
  }

  List<String> _generateTimingRecommendations({
    required List<String> insights,
    required List<MissedOpportunity> missedOpportunities,
  }) {
    final recommendations = <String>[];
    
    if (missedOpportunities.isNotEmpty) {
      recommendations.add('놓친 기회를 줄이기 위해 실시간 모니터링을 강화하세요');
    }
    
    recommendations.add('사용자 활동 패턴에 맞춰 개입 시간을 조정하세요');
    
    return recommendations;
  }

  Future<List<InterventionRecord>> _getInterventionHistory(
    String userId,
    InterventionType type,
  ) async {
    final history = _interventionHistory[userId] ?? [];
    return history.where((r) => r.type == type).toList();
  }

  FrequencyImpact _analyzeFrequencyImpact(List<InterventionRecord> history) {
    // Analyze how frequency affects engagement
    return FrequencyImpact();
  }

  FatigueCurve _calculateFatigueCurve(List<InterventionRecord> history) {
    // Calculate intervention fatigue over time
    return FatigueCurve();
  }

  double _determineOptimalFrequency({
    required FrequencyImpact impact,
    required FatigueCurve fatigue,
    required OptimizationGoal goal,
  }) {
    // Determine optimal intervention frequency
    switch (goal) {
      case OptimizationGoal.maximizeEngagement:
        return 3.0; // per day
      case OptimizationGoal.minimizeFatigue:
        return 1.5; // per day
      case OptimizationGoal.balanceEffectiveness:
        return 2.0; // per day
    }
  }

  FrequencySchedule _createFrequencySchedule({
    required double baseFrequency,
    required Map<String, double> adaptiveFactors,
  }) {
    return FrequencySchedule(
      baseFrequency: baseFrequency,
      variations: {
        'weekday': baseFrequency * 1.2,
        'weekend': baseFrequency * 0.8,
      },
    );
  }

  Map<String, double> _getAdaptiveFactors(String userId) {
    // Get factors that affect frequency
    return {
      'engagement_trend': 1.0,
      'fatigue_level': 0.9,
      'goal_proximity': 1.1,
    };
  }

  List<FrequencyRule> _generateFrequencyRules({
    required double frequency,
    required FatigueCurve fatigue,
  }) {
    return [
      FrequencyRule(
        condition: '높은 피로도',
        action: '빈도 30% 감소',
        threshold: 0.7,
      ),
      FrequencyRule(
        condition: '낮은 참여율',
        action: '빈도 20% 감소',
        threshold: 0.3,
      ),
    ];
  }

  double _getCurrentFrequency(List<InterventionRecord> history) {
    if (history.isEmpty) return 0.0;
    
    // Calculate average daily frequency over last 7 days
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentInterventions = history.where((r) => r.deliveredAt.isAfter(weekAgo)).length;
    
    return recentInterventions / 7.0;
  }

  double _calculateExpectedImprovement(double current, double optimal) {
    if (current == 0) return 1.0;
    return (optimal - current) / current;
  }

  Future<List<ActivityPattern>> _predictActivityPatterns({
    required String userId,
    required DateTime date,
  }) async {
    // Predict activity patterns for given date
    return [];
  }

  Future<List<ReceptivityPrediction>> _predictReceptivity({
    required String userId,
    required InterventionType type,
    required DateTime date,
    required List<ActivityPattern> activity,
  }) async {
    // Predict receptivity throughout the day
    return [];
  }

  Map<InterventionType, List<TimeWindow>> _predictOptimalWindows({
    required Map<InterventionType, List<ReceptivityPrediction>> receptivity,
    required UserTimingModel userModel,
  }) {
    // Predict optimal intervention windows
    return {};
  }

  double _calculatePredictionConfidence({
    required UserTimingModel model,
    required DateTime targetDate,
  }) {
    // Calculate confidence in predictions
    final daysDifference = targetDate.difference(DateTime.now()).inDays;
    
    // Confidence decreases with distance
    final distanceFactor = math.exp(-daysDifference / 7.0);
    
    // Confidence increases with data
    final dataFactor = math.min(1.0, model.patterns.length / 100.0);
    
    return distanceFactor * 0.7 + dataFactor * 0.3;
  }

  Map<String, double> _identifyInfluencingFactors(
    UserTimingModel model,
    DateTime targetDate,
  ) {
    // Identify factors influencing timing
    return {
      'day_of_week': 0.3,
      'time_of_day': 0.4,
      'activity_level': 0.2,
      'recent_engagement': 0.1,
    };
  }

  Future<InterventionRecord?> _findInterventionRecord(String interventionId) async {
    for (final userRecords in _interventionHistory.values) {
      final record = userRecords.firstWhere(
        (r) => r.id == interventionId,
        orElse: () => InterventionRecord.empty(),
      );
      if (record.id.isNotEmpty) return record;
    }
    return null;
  }

  Future<void> _updateTimingModel({
    required UserTimingModel model,
    required InterventionRecord record,
    required TimingFeedback feedback,
  }) async {
    // Update model based on feedback
    final hour = record.deliveredAt.hour;
    model.effectiveness[record.type] ??= {};
    
    // Update effectiveness score for this hour
    final currentScore = model.effectiveness[record.type]![hour] ?? 0.5;
    final feedbackScore = feedback == TimingFeedback.perfect ? 1.0 :
                         feedback == TimingFeedback.good ? 0.8 :
                         feedback == TimingFeedback.poor ? 0.2 : 0.5;
    
    // Weighted average with more weight on recent feedback
    model.effectiveness[record.type]![hour] = currentScore * 0.7 + feedbackScore * 0.3;
  }

  Future<void> _adjustFutureInterventions({
    required String userId,
    required InterventionRecord basedOn,
    required TimingFeedback feedback,
  }) async {
    // Adjust timing of future scheduled interventions
    if (feedback == TimingFeedback.tooEarly) {
      // Delay future interventions
      final queue = _interventionQueues[userId];
      if (queue != null) {
        for (final scheduled in queue.pending) {
          scheduled.scheduledTime = scheduled.scheduledTime.add(
            const Duration(minutes: 30),
          );
        }
      }
    } else if (feedback == TimingFeedback.tooLate) {
      // Advance future interventions
      final queue = _interventionQueues[userId];
      if (queue != null) {
        for (final scheduled in queue.pending) {
          scheduled.scheduledTime = scheduled.scheduledTime.subtract(
            const Duration(minutes: 30),
          );
        }
      }
    }
  }

  String _generateFeedbackInsight(TimingFeedback feedback) {
    switch (feedback) {
      case TimingFeedback.perfect:
        return '완벽한 타이밍이었습니다!';
      case TimingFeedback.good:
        return '좋은 타이밍이었습니다';
      case TimingFeedback.tooEarly:
        return '조금 이른 시간이었습니다';
      case TimingFeedback.tooLate:
        return '조금 늦은 시간이었습니다';
      case TimingFeedback.poor:
        return '타이밍 개선이 필요합니다';
    }
  }

  double _assessFeedbackImpact(TimingFeedback feedback) {
    switch (feedback) {
      case TimingFeedback.perfect:
        return 1.0;
      case TimingFeedback.good:
        return 0.7;
      case TimingFeedback.tooEarly:
      case TimingFeedback.tooLate:
        return 0.4;
      case TimingFeedback.poor:
        return 0.2;
    }
  }

  Future<List<InterventionRecord>> _getRecentInterventions(String userId) async {
    final history = _interventionHistory[userId] ?? [];
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return history.where((r) => r.deliveredAt.isAfter(cutoff)).toList();
  }

  Future<UserState> _assessUserState(String userId) async {
    // Assess current user state
    return UserState.active;
  }

  // Additional helper method stubs...
  Future<List<Pattern>> _analyzeRecentPatterns(String userId) async => [];
  List<TimingInsight> _generatePatternInsights(List<Pattern> patterns) => [];
  
  Future<List<Opportunity>> _identifyTimingOpportunities(String userId) async => [];
  List<TimingInsight> _generateOpportunityInsights(List<Opportunity> opportunities) => [];
  
  Future<List<Trend>> _analyzeEffectivenessTrends(String userId) async => [];
  List<TimingInsight> _generateTrendInsights(List<Trend> trends) => [];
  
  Future<List<TimingInsight>> _generatePredictiveInsights(String userId) async => [];
}

// Data models
class OptimalTiming {
  final DateTime recommendedTime;
  final ReceptivityWindow window;
  final double confidence;
  final List<DateTime> alternativeTimes;
  final TimingRationale rationale;
  final AdaptiveAdjustments adaptiveAdjustments;

  OptimalTiming({
    required this.recommendedTime,
    required this.window,
    required this.confidence,
    required this.alternativeTimes,
    required this.rationale,
    required this.adaptiveAdjustments,
  });
}

class InterventionContext {
  final Map<String, dynamic> data;
  final double? urgency;
  final String? trigger;

  InterventionContext({
    this.data = const {},
    this.urgency,
    this.trigger,
  });
}

class TimingConstraints {
  final DateTime? earliestTime;
  final DateTime? latestTime;
  final List<DateTimeRange> blackoutPeriods;
  final Map<String, dynamic>? additionalConstraints;

  TimingConstraints({
    this.earliestTime,
    this.latestTime,
    this.blackoutPeriods = const [],
    this.additionalConstraints,
  });
}

class UserTimingModel {
  final String userId;
  final TimingPreferences preferences;
  final List<TimingPattern> patterns;
  final Map<InterventionType, Map<int, double>> effectiveness; // type -> hour -> score

  UserTimingModel({
    required this.userId,
    required this.preferences,
    required this.patterns,
    required this.effectiveness,
  });
}

class TimingPreferences {
  final bool preferEarlyInWindow;
  final bool preferLateInWindow;
  final List<int> preferredHours;
  final List<int> avoidHours;

  TimingPreferences({
    this.preferEarlyInWindow = false,
    this.preferLateInWindow = false,
    this.preferredHours = const [],
    this.avoidHours = const [],
  });

  factory TimingPreferences.defaults() => TimingPreferences();
}

class ReceptivityWindow {
  final DateTime start;
  final DateTime end;
  final double confidence;
  final List<String> factors;

  ReceptivityWindow({
    required this.start,
    required this.end,
    required this.confidence,
    required this.factors,
  });
}

class TimingRationale {
  final String mainReason;
  final List<String> supportingFactors;
  final String confidenceExplanation;

  TimingRationale({
    required this.mainReason,
    required this.supportingFactors,
    required this.confidenceExplanation,
  });
}

class AdaptiveAdjustments {
  final bool enabled;
  final Duration maxAdjustment;
  final List<String> triggers;

  AdaptiveAdjustments({
    required this.enabled,
    required this.maxAdjustment,
    required this.triggers,
  });
}

class InterventionOpportunity {
  final OpportunityType type;
  final String trigger;
  final double relevance;
  final Duration timeWindow;

  InterventionOpportunity({
    required this.type,
    required this.trigger,
    required this.relevance,
    required this.timeWindow,
  });
}

class UserActivityMonitor {
  final String userId;
  final StreamController<UserActivity> _activityController = StreamController.broadcast();

  UserActivityMonitor({required this.userId});

  Stream<UserActivity> get activityStream => _activityController.stream;
}

class UserActivity {
  final ActivityType type;
  final Duration duration;
  final DateTime timestamp;

  UserActivity({
    required this.type,
    required this.duration,
    required this.timestamp,
  });
}

class Intervention {
  final InterventionType type;
  final String content;
  final InterventionContext context;
  final TimingConstraints? constraints;

  Intervention({
    required this.type,
    required this.content,
    required this.context,
    this.constraints,
  });
}

class ScheduledIntervention {
  final String id;
  final String userId;
  final Intervention intervention;
  DateTime scheduledTime;
  final ReceptivityWindow window;
  final SchedulingStrategy strategy;
  final double priority;
  final DateTime createdAt;

  ScheduledIntervention({
    required this.id,
    required this.userId,
    required this.intervention,
    required this.scheduledTime,
    required this.window,
    required this.strategy,
    required this.priority,
    required this.createdAt,
  });
}

class InterventionQueue {
  final List<ScheduledIntervention> pending = [];

  void add(ScheduledIntervention intervention) {
    pending.add(intervention);
    pending.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }
}

class InterventionRecord {
  final String id;
  final String userId;
  final InterventionType type;
  final DateTime scheduledTime;
  final DateTime deliveredAt;
  final ReceptivityWindow window;
  double? engagementRate;
  TimingFeedback? feedback;

  InterventionRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.scheduledTime,
    required this.deliveredAt,
    required this.window,
    this.engagementRate,
    this.feedback,
  });

  factory InterventionRecord.empty() => InterventionRecord(
    id: '',
    userId: '',
    type: InterventionType.general,
    scheduledTime: DateTime.now(),
    deliveredAt: DateTime.now(),
    window: ReceptivityWindow(
      start: DateTime.now(),
      end: DateTime.now(),
      confidence: 0,
      factors: [],
    ),
  );
}

class TimingEffectivenessReport {
  final String userId;
  final DateTimeRange period;
  final int totalInterventions;
  final Map<int, double> engagementByTime;
  final List<ResponsePattern> responsePatterns;
  final List<TimeSlot> optimalTimeSlots;
  final double timingAccuracy;
  final List<MissedOpportunity> missedOpportunities;
  final List<String> insights;
  final List<String> recommendations;

  TimingEffectivenessReport({
    required this.userId,
    required this.period,
    required this.totalInterventions,
    required this.engagementByTime,
    required this.responsePatterns,
    required this.optimalTimeSlots,
    required this.timingAccuracy,
    required this.missedOpportunities,
    required this.insights,
    required this.recommendations,
  });
}

class FrequencyOptimization {
  final String userId;
  final InterventionType type;
  final double currentFrequency;
  final double optimalFrequency;
  final FrequencySchedule schedule;
  final List<FrequencyRule> rules;
  final double expectedImprovement;

  FrequencyOptimization({
    required this.userId,
    required this.type,
    required this.currentFrequency,
    required this.optimalFrequency,
    required this.schedule,
    required this.rules,
    required this.expectedImprovement,
  });
}

class TimingPredictions {
  final String userId;
  final DateTime targetDate;
  final List<ActivityPattern> predictedActivity;
  final Map<InterventionType, List<ReceptivityPrediction>> receptivityByType;
  final Map<InterventionType, List<TimeWindow>> optimalWindows;
  final double confidence;
  final Map<String, double> factors;

  TimingPredictions({
    required this.userId,
    required this.targetDate,
    required this.predictedActivity,
    required this.receptivityByType,
    required this.optimalWindows,
    required this.confidence,
    required this.factors,
  });
}

class TimingInsight {
  final InsightType type;
  final String content;
  final double impact;
  final DateTime timestamp;
  final InsightCategory? category;
  final double relevance;

  TimingInsight({
    required this.type,
    required this.content,
    required this.impact,
    required this.timestamp,
    this.category,
    this.relevance = 0.5,
  });
}

class TimingPredictionModel {
  // ML model for timing predictions
}

// Enums
enum InterventionType {
  reminder,
  motivational,
  educational,
  feedback,
  critical,
  general,
}

enum OpportunityType {
  momentum,
  break_,
  completion,
  struggle,
  achievement,
}

enum ActivityType {
  studying,
  resting,
  reviewing,
  practicing,
}

enum SchedulingStrategy {
  fixed,
  adaptive,
  opportunistic,
}

enum OptimizationGoal {
  maximizeEngagement,
  minimizeFatigue,
  balanceEffectiveness,
}

enum TimingFeedback {
  perfect,
  good,
  tooEarly,
  tooLate,
  poor,
}

enum InsightType {
  pattern,
  opportunity,
  trend,
  prediction,
  feedbackReceived,
}

enum InsightCategory {
  timing,
  frequency,
  effectiveness,
  prediction,
}

enum UserState {
  active,
  passive,
  busy,
  available,
}

// Supporting classes
class ContextAnalysis {
  final double urgency;
  final double relevance;
  final UserState userState;

  ContextAnalysis({
    required this.urgency,
    required this.relevance,
    required this.userState,
  });
}

class ActivityPattern {}
class TimingPattern {}
class ResponsePattern {}
class TimeSlot {
  final int hour;
  final double engagementRate;
  final int sampleSize;

  TimeSlot({
    required this.hour,
    required this.engagementRate,
    required this.sampleSize,
  });
}
class MissedOpportunity {}
class FrequencyImpact {}
class FatigueCurve {}
class FrequencySchedule {
  final double baseFrequency;
  final Map<String, double> variations;

  FrequencySchedule({
    required this.baseFrequency,
    required this.variations,
  });
}
class FrequencyRule {
  final String condition;
  final String action;
  final double threshold;

  FrequencyRule({
    required this.condition,
    required this.action,
    required this.threshold,
  });
}
class ReceptivityPrediction {}
class TimeWindow {}
class Pattern {}
class Opportunity {}
class Trend {}