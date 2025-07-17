import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import all services
import 'predictive_analytics_service.dart' as predictive;
import 'learning_pattern_analyzer.dart' as pattern;
import 'cognitive_load_monitor.dart';
import 'attention_tracking_service.dart';
import 'mistake_pattern_service.dart' as mistake;
import 'session_feedback_service.dart' as session;
import 'progress_visualization_service.dart' as progress;
import 'achievement_tracking_service.dart' as achievement;
import 'learning_journal_service.dart';
import 'problem_difficulty_analyzer.dart' as difficulty;
import 'solution_quality_evaluator.dart' as solution;
import 'adaptive_assessment_engine.dart';
import 'performance_metrics_calculator.dart' as metrics;
import 'smart_notification_service.dart' as notification;
import 'behavioral_nudge_engine.dart' as nudge;
import 'motivational_message_generator.dart' as motivation;
import 'intervention_timing_optimizer.dart' as timing;
import 'data_fusion_service.dart';
import 'ontology_service.dart';
import 'curriculum_service.dart';
import 'educational_content_service.dart';
import 'personalized_learning_service.dart' as personalized;
import '../../models/service_models.dart' as models;

/// Main orchestrator for AI Tutor functionality
class AITutorOrchestrator {
  static final AITutorOrchestrator _instance = AITutorOrchestrator._internal();
  factory AITutorOrchestrator() => _instance;
  AITutorOrchestrator._internal();

  // Service instances
  late final predictive.PredictiveAnalyticsService _predictiveAnalytics;
  late final pattern.LearningPatternAnalyzer _patternAnalyzer;
  late final CognitiveLoadMonitor _cognitiveMonitor;
  late final AttentionTrackingService _attentionTracker;
  late final mistake.MistakePatternService _mistakeAnalyzer;
  late final session.SessionFeedbackService _sessionFeedback;
  late final progress.ProgressVisualizationService _progressVisualizer;
  late final achievement.AchievementTrackingService _achievementTracker;
  late final LearningJournalService _journalService;
  late final difficulty.ProblemDifficultyAnalyzer _difficultyAnalyzer;
  late final solution.SolutionQualityEvaluator _solutionEvaluator;
  late final AdaptiveAssessmentEngine _assessmentEngine;
  late final metrics.PerformanceMetricsCalculator _metricsCalculator;
  late final notification.SmartNotificationService _notificationService;
  late final nudge.BehavioralNudgeEngine _nudgeEngine;
  late final motivation.MotivationalMessageGenerator _messageGenerator;
  late final timing.InterventionTimingOptimizer _timingOptimizer;
  late final DataFusionService _dataFusion;
  late final OntologyService _ontologyService;
  late final CurriculumService _curriculumService;
  late final EducationalContentService _contentService;
  late final personalized.PersonalizedLearningService _personalizedLearning;

  // Orchestration state
  final Map<String, TutorSession> _activeSessions = {};
  final Map<String, StreamController<TutorEvent>> _eventStreams = {};
  final Map<String, LearnerProfile> _learnerProfiles = {};

  /// Initialize the AI Tutor orchestrator
  Future<void> initialize() async {
    try {
      safePrint('Initializing AI Tutor Orchestrator...');
      
      // Initialize all services
      await _initializeServices();
      
      // Set up service interconnections
      await _setupServiceConnections();
      
      // Load ML models
      await _loadMLModels();
      
      // Start background monitoring
      _startBackgroundMonitoring();
      
      safePrint('AI Tutor Orchestrator initialized successfully');
    } catch (e) {
      safePrint('Error initializing AI Tutor Orchestrator: $e');
      rethrow;
    }
  }

  /// Start AI tutoring session
  Future<TutorSession> startTutoringSession({
    required String userId,
    required String subject,
    TutoringMode mode = TutoringMode.adaptive,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      // Create session ID
      final sessionId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Get or create learner profile
      final profile = await _getOrCreateLearnerProfile(userId);
      
      // Create learning context
      final context = await _dataFusion.createLearningContext(
        userId: userId,
        ref: null, // Pass actual ref in production
      );
      
      // Initialize session
      final session = TutorSession(
        id: sessionId,
        userId: userId,
        subject: subject,
        mode: mode,
        startTime: DateTime.now(),
        profile: profile,
        context: context,
        preferences: preferences ?? {},
      );
      
      _activeSessions[sessionId] = session;
      _eventStreams[sessionId] = StreamController<TutorEvent>.broadcast();
      
      // Start session services
      await _startSessionServices(session);
      
      // Generate welcome message
      final welcomeMessage = await _generateWelcomeMessage(session);
      _emitEvent(sessionId, TutorEvent(
        type: TutorEventType.message,
        data: welcomeMessage,
      ));
      
      return session;
    } catch (e) {
      safePrint('Error starting tutoring session: $e');
      rethrow;
    }
  }

  /// Process user input and generate AI response
  Future<TutorResponse> processUserInput({
    required String sessionId,
    required UserInput input,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) {
        throw Exception('Session not found');
      }

      // Update attention tracking
      await _attentionTracker.recordEvent(
        userId: session.userId,
        type: AttentionEventType.interaction,
      );

      // Analyze input type
      final inputAnalysis = await _analyzeUserInput(input, session);

      // Route to appropriate handler
      TutorResponse response;
      switch (inputAnalysis.primaryIntent) {
        case UserIntent.askQuestion:
          response = await _handleQuestion(input, session, inputAnalysis);
          break;
        case UserIntent.submitSolution:
          response = await _handleSolutionSubmission(input, session, inputAnalysis);
          break;
        case UserIntent.requestHelp:
          response = await _handleHelpRequest(input, session, inputAnalysis);
          break;
        case UserIntent.provideFeedback:
          response = await _handleFeedback(input, session, inputAnalysis);
          break;
        default:
          response = await _handleGeneralInput(input, session, inputAnalysis);
      }

      // Update session context
      await _updateSessionContext(session, input, response);

      // Check for intervention opportunities
      await _checkInterventionOpportunities(session);

      return response;
    } catch (e) {
      safePrint('Error processing user input: $e');
      return TutorResponse(
        type: ResponseType.error,
        content: '죄송합니다. 요청을 처리하는 중 오류가 발생했습니다.',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Get real-time tutoring insights
  Stream<TutoringInsight> getTutoringInsights(String sessionId) {
    final controller = StreamController<TutoringInsight>.broadcast();
    
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final session = _activeSessions[sessionId];
      if (session == null) {
        timer.cancel();
        return;
      }

      try {
        // Gather insights from various services
        final cognitiveLoad = await _cognitiveMonitor.getCognitiveLoadState(session.userId);
        final attention = await _attentionTracker.getCurrentAttentionState(session.userId);
        final patterns = await _patternAnalyzer.getRecentPatterns(
          userId: session.userId,
          subject: session.subject,
        );

        // Generate composite insight
        final insight = TutoringInsight(
          sessionId: sessionId,
          timestamp: DateTime.now(),
          cognitiveLoad: cognitiveLoad.currentLoad,
          attentionLevel: attention.currentFocus,
          learningVelocity: patterns.velocity,
          recommendations: await _generateInsightRecommendations(
            session: session,
            cognitiveLoad: cognitiveLoad,
            attention: attention,
            patterns: patterns,
          ),
        );

        controller.add(insight);
      } catch (e) {
        safePrint('Error generating tutoring insights: $e');
      }
    });

    return controller.stream;
  }

  /// Generate personalized learning path
  Future<LearningPath> generateLearningPath({
    required String userId,
    required String subject,
    required LearningGoal goal,
    Duration? timeframe,
  }) async {
    try {
      // Get learner profile
      final profile = await _getOrCreateLearnerProfile(userId);
      
      // Get current knowledge state
      final knowledgeState = await _assessCurrentKnowledge(userId, subject);
      
      // Get curriculum structure
      final curriculum = await _curriculumService.getCurriculumStructure(
        subject: subject,
        level: profile.academicLevel,
      );
      
      // Generate path using ontology
      final ontologyPath = await _ontologyService.generateLearningPath(
        currentKnowledge: knowledgeState,
        targetGoal: goal,
        curriculum: curriculum,
      );
      
      // Personalize the path
      final personalizedPath = await _personalizedLearning.personalizePath(
        userId: userId,
        basePath: ontologyPath,
        timeframe: timeframe,
        preferences: profile.preferences,
      );
      
      // Add milestones and checkpoints
      final enrichedPath = await _enrichLearningPath(
        path: personalizedPath,
        userId: userId,
        goal: goal,
      );
      
      return enrichedPath;
    } catch (e) {
      safePrint('Error generating learning path: $e');
      rethrow;
    }
  }

  /// Provide adaptive problem recommendation
  Future<ProblemRecommendation> recommendNextProblem({
    required String sessionId,
    ProblemConstraints? constraints,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) {
        throw Exception('Session not found');
      }

      // Get current ability estimate
      final ability = await _assessmentEngine.getCurrentAbilityEstimate(
        userId: session.userId,
        subject: session.subject,
      );

      // Calculate optimal difficulty
      final optimalDifficulty = await _difficultyAnalyzer.calculateOptimalDifficulty(
        userId: session.userId,
        abilityProfile: ability,
        subject: session.subject,
      );

      // Get available problems
      final availableProblems = await _contentService.getProblems(
        subject: session.subject,
        difficultyRange: optimalDifficulty,
        constraints: constraints,
      );

      // Recommend problems
      final recommendations = await _difficultyAnalyzer.recommendProblems(
        userId: session.userId,
        subject: session.subject,
        difficultyRange: optimalDifficulty,
        availableProblems: availableProblems,
        count: 3,
      );

      // Select best recommendation
      final selected = recommendations.first;

      // Generate context and hints
      final context = await _generateProblemContext(selected.problem, session);
      final hints = await _generateAdaptiveHints(selected.problem, session);

      return ProblemRecommendation(
        problem: selected.problem,
        difficulty: selected.difficulty,
        estimatedSuccessProbability: selected.estimatedSuccessProbability,
        reasons: selected.reasons,
        context: context,
        adaptiveHints: hints,
      );
    } catch (e) {
      safePrint('Error recommending problem: $e');
      rethrow;
    }
  }

  /// Generate comprehensive learning report
  Future<LearningReport> generateLearningReport({
    required String userId,
    required DateTimeRange period,
    List<String>? subjects,
  }) async {
    try {
      // Gather data from all services
      final sessions = await _sessionFeedback.getSessionHistory(
        userId: userId,
        period: period,
      );

      final assessments = await _assessmentEngine.getAssessmentHistory(
        userId: userId,
        period: period,
      );

      final achievements = await _achievementTracker.getAchievements(
        userId: userId,
        period: period,
      );

      final journalEntries = await _journalService.getEntries(
        userId: userId,
        startDate: period.start,
        endDate: period.end,
      );

      // Calculate comprehensive metrics
      final metrics = await _metricsCalculator.calculateMetrics(
        userId: userId,
        subject: 'all',
        sessions: sessions,
        assessments: assessments,
      );

      // Analyze patterns
      final patterns = await _patternAnalyzer.analyzeComprehensivePatterns(
        userId: userId,
        period: period,
      ) as ComprehensivePatterns;

      // Generate visualizations
      final visualizations = await _progressVisualizer.generateProgressDashboard(
        userId: userId,
        period: period,
        subjects: subjects,
      );

      // Create insights and recommendations
      final insights = await _generateComprehensiveInsights(
        metrics: metrics,
        patterns: patterns,
        achievements: achievements,
      );

      final recommendations = await _generateLearningRecommendations(
        userId: userId,
        metrics: metrics,
        patterns: patterns,
      );

      return LearningReport(
        userId: userId,
        period: period,
        metrics: metrics,
        patterns: patterns,
        achievements: achievements,
        journalSummary: _summarizeJournalEntries(journalEntries),
        visualizations: visualizations,
        insights: insights,
        recommendations: recommendations,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error generating learning report: $e');
      rethrow;
    }
  }

  /// Trigger smart intervention
  Future<void> triggerSmartIntervention({
    required String userId,
    required InterventionTrigger trigger,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Calculate optimal timing
      final timing = await _timingOptimizer.calculateOptimalTiming(
        userId: userId,
        type: _mapTriggerToInterventionType(trigger),
        context: InterventionContext(data: context ?? {}),
      );

      // Generate intervention content
      InterventionContent content;
      switch (trigger) {
        case InterventionTrigger.lowMotivation:
          content = await _generateMotivationalIntervention(userId, context);
          break;
        case InterventionTrigger.highCognitiveLoad:
          content = await _generateCognitiveLoadIntervention(userId, context);
          break;
        case InterventionTrigger.struggleDetected:
          content = await _generateStruggleIntervention(userId, context);
          break;
        case InterventionTrigger.achievementUnlocked:
          content = await _generateAchievementIntervention(userId, context);
          break;
        default:
          content = await _generateGeneralIntervention(userId, context);
      }

      // Schedule intervention
      await _timingOptimizer.scheduleIntervention(
        userId: userId,
        intervention: Intervention(
          type: content.type,
          content: content.message,
          context: InterventionContext(data: context ?? {}),
        ),
      );

      // Track intervention
      await _trackIntervention(
        userId: userId,
        trigger: trigger,
        content: content,
        timing: timing,
      );
    } catch (e) {
      safePrint('Error triggering smart intervention: $e');
    }
  }

  /// End tutoring session
  Future<SessionSummary> endTutoringSession(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) {
        throw Exception('Session not found');
      }

      session.endTime = DateTime.now();

      // Generate session summary
      final summary = await _generateSessionSummary(session);

      // Record session feedback
      await _sessionFeedback.endSession(
        sessionId: sessionId,
        summary: summary,
      );

      // Update learner profile
      await _updateLearnerProfile(session, summary);

      // Clean up session
      _activeSessions.remove(sessionId);
      _eventStreams[sessionId]?.close();
      _eventStreams.remove(sessionId);

      // Schedule follow-up if needed
      await _scheduleFollowUp(session, summary);

      return summary;
    } catch (e) {
      safePrint('Error ending tutoring session: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _initializeServices() async {
    _predictiveAnalytics = predictive.PredictiveAnalyticsService();
    _patternAnalyzer = pattern.LearningPatternAnalyzer();
    _cognitiveMonitor = CognitiveLoadMonitor();
    _attentionTracker = AttentionTrackingService();
    _mistakeAnalyzer = mistake.MistakePatternService();
    _sessionFeedback = session.SessionFeedbackService();
    _progressVisualizer = progress.ProgressVisualizationService();
    _achievementTracker = achievement.AchievementTrackingService();
    _journalService = LearningJournalService();
    _difficultyAnalyzer = difficulty.ProblemDifficultyAnalyzer();
    _solutionEvaluator = solution.SolutionQualityEvaluator();
    _assessmentEngine = AdaptiveAssessmentEngine();
    _metricsCalculator = metrics.PerformanceMetricsCalculator();
    _notificationService = notification.SmartNotificationService();
    _nudgeEngine = nudge.BehavioralNudgeEngine();
    _messageGenerator = motivation.MotivationalMessageGenerator();
    _timingOptimizer = timing.InterventionTimingOptimizer();
    _dataFusion = DataFusionService();
    _ontologyService = OntologyService();
    _curriculumService = CurriculumService();
    _contentService = EducationalContentService();
    _personalizedLearning = personalized.PersonalizedLearningService();

    // Initialize each service
    await Future.wait([
      _notificationService.initialize(),
      _nudgeEngine.initialize(),
      _messageGenerator.initialize(),
      _timingOptimizer.initialize(),
      _achievementTracker.initialize(),
    ]);
  }

  Future<void> _setupServiceConnections() async {
    // Set up inter-service communications
    // For example, connect pattern analyzer to cognitive monitor
  }

  Future<void> _loadMLModels() async {
    // Load pre-trained ML models
  }

  void _startBackgroundMonitoring() {
    // Start periodic background tasks
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      for (final session in _activeSessions.values) {
        await _performBackgroundChecks(session);
      }
    });
  }

  Future<LearnerProfile> _getOrCreateLearnerProfile(String userId) async {
    if (_learnerProfiles.containsKey(userId)) {
      return _learnerProfiles[userId]!;
    }

    // Create new profile
    final profile = LearnerProfile(
      userId: userId,
      academicLevel: AcademicLevel.highSchool,
      learningStyle: LearningStyle.visual,
      preferences: {},
      strengths: [],
      weaknesses: [],
      createdAt: DateTime.now(),
    );

    _learnerProfiles[userId] = profile;
    return profile;
  }

  Future<void> _startSessionServices(TutorSession session) async {
    // Start cognitive monitoring
    _cognitiveMonitor.startMonitoring(session.userId);
    
    // Start attention tracking
    _attentionTracker.startTracking(session.userId);
    
    // Start session recording
    await _sessionFeedback.startSession(
      userId: session.userId,
      subject: session.subject,
      topics: [],
      goals: SessionGoals(
        primary: '효과적인 학습',
        secondary: [],
      ),
    );
  }

  Future<WelcomeMessage> _generateWelcomeMessage(TutorSession session) async {
    final message = await _messageGenerator.generateMessage(
      userId: session.userId,
      context: MessageContext(
        trigger: MessageTrigger.scheduled,
        variables: {
          'subject': session.subject,
          'mode': session.mode.toString(),
        },
      ),
    );

    return WelcomeMessage(
      content: message.content,
      personalizedGreeting: '안녕하세요! ${session.subject} 학습을 시작해볼까요?',
      suggestedActions: [
        '오늘의 학습 목표 설정하기',
        '이전 학습 내용 복습하기',
        '새로운 주제 탐색하기',
      ],
    );
  }

  void _emitEvent(String sessionId, TutorEvent event) {
    _eventStreams[sessionId]?.add(event);
  }

  Future<InputAnalysis> _analyzeUserInput(
    UserInput input,
    TutorSession session,
  ) async {
    // Analyze user input to determine intent and context
    return InputAnalysis(
      primaryIntent: UserIntent.askQuestion,
      confidence: 0.85,
      entities: [],
      sentiment: 0.7,
    );
  }

  Future<TutorResponse> _handleQuestion(
    UserInput input,
    TutorSession session,
    InputAnalysis analysis,
  ) async {
    // Handle question-type input
    return TutorResponse(
      type: ResponseType.explanation,
      content: '좋은 질문입니다! 설명해드리겠습니다...',
      metadata: {},
    );
  }

  Future<TutorResponse> _handleSolutionSubmission(
    UserInput input,
    TutorSession session,
    InputAnalysis analysis,
  ) async {
    // Evaluate submitted solution
    final evaluation = await _solutionEvaluator.evaluateSolution(
      problemId: input.metadata?['problemId'] ?? '',
      solution: Solution(
        id: 'sol_${DateTime.now().millisecondsSinceEpoch}',
        problemId: input.metadata?['problemId'] ?? '',
        content: input.content,
        problemType: 'math',
        subject: session.subject,
        submittedAt: DateTime.now(),
      ),
      context: mistake.ProblemContext(
        problemType: 'math',
        subject: session.subject,
      ),
    );

    return TutorResponse(
      type: ResponseType.feedback,
      content: evaluation.detailedFeedback.overallComments.join('\n'),
      metadata: {
        'evaluation': evaluation,
      },
    );
  }

  Future<TutorResponse> _handleHelpRequest(
    UserInput input,
    TutorSession session,
    InputAnalysis analysis,
  ) async {
    // Generate helpful hints
    final hints = await _solutionEvaluator.generateHints(
      currentSolution: input.content,
      problem: difficulty.Problem(
        id: input.metadata?['problemId'] ?? '',
        type: 'current',
        content: '',
        concepts: [],
      ),
      hintsRequested: 1,
    );

    return TutorResponse(
      type: ResponseType.hint,
      content: hints.isNotEmpty ? hints.first.content : '단계별로 접근해보세요.',
      metadata: {
        'hints': hints,
      },
    );
  }

  Future<TutorResponse> _handleFeedback(
    UserInput input,
    TutorSession session,
    InputAnalysis analysis,
  ) async {
    // Process user feedback
    return TutorResponse(
      type: ResponseType.acknowledgment,
      content: '피드백 감사합니다! 더 나은 학습 경험을 위해 반영하겠습니다.',
      metadata: {},
    );
  }

  Future<TutorResponse> _handleGeneralInput(
    UserInput input,
    TutorSession session,
    InputAnalysis analysis,
  ) async {
    // Handle general conversation
    return TutorResponse(
      type: ResponseType.conversation,
      content: '네, 이해했습니다. 계속 진행해주세요.',
      metadata: {},
    );
  }

  Future<void> _updateSessionContext(
    TutorSession session,
    UserInput input,
    TutorResponse response,
  ) async {
    // Update session context with new interaction
    session.interactionCount++;
    session.lastInteraction = DateTime.now();
  }

  Future<void> _checkInterventionOpportunities(TutorSession session) async {
    // Monitor for intervention opportunities
    final cognitiveState = await _cognitiveMonitor.getCognitiveLoadState(session.userId);
    
    if (cognitiveState.currentLoad > 0.8) {
      await triggerSmartIntervention(
        userId: session.userId,
        trigger: InterventionTrigger.highCognitiveLoad,
        context: {
          'load': cognitiveState.currentLoad,
          'subject': session.subject,
        },
      );
    }
  }

  Future<void> _performBackgroundChecks(TutorSession session) async {
    // Perform periodic background checks
    try {
      // Check attention levels
      final attentionState = await _attentionTracker.getCurrentAttentionState(
        session.userId,
      );
      
      if (attentionState.currentFocus < 0.5) {
        await _nudgeEngine.triggerContextualNudge(
          userId: session.userId,
          event: TriggerEvent.inactivity,
        );
      }
    } catch (e) {
      safePrint('Error in background checks: $e');
    }
  }

  Future<List<String>> _generateInsightRecommendations({
    required TutorSession session,
    required CognitiveLoadState cognitiveLoad,
    required AttentionState attention,
    required RecentPatterns patterns,
  }) async {
    final recommendations = <String>[];

    if (cognitiveLoad.currentLoad > 0.7) {
      recommendations.add('인지 부하가 높습니다. 잠시 휴식을 취하는 것이 좋겠습니다.');
    }

    if (attention.currentFocus < 0.6) {
      recommendations.add('집중력이 떨어지고 있습니다. 짧은 휴식 후 다시 시작해보세요.');
    }

    if (patterns.velocity < 0.5) {
      recommendations.add('학습 속도가 느려지고 있습니다. 난이도를 조정해보는 것은 어떨까요?');
    }

    return recommendations;
  }

  Future<KnowledgeState> _assessCurrentKnowledge(
    String userId,
    String subject,
  ) async {
    // Assess current knowledge state
    return KnowledgeState(
      userId: userId,
      subject: subject,
      masteredConcepts: [],
      partialConcepts: [],
      unknownConcepts: [],
    );
  }

  Future<LearningPath> _enrichLearningPath({
    required LearningPath path,
    required String userId,
    required LearningGoal goal,
  }) async {
    // Add milestones, checkpoints, and estimates
    return path;
  }

  Future<String> _generateProblemContext(
    difficulty.Problem problem,
    TutorSession session,
  ) async {
    // Generate contextual information for problem
    return '이 문제는 ${problem.concepts.join(", ")} 개념을 다룹니다.';
  }

  Future<List<AdaptiveHint>> _generateAdaptiveHints(
    difficulty.Problem problem,
    TutorSession session,
  ) async {
    // Generate adaptive hints based on user profile
    return [
      AdaptiveHint(
        level: 1,
        content: '문제를 단계별로 나누어 생각해보세요.',
        triggerCondition: 'After 2 minutes',
      ),
      AdaptiveHint(
        level: 2,
        content: '핵심 개념을 다시 확인해보세요.',
        triggerCondition: 'After 5 minutes',
      ),
    ];
  }

  String _summarizeJournalEntries(List<JournalEntry> entries) {
    if (entries.isEmpty) return '학습 일지가 없습니다.';
    
    return '${entries.length}개의 학습 일지가 작성되었습니다. '
           '주요 주제: ${entries.map((e) => e.tags).expand((t) => t).toSet().join(", ")}';
  }

  Future<List<String>> _generateComprehensiveInsights({
    required models.PerformanceMetrics metrics,
    required ComprehensivePatterns patterns,
    required List<models.ServiceAchievement> achievements,
  }) async {
    final insights = <String>[];

    // Performance insights
    if (metrics.basicMetrics.averageAccuracy > 0.8) {
      insights.add('뛰어난 정확도를 유지하고 있습니다!');
    }

    // Pattern insights
    if (patterns.hasConsistentSchedule) {
      insights.add('규칙적인 학습 패턴이 좋은 성과로 이어지고 있습니다.');
    }

    // Achievement insights
    if (achievements.length > 5) {
      insights.add('다양한 성취를 이루고 있습니다. 계속 이 추세를 유지하세요!');
    }

    return insights;
  }

  Future<List<String>> _generateLearningRecommendations({
    required String userId,
    required models.PerformanceMetrics metrics,
    required ComprehensivePatterns patterns,
  }) async {
    final recommendations = <String>[];

    // Based on metrics
    if (metrics.efficiencyMetrics.learningVelocity < 0.5) {
      recommendations.add('학습 속도를 높이기 위해 더 집중된 세션을 시도해보세요.');
    }

    // Based on patterns
    if (!patterns.hasConsistentSchedule) {
      recommendations.add('일정한 학습 스케줄을 만들어보세요.');
    }

    return recommendations;
  }

  timing.InterventionType _mapTriggerToInterventionType(InterventionTrigger trigger) {
    switch (trigger) {
      case InterventionTrigger.lowMotivation:
        return timing.InterventionType.motivational;
      case InterventionTrigger.highCognitiveLoad:
        return timing.InterventionType.break_;
      case InterventionTrigger.struggleDetected:
        return timing.InterventionType.educational;
      case InterventionTrigger.achievementUnlocked:
        return timing.InterventionType.reward;
      default:
        return timing.InterventionType.general;
    }
  }

  Future<InterventionContent> _generateMotivationalIntervention(
    String userId,
    Map<String, dynamic>? context,
  ) async {
    final message = await _messageGenerator.generateMessage(
      userId: userId,
      context: MessageContext(
        trigger: MessageTrigger.scheduled,
        variables: context ?? {},
      ),
      preferredTone: MessageTone.encouraging,
    );

    return InterventionContent(
      type: timing.InterventionType.motivational,
      message: message.content,
      visual: '💪',
    );
  }

  Future<InterventionContent> _generateCognitiveLoadIntervention(
    String userId,
    Map<String, dynamic>? context,
  ) async {
    return InterventionContent(
      type: timing.InterventionType.break_,
      message: '인지 부하가 높아 보입니다. 5분간 휴식을 취하는 것을 권장합니다.',
      visual: '🧘',
    );
  }

  Future<InterventionContent> _generateStruggleIntervention(
    String userId,
    Map<String, dynamic>? context,
  ) async {
    final encouragement = await _messageGenerator.generateEncouragement(
      userId: userId,
      struggle: StruggleContext(
        area: context?['area'] ?? 'current topic',
        type: StruggleType.conceptual,
        duration: const Duration(minutes: 10),
        intensity: 0.7,
      ),
    );

    return InterventionContent(
      type: timing.InterventionType.educational,
      message: encouragement.coreMessage,
      visual: '🤔',
      additionalContent: encouragement.practicalSuggestions,
    );
  }

  Future<InterventionContent> _generateAchievementIntervention(
    String userId,
    Map<String, dynamic>? context,
  ) async {
    final celebration = await _messageGenerator.generateCelebrationMessage(
      userId: userId,
      achievement: models.ServiceAchievement(
        id: context?['achievementId'] ?? '',
        name: context?['achievementName'] ?? '새로운 성취',
        description: '',
        rarity: models.AchievementRarity.rare,
        firstTime: true,
        percentile: 90.0,
      ),
    );

    return InterventionContent(
      type: timing.InterventionType.reward,
      message: celebration.content,
      visual: celebration.visuals.emoji,
    );
  }

  Future<InterventionContent> _generateGeneralIntervention(
    String userId,
    Map<String, dynamic>? context,
  ) async {
    return InterventionContent(
      type: timing.InterventionType.general,
      message: '학습을 계속 진행해주세요. 도움이 필요하면 언제든 말씀해주세요.',
      visual: '📚',
    );
  }

  Future<void> _trackIntervention({
    required String userId,
    required InterventionTrigger trigger,
    required InterventionContent content,
    required OptimalTiming timing,
  }) async {
    // Track intervention for analytics
    safePrint('Intervention tracked: $trigger at ${timing.recommendedTime}');
  }

  Future<SessionSummary> _generateSessionSummary(TutorSession session) async {
    final duration = session.endTime!.difference(session.startTime);
    
    // Get session metrics
    final metrics = await _sessionFeedback.getSessionMetrics(session.id);
    
    // Get achievements during session
    final achievements = await _achievementTracker.getSessionAchievements(
      userId: session.userId,
      sessionId: session.id,
    );
    
    // Get key learning points
    final keyPoints = await _extractKeyLearningPoints(session);
    
    return SessionSummary(
      sessionId: session.id,
      duration: duration,
      topicsCoered: session.topicsCovered,
      problemsSolved: session.problemsSolved,
      accuracy: metrics?.accuracy ?? 0.0,
      achievements: achievements,
      keyLearningPoints: keyPoints,
      recommendations: await _generateSessionRecommendations(session, metrics),
    );
  }

  Future<void> _updateLearnerProfile(
    TutorSession session,
    SessionSummary summary,
  ) async {
    final profile = _learnerProfiles[session.userId];
    if (profile != null) {
      // Update profile based on session performance
      profile.totalSessions++;
      profile.totalStudyTime += summary.duration;
      profile.lastSessionAt = DateTime.now();
    }
  }

  Future<void> _scheduleFollowUp(
    TutorSession session,
    SessionSummary summary,
  ) async {
    // Schedule follow-up reminders or reviews
    if (summary.accuracy < 0.7) {
      await _notificationService.scheduleSmartNotification(
        userId: session.userId,
        type: NotificationType.reminder,
        title: '복습 시간입니다',
        body: '이전 학습 내용을 복습해보는 것은 어떨까요?',
        scheduledTime: DateTime.now().add(const Duration(days: 1)),
      );
    }
  }

  Future<List<String>> _extractKeyLearningPoints(TutorSession session) async {
    // Extract key learning points from session
    return [
      '핵심 개념을 이해했습니다',
      '문제 해결 능력이 향상되었습니다',
    ];
  }

  Future<List<String>> _generateSessionRecommendations(
    TutorSession session,
    SessionMetrics? metrics,
  ) async {
    final recommendations = <String>[];
    
    if (metrics != null && metrics.accuracy < 0.7) {
      recommendations.add('기초 개념을 다시 복습해보세요');
    }
    
    if (session.problemsSolved < 5) {
      recommendations.add('더 많은 연습 문제를 풀어보세요');
    }
    
    return recommendations;
  }
}

// Data models
class TutorSession {
  final String id;
  final String userId;
  final String subject;
  final TutoringMode mode;
  final DateTime startTime;
  DateTime? endTime;
  final LearnerProfile profile;
  final LearningContext context;
  final Map<String, dynamic> preferences;
  
  // Session state
  int interactionCount = 0;
  DateTime? lastInteraction;
  List<String> topicsCovered = [];
  int problemsSolved = 0;

  TutorSession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.mode,
    required this.startTime,
    this.endTime,
    required this.profile,
    required this.context,
    required this.preferences,
  });
}

class LearnerProfile {
  final String userId;
  final AcademicLevel academicLevel;
  final LearningStyle learningStyle;
  final Map<String, dynamic> preferences;
  final List<String> strengths;
  final List<String> weaknesses;
  final DateTime createdAt;
  
  // Profile statistics
  int totalSessions = 0;
  Duration totalStudyTime = Duration.zero;
  DateTime? lastSessionAt;

  LearnerProfile({
    required this.userId,
    required this.academicLevel,
    required this.learningStyle,
    required this.preferences,
    required this.strengths,
    required this.weaknesses,
    required this.createdAt,
  });
}

class TutorEvent {
  final TutorEventType type;
  final dynamic data;
  final DateTime timestamp;

  TutorEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class UserInput {
  final String content;
  final InputType type;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  UserInput({
    required this.content,
    required this.type,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class TutorResponse {
  final ResponseType type;
  final String content;
  final Map<String, dynamic> metadata;
  final List<String>? suggestions;
  final List<VisualElement>? visuals;

  TutorResponse({
    required this.type,
    required this.content,
    required this.metadata,
    this.suggestions,
    this.visuals,
  });
}

class TutoringInsight {
  final String sessionId;
  final DateTime timestamp;
  final double cognitiveLoad;
  final double attentionLevel;
  final double learningVelocity;
  final List<String> recommendations;

  TutoringInsight({
    required this.sessionId,
    required this.timestamp,
    required this.cognitiveLoad,
    required this.attentionLevel,
    required this.learningVelocity,
    required this.recommendations,
  });
}

class LearningPath {
  final String userId;
  final String subject;
  final LearningGoal goal;
  final List<LearningNode> nodes;
  final Map<String, List<String>> prerequisites;
  final Duration estimatedDuration;
  final List<Milestone> milestones;

  LearningPath({
    required this.userId,
    required this.subject,
    required this.goal,
    required this.nodes,
    required this.prerequisites,
    required this.estimatedDuration,
    required this.milestones,
  });
}

class LearningReport {
  final String userId;
  final DateTimeRange period;
  final models.PerformanceMetrics metrics;
  final ComprehensivePatterns patterns;
  final List<models.ServiceAchievement> achievements;
  final String journalSummary;
  final ProgressDashboard visualizations;
  final List<String> insights;
  final List<String> recommendations;
  final DateTime generatedAt;

  LearningReport({
    required this.userId,
    required this.period,
    required this.metrics,
    required this.patterns,
    required this.achievements,
    required this.journalSummary,
    required this.visualizations,
    required this.insights,
    required this.recommendations,
    required this.generatedAt,
  });
}

class SessionSummary {
  final String sessionId;
  final Duration duration;
  final List<String> topicsCoered;
  final int problemsSolved;
  final double accuracy;
  final List<models.ServiceAchievement> achievements;
  final List<String> keyLearningPoints;
  final List<String> recommendations;

  SessionSummary({
    required this.sessionId,
    required this.duration,
    required this.topicsCoered,
    required this.problemsSolved,
    required this.accuracy,
    required this.achievements,
    required this.keyLearningPoints,
    required this.recommendations,
  });
}

class InterventionContent {
  final timing.InterventionType type;
  final String message;
  final String visual;
  final List<String>? additionalContent;

  InterventionContent({
    required this.type,
    required this.message,
    required this.visual,
    this.additionalContent,
  });
}

// Supporting classes
class WelcomeMessage {
  final String content;
  final String personalizedGreeting;
  final List<String> suggestedActions;

  WelcomeMessage({
    required this.content,
    required this.personalizedGreeting,
    required this.suggestedActions,
  });
}

class InputAnalysis {
  final UserIntent primaryIntent;
  final double confidence;
  final List<String> entities;
  final double sentiment;

  InputAnalysis({
    required this.primaryIntent,
    required this.confidence,
    required this.entities,
    required this.sentiment,
  });
}

class CognitiveLoadState {
  final String userId;
  final double currentLoad;
  final double intrinsicLoad;
  final double extraneousLoad;
  final double germaneLoad;
  final DateTime timestamp;

  CognitiveLoadState({
    required this.userId,
    required this.currentLoad,
    required this.intrinsicLoad,
    required this.extraneousLoad,
    required this.germaneLoad,
    required this.timestamp,
  });
}

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

class RecentPatterns {
  final double velocity;
  final bool hasConsistentSchedule;

  RecentPatterns({
    required this.velocity,
    required this.hasConsistentSchedule,
  });
}

class KnowledgeState {
  final String userId;
  final String subject;
  final List<String> masteredConcepts;
  final List<String> partialConcepts;
  final List<String> unknownConcepts;

  KnowledgeState({
    required this.userId,
    required this.subject,
    required this.masteredConcepts,
    required this.partialConcepts,
    required this.unknownConcepts,
  });
}

class LearningGoal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final DateTime targetDate;

  LearningGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetDate,
  });
}

class ProblemConstraints {
  final List<String>? includeTopis;
  final List<String>? excludeTopics;
  final int? maxDifficulty;
  final Duration? timeLimit;

  ProblemConstraints({
    this.includeTopis,
    this.excludeTopics,
    this.maxDifficulty,
    this.timeLimit,
  });
}

class AdaptiveHint {
  final int level;
  final String content;
  final String triggerCondition;

  AdaptiveHint({
    required this.level,
    required this.content,
    required this.triggerCondition,
  });
}

class ComprehensivePatterns {
  final bool hasConsistentSchedule;
  final List<String> dominantLearningTimes;
  final Map<String, double> subjectPreferences;

  ComprehensivePatterns({
    required this.hasConsistentSchedule,
    required this.dominantLearningTimes,
    required this.subjectPreferences,
  });
}

class SessionMetrics {
  final double accuracy;
  final int problemsAttempted;
  final Duration averageResponseTime;

  SessionMetrics({
    required this.accuracy,
    required this.problemsAttempted,
    required this.averageResponseTime,
  });
}

class LearningNode {
  final String id;
  final String title;
  final String content;
  final List<String> concepts;
  final double estimatedTime;

  LearningNode({
    required this.id,
    required this.title,
    required this.content,
    required this.concepts,
    required this.estimatedTime,
  });
}

class VisualElement {
  final String type;
  final Map<String, dynamic> data;

  VisualElement({
    required this.type,
    required this.data,
  });
}

// Enums
enum TutoringMode {
  adaptive,
  guided,
  practice,
  assessment,
}

enum TutorEventType {
  message,
  hint,
  feedback,
  progress,
  achievement,
}

enum InputType {
  text,
  voice,
  drawing,
  selection,
}

enum ResponseType {
  explanation,
  hint,
  feedback,
  question,
  encouragement,
  correction,
  acknowledgment,
  conversation,
  error,
}

enum UserIntent {
  askQuestion,
  submitSolution,
  requestHelp,
  provideFeedback,
  navigate,
  general,
}

enum AcademicLevel {
  elementary,
  middleSchool,
  highSchool,
  university,
}

enum LearningStyle {
  visual,
  auditory,
  kinesthetic,
  readingWriting,
}

enum InterventionTrigger {
  lowMotivation,
  highCognitiveLoad,
  struggleDetected,
  achievementUnlocked,
  inactivity,
  scheduled,
}

enum GoalType {
  mastery,
  completion,
  improvement,
  exploration,
}

// Extension methods
extension AITutorOrchestratorExtensions on WidgetRef {
  AITutorOrchestrator get aiTutor => AITutorOrchestrator();
}