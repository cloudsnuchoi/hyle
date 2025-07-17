import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for adaptive assessment and testing
class AdaptiveAssessmentEngine {
  static final AdaptiveAssessmentEngine _instance = AdaptiveAssessmentEngine._internal();
  factory AdaptiveAssessmentEngine() => _instance;
  AdaptiveAssessmentEngine._internal();

  // Assessment configuration
  static const int _minQuestionsForReliableScore = 10;
  static const int _maxQuestionsPerSession = 50;
  static const double _stoppingThreshold = 0.95; // 95% confidence
  static const double _abilityChangeThreshold = 0.01;
  
  // Active assessments
  final Map<String, ActiveAssessment> _activeAssessments = {};
  final Map<String, StreamController<AssessmentUpdate>> _updateControllers = {};

  /// Start adaptive assessment session
  Future<AssessmentSession> startAssessment({
    required String userId,
    required String subject,
    required AssessmentType type,
    AssessmentConfig? config,
  }) async {
    try {
      final sessionId = '${userId}_${subject}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Initialize assessment configuration
      final assessmentConfig = config ?? AssessmentConfig.defaultConfig();
      
      // Get initial ability estimate
      final initialAbility = await _getInitialAbilityEstimate(userId, subject);
      
      // Create assessment session
      final session = AssessmentSession(
        id: sessionId,
        userId: userId,
        subject: subject,
        type: type,
        config: assessmentConfig,
        startTime: DateTime.now(),
        currentAbility: initialAbility,
        abilityHistory: [initialAbility],
        questions: [],
        responses: [],
        status: AssessmentStatus.active,
      );
      
      // Create active assessment
      _activeAssessments[sessionId] = ActiveAssessment(
        session: session,
        itemBank: await _loadItemBank(subject, type),
        theta: initialAbility.score,
        standardError: 1.0,
      );
      
      // Create update stream
      _updateControllers[sessionId] = StreamController<AssessmentUpdate>.broadcast();
      
      // Select first question
      final firstQuestion = await _selectNextQuestion(sessionId);
      session.questions.add(firstQuestion);
      
      // Emit update
      _emitUpdate(sessionId, AssessmentUpdate(
        type: UpdateType.questionSelected,
        question: firstQuestion,
        sessionStatus: session.status,
      ));
      
      return session;
    } catch (e) {
      safePrint('Error starting assessment: $e');
      rethrow;
    }
  }

  /// Submit response to current question
  Future<ResponseResult> submitResponse({
    required String sessionId,
    required String questionId,
    required String response,
    required int timeSpent,
  }) async {
    try {
      final activeAssessment = _activeAssessments[sessionId];
      if (activeAssessment == null) {
        throw Exception('Assessment session not found');
      }
      
      final session = activeAssessment.session;
      final question = session.questions.lastWhere((q) => q.id == questionId);
      
      // Evaluate response
      final isCorrect = await _evaluateResponse(question, response);
      
      // Create response record
      final responseRecord = QuestionResponse(
        questionId: questionId,
        response: response,
        isCorrect: isCorrect,
        timeSpent: timeSpent,
        timestamp: DateTime.now(),
      );
      
      session.responses.add(responseRecord);
      
      // Update ability estimate using IRT
      final newAbility = _updateAbilityEstimate(
        currentTheta: activeAssessment.theta,
        responses: session.responses,
        questions: session.questions,
      );
      
      activeAssessment.theta = newAbility.theta;
      activeAssessment.standardError = newAbility.standardError;
      
      // Update session ability
      session.currentAbility = AbilityEstimate(
        score: newAbility.theta,
        confidence: 1 - newAbility.standardError,
        standardError: newAbility.standardError,
      );
      session.abilityHistory.add(session.currentAbility);
      
      // Check stopping criteria
      final shouldStop = _checkStoppingCriteria(activeAssessment);
      
      ResponseResult result;
      
      if (shouldStop) {
        // Finalize assessment
        result = await _finalizeAssessment(sessionId);
      } else {
        // Select next question
        final nextQuestion = await _selectNextQuestion(sessionId);
        session.questions.add(nextQuestion);
        
        result = ResponseResult(
          isCorrect: isCorrect,
          feedback: _generateImmediateFeedback(question, isCorrect),
          currentAbility: session.currentAbility,
          nextQuestion: nextQuestion,
          progress: _calculateProgress(session),
        );
        
        // Emit update
        _emitUpdate(sessionId, AssessmentUpdate(
          type: UpdateType.responseSubmitted,
          response: responseRecord,
          newAbility: session.currentAbility,
          question: nextQuestion,
          sessionStatus: session.status,
        ));
      }
      
      return result;
    } catch (e) {
      safePrint('Error submitting response: $e');
      rethrow;
    }
  }

  /// Get current assessment status
  Future<AssessmentStatus> getAssessmentStatus(String sessionId) async {
    final activeAssessment = _activeAssessments[sessionId];
    if (activeAssessment == null) {
      throw Exception('Assessment session not found');
    }
    
    return activeAssessment.session.status;
  }

  /// Generate diagnostic report
  Future<DiagnosticReport> generateDiagnosticReport({
    required String sessionId,
  }) async {
    try {
      final activeAssessment = _activeAssessments[sessionId];
      if (activeAssessment == null) {
        throw Exception('Assessment session not found');
      }
      
      final session = activeAssessment.session;
      
      // Analyze performance by topic
      final topicAnalysis = _analyzeTopicPerformance(session);
      
      // Identify strengths and weaknesses
      final strengths = _identifyStrengths(topicAnalysis);
      final weaknesses = _identifyWeaknesses(topicAnalysis);
      
      // Analyze response patterns
      final patterns = _analyzeResponsePatterns(session);
      
      // Generate skill profile
      final skillProfile = _generateSkillProfile(session, topicAnalysis);
      
      // Create learning recommendations
      final recommendations = await _generateLearningRecommendations(
        weaknesses: weaknesses,
        patterns: patterns,
        currentAbility: session.currentAbility,
      );
      
      // Calculate reliability metrics
      final reliability = _calculateReliability(session);
      
      // Generate insights
      final insights = _generateDiagnosticInsights(
        session: session,
        topicAnalysis: topicAnalysis,
        patterns: patterns,
      );
      
      return DiagnosticReport(
        sessionId: sessionId,
        userId: session.userId,
        subject: session.subject,
        overallAbility: session.currentAbility,
        topicAnalysis: topicAnalysis,
        strengths: strengths,
        weaknesses: weaknesses,
        responsePatterns: patterns,
        skillProfile: skillProfile,
        recommendations: recommendations,
        reliability: reliability,
        insights: insights,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error generating diagnostic report: $e');
      rethrow;
    }
  }

  /// Create custom assessment
  Future<CustomAssessment> createCustomAssessment({
    required String userId,
    required List<String> topics,
    required DifficultyRange difficultyRange,
    required int questionCount,
    AssessmentConstraints? constraints,
  }) async {
    try {
      // Load questions for specified topics
      final availableQuestions = await _loadQuestionsForTopics(topics);
      
      // Filter by difficulty range
      final filteredQuestions = availableQuestions.where((q) =>
        q.difficulty >= difficultyRange.min &&
        q.difficulty <= difficultyRange.max
      ).toList();
      
      // Apply constraints if provided
      if (constraints != null) {
        _applyConstraints(filteredQuestions, constraints);
      }
      
      // Select questions using stratified sampling
      final selectedQuestions = _stratifiedQuestionSelection(
        questions: filteredQuestions,
        count: questionCount,
        topics: topics,
      );
      
      // Create assessment blueprint
      final blueprint = AssessmentBlueprint(
        topics: topics,
        questionDistribution: _calculateQuestionDistribution(selectedQuestions),
        difficultyDistribution: _calculateDifficultyDistribution(selectedQuestions),
        estimatedDuration: _estimateDuration(selectedQuestions),
      );
      
      return CustomAssessment(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        questions: selectedQuestions,
        blueprint: blueprint,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error creating custom assessment: $e');
      rethrow;
    }
  }

  /// Analyze assessment performance
  Future<PerformanceAnalysis> analyzePerformance({
    required String userId,
    required String subject,
    required DateTimeRange period,
  }) async {
    try {
      // Fetch assessment history
      final assessments = await _fetchAssessmentHistory(
        userId: userId,
        subject: subject,
        period: period,
      );
      
      if (assessments.isEmpty) {
        return PerformanceAnalysis.empty(userId: userId, subject: subject);
      }
      
      // Track ability progression
      final abilityProgression = _trackAbilityProgression(assessments);
      
      // Analyze consistency
      final consistency = _analyzeConsistency(assessments);
      
      // Identify improvement areas
      final improvementAreas = _identifyImprovementAreas(assessments);
      
      // Calculate growth metrics
      final growth = _calculateGrowthMetrics(
        startAbility: assessments.first.finalAbility,
        endAbility: assessments.last.finalAbility,
        duration: period.duration,
      );
      
      // Analyze test-taking behavior
      final behavior = _analyzeTestTakingBehavior(assessments);
      
      // Generate performance insights
      final insights = _generatePerformanceInsights(
        progression: abilityProgression,
        consistency: consistency,
        growth: growth,
        behavior: behavior,
      );
      
      return PerformanceAnalysis(
        userId: userId,
        subject: subject,
        period: period,
        assessmentCount: assessments.length,
        abilityProgression: abilityProgression,
        consistency: consistency,
        improvementAreas: improvementAreas,
        growthMetrics: growth,
        testTakingBehavior: behavior,
        insights: insights,
      );
    } catch (e) {
      safePrint('Error analyzing performance: $e');
      rethrow;
    }
  }

  /// Generate practice assessment
  Future<PracticeAssessment> generatePracticeAssessment({
    required String userId,
    required String subject,
    required List<String> weakTopics,
    int? questionCount,
  }) async {
    try {
      // Get user's current ability
      final currentAbility = await _getCurrentAbility(userId, subject);
      
      // Determine appropriate difficulty range
      final difficultyRange = _determinePracticeDifficultyRange(
        currentAbility: currentAbility,
        targetImprovement: true,
      );
      
      // Load questions focusing on weak topics
      final questions = await _loadPracticeQuestions(
        topics: weakTopics,
        difficultyRange: difficultyRange,
        count: questionCount ?? 10,
      );
      
      // Add scaffolding for difficult questions
      final scaffoldedQuestions = _addScaffolding(questions, currentAbility);
      
      // Create practice plan
      final practicePlan = PracticePlan(
        focusAreas: weakTopics,
        suggestedOrder: _optimizeQuestionOrder(scaffoldedQuestions),
        estimatedTime: _estimatePracticeTime(scaffoldedQuestions),
        targetSkills: _identifyTargetSkills(weakTopics),
      );
      
      return PracticeAssessment(
        id: 'practice_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        subject: subject,
        questions: scaffoldedQuestions,
        practicePlan: practicePlan,
        adaptiveDifficulty: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error generating practice assessment: $e');
      rethrow;
    }
  }

  /// Validate assessment results
  Future<ValidationResult> validateAssessment({
    required String sessionId,
    ValidationCriteria? criteria,
  }) async {
    try {
      final activeAssessment = _activeAssessments[sessionId];
      if (activeAssessment == null) {
        throw Exception('Assessment session not found');
      }
      
      final session = activeAssessment.session;
      criteria ??= ValidationCriteria.standard();
      
      // Check response validity
      final responseValidity = _checkResponseValidity(session.responses);
      
      // Analyze response time patterns
      final timeValidity = _analyzeResponseTimes(session.responses, criteria);
      
      // Check for aberrant response patterns
      final aberrantPatterns = _detectAberrantPatterns(session);
      
      // Calculate fit statistics
      final fitStatistics = _calculateFitStatistics(session);
      
      // Determine overall validity
      final isValid = responseValidity.isValid &&
                     timeValidity.isValid &&
                     aberrantPatterns.isEmpty &&
                     fitStatistics.isWithinAcceptableRange;
      
      // Generate validity report
      final report = _generateValidityReport(
        responseValidity: responseValidity,
        timeValidity: timeValidity,
        aberrantPatterns: aberrantPatterns,
        fitStatistics: fitStatistics,
      );
      
      return ValidationResult(
        sessionId: sessionId,
        isValid: isValid,
        responseValidity: responseValidity,
        timeValidity: timeValidity,
        aberrantPatterns: aberrantPatterns,
        fitStatistics: fitStatistics,
        report: report,
        recommendations: isValid ? [] : _generateValidityRecommendations(report),
      );
    } catch (e) {
      safePrint('Error validating assessment: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<AbilityEstimate> _getInitialAbilityEstimate(
    String userId,
    String subject,
  ) async {
    // Check for previous assessments
    final history = await _fetchAssessmentHistory(
      userId: userId,
      subject: subject,
      period: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 90)),
        end: DateTime.now(),
      ),
    );
    
    if (history.isNotEmpty) {
      // Use most recent ability estimate
      return history.last.finalAbility;
    }
    
    // Default to average ability
    return AbilityEstimate(
      score: 0.0, // θ = 0 in standard normal distribution
      confidence: 0.5,
      standardError: 1.0,
    );
  }

  Future<List<AssessmentQuestion>> _loadItemBank(
    String subject,
    AssessmentType type,
  ) async {
    // Simulate loading item bank
    return List.generate(100, (index) => AssessmentQuestion(
      id: 'q_${subject}_$index',
      content: 'Question $index for $subject',
      type: QuestionType.multipleChoice,
      difficulty: -3.0 + (index * 0.06), // -3 to 3 range
      discrimination: 0.5 + (math.Random().nextDouble() * 1.5),
      topics: ['topic${index % 5}'],
      options: ['A', 'B', 'C', 'D'],
      correctAnswer: 'A',
    ));
  }

  Future<AssessmentQuestion> _selectNextQuestion(String sessionId) async {
    final activeAssessment = _activeAssessments[sessionId]!;
    final session = activeAssessment.session;
    
    // Get already asked questions
    final askedQuestionIds = session.questions.map((q) => q.id).toSet();
    
    // Filter available questions
    final availableQuestions = activeAssessment.itemBank
        .where((q) => !askedQuestionIds.contains(q.id))
        .toList();
    
    if (availableQuestions.isEmpty) {
      throw Exception('No more questions available');
    }
    
    // Maximum information selection
    double maxInfo = 0;
    AssessmentQuestion? selectedQuestion;
    
    for (final question in availableQuestions) {
      final info = _calculateInformation(
        theta: activeAssessment.theta,
        difficulty: question.difficulty,
        discrimination: question.discrimination,
      );
      
      if (info > maxInfo) {
        maxInfo = info;
        selectedQuestion = question;
      }
    }
    
    return selectedQuestion!;
  }

  double _calculateInformation(
      {required double theta,
      required double difficulty,
      required double discrimination}) {
    // Fisher information for 2PL model
    final z = discrimination * (theta - difficulty);
    final p = 1 / (1 + math.exp(-z));
    return discrimination * discrimination * p * (1 - p);
  }

  Future<bool> _evaluateResponse(
    AssessmentQuestion question,
    String response,
  ) async {
    // Simple evaluation - in practice would be more complex
    return response == question.correctAnswer;
  }

  _AbilityUpdate _updateAbilityEstimate({
    required double currentTheta,
    required List<QuestionResponse> responses,
    required List<AssessmentQuestion> questions,
  }) {
    // Maximum Likelihood Estimation for ability
    double theta = currentTheta;
    const int maxIterations = 20;
    const double tolerance = 0.001;
    
    for (int iteration = 0; iteration < maxIterations; iteration++) {
      double firstDerivative = 0;
      double secondDerivative = 0;
      
      for (int i = 0; i < responses.length; i++) {
        final response = responses[i];
        final question = questions[i];
        
        final z = question.discrimination * (theta - question.difficulty);
        final p = 1 / (1 + math.exp(-z));
        
        final residual = (response.isCorrect ? 1 : 0) - p;
        
        firstDerivative += question.discrimination * residual;
        secondDerivative -= question.discrimination * question.discrimination * p * (1 - p);
      }
      
      // Newton-Raphson update
      final delta = firstDerivative / (-secondDerivative);
      theta += delta;
      
      if (delta.abs() < tolerance) {
        break;
      }
    }
    
    // Calculate standard error
    double information = 0;
    for (final question in questions) {
      information += _calculateInformation(
        theta: theta,
        difficulty: question.difficulty,
        discrimination: question.discrimination,
      );
    }
    
    final standardError = 1 / math.sqrt(information);
    
    return _AbilityUpdate(theta: theta, standardError: standardError);
  }

  bool _checkStoppingCriteria(ActiveAssessment assessment) {
    final session = assessment.session;
    
    // Check minimum questions
    if (session.questions.length < _minQuestionsForReliableScore) {
      return false;
    }
    
    // Check maximum questions
    if (session.questions.length >= _maxQuestionsPerSession) {
      return true;
    }
    
    // Check standard error threshold
    if (assessment.standardError < (1 - _stoppingThreshold)) {
      return true;
    }
    
    // Check ability stability
    if (session.abilityHistory.length >= 5) {
      final recent = session.abilityHistory.sublist(
        session.abilityHistory.length - 5,
      );
      final variance = _calculateVariance(recent.map((a) => a.score).toList());
      
      if (variance < _abilityChangeThreshold) {
        return true;
      }
    }
    
    return false;
  }

  Future<ResponseResult> _finalizeAssessment(String sessionId) async {
    final activeAssessment = _activeAssessments[sessionId]!;
    final session = activeAssessment.session;
    
    session.status = AssessmentStatus.completed;
    session.endTime = DateTime.now();
    session.finalAbility = session.currentAbility;
    
    // Generate final report
    final report = await generateDiagnosticReport(sessionId: sessionId);
    
    // Clean up
    _activeAssessments.remove(sessionId);
    _updateControllers[sessionId]?.close();
    _updateControllers.remove(sessionId);
    
    return ResponseResult(
      isCorrect: session.responses.last.isCorrect,
      feedback: _generateFinalFeedback(session),
      currentAbility: session.currentAbility,
      isComplete: true,
      finalReport: report,
    );
  }

  String _generateImmediateFeedback(AssessmentQuestion question, bool isCorrect) {
    if (isCorrect) {
      return '정답입니다! 잘하셨어요.';
    } else {
      return '아쉽게도 틀렸습니다. 다음 문제에 도전해보세요.';
    }
  }

  double _calculateProgress(AssessmentSession session) {
    final minQuestions = math.min(
      _minQuestionsForReliableScore,
      session.config.minQuestions ?? _minQuestionsForReliableScore,
    );
    
    return (session.questions.length / minQuestions).clamp(0.0, 1.0);
  }

  void _emitUpdate(String sessionId, AssessmentUpdate update) {
    _updateControllers[sessionId]?.add(update);
  }

  Map<String, TopicPerformance> _analyzeTopicPerformance(
    AssessmentSession session,
  ) {
    final topicPerformance = <String, TopicPerformance>{};
    
    for (int i = 0; i < session.questions.length; i++) {
      final question = session.questions[i];
      final response = session.responses[i];
      
      for (final topic in question.topics) {
        topicPerformance[topic] ??= TopicPerformance(
          topic: topic,
          correctCount: 0,
          totalCount: 0,
          averageDifficulty: 0,
        );
        
        final perf = topicPerformance[topic]!;
        perf.totalCount++;
        if (response.isCorrect) perf.correctCount++;
        perf.averageDifficulty = 
            (perf.averageDifficulty * (perf.totalCount - 1) + question.difficulty) / 
            perf.totalCount;
      }
    }
    
    return topicPerformance;
  }

  List<String> _identifyStrengths(Map<String, TopicPerformance> topicAnalysis) {
    return topicAnalysis.entries
        .where((e) => e.value.accuracy > 0.8)
        .map((e) => e.key)
        .toList();
  }

  List<String> _identifyWeaknesses(Map<String, TopicPerformance> topicAnalysis) {
    return topicAnalysis.entries
        .where((e) => e.value.accuracy < 0.5)
        .map((e) => e.key)
        .toList();
  }

  ResponsePatterns _analyzeResponsePatterns(AssessmentSession session) {
    // Analyze various response patterns
    final speedAccuracyTradeoff = _analyzeSpeedAccuracy(session.responses);
    final fatigueEffect = _analyzeFatigue(session.responses);
    final guessingBehavior = _detectGuessing(session.responses, session.questions);
    
    return ResponsePatterns(
      speedAccuracyTradeoff: speedAccuracyTradeoff,
      fatigueEffect: fatigueEffect,
      guessingBehavior: guessingBehavior,
    );
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    double variance = 0;
    
    for (final value in values) {
      variance += math.pow(value - mean, 2);
    }
    
    return variance / values.length;
  }

  String _generateFinalFeedback(AssessmentSession session) {
    final correctCount = session.responses.where((r) => r.isCorrect).length;
    final accuracy = correctCount / session.responses.length;
    
    if (accuracy >= 0.9) {
      return '훌륭합니다! 매우 높은 정답률을 보이셨습니다.';
    } else if (accuracy >= 0.7) {
      return '잘하셨습니다! 좋은 성과를 보이셨습니다.';
    } else if (accuracy >= 0.5) {
      return '수고하셨습니다. 더 연습하면 향상될 거예요.';
    } else {
      return '수고하셨습니다. 기초부터 차근차근 학습해보세요.';
    }
  }

  // Additional stub implementations...
  SkillProfile _generateSkillProfile(
    AssessmentSession session,
    Map<String, TopicPerformance> topicAnalysis,
  ) => SkillProfile();

  Future<List<LearningRecommendation>> _generateLearningRecommendations({
    required List<String> weaknesses,
    required ResponsePatterns patterns,
    required AbilityEstimate currentAbility,
  }) async => [];

  ReliabilityMetrics _calculateReliability(AssessmentSession session) =>
      ReliabilityMetrics(cronbachAlpha: 0.85);

  List<String> _generateDiagnosticInsights({
    required AssessmentSession session,
    required Map<String, TopicPerformance> topicAnalysis,
    required ResponsePatterns patterns,
  }) => [];

  Future<List<AssessmentQuestion>> _loadQuestionsForTopics(
    List<String> topics,
  ) async => [];

  void _applyConstraints(
    List<AssessmentQuestion> questions,
    AssessmentConstraints constraints,
  ) {}

  List<AssessmentQuestion> _stratifiedQuestionSelection({
    required List<AssessmentQuestion> questions,
    required int count,
    required List<String> topics,
  }) => questions.take(count).toList();

  Map<String, int> _calculateQuestionDistribution(
    List<AssessmentQuestion> questions,
  ) => {};

  Map<String, double> _calculateDifficultyDistribution(
    List<AssessmentQuestion> questions,
  ) => {};

  Duration _estimateDuration(List<AssessmentQuestion> questions) =>
      Duration(minutes: questions.length * 2);

  Future<List<AssessmentSession>> _fetchAssessmentHistory({
    required String userId,
    required String subject,
    required DateTimeRange period,
  }) async => [];

  List<AbilityPoint> _trackAbilityProgression(
    List<AssessmentSession> assessments,
  ) => [];

  ConsistencyMetrics _analyzeConsistency(
    List<AssessmentSession> assessments,
  ) => ConsistencyMetrics();

  List<String> _identifyImprovementAreas(
    List<AssessmentSession> assessments,
  ) => [];

  GrowthMetrics _calculateGrowthMetrics({
    required AbilityEstimate startAbility,
    required AbilityEstimate endAbility,
    required Duration duration,
  }) => GrowthMetrics();

  TestTakingBehavior _analyzeTestTakingBehavior(
    List<AssessmentSession> assessments,
  ) => TestTakingBehavior();

  List<String> _generatePerformanceInsights({
    required List<AbilityPoint> progression,
    required ConsistencyMetrics consistency,
    required GrowthMetrics growth,
    required TestTakingBehavior behavior,
  }) => [];

  Future<AbilityEstimate> _getCurrentAbility(
    String userId,
    String subject,
  ) async => AbilityEstimate(score: 0.0, confidence: 0.5, standardError: 1.0);

  DifficultyRange _determinePracticeDifficultyRange({
    required AbilityEstimate currentAbility,
    required bool targetImprovement,
  }) => DifficultyRange(min: -1.0, max: 1.0);

  Future<List<AssessmentQuestion>> _loadPracticeQuestions({
    required List<String> topics,
    required DifficultyRange difficultyRange,
    required int count,
  }) async => [];

  List<AssessmentQuestion> _addScaffolding(
    List<AssessmentQuestion> questions,
    AbilityEstimate ability,
  ) => questions;

  List<AssessmentQuestion> _optimizeQuestionOrder(
    List<AssessmentQuestion> questions,
  ) => questions;

  Duration _estimatePracticeTime(List<AssessmentQuestion> questions) =>
      Duration(minutes: questions.length * 2);

  List<String> _identifyTargetSkills(List<String> topics) => topics;

  ResponseValidity _checkResponseValidity(List<QuestionResponse> responses) =>
      ResponseValidity(isValid: true);

  TimeValidity _analyzeResponseTimes(
    List<QuestionResponse> responses,
    ValidationCriteria criteria,
  ) => TimeValidity(isValid: true);

  List<AberrantPattern> _detectAberrantPatterns(AssessmentSession session) => [];

  FitStatistics _calculateFitStatistics(AssessmentSession session) =>
      FitStatistics(isWithinAcceptableRange: true);

  String _generateValidityReport({
    required ResponseValidity responseValidity,
    required TimeValidity timeValidity,
    required List<AberrantPattern> aberrantPatterns,
    required FitStatistics fitStatistics,
  }) => 'Validity report';

  List<String> _generateValidityRecommendations(String report) => [];

  double _analyzeSpeedAccuracy(List<QuestionResponse> responses) => 0.0;
  double _analyzeFatigue(List<QuestionResponse> responses) => 0.0;
  double _detectGuessing(
    List<QuestionResponse> responses,
    List<AssessmentQuestion> questions,
  ) => 0.0;
}

// Data models
class AssessmentSession {
  final String id;
  final String userId;
  final String subject;
  final AssessmentType type;
  final AssessmentConfig config;
  final DateTime startTime;
  DateTime? endTime;
  AbilityEstimate currentAbility;
  AbilityEstimate? finalAbility;
  final List<AbilityEstimate> abilityHistory;
  final List<AssessmentQuestion> questions;
  final List<QuestionResponse> responses;
  AssessmentStatus status;

  AssessmentSession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.type,
    required this.config,
    required this.startTime,
    this.endTime,
    required this.currentAbility,
    this.finalAbility,
    required this.abilityHistory,
    required this.questions,
    required this.responses,
    required this.status,
  });
}

class ActiveAssessment {
  final AssessmentSession session;
  final List<AssessmentQuestion> itemBank;
  double theta; // Current ability estimate
  double standardError;

  ActiveAssessment({
    required this.session,
    required this.itemBank,
    required this.theta,
    required this.standardError,
  });
}

class AssessmentQuestion {
  final String id;
  final String content;
  final QuestionType type;
  final double difficulty; // IRT b parameter
  final double discrimination; // IRT a parameter
  final List<String> topics;
  final List<String>? options;
  final String correctAnswer;
  final Map<String, dynamic>? metadata;

  AssessmentQuestion({
    required this.id,
    required this.content,
    required this.type,
    required this.difficulty,
    required this.discrimination,
    required this.topics,
    this.options,
    required this.correctAnswer,
    this.metadata,
  });
}

class QuestionResponse {
  final String questionId;
  final String response;
  final bool isCorrect;
  final int timeSpent; // seconds
  final DateTime timestamp;

  QuestionResponse({
    required this.questionId,
    required this.response,
    required this.isCorrect,
    required this.timeSpent,
    required this.timestamp,
  });
}

class AbilityEstimate {
  final double score; // theta in IRT
  final double confidence;
  final double standardError;

  AbilityEstimate({
    required this.score,
    required this.confidence,
    required this.standardError,
  });
}

class AssessmentConfig {
  final int? minQuestions;
  final int? maxQuestions;
  final double? targetPrecision;
  final Duration? timeLimit;
  final bool adaptiveDifficulty;
  final bool allowReview;
  final bool showFeedback;

  AssessmentConfig({
    this.minQuestions,
    this.maxQuestions,
    this.targetPrecision,
    this.timeLimit,
    this.adaptiveDifficulty = true,
    this.allowReview = false,
    this.showFeedback = true,
  });

  factory AssessmentConfig.defaultConfig() {
    return AssessmentConfig(
      minQuestions: 10,
      maxQuestions: 50,
      targetPrecision: 0.95,
      adaptiveDifficulty: true,
      showFeedback: true,
    );
  }
}

class AssessmentUpdate {
  final UpdateType type;
  final AssessmentQuestion? question;
  final QuestionResponse? response;
  final AbilityEstimate? newAbility;
  final AssessmentStatus sessionStatus;

  AssessmentUpdate({
    required this.type,
    this.question,
    this.response,
    this.newAbility,
    required this.sessionStatus,
  });
}

class ResponseResult {
  final bool isCorrect;
  final String feedback;
  final AbilityEstimate currentAbility;
  final AssessmentQuestion? nextQuestion;
  final double? progress;
  final bool isComplete;
  final DiagnosticReport? finalReport;

  ResponseResult({
    required this.isCorrect,
    required this.feedback,
    required this.currentAbility,
    this.nextQuestion,
    this.progress,
    this.isComplete = false,
    this.finalReport,
  });
}

class DiagnosticReport {
  final String sessionId;
  final String userId;
  final String subject;
  final AbilityEstimate overallAbility;
  final Map<String, TopicPerformance> topicAnalysis;
  final List<String> strengths;
  final List<String> weaknesses;
  final ResponsePatterns responsePatterns;
  final SkillProfile skillProfile;
  final List<LearningRecommendation> recommendations;
  final ReliabilityMetrics reliability;
  final List<String> insights;
  final DateTime generatedAt;

  DiagnosticReport({
    required this.sessionId,
    required this.userId,
    required this.subject,
    required this.overallAbility,
    required this.topicAnalysis,
    required this.strengths,
    required this.weaknesses,
    required this.responsePatterns,
    required this.skillProfile,
    required this.recommendations,
    required this.reliability,
    required this.insights,
    required this.generatedAt,
  });
}

class TopicPerformance {
  final String topic;
  int correctCount;
  int totalCount;
  double averageDifficulty;

  TopicPerformance({
    required this.topic,
    required this.correctCount,
    required this.totalCount,
    required this.averageDifficulty,
  });

  double get accuracy => totalCount > 0 ? correctCount / totalCount : 0.0;
}

class CustomAssessment {
  final String id;
  final String userId;
  final List<AssessmentQuestion> questions;
  final AssessmentBlueprint blueprint;
  final DateTime createdAt;

  CustomAssessment({
    required this.id,
    required this.userId,
    required this.questions,
    required this.blueprint,
    required this.createdAt,
  });
}

class AssessmentBlueprint {
  final List<String> topics;
  final Map<String, int> questionDistribution;
  final Map<String, double> difficultyDistribution;
  final Duration estimatedDuration;

  AssessmentBlueprint({
    required this.topics,
    required this.questionDistribution,
    required this.difficultyDistribution,
    required this.estimatedDuration,
  });
}

class PerformanceAnalysis {
  final String userId;
  final String subject;
  final DateTimeRange period;
  final int assessmentCount;
  final List<AbilityPoint> abilityProgression;
  final ConsistencyMetrics consistency;
  final List<String> improvementAreas;
  final GrowthMetrics growthMetrics;
  final TestTakingBehavior testTakingBehavior;
  final List<String> insights;

  PerformanceAnalysis({
    required this.userId,
    required this.subject,
    required this.period,
    required this.assessmentCount,
    required this.abilityProgression,
    required this.consistency,
    required this.improvementAreas,
    required this.growthMetrics,
    required this.testTakingBehavior,
    required this.insights,
  });

  factory PerformanceAnalysis.empty({
    required String userId,
    required String subject,
  }) {
    return PerformanceAnalysis(
      userId: userId,
      subject: subject,
      period: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now(),
      ),
      assessmentCount: 0,
      abilityProgression: [],
      consistency: ConsistencyMetrics(),
      improvementAreas: [],
      growthMetrics: GrowthMetrics(),
      testTakingBehavior: TestTakingBehavior(),
      insights: [],
    );
  }
}

class PracticeAssessment {
  final String id;
  final String userId;
  final String subject;
  final List<AssessmentQuestion> questions;
  final PracticePlan practicePlan;
  final bool adaptiveDifficulty;
  final DateTime createdAt;

  PracticeAssessment({
    required this.id,
    required this.userId,
    required this.subject,
    required this.questions,
    required this.practicePlan,
    required this.adaptiveDifficulty,
    required this.createdAt,
  });
}

class PracticePlan {
  final List<String> focusAreas;
  final List<AssessmentQuestion> suggestedOrder;
  final Duration estimatedTime;
  final List<String> targetSkills;

  PracticePlan({
    required this.focusAreas,
    required this.suggestedOrder,
    required this.estimatedTime,
    required this.targetSkills,
  });
}

class ValidationResult {
  final String sessionId;
  final bool isValid;
  final ResponseValidity responseValidity;
  final TimeValidity timeValidity;
  final List<AberrantPattern> aberrantPatterns;
  final FitStatistics fitStatistics;
  final String report;
  final List<String> recommendations;

  ValidationResult({
    required this.sessionId,
    required this.isValid,
    required this.responseValidity,
    required this.timeValidity,
    required this.aberrantPatterns,
    required this.fitStatistics,
    required this.report,
    required this.recommendations,
  });
}

class ValidationCriteria {
  final double minResponseTime;
  final double maxResponseTime;
  final double maxGuessing;
  final double fitThreshold;

  ValidationCriteria({
    required this.minResponseTime,
    required this.maxResponseTime,
    required this.maxGuessing,
    required this.fitThreshold,
  });

  factory ValidationCriteria.standard() {
    return ValidationCriteria(
      minResponseTime: 5.0, // seconds
      maxResponseTime: 300.0, // seconds
      maxGuessing: 0.25,
      fitThreshold: 2.0,
    );
  }
}

// Enums
enum AssessmentType {
  diagnostic,
  formative,
  summative,
  placement,
  practice,
}

enum AssessmentStatus {
  active,
  paused,
  completed,
  abandoned,
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  shortAnswer,
  essay,
  numeric,
}

enum UpdateType {
  questionSelected,
  responseSubmitted,
  assessmentCompleted,
  assessmentPaused,
}

// Supporting classes
class DifficultyRange {
  final double min;
  final double max;

  DifficultyRange({required this.min, required this.max});
}

class AssessmentConstraints {
  final int? maxQuestionsPerTopic;
  final double? minTopicCoverage;
  final List<String>? excludeTopics;

  AssessmentConstraints({
    this.maxQuestionsPerTopic,
    this.minTopicCoverage,
    this.excludeTopics,
  });
}

class ResponsePatterns {
  final double speedAccuracyTradeoff;
  final double fatigueEffect;
  final double guessingBehavior;

  ResponsePatterns({
    required this.speedAccuracyTradeoff,
    required this.fatigueEffect,
    required this.guessingBehavior,
  });
}

class SkillProfile {}
class LearningRecommendation {}
class ReliabilityMetrics {
  final double cronbachAlpha;
  ReliabilityMetrics({required this.cronbachAlpha});
}
class AbilityPoint {}
class ConsistencyMetrics {}
class GrowthMetrics {}
class TestTakingBehavior {}
class ResponseValidity {
  final bool isValid;
  ResponseValidity({required this.isValid});
}
class TimeValidity {
  final bool isValid;
  TimeValidity({required this.isValid});
}
class AberrantPattern {}
class FitStatistics {
  final bool isWithinAcceptableRange;
  FitStatistics({required this.isWithinAcceptableRange});
}

// Private helper classes
class _AbilityUpdate {
  final double theta;
  final double standardError;

  _AbilityUpdate({required this.theta, required this.standardError});
}