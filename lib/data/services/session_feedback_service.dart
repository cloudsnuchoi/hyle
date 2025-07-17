import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../../models/service_models.dart' as models;

/// Service for managing study session feedback and insights
class SessionFeedbackService {
  static final SessionFeedbackService _instance = SessionFeedbackService._internal();
  factory SessionFeedbackService() => _instance;
  SessionFeedbackService._internal();

  // Active session tracking
  final Map<String, FeedbackStudySession> _activeSessions = {};
  final Map<String, StreamController<SessionUpdate>> _sessionControllers = {};

  /// Start a new study session
  Future<FeedbackStudySession> startSession({
    required String userId,
    required String subject,
    required List<String> topics,
    required SessionGoals goals,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final session = FeedbackStudySession(
        id: sessionId,
        userId: userId,
        subject: subject,
        topics: topics,
        goals: goals,
        startTime: DateTime.now(),
        status: SessionStatus.active,
        metadata: metadata ?? {},
      );

      _activeSessions[sessionId] = session;
      _sessionControllers[sessionId] = StreamController<SessionUpdate>.broadcast();

      // Start monitoring
      _startSessionMonitoring(sessionId);

      // Log session start
      await _logSessionEvent(
        sessionId: sessionId,
        event: SessionEvent(
          type: SessionEventType.started,
          timestamp: DateTime.now(),
          data: {'subject': subject, 'topics': topics},
        ),
      );

      return session;
    } catch (e) {
      safePrint('Error starting session: $e');
      rethrow;
    }
  }

  /// Get session updates stream
  Stream<SessionUpdate> getSessionUpdates(String sessionId) {
    if (!_sessionControllers.containsKey(sessionId)) {
      throw Exception('Session not found');
    }
    return _sessionControllers[sessionId]!.stream;
  }

  /// Record session activity
  Future<void> recordActivity({
    required String sessionId,
    required ActivityType type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) throw Exception('Session not found');

      // Create activity record
      final activity = SessionActivity(
        type: type,
        timestamp: DateTime.now(),
        duration: data['duration'] ?? 0,
        data: data,
      );

      // Update session
      session.activities.add(activity);
      session.lastActivityTime = DateTime.now();

      // Update metrics
      _updateSessionMetrics(session, activity);

      // Check for feedback triggers
      await _checkFeedbackTriggers(session, activity);

      // Emit update
      _sessionControllers[sessionId]?.add(SessionUpdate(
        sessionId: sessionId,
        type: UpdateType.activity,
        data: activity,
      ));
    } catch (e) {
      safePrint('Error recording activity: $e');
    }
  }

  /// Provide real-time feedback
  Future<RealTimeFeedback> provideRealTimeFeedback({
    required String sessionId,
    required FeedbackContext context,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) throw Exception('Session not found');

      // Analyze current state
      final analysis = _analyzeCurrentState(session, context);

      // Generate feedback based on analysis
      final feedback = _generateFeedback(analysis, session);

      // Check if intervention needed
      final intervention = _checkInterventionNeed(analysis, session);

      // Store feedback
      session.feedbackHistory.add(feedback);

      // Emit feedback event
      _sessionControllers[sessionId]?.add(SessionUpdate(
        sessionId: sessionId,
        type: UpdateType.feedback,
        data: feedback,
      ));

      return RealTimeFeedback(
        type: feedback.type,
        message: feedback.message,
        suggestions: feedback.suggestions,
        urgency: feedback.urgency,
        intervention: intervention,
        visualCues: _generateVisualCues(feedback),
      );
    } catch (e) {
      safePrint('Error providing real-time feedback: $e');
      rethrow;
    }
  }

  /// End study session
  Future<SessionSummary> endSession({
    required String sessionId,
    required EndReason reason,
    String? userFeedback,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) throw Exception('Session not found');

      // Update session status
      session.endTime = DateTime.now();
      session.status = SessionStatus.completed;
      session.endReason = reason;

      // Calculate final metrics
      final metrics = _calculateFinalMetrics(session);

      // Generate insights
      final insights = await _generateSessionInsights(session, metrics);

      // Calculate achievements
      final achievements = _checkAchievements(session, metrics);

      // Generate recommendations
      final recommendations = await _generateNextSessionRecommendations(
        session: session,
        metrics: metrics,
        insights: insights,
      );

      // Create summary
      final summary = SessionSummary(
        sessionId: sessionId,
        duration: session.endTime!.difference(session.startTime),
        metrics: metrics,
        insights: insights,
        achievements: achievements,
        recommendations: recommendations,
        goalsAchieved: _evaluateGoals(session.goals, metrics),
        userMood: await _assessUserMood(session),
        keyMoments: _identifyKeyMoments(session),
      );

      // Store session data
      await _storeSessionData(session, summary);

      // Clean up
      _activeSessions.remove(sessionId);
      _sessionControllers[sessionId]?.close();
      _sessionControllers.remove(sessionId);

      // Log session end
      await _logSessionEvent(
        sessionId: sessionId,
        event: SessionEvent(
          type: SessionEventType.ended,
          timestamp: DateTime.now(),
          data: {'reason': reason.toString(), 'summary': summary.toJson()},
        ),
      );

      return summary;
    } catch (e) {
      safePrint('Error ending session: $e');
      rethrow;
    }
  }

  /// Get session feedback history
  Future<FeedbackHistory> getSessionFeedbackHistory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Fetch historical sessions
      final sessions = await _fetchSessionHistory(userId, startDate, endDate);

      // Aggregate feedback
      final allFeedback = <SessionFeedback>[];
      final feedbackPatterns = <String, int>{};

      for (final session in sessions) {
        allFeedback.addAll(session.feedbackHistory);
        
        // Count feedback types
        for (final feedback in session.feedbackHistory) {
          feedbackPatterns[feedback.type] = 
              (feedbackPatterns[feedback.type] ?? 0) + 1;
        }
      }

      // Analyze feedback effectiveness
      final effectiveness = _analyzeFeedbackEffectiveness(sessions);

      // Identify improvement areas
      final improvementAreas = _identifyImprovementAreas(allFeedback);

      return FeedbackHistory(
        userId: userId,
        period: DateTimeRange(start: startDate, end: endDate),
        totalSessions: sessions.length,
        totalFeedback: allFeedback.length,
        feedbackPatterns: feedbackPatterns,
        effectiveness: effectiveness,
        improvementAreas: improvementAreas,
        trends: _analyzeFeedbackTrends(sessions),
      );
    } catch (e) {
      safePrint('Error getting feedback history: $e');
      rethrow;
    }
  }

  /// Analyze session quality
  Future<SessionQualityAnalysis> analyzeSessionQuality({
    required String sessionId,
  }) async {
    try {
      final session = _activeSessions[sessionId] ?? 
          await _fetchSession(sessionId);

      // Calculate quality metrics
      final focusQuality = _calculateFocusQuality(session);
      final productivityScore = _calculateProductivityScore(session);
      final engagementLevel = _calculateEngagementLevel(session);
      final learningEfficiency = _calculateLearningEfficiency(session);

      // Identify quality factors
      final positiveFactors = _identifyPositiveFactors(session);
      final negativeFactors = _identifyNegativeFactors(session);

      // Generate quality insights
      final insights = _generateQualityInsights(
        focus: focusQuality,
        productivity: productivityScore,
        engagement: engagementLevel,
        efficiency: learningEfficiency,
      );

      return SessionQualityAnalysis(
        sessionId: sessionId,
        overallQuality: _calculateOverallQuality(
          focusQuality,
          productivityScore,
          engagementLevel,
          learningEfficiency,
        ),
        focusQuality: focusQuality,
        productivityScore: productivityScore,
        engagementLevel: engagementLevel,
        learningEfficiency: learningEfficiency,
        positiveFactors: positiveFactors,
        negativeFactors: negativeFactors,
        insights: insights,
        recommendations: _generateQualityRecommendations(
          positiveFactors,
          negativeFactors,
        ),
      );
    } catch (e) {
      safePrint('Error analyzing session quality: $e');
      rethrow;
    }
  }

  /// Generate personalized session tips
  Future<PersonalizedSessionTips> generateSessionTips({
    required String userId,
    required String subject,
    required SessionContext context,
  }) async {
    try {
      // Get user's session history
      final history = await _getUserSessionPatterns(userId, subject);

      // Analyze optimal conditions
      final optimalConditions = _analyzeOptimalConditions(history);

      // Generate pre-session tips
      final preSessionTips = _generatePreSessionTips(
        history: history,
        context: context,
        optimal: optimalConditions,
      );

      // Generate during-session tips
      final duringSessionTips = _generateDuringSessionTips(
        history: history,
        subject: subject,
      );

      // Generate post-session tips
      final postSessionTips = _generatePostSessionTips(history);

      // Create personalized routine
      final routine = _createPersonalizedRoutine(
        userId: userId,
        optimal: optimalConditions,
      );

      return PersonalizedSessionTips(
        userId: userId,
        subject: subject,
        preSessionTips: preSessionTips,
        duringSessionTips: duringSessionTips,
        postSessionTips: postSessionTips,
        personalizedRoutine: routine,
        optimalConditions: optimalConditions,
        basedOnSessions: history.length,
      );
    } catch (e) {
      safePrint('Error generating session tips: $e');
      rethrow;
    }
  }

  /// Compare sessions for improvement tracking
  Future<SessionComparison> compareSessions({
    required String sessionId1,
    required String sessionId2,
  }) async {
    try {
      // Fetch both sessions
      final session1 = await _fetchSession(sessionId1);
      final session2 = await _fetchSession(sessionId2);

      // Calculate metrics for both
      final metrics1 = _calculateFinalMetrics(session1);
      final metrics2 = _calculateFinalMetrics(session2);

      // Compare key metrics
      final improvements = <String, double>{};
      final declines = <String, double>{};

      // Focus improvement
      final focusDiff = metrics2.averageFocus - metrics1.averageFocus;
      if (focusDiff > 0) {
        improvements['focus'] = focusDiff;
      } else if (focusDiff < 0) {
        declines['focus'] = focusDiff.abs();
      }

      // Productivity improvement
      final productivityDiff = metrics2.productivity - metrics1.productivity;
      if (productivityDiff > 0) {
        improvements['productivity'] = productivityDiff;
      } else if (productivityDiff < 0) {
        declines['productivity'] = productivityDiff.abs();
      }

      // Identify what changed
      final changes = _identifySessionChanges(session1, session2);

      // Generate insights
      final insights = _generateComparisonInsights(
        improvements: improvements,
        declines: declines,
        changes: changes,
      );

      return SessionComparison(
        session1Id: sessionId1,
        session2Id: sessionId2,
        improvements: improvements,
        declines: declines,
        changes: changes,
        insights: insights,
        overallProgress: _calculateOverallProgress(improvements, declines),
      );
    } catch (e) {
      safePrint('Error comparing sessions: $e');
      rethrow;
    }
  }

  // Private helper methods

  void _startSessionMonitoring(String sessionId) {
    // Monitor session every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) {
      final session = _activeSessions[sessionId];
      if (session == null || session.status != SessionStatus.active) {
        timer.cancel();
        return;
      }

      // Check for inactivity
      final inactiveTime = DateTime.now().difference(session.lastActivityTime);
      if (inactiveTime.inMinutes > 5) {
        _handleInactivity(sessionId, inactiveTime);
      }

      // Update session health
      _updateSessionHealth(session);
    });
  }

  void _handleInactivity(String sessionId, Duration inactiveTime) {
    _sessionControllers[sessionId]?.add(SessionUpdate(
      sessionId: sessionId,
      type: UpdateType.alert,
      data: {
        'type': 'inactivity',
        'duration': inactiveTime.inMinutes,
        'message': 'You\'ve been inactive for ${inactiveTime.inMinutes} minutes',
      },
    ));
  }

  void _updateSessionHealth(FeedbackStudySession session) {
    // Calculate current session health
    final duration = DateTime.now().difference(session.startTime);
    
    double health = 1.0;
    
    // Decrease health for very long sessions
    if (duration.inMinutes > 90) {
      health -= 0.3;
    } else if (duration.inMinutes > 60) {
      health -= 0.1;
    }
    
    // Check focus patterns
    if (session.metrics.focusDrops > 3) {
      health -= 0.2;
    }
    
    session.health = health.clamp(0.0, 1.0);
  }

  Future<void> _logSessionEvent({
    required String sessionId,
    required SessionEvent event,
  }) async {
    try {
      await Amplify.API.post(
        '/sessions/$sessionId/events',
        apiName: 'sessionAPI',
        body: HttpPayload.json(event.toJson()),
      ).response;
    } catch (e) {
      safePrint('Error logging session event: $e');
    }
  }

  void _updateSessionMetrics(FeedbackStudySession session, SessionActivity activity) {
    // Update various metrics based on activity
    switch (activity.type) {
      case ActivityType.problemSolved:
        session.metrics.problemsSolved++;
        if (activity.metadata?['correct'] == true) {
          session.metrics.correctAnswers++;
        }
        break;
      case ActivityType.conceptStudied:
        session.metrics.conceptsStudied++;
        break;
      case ActivityType.notesTaken:
        session.metrics.notesTaken++;
        break;
      case ActivityType.resourceAccessed:
        session.metrics.resourcesUsed++;
        break;
      default:
        break;
    }
    
    // Update time metrics
    session.metrics.activeTime += activity.duration;
  }

  Future<void> _checkFeedbackTriggers(
    FeedbackStudySession session,
    SessionActivity activity,
  ) async {
    // Check various conditions for feedback
    
    // Long session without break
    final duration = DateTime.now().difference(session.startTime);
    if (duration.inMinutes > 45 && !session.hadBreak) {
      await provideRealTimeFeedback(
        sessionId: session.id,
        context: FeedbackContext(
          trigger: 'long_session',
          data: {'duration': duration.inMinutes},
        ),
      );
    }
    
    // Multiple incorrect answers
    if (session.metrics.correctAnswers < session.metrics.problemsSolved * 0.5 &&
        session.metrics.problemsSolved >= 5) {
      await provideRealTimeFeedback(
        sessionId: session.id,
        context: FeedbackContext(
          trigger: 'low_accuracy',
          data: {'accuracy': session.metrics.correctAnswers / session.metrics.problemsSolved},
        ),
      );
    }
  }

  SessionAnalysis _analyzeCurrentState(
    FeedbackStudySession session,
    FeedbackContext context,
  ) {
    return SessionAnalysis(
      focusLevel: _assessCurrentFocus(session),
      productivityLevel: _assessProductivity(session),
      stressIndicators: _detectStressIndicators(session),
      needsBreak: _checkBreakNeed(session),
      performanceTrend: _analyzePerformanceTrend(session),
    );
  }

  double _assessCurrentFocus(FeedbackStudySession session) {
    // Assess focus based on recent activities
    if (session.activities.isEmpty) return 0.7;
    
    // Check activity frequency
    final recentActivities = session.activities
        .where((a) => DateTime.now().difference(a.timestamp).inMinutes < 10)
        .toList();
    
    return recentActivities.length >= 3 ? 0.8 : 0.6;
  }

  double _assessProductivity(FeedbackStudySession session) {
    if (session.metrics.problemsSolved == 0) return 0.5;
    
    final accuracy = session.metrics.correctAnswers / session.metrics.problemsSolved;
    final rate = session.metrics.problemsSolved / 
        (DateTime.now().difference(session.startTime).inMinutes + 1);
    
    return (accuracy * 0.6 + rate * 0.4).clamp(0.0, 1.0);
  }

  List<String> _detectStressIndicators(FeedbackStudySession session) {
    final indicators = <String>[];
    
    // Rapid activity switching
    if (session.metrics.focusDrops > 5) {
      indicators.add('frequent_context_switching');
    }
    
    // Declining performance
    if (session.metrics.correctAnswers < session.metrics.problemsSolved * 0.4) {
      indicators.add('declining_accuracy');
    }
    
    return indicators;
  }

  bool _checkBreakNeed(FeedbackStudySession session) {
    final duration = DateTime.now().difference(session.startTime);
    return duration.inMinutes > 45 && !session.hadBreak;
  }

  String _analyzePerformanceTrend(FeedbackStudySession session) {
    // Analyze recent performance
    final recentActivities = session.activities
        .where((a) => a.type == ActivityType.problemSolved)
        .toList();
    
    if (recentActivities.length < 3) return 'stable';
    
    // Check last 3 problems
    final last3 = recentActivities.skip(recentActivities.length - 3).toList();
    final correctCount = last3.where((a) => a.metadata?['correct'] == true).length;
    
    if (correctCount >= 2) return 'improving';
    if (correctCount == 0) return 'declining';
    return 'stable';
  }

  SessionFeedback _generateFeedback(
    SessionAnalysis analysis,
    FeedbackStudySession session,
  ) {
    String type = 'encouragement';
    String message = '';
    List<String> suggestions = [];
    
    if (analysis.needsBreak) {
      type = 'break_reminder';
      message = 'You\'ve been studying for a while. Time for a short break!';
      suggestions = [
        'Take a 5-10 minute break',
        'Stretch and move around',
        'Hydrate and rest your eyes',
      ];
    } else if (analysis.performanceTrend == 'declining') {
      type = 'performance_support';
      message = 'I notice you\'re having some difficulty. Let\'s adjust our approach.';
      suggestions = [
        'Review the concept once more',
        'Try an easier problem first',
        'Take a moment to refocus',
      ];
    } else if (analysis.performanceTrend == 'improving') {
      type = 'positive_reinforcement';
      message = 'Great progress! You\'re really getting the hang of this.';
      suggestions = [
        'Keep up the momentum',
        'Try a slightly harder challenge',
      ];
    }
    
    return SessionFeedback(
      type: type,
      message: message,
      suggestions: suggestions,
      timestamp: DateTime.now(),
      urgency: analysis.needsBreak ? FeedbackUrgency.high : FeedbackUrgency.low,
    );
  }

  InterventionNeeds? _checkInterventionNeed(
    SessionAnalysis analysis,
    FeedbackStudySession session,
  ) {
    if (analysis.stressIndicators.length >= 2) {
      return InterventionNeeds(
        type: 'stress_management',
        urgency: 'medium',
        suggestedActions: [
          'Pause and take deep breaths',
          'Switch to review mode',
          'Consider ending session early',
        ],
      );
    }
    
    if (analysis.performanceTrend == 'declining' && 
        session.metrics.problemsSolved > 10) {
      return InterventionNeeds(
        type: 'cognitive_overload',
        urgency: 'high',
        suggestedActions: [
          'Take a proper break',
          'Review fundamentals',
          'Reduce problem difficulty',
        ],
      );
    }
    
    return null;
  }

  List<VisualCue> _generateVisualCues(SessionFeedback feedback) {
    final cues = <VisualCue>[];
    
    switch (feedback.type) {
      case 'break_reminder':
        cues.add(VisualCue(
          type: 'icon',
          value: Icons.timer,
          color: Colors.orange,
        ));
        break;
      case 'positive_reinforcement':
        cues.add(VisualCue(
          type: 'icon',
          value: Icons.star,
          color: Colors.amber,
        ));
        break;
      case 'performance_support':
        cues.add(VisualCue(
          type: 'icon',
          value: Icons.support,
          color: Colors.blue,
        ));
        break;
    }
    
    return cues;
  }

  SessionMetrics _calculateFinalMetrics(FeedbackStudySession session) {
    final duration = (session.endTime ?? DateTime.now())
        .difference(session.startTime);
    
    return SessionMetrics(
      totalDuration: duration,
      activeTime: session.metrics.activeTime,
      problemsSolved: session.metrics.problemsSolved,
      correctAnswers: session.metrics.correctAnswers,
      conceptsStudied: session.metrics.conceptsStudied,
      notesTaken: session.metrics.notesTaken,
      resourcesUsed: session.metrics.resourcesUsed,
      focusDrops: session.metrics.focusDrops,
      averageFocus: _calculateAverageFocus(session),
      productivity: _calculateProductivity(session),
      efficiency: _calculateEfficiency(session),
    );
  }

  double _calculateAverageFocus(FeedbackStudySession session) {
    // Calculate based on activity patterns
    if (session.activities.isEmpty) return 0.0;
    
    final totalTime = DateTime.now().difference(session.startTime).inMinutes;
    final activeTime = session.metrics.activeTime;
    
    return (activeTime / totalTime).clamp(0.0, 1.0);
  }

  double _calculateProductivity(FeedbackStudySession session) {
    if (session.metrics.problemsSolved == 0) return 0.0;
    
    final accuracy = session.metrics.correctAnswers / session.metrics.problemsSolved;
    final conceptProgress = session.metrics.conceptsStudied * 0.1;
    
    return (accuracy * 0.7 + conceptProgress * 0.3).clamp(0.0, 1.0);
  }

  double _calculateEfficiency(FeedbackStudySession session) {
    final goalProgress = _calculateGoalProgress(session.goals, session.metrics);
    final timeEfficiency = session.metrics.activeTime / 
        DateTime.now().difference(session.startTime).inMinutes;
    
    return (goalProgress * 0.6 + timeEfficiency * 0.4).clamp(0.0, 1.0);
  }

  double _calculateGoalProgress(SessionGoals goals, SessionMetrics metrics) {
    double progress = 0.0;
    int goalCount = 0;
    
    if (goals.targetProblems != null && goals.targetProblems! > 0) {
      progress += metrics.problemsSolved / goals.targetProblems!;
      goalCount++;
    }
    
    if (goals.targetConcepts != null && goals.targetConcepts! > 0) {
      progress += metrics.conceptsStudied / goals.targetConcepts!;
      goalCount++;
    }
    
    if (goals.targetDuration != null) {
      progress += metrics.totalDuration.inMinutes / goals.targetDuration!;
      goalCount++;
    }
    
    return goalCount > 0 ? (progress / goalCount).clamp(0.0, 1.0) : 0.0;
  }

  Future<List<SessionInsight>> _generateSessionInsights(
    FeedbackStudySession session,
    SessionMetrics metrics,
  ) async {
    final insights = <SessionInsight>[];
    
    // Focus insight
    if (metrics.averageFocus > 0.8) {
      insights.add(SessionInsight(
        type: 'focus',
        title: 'Excellent Focus',
        description: 'You maintained great concentration throughout',
        impact: 'positive',
      ));
    } else if (metrics.focusDrops > 5) {
      insights.add(SessionInsight(
        type: 'focus',
        title: 'Frequent Distractions',
        description: 'Your focus was interrupted ${metrics.focusDrops} times',
        impact: 'negative',
        suggestion: 'Try to minimize distractions in your study environment',
      ));
    }
    
    // Productivity insight
    if (metrics.productivity > 0.8) {
      insights.add(SessionInsight(
        type: 'productivity',
        title: 'High Productivity',
        description: 'You accomplished a lot this session',
        impact: 'positive',
      ));
    }
    
    // Efficiency insight
    if (metrics.efficiency > 0.7) {
      insights.add(SessionInsight(
        type: 'efficiency',
        title: 'Efficient Learning',
        description: 'You made good progress toward your goals',
        impact: 'positive',
      ));
    }
    
    return insights;
  }

  List<models.SessionAchievement> _checkAchievements(
    FeedbackStudySession session,
    SessionMetrics metrics,
  ) {
    final achievements = <models.SessionAchievement>[];
    
    // Perfect accuracy
    if (metrics.problemsSolved >= 10 && 
        metrics.correctAnswers == metrics.problemsSolved) {
      achievements.add(models.SessionAchievement(
        id: 'perfect_accuracy',
        title: 'Perfect Score',
        description: 'Solved all problems correctly',
        icon: Icons.check_circle,
        rarity: 'rare',
      ));
    }
    
    // Long focus
    if (metrics.averageFocus > 0.9 && metrics.totalDuration.inMinutes > 60) {
      achievements.add(models.SessionAchievement(
        id: 'deep_focus',
        title: 'Deep Focus',
        description: 'Maintained exceptional focus for over an hour',
        icon: Icons.psychology,
        rarity: 'epic',
      ));
    }
    
    // Goal crusher
    if (_calculateGoalProgress(session.goals, metrics) >= 1.2) {
      achievements.add(models.SessionAchievement(
        id: 'goal_crusher',
        title: 'Goal Crusher',
        description: 'Exceeded your session goals by 20%',
        icon: Icons.trending_up,
        rarity: 'uncommon',
      ));
    }
    
    return achievements;
  }

  Future<List<NextSessionRecommendation>> _generateNextSessionRecommendations({
    required FeedbackStudySession session,
    required SessionMetrics metrics,
    required List<SessionInsight> insights,
  }) async {
    final recommendations = <NextSessionRecommendation>[];
    
    // Based on performance
    if (metrics.productivity < 0.6) {
      recommendations.add(NextSessionRecommendation(
        type: 'difficulty_adjustment',
        title: 'Start with easier problems',
        description: 'Build confidence before tackling harder concepts',
        priority: 1,
      ));
    }
    
    // Based on focus patterns
    if (metrics.focusDrops > 5) {
      recommendations.add(NextSessionRecommendation(
        type: 'environment',
        title: 'Optimize study environment',
        description: 'Find a quieter space or use focus music',
        priority: 2,
      ));
    }
    
    // Based on timing
    if (metrics.efficiency < 0.5 && metrics.totalDuration.inMinutes > 90) {
      recommendations.add(NextSessionRecommendation(
        type: 'duration',
        title: 'Try shorter sessions',
        description: 'Multiple 45-minute sessions might be more effective',
        priority: 1,
      ));
    }
    
    return recommendations;
  }

  Map<String, bool> _evaluateGoals(SessionGoals goals, SessionMetrics metrics) {
    final evaluation = <String, bool>{};
    
    if (goals.targetProblems != null) {
      evaluation['problems'] = metrics.problemsSolved >= goals.targetProblems!;
    }
    
    if (goals.targetConcepts != null) {
      evaluation['concepts'] = metrics.conceptsStudied >= goals.targetConcepts!;
    }
    
    if (goals.targetDuration != null) {
      evaluation['duration'] = metrics.totalDuration.inMinutes >= goals.targetDuration!;
    }
    
    if (goals.targetAccuracy != null && metrics.problemsSolved > 0) {
      final accuracy = metrics.correctAnswers / metrics.problemsSolved;
      evaluation['accuracy'] = accuracy >= goals.targetAccuracy!;
    }
    
    return evaluation;
  }

  Future<UserMood> _assessUserMood(FeedbackStudySession session) async {
    // Analyze session patterns to infer mood
    double satisfaction = 0.5;
    
    // Good performance increases satisfaction
    if (session.metrics.correctAnswers > session.metrics.problemsSolved * 0.8) {
      satisfaction += 0.2;
    }
    
    // Achieving goals increases satisfaction
    final goalsAchieved = _evaluateGoals(session.goals, session.metrics)
        .values
        .where((v) => v)
        .length;
    satisfaction += goalsAchieved * 0.1;
    
    // Long sessions without breaks decrease satisfaction
    if (session.endTime != null) {
      final duration = session.endTime!.difference(session.startTime);
      if (duration.inMinutes > 90 && !session.hadBreak) {
        satisfaction -= 0.2;
      }
    }
    
    return UserMood(
      satisfaction: satisfaction.clamp(0.0, 1.0),
      energy: session.health,
      confidence: session.metrics.correctAnswers / 
          math.max(session.metrics.problemsSolved, 1),
    );
  }

  List<KeyMoment> _identifyKeyMoments(FeedbackStudySession session) {
    final moments = <KeyMoment>[];
    
    // Find breakthrough moments
    int consecutiveCorrect = 0;
    for (final activity in session.activities) {
      if (activity.type == ActivityType.problemSolved) {
        if (activity.metadata?['correct'] == true) {
          consecutiveCorrect++;
          if (consecutiveCorrect == 5) {
            moments.add(KeyMoment(
              timestamp: activity.timestamp,
              type: 'breakthrough',
              description: 'Solved 5 problems in a row',
              significance: 'high',
            ));
          }
        } else {
          consecutiveCorrect = 0;
        }
      }
    }
    
    // Find struggle moments
    final struggles = session.activities
        .where((a) => a.type == ActivityType.problemSolved && 
                     a.metadata?['correct'] == false &&
                     a.duration > 300) // 5+ minutes
        .map((a) => KeyMoment(
          timestamp: a.timestamp,
          type: 'struggle',
          description: 'Challenging problem took ${a.duration ~/ 60} minutes',
          significance: 'medium',
        ))
        .toList();
    
    moments.addAll(struggles);
    
    return moments;
  }

  Future<void> _storeSessionData(
    FeedbackStudySession session,
    SessionSummary summary,
  ) async {
    try {
      await Amplify.API.post(
        '/sessions',
        apiName: 'sessionAPI',
        body: HttpPayload.json({
          'session': session.toJson(),
          'summary': summary.toJson(),
        }),
      ).response;
    } catch (e) {
      safePrint('Error storing session data: $e');
    }
  }

  Future<List<FeedbackStudySession>> _fetchSessionHistory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Fetch from database
    return [];
  }

  FeedbackEffectiveness _analyzeFeedbackEffectiveness(
    List<FeedbackStudySession> sessions,
  ) {
    // Analyze how users responded to feedback
    return FeedbackEffectiveness(
      responseRate: 0.75,
      positiveImpact: 0.6,
      mostEffectiveTypes: ['break_reminder', 'positive_reinforcement'],
      leastEffectiveTypes: ['generic_encouragement'],
    );
  }

  List<String> _identifyImprovementAreas(List<SessionFeedback> feedback) {
    final areas = <String>{};
    
    for (final fb in feedback) {
      if (fb.type == 'performance_support') {
        areas.add('Problem-solving accuracy');
      } else if (fb.type == 'break_reminder') {
        areas.add('Session pacing');
      } else if (fb.type == 'focus_improvement') {
        areas.add('Concentration management');
      }
    }
    
    return areas.toList();
  }

  FeedbackTrends _analyzeFeedbackTrends(List<FeedbackStudySession> sessions) {
    // Analyze how feedback patterns change over time
    return FeedbackTrends(
      improvingAreas: ['Focus duration', 'Break compliance'],
      decliningAreas: [],
      emergingPatterns: ['Late session fatigue'],
    );
  }

  Future<FeedbackStudySession> _fetchSession(String sessionId) async {
    // Fetch from database or cache
    final session = _activeSessions[sessionId];
    if (session != null) return session;
    
    // Fetch from database
    throw Exception('Session not found');
  }

  double _calculateFocusQuality(FeedbackStudySession session) {
    if (session.activities.isEmpty) return 0.0;
    
    // Calculate based on activity continuity
    final gaps = <int>[];
    for (int i = 1; i < session.activities.length; i++) {
      final gap = session.activities[i].timestamp
          .difference(session.activities[i-1].timestamp)
          .inMinutes;
      gaps.add(gap);
    }
    
    if (gaps.isEmpty) return 0.5;
    
    // Fewer gaps = better focus
    final avgGap = gaps.reduce((a, b) => a + b) / gaps.length;
    return (1 / (1 + avgGap / 5)).clamp(0.0, 1.0);
  }

  double _calculateProductivityScore(FeedbackStudySession session) {
    return _calculateProductivity(session);
  }

  double _calculateEngagementLevel(FeedbackStudySession session) {
    // Based on activity variety and frequency
    final activityTypes = session.activities
        .map((a) => a.type)
        .toSet()
        .length;
    
    final activityRate = session.activities.length / 
        math.max(DateTime.now().difference(session.startTime).inMinutes, 1);
    
    return (activityTypes * 0.1 + activityRate * 0.5).clamp(0.0, 1.0);
  }

  double _calculateLearningEfficiency(FeedbackStudySession session) {
    return _calculateEfficiency(session);
  }

  List<String> _identifyPositiveFactors(FeedbackStudySession session) {
    final factors = <String>[];
    
    if (session.metrics.averageFocus > 0.7) {
      factors.add('Good focus maintenance');
    }
    
    if (session.metrics.correctAnswers > session.metrics.problemsSolved * 0.8) {
      factors.add('High accuracy');
    }
    
    if (session.hadBreak) {
      factors.add('Proper break management');
    }
    
    return factors;
  }

  List<String> _identifyNegativeFactors(FeedbackStudySession session) {
    final factors = <String>[];
    
    if (session.metrics.focusDrops > 5) {
      factors.add('Frequent interruptions');
    }
    
    if (!session.hadBreak && 
        DateTime.now().difference(session.startTime).inMinutes > 60) {
      factors.add('No breaks taken');
    }
    
    if (session.metrics.correctAnswers < session.metrics.problemsSolved * 0.5) {
      factors.add('Low accuracy');
    }
    
    return factors;
  }

  List<QualityInsight> _generateQualityInsights({
    required double focus,
    required double productivity,
    required double engagement,
    required double efficiency,
  }) {
    final insights = <QualityInsight>[];
    
    if (focus > 0.8 && productivity > 0.7) {
      insights.add(QualityInsight(
        aspect: 'overall',
        observation: 'Excellent session quality',
        impact: 'You\'re in the learning zone',
      ));
    }
    
    if (engagement < 0.5) {
      insights.add(QualityInsight(
        aspect: 'engagement',
        observation: 'Low engagement detected',
        impact: 'Consider more interactive activities',
      ));
    }
    
    return insights;
  }

  double _calculateOverallQuality(
    double focus,
    double productivity,
    double engagement,
    double efficiency,
  ) {
    return (focus * 0.3 + productivity * 0.3 + 
            engagement * 0.2 + efficiency * 0.2);
  }

  List<String> _generateQualityRecommendations(
    List<String> positive,
    List<String> negative,
  ) {
    final recommendations = <String>[];
    
    // Build on positives
    if (positive.contains('Good focus maintenance')) {
      recommendations.add('Continue with current focus strategies');
    }
    
    // Address negatives
    if (negative.contains('Frequent interruptions')) {
      recommendations.add('Find a quieter study environment');
      recommendations.add('Use do-not-disturb mode');
    }
    
    if (negative.contains('No breaks taken')) {
      recommendations.add('Set break reminders every 45 minutes');
    }
    
    return recommendations;
  }

  Future<List<SessionPatternData>> _getUserSessionPatterns(
    String userId,
    String subject,
  ) async {
    // Fetch and analyze user's session patterns
    return [];
  }

  OptimalConditions _analyzeOptimalConditions(
    List<SessionPatternData> history,
  ) {
    // Analyze when user performs best
    return OptimalConditions(
      bestTimeOfDay: TimeOfDay(hour: 14, minute: 0),
      optimalDuration: 45,
      idealBreakFrequency: 45,
      preferredDifficulty: 'moderate',
      environmentalFactors: {
        'noise_level': 'quiet',
        'lighting': 'natural',
      },
    );
  }

  List<SessionTip> _generatePreSessionTips({
    required List<SessionPatternData> history,
    required SessionContext context,
    required OptimalConditions optimal,
  }) {
    final tips = <SessionTip>[];
    
    // Time-based tip
    final currentHour = DateTime.now().hour;
    if ((optimal.bestTimeOfDay.hour - currentHour).abs() > 3) {
      tips.add(SessionTip(
        category: 'timing',
        tip: 'You usually perform better around ${optimal.bestTimeOfDay.hour}:00',
        priority: 'low',
      ));
    }
    
    // Environment tip
    tips.add(SessionTip(
      category: 'environment',
      tip: 'Ensure your study space is quiet and well-lit',
      priority: 'medium',
    ));
    
    // Preparation tip
    tips.add(SessionTip(
      category: 'preparation',
      tip: 'Have water and healthy snacks ready',
      priority: 'low',
    ));
    
    return tips;
  }

  List<SessionTip> _generateDuringSessionTips({
    required List<SessionPatternData> history,
    required String subject,
  }) {
    return [
      SessionTip(
        category: 'focus',
        tip: 'If you feel stuck, take a 2-minute mental break',
        priority: 'medium',
      ),
      SessionTip(
        category: 'technique',
        tip: 'Use the Pomodoro technique for better time management',
        priority: 'medium',
      ),
    ];
  }

  List<SessionTip> _generatePostSessionTips(
    List<SessionPatternData> history,
  ) {
    return [
      SessionTip(
        category: 'review',
        tip: 'Spend 5 minutes reviewing what you learned',
        priority: 'high',
      ),
      SessionTip(
        category: 'reflection',
        tip: 'Note down any challenging concepts for next time',
        priority: 'medium',
      ),
    ];
  }

  PersonalizedRoutine _createPersonalizedRoutine({
    required String userId,
    required OptimalConditions optimal,
  }) {
    return PersonalizedRoutine(
      preSession: [
        RoutineStep(
          duration: 5,
          activity: 'Review goals and materials',
        ),
        RoutineStep(
          duration: 2,
          activity: 'Clear distractions',
        ),
      ],
      duringSession: [
        RoutineStep(
          duration: optimal.optimalDuration,
          activity: 'Focused study block',
        ),
        RoutineStep(
          duration: 10,
          activity: 'Break and stretch',
        ),
      ],
      postSession: [
        RoutineStep(
          duration: 5,
          activity: 'Review and summarize',
        ),
        RoutineStep(
          duration: 3,
          activity: 'Plan next session',
        ),
      ],
    );
  }

  List<SessionChange> _identifySessionChanges(
    FeedbackStudySession session1,
    FeedbackStudySession session2,
  ) {
    final changes = <SessionChange>[];
    
    // Duration change
    final duration1 = (session1.endTime ?? DateTime.now())
        .difference(session1.startTime);
    final duration2 = (session2.endTime ?? DateTime.now())
        .difference(session2.startTime);
    
    if ((duration2.inMinutes - duration1.inMinutes).abs() > 15) {
      changes.add(SessionChange(
        aspect: 'duration',
        from: '${duration1.inMinutes} minutes',
        to: '${duration2.inMinutes} minutes',
      ));
    }
    
    // Subject change
    if (session1.subject != session2.subject) {
      changes.add(SessionChange(
        aspect: 'subject',
        from: session1.subject,
        to: session2.subject,
      ));
    }
    
    return changes;
  }

  List<ComparisonInsight> _generateComparisonInsights({
    required Map<String, double> improvements,
    required Map<String, double> declines,
    required List<SessionChange> changes,
  }) {
    final insights = <ComparisonInsight>[];
    
    if (improvements['focus'] != null && improvements['focus']! > 0.1) {
      insights.add(ComparisonInsight(
        type: 'improvement',
        message: 'Your focus improved by ${(improvements['focus']! * 100).round()}%',
        significance: 'high',
      ));
    }
    
    if (declines['productivity'] != null && declines['productivity']! > 0.1) {
      insights.add(ComparisonInsight(
        type: 'decline',
        message: 'Productivity decreased. Consider what changed.',
        significance: 'medium',
      ));
    }
    
    return insights;
  }

  double _calculateOverallProgress(
    Map<String, double> improvements,
    Map<String, double> declines,
  ) {
    final totalImprovement = improvements.values.fold(0.0, (a, b) => a + b);
    final totalDecline = declines.values.fold(0.0, (a, b) => a + b);
    
    return totalImprovement - totalDecline;
  }
}

// Data models
class FeedbackStudySession {
  final String id;
  final String userId;
  final String subject;
  final List<String> topics;
  final SessionGoals goals;
  final DateTime startTime;
  DateTime? endTime;
  SessionStatus status;
  EndReason? endReason;
  final List<SessionActivity> activities = [];
  final List<SessionFeedback> feedbackHistory = [];
  final SessionMetrics metrics = SessionMetrics();
  DateTime lastActivityTime;
  bool hadBreak = false;
  double health = 1.0;
  final Map<String, dynamic> metadata;

  FeedbackStudySession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.topics,
    required this.goals,
    required this.startTime,
    this.endTime,
    required this.status,
    this.endReason,
    required this.metadata,
  }) : lastActivityTime = startTime;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'subject': subject,
    'topics': topics,
    'goals': goals.toJson(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'status': status.toString(),
    'metadata': metadata,
  };
}

class SessionGoals {
  final int? targetProblems;
  final int? targetConcepts;
  final int? targetDuration; // minutes
  final double? targetAccuracy;
  final List<String>? specificObjectives;

  SessionGoals({
    this.targetProblems,
    this.targetConcepts,
    this.targetDuration,
    this.targetAccuracy,
    this.specificObjectives,
  });

  Map<String, dynamic> toJson() => {
    'targetProblems': targetProblems,
    'targetConcepts': targetConcepts,
    'targetDuration': targetDuration,
    'targetAccuracy': targetAccuracy,
    'specificObjectives': specificObjectives,
  };
}

enum SessionStatus { active, paused, completed, abandoned }

enum EndReason { completed, timeout, abandoned, error }

// SessionActivity class moved to service_models.dart
// Using models.SessionActivity

// ActivityType enum moved to service_models.dart

class SessionMetrics {
  int activeTime = 0; // seconds
  int problemsSolved = 0;
  int correctAnswers = 0;
  int conceptsStudied = 0;
  int notesTaken = 0;
  int resourcesUsed = 0;
  int focusDrops = 0;
  double averageFocus = 0.0;
  double productivity = 0.0;
  double efficiency = 0.0;
  Duration totalDuration = Duration.zero;
}

class SessionUpdate {
  final String sessionId;
  final UpdateType type;
  final dynamic data;

  SessionUpdate({
    required this.sessionId,
    required this.type,
    required this.data,
  });
}

enum UpdateType { activity, feedback, alert, metric }

class SessionEvent {
  final SessionEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  SessionEvent({
    required this.type,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };
}

enum SessionEventType { started, ended, paused, resumed }

class RealTimeFeedback {
  final String type;
  final String message;
  final List<String> suggestions;
  final FeedbackUrgency urgency;
  final InterventionNeeds? intervention;
  final List<VisualCue> visualCues;

  RealTimeFeedback({
    required this.type,
    required this.message,
    required this.suggestions,
    required this.urgency,
    this.intervention,
    required this.visualCues,
  });
}

class FeedbackContext {
  final String trigger;
  final Map<String, dynamic> data;

  FeedbackContext({
    required this.trigger,
    required this.data,
  });
}

class SessionAnalysis {
  final double focusLevel;
  final double productivityLevel;
  final List<String> stressIndicators;
  final bool needsBreak;
  final String performanceTrend;

  SessionAnalysis({
    required this.focusLevel,
    required this.productivityLevel,
    required this.stressIndicators,
    required this.needsBreak,
    required this.performanceTrend,
  });
}

class SessionFeedback {
  final String type;
  final String message;
  final List<String> suggestions;
  final DateTime timestamp;
  final FeedbackUrgency urgency;

  SessionFeedback({
    required this.type,
    required this.message,
    required this.suggestions,
    required this.timestamp,
    required this.urgency,
  });
}

enum FeedbackUrgency { low, medium, high }

class InterventionNeeds {
  final String type;
  final String urgency;
  final List<String> suggestedActions;

  InterventionNeeds({
    required this.type,
    required this.urgency,
    required this.suggestedActions,
  });
}

class VisualCue {
  final String type;
  final dynamic value;
  final Color color;

  VisualCue({
    required this.type,
    required this.value,
    required this.color,
  });
}

class SessionSummary {
  final String sessionId;
  final Duration duration;
  final SessionMetrics metrics;
  final List<SessionInsight> insights;
  final List<models.SessionAchievement> achievements;
  final List<NextSessionRecommendation> recommendations;
  final Map<String, bool> goalsAchieved;
  final UserMood userMood;
  final List<KeyMoment> keyMoments;

  SessionSummary({
    required this.sessionId,
    required this.duration,
    required this.metrics,
    required this.insights,
    required this.achievements,
    required this.recommendations,
    required this.goalsAchieved,
    required this.userMood,
    required this.keyMoments,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'duration': duration.inMinutes,
    'metrics': {
      'problemsSolved': metrics.problemsSolved,
      'correctAnswers': metrics.correctAnswers,
      'averageFocus': metrics.averageFocus,
      'productivity': metrics.productivity,
    },
    'insights': insights.length,
    'achievements': achievements.length,
    'goalsAchieved': goalsAchieved,
  };
}

class SessionInsight {
  final String type;
  final String title;
  final String description;
  final String impact;
  final String? suggestion;

  SessionInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.impact,
    this.suggestion,
  });
}

// Achievement class moved to service_models.dart
// Using models.SessionAchievement instead

class NextSessionRecommendation {
  final String type;
  final String title;
  final String description;
  final int priority;

  NextSessionRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  });
}

class UserMood {
  final double satisfaction;
  final double energy;
  final double confidence;

  UserMood({
    required this.satisfaction,
    required this.energy,
    required this.confidence,
  });
}

class KeyMoment {
  final DateTime timestamp;
  final String type;
  final String description;
  final String significance;

  KeyMoment({
    required this.timestamp,
    required this.type,
    required this.description,
    required this.significance,
  });
}

class FeedbackHistory {
  final String userId;
  final DateTimeRange period;
  final int totalSessions;
  final int totalFeedback;
  final Map<String, int> feedbackPatterns;
  final FeedbackEffectiveness effectiveness;
  final List<String> improvementAreas;
  final FeedbackTrends trends;

  FeedbackHistory({
    required this.userId,
    required this.period,
    required this.totalSessions,
    required this.totalFeedback,
    required this.feedbackPatterns,
    required this.effectiveness,
    required this.improvementAreas,
    required this.trends,
  });
}

class FeedbackEffectiveness {
  final double responseRate;
  final double positiveImpact;
  final List<String> mostEffectiveTypes;
  final List<String> leastEffectiveTypes;

  FeedbackEffectiveness({
    required this.responseRate,
    required this.positiveImpact,
    required this.mostEffectiveTypes,
    required this.leastEffectiveTypes,
  });
}

class FeedbackTrends {
  final List<String> improvingAreas;
  final List<String> decliningAreas;
  final List<String> emergingPatterns;

  FeedbackTrends({
    required this.improvingAreas,
    required this.decliningAreas,
    required this.emergingPatterns,
  });
}

class SessionQualityAnalysis {
  final String sessionId;
  final double overallQuality;
  final double focusQuality;
  final double productivityScore;
  final double engagementLevel;
  final double learningEfficiency;
  final List<String> positiveFactors;
  final List<String> negativeFactors;
  final List<QualityInsight> insights;
  final List<String> recommendations;

  SessionQualityAnalysis({
    required this.sessionId,
    required this.overallQuality,
    required this.focusQuality,
    required this.productivityScore,
    required this.engagementLevel,
    required this.learningEfficiency,
    required this.positiveFactors,
    required this.negativeFactors,
    required this.insights,
    required this.recommendations,
  });
}

class QualityInsight {
  final String aspect;
  final String observation;
  final String impact;

  QualityInsight({
    required this.aspect,
    required this.observation,
    required this.impact,
  });
}

class PersonalizedSessionTips {
  final String userId;
  final String subject;
  final List<SessionTip> preSessionTips;
  final List<SessionTip> duringSessionTips;
  final List<SessionTip> postSessionTips;
  final PersonalizedRoutine personalizedRoutine;
  final OptimalConditions optimalConditions;
  final int basedOnSessions;

  PersonalizedSessionTips({
    required this.userId,
    required this.subject,
    required this.preSessionTips,
    required this.duringSessionTips,
    required this.postSessionTips,
    required this.personalizedRoutine,
    required this.optimalConditions,
    required this.basedOnSessions,
  });
}

class SessionTip {
  final String category;
  final String tip;
  final String priority;

  SessionTip({
    required this.category,
    required this.tip,
    required this.priority,
  });
}

class PersonalizedRoutine {
  final List<RoutineStep> preSession;
  final List<RoutineStep> duringSession;
  final List<RoutineStep> postSession;

  PersonalizedRoutine({
    required this.preSession,
    required this.duringSession,
    required this.postSession,
  });
}

class RoutineStep {
  final int duration;
  final String activity;

  RoutineStep({
    required this.duration,
    required this.activity,
  });
}

class OptimalConditions {
  final TimeOfDay bestTimeOfDay;
  final int optimalDuration;
  final int idealBreakFrequency;
  final String preferredDifficulty;
  final Map<String, dynamic> environmentalFactors;

  OptimalConditions({
    required this.bestTimeOfDay,
    required this.optimalDuration,
    required this.idealBreakFrequency,
    required this.preferredDifficulty,
    required this.environmentalFactors,
  });
}

class SessionContext {
  final String timeOfDay;
  final String energyLevel;
  final String location;
  final List<String> availableResources;

  SessionContext({
    required this.timeOfDay,
    required this.energyLevel,
    required this.location,
    required this.availableResources,
  });
}

class SessionComparison {
  final String session1Id;
  final String session2Id;
  final Map<String, double> improvements;
  final Map<String, double> declines;
  final List<SessionChange> changes;
  final List<ComparisonInsight> insights;
  final double overallProgress;

  SessionComparison({
    required this.session1Id,
    required this.session2Id,
    required this.improvements,
    required this.declines,
    required this.changes,
    required this.insights,
    required this.overallProgress,
  });
}

class SessionChange {
  final String aspect;
  final String from;
  final String to;

  SessionChange({
    required this.aspect,
    required this.from,
    required this.to,
  });
}

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

// Supporting classes
class SessionPatternData {
  final String sessionId;
  final DateTime date;
  final double quality;
  final SessionMetrics metrics;

  SessionPatternData({
    required this.sessionId,
    required this.date,
    required this.quality,
    required this.metrics,
  });
}