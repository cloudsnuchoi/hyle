import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for behavioral nudges and interventions
class BehavioralNudgeEngine {
  static final BehavioralNudgeEngine _instance = BehavioralNudgeEngine._internal();
  factory BehavioralNudgeEngine() => _instance;
  BehavioralNudgeEngine._internal();

  // Nudge system state
  final Map<String, UserNudgeProfile> _userProfiles = {};
  final Map<String, List<ActiveNudge>> _activeNudges = {};
  final Map<String, StreamController<NudgeEvent>> _nudgeStreams = {};
  
  // Behavioral models
  final Map<String, BehaviorModel> _behaviorModels = {};
  final Map<String, InterventionHistory> _interventionHistory = {};
  
  // Nudge effectiveness tracking
  final Map<String, NudgeEffectiveness> _effectivenessData = {};

  /// Initialize nudge engine
  Future<void> initialize() async {
    try {
      // Load behavioral science principles
      await _loadBehavioralPrinciples();
      
      // Initialize user models
      await _initializeUserModels();
      
      // Set up nudge triggers
      await _setupNudgeTriggers();
      
      safePrint('Behavioral nudge engine initialized');
    } catch (e) {
      safePrint('Error initializing nudge engine: $e');
    }
  }

  /// Create personalized nudge
  Future<NudgeResult> createPersonalizedNudge({
    required String userId,
    required NudgeContext context,
    NudgeType? preferredType,
  }) async {
    try {
      // Get user profile
      final profile = await _getUserNudgeProfile(userId);
      
      // Analyze current behavior
      final behaviorAnalysis = await _analyzeBehavior(userId, context);
      
      // Identify nudge opportunity
      final opportunity = _identifyNudgeOpportunity(
        profile: profile,
        behavior: behaviorAnalysis,
        context: context,
      );
      
      if (opportunity == null) {
        return NudgeResult(
          created: false,
          reason: 'No appropriate nudge opportunity identified',
        );
      }
      
      // Select nudge type
      final nudgeType = preferredType ?? _selectOptimalNudgeType(
        opportunity: opportunity,
        profile: profile,
        context: context,
      );
      
      // Generate nudge content
      final content = await _generateNudgeContent(
        type: nudgeType,
        opportunity: opportunity,
        profile: profile,
        context: context,
      );
      
      // Apply behavioral principles
      final enhancedContent = _applyBehavioralPrinciples(
        content: content,
        principles: opportunity.applicablePrinciples,
        profile: profile,
      );
      
      // Create nudge
      final nudge = ActiveNudge(
        id: _generateNudgeId(),
        userId: userId,
        type: nudgeType,
        content: enhancedContent,
        context: context,
        opportunity: opportunity,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(opportunity.validityDuration),
      );
      
      // Activate nudge
      await _activateNudge(nudge);
      
      return NudgeResult(
        created: true,
        nudge: nudge,
        expectedImpact: opportunity.expectedImpact,
      );
    } catch (e) {
      safePrint('Error creating personalized nudge: $e');
      return NudgeResult(
        created: false,
        reason: 'Error: $e',
      );
    }
  }

  /// Trigger contextual nudge
  Future<void> triggerContextualNudge({
    required String userId,
    required TriggerEvent event,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if nudge is appropriate
      if (!await _shouldTriggerNudge(userId, event)) {
        return;
      }
      
      // Create context from event
      final context = NudgeContext(
        trigger: event,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );
      
      // Generate appropriate nudge
      final result = await createPersonalizedNudge(
        userId: userId,
        context: context,
      );
      
      if (result.created && result.nudge != null) {
        // Track trigger
        await _trackNudgeTrigger(
          userId: userId,
          nudge: result.nudge!,
          event: event,
        );
      }
    } catch (e) {
      safePrint('Error triggering contextual nudge: $e');
    }
  }

  /// Get active nudges for user
  Future<List<ActiveNudge>> getActiveNudges(String userId) async {
    final nudges = _activeNudges[userId] ?? [];
    
    // Filter out expired nudges
    final now = DateTime.now();
    final activeNudges = nudges.where((n) => n.expiresAt.isAfter(now)).toList();
    
    // Update cache
    _activeNudges[userId] = activeNudges;
    
    return activeNudges;
  }

  /// Record nudge response
  Future<void> recordNudgeResponse({
    required String nudgeId,
    required NudgeResponse response,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Find nudge
      final nudge = await _findNudge(nudgeId);
      if (nudge == null) return;
      
      // Record response
      nudge.response = response;
      nudge.respondedAt = DateTime.now();
      nudge.responseMetadata = metadata;
      
      // Update effectiveness data
      await _updateEffectivenessData(
        nudge: nudge,
        response: response,
      );
      
      // Update user model
      await _updateUserModel(
        userId: nudge.userId,
        nudge: nudge,
        response: response,
      );
      
      // Emit event
      _nudgeStreams[nudge.userId]?.add(NudgeEvent(
        type: NudgeEventType.responded,
        nudgeId: nudgeId,
        response: response,
        timestamp: DateTime.now(),
      ));
      
      // Handle follow-up actions
      await _handleNudgeResponse(nudge, response);
    } catch (e) {
      safePrint('Error recording nudge response: $e');
    }
  }

  /// Analyze nudge effectiveness
  Future<NudgeEffectivenessReport> analyzeEffectiveness({
    required String userId,
    DateTimeRange? period,
    NudgeType? type,
  }) async {
    try {
      // Get intervention history
      final history = _interventionHistory[userId] ?? InterventionHistory();
      
      // Filter by period and type
      final relevantNudges = history.getNudges(period, type);
      
      // Calculate metrics
      final responseRate = _calculateResponseRate(relevantNudges);
      final positiveResponseRate = _calculatePositiveResponseRate(relevantNudges);
      final behaviorChangeRate = await _calculateBehaviorChangeRate(
        userId: userId,
        nudges: relevantNudges,
      );
      
      // Analyze by type
      final typeAnalysis = _analyzeByNudgeType(relevantNudges);
      
      // Analyze by principle
      final principleAnalysis = _analyzeByPrinciple(relevantNudges);
      
      // Analyze timing effectiveness
      final timingAnalysis = _analyzeTimingEffectiveness(relevantNudges);
      
      // Generate insights
      final insights = _generateEffectivenessInsights(
        responseRate: responseRate,
        positiveResponseRate: positiveResponseRate,
        behaviorChangeRate: behaviorChangeRate,
        typeAnalysis: typeAnalysis,
        principleAnalysis: principleAnalysis,
      );
      
      // Generate recommendations
      final recommendations = _generateNudgeRecommendations(
        userId: userId,
        analysis: typeAnalysis,
        insights: insights,
      );
      
      return NudgeEffectivenessReport(
        userId: userId,
        period: period ?? DateTimeRange(
          start: relevantNudges.first.createdAt,
          end: relevantNudges.last.createdAt,
        ),
        totalNudges: relevantNudges.length,
        responseRate: responseRate,
        positiveResponseRate: positiveResponseRate,
        behaviorChangeRate: behaviorChangeRate,
        typeAnalysis: typeAnalysis,
        principleAnalysis: principleAnalysis,
        timingAnalysis: timingAnalysis,
        insights: insights,
        recommendations: recommendations,
      );
    } catch (e) {
      safePrint('Error analyzing nudge effectiveness: $e');
      rethrow;
    }
  }

  /// Create habit formation nudge sequence
  Future<HabitFormationPlan> createHabitFormationPlan({
    required String userId,
    required String targetHabit,
    required HabitParameters parameters,
  }) async {
    try {
      // Analyze current habits
      final currentHabits = await _analyzeCurrentHabits(userId);
      
      // Design habit loop
      final habitLoop = _designHabitLoop(
        targetHabit: targetHabit,
        parameters: parameters,
        existingHabits: currentHabits,
      );
      
      // Create nudge sequence
      final nudgeSequence = _createHabitNudgeSequence(
        habitLoop: habitLoop,
        parameters: parameters,
      );
      
      // Define milestones
      final milestones = _defineHabitMilestones(
        targetHabit: targetHabit,
        parameters: parameters,
      );
      
      // Create reinforcement schedule
      final reinforcementSchedule = _createReinforcementSchedule(
        habitLoop: habitLoop,
        milestones: milestones,
      );
      
      // Generate implementation plan
      final plan = HabitFormationPlan(
        userId: userId,
        targetHabit: targetHabit,
        habitLoop: habitLoop,
        nudgeSequence: nudgeSequence,
        milestones: milestones,
        reinforcementSchedule: reinforcementSchedule,
        estimatedDuration: _estimateHabitFormationDuration(parameters),
        createdAt: DateTime.now(),
      );
      
      // Activate plan
      await _activateHabitPlan(plan);
      
      return plan;
    } catch (e) {
      safePrint('Error creating habit formation plan: $e');
      rethrow;
    }
  }

  /// Get nudge recommendations
  Future<List<NudgeRecommendation>> getNudgeRecommendations({
    required String userId,
    required RecommendationContext context,
  }) async {
    try {
      // Get user profile and history
      final profile = await _getUserNudgeProfile(userId);
      final history = _interventionHistory[userId] ?? InterventionHistory();
      
      // Analyze current state
      final currentState = await _analyzeCurrentState(userId);
      
      // Identify opportunities
      final opportunities = _identifyNudgeOpportunities(
        profile: profile,
        state: currentState,
        context: context,
      );
      
      // Generate recommendations
      final recommendations = <NudgeRecommendation>[];
      
      for (final opportunity in opportunities) {
        // Check if nudge would be effective
        final effectiveness = await _predictNudgeEffectiveness(
          userId: userId,
          opportunity: opportunity,
          history: history,
        );
        
        if (effectiveness.probability > 0.6) {
          recommendations.add(NudgeRecommendation(
            opportunity: opportunity,
            recommendedType: _selectOptimalNudgeType(
              opportunity: opportunity,
              profile: profile,
              context: NudgeContext(
                trigger: TriggerEvent.manual,
                timestamp: DateTime.now(),
              ),
            ),
            timing: _recommendTiming(opportunity, profile),
            expectedEffectiveness: effectiveness,
            priority: _calculatePriority(opportunity, effectiveness),
            rationale: _generateRationale(opportunity, effectiveness),
          ));
        }
      }
      
      // Sort by priority
      recommendations.sort((a, b) => b.priority.compareTo(a.priority));
      
      return recommendations.take(5).toList(); // Top 5 recommendations
    } catch (e) {
      safePrint('Error getting nudge recommendations: $e');
      return [];
    }
  }

  /// Monitor behavior change
  Stream<BehaviorChangeUpdate> monitorBehaviorChange(String userId) {
    final controller = StreamController<BehaviorChangeUpdate>.broadcast();
    
    // Set up periodic monitoring
    Timer.periodic(const Duration(hours: 1), (timer) async {
      try {
        // Get current behavior metrics
        final metrics = await _getCurrentBehaviorMetrics(userId);
        
        // Compare with baseline
        final baseline = await _getBaselineBehavior(userId);
        
        // Calculate changes
        final changes = _calculateBehaviorChanges(metrics, baseline);
        
        // Identify significant changes
        final significantChanges = _identifySignificantChanges(changes);
        
        // Generate update
        if (significantChanges.isNotEmpty) {
          controller.add(BehaviorChangeUpdate(
            userId: userId,
            changes: significantChanges,
            metrics: metrics,
            timestamp: DateTime.now(),
            recommendations: _generateChangeRecommendations(significantChanges),
          ));
        }
      } catch (e) {
        safePrint('Error monitoring behavior change: $e');
      }
    });
    
    return controller.stream;
  }

  /// Apply gamification nudge
  Future<GamificationNudge> applyGamificationNudge({
    required String userId,
    required String achievementId,
    required GamificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get user's gamification profile
      final profile = await _getGamificationProfile(userId);
      
      // Design gamification element
      final element = _designGamificationElement(
        type: type,
        achievementId: achievementId,
        profile: profile,
        metadata: metadata,
      );
      
      // Create visual representation
      final visual = _createGamificationVisual(element);
      
      // Calculate rewards
      final rewards = _calculateGamificationRewards(
        element: element,
        profile: profile,
      );
      
      // Create nudge
      final nudge = GamificationNudge(
        element: element,
        visual: visual,
        rewards: rewards,
        triggerConditions: _defineGamificationTriggers(element),
        expirationRules: _defineExpirationRules(element),
      );
      
      // Activate gamification
      await _activateGamification(userId, nudge);
      
      return nudge;
    } catch (e) {
      safePrint('Error applying gamification nudge: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _loadBehavioralPrinciples() async {
    // Load behavioral science principles
  }

  Future<void> _initializeUserModels() async {
    // Initialize user behavior models
  }

  Future<void> _setupNudgeTriggers() async {
    // Set up automatic nudge triggers
  }

  Future<UserNudgeProfile> _getUserNudgeProfile(String userId) async {
    if (_userProfiles.containsKey(userId)) {
      return _userProfiles[userId]!;
    }
    
    // Create new profile
    final profile = UserNudgeProfile(
      userId: userId,
      preferences: NudgePreferences.defaults(),
      responseHistory: [],
      effectiveTypes: [],
      ineffectiveTypes: [],
    );
    
    _userProfiles[userId] = profile;
    return profile;
  }

  Future<BehaviorAnalysis> _analyzeBehavior(
    String userId,
    NudgeContext context,
  ) async {
    // Analyze current user behavior
    return BehaviorAnalysis(
      currentState: BehaviorState.active,
      patterns: [],
      triggers: [],
      barriers: [],
    );
  }

  NudgeOpportunity? _identifyNudgeOpportunity({
    required UserNudgeProfile profile,
    required BehaviorAnalysis behavior,
    required NudgeContext context,
  }) {
    // Identify if there's a good nudge opportunity
    if (behavior.currentState == BehaviorState.inactive) {
      return NudgeOpportunity(
        type: OpportunityType.reengagement,
        behavior: '학습 재개',
        applicablePrinciples: [
          BehavioralPrinciple.lossAversion,
          BehavioralPrinciple.socialProof,
        ],
        expectedImpact: 0.7,
        validityDuration: const Duration(hours: 24),
      );
    }
    
    return null;
  }

  NudgeType _selectOptimalNudgeType({
    required NudgeOpportunity opportunity,
    required UserNudgeProfile profile,
    required NudgeContext context,
  }) {
    // Select best nudge type based on opportunity and profile
    if (opportunity.type == OpportunityType.reengagement) {
      return NudgeType.motivational;
    }
    
    return NudgeType.reminder;
  }

  Future<NudgeContent> _generateNudgeContent({
    required NudgeType type,
    required NudgeOpportunity opportunity,
    required UserNudgeProfile profile,
    required NudgeContext context,
  }) async {
    // Generate personalized nudge content
    switch (type) {
      case NudgeType.motivational:
        return NudgeContent(
          title: '다시 시작해볼까요? 💪',
          message: '짧은 학습 세션으로 시작해보세요. 5분만 투자해도 큰 차이를 만들 수 있어요!',
          action: '학습 시작하기',
          visual: '🎯',
        );
        
      case NudgeType.reminder:
        return NudgeContent(
          title: '학습 시간이에요 📚',
          message: '오늘의 목표를 달성하기 위해 지금 시작하세요.',
          action: '바로 시작',
          visual: '⏰',
        );
        
      default:
        return NudgeContent(
          title: '알림',
          message: context.metadata['message'] ?? '',
          action: '확인',
        );
    }
  }

  NudgeContent _applyBehavioralPrinciples({
    required NudgeContent content,
    required List<BehavioralPrinciple> principles,
    required UserNudgeProfile profile,
  }) {
    var enhancedContent = content;
    
    for (final principle in principles) {
      switch (principle) {
        case BehavioralPrinciple.lossAversion:
          enhancedContent = NudgeContent(
            title: enhancedContent.title,
            message: '${enhancedContent.message}\n연속 학습 ${profile.currentStreak}일을 잃지 마세요!',
            action: enhancedContent.action,
            visual: enhancedContent.visual,
          );
          break;
          
        case BehavioralPrinciple.socialProof:
          enhancedContent = NudgeContent(
            title: enhancedContent.title,
            message: '${enhancedContent.message}\n다른 학습자들도 지금 공부하고 있어요.',
            action: enhancedContent.action,
            visual: enhancedContent.visual,
          );
          break;
          
        default:
          break;
      }
    }
    
    return enhancedContent;
  }

  String _generateNudgeId() {
    return 'nudge_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  Future<void> _activateNudge(ActiveNudge nudge) async {
    // Add to active nudges
    _activeNudges[nudge.userId] ??= [];
    _activeNudges[nudge.userId]!.add(nudge);
    
    // Store in history
    _interventionHistory[nudge.userId] ??= InterventionHistory();
    _interventionHistory[nudge.userId]!.addNudge(nudge);
    
    // Emit event
    _nudgeStreams[nudge.userId]?.add(NudgeEvent(
      type: NudgeEventType.created,
      nudgeId: nudge.id,
      timestamp: DateTime.now(),
    ));
  }

  Future<bool> _shouldTriggerNudge(String userId, TriggerEvent event) async {
    // Check if nudge should be triggered
    final profile = await _getUserNudgeProfile(userId);
    
    // Check nudge fatigue
    final recentNudges = await _getRecentNudgeCount(userId);
    if (recentNudges > profile.preferences.maxNudgesPerDay) {
      return false;
    }
    
    // Check event relevance
    if (!profile.preferences.enabledTriggers.contains(event)) {
      return false;
    }
    
    return true;
  }

  Future<void> _trackNudgeTrigger({
    required String userId,
    required ActiveNudge nudge,
    required TriggerEvent event,
  }) async {
    // Track nudge trigger for analytics
  }

  Future<ActiveNudge?> _findNudge(String nudgeId) async {
    for (final userNudges in _activeNudges.values) {
      final nudge = userNudges.firstWhere(
        (n) => n.id == nudgeId,
        orElse: () => ActiveNudge.empty(),
      );
      if (nudge.id.isNotEmpty) return nudge;
    }
    return null;
  }

  Future<void> _updateEffectivenessData({
    required ActiveNudge nudge,
    required NudgeResponse response,
  }) async {
    // Update effectiveness tracking
    final key = '${nudge.type}_${nudge.opportunity.type}';
    _effectivenessData[key] ??= NudgeEffectiveness();
    _effectivenessData[key]!.recordResponse(response);
  }

  Future<void> _updateUserModel({
    required String userId,
    required ActiveNudge nudge,
    required NudgeResponse response,
  }) async {
    // Update user behavior model
    _behaviorModels[userId] ??= BehaviorModel();
    _behaviorModels[userId]!.updateWithNudgeResponse(nudge, response);
  }

  Future<void> _handleNudgeResponse(
    ActiveNudge nudge,
    NudgeResponse response,
  ) async {
    // Handle different response types
    switch (response) {
      case NudgeResponse.accepted:
        // Track positive engagement
        break;
      case NudgeResponse.dismissed:
        // Adjust future nudge timing/frequency
        break;
      case NudgeResponse.snoozed:
        // Reschedule nudge
        break;
      case NudgeResponse.ignored:
        // Reduce nudge frequency
        break;
    }
  }

  Future<int> _getRecentNudgeCount(String userId) async {
    final nudges = _activeNudges[userId] ?? [];
    final recentCutoff = DateTime.now().subtract(const Duration(hours: 24));
    return nudges.where((n) => n.createdAt.isAfter(recentCutoff)).length;
  }

  // Analysis helper methods
  double _calculateResponseRate(List<ActiveNudge> nudges) {
    if (nudges.isEmpty) return 0.0;
    final responded = nudges.where((n) => n.response != null).length;
    return responded / nudges.length;
  }

  double _calculatePositiveResponseRate(List<ActiveNudge> nudges) {
    if (nudges.isEmpty) return 0.0;
    final positive = nudges.where((n) => 
      n.response == NudgeResponse.accepted
    ).length;
    return positive / nudges.length;
  }

  Future<double> _calculateBehaviorChangeRate({
    required String userId,
    required List<ActiveNudge> nudges,
  }) async {
    // Calculate actual behavior change rate
    return 0.65; // Placeholder
  }

  Map<NudgeType, TypeAnalysis> _analyzeByNudgeType(List<ActiveNudge> nudges) {
    final analysis = <NudgeType, TypeAnalysis>{};
    
    for (final type in NudgeType.values) {
      final typeNudges = nudges.where((n) => n.type == type).toList();
      if (typeNudges.isNotEmpty) {
        analysis[type] = TypeAnalysis(
          count: typeNudges.length,
          responseRate: _calculateResponseRate(typeNudges),
          positiveRate: _calculatePositiveResponseRate(typeNudges),
        );
      }
    }
    
    return analysis;
  }

  Map<BehavioralPrinciple, PrincipleAnalysis> _analyzeByPrinciple(
    List<ActiveNudge> nudges,
  ) {
    // Analyze effectiveness by behavioral principle
    return {};
  }

  TimingAnalysis _analyzeTimingEffectiveness(List<ActiveNudge> nudges) {
    // Analyze when nudges are most effective
    return TimingAnalysis();
  }

  List<String> _generateEffectivenessInsights({
    required double responseRate,
    required double positiveResponseRate,
    required double behaviorChangeRate,
    required Map<NudgeType, TypeAnalysis> typeAnalysis,
    required Map<BehavioralPrinciple, PrincipleAnalysis> principleAnalysis,
  }) {
    final insights = <String>[];
    
    if (responseRate > 0.7) {
      insights.add('넛지에 대한 반응률이 매우 높습니다');
    }
    
    if (behaviorChangeRate > 0.5) {
      insights.add('넛지가 실제 행동 변화로 잘 이어지고 있습니다');
    }
    
    // Find most effective type
    final bestType = typeAnalysis.entries
        .reduce((a, b) => a.value.positiveRate > b.value.positiveRate ? a : b);
    insights.add('${bestType.key} 유형의 넛지가 가장 효과적입니다');
    
    return insights;
  }

  List<String> _generateNudgeRecommendations({
    required String userId,
    required Map<NudgeType, TypeAnalysis> analysis,
    required List<String> insights,
  }) {
    // Generate recommendations based on analysis
    return [
      '동기부여 넛지의 빈도를 높이세요',
      '오전 시간대에 넛지를 집중하세요',
      '게임화 요소를 더 활용해보세요',
    ];
  }

  // Habit formation methods
  Future<List<Habit>> _analyzeCurrentHabits(String userId) async {
    // Analyze user's current habits
    return [];
  }

  HabitLoop _designHabitLoop({
    required String targetHabit,
    required HabitParameters parameters,
    required List<Habit> existingHabits,
  }) {
    // Design habit loop (cue, routine, reward)
    return HabitLoop(
      cue: '매일 같은 시간에 알림',
      routine: targetHabit,
      reward: '진도 시각화 및 성취감',
      context: '학습 환경 준비',
    );
  }

  List<ScheduledNudge> _createHabitNudgeSequence({
    required HabitLoop habitLoop,
    required HabitParameters parameters,
  }) {
    // Create sequence of nudges for habit formation
    final sequence = <ScheduledNudge>[];
    
    // Initial phase - frequent reminders
    for (int i = 0; i < 7; i++) {
      sequence.add(ScheduledNudge(
        day: i + 1,
        type: NudgeType.reminder,
        content: '습관 형성 ${i + 1}일차: ${habitLoop.routine}',
        timing: parameters.preferredTime,
      ));
    }
    
    // Reinforcement phase - less frequent
    for (int i = 7; i < 21; i += 2) {
      sequence.add(ScheduledNudge(
        day: i + 1,
        type: NudgeType.motivational,
        content: '잘하고 있어요! 계속해보세요.',
        timing: parameters.preferredTime,
      ));
    }
    
    return sequence;
  }

  List<HabitMilestone> _defineHabitMilestones({
    required String targetHabit,
    required HabitParameters parameters,
  }) {
    return [
      HabitMilestone(days: 3, name: '첫 3일 달성', reward: '뱃지 획득'),
      HabitMilestone(days: 7, name: '일주일 연속', reward: '특별 보상'),
      HabitMilestone(days: 21, name: '습관 형성', reward: '마스터 뱃지'),
      HabitMilestone(days: 66, name: '습관 정착', reward: '영구 업적'),
    ];
  }

  ReinforcementSchedule _createReinforcementSchedule({
    required HabitLoop habitLoop,
    required List<HabitMilestone> milestones,
  }) {
    return ReinforcementSchedule(
      immediate: '완료 즉시 시각적 피드백',
      daily: '일일 진도 요약',
      weekly: '주간 성과 리포트',
      milestoneRewards: milestones.map((m) => m.reward).toList(),
    );
  }

  Duration _estimateHabitFormationDuration(HabitParameters parameters) {
    // Research suggests 66 days on average for habit formation
    return const Duration(days: 66);
  }

  Future<void> _activateHabitPlan(HabitFormationPlan plan) async {
    // Activate the habit formation plan
  }

  // Additional helper method stubs...
  Future<UserState> _analyzeCurrentState(String userId) async => UserState();
  
  List<NudgeOpportunity> _identifyNudgeOpportunities({
    required UserNudgeProfile profile,
    required UserState state,
    required RecommendationContext context,
  }) => [];
  
  Future<EffectivenessPrediction> _predictNudgeEffectiveness({
    required String userId,
    required NudgeOpportunity opportunity,
    required InterventionHistory history,
  }) async => EffectivenessPrediction(probability: 0.75);
  
  DateTime _recommendTiming(
    NudgeOpportunity opportunity,
    UserNudgeProfile profile,
  ) => DateTime.now().add(const Duration(hours: 2));
  
  double _calculatePriority(
    NudgeOpportunity opportunity,
    EffectivenessPrediction effectiveness,
  ) => opportunity.expectedImpact * effectiveness.probability;
  
  String _generateRationale(
    NudgeOpportunity opportunity,
    EffectivenessPrediction effectiveness,
  ) => '이 넛지는 ${(effectiveness.probability * 100).toStringAsFixed(0)}% 확률로 효과적일 것으로 예상됩니다';
  
  Future<BehaviorMetrics> _getCurrentBehaviorMetrics(String userId) async =>
      BehaviorMetrics();
  
  Future<BehaviorMetrics> _getBaselineBehavior(String userId) async =>
      BehaviorMetrics();
  
  List<BehaviorChange> _calculateBehaviorChanges(
    BehaviorMetrics current,
    BehaviorMetrics baseline,
  ) => [];
  
  List<BehaviorChange> _identifySignificantChanges(
    List<BehaviorChange> changes,
  ) => changes.where((c) => c.magnitude > 0.2).toList();
  
  List<String> _generateChangeRecommendations(
    List<BehaviorChange> changes,
  ) => [];
  
  Future<GamificationProfile> _getGamificationProfile(String userId) async =>
      GamificationProfile();
  
  GamificationElement _designGamificationElement({
    required GamificationType type,
    required String achievementId,
    required GamificationProfile profile,
    Map<String, dynamic>? metadata,
  }) => GamificationElement(type: type, id: achievementId);
  
  GamificationVisual _createGamificationVisual(GamificationElement element) =>
      GamificationVisual();
  
  List<Reward> _calculateGamificationRewards({
    required GamificationElement element,
    required GamificationProfile profile,
  }) => [];
  
  List<TriggerCondition> _defineGamificationTriggers(
    GamificationElement element,
  ) => [];
  
  ExpirationRules _defineExpirationRules(GamificationElement element) =>
      ExpirationRules();
  
  Future<void> _activateGamification(
    String userId,
    GamificationNudge nudge,
  ) async {}
}

// Data models
class ActiveNudge {
  final String id;
  final String userId;
  final NudgeType type;
  final NudgeContent content;
  final NudgeContext context;
  final NudgeOpportunity opportunity;
  final DateTime createdAt;
  final DateTime expiresAt;
  NudgeResponse? response;
  DateTime? respondedAt;
  Map<String, dynamic>? responseMetadata;

  ActiveNudge({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    required this.context,
    required this.opportunity,
    required this.createdAt,
    required this.expiresAt,
    this.response,
    this.respondedAt,
    this.responseMetadata,
  });

  factory ActiveNudge.empty() => ActiveNudge(
    id: '',
    userId: '',
    type: NudgeType.reminder,
    content: NudgeContent(title: '', message: '', action: ''),
    context: NudgeContext(
      trigger: TriggerEvent.manual,
      timestamp: DateTime.now(),
    ),
    opportunity: NudgeOpportunity(
      type: OpportunityType.general,
      behavior: '',
      applicablePrinciples: [],
      expectedImpact: 0,
      validityDuration: Duration.zero,
    ),
    createdAt: DateTime.now(),
    expiresAt: DateTime.now(),
  );
}

class UserNudgeProfile {
  final String userId;
  final NudgePreferences preferences;
  final List<NudgeResponse> responseHistory;
  final List<NudgeType> effectiveTypes;
  final List<NudgeType> ineffectiveTypes;
  int currentStreak;

  UserNudgeProfile({
    required this.userId,
    required this.preferences,
    required this.responseHistory,
    required this.effectiveTypes,
    required this.ineffectiveTypes,
    this.currentStreak = 0,
  });
}

class NudgeContext {
  final TriggerEvent trigger;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  NudgeContext({
    required this.trigger,
    required this.timestamp,
    this.metadata = const {},
  });
}

class NudgeOpportunity {
  final OpportunityType type;
  final String behavior;
  final List<BehavioralPrinciple> applicablePrinciples;
  final double expectedImpact;
  final Duration validityDuration;

  NudgeOpportunity({
    required this.type,
    required this.behavior,
    required this.applicablePrinciples,
    required this.expectedImpact,
    required this.validityDuration,
  });
}

class NudgeContent {
  final String title;
  final String message;
  final String action;
  final String? visual;
  final Map<String, dynamic>? customData;

  NudgeContent({
    required this.title,
    required this.message,
    required this.action,
    this.visual,
    this.customData,
  });
}

class NudgeResult {
  final bool created;
  final ActiveNudge? nudge;
  final double? expectedImpact;
  final String? reason;

  NudgeResult({
    required this.created,
    this.nudge,
    this.expectedImpact,
    this.reason,
  });
}

class NudgeEvent {
  final NudgeEventType type;
  final String nudgeId;
  final DateTime timestamp;
  final NudgeResponse? response;

  NudgeEvent({
    required this.type,
    required this.nudgeId,
    required this.timestamp,
    this.response,
  });
}

class NudgeEffectivenessReport {
  final String userId;
  final DateTimeRange period;
  final int totalNudges;
  final double responseRate;
  final double positiveResponseRate;
  final double behaviorChangeRate;
  final Map<NudgeType, TypeAnalysis> typeAnalysis;
  final Map<BehavioralPrinciple, PrincipleAnalysis> principleAnalysis;
  final TimingAnalysis timingAnalysis;
  final List<String> insights;
  final List<String> recommendations;

  NudgeEffectivenessReport({
    required this.userId,
    required this.period,
    required this.totalNudges,
    required this.responseRate,
    required this.positiveResponseRate,
    required this.behaviorChangeRate,
    required this.typeAnalysis,
    required this.principleAnalysis,
    required this.timingAnalysis,
    required this.insights,
    required this.recommendations,
  });
}

class HabitFormationPlan {
  final String userId;
  final String targetHabit;
  final HabitLoop habitLoop;
  final List<ScheduledNudge> nudgeSequence;
  final List<HabitMilestone> milestones;
  final ReinforcementSchedule reinforcementSchedule;
  final Duration estimatedDuration;
  final DateTime createdAt;

  HabitFormationPlan({
    required this.userId,
    required this.targetHabit,
    required this.habitLoop,
    required this.nudgeSequence,
    required this.milestones,
    required this.reinforcementSchedule,
    required this.estimatedDuration,
    required this.createdAt,
  });
}

class NudgeRecommendation {
  final NudgeOpportunity opportunity;
  final NudgeType recommendedType;
  final DateTime timing;
  final EffectivenessPrediction expectedEffectiveness;
  final double priority;
  final String rationale;

  NudgeRecommendation({
    required this.opportunity,
    required this.recommendedType,
    required this.timing,
    required this.expectedEffectiveness,
    required this.priority,
    required this.rationale,
  });
}

class BehaviorChangeUpdate {
  final String userId;
  final List<BehaviorChange> changes;
  final BehaviorMetrics metrics;
  final DateTime timestamp;
  final List<String> recommendations;

  BehaviorChangeUpdate({
    required this.userId,
    required this.changes,
    required this.metrics,
    required this.timestamp,
    required this.recommendations,
  });
}

class GamificationNudge {
  final GamificationElement element;
  final GamificationVisual visual;
  final List<Reward> rewards;
  final List<TriggerCondition> triggerConditions;
  final ExpirationRules expirationRules;

  GamificationNudge({
    required this.element,
    required this.visual,
    required this.rewards,
    required this.triggerConditions,
    required this.expirationRules,
  });
}

class NudgePreferences {
  final List<NudgeType> enabledTypes;
  final List<TriggerEvent> enabledTriggers;
  final int maxNudgesPerDay;
  final Map<NudgeType, NudgeTypePreference> typePreferences;

  NudgePreferences({
    required this.enabledTypes,
    required this.enabledTriggers,
    required this.maxNudgesPerDay,
    required this.typePreferences,
  });

  factory NudgePreferences.defaults() => NudgePreferences(
    enabledTypes: NudgeType.values,
    enabledTriggers: TriggerEvent.values,
    maxNudgesPerDay: 5,
    typePreferences: {},
  );
}

class BehaviorModel {
  void updateWithNudgeResponse(ActiveNudge nudge, NudgeResponse response) {
    // Update model with response data
  }
}

class InterventionHistory {
  final List<ActiveNudge> nudges = [];

  void addNudge(ActiveNudge nudge) => nudges.add(nudge);

  List<ActiveNudge> getNudges(DateTimeRange? period, NudgeType? type) {
    return nudges.where((nudge) {
      final inPeriod = period == null || 
          (nudge.createdAt.isAfter(period.start) && 
           nudge.createdAt.isBefore(period.end));
      final matchesType = type == null || nudge.type == type;
      return inPeriod && matchesType;
    }).toList();
  }
}

class NudgeEffectiveness {
  int totalCount = 0;
  int responseCount = 0;
  int positiveCount = 0;

  void recordResponse(NudgeResponse response) {
    totalCount++;
    if (response != NudgeResponse.ignored) {
      responseCount++;
    }
    if (response == NudgeResponse.accepted) {
      positiveCount++;
    }
  }

  double get responseRate => totalCount > 0 ? responseCount / totalCount : 0;
  double get positiveRate => totalCount > 0 ? positiveCount / totalCount : 0;
}

class BehaviorAnalysis {
  final BehaviorState currentState;
  final List<BehaviorPattern> patterns;
  final List<BehaviorTrigger> triggers;
  final List<BehaviorBarrier> barriers;

  BehaviorAnalysis({
    required this.currentState,
    required this.patterns,
    required this.triggers,
    required this.barriers,
  });
}

class HabitLoop {
  final String cue;
  final String routine;
  final String reward;
  final String context;

  HabitLoop({
    required this.cue,
    required this.routine,
    required this.reward,
    required this.context,
  });
}

class HabitParameters {
  final TimeOfDay preferredTime;
  final Duration targetDuration;
  final int targetFrequency; // per week
  final String motivation;

  HabitParameters({
    required this.preferredTime,
    required this.targetDuration,
    required this.targetFrequency,
    required this.motivation,
  });
}

class ScheduledNudge {
  final int day;
  final NudgeType type;
  final String content;
  final TimeOfDay timing;

  ScheduledNudge({
    required this.day,
    required this.type,
    required this.content,
    required this.timing,
  });
}

class HabitMilestone {
  final int days;
  final String name;
  final String reward;

  HabitMilestone({
    required this.days,
    required this.name,
    required this.reward,
  });
}

class ReinforcementSchedule {
  final String immediate;
  final String daily;
  final String weekly;
  final List<String> milestoneRewards;

  ReinforcementSchedule({
    required this.immediate,
    required this.daily,
    required this.weekly,
    required this.milestoneRewards,
  });
}

// Enums
enum NudgeType {
  reminder,
  motivational,
  educational,
  social,
  reward,
  progress,
  challenge,
  feedback,
}

enum TriggerEvent {
  inactivity,
  goalApproaching,
  streakAtRisk,
  newContent,
  peerActivity,
  scheduled,
  contextual,
  manual,
}

enum NudgeResponse {
  accepted,
  dismissed,
  snoozed,
  ignored,
}

enum BehavioralPrinciple {
  lossAversion,
  socialProof,
  commitment,
  reciprocity,
  scarcity,
  authority,
  consistency,
  framing,
}

enum OpportunityType {
  reengagement,
  habitReinforcement,
  goalPursuit,
  challengeOvercoming,
  celebratory,
  preventive,
  general,
}

enum BehaviorState {
  active,
  declining,
  inactive,
  improving,
}

enum NudgeEventType {
  created,
  delivered,
  responded,
  expired,
}

enum GamificationType {
  badge,
  points,
  level,
  streak,
  leaderboard,
  challenge,
}

// Supporting classes
class TypeAnalysis {
  final int count;
  final double responseRate;
  final double positiveRate;

  TypeAnalysis({
    required this.count,
    required this.responseRate,
    required this.positiveRate,
  });
}

class PrincipleAnalysis {}
class TimingAnalysis {}
class Habit {}
class UserState {}
class RecommendationContext {}
class EffectivenessPrediction {
  final double probability;
  EffectivenessPrediction({required this.probability});
}
class BehaviorMetrics {}
class BehaviorChange {
  final double magnitude;
  BehaviorChange({required this.magnitude});
}
class GamificationProfile {}
class GamificationElement {
  final GamificationType type;
  final String id;
  GamificationElement({required this.type, required this.id});
}
class GamificationVisual {}
class Reward {}
class TriggerCondition {}
class ExpirationRules {}
class NudgeTypePreference {}
class BehaviorPattern {}
class BehaviorTrigger {}
class BehaviorBarrier {}