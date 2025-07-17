import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for monitoring and managing cognitive load
class CognitiveLoadMonitor {
  static final CognitiveLoadMonitor _instance = CognitiveLoadMonitor._internal();
  factory CognitiveLoadMonitor() => _instance;
  CognitiveLoadMonitor._internal();

  // Cognitive load thresholds
  static const double _optimalLoadMin = 0.4;
  static const double _optimalLoadMax = 0.7;
  static const double _overloadThreshold = 0.85;
  
  // Real-time monitoring state
  final Map<String, CognitiveLoadState> _userStates = {};
  final Map<String, StreamController<CognitiveLoadState>> _stateControllers = {};

  /// Start monitoring cognitive load for a user
  Stream<CognitiveLoadState> startMonitoring(String userId) {
    // Initialize state if needed
    _userStates[userId] ??= CognitiveLoadState(
      userId: userId,
      currentLoad: 0.5,
      intrinsicLoad: 0.3,
      extraneousLoad: 0.1,
      germaneLoad: 0.1,
      timestamp: DateTime.now(),
    );

    // Create stream controller if needed
    _stateControllers[userId] ??= StreamController<CognitiveLoadState>.broadcast();

    // Start periodic updates
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_stateControllers.containsKey(userId)) {
        timer.cancel();
        return;
      }
      _updateCognitiveLoad(userId);
    });

    return _stateControllers[userId]!.stream;
  }

  /// Stop monitoring for a user
  void stopMonitoring(String userId) {
    _stateControllers[userId]?.close();
    _stateControllers.remove(userId);
    _userStates.remove(userId);
  }

  /// Update cognitive load based on current activity
  Future<void> updateActivityContext({
    required String userId,
    required ActivityContext context,
  }) async {
    try {
      final state = _userStates[userId];
      if (state == null) return;

      // Calculate load components
      final intrinsic = _calculateIntrinsicLoad(context);
      final extraneous = _calculateExtraneousLoad(context);
      final germane = _calculateGermaneLoad(context);
      
      // Update state
      final newState = CognitiveLoadState(
        userId: userId,
        currentLoad: intrinsic + extraneous + germane,
        intrinsicLoad: intrinsic,
        extraneousLoad: extraneous,
        germaneLoad: germane,
        timestamp: DateTime.now(),
        currentActivity: context.activityType,
        subjectComplexity: context.subjectComplexity,
        environmentFactors: _assessEnvironment(context),
      );

      _userStates[userId] = newState;
      _stateControllers[userId]?.add(newState);

      // Check for overload
      if (newState.currentLoad > _overloadThreshold) {
        await _handleCognitiveOverload(userId, newState);
      }
    } catch (e) {
      safePrint('Error updating activity context: $e');
    }
  }

  /// Analyze cognitive load patterns
  Future<CognitiveLoadAnalysis> analyzeCognitiveLoad({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Fetch historical data
      final history = await _fetchLoadHistory(userId, startDate, endDate);
      
      // Analyze patterns
      final patterns = _identifyLoadPatterns(history);
      
      // Calculate statistics
      final stats = _calculateLoadStatistics(history);
      
      // Identify overload episodes
      final overloadEpisodes = _identifyOverloadEpisodes(history);
      
      // Analyze recovery patterns
      final recoveryAnalysis = _analyzeRecoveryPatterns(history);
      
      // Generate recommendations
      final recommendations = _generateLoadRecommendations(
        patterns: patterns,
        stats: stats,
        overloadEpisodes: overloadEpisodes,
      );
      
      return CognitiveLoadAnalysis(
        userId: userId,
        period: DateTimeRange(start: startDate, end: endDate),
        averageLoad: stats.averageLoad,
        peakLoad: stats.peakLoad,
        optimalLoadPercentage: stats.optimalLoadPercentage,
        overloadFrequency: overloadEpisodes.length,
        patterns: patterns,
        overloadEpisodes: overloadEpisodes,
        recoveryAnalysis: recoveryAnalysis,
        recommendations: recommendations,
      );
    } catch (e) {
      safePrint('Error analyzing cognitive load: $e');
      rethrow;
    }
  }

  /// Calculate optimal task difficulty
  Future<DifficultyRecommendation> recommendTaskDifficulty({
    required String userId,
    required String taskType,
    required double currentPerformance,
  }) async {
    try {
      final state = _userStates[userId] ?? await _getCurrentState(userId);
      
      // Calculate available cognitive capacity
      final availableCapacity = 1.0 - state.currentLoad;
      
      // Factor in performance trends
      final performanceFactor = _calculatePerformanceFactor(currentPerformance);
      
      // Determine optimal difficulty
      final optimalDifficulty = _calculateOptimalDifficulty(
        availableCapacity: availableCapacity,
        performanceFactor: performanceFactor,
        taskType: taskType,
      );
      
      // Generate task recommendations
      final tasks = await _generateDifficultyBasedTasks(
        userId: userId,
        taskType: taskType,
        targetDifficulty: optimalDifficulty,
      );
      
      return DifficultyRecommendation(
        recommendedDifficulty: optimalDifficulty,
        currentCapacity: availableCapacity,
        reasoning: _explainDifficultyChoice(optimalDifficulty, state),
        suggestedTasks: tasks,
        alternativeDifficulties: _generateAlternatives(optimalDifficulty),
      );
    } catch (e) {
      safePrint('Error recommending task difficulty: $e');
      rethrow;
    }
  }

  /// Monitor working memory usage
  Future<WorkingMemoryStatus> assessWorkingMemory({
    required String userId,
    required List<ActiveItem> currentItems,
  }) async {
    try {
      // Calculate memory load
      final itemCount = currentItems.length;
      final complexity = _calculateItemComplexity(currentItems);
      
      // Estimate chunks used
      final chunksUsed = _estimateChunks(currentItems);
      
      // Calculate utilization
      final utilization = chunksUsed / 7.0; // Miller's magic number
      
      // Assess interference
      final interference = _assessInterference(currentItems);
      
      // Generate optimization suggestions
      final optimizations = _generateMemoryOptimizations(
        currentItems: currentItems,
        utilization: utilization,
        interference: interference,
      );
      
      return WorkingMemoryStatus(
        itemCount: itemCount,
        chunksUsed: chunksUsed,
        utilization: utilization,
        complexityScore: complexity,
        interferenceLevel: interference,
        isOverloaded: utilization > 0.9,
        optimizations: optimizations,
      );
    } catch (e) {
      safePrint('Error assessing working memory: $e');
      rethrow;
    }
  }

  /// Predict cognitive fatigue
  Future<FatiguePrediction> predictCognitiveFatigue({
    required String userId,
    required int plannedDuration,
  }) async {
    try {
      final state = _userStates[userId] ?? await _getCurrentState(userId);
      final history = await _getRecentHistory(userId);
      
      // Calculate current fatigue level
      final currentFatigue = _calculateCurrentFatigue(state, history);
      
      // Project fatigue over time
      final projections = <FatigueProjection>[];
      double fatigue = currentFatigue;
      
      for (int minutes = 15; minutes <= plannedDuration; minutes += 15) {
        fatigue = _projectFatigue(
          current: fatigue,
          cognitiveLoad: state.currentLoad,
          duration: 15,
        );
        
        projections.add(FatigueProjection(
          timeMinutes: minutes,
          fatigueLevel: fatigue,
          performanceImpact: _calculatePerformanceImpact(fatigue),
        ));
      }
      
      // Find optimal break points
      final breakPoints = _findOptimalBreakPoints(projections);
      
      // Generate fatigue management plan
      final managementPlan = _generateFatigueManagementPlan(
        projections: projections,
        breakPoints: breakPoints,
      );
      
      return FatiguePrediction(
        currentFatigue: currentFatigue,
        projections: projections,
        optimalBreakPoints: breakPoints,
        managementPlan: managementPlan,
        maxProductiveDuration: _findMaxProductiveDuration(projections),
      );
    } catch (e) {
      safePrint('Error predicting cognitive fatigue: $e');
      rethrow;
    }
  }

  /// Optimize cognitive load distribution
  Future<LoadOptimizationPlan> optimizeCognitiveLoad({
    required String userId,
    required List<PlannedActivity> activities,
    required Duration timeframe,
  }) async {
    try {
      // Analyze activity cognitive demands
      final demands = _analyzeActivityDemands(activities);
      
      // Get user's cognitive capacity profile
      final capacityProfile = await _getUserCapacityProfile(userId);
      
      // Optimize activity sequence
      final optimizedSequence = _optimizeActivitySequence(
        activities: activities,
        demands: demands,
        capacityProfile: capacityProfile,
      );
      
      // Distribute breaks optimally
      final breakSchedule = _optimizeBreakSchedule(
        sequence: optimizedSequence,
        timeframe: timeframe,
      );
      
      // Calculate expected outcomes
      final outcomes = _predictOptimizationOutcomes(
        original: activities,
        optimized: optimizedSequence,
        breaks: breakSchedule,
      );
      
      return LoadOptimizationPlan(
        originalSequence: activities,
        optimizedSequence: optimizedSequence,
        breakSchedule: breakSchedule,
        expectedImprovement: outcomes.improvementPercentage,
        cognitiveLoadProfile: _generateLoadProfile(optimizedSequence),
        recommendations: _generateOptimizationTips(outcomes),
      );
    } catch (e) {
      safePrint('Error optimizing cognitive load: $e');
      rethrow;
    }
  }

  // Private helper methods

  void _updateCognitiveLoad(String userId) {
    final state = _userStates[userId];
    if (state == null) return;

    // Simulate load changes based on time and recovery
    final timeSinceUpdate = DateTime.now().difference(state.timestamp).inSeconds;
    final recovery = timeSinceUpdate * 0.001; // Simple recovery model
    
    final newLoad = (state.currentLoad - recovery).clamp(0.0, 1.0);
    
    final updatedState = CognitiveLoadState(
      userId: userId,
      currentLoad: newLoad,
      intrinsicLoad: state.intrinsicLoad * 0.95, // Gradual decrease
      extraneousLoad: state.extraneousLoad * 0.9,
      germaneLoad: state.germaneLoad,
      timestamp: DateTime.now(),
    );
    
    _userStates[userId] = updatedState;
    _stateControllers[userId]?.add(updatedState);
  }

  double _calculateIntrinsicLoad(ActivityContext context) {
    // Base complexity of the material
    double load = context.subjectComplexity ?? 0.5;
    
    // Adjust for prior knowledge
    if (context.priorKnowledge != null) {
      load *= (1 - context.priorKnowledge! * 0.3);
    }
    
    // Adjust for concept interconnectedness
    if (context.conceptCount != null) {
      load += context.conceptCount! * 0.02;
    }
    
    return load.clamp(0.0, 0.6);
  }

  double _calculateExtraneousLoad(ActivityContext context) {
    double load = 0.0;
    
    // Poor instructional design
    if (context.hasDistractions == true) {
      load += 0.15;
    }
    
    // Split attention effect
    if (context.requiresMultitasking == true) {
      load += 0.2;
    }
    
    // Unclear instructions
    if (context.clarityScore != null) {
      load += (1 - context.clarityScore!) * 0.15;
    }
    
    return load.clamp(0.0, 0.4);
  }

  double _calculateGermaneLoad(ActivityContext context) {
    double load = 0.0;
    
    // Schema construction activities
    if (context.requiresIntegration == true) {
      load += 0.15;
    }
    
    // Problem-solving practice
    if (context.activityType == 'problem_solving') {
      load += 0.2;
    }
    
    // Reflection and metacognition
    if (context.includesReflection == true) {
      load += 0.1;
    }
    
    return load.clamp(0.0, 0.3);
  }

  Map<String, double> _assessEnvironment(ActivityContext context) {
    return {
      'noise_level': context.noiseLevel ?? 0.3,
      'interruptions': context.interruptionFrequency ?? 0.2,
      'comfort': context.comfortLevel ?? 0.7,
      'lighting': context.lightingQuality ?? 0.8,
    };
  }

  Future<void> _handleCognitiveOverload(String userId, CognitiveLoadState state) async {
    // Log overload event
    await _logOverloadEvent(userId, state);
    
    // Trigger intervention
    // This would integrate with the proactive intervention service
    safePrint('Cognitive overload detected for user $userId');
  }

  Future<List<CognitiveLoadDataPoint>> _fetchLoadHistory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Fetch from database - simplified
    return [];
  }

  List<LoadPattern> _identifyLoadPatterns(List<CognitiveLoadDataPoint> history) {
    final patterns = <LoadPattern>[];
    
    // Time-based patterns
    final timePatterns = _findTimeBasedPatterns(history);
    patterns.addAll(timePatterns);
    
    // Activity-based patterns
    final activityPatterns = _findActivityPatterns(history);
    patterns.addAll(activityPatterns);
    
    // Recovery patterns
    final recoveryPatterns = _findRecoveryPatterns(history);
    patterns.addAll(recoveryPatterns);
    
    return patterns;
  }

  LoadStatistics _calculateLoadStatistics(List<CognitiveLoadDataPoint> history) {
    if (history.isEmpty) {
      return LoadStatistics(
        averageLoad: 0.5,
        peakLoad: 0.5,
        optimalLoadPercentage: 0.0,
      );
    }
    
    final loads = history.map((h) => h.totalLoad).toList();
    final average = loads.reduce((a, b) => a + b) / loads.length;
    final peak = loads.reduce(math.max);
    
    final optimalCount = loads.where((l) => l >= _optimalLoadMin && l <= _optimalLoadMax).length;
    final optimalPercentage = optimalCount / loads.length;
    
    return LoadStatistics(
      averageLoad: average,
      peakLoad: peak,
      optimalLoadPercentage: optimalPercentage,
    );
  }

  List<OverloadEpisode> _identifyOverloadEpisodes(List<CognitiveLoadDataPoint> history) {
    final episodes = <OverloadEpisode>[];
    
    OverloadEpisode? currentEpisode;
    
    for (final point in history) {
      if (point.totalLoad > _overloadThreshold) {
        if (currentEpisode == null) {
          currentEpisode = OverloadEpisode(
            startTime: point.timestamp,
            peakLoad: point.totalLoad,
            duration: 0,
          );
        } else {
          currentEpisode.peakLoad = math.max(currentEpisode.peakLoad, point.totalLoad);
        }
      } else if (currentEpisode != null) {
        currentEpisode.endTime = point.timestamp;
        currentEpisode.duration = currentEpisode.endTime!
            .difference(currentEpisode.startTime)
            .inMinutes;
        episodes.add(currentEpisode);
        currentEpisode = null;
      }
    }
    
    return episodes;
  }

  RecoveryAnalysis _analyzeRecoveryPatterns(List<CognitiveLoadDataPoint> history) {
    // Analyze how quickly load decreases after peaks
    final recoveryRates = <double>[];
    
    for (int i = 1; i < history.length; i++) {
      if (history[i-1].totalLoad > _overloadThreshold && 
          history[i].totalLoad < history[i-1].totalLoad) {
        final rate = (history[i-1].totalLoad - history[i].totalLoad) / 
                    history[i].timestamp.difference(history[i-1].timestamp).inMinutes;
        recoveryRates.add(rate);
      }
    }
    
    final avgRecoveryRate = recoveryRates.isEmpty ? 0.01 
        : recoveryRates.reduce((a, b) => a + b) / recoveryRates.length;
    
    return RecoveryAnalysis(
      averageRecoveryRate: avgRecoveryRate,
      optimalRestDuration: (0.3 / avgRecoveryRate).round(), // Time to recover 30%
      recoveryPatterns: _categorizeRecoveryPatterns(recoveryRates),
    );
  }

  List<LoadRecommendation> _generateLoadRecommendations({
    required List<LoadPattern> patterns,
    required LoadStatistics stats,
    required List<OverloadEpisode> overloadEpisodes,
  }) {
    final recommendations = <LoadRecommendation>[];
    
    // Check if frequently overloaded
    if (overloadEpisodes.length > 5) {
      recommendations.add(LoadRecommendation(
        type: RecommendationType.urgent,
        title: 'Frequent Cognitive Overload',
        description: 'You experience cognitive overload ${overloadEpisodes.length} times in this period',
        action: 'Reduce task complexity or increase break frequency',
        expectedImpact: 0.3,
      ));
    }
    
    // Check if underutilized
    if (stats.averageLoad < _optimalLoadMin) {
      recommendations.add(LoadRecommendation(
        type: RecommendationType.optimization,
        title: 'Cognitive Underutilization',
        description: 'Your average cognitive load is below optimal range',
        action: 'Increase task difficulty or combine related activities',
        expectedImpact: 0.2,
      ));
    }
    
    return recommendations;
  }

  Future<CognitiveLoadState> _getCurrentState(String userId) async {
    // Fetch current state from storage or calculate
    return CognitiveLoadState(
      userId: userId,
      currentLoad: 0.5,
      intrinsicLoad: 0.3,
      extraneousLoad: 0.1,
      germaneLoad: 0.1,
      timestamp: DateTime.now(),
    );
  }

  double _calculatePerformanceFactor(double performance) {
    // High performance suggests capacity for more challenge
    return performance > 0.8 ? 1.2 : performance > 0.6 ? 1.0 : 0.8;
  }

  double _calculateOptimalDifficulty({
    required double availableCapacity,
    required double performanceFactor,
    required String taskType,
  }) {
    // Base difficulty on available capacity
    double difficulty = availableCapacity * 0.7; // Leave some buffer
    
    // Adjust for performance
    difficulty *= performanceFactor;
    
    // Adjust for task type
    if (taskType == 'practice') {
      difficulty *= 0.9; // Slightly easier for practice
    } else if (taskType == 'assessment') {
      difficulty *= 1.1; // Slightly harder for assessment
    }
    
    return difficulty.clamp(0.3, 0.9);
  }

  Future<List<TaskSuggestion>> _generateDifficultyBasedTasks(
    String userId,
    String taskType,
    double targetDifficulty,
  ) async {
    // Generate task suggestions based on difficulty
    return [
      TaskSuggestion(
        title: 'Recommended Task',
        difficulty: targetDifficulty,
        estimatedTime: 20,
        concepts: ['concept1', 'concept2'],
      ),
    ];
  }

  String _explainDifficultyChoice(double difficulty, CognitiveLoadState state) {
    if (difficulty < 0.4) {
      return 'Starting with easier tasks due to current cognitive load';
    } else if (difficulty > 0.7) {
      return 'Challenging task selected based on low cognitive load and high performance';
    }
    return 'Moderate difficulty to maintain optimal cognitive engagement';
  }

  Map<String, double> _generateAlternatives(double optimal) {
    return {
      'easier': (optimal * 0.7).clamp(0.2, 0.8),
      'moderate': optimal,
      'harder': (optimal * 1.3).clamp(0.4, 0.95),
    };
  }

  double _calculateItemComplexity(List<ActiveItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.complexity) / items.length;
  }

  int _estimateChunks(List<ActiveItem> items) {
    // Group related items
    int chunks = 0;
    final processed = <ActiveItem>{};
    
    for (final item in items) {
      if (processed.contains(item)) continue;
      
      // Find related items
      final related = items.where((i) => 
        i != item && i.category == item.category
      ).toList();
      
      if (related.isNotEmpty && related.length <= 3) {
        // Can be chunked together
        chunks += 1;
        processed.add(item);
        processed.addAll(related);
      } else {
        // Individual chunk
        chunks += 1;
        processed.add(item);
      }
    }
    
    return chunks;
  }

  double _assessInterference(List<ActiveItem> items) {
    // Check for similar items that might interfere
    double interference = 0.0;
    
    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        if (items[i].similarity(items[j]) > 0.7) {
          interference += 0.1;
        }
      }
    }
    
    return interference.clamp(0.0, 1.0);
  }

  List<MemoryOptimization> _generateMemoryOptimizations({
    required List<ActiveItem> currentItems,
    required double utilization,
    required double interference,
  }) {
    final optimizations = <MemoryOptimization>[];
    
    if (utilization > 0.8) {
      optimizations.add(MemoryOptimization(
        type: 'reduce',
        description: 'Offload less critical items to external memory',
        items: currentItems.where((i) => i.priority < 0.5).toList(),
      ));
    }
    
    if (interference > 0.3) {
      optimizations.add(MemoryOptimization(
        type: 'reorganize',
        description: 'Separate similar items to reduce interference',
        items: currentItems.where((i) => i.hasHighSimilarity).toList(),
      ));
    }
    
    return optimizations;
  }

  double _calculateCurrentFatigue(
    CognitiveLoadState state,
    List<CognitiveLoadDataPoint> history,
  ) {
    // Base fatigue on sustained high load
    double fatigue = 0.0;
    
    // Recent high load
    if (state.currentLoad > 0.7) {
      fatigue += 0.2;
    }
    
    // Sustained load over time
    final recentHighLoad = history
        .where((h) => h.totalLoad > 0.7)
        .length;
    fatigue += recentHighLoad * 0.05;
    
    return fatigue.clamp(0.0, 1.0);
  }

  double _projectFatigue({
    required double current,
    required double cognitiveLoad,
    required int duration,
  }) {
    // Fatigue accumulation model
    final accumulation = cognitiveLoad * duration * 0.001;
    return (current + accumulation).clamp(0.0, 1.0);
  }

  double _calculatePerformanceImpact(double fatigue) {
    // Performance decreases with fatigue
    return 1.0 - (fatigue * 0.4);
  }

  List<int> _findOptimalBreakPoints(List<FatigueProjection> projections) {
    final breakPoints = <int>[];
    
    for (int i = 0; i < projections.length; i++) {
      if (projections[i].fatigueLevel > 0.6 && 
          (breakPoints.isEmpty || 
           projections[i].timeMinutes - breakPoints.last > 30)) {
        breakPoints.add(projections[i].timeMinutes);
      }
    }
    
    return breakPoints;
  }

  FatigueManagementPlan _generateFatigueManagementPlan({
    required List<FatigueProjection> projections,
    required List<int> breakPoints,
  }) {
    return FatigueManagementPlan(
      workPeriods: _generateWorkPeriods(breakPoints),
      breakDurations: _calculateBreakDurations(breakPoints),
      activities: _suggestRecoveryActivities(projections),
    );
  }

  int _findMaxProductiveDuration(List<FatigueProjection> projections) {
    // Find when performance drops below 70%
    for (final projection in projections) {
      if (projection.performanceImpact < 0.7) {
        return projection.timeMinutes;
      }
    }
    return projections.last.timeMinutes;
  }

  List<WorkPeriod> _generateWorkPeriods(List<int> breakPoints) {
    final periods = <WorkPeriod>[];
    int start = 0;
    
    for (final breakPoint in breakPoints) {
      periods.add(WorkPeriod(
        startMinute: start,
        endMinute: breakPoint,
        duration: breakPoint - start,
      ));
      start = breakPoint + 10; // Assume 10-minute break
    }
    
    return periods;
  }

  List<int> _calculateBreakDurations(List<int> breakPoints) {
    return breakPoints.map((point) {
      if (point < 60) return 5;
      if (point < 120) return 10;
      return 15;
    }).toList();
  }

  List<String> _suggestRecoveryActivities(List<FatigueProjection> projections) {
    final maxFatigue = projections.map((p) => p.fatigueLevel).reduce(math.max);
    
    if (maxFatigue > 0.8) {
      return ['Take a walk', 'Do light stretching', 'Practice deep breathing'];
    } else if (maxFatigue > 0.6) {
      return ['Close eyes for 2 minutes', 'Look at distant objects', 'Drink water'];
    }
    return ['Brief mental break', 'Change position'];
  }

  Map<PlannedActivity, double> _analyzeActivityDemands(List<PlannedActivity> activities) {
    final demands = <PlannedActivity, double>{};
    
    for (final activity in activities) {
      demands[activity] = _estimateActivityDemand(activity);
    }
    
    return demands;
  }

  double _estimateActivityDemand(PlannedActivity activity) {
    double demand = 0.5; // Base demand
    
    // Adjust for activity type
    switch (activity.type) {
      case 'problem_solving':
        demand += 0.2;
        break;
      case 'memorization':
        demand += 0.1;
        break;
      case 'review':
        demand -= 0.1;
        break;
    }
    
    // Adjust for complexity
    demand += activity.complexity * 0.3;
    
    return demand.clamp(0.1, 0.9);
  }

  Future<UserCapacityProfile> _getUserCapacityProfile(String userId) async {
    // Fetch user's cognitive capacity profile
    return UserCapacityProfile(
      peakHours: [9, 10, 11, 14, 15],
      averageCapacity: 0.7,
      recoveryRate: 0.02,
    );
  }

  List<PlannedActivity> _optimizeActivitySequence({
    required List<PlannedActivity> activities,
    required Map<PlannedActivity, double> demands,
    required UserCapacityProfile capacityProfile,
  }) {
    // Sort by cognitive demand and interleave
    final sorted = activities.toList()
      ..sort((a, b) => demands[a]!.compareTo(demands[b]!));
    
    // Interleave high and low demand activities
    final optimized = <PlannedActivity>[];
    final high = sorted.where((a) => demands[a]! > 0.6).toList();
    final low = sorted.where((a) => demands[a]! <= 0.6).toList();
    
    while (high.isNotEmpty || low.isNotEmpty) {
      if (high.isNotEmpty) {
        optimized.add(high.removeAt(0));
      }
      if (low.isNotEmpty) {
        optimized.add(low.removeAt(0));
      }
    }
    
    return optimized;
  }

  List<ScheduledBreak> _optimizeBreakSchedule({
    required List<PlannedActivity> sequence,
    required Duration timeframe,
  }) {
    final breaks = <ScheduledBreak>[];
    int currentTime = 0;
    
    for (int i = 0; i < sequence.length; i++) {
      currentTime += sequence[i].estimatedDuration;
      
      if (currentTime > 45 && i < sequence.length - 1) {
        breaks.add(ScheduledBreak(
          afterActivity: i,
          startTime: currentTime,
          duration: 10,
        ));
        currentTime += 10;
      }
    }
    
    return breaks;
  }

  OptimizationOutcomes _predictOptimizationOutcomes({
    required List<PlannedActivity> original,
    required List<PlannedActivity> optimized,
    required List<ScheduledBreak> breaks,
  }) {
    // Simulate outcomes
    return OptimizationOutcomes(
      originalEfficiency: 0.7,
      optimizedEfficiency: 0.85,
      improvementPercentage: 0.15,
      reducedOverloadRisk: 0.3,
    );
  }

  List<LoadLevel> _generateLoadProfile(List<PlannedActivity> sequence) {
    final profile = <LoadLevel>[];
    double currentLoad = 0.3;
    
    for (final activity in sequence) {
      currentLoad = (currentLoad + _estimateActivityDemand(activity)) / 2;
      profile.add(LoadLevel(
        activity: activity.name,
        load: currentLoad,
        duration: activity.estimatedDuration,
      ));
    }
    
    return profile;
  }

  List<String> _generateOptimizationTips(OptimizationOutcomes outcomes) {
    final tips = <String>[];
    
    if (outcomes.improvementPercentage > 0.1) {
      tips.add('This optimization can improve your efficiency by ${(outcomes.improvementPercentage * 100).round()}%');
    }
    
    if (outcomes.reducedOverloadRisk > 0.2) {
      tips.add('Cognitive overload risk reduced significantly');
    }
    
    tips.add('Remember to adjust based on your daily energy levels');
    
    return tips;
  }

  Future<void> _logOverloadEvent(String userId, CognitiveLoadState state) async {
    // Log to analytics
    safePrint('Logging cognitive overload event for user $userId');
  }

  Future<List<CognitiveLoadDataPoint>> _getRecentHistory(String userId) async {
    // Get last hour of data
    return [];
  }

  List<LoadPattern> _findTimeBasedPatterns(List<CognitiveLoadDataPoint> history) {
    // Analyze patterns by time of day
    return [];
  }

  List<LoadPattern> _findActivityPatterns(List<CognitiveLoadDataPoint> history) {
    // Analyze patterns by activity type
    return [];
  }

  List<LoadPattern> _findRecoveryPatterns(List<CognitiveLoadDataPoint> history) {
    // Analyze how load recovers after peaks
    return [];
  }

  String _categorizeRecoveryPatterns(List<double> rates) {
    if (rates.isEmpty) return 'unknown';
    
    final avg = rates.reduce((a, b) => a + b) / rates.length;
    
    if (avg > 0.05) return 'fast';
    if (avg > 0.02) return 'moderate';
    return 'slow';
  }
}

// Data models
class CognitiveLoadState {
  final String userId;
  final double currentLoad;
  final double intrinsicLoad;
  final double extraneousLoad;
  final double germaneLoad;
  final DateTime timestamp;
  final String? currentActivity;
  final double? subjectComplexity;
  final Map<String, double>? environmentFactors;

  CognitiveLoadState({
    required this.userId,
    required this.currentLoad,
    required this.intrinsicLoad,
    required this.extraneousLoad,
    required this.germaneLoad,
    required this.timestamp,
    this.currentActivity,
    this.subjectComplexity,
    this.environmentFactors,
  });

  double get totalLoad => intrinsicLoad + extraneousLoad + germaneLoad;
}

class ActivityContext {
  final String activityType;
  final double? subjectComplexity;
  final double? priorKnowledge;
  final int? conceptCount;
  final bool? hasDistractions;
  final bool? requiresMultitasking;
  final double? clarityScore;
  final bool? requiresIntegration;
  final bool? includesReflection;
  final double? noiseLevel;
  final double? interruptionFrequency;
  final double? comfortLevel;
  final double? lightingQuality;

  ActivityContext({
    required this.activityType,
    this.subjectComplexity,
    this.priorKnowledge,
    this.conceptCount,
    this.hasDistractions,
    this.requiresMultitasking,
    this.clarityScore,
    this.requiresIntegration,
    this.includesReflection,
    this.noiseLevel,
    this.interruptionFrequency,
    this.comfortLevel,
    this.lightingQuality,
  });
}

class CognitiveLoadAnalysis {
  final String userId;
  final DateTimeRange period;
  final double averageLoad;
  final double peakLoad;
  final double optimalLoadPercentage;
  final int overloadFrequency;
  final List<LoadPattern> patterns;
  final List<OverloadEpisode> overloadEpisodes;
  final RecoveryAnalysis recoveryAnalysis;
  final List<LoadRecommendation> recommendations;

  CognitiveLoadAnalysis({
    required this.userId,
    required this.period,
    required this.averageLoad,
    required this.peakLoad,
    required this.optimalLoadPercentage,
    required this.overloadFrequency,
    required this.patterns,
    required this.overloadEpisodes,
    required this.recoveryAnalysis,
    required this.recommendations,
  });
}

class LoadPattern {
  final String type;
  final String description;
  final double frequency;
  final double impact;

  LoadPattern({
    required this.type,
    required this.description,
    required this.frequency,
    required this.impact,
  });
}

class OverloadEpisode {
  final DateTime startTime;
  DateTime? endTime;
  double peakLoad;
  int duration;

  OverloadEpisode({
    required this.startTime,
    this.endTime,
    required this.peakLoad,
    required this.duration,
  });
}

class RecoveryAnalysis {
  final double averageRecoveryRate;
  final int optimalRestDuration;
  final String recoveryPatterns;

  RecoveryAnalysis({
    required this.averageRecoveryRate,
    required this.optimalRestDuration,
    required this.recoveryPatterns,
  });
}

class LoadRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final String action;
  final double expectedImpact;

  LoadRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.action,
    required this.expectedImpact,
  });
}

enum RecommendationType { urgent, optimization, maintenance }

class DifficultyRecommendation {
  final double recommendedDifficulty;
  final double currentCapacity;
  final String reasoning;
  final List<TaskSuggestion> suggestedTasks;
  final Map<String, double> alternativeDifficulties;

  DifficultyRecommendation({
    required this.recommendedDifficulty,
    required this.currentCapacity,
    required this.reasoning,
    required this.suggestedTasks,
    required this.alternativeDifficulties,
  });
}

class TaskSuggestion {
  final String title;
  final double difficulty;
  final int estimatedTime;
  final List<String> concepts;

  TaskSuggestion({
    required this.title,
    required this.difficulty,
    required this.estimatedTime,
    required this.concepts,
  });
}

class WorkingMemoryStatus {
  final int itemCount;
  final int chunksUsed;
  final double utilization;
  final double complexityScore;
  final double interferenceLevel;
  final bool isOverloaded;
  final List<MemoryOptimization> optimizations;

  WorkingMemoryStatus({
    required this.itemCount,
    required this.chunksUsed,
    required this.utilization,
    required this.complexityScore,
    required this.interferenceLevel,
    required this.isOverloaded,
    required this.optimizations,
  });
}

class ActiveItem {
  final String id;
  final String content;
  final String category;
  final double complexity;
  final double priority;
  final bool hasHighSimilarity;

  ActiveItem({
    required this.id,
    required this.content,
    required this.category,
    required this.complexity,
    required this.priority,
    required this.hasHighSimilarity,
  });

  double similarity(ActiveItem other) {
    if (category == other.category) return 0.8;
    return 0.2;
  }
}

class MemoryOptimization {
  final String type;
  final String description;
  final List<ActiveItem> items;

  MemoryOptimization({
    required this.type,
    required this.description,
    required this.items,
  });
}

class FatiguePrediction {
  final double currentFatigue;
  final List<FatigueProjection> projections;
  final List<int> optimalBreakPoints;
  final FatigueManagementPlan managementPlan;
  final int maxProductiveDuration;

  FatiguePrediction({
    required this.currentFatigue,
    required this.projections,
    required this.optimalBreakPoints,
    required this.managementPlan,
    required this.maxProductiveDuration,
  });
}

class FatigueProjection {
  final int timeMinutes;
  final double fatigueLevel;
  final double performanceImpact;

  FatigueProjection({
    required this.timeMinutes,
    required this.fatigueLevel,
    required this.performanceImpact,
  });
}

class FatigueManagementPlan {
  final List<WorkPeriod> workPeriods;
  final List<int> breakDurations;
  final List<String> activities;

  FatigueManagementPlan({
    required this.workPeriods,
    required this.breakDurations,
    required this.activities,
  });
}

class WorkPeriod {
  final int startMinute;
  final int endMinute;
  final int duration;

  WorkPeriod({
    required this.startMinute,
    required this.endMinute,
    required this.duration,
  });
}

class LoadOptimizationPlan {
  final List<PlannedActivity> originalSequence;
  final List<PlannedActivity> optimizedSequence;
  final List<ScheduledBreak> breakSchedule;
  final double expectedImprovement;
  final List<LoadLevel> cognitiveLoadProfile;
  final List<String> recommendations;

  LoadOptimizationPlan({
    required this.originalSequence,
    required this.optimizedSequence,
    required this.breakSchedule,
    required this.expectedImprovement,
    required this.cognitiveLoadProfile,
    required this.recommendations,
  });
}

class PlannedActivity {
  final String name;
  final String type;
  final double complexity;
  final int estimatedDuration;

  PlannedActivity({
    required this.name,
    required this.type,
    required this.complexity,
    required this.estimatedDuration,
  });
}

class ScheduledBreak {
  final int afterActivity;
  final int startTime;
  final int duration;

  ScheduledBreak({
    required this.afterActivity,
    required this.startTime,
    required this.duration,
  });
}

class LoadLevel {
  final String activity;
  final double load;
  final int duration;

  LoadLevel({
    required this.activity,
    required this.load,
    required this.duration,
  });
}

class CognitiveLoadDataPoint {
  final DateTime timestamp;
  final double totalLoad;
  final double intrinsicLoad;
  final double extraneousLoad;
  final double germaneLoad;
  final String? activity;

  CognitiveLoadDataPoint({
    required this.timestamp,
    required this.totalLoad,
    required this.intrinsicLoad,
    required this.extraneousLoad,
    required this.germaneLoad,
    this.activity,
  });
}

class LoadStatistics {
  final double averageLoad;
  final double peakLoad;
  final double optimalLoadPercentage;

  LoadStatistics({
    required this.averageLoad,
    required this.peakLoad,
    required this.optimalLoadPercentage,
  });
}

class UserCapacityProfile {
  final List<int> peakHours;
  final double averageCapacity;
  final double recoveryRate;

  UserCapacityProfile({
    required this.peakHours,
    required this.averageCapacity,
    required this.recoveryRate,
  });
}

class OptimizationOutcomes {
  final double originalEfficiency;
  final double optimizedEfficiency;
  final double improvementPercentage;
  final double reducedOverloadRisk;

  OptimizationOutcomes({
    required this.originalEfficiency,
    required this.optimizedEfficiency,
    required this.improvementPercentage,
    required this.reducedOverloadRisk,
  });
}