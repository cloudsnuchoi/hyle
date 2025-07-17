import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for tracking and analyzing attention patterns
class AttentionTrackingService {
  static final AttentionTrackingService _instance = AttentionTrackingService._internal();
  factory AttentionTrackingService() => _instance;
  AttentionTrackingService._internal();

  // Attention tracking state
  final Map<String, AttentionState> _userStates = {};
  final Map<String, StreamController<AttentionState>> _stateControllers = {};
  final Map<String, List<AttentionEvent>> _eventBuffers = {};
  
  // Thresholds
  static const int _sustainedAttentionThreshold = 20; // minutes
  static const double _focusThreshold = 0.7;
  static const int _distractionThreshold = 3; // per 10 minutes

  /// Start tracking attention for a user
  Stream<AttentionState> startTracking(String userId) {
    // Initialize state
    _userStates[userId] = AttentionState(
      userId: userId,
      currentFocus: 0.8,
      attentionSpan: 25,
      distractionCount: 0,
      lastDistraction: null,
      sessionStartTime: DateTime.now(),
      timestamp: DateTime.now(),
    );

    _eventBuffers[userId] = [];
    _stateControllers[userId] = StreamController<AttentionState>.broadcast();

    // Start periodic attention assessment
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_stateControllers.containsKey(userId)) {
        timer.cancel();
        return;
      }
      _assessAttention(userId);
    });

    return _stateControllers[userId]!.stream;
  }

  /// Stop tracking for a user
  void stopTracking(String userId) {
    _stateControllers[userId]?.close();
    _stateControllers.remove(userId);
    _userStates.remove(userId);
    _eventBuffers.remove(userId);
  }

  /// Record attention event
  Future<void> recordEvent({
    required String userId,
    required AttentionEventType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = AttentionEvent(
        type: type,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      _eventBuffers[userId]?.add(event);

      // Update state based on event
      await _updateStateFromEvent(userId, event);

      // Check for attention patterns
      if (_eventBuffers[userId]!.length >= 10) {
        await _analyzeRecentEvents(userId);
      }
    } catch (e) {
      safePrint('Error recording attention event: $e');
    }
  }

  /// Analyze attention patterns
  Future<AttentionAnalysis> analyzeAttentionPatterns({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Fetch historical data
      final sessions = await _fetchAttentionSessions(userId, startDate, endDate);
      
      // Calculate metrics
      final metrics = _calculateAttentionMetrics(sessions);
      
      // Identify patterns
      final patterns = _identifyAttentionPatterns(sessions);
      
      // Analyze distractions
      final distractionAnalysis = _analyzeDistractions(sessions);
      
      // Determine attention profile
      final profile = _determineAttentionProfile(metrics, patterns);
      
      // Generate recommendations
      final recommendations = _generateAttentionRecommendations(
        profile: profile,
        patterns: patterns,
        distractions: distractionAnalysis,
      );
      
      return AttentionAnalysis(
        userId: userId,
        period: DateTimeRange(start: startDate, end: endDate),
        metrics: metrics,
        patterns: patterns,
        distractionAnalysis: distractionAnalysis,
        attentionProfile: profile,
        recommendations: recommendations,
        insights: _generateAttentionInsights(metrics, patterns),
      );
    } catch (e) {
      safePrint('Error analyzing attention patterns: $e');
      rethrow;
    }
  }

  /// Monitor sustained attention
  Future<SustainedAttentionReport> monitorSustainedAttention({
    required String userId,
    required String taskId,
    required int targetDuration,
  }) async {
    try {
      final startTime = DateTime.now();
      final checkpoints = <AttentionCheckpoint>[];
      
      // Create monitoring timer
      Timer.periodic(const Duration(minutes: 5), (timer) {
        final elapsed = DateTime.now().difference(startTime).inMinutes;
        
        if (elapsed >= targetDuration) {
          timer.cancel();
          return;
        }
        
        final state = _userStates[userId];
        if (state != null) {
          checkpoints.add(AttentionCheckpoint(
            timestamp: DateTime.now(),
            focusLevel: state.currentFocus,
            distractionsSinceStart: state.distractionCount,
            performance: _estimatePerformance(state),
          ));
        }
      });
      
      // Wait for completion or interruption
      await Future.delayed(Duration(minutes: targetDuration));
      
      // Generate report
      final finalState = _userStates[userId]!;
      final success = _evaluateSustainedAttention(checkpoints, targetDuration);
      
      return SustainedAttentionReport(
        taskId: taskId,
        targetDuration: targetDuration,
        actualDuration: DateTime.now().difference(startTime).inMinutes,
        success: success,
        averageFocus: _calculateAverageFocus(checkpoints),
        focusVariability: _calculateFocusVariability(checkpoints),
        distractionCount: finalState.distractionCount,
        checkpoints: checkpoints,
        recommendations: _generateSustainedAttentionTips(success, checkpoints),
      );
    } catch (e) {
      safePrint('Error monitoring sustained attention: $e');
      rethrow;
    }
  }

  /// Detect attention wandering
  Future<WanderingDetection> detectAttentionWandering({
    required String userId,
    required List<BehaviorSignal> signals,
  }) async {
    try {
      // Analyze behavioral signals
      final wanderingScore = _calculateWanderingScore(signals);
      
      // Check against patterns
      final isWandering = wanderingScore > 0.6;
      
      // Identify type of wandering
      final wanderingType = _classifyWanderingType(signals);
      
      // Determine intervention need
      final interventionNeeded = isWandering && wanderingScore > 0.75;
      
      // Generate recovery strategies
      final recoveryStrategies = isWandering 
          ? _generateRecoveryStrategies(wanderingType)
          : [];
      
      return WanderingDetection(
        isWandering: isWandering,
        confidence: _calculateDetectionConfidence(signals),
        wanderingScore: wanderingScore,
        wanderingType: wanderingType,
        triggerSignals: signals.where((s) => s.strength > 0.7).toList(),
        interventionNeeded: interventionNeeded,
        recoveryStrategies: recoveryStrategies,
      );
    } catch (e) {
      safePrint('Error detecting attention wandering: $e');
      rethrow;
    }
  }

  /// Optimize attention for task
  Future<AttentionOptimization> optimizeAttentionForTask({
    required String userId,
    required TaskProfile task,
  }) async {
    try {
      // Get user's attention profile
      final profile = await _getUserAttentionProfile(userId);
      
      // Analyze task requirements
      final requirements = _analyzeTaskRequirements(task);
      
      // Match profile to requirements
      final compatibility = _calculateCompatibility(profile, requirements);
      
      // Generate optimization strategies
      final strategies = _generateOptimizationStrategies(
        profile: profile,
        requirements: requirements,
        compatibility: compatibility,
      );
      
      // Create attention schedule
      final schedule = _createAttentionSchedule(
        task: task,
        profile: profile,
        strategies: strategies,
      );
      
      // Predict success probability
      final successProbability = _predictAttentionSuccess(
        profile: profile,
        task: task,
        strategies: strategies,
      );
      
      return AttentionOptimization(
        taskCompatibility: compatibility,
        recommendedStrategies: strategies,
        attentionSchedule: schedule,
        expectedFocusDuration: _calculateExpectedFocus(profile, task),
        breakRecommendations: _generateBreakRecommendations(task, profile),
        environmentalFactors: _identifyEnvironmentalFactors(profile),
        successProbability: successProbability,
      );
    } catch (e) {
      safePrint('Error optimizing attention for task: $e');
      rethrow;
    }
  }

  /// Train attention skills
  Future<AttentionTrainingPlan> createAttentionTrainingPlan({
    required String userId,
    required List<String> weakAreas,
    required int trainingDurationDays,
  }) async {
    try {
      // Assess current skills
      final baseline = await _assessAttentionSkills(userId);
      
      // Create progressive exercises
      final exercises = _createProgressiveExercises(
        baseline: baseline,
        weakAreas: weakAreas,
        duration: trainingDurationDays,
      );
      
      // Set milestones
      final milestones = _setTrainingMilestones(
        baseline: baseline,
        targetDuration: trainingDurationDays,
      );
      
      // Generate daily routines
      final dailyRoutines = _generateDailyRoutines(
        exercises: exercises,
        userProfile: baseline,
      );
      
      return AttentionTrainingPlan(
        userId: userId,
        baseline: baseline,
        exercises: exercises,
        milestones: milestones,
        dailyRoutines: dailyRoutines,
        expectedImprovement: _calculateExpectedImprovement(
          baseline,
          trainingDurationDays,
        ),
        trackingMetrics: _defineTrackingMetrics(weakAreas),
      );
    } catch (e) {
      safePrint('Error creating attention training plan: $e');
      rethrow;
    }
  }

  // Private helper methods

  void _assessAttention(String userId) {
    final state = _userStates[userId];
    if (state == null) return;

    // Simulate attention fluctuation
    final events = _eventBuffers[userId] ?? [];
    final recentEvents = events.where((e) => 
      DateTime.now().difference(e.timestamp).inSeconds < 30
    ).toList();

    // Update focus based on recent events
    double newFocus = state.currentFocus;
    
    for (final event in recentEvents) {
      switch (event.type) {
        case AttentionEventType.focused:
          newFocus = math.min(1.0, newFocus + 0.05);
          break;
        case AttentionEventType.distracted:
          newFocus = math.max(0.0, newFocus - 0.1);
          break;
        case AttentionEventType.taskSwitch:
          newFocus = math.max(0.0, newFocus - 0.15);
          break;
        case AttentionEventType.break_taken:
          newFocus = 0.8; // Reset after break
          break;
        default:
          break;
      }
    }

    // Update state
    final updatedState = AttentionState(
      userId: userId,
      currentFocus: newFocus,
      attentionSpan: _calculateAttentionSpan(events),
      distractionCount: state.distractionCount,
      lastDistraction: state.lastDistraction,
      sessionStartTime: state.sessionStartTime,
      timestamp: DateTime.now(),
    );

    _userStates[userId] = updatedState;
    _stateControllers[userId]?.add(updatedState);
  }

  Future<void> _updateStateFromEvent(String userId, AttentionEvent event) async {
    final state = _userStates[userId];
    if (state == null) return;

    switch (event.type) {
      case AttentionEventType.distracted:
        _userStates[userId] = AttentionState(
          userId: userId,
          currentFocus: math.max(0, state.currentFocus - 0.1),
          attentionSpan: state.attentionSpan,
          distractionCount: state.distractionCount + 1,
          lastDistraction: event.timestamp,
          sessionStartTime: state.sessionStartTime,
          timestamp: DateTime.now(),
        );
        break;
      case AttentionEventType.refocused:
        _userStates[userId] = AttentionState(
          userId: userId,
          currentFocus: math.min(1, state.currentFocus + 0.15),
          attentionSpan: state.attentionSpan,
          distractionCount: state.distractionCount,
          lastDistraction: state.lastDistraction,
          sessionStartTime: state.sessionStartTime,
          timestamp: DateTime.now(),
        );
        break;
      default:
        break;
    }
  }

  Future<void> _analyzeRecentEvents(String userId) async {
    final events = _eventBuffers[userId] ?? [];
    if (events.length < 10) return;

    // Analyze patterns in recent events
    final recentEvents = events.sublist(events.length - 10);
    
    // Count distractions
    final distractionCount = recentEvents
        .where((e) => e.type == AttentionEventType.distracted)
        .length;

    // Check for rapid task switching
    final taskSwitches = recentEvents
        .where((e) => e.type == AttentionEventType.taskSwitch)
        .length;

    // Alert if patterns indicate attention issues
    if (distractionCount > 5 || taskSwitches > 3) {
      safePrint('Attention issues detected for user $userId');
      // Trigger intervention
    }

    // Clean up old events
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _eventBuffers[userId] = events
        .where((e) => e.timestamp.isAfter(cutoff))
        .toList();
  }

  int _calculateAttentionSpan(List<AttentionEvent> events) {
    if (events.isEmpty) return 25; // Default

    // Find longest period without distraction
    int maxSpan = 0;
    DateTime? lastFocus;

    for (final event in events) {
      if (event.type == AttentionEventType.focused) {
        lastFocus = event.timestamp;
      } else if (event.type == AttentionEventType.distracted && lastFocus != null) {
        final span = event.timestamp.difference(lastFocus).inMinutes;
        maxSpan = math.max(maxSpan, span);
        lastFocus = null;
      }
    }

    return maxSpan > 0 ? maxSpan : 25;
  }

  Future<List<AttentionSession>> _fetchAttentionSessions(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Fetch from database - simplified
    return [];
  }

  AttentionMetrics _calculateAttentionMetrics(List<AttentionSession> sessions) {
    if (sessions.isEmpty) {
      return AttentionMetrics(
        averageFocus: 0.7,
        averageSpan: 25,
        focusConsistency: 0.5,
        distractionRate: 0.2,
        recoveryTime: 5,
        peakFocusTime: const TimeOfDay(hour: 10, minute: 0),
      );
    }

    // Calculate averages
    final totalFocus = sessions.fold(0.0, (sum, s) => sum + s.averageFocus);
    final totalSpan = sessions.fold(0, (sum, s) => sum + s.longestFocusPeriod);
    
    return AttentionMetrics(
      averageFocus: totalFocus / sessions.length,
      averageSpan: totalSpan ~/ sessions.length,
      focusConsistency: _calculateConsistency(sessions),
      distractionRate: _calculateDistractionRate(sessions),
      recoveryTime: _calculateAverageRecovery(sessions),
      peakFocusTime: _findPeakFocusTime(sessions),
    );
  }

  double _calculateConsistency(List<AttentionSession> sessions) {
    if (sessions.length < 2) return 0.5;

    final focuses = sessions.map((s) => s.averageFocus).toList();
    final mean = focuses.reduce((a, b) => a + b) / focuses.length;
    final variance = focuses
        .map((f) => math.pow(f - mean, 2))
        .reduce((a, b) => a + b) / focuses.length;

    return 1 / (1 + variance);
  }

  double _calculateDistractionRate(List<AttentionSession> sessions) {
    final totalTime = sessions.fold(0, (sum, s) => sum + s.duration);
    final totalDistractions = sessions.fold(0, (sum, s) => sum + s.distractionCount);

    return totalTime > 0 ? totalDistractions / (totalTime / 60) : 0.0;
  }

  int _calculateAverageRecovery(List<AttentionSession> sessions) {
    final recoveries = <int>[];

    for (final session in sessions) {
      recoveries.addAll(session.recoveryTimes);
    }

    return recoveries.isEmpty ? 5 
        : recoveries.reduce((a, b) => a + b) ~/ recoveries.length;
  }

  TimeOfDay _findPeakFocusTime(List<AttentionSession> sessions) {
    final hourlyFocus = <int, List<double>>{};

    for (final session in sessions) {
      final hour = session.startTime.hour;
      hourlyFocus[hour] ??= [];
      hourlyFocus[hour]!.add(session.averageFocus);
    }

    int peakHour = 10;
    double maxFocus = 0;

    hourlyFocus.forEach((hour, focuses) {
      final avg = focuses.reduce((a, b) => a + b) / focuses.length;
      if (avg > maxFocus) {
        maxFocus = avg;
        peakHour = hour;
      }
    });

    return TimeOfDay(hour: peakHour, minute: 0);
  }

  List<AttentionPattern> _identifyAttentionPatterns(List<AttentionSession> sessions) {
    final patterns = <AttentionPattern>[];

    // Warm-up pattern
    final warmupTime = _analyzeWarmupPattern(sessions);
    if (warmupTime > 0) {
      patterns.add(AttentionPattern(
        type: 'warmup',
        description: 'Requires $warmupTime minutes to reach peak focus',
        frequency: 0.8,
        impact: 'medium',
      ));
    }

    // Post-break pattern
    final postBreakDip = _analyzePostBreakPattern(sessions);
    if (postBreakDip) {
      patterns.add(AttentionPattern(
        type: 'post_break_dip',
        description: 'Focus drops after breaks',
        frequency: 0.6,
        impact: 'low',
      ));
    }

    // Time-of-day pattern
    final todPattern = _analyzeTimeOfDayPattern(sessions);
    if (todPattern != null) {
      patterns.add(todPattern);
    }

    return patterns;
  }

  int _analyzeWarmupPattern(List<AttentionSession> sessions) {
    final warmupTimes = <int>[];

    for (final session in sessions) {
      if (session.focusProgression.isNotEmpty) {
        // Find time to reach 80% of peak focus
        final peak = session.focusProgression.reduce(math.max);
        final threshold = peak * 0.8;

        for (int i = 0; i < session.focusProgression.length; i++) {
          if (session.focusProgression[i] >= threshold) {
            warmupTimes.add(i * 5); // Assuming 5-minute intervals
            break;
          }
        }
      }
    }

    return warmupTimes.isEmpty ? 0 
        : warmupTimes.reduce((a, b) => a + b) ~/ warmupTimes.length;
  }

  bool _analyzePostBreakPattern(List<AttentionSession> sessions) {
    // Check if focus typically drops after breaks
    return sessions.where((s) => s.postBreakDips > 0).length > sessions.length / 2;
  }

  AttentionPattern? _analyzeTimeOfDayPattern(List<AttentionSession> sessions) {
    // Group by time of day
    final morning = sessions.where((s) => s.startTime.hour < 12).toList();
    final afternoon = sessions.where((s) => 
      s.startTime.hour >= 12 && s.startTime.hour < 17).toList();
    final evening = sessions.where((s) => s.startTime.hour >= 17).toList();

    // Calculate average focus for each period
    final morningFocus = morning.isEmpty ? 0.0 
        : morning.map((s) => s.averageFocus).reduce((a, b) => a + b) / morning.length;
    final afternoonFocus = afternoon.isEmpty ? 0.0 
        : afternoon.map((s) => s.averageFocus).reduce((a, b) => a + b) / afternoon.length;
    final eveningFocus = evening.isEmpty ? 0.0 
        : evening.map((s) => s.averageFocus).reduce((a, b) => a + b) / evening.length;

    // Identify pattern
    if (morningFocus > afternoonFocus && morningFocus > eveningFocus) {
      return AttentionPattern(
        type: 'morning_person',
        description: 'Highest focus in morning hours',
        frequency: 0.9,
        impact: 'high',
      );
    } else if (eveningFocus > morningFocus && eveningFocus > afternoonFocus) {
      return AttentionPattern(
        type: 'night_owl',
        description: 'Highest focus in evening hours',
        frequency: 0.9,
        impact: 'high',
      );
    }

    return null;
  }

  DistractionAnalysis _analyzeDistractions(List<AttentionSession> sessions) {
    final allDistractions = <Distraction>[];

    for (final session in sessions) {
      allDistractions.addAll(session.distractions);
    }

    // Categorize distractions
    final categories = <String, int>{};
    final timeOfDay = <int, int>{};

    for (final distraction in allDistractions) {
      categories[distraction.category] = (categories[distraction.category] ?? 0) + 1;
      timeOfDay[distraction.timestamp.hour] = (timeOfDay[distraction.timestamp.hour] ?? 0) + 1;
    }

    // Find most common
    final commonTypes = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final commonTimes = timeOfDay.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DistractionAnalysis(
      totalCount: allDistractions.length,
      averagePerSession: sessions.isEmpty ? 0.0 
          : allDistractions.length / sessions.length,
      commonTypes: commonTypes.take(3).map((e) => e.key).toList(),
      peakDistrationTimes: commonTimes.take(3).map((e) => e.key).toList(),
      triggers: _identifyDistractionTriggers(allDistractions),
      impactOnPerformance: _calculateDistractionImpact(sessions),
    );
  }

  List<String> _identifyDistractionTriggers(List<Distraction> distractions) {
    final triggers = <String>{};

    for (final distraction in distractions) {
      if (distraction.trigger != null) {
        triggers.add(distraction.trigger!);
      }
    }

    return triggers.toList();
  }

  double _calculateDistractionImpact(List<AttentionSession> sessions) {
    // Compare performance with and without distractions
    final lowDistraction = sessions.where((s) => s.distractionCount < 3).toList();
    final highDistraction = sessions.where((s) => s.distractionCount >= 3).toList();

    if (lowDistraction.isEmpty || highDistraction.isEmpty) return 0.0;

    final lowPerf = lowDistraction
        .map((s) => s.taskPerformance)
        .reduce((a, b) => a + b) / lowDistraction.length;
    final highPerf = highDistraction
        .map((s) => s.taskPerformance)
        .reduce((a, b) => a + b) / highDistraction.length;

    return lowPerf - highPerf;
  }

  AttentionProfile _determineAttentionProfile(
    AttentionMetrics metrics,
    List<AttentionPattern> patterns,
  ) {
    String type = 'balanced';

    if (metrics.averageSpan > 40) {
      type = 'sustained';
    } else if (metrics.averageSpan < 20) {
      type = 'fragmented';
    } else if (metrics.focusConsistency > 0.8) {
      type = 'consistent';
    } else if (metrics.distractionRate > 0.5) {
      type = 'distractible';
    }

    return AttentionProfile(
      type: type,
      strengths: _identifyStrengths(metrics),
      weaknesses: _identifyWeaknesses(metrics),
      optimalConditions: _determineOptimalConditions(patterns),
      improvementPotential: _calculateImprovementPotential(metrics),
    );
  }

  List<String> _identifyStrengths(AttentionMetrics metrics) {
    final strengths = <String>[];

    if (metrics.averageFocus > 0.8) {
      strengths.add('High focus intensity');
    }
    if (metrics.averageSpan > 35) {
      strengths.add('Long attention span');
    }
    if (metrics.recoveryTime < 3) {
      strengths.add('Quick recovery from distractions');
    }
    if (metrics.focusConsistency > 0.7) {
      strengths.add('Consistent focus levels');
    }

    return strengths;
  }

  List<String> _identifyWeaknesses(AttentionMetrics metrics) {
    final weaknesses = <String>[];

    if (metrics.averageFocus < 0.6) {
      weaknesses.add('Low average focus');
    }
    if (metrics.averageSpan < 20) {
      weaknesses.add('Short attention span');
    }
    if (metrics.distractionRate > 0.4) {
      weaknesses.add('High distraction rate');
    }
    if (metrics.recoveryTime > 10) {
      weaknesses.add('Slow recovery from distractions');
    }

    return weaknesses;
  }

  Map<String, dynamic> _determineOptimalConditions(List<AttentionPattern> patterns) {
    final conditions = <String, dynamic>{};

    for (final pattern in patterns) {
      if (pattern.type == 'morning_person') {
        conditions['best_time'] = 'morning';
      } else if (pattern.type == 'night_owl') {
        conditions['best_time'] = 'evening';
      }

      if (pattern.type == 'warmup') {
        conditions['needs_warmup'] = true;
      }
    }

    return conditions;
  }

  double _calculateImprovementPotential(AttentionMetrics metrics) {
    // Calculate how much room for improvement exists
    double potential = 0.0;

    potential += (1.0 - metrics.averageFocus) * 0.3;
    potential += (60 - metrics.averageSpan) / 60 * 0.3;
    potential += metrics.distractionRate * 0.2;
    potential += (1.0 - metrics.focusConsistency) * 0.2;

    return potential.clamp(0.0, 1.0);
  }

  List<AttentionRecommendation> _generateAttentionRecommendations({
    required AttentionProfile profile,
    required List<AttentionPattern> patterns,
    required DistractionAnalysis distractions,
  }) {
    final recommendations = <AttentionRecommendation>[];

    // Profile-based recommendations
    switch (profile.type) {
      case 'fragmented':
        recommendations.add(AttentionRecommendation(
          title: 'Build Sustained Focus',
          description: 'Practice extending focus periods gradually',
          techniques: [
            'Start with 10-minute focus blocks',
            'Increase by 2 minutes each week',
            'Use timer to track progress',
          ],
          expectedBenefit: 'Increase attention span by 50%',
          priority: 1,
        ));
        break;
      case 'distractible':
        recommendations.add(AttentionRecommendation(
          title: 'Reduce Distractions',
          description: 'Minimize environmental and digital distractions',
          techniques: [
            'Use website blockers during study',
            'Create a dedicated study space',
            'Turn off notifications',
          ],
          expectedBenefit: 'Reduce distractions by 60%',
          priority: 1,
        ));
        break;
    }

    // Pattern-based recommendations
    for (final pattern in patterns) {
      if (pattern.type == 'warmup' && pattern.impact == 'medium') {
        recommendations.add(AttentionRecommendation(
          title: 'Optimize Warm-up',
          description: 'Use warm-up time effectively',
          techniques: [
            'Start with easier tasks',
            'Review previous material',
            'Do light physical exercise',
          ],
          expectedBenefit: 'Reach peak focus 30% faster',
          priority: 2,
        ));
      }
    }

    return recommendations;
  }

  List<AttentionInsight> _generateAttentionInsights(
    AttentionMetrics metrics,
    List<AttentionPattern> patterns,
  ) {
    final insights = <AttentionInsight>[];

    // Metric-based insights
    if (metrics.averageSpan > 40) {
      insights.add(AttentionInsight(
        type: 'strength',
        title: 'Exceptional Attention Span',
        description: 'Your attention span is ${metrics.averageSpan} minutes, well above average',
        implication: 'You can handle complex, lengthy tasks effectively',
      ));
    }

    // Pattern-based insights
    for (final pattern in patterns) {
      if (pattern.frequency > 0.7) {
        insights.add(AttentionInsight(
          type: 'pattern',
          title: pattern.type.replaceAll('_', ' ').toUpperCase(),
          description: pattern.description,
          implication: 'Plan your schedule around this pattern',
        ));
      }
    }

    return insights;
  }

  double _estimatePerformance(AttentionState state) {
    return state.currentFocus * 0.8 + (state.attentionSpan / 60) * 0.2;
  }

  bool _evaluateSustainedAttention(
    List<AttentionCheckpoint> checkpoints,
    int targetDuration,
  ) {
    if (checkpoints.isEmpty) return false;

    // Check if focus remained above threshold
    final focusAboveThreshold = checkpoints
        .where((c) => c.focusLevel >= _focusThreshold)
        .length;

    return focusAboveThreshold >= checkpoints.length * 0.8;
  }

  double _calculateAverageFocus(List<AttentionCheckpoint> checkpoints) {
    if (checkpoints.isEmpty) return 0.0;

    final total = checkpoints.fold(0.0, (sum, c) => sum + c.focusLevel);
    return total / checkpoints.length;
  }

  double _calculateFocusVariability(List<AttentionCheckpoint> checkpoints) {
    if (checkpoints.length < 2) return 0.0;

    final focuses = checkpoints.map((c) => c.focusLevel).toList();
    final mean = focuses.reduce((a, b) => a + b) / focuses.length;
    final variance = focuses
        .map((f) => math.pow(f - mean, 2))
        .reduce((a, b) => a + b) / focuses.length;

    return math.sqrt(variance);
  }

  List<String> _generateSustainedAttentionTips(
    bool success,
    List<AttentionCheckpoint> checkpoints,
  ) {
    final tips = <String>[];

    if (!success) {
      tips.add('Try shorter focus periods and gradually increase');
      tips.add('Ensure adequate rest before attempting sustained focus');
    }

    // Check for mid-session dips
    bool hasMidDip = false;
    if (checkpoints.length > 4) {
      final midIndex = checkpoints.length ~/ 2;
      if (checkpoints[midIndex].focusLevel < checkpoints[0].focusLevel * 0.8) {
        hasMidDip = true;
      }
    }

    if (hasMidDip) {
      tips.add('Consider a micro-break at the halfway point');
      tips.add('Try the 20-20-20 rule for eye strain');
    }

    return tips;
  }

  double _calculateWanderingScore(List<BehaviorSignal> signals) {
    double score = 0.0;

    for (final signal in signals) {
      switch (signal.type) {
        case 'gaze_deviation':
          score += signal.strength * 0.3;
          break;
        case 'task_switching':
          score += signal.strength * 0.25;
          break;
        case 'idle_time':
          score += signal.strength * 0.2;
          break;
        case 'typing_pause':
          score += signal.strength * 0.15;
          break;
        case 'scroll_pattern':
          score += signal.strength * 0.1;
          break;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  String _classifyWanderingType(List<BehaviorSignal> signals) {
    // Analyze signal patterns to determine wandering type
    final hasGazeDeviation = signals.any((s) => 
      s.type == 'gaze_deviation' && s.strength > 0.6);
    final hasTaskSwitching = signals.any((s) => 
      s.type == 'task_switching' && s.strength > 0.6);

    if (hasGazeDeviation && hasTaskSwitching) {
      return 'active_wandering';
    } else if (hasGazeDeviation) {
      return 'passive_wandering';
    } else if (hasTaskSwitching) {
      return 'task_wandering';
    }

    return 'mild_wandering';
  }

  double _calculateDetectionConfidence(List<BehaviorSignal> signals) {
    // More signals = higher confidence
    double confidence = math.min(signals.length * 0.1, 0.5);

    // Strong signals increase confidence
    final strongSignals = signals.where((s) => s.strength > 0.8).length;
    confidence += strongSignals * 0.1;

    return confidence.clamp(0.0, 0.95);
  }

  List<RecoveryStrategy> _generateRecoveryStrategies(String wanderingType) {
    switch (wanderingType) {
      case 'active_wandering':
        return [
          RecoveryStrategy(
            name: 'Task Reset',
            description: 'Close all distractions and return to main task',
            steps: [
              'Close unnecessary tabs/apps',
              'Take 3 deep breaths',
              'Re-read task objectives',
            ],
            estimatedTime: 2,
          ),
          RecoveryStrategy(
            name: 'Pomodoro Restart',
            description: 'Start a fresh Pomodoro session',
            steps: [
              'Note where you left off',
              'Set 25-minute timer',
              'Focus on single sub-task',
            ],
            estimatedTime: 1,
          ),
        ];
      case 'passive_wandering':
        return [
          RecoveryStrategy(
            name: 'Active Engagement',
            description: 'Increase active participation',
            steps: [
              'Stand up and stretch',
              'Read content aloud',
              'Take active notes',
            ],
            estimatedTime: 3,
          ),
        ];
      default:
        return [
          RecoveryStrategy(
            name: 'Gentle Refocus',
            description: 'Gradually return attention',
            steps: [
              'Acknowledge wandering without judgment',
              'Focus on breath for 30 seconds',
              'Return to task',
            ],
            estimatedTime: 1,
          ),
        ];
    }
  }

  // Additional helper methods continue...

  Future<UserAttentionProfile> _getUserAttentionProfile(String userId) async {
    // Fetch user's attention profile
    return UserAttentionProfile(
      averageSpan: 25,
      peakFocusTime: const TimeOfDay(hour: 10, minute: 0),
      distractionSensitivity: 0.6,
      recoverySpeed: 0.7,
    );
  }

  TaskRequirements _analyzeTaskRequirements(TaskProfile task) {
    return TaskRequirements(
      minFocusDuration: task.estimatedDuration,
      cognitiveLoad: task.complexity,
      attentionType: task.requiresSustained ? 'sustained' : 'selective',
      interruptionTolerance: task.allowsBreaks ? 0.7 : 0.2,
    );
  }

  double _calculateCompatibility(
    UserAttentionProfile profile,
    TaskRequirements requirements,
  ) {
    double compatibility = 1.0;

    // Check duration compatibility
    if (requirements.minFocusDuration > profile.averageSpan) {
      compatibility *= profile.averageSpan / requirements.minFocusDuration;
    }

    // Check cognitive load compatibility
    if (requirements.cognitiveLoad > 0.7 && profile.distractionSensitivity > 0.6) {
      compatibility *= 0.8;
    }

    return compatibility.clamp(0.0, 1.0);
  }

  List<AttentionStrategy> _generateOptimizationStrategies({
    required UserAttentionProfile profile,
    required TaskRequirements requirements,
    required double compatibility,
  }) {
    final strategies = <AttentionStrategy>[];

    if (compatibility < 0.7) {
      strategies.add(AttentionStrategy(
        name: 'Task Chunking',
        description: 'Break task into smaller segments',
        implementation: 'Divide into ${profile.averageSpan}-minute chunks',
      ));
    }

    if (requirements.cognitiveLoad > 0.7) {
      strategies.add(AttentionStrategy(
        name: 'Load Distribution',
        description: 'Alternate high and low cognitive load',
        implementation: 'Follow difficult sections with easier review',
      ));
    }

    return strategies;
  }

  AttentionSchedule _createAttentionSchedule({
    required TaskProfile task,
    required UserAttentionProfile profile,
    required List<AttentionStrategy> strategies,
  }) {
    final blocks = <FocusBlock>[];
    int remainingDuration = task.estimatedDuration;
    int blockNumber = 0;

    while (remainingDuration > 0) {
      final blockDuration = math.min(profile.averageSpan, remainingDuration);
      
      blocks.add(FocusBlock(
        number: blockNumber++,
        duration: blockDuration,
        focusType: blockNumber % 2 == 0 ? 'deep' : 'moderate',
        breakAfter: remainingDuration > blockDuration ? 5 : 0,
      ));

      remainingDuration -= blockDuration + 5; // Include break
    }

    return AttentionSchedule(blocks: blocks, totalDuration: task.estimatedDuration);
  }

  int _calculateExpectedFocus(UserAttentionProfile profile, TaskProfile task) {
    if (task.estimatedDuration <= profile.averageSpan) {
      return task.estimatedDuration;
    }

    // Account for breaks and fatigue
    final sessions = task.estimatedDuration ~/ profile.averageSpan;
    final focusTime = sessions * profile.averageSpan;
    final efficiency = 0.9 - (sessions * 0.05); // Decrease with more sessions

    return (focusTime * efficiency).round();
  }

  List<BreakRecommendation> _generateBreakRecommendations(
    TaskProfile task,
    UserAttentionProfile profile,
  ) {
    final recommendations = <BreakRecommendation>[];

    if (task.estimatedDuration > profile.averageSpan) {
      recommendations.add(BreakRecommendation(
        afterMinutes: profile.averageSpan,
        duration: 5,
        activity: 'Stand and stretch',
        reason: 'Matches your natural attention span',
      ));
    }

    if (task.complexity > 0.7) {
      recommendations.add(BreakRecommendation(
        afterMinutes: 45,
        duration: 10,
        activity: 'Walk or light exercise',
        reason: 'High cognitive load requires longer recovery',
      ));
    }

    return recommendations;
  }

  Map<String, dynamic> _identifyEnvironmentalFactors(UserAttentionProfile profile) {
    return {
      'noise_sensitivity': profile.distractionSensitivity > 0.6 ? 'high' : 'low',
      'ideal_temperature': '20-22°C',
      'lighting': 'natural or warm white',
      'minimize_notifications': true,
    };
  }

  double _predictAttentionSuccess({
    required UserAttentionProfile profile,
    required TaskProfile task,
    required List<AttentionStrategy> strategies,
  }) {
    double baseProbability = 0.5;

    // Adjust for compatibility
    if (task.estimatedDuration <= profile.averageSpan) {
      baseProbability += 0.2;
    }

    // Adjust for strategies
    baseProbability += strategies.length * 0.1;

    // Adjust for time of day
    final currentHour = DateTime.now().hour;
    if ((profile.peakFocusTime.hour - currentHour).abs() <= 2) {
      baseProbability += 0.15;
    }

    return baseProbability.clamp(0.0, 0.95);
  }

  Future<AttentionBaseline> _assessAttentionSkills(String userId) async {
    // Assess current attention skills
    return AttentionBaseline(
      sustainedAttention: 0.6,
      selectiveAttention: 0.7,
      dividedAttention: 0.5,
      executiveControl: 0.65,
      currentSpan: 25,
    );
  }

  List<AttentionExercise> _createProgressiveExercises({
    required AttentionBaseline baseline,
    required List<String> weakAreas,
    required int duration,
  }) {
    final exercises = <AttentionExercise>[];

    // Create exercises for each weak area
    for (final area in weakAreas) {
      switch (area) {
        case 'sustained_attention':
          exercises.add(AttentionExercise(
            name: 'Focus Extension',
            type: 'sustained',
            description: 'Gradually increase focus duration',
            startingDuration: baseline.currentSpan,
            targetDuration: baseline.currentSpan * 2,
            progressionRate: 2, // minutes per week
            techniques: ['Pomodoro', 'Mindful breathing'],
          ));
          break;
        case 'selective_attention':
          exercises.add(AttentionExercise(
            name: 'Distraction Filtering',
            type: 'selective',
            description: 'Practice ignoring irrelevant stimuli',
            startingDuration: 10,
            targetDuration: 20,
            progressionRate: 1,
            techniques: ['Stroop tasks', 'Attention anchoring'],
          ));
          break;
      }
    }

    return exercises;
  }

  List<TrainingMilestone> _setTrainingMilestones({
    required AttentionBaseline baseline,
    required int targetDuration,
  }) {
    final milestones = <TrainingMilestone>[];
    
    // Week 1 milestone
    milestones.add(TrainingMilestone(
      week: 1,
      targetSpan: baseline.currentSpan + 5,
      targetFocusLevel: baseline.sustainedAttention + 0.05,
      assessmentTask: 'Complete 30-minute focused reading',
    ));

    // Week 2 milestone
    milestones.add(TrainingMilestone(
      week: 2,
      targetSpan: baseline.currentSpan + 10,
      targetFocusLevel: baseline.sustainedAttention + 0.1,
      assessmentTask: 'Work on complex problem for 40 minutes',
    ));

    // Add more milestones based on duration

    return milestones;
  }

  List<DailyRoutine> _generateDailyRoutines({
    required List<AttentionExercise> exercises,
    required AttentionBaseline userProfile,
  }) {
    final routines = <DailyRoutine>[];

    // Morning routine
    routines.add(DailyRoutine(
      timeOfDay: 'morning',
      duration: 20,
      activities: [
        'Mindfulness meditation (5 min)',
        'Focus warm-up exercise (10 min)',
        'Set daily intentions (5 min)',
      ],
      purpose: 'Prepare attention systems for the day',
    ));

    // Main practice routine
    routines.add(DailyRoutine(
      timeOfDay: 'peak_hours',
      duration: 45,
      activities: [
        'Primary attention exercise (25 min)',
        'Break (5 min)',
        'Secondary exercise (15 min)',
      ],
      purpose: 'Build core attention skills',
    ));

    return routines;
  }

  Map<String, double> _calculateExpectedImprovement(
    AttentionBaseline baseline,
    int trainingDays,
  ) {
    // Estimate improvement based on training duration
    final weeks = trainingDays / 7;
    
    return {
      'attention_span': baseline.currentSpan * (1 + weeks * 0.1),
      'sustained_attention': baseline.sustainedAttention + (weeks * 0.02),
      'selective_attention': baseline.selectiveAttention + (weeks * 0.015),
      'overall_improvement': weeks * 0.05,
    };
  }

  List<String> _defineTrackingMetrics(List<String> weakAreas) {
    final metrics = <String>[
      'Daily focus duration',
      'Distraction frequency',
      'Task completion rate',
      'Focus quality score',
    ];

    // Add specific metrics for weak areas
    for (final area in weakAreas) {
      if (area == 'sustained_attention') {
        metrics.add('Longest uninterrupted focus period');
      } else if (area == 'selective_attention') {
        metrics.add('Distraction recovery time');
      }
    }

    return metrics;
  }
}

// Data models
class AttentionState {
  final String userId;
  final double currentFocus;
  final int attentionSpan;
  final int distractionCount;
  final DateTime? lastDistraction;
  final DateTime sessionStartTime;
  final DateTime timestamp;

  AttentionState({
    required this.userId,
    required this.currentFocus,
    required this.attentionSpan,
    required this.distractionCount,
    this.lastDistraction,
    required this.sessionStartTime,
    required this.timestamp,
  });
}

class AttentionEvent {
  final AttentionEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  AttentionEvent({
    required this.type,
    required this.timestamp,
    required this.metadata,
  });
}

enum AttentionEventType {
  focused,
  distracted,
  refocused,
  taskSwitch,
  break_taken,
  session_start,
  session_end
}

class AttentionAnalysis {
  final String userId;
  final DateTimeRange period;
  final AttentionMetrics metrics;
  final List<AttentionPattern> patterns;
  final DistractionAnalysis distractionAnalysis;
  final AttentionProfile attentionProfile;
  final List<AttentionRecommendation> recommendations;
  final List<AttentionInsight> insights;

  AttentionAnalysis({
    required this.userId,
    required this.period,
    required this.metrics,
    required this.patterns,
    required this.distractionAnalysis,
    required this.attentionProfile,
    required this.recommendations,
    required this.insights,
  });
}

class AttentionMetrics {
  final double averageFocus;
  final int averageSpan;
  final double focusConsistency;
  final double distractionRate;
  final int recoveryTime;
  final TimeOfDay peakFocusTime;

  AttentionMetrics({
    required this.averageFocus,
    required this.averageSpan,
    required this.focusConsistency,
    required this.distractionRate,
    required this.recoveryTime,
    required this.peakFocusTime,
  });
}

class AttentionPattern {
  final String type;
  final String description;
  final double frequency;
  final String impact;

  AttentionPattern({
    required this.type,
    required this.description,
    required this.frequency,
    required this.impact,
  });
}

class DistractionAnalysis {
  final int totalCount;
  final double averagePerSession;
  final List<String> commonTypes;
  final List<int> peakDistrationTimes;
  final List<String> triggers;
  final double impactOnPerformance;

  DistractionAnalysis({
    required this.totalCount,
    required this.averagePerSession,
    required this.commonTypes,
    required this.peakDistrationTimes,
    required this.triggers,
    required this.impactOnPerformance,
  });
}

class AttentionProfile {
  final String type;
  final List<String> strengths;
  final List<String> weaknesses;
  final Map<String, dynamic> optimalConditions;
  final double improvementPotential;

  AttentionProfile({
    required this.type,
    required this.strengths,
    required this.weaknesses,
    required this.optimalConditions,
    required this.improvementPotential,
  });
}

class AttentionRecommendation {
  final String title;
  final String description;
  final List<String> techniques;
  final String expectedBenefit;
  final int priority;

  AttentionRecommendation({
    required this.title,
    required this.description,
    required this.techniques,
    required this.expectedBenefit,
    required this.priority,
  });
}

class AttentionInsight {
  final String type;
  final String title;
  final String description;
  final String implication;

  AttentionInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.implication,
  });
}

class SustainedAttentionReport {
  final String taskId;
  final int targetDuration;
  final int actualDuration;
  final bool success;
  final double averageFocus;
  final double focusVariability;
  final int distractionCount;
  final List<AttentionCheckpoint> checkpoints;
  final List<String> recommendations;

  SustainedAttentionReport({
    required this.taskId,
    required this.targetDuration,
    required this.actualDuration,
    required this.success,
    required this.averageFocus,
    required this.focusVariability,
    required this.distractionCount,
    required this.checkpoints,
    required this.recommendations,
  });
}

class AttentionCheckpoint {
  final DateTime timestamp;
  final double focusLevel;
  final int distractionsSinceStart;
  final double performance;

  AttentionCheckpoint({
    required this.timestamp,
    required this.focusLevel,
    required this.distractionsSinceStart,
    required this.performance,
  });
}

class WanderingDetection {
  final bool isWandering;
  final double confidence;
  final double wanderingScore;
  final String wanderingType;
  final List<BehaviorSignal> triggerSignals;
  final bool interventionNeeded;
  final List<RecoveryStrategy> recoveryStrategies;

  WanderingDetection({
    required this.isWandering,
    required this.confidence,
    required this.wanderingScore,
    required this.wanderingType,
    required this.triggerSignals,
    required this.interventionNeeded,
    required this.recoveryStrategies,
  });
}

class BehaviorSignal {
  final String type;
  final double strength;
  final DateTime timestamp;

  BehaviorSignal({
    required this.type,
    required this.strength,
    required this.timestamp,
  });
}

class RecoveryStrategy {
  final String name;
  final String description;
  final List<String> steps;
  final int estimatedTime;

  RecoveryStrategy({
    required this.name,
    required this.description,
    required this.steps,
    required this.estimatedTime,
  });
}

class AttentionOptimization {
  final double taskCompatibility;
  final List<AttentionStrategy> recommendedStrategies;
  final AttentionSchedule attentionSchedule;
  final int expectedFocusDuration;
  final List<BreakRecommendation> breakRecommendations;
  final Map<String, dynamic> environmentalFactors;
  final double successProbability;

  AttentionOptimization({
    required this.taskCompatibility,
    required this.recommendedStrategies,
    required this.attentionSchedule,
    required this.expectedFocusDuration,
    required this.breakRecommendations,
    required this.environmentalFactors,
    required this.successProbability,
  });
}

class TaskProfile {
  final String name;
  final int estimatedDuration;
  final double complexity;
  final bool requiresSustained;
  final bool allowsBreaks;

  TaskProfile({
    required this.name,
    required this.estimatedDuration,
    required this.complexity,
    required this.requiresSustained,
    required this.allowsBreaks,
  });
}

class AttentionStrategy {
  final String name;
  final String description;
  final String implementation;

  AttentionStrategy({
    required this.name,
    required this.description,
    required this.implementation,
  });
}

class AttentionSchedule {
  final List<FocusBlock> blocks;
  final int totalDuration;

  AttentionSchedule({
    required this.blocks,
    required this.totalDuration,
  });
}

class FocusBlock {
  final int number;
  final int duration;
  final String focusType;
  final int breakAfter;

  FocusBlock({
    required this.number,
    required this.duration,
    required this.focusType,
    required this.breakAfter,
  });
}

class BreakRecommendation {
  final int afterMinutes;
  final int duration;
  final String activity;
  final String reason;

  BreakRecommendation({
    required this.afterMinutes,
    required this.duration,
    required this.activity,
    required this.reason,
  });
}

class AttentionTrainingPlan {
  final String userId;
  final AttentionBaseline baseline;
  final List<AttentionExercise> exercises;
  final List<TrainingMilestone> milestones;
  final List<DailyRoutine> dailyRoutines;
  final Map<String, double> expectedImprovement;
  final List<String> trackingMetrics;

  AttentionTrainingPlan({
    required this.userId,
    required this.baseline,
    required this.exercises,
    required this.milestones,
    required this.dailyRoutines,
    required this.expectedImprovement,
    required this.trackingMetrics,
  });
}

class AttentionBaseline {
  final double sustainedAttention;
  final double selectiveAttention;
  final double dividedAttention;
  final double executiveControl;
  final int currentSpan;

  AttentionBaseline({
    required this.sustainedAttention,
    required this.selectiveAttention,
    required this.dividedAttention,
    required this.executiveControl,
    required this.currentSpan,
  });
}

class AttentionExercise {
  final String name;
  final String type;
  final String description;
  final int startingDuration;
  final int targetDuration;
  final int progressionRate;
  final List<String> techniques;

  AttentionExercise({
    required this.name,
    required this.type,
    required this.description,
    required this.startingDuration,
    required this.targetDuration,
    required this.progressionRate,
    required this.techniques,
  });
}

class TrainingMilestone {
  final int week;
  final int targetSpan;
  final double targetFocusLevel;
  final String assessmentTask;

  TrainingMilestone({
    required this.week,
    required this.targetSpan,
    required this.targetFocusLevel,
    required this.assessmentTask,
  });
}

class DailyRoutine {
  final String timeOfDay;
  final int duration;
  final List<String> activities;
  final String purpose;

  DailyRoutine({
    required this.timeOfDay,
    required this.duration,
    required this.activities,
    required this.purpose,
  });
}

// Supporting classes
class AttentionSession {
  final DateTime startTime;
  final int duration;
  final double averageFocus;
  final int longestFocusPeriod;
  final int distractionCount;
  final List<int> recoveryTimes;
  final List<double> focusProgression;
  final int postBreakDips;
  final List<Distraction> distractions;
  final double taskPerformance;

  AttentionSession({
    required this.startTime,
    required this.duration,
    required this.averageFocus,
    required this.longestFocusPeriod,
    required this.distractionCount,
    required this.recoveryTimes,
    required this.focusProgression,
    required this.postBreakDips,
    required this.distractions,
    required this.taskPerformance,
  });
}

class Distraction {
  final String category;
  final DateTime timestamp;
  final int duration;
  final String? trigger;

  Distraction({
    required this.category,
    required this.timestamp,
    required this.duration,
    this.trigger,
  });
}

class UserAttentionProfile {
  final int averageSpan;
  final TimeOfDay peakFocusTime;
  final double distractionSensitivity;
  final double recoverySpeed;

  UserAttentionProfile({
    required this.averageSpan,
    required this.peakFocusTime,
    required this.distractionSensitivity,
    required this.recoverySpeed,
  });
}

class TaskRequirements {
  final int minFocusDuration;
  final double cognitiveLoad;
  final String attentionType;
  final double interruptionTolerance;

  TaskRequirements({
    required this.minFocusDuration,
    required this.cognitiveLoad,
    required this.attentionType,
    required this.interruptionTolerance,
  });
}