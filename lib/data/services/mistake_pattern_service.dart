import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for analyzing and learning from mistake patterns
class MistakePatternService {
  static final MistakePatternService _instance = MistakePatternService._internal();
  factory MistakePatternService() => _instance;
  MistakePatternService._internal();

  // Mistake categorization thresholds
  static const double _systematicThreshold = 0.7;
  static const int _patternMinOccurrences = 3;
  static const double _improvementThreshold = 0.3;

  /// Record a mistake
  Future<MistakeAnalysisResult> recordMistake({
    required String userId,
    required MistakeRecord mistake,
  }) async {
    try {
      // Store the mistake
      await _storeMistake(userId, mistake);
      
      // Analyze immediate context
      final immediateAnalysis = await _analyzeImmediateContext(mistake);
      
      // Check for patterns
      final patterns = await _checkForPatterns(userId, mistake);
      
      // Generate immediate feedback
      final feedback = _generateImmediateFeedback(
        mistake: mistake,
        analysis: immediateAnalysis,
        patterns: patterns,
      );
      
      // Suggest remediation if pattern detected
      final remediation = patterns.isNotEmpty 
          ? await _suggestRemediation(patterns.first)
          : null;
      
      return MistakeAnalysisResult(
        mistakeId: mistake.id,
        immediateAnalysis: immediateAnalysis,
        patternsDetected: patterns,
        feedback: feedback,
        remediation: remediation,
        similarMistakesCount: await _countSimilarMistakes(userId, mistake),
      );
    } catch (e) {
      safePrint('Error recording mistake: $e');
      rethrow;
    }
  }

  /// Analyze mistake patterns comprehensively
  Future<MistakePatternAnalysis> analyzeMistakePatterns({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? subject,
  }) async {
    try {
      // Fetch mistakes for period
      final mistakes = await _fetchMistakes(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        subject: subject,
      );
      
      // Categorize mistakes
      final categories = _categorizeMistakes(mistakes);
      
      // Identify systematic patterns
      final systematicPatterns = _identifySystematicPatterns(mistakes);
      
      // Analyze root causes
      final rootCauses = await _analyzeRootCauses(systematicPatterns);
      
      // Track improvement over time
      final improvementTrends = _analyzeImprovementTrends(mistakes);
      
      // Identify knowledge gaps
      final knowledgeGaps = _identifyKnowledgeGaps(mistakes);
      
      // Generate targeted interventions
      final interventions = _generateTargetedInterventions(
        patterns: systematicPatterns,
        rootCauses: rootCauses,
        gaps: knowledgeGaps,
      );
      
      return MistakePatternAnalysis(
        userId: userId,
        period: DateTimeRange(start: startDate, end: endDate),
        totalMistakes: mistakes.length,
        mistakeCategories: categories,
        systematicPatterns: systematicPatterns,
        rootCauseAnalysis: rootCauses,
        improvementTrends: improvementTrends,
        knowledgeGaps: knowledgeGaps,
        targetedInterventions: interventions,
        insights: _generateInsights(mistakes, systematicPatterns),
      );
    } catch (e) {
      safePrint('Error analyzing mistake patterns: $e');
      rethrow;
    }
  }

  /// Predict mistake likelihood
  Future<MistakePrediction> predictMistakeLikelihood({
    required String userId,
    required String conceptId,
    required ProblemContext context,
  }) async {
    try {
      // Get user's mistake history for concept
      final history = await _getConceptMistakeHistory(userId, conceptId);
      
      // Calculate base mistake rate
      final baseMistakeRate = _calculateBaseMistakeRate(history);
      
      // Analyze context factors
      final contextFactors = _analyzeContextFactors(context);
      
      // Check for similar problem patterns
      final similarProblems = await _findSimilarProblems(
        userId: userId,
        context: context,
      );
      
      // Calculate adjusted likelihood
      final likelihood = _calculateAdjustedLikelihood(
        baseRate: baseMistakeRate,
        contextFactors: contextFactors,
        similarProblems: similarProblems,
      );
      
      // Identify high-risk areas
      final riskAreas = _identifyHighRiskAreas(
        concept: conceptId,
        context: context,
        history: history,
      );
      
      // Generate preventive strategies
      final preventiveStrategies = _generatePreventiveStrategies(
        riskAreas: riskAreas,
        likelihood: likelihood,
      );
      
      return MistakePrediction(
        conceptId: conceptId,
        mistakeLikelihood: likelihood,
        confidence: _calculatePredictionConfidence(history.length),
        highRiskAreas: riskAreas,
        preventiveStrategies: preventiveStrategies,
        historicalMistakeRate: baseMistakeRate,
        contextualFactors: contextFactors,
      );
    } catch (e) {
      safePrint('Error predicting mistake likelihood: $e');
      rethrow;
    }
  }

  /// Create mistake remediation plan
  Future<RemediationPlan> createRemediationPlan({
    required String userId,
    required List<MistakePattern> patterns,
    required int availableTimeDays,
  }) async {
    try {
      // Prioritize patterns by impact
      final prioritizedPatterns = _prioritizePatterns(patterns);
      
      // Create targeted exercises for each pattern
      final exercises = <RemediationExercise>[];
      
      for (final pattern in prioritizedPatterns) {
        final patternExercises = await _createPatternExercises(
          pattern: pattern,
          userId: userId,
        );
        exercises.addAll(patternExercises);
      }
      
      // Create practice schedule
      final schedule = _createPracticeSchedule(
        exercises: exercises,
        availableDays: availableTimeDays,
      );
      
      // Set progress milestones
      final milestones = _setRemediationMilestones(
        patterns: patterns,
        schedule: schedule,
      );
      
      // Estimate improvement timeline
      final timeline = _estimateImprovementTimeline(
        patterns: patterns,
        exerciseCount: exercises.length,
      );
      
      return RemediationPlan(
        userId: userId,
        targetPatterns: prioritizedPatterns,
        exercises: exercises,
        schedule: schedule,
        milestones: milestones,
        estimatedTimeline: timeline,
        successMetrics: _defineSuccessMetrics(patterns),
        adaptiveAdjustments: _planAdaptiveAdjustments(),
      );
    } catch (e) {
      safePrint('Error creating remediation plan: $e');
      rethrow;
    }
  }

  /// Analyze mistake in real-time during practice
  Future<RealTimeMistakeAnalysis> analyzeRealTimeMistake({
    required String userId,
    required String problemId,
    required StudentSolution solution,
    required CorrectSolution correct,
  }) async {
    try {
      // Compare solutions
      final comparison = _compareSolutions(solution, correct);
      
      // Identify mistake type
      final mistakeType = _identifyMistakeType(comparison);
      
      // Find the exact error point
      final errorPoint = _findErrorPoint(solution, correct);
      
      // Analyze thinking process
      final thinkingAnalysis = _analyzeThinkingProcess(
        solution: solution,
        errorPoint: errorPoint,
      );
      
      // Check if it's a repeated mistake
      final isRepeated = await _checkIfRepeatedMistake(
        userId: userId,
        mistakeType: mistakeType,
      );
      
      // Generate targeted hint
      final hint = _generateTargetedHint(
        mistakeType: mistakeType,
        errorPoint: errorPoint,
        isRepeated: isRepeated,
      );
      
      // Suggest correction approach
      final correctionApproach = _suggestCorrectionApproach(
        mistakeType: mistakeType,
        thinkingAnalysis: thinkingAnalysis,
      );
      
      return RealTimeMistakeAnalysis(
        problemId: problemId,
        mistakeType: mistakeType,
        errorPoint: errorPoint,
        comparison: comparison,
        thinkingAnalysis: thinkingAnalysis,
        isRepeatedMistake: isRepeated,
        hint: hint,
        correctionApproach: correctionApproach,
        conceptualGap: _identifyConceptualGap(mistakeType, errorPoint),
      );
    } catch (e) {
      safePrint('Error analyzing real-time mistake: $e');
      rethrow;
    }
  }

  /// Track mistake improvement
  Future<MistakeImprovementReport> trackMistakeImprovement({
    required String userId,
    required String conceptId,
    required DateTime since,
  }) async {
    try {
      // Get mistakes over time
      final mistakes = await _fetchConceptMistakes(
        userId: userId,
        conceptId: conceptId,
        since: since,
      );
      
      // Calculate improvement metrics
      final metrics = _calculateImprovementMetrics(mistakes);
      
      // Identify persistent issues
      final persistentIssues = _identifyPersistentIssues(mistakes);
      
      // Analyze improvement factors
      final improvementFactors = _analyzeImprovementFactors(mistakes);
      
      // Project future improvement
      final projection = _projectFutureImprovement(
        currentMetrics: metrics,
        improvementRate: improvementFactors.rate,
      );
      
      // Generate recommendations
      final recommendations = _generateImprovementRecommendations(
        metrics: metrics,
        persistentIssues: persistentIssues,
        projection: projection,
      );
      
      return MistakeImprovementReport(
        userId: userId,
        conceptId: conceptId,
        period: DateTimeRange(start: since, end: DateTime.now()),
        improvementMetrics: metrics,
        persistentIssues: persistentIssues,
        improvementFactors: improvementFactors,
        futureProjection: projection,
        recommendations: recommendations,
        celebrateAchievements: _identifyAchievements(metrics),
      );
    } catch (e) {
      safePrint('Error tracking mistake improvement: $e');
      rethrow;
    }
  }

  /// Learn from collective mistakes
  Future<CollectiveMistakeInsights> analyzeCollectiveMistakes({
    required String conceptId,
    required int sampleSize,
  }) async {
    try {
      // Fetch anonymous mistake data
      final collectiveMistakes = await _fetchCollectiveMistakes(
        conceptId: conceptId,
        limit: sampleSize,
      );
      
      // Identify common patterns
      final commonPatterns = _identifyCommonPatterns(collectiveMistakes);
      
      // Analyze difficulty indicators
      final difficultyIndicators = _analyzeDifficultyIndicators(
        mistakes: collectiveMistakes,
        patterns: commonPatterns,
      );
      
      // Find effective solutions
      final effectiveSolutions = await _findEffectiveSolutions(
        conceptId: conceptId,
        patterns: commonPatterns,
      );
      
      // Generate teaching insights
      final teachingInsights = _generateTeachingInsights(
        patterns: commonPatterns,
        solutions: effectiveSolutions,
      );
      
      return CollectiveMistakeInsights(
        conceptId: conceptId,
        sampleSize: collectiveMistakes.length,
        commonPatterns: commonPatterns,
        difficultyIndicators: difficultyIndicators,
        effectiveSolutions: effectiveSolutions,
        teachingInsights: teachingInsights,
        mistakeDistribution: _calculateMistakeDistribution(collectiveMistakes),
      );
    } catch (e) {
      safePrint('Error analyzing collective mistakes: $e');
      rethrow;
    }
  }

  // Private helper methods

  Future<void> _storeMistake(String userId, MistakeRecord mistake) async {
    // Store in database
    try {
      await Amplify.API.post(
        '/mistakes',
        apiName: 'mistakeAPI',
        body: HttpPayload.json({
          'userId': userId,
          'mistake': mistake.toJson(),
        }),
      ).response;
    } catch (e) {
      safePrint('Error storing mistake: $e');
    }
  }

  Future<ImmediateAnalysis> _analyzeImmediateContext(MistakeRecord mistake) async {
    return ImmediateAnalysis(
      mistakeCategory: _categorizeSingleMistake(mistake),
      severity: _assessSeverity(mistake),
      immediateImpact: _assessImmediateImpact(mistake),
      relatedConcepts: _findRelatedConcepts(mistake),
    );
  }

  Future<List<MistakePattern>> _checkForPatterns(
    String userId,
    MistakeRecord mistake,
  ) async {
    // Fetch recent mistakes
    final recentMistakes = await _fetchRecentMistakes(userId, days: 7);
    
    // Look for patterns
    final patterns = <MistakePattern>[];
    
    // Check for repeated mistake type
    final similarMistakes = recentMistakes.where((m) => 
      m.type == mistake.type && m.subject == mistake.subject
    ).toList();
    
    if (similarMistakes.length >= _patternMinOccurrences) {
      patterns.add(MistakePattern(
        id: 'repeated_${mistake.type}',
        type: 'repeated_error',
        description: 'Repeated ${mistake.type} errors in ${mistake.subject}',
        occurrences: similarMistakes.length + 1,
        confidence: 0.8,
        affectedConcepts: [mistake.concept],
        examples: similarMistakes.take(3).toList(),
      ));
    }
    
    return patterns;
  }

  MistakeFeedback _generateImmediateFeedback({
    required MistakeRecord mistake,
    required ImmediateAnalysis analysis,
    required List<MistakePattern> patterns,
  }) {
    String message = '';
    String type = 'corrective';
    
    if (patterns.isNotEmpty) {
      message = 'I notice this is similar to previous mistakes. Let\'s address the pattern.';
      type = 'pattern_alert';
    } else if (analysis.severity == 'high') {
      message = 'This is an important concept. Let\'s review it carefully.';
      type = 'conceptual';
    } else {
      message = 'Good attempt! Here\'s where to focus:';
      type = 'encouraging';
    }
    
    return MistakeFeedback(
      type: type,
      message: message,
      focusPoints: _identifyFocusPoints(mistake, analysis),
      encouragement: _generateEncouragement(analysis.severity),
    );
  }

  Future<Remediation?> _suggestRemediation(MistakePattern pattern) async {
    return Remediation(
      patternId: pattern.id,
      title: 'Address ${pattern.type} pattern',
      exercises: [
        'Review fundamental concepts',
        'Practice with guided examples',
        'Apply to new problems',
      ],
      estimatedTime: 30,
      resources: await _findRemediationResources(pattern),
    );
  }

  Future<int> _countSimilarMistakes(String userId, MistakeRecord mistake) async {
    // Count similar mistakes in history
    return 0; // Simplified
  }

  Future<List<MistakeRecord>> _fetchMistakes({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? subject,
  }) async {
    // Fetch from database
    return [];
  }

  Map<String, MistakeCategory> _categorizeMistakes(List<MistakeRecord> mistakes) {
    final categories = <String, MistakeCategory>{};
    
    for (final mistake in mistakes) {
      final category = _categorizeSingleMistake(mistake);
      categories[category] ??= MistakeCategory(
        name: category,
        count: 0,
        mistakes: [],
      );
      
      categories[category]!.count++;
      categories[category]!.mistakes.add(mistake);
    }
    
    return categories;
  }

  String _categorizeSingleMistake(MistakeRecord mistake) {
    // Categorize based on type
    switch (mistake.type) {
      case 'calculation':
        return 'Computational Errors';
      case 'conceptual':
        return 'Conceptual Misunderstandings';
      case 'procedural':
        return 'Procedural Mistakes';
      case 'careless':
        return 'Careless Errors';
      default:
        return 'Other';
    }
  }

  List<MistakePattern> _identifySystematicPatterns(List<MistakeRecord> mistakes) {
    final patterns = <MistakePattern>[];
    
    // Group by type and concept
    final grouped = <String, List<MistakeRecord>>{};
    
    for (final mistake in mistakes) {
      final key = '${mistake.type}_${mistake.concept}';
      grouped[key] ??= [];
      grouped[key]!.add(mistake);
    }
    
    // Find patterns
    grouped.forEach((key, group) {
      if (group.length >= _patternMinOccurrences) {
        final consistency = _calculatePatternConsistency(group);
        
        if (consistency > _systematicThreshold) {
          patterns.add(MistakePattern(
            id: key,
            type: group.first.type,
            description: _describePattern(group),
            occurrences: group.length,
            confidence: consistency,
            affectedConcepts: group.map((m) => m.concept).toSet().toList(),
            examples: group.take(3).toList(),
          ));
        }
      }
    });
    
    return patterns;
  }

  double _calculatePatternConsistency(List<MistakeRecord> mistakes) {
    // Check how consistent the mistakes are
    if (mistakes.length < 2) return 0.0;
    
    // Compare mistake details
    int consistentCount = 0;
    for (int i = 1; i < mistakes.length; i++) {
      if (_areMistakesSimilar(mistakes[i], mistakes[i-1])) {
        consistentCount++;
      }
    }
    
    return consistentCount / (mistakes.length - 1);
  }

  bool _areMistakesSimilar(MistakeRecord m1, MistakeRecord m2) {
    return m1.type == m2.type && 
           m1.concept == m2.concept &&
           (m1.details['subtype'] == m2.details['subtype']);
  }

  String _describePattern(List<MistakeRecord> mistakes) {
    final first = mistakes.first;
    return 'Consistent ${first.type} errors in ${first.concept} (${mistakes.length} occurrences)';
  }

  Future<RootCauseAnalysis> _analyzeRootCauses(
    List<MistakePattern> patterns,
  ) async {
    final causes = <String, RootCause>{};
    
    for (final pattern in patterns) {
      final cause = await _identifyRootCause(pattern);
      causes[pattern.id] = cause;
    }
    
    return RootCauseAnalysis(
      identifiedCauses: causes,
      primaryCause: _identifyPrimaryCause(causes),
      contributingFactors: _identifyContributingFactors(causes),
    );
  }

  Future<RootCause> _identifyRootCause(MistakePattern pattern) async {
    // Analyze pattern to find root cause
    String causeType = 'unknown';
    String description = '';
    
    if (pattern.type == 'calculation') {
      causeType = 'skill_gap';
      description = 'Insufficient practice with arithmetic operations';
    } else if (pattern.type == 'conceptual') {
      causeType = 'understanding_gap';
      description = 'Incomplete understanding of underlying concepts';
    }
    
    return RootCause(
      type: causeType,
      description: description,
      confidence: 0.7,
      evidence: pattern.examples.map((e) => e.description).toList(),
    );
  }

  String _identifyPrimaryCause(Map<String, RootCause> causes) {
    if (causes.isEmpty) return 'unknown';
    
    // Find most common cause type
    final typeCounts = <String, int>{};
    causes.values.forEach((cause) {
      typeCounts[cause.type] = (typeCounts[cause.type] ?? 0) + 1;
    });
    
    return typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  List<String> _identifyContributingFactors(Map<String, RootCause> causes) {
    final factors = <String>{};
    
    causes.values.forEach((cause) {
      if (cause.type == 'skill_gap') {
        factors.add('Insufficient practice');
      } else if (cause.type == 'understanding_gap') {
        factors.add('Conceptual confusion');
      }
    });
    
    return factors.toList();
  }

  ImprovementTrends _analyzeImprovementTrends(List<MistakeRecord> mistakes) {
    // Sort by date
    mistakes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Calculate mistake rate over time
    final weeklyRates = <DateTime, double>{};
    
    // Group by week
    for (final mistake in mistakes) {
      final weekStart = _getWeekStart(mistake.timestamp);
      weeklyRates[weekStart] = (weeklyRates[weekStart] ?? 0) + 1;
    }
    
    // Calculate trend
    final rates = weeklyRates.values.toList();
    final trend = rates.length >= 2 
        ? (rates.last - rates.first) / rates.first
        : 0.0;
    
    return ImprovementTrends(
      overallTrend: trend < 0 ? 'improving' : 'declining',
      trendStrength: trend.abs(),
      weeklyMistakeRates: weeklyRates,
      improvementRate: trend < 0 ? trend.abs() : 0.0,
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - weekday + 1);
  }

  List<KnowledgeGap> _identifyKnowledgeGaps(List<MistakeRecord> mistakes) {
    final gaps = <KnowledgeGap>[];
    
    // Group by concept
    final conceptGroups = <String, List<MistakeRecord>>{};
    for (final mistake in mistakes) {
      conceptGroups[mistake.concept] ??= [];
      conceptGroups[mistake.concept]!.add(mistake);
    }
    
    // Identify gaps
    conceptGroups.forEach((concept, mistakes) {
      if (mistakes.length >= 3) {
        gaps.add(KnowledgeGap(
          concept: concept,
          severity: _calculateGapSeverity(mistakes),
          affectedSkills: _identifyAffectedSkills(mistakes),
          recommendedReview: _recommendReview(concept, mistakes),
        ));
      }
    });
    
    return gaps;
  }

  double _calculateGapSeverity(List<MistakeRecord> mistakes) {
    // Base on frequency and consistency
    return math.min(mistakes.length * 0.1, 1.0);
  }

  List<String> _identifyAffectedSkills(List<MistakeRecord> mistakes) {
    final skills = <String>{};
    
    for (final mistake in mistakes) {
      if (mistake.details['skill'] != null) {
        skills.add(mistake.details['skill']);
      }
    }
    
    return skills.toList();
  }

  List<String> _recommendReview(String concept, List<MistakeRecord> mistakes) {
    return [
      'Review $concept fundamentals',
      'Practice with guided examples',
      'Test understanding with varied problems',
    ];
  }

  List<TargetedIntervention> _generateTargetedInterventions({
    required List<MistakePattern> patterns,
    required RootCauseAnalysis rootCauses,
    required List<KnowledgeGap> gaps,
  }) {
    final interventions = <TargetedIntervention>[];
    
    // Pattern-based interventions
    for (final pattern in patterns) {
      interventions.add(TargetedIntervention(
        target: pattern.id,
        type: 'pattern_breaking',
        title: 'Break ${pattern.type} pattern',
        description: 'Targeted practice to overcome systematic errors',
        activities: _generatePatternActivities(pattern),
        estimatedDuration: 60,
        priority: pattern.occurrences > 5 ? 1 : 2,
      ));
    }
    
    // Gap-based interventions
    for (final gap in gaps) {
      interventions.add(TargetedIntervention(
        target: gap.concept,
        type: 'knowledge_building',
        title: 'Fill ${gap.concept} gap',
        description: 'Strengthen understanding of core concepts',
        activities: gap.recommendedReview,
        estimatedDuration: 45,
        priority: gap.severity > 0.7 ? 1 : 2,
      ));
    }
    
    return interventions;
  }

  List<String> _generatePatternActivities(MistakePattern pattern) {
    return [
      'Identify trigger conditions',
      'Practice recognition exercises',
      'Apply correction strategies',
      'Test with similar problems',
    ];
  }

  List<MistakeInsight> _generateInsights(
    List<MistakeRecord> mistakes,
    List<MistakePattern> patterns,
  ) {
    final insights = <MistakeInsight>[];
    
    // Frequency insight
    if (mistakes.length > 20) {
      insights.add(MistakeInsight(
        type: 'frequency',
        title: 'High Mistake Frequency',
        description: 'You made ${mistakes.length} mistakes in this period',
        recommendation: 'Consider slowing down and double-checking work',
      ));
    }
    
    // Pattern insight
    if (patterns.isNotEmpty) {
      insights.add(MistakeInsight(
        type: 'pattern',
        title: 'Systematic Patterns Detected',
        description: 'Found ${patterns.length} recurring mistake patterns',
        recommendation: 'Focus on breaking these specific patterns',
      ));
    }
    
    return insights;
  }

  Future<List<MistakeRecord>> _fetchRecentMistakes(String userId, {int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    return _fetchMistakes(
      userId: userId,
      startDate: since,
      endDate: DateTime.now(),
    );
  }

  String _assessSeverity(MistakeRecord mistake) {
    // Assess based on impact
    if (mistake.impactScore > 0.7) return 'high';
    if (mistake.impactScore > 0.4) return 'medium';
    return 'low';
  }

  String _assessImmediateImpact(MistakeRecord mistake) {
    if (mistake.preventedProgress) {
      return 'Blocks further progress';
    } else if (mistake.affectsUnderstanding) {
      return 'May lead to misconceptions';
    }
    return 'Minor impact on current task';
  }

  List<String> _findRelatedConcepts(MistakeRecord mistake) {
    // Find concepts related to the mistake
    return [mistake.concept]; // Simplified
  }

  List<String> _identifyFocusPoints(MistakeRecord mistake, ImmediateAnalysis analysis) {
    final points = <String>[];
    
    if (analysis.severity == 'high') {
      points.add('Review ${mistake.concept} fundamentals');
    }
    
    if (mistake.type == 'procedural') {
      points.add('Check each step carefully');
    }
    
    points.add('Practice similar problems');
    
    return points;
  }

  String _generateEncouragement(String severity) {
    switch (severity) {
      case 'high':
        return 'This is challenging - you\'re tackling difficult material!';
      case 'medium':
        return 'Good effort - let\'s refine your approach';
      default:
        return 'Minor slip - you\'re on the right track!';
    }
  }

  Future<List<String>> _findRemediationResources(MistakePattern pattern) async {
    // Find relevant resources
    return [
      'Video: Understanding ${pattern.affectedConcepts.first}',
      'Practice set: ${pattern.type} exercises',
      'Guide: Common ${pattern.type} mistakes and solutions',
    ];
  }

  // Additional helper methods for prediction, real-time analysis, etc...

  Future<List<ConceptMistake>> _getConceptMistakeHistory(
    String userId,
    String conceptId,
  ) async {
    // Fetch historical mistakes for concept
    return [];
  }

  double _calculateBaseMistakeRate(List<ConceptMistake> history) {
    if (history.isEmpty) return 0.0;
    
    final mistakeCount = history.where((m) => m.wasMistake).length;
    return mistakeCount / history.length;
  }

  Map<String, double> _analyzeContextFactors(ProblemContext context) {
    return {
      'complexity': context.complexity,
      'time_pressure': context.hasTimeLimit ? 0.3 : 0.0,
      'new_variation': context.isNewVariation ? 0.2 : 0.0,
      'multi_step': context.requiresMultipleSteps ? 0.15 : 0.0,
    };
  }

  Future<List<SimilarProblem>> _findSimilarProblems({
    required String userId,
    required ProblemContext context,
  }) async {
    // Find similar problems user has attempted
    return [];
  }

  double _calculateAdjustedLikelihood({
    required double baseRate,
    required Map<String, double> contextFactors,
    required List<SimilarProblem> similarProblems,
  }) {
    double likelihood = baseRate;
    
    // Apply context factors
    contextFactors.forEach((factor, weight) {
      likelihood += weight * 0.1;
    });
    
    // Adjust based on similar problem performance
    if (similarProblems.isNotEmpty) {
      final similarMistakeRate = similarProblems
          .where((p) => p.hadMistake)
          .length / similarProblems.length;
      likelihood = (likelihood + similarMistakeRate) / 2;
    }
    
    return likelihood.clamp(0.0, 1.0);
  }

  List<String> _identifyHighRiskAreas({
    required String concept,
    required ProblemContext context,
    required List<ConceptMistake> history,
  }) {
    final riskAreas = <String>[];
    
    if (context.requiresMultipleSteps) {
      riskAreas.add('Step sequencing');
    }
    
    if (context.complexity > 0.7) {
      riskAreas.add('Complex reasoning');
    }
    
    // Check historical patterns
    final commonMistakeTypes = _findCommonMistakeTypes(history);
    riskAreas.addAll(commonMistakeTypes);
    
    return riskAreas;
  }

  List<String> _findCommonMistakeTypes(List<ConceptMistake> history) {
    final typeCounts = <String, int>{};
    
    for (final mistake in history.where((m) => m.wasMistake)) {
      typeCounts[mistake.mistakeType] = (typeCounts[mistake.mistakeType] ?? 0) + 1;
    }
    
    return typeCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();
  }

  List<PreventiveStrategy> _generatePreventiveStrategies({
    required List<String> riskAreas,
    required double likelihood,
  }) {
    final strategies = <PreventiveStrategy>[];
    
    for (final area in riskAreas) {
      strategies.add(PreventiveStrategy(
        riskArea: area,
        strategy: _getStrategyForRiskArea(area),
        checkpoints: _getCheckpointsForArea(area),
      ));
    }
    
    if (likelihood > 0.6) {
      strategies.add(PreventiveStrategy(
        riskArea: 'general',
        strategy: 'Take extra time to review before submitting',
        checkpoints: ['Double-check calculations', 'Verify logic flow'],
      ));
    }
    
    return strategies;
  }

  String _getStrategyForRiskArea(String area) {
    switch (area) {
      case 'Step sequencing':
        return 'Write out all steps before solving';
      case 'Complex reasoning':
        return 'Break down into smaller sub-problems';
      default:
        return 'Focus carefully on this aspect';
    }
  }

  List<String> _getCheckpointsForArea(String area) {
    switch (area) {
      case 'Step sequencing':
        return ['Verify each step follows logically', 'Check for skipped steps'];
      case 'Complex reasoning':
        return ['Validate assumptions', 'Test with simple case'];
      default:
        return ['Review this area specifically'];
    }
  }

  double _calculatePredictionConfidence(int historySize) {
    // More history = more confident prediction
    return math.min(historySize * 0.1, 0.9);
  }

  List<MistakePattern> _prioritizePatterns(List<MistakePattern> patterns) {
    // Sort by impact (frequency * severity)
    final sorted = patterns.toList()
      ..sort((a, b) => (b.occurrences * b.confidence)
          .compareTo(a.occurrences * a.confidence));
    
    return sorted;
  }

  Future<List<RemediationExercise>> _createPatternExercises({
    required MistakePattern pattern,
    required String userId,
  }) async {
    final exercises = <RemediationExercise>[];
    
    // Recognition exercise
    exercises.add(RemediationExercise(
      id: '${pattern.id}_recognition',
      type: 'recognition',
      title: 'Identify ${pattern.type} triggers',
      description: 'Learn to recognize when this mistake might occur',
      difficulty: 0.3,
      estimatedTime: 10,
      concepts: pattern.affectedConcepts,
    ));
    
    // Correction exercise
    exercises.add(RemediationExercise(
      id: '${pattern.id}_correction',
      type: 'correction',
      title: 'Practice correct approach',
      description: 'Apply the right method to similar problems',
      difficulty: 0.5,
      estimatedTime: 15,
      concepts: pattern.affectedConcepts,
    ));
    
    // Application exercise
    exercises.add(RemediationExercise(
      id: '${pattern.id}_application',
      type: 'application',
      title: 'Apply to new contexts',
      description: 'Use learned skills in varied situations',
      difficulty: 0.7,
      estimatedTime: 20,
      concepts: pattern.affectedConcepts,
    ));
    
    return exercises;
  }

  PracticeSchedule _createPracticeSchedule({
    required List<RemediationExercise> exercises,
    required int availableDays,
  }) {
    final schedule = PracticeSchedule(days: []);
    
    // Distribute exercises across days
    final exercisesPerDay = (exercises.length / availableDays).ceil();
    
    for (int day = 0; day < availableDays; day++) {
      final dayExercises = exercises
          .skip(day * exercisesPerDay)
          .take(exercisesPerDay)
          .toList();
      
      if (dayExercises.isNotEmpty) {
        schedule.days.add(PracticeDay(
          dayNumber: day + 1,
          exercises: dayExercises,
          totalTime: dayExercises.fold(0, (sum, e) => sum + e.estimatedTime),
        ));
      }
    }
    
    return schedule;
  }

  List<RemediationMilestone> _setRemediationMilestones({
    required List<MistakePattern> patterns,
    required PracticeSchedule schedule,
  }) {
    final milestones = <RemediationMilestone>[];
    
    // First milestone - recognition
    milestones.add(RemediationMilestone(
      day: 3,
      goal: 'Recognize all pattern triggers',
      assessment: 'Identify patterns in sample problems',
      targetAccuracy: 0.8,
    ));
    
    // Second milestone - correction
    milestones.add(RemediationMilestone(
      day: 7,
      goal: 'Apply corrections consistently',
      assessment: 'Solve problems without repeating patterns',
      targetAccuracy: 0.85,
    ));
    
    // Final milestone - mastery
    milestones.add(RemediationMilestone(
      day: schedule.days.length,
      goal: 'Demonstrate pattern mastery',
      assessment: 'Mixed problem set with high accuracy',
      targetAccuracy: 0.9,
    ));
    
    return milestones;
  }

  ImprovementTimeline _estimateImprovementTimeline({
    required List<MistakePattern> patterns,
    required int exerciseCount,
  }) {
    final totalSeverity = patterns.fold(0.0, 
      (sum, p) => sum + (p.occurrences * p.confidence));
    
    // Estimate days based on severity and exercises
    final estimatedDays = (totalSeverity * 3 + exerciseCount * 0.5).round();
    
    return ImprovementTimeline(
      estimatedDays: estimatedDays,
      phases: [
        TimelinePhase(
          name: 'Recognition',
          duration: (estimatedDays * 0.3).round(),
          focus: 'Learn to identify mistake triggers',
        ),
        TimelinePhase(
          name: 'Correction',
          duration: (estimatedDays * 0.4).round(),
          focus: 'Practice correct approaches',
        ),
        TimelinePhase(
          name: 'Mastery',
          duration: (estimatedDays * 0.3).round(),
          focus: 'Apply skills consistently',
        ),
      ],
    );
  }

  List<SuccessMetric> _defineSuccessMetrics(List<MistakePattern> patterns) {
    return [
      SuccessMetric(
        name: 'Pattern Reduction',
        target: 0.8,
        measurement: 'Reduction in pattern occurrence',
      ),
      SuccessMetric(
        name: 'Accuracy Improvement',
        target: 0.9,
        measurement: 'Overall problem-solving accuracy',
      ),
      SuccessMetric(
        name: 'Speed Improvement',
        target: 0.7,
        measurement: 'Time to correct identification',
      ),
    ];
  }

  List<AdaptiveAdjustment> _planAdaptiveAdjustments() {
    return [
      AdaptiveAdjustment(
        trigger: 'Low progress after 3 days',
        adjustment: 'Simplify exercises and add more guidance',
      ),
      AdaptiveAdjustment(
        trigger: 'Rapid progress',
        adjustment: 'Accelerate to more challenging exercises',
      ),
      AdaptiveAdjustment(
        trigger: 'Specific concept struggle',
        adjustment: 'Add targeted concept review',
      ),
    ];
  }

  SolutionComparison _compareSolutions(
    StudentSolution student,
    CorrectSolution correct,
  ) {
    return SolutionComparison(
      matchingSteps: _findMatchingSteps(student, correct),
      divergencePoint: _findDivergencePoint(student, correct),
      missingSteps: _findMissingSteps(student, correct),
      extraSteps: _findExtraSteps(student, correct),
    );
  }

  String _identifyMistakeType(SolutionComparison comparison) {
    if (comparison.missingSteps.isNotEmpty) {
      return 'incomplete_solution';
    } else if (comparison.divergencePoint != null) {
      return 'logical_error';
    } else if (comparison.extraSteps.isNotEmpty) {
      return 'overcomplicated';
    }
    return 'other';
  }

  ErrorPoint _findErrorPoint(StudentSolution solution, CorrectSolution correct) {
    // Find where the error occurred
    for (int i = 0; i < solution.steps.length; i++) {
      if (i >= correct.steps.length || 
          !_areStepsEquivalent(solution.steps[i], correct.steps[i])) {
        return ErrorPoint(
          stepNumber: i + 1,
          studentStep: solution.steps[i],
          expectedStep: i < correct.steps.length ? correct.steps[i] : null,
        );
      }
    }
    
    return ErrorPoint(stepNumber: -1, studentStep: null, expectedStep: null);
  }

  ThinkingAnalysis _analyzeThinkingProcess({
    required StudentSolution solution,
    required ErrorPoint errorPoint,
  }) {
    return ThinkingAnalysis(
      approach: _identifyApproach(solution),
      misconceptions: _identifyMisconceptions(solution, errorPoint),
      strengthsShown: _identifyStrengths(solution),
      processingPattern: _analyzeProcessingPattern(solution),
    );
  }

  Future<bool> _checkIfRepeatedMistake(
    String userId,
    String mistakeType,
  ) async {
    // Check recent history for same mistake type
    final recent = await _fetchRecentMistakes(userId, days: 30);
    return recent.any((m) => m.type == mistakeType);
  }

  Hint _generateTargetedHint({
    required String mistakeType,
    required ErrorPoint errorPoint,
    required bool isRepeated,
  }) {
    String content = '';
    String level = 'gentle';
    
    if (isRepeated) {
      content = 'Remember, we\'ve seen this before. ';
      level = 'direct';
    }
    
    switch (mistakeType) {
      case 'incomplete_solution':
        content += 'Check if all required steps are included.';
        break;
      case 'logical_error':
        content += 'Review the logic at step ${errorPoint.stepNumber}.';
        break;
      default:
        content += 'Take another look at your approach.';
    }
    
    return Hint(
      content: content,
      level: level,
      focusArea: errorPoint.stepNumber > 0 ? 'Step ${errorPoint.stepNumber}' : null,
    );
  }

  CorrectionApproach _suggestCorrectionApproach({
    required String mistakeType,
    required ThinkingAnalysis thinkingAnalysis,
  }) {
    final steps = <String>[];
    
    if (thinkingAnalysis.misconceptions.isNotEmpty) {
      steps.add('First, let\'s clarify the concept');
      steps.add('Review the fundamental principle');
    }
    
    steps.add('Identify where the approach diverged');
    steps.add('Apply the correct method');
    steps.add('Verify the result makes sense');
    
    return CorrectionApproach(
      steps: steps,
      focusConcepts: thinkingAnalysis.misconceptions,
      estimatedTime: 5,
    );
  }

  String _identifyConceptualGap(String mistakeType, ErrorPoint errorPoint) {
    // Identify what concept understanding is missing
    return 'Conceptual gap in problem decomposition';
  }

  Future<List<MistakeRecord>> _fetchConceptMistakes({
    required String userId,
    required String conceptId,
    required DateTime since,
  }) async {
    return _fetchMistakes(
      userId: userId,
      startDate: since,
      endDate: DateTime.now(),
      subject: conceptId,
    );
  }

  ImprovementMetrics _calculateImprovementMetrics(List<MistakeRecord> mistakes) {
    // Sort by date
    mistakes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    if (mistakes.isEmpty) {
      return ImprovementMetrics(
        mistakeRateChange: 0.0,
        accuracyImprovement: 0.0,
        conceptMastery: 0.0,
        timeToCorrectImprovement: 0.0,
      );
    }
    
    // Calculate metrics
    final early = mistakes.take(mistakes.length ~/ 2).toList();
    final late = mistakes.skip(mistakes.length ~/ 2).toList();
    
    final earlyRate = early.length / (early.last.timestamp.difference(early.first.timestamp).inDays + 1);
    final lateRate = late.length / (late.last.timestamp.difference(late.first.timestamp).inDays + 1);
    
    return ImprovementMetrics(
      mistakeRateChange: (earlyRate - lateRate) / earlyRate,
      accuracyImprovement: 0.15, // Simplified
      conceptMastery: 0.7, // Simplified
      timeToCorrectImprovement: 0.2, // Simplified
    );
  }

  List<PersistentIssue> _identifyPersistentIssues(List<MistakeRecord> mistakes) {
    final issues = <PersistentIssue>[];
    
    // Group by specific error type
    final typeGroups = <String, List<MistakeRecord>>{};
    for (final mistake in mistakes) {
      final key = '${mistake.type}_${mistake.details['subtype'] ?? ''}';
      typeGroups[key] ??= [];
      typeGroups[key]!.add(mistake);
    }
    
    // Find persistent ones
    typeGroups.forEach((type, group) {
      if (group.length >= 3) {
        // Check if still occurring recently
        final recentCount = group
            .where((m) => DateTime.now().difference(m.timestamp).inDays < 7)
            .length;
        
        if (recentCount > 0) {
          issues.add(PersistentIssue(
            type: type,
            occurrences: group.length,
            lastOccurrence: group.last.timestamp,
            severity: 'medium',
          ));
        }
      }
    });
    
    return issues;
  }

  ImprovementFactors _analyzeImprovementFactors(List<MistakeRecord> mistakes) {
    return ImprovementFactors(
      rate: 0.05, // 5% improvement per week
      acceleratingFactors: ['Regular practice', 'Targeted exercises'],
      impedingFactors: ['Complex concepts', 'Limited practice time'],
    );
  }

  FutureProjection _projectFutureImprovement({
    required ImprovementMetrics currentMetrics,
    required double improvementRate,
  }) {
    return FutureProjection(
      expectedMasteryDate: DateTime.now().add(Duration(days: 30)),
      projectedAccuracy: math.min(currentMetrics.accuracyImprovement + 0.2, 0.95),
      confidenceInterval: [0.75, 0.9],
    );
  }

  List<ImprovementRecommendation> _generateImprovementRecommendations({
    required ImprovementMetrics metrics,
    required List<PersistentIssue> persistentIssues,
    required FutureProjection projection,
  }) {
    final recommendations = <ImprovementRecommendation>[];
    
    if (persistentIssues.isNotEmpty) {
      recommendations.add(ImprovementRecommendation(
        title: 'Address Persistent Issues',
        description: 'Focus on ${persistentIssues.first.type} errors',
        priority: 1,
        expectedImpact: 'High',
      ));
    }
    
    if (metrics.mistakeRateChange < 0.1) {
      recommendations.add(ImprovementRecommendation(
        title: 'Increase Practice Frequency',
        description: 'More consistent practice will accelerate improvement',
        priority: 2,
        expectedImpact: 'Medium',
      ));
    }
    
    return recommendations;
  }

  List<String> _identifyAchievements(ImprovementMetrics metrics) {
    final achievements = <String>[];
    
    if (metrics.mistakeRateChange > 0.3) {
      achievements.add('Significant mistake reduction!');
    }
    
    if (metrics.accuracyImprovement > 0.2) {
      achievements.add('Notable accuracy improvement!');
    }
    
    if (metrics.conceptMastery > 0.8) {
      achievements.add('Approaching concept mastery!');
    }
    
    return achievements;
  }

  Future<List<CollectiveMistake>> _fetchCollectiveMistakes({
    required String conceptId,
    required int limit,
  }) async {
    // Fetch anonymized mistake data
    return [];
  }

  List<CommonPattern> _identifyCommonPatterns(List<CollectiveMistake> mistakes) {
    final patterns = <CommonPattern>[];
    
    // Group and analyze
    final typeGroups = <String, List<CollectiveMistake>>{};
    for (final mistake in mistakes) {
      typeGroups[mistake.type] ??= [];
      typeGroups[mistake.type]!.add(mistake);
    }
    
    typeGroups.forEach((type, group) {
      if (group.length >= mistakes.length * 0.1) { // 10% threshold
        patterns.add(CommonPattern(
          type: type,
          frequency: group.length / mistakes.length,
          description: 'Common $type error',
          examples: group.take(3).map((m) => m.description).toList(),
        ));
      }
    });
    
    return patterns;
  }

  List<DifficultyIndicator> _analyzeDifficultyIndicators({
    required List<CollectiveMistake> mistakes,
    required List<CommonPattern> patterns,
  }) {
    return [
      DifficultyIndicator(
        aspect: 'Conceptual complexity',
        level: patterns.length > 3 ? 'high' : 'medium',
        evidence: '${patterns.length} common error patterns',
      ),
    ];
  }

  Future<List<EffectiveSolution>> _findEffectiveSolutions({
    required String conceptId,
    required List<CommonPattern> patterns,
  }) async {
    // Find what worked for others
    return [
      EffectiveSolution(
        approach: 'Step-by-step breakdown',
        successRate: 0.85,
        description: 'Breaking complex problems into smaller steps',
      ),
    ];
  }

  List<TeachingInsight> _generateTeachingInsights({
    required List<CommonPattern> patterns,
    required List<EffectiveSolution> solutions,
  }) {
    return [
      TeachingInsight(
        insight: 'Students struggle with ${patterns.first.type}',
        recommendation: 'Emphasize ${solutions.first.approach}',
        evidence: 'Based on ${patterns.first.frequency * 100}% error rate',
      ),
    ];
  }

  Map<String, double> _calculateMistakeDistribution(List<CollectiveMistake> mistakes) {
    final distribution = <String, double>{};
    final total = mistakes.length;
    
    final typeCount = <String, int>{};
    for (final mistake in mistakes) {
      typeCount[mistake.type] = (typeCount[mistake.type] ?? 0) + 1;
    }
    
    typeCount.forEach((type, count) {
      distribution[type] = count / total;
    });
    
    return distribution;
  }

  // Helper methods for solution comparison
  List<int> _findMatchingSteps(StudentSolution student, CorrectSolution correct) {
    final matching = <int>[];
    
    for (int i = 0; i < math.min(student.steps.length, correct.steps.length); i++) {
      if (_areStepsEquivalent(student.steps[i], correct.steps[i])) {
        matching.add(i);
      }
    }
    
    return matching;
  }

  int? _findDivergencePoint(StudentSolution student, CorrectSolution correct) {
    for (int i = 0; i < math.min(student.steps.length, correct.steps.length); i++) {
      if (!_areStepsEquivalent(student.steps[i], correct.steps[i])) {
        return i;
      }
    }
    return null;
  }

  List<String> _findMissingSteps(StudentSolution student, CorrectSolution correct) {
    if (student.steps.length >= correct.steps.length) return [];
    
    return correct.steps
        .skip(student.steps.length)
        .map((s) => s.description)
        .toList();
  }

  List<String> _findExtraSteps(StudentSolution student, CorrectSolution correct) {
    final extra = <String>[];
    
    // Simplified - would need more sophisticated comparison
    if (student.steps.length > correct.steps.length + 2) {
      extra.add('Solution appears overcomplicated');
    }
    
    return extra;
  }

  bool _areStepsEquivalent(SolutionStep step1, SolutionStep step2) {
    // Simplified comparison
    return step1.type == step2.type && step1.result == step2.result;
  }

  String _identifyApproach(StudentSolution solution) {
    // Analyze the general approach taken
    return 'systematic'; // Simplified
  }

  List<String> _identifyMisconceptions(StudentSolution solution, ErrorPoint error) {
    // Identify conceptual misunderstandings
    return [];
  }

  List<String> _identifyStrengths(StudentSolution solution) {
    // Identify what the student did well
    return ['Clear problem setup', 'Organized work'];
  }

  String _analyzeProcessingPattern(StudentSolution solution) {
    // Analyze how student processes information
    return 'sequential';
  }
}

// Data models
class MistakeRecord {
  final String id;
  final String type;
  final String subject;
  final String concept;
  final String description;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final double impactScore;
  final bool preventedProgress;
  final bool affectsUnderstanding;

  MistakeRecord({
    required this.id,
    required this.type,
    required this.subject,
    required this.concept,
    required this.description,
    required this.details,
    required this.timestamp,
    required this.impactScore,
    required this.preventedProgress,
    required this.affectsUnderstanding,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'subject': subject,
    'concept': concept,
    'description': description,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
    'impactScore': impactScore,
    'preventedProgress': preventedProgress,
    'affectsUnderstanding': affectsUnderstanding,
  };
}

class MistakeAnalysisResult {
  final String mistakeId;
  final ImmediateAnalysis immediateAnalysis;
  final List<MistakePattern> patternsDetected;
  final MistakeFeedback feedback;
  final Remediation? remediation;
  final int similarMistakesCount;

  MistakeAnalysisResult({
    required this.mistakeId,
    required this.immediateAnalysis,
    required this.patternsDetected,
    required this.feedback,
    this.remediation,
    required this.similarMistakesCount,
  });
}

class ImmediateAnalysis {
  final String mistakeCategory;
  final String severity;
  final String immediateImpact;
  final List<String> relatedConcepts;

  ImmediateAnalysis({
    required this.mistakeCategory,
    required this.severity,
    required this.immediateImpact,
    required this.relatedConcepts,
  });
}

class MistakePattern {
  final String id;
  final String type;
  final String description;
  final int occurrences;
  final double confidence;
  final List<String> affectedConcepts;
  final List<MistakeRecord> examples;

  MistakePattern({
    required this.id,
    required this.type,
    required this.description,
    required this.occurrences,
    required this.confidence,
    required this.affectedConcepts,
    required this.examples,
  });
}

class MistakeFeedback {
  final String type;
  final String message;
  final List<String> focusPoints;
  final String encouragement;

  MistakeFeedback({
    required this.type,
    required this.message,
    required this.focusPoints,
    required this.encouragement,
  });
}

class Remediation {
  final String patternId;
  final String title;
  final List<String> exercises;
  final int estimatedTime;
  final List<String> resources;

  Remediation({
    required this.patternId,
    required this.title,
    required this.exercises,
    required this.estimatedTime,
    required this.resources,
  });
}

class MistakePatternAnalysis {
  final String userId;
  final DateTimeRange period;
  final int totalMistakes;
  final Map<String, MistakeCategory> mistakeCategories;
  final List<MistakePattern> systematicPatterns;
  final RootCauseAnalysis rootCauseAnalysis;
  final ImprovementTrends improvementTrends;
  final List<KnowledgeGap> knowledgeGaps;
  final List<TargetedIntervention> targetedInterventions;
  final List<MistakeInsight> insights;

  MistakePatternAnalysis({
    required this.userId,
    required this.period,
    required this.totalMistakes,
    required this.mistakeCategories,
    required this.systematicPatterns,
    required this.rootCauseAnalysis,
    required this.improvementTrends,
    required this.knowledgeGaps,
    required this.targetedInterventions,
    required this.insights,
  });
}

class MistakeCategory {
  final String name;
  int count;
  final List<MistakeRecord> mistakes;

  MistakeCategory({
    required this.name,
    required this.count,
    required this.mistakes,
  });
}

class RootCauseAnalysis {
  final Map<String, RootCause> identifiedCauses;
  final String primaryCause;
  final List<String> contributingFactors;

  RootCauseAnalysis({
    required this.identifiedCauses,
    required this.primaryCause,
    required this.contributingFactors,
  });
}

class RootCause {
  final String type;
  final String description;
  final double confidence;
  final List<String> evidence;

  RootCause({
    required this.type,
    required this.description,
    required this.confidence,
    required this.evidence,
  });
}

class ImprovementTrends {
  final String overallTrend;
  final double trendStrength;
  final Map<DateTime, double> weeklyMistakeRates;
  final double improvementRate;

  ImprovementTrends({
    required this.overallTrend,
    required this.trendStrength,
    required this.weeklyMistakeRates,
    required this.improvementRate,
  });
}

class KnowledgeGap {
  final String concept;
  final double severity;
  final List<String> affectedSkills;
  final List<String> recommendedReview;

  KnowledgeGap({
    required this.concept,
    required this.severity,
    required this.affectedSkills,
    required this.recommendedReview,
  });
}

class TargetedIntervention {
  final String target;
  final String type;
  final String title;
  final String description;
  final List<String> activities;
  final int estimatedDuration;
  final int priority;

  TargetedIntervention({
    required this.target,
    required this.type,
    required this.title,
    required this.description,
    required this.activities,
    required this.estimatedDuration,
    required this.priority,
  });
}

class MistakeInsight {
  final String type;
  final String title;
  final String description;
  final String recommendation;

  MistakeInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.recommendation,
  });
}

class MistakePrediction {
  final String conceptId;
  final double mistakeLikelihood;
  final double confidence;
  final List<String> highRiskAreas;
  final List<PreventiveStrategy> preventiveStrategies;
  final double historicalMistakeRate;
  final Map<String, double> contextualFactors;

  MistakePrediction({
    required this.conceptId,
    required this.mistakeLikelihood,
    required this.confidence,
    required this.highRiskAreas,
    required this.preventiveStrategies,
    required this.historicalMistakeRate,
    required this.contextualFactors,
  });
}

class ProblemContext {
  final double complexity;
  final bool hasTimeLimit;
  final bool isNewVariation;
  final bool requiresMultipleSteps;

  ProblemContext({
    required this.complexity,
    required this.hasTimeLimit,
    required this.isNewVariation,
    required this.requiresMultipleSteps,
  });
}

class PreventiveStrategy {
  final String riskArea;
  final String strategy;
  final List<String> checkpoints;

  PreventiveStrategy({
    required this.riskArea,
    required this.strategy,
    required this.checkpoints,
  });
}

class RemediationPlan {
  final String userId;
  final List<MistakePattern> targetPatterns;
  final List<RemediationExercise> exercises;
  final PracticeSchedule schedule;
  final List<RemediationMilestone> milestones;
  final ImprovementTimeline estimatedTimeline;
  final List<SuccessMetric> successMetrics;
  final List<AdaptiveAdjustment> adaptiveAdjustments;

  RemediationPlan({
    required this.userId,
    required this.targetPatterns,
    required this.exercises,
    required this.schedule,
    required this.milestones,
    required this.estimatedTimeline,
    required this.successMetrics,
    required this.adaptiveAdjustments,
  });
}

class RemediationExercise {
  final String id;
  final String type;
  final String title;
  final String description;
  final double difficulty;
  final int estimatedTime;
  final List<String> concepts;

  RemediationExercise({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedTime,
    required this.concepts,
  });
}

class PracticeSchedule {
  final List<PracticeDay> days;

  PracticeSchedule({required this.days});
}

class PracticeDay {
  final int dayNumber;
  final List<RemediationExercise> exercises;
  final int totalTime;

  PracticeDay({
    required this.dayNumber,
    required this.exercises,
    required this.totalTime,
  });
}

class RemediationMilestone {
  final int day;
  final String goal;
  final String assessment;
  final double targetAccuracy;

  RemediationMilestone({
    required this.day,
    required this.goal,
    required this.assessment,
    required this.targetAccuracy,
  });
}

class ImprovementTimeline {
  final int estimatedDays;
  final List<TimelinePhase> phases;

  ImprovementTimeline({
    required this.estimatedDays,
    required this.phases,
  });
}

class TimelinePhase {
  final String name;
  final int duration;
  final String focus;

  TimelinePhase({
    required this.name,
    required this.duration,
    required this.focus,
  });
}

class SuccessMetric {
  final String name;
  final double target;
  final String measurement;

  SuccessMetric({
    required this.name,
    required this.target,
    required this.measurement,
  });
}

class AdaptiveAdjustment {
  final String trigger;
  final String adjustment;

  AdaptiveAdjustment({
    required this.trigger,
    required this.adjustment,
  });
}

class RealTimeMistakeAnalysis {
  final String problemId;
  final String mistakeType;
  final ErrorPoint errorPoint;
  final SolutionComparison comparison;
  final ThinkingAnalysis thinkingAnalysis;
  final bool isRepeatedMistake;
  final Hint hint;
  final CorrectionApproach correctionApproach;
  final String conceptualGap;

  RealTimeMistakeAnalysis({
    required this.problemId,
    required this.mistakeType,
    required this.errorPoint,
    required this.comparison,
    required this.thinkingAnalysis,
    required this.isRepeatedMistake,
    required this.hint,
    required this.correctionApproach,
    required this.conceptualGap,
  });
}

class StudentSolution {
  final List<SolutionStep> steps;
  final String finalAnswer;

  StudentSolution({
    required this.steps,
    required this.finalAnswer,
  });
}

class CorrectSolution {
  final List<SolutionStep> steps;
  final String finalAnswer;

  CorrectSolution({
    required this.steps,
    required this.finalAnswer,
  });
}

class SolutionStep {
  final String type;
  final String description;
  final dynamic result;

  SolutionStep({
    required this.type,
    required this.description,
    this.result,
  });
}

class SolutionComparison {
  final List<int> matchingSteps;
  final int? divergencePoint;
  final List<String> missingSteps;
  final List<String> extraSteps;

  SolutionComparison({
    required this.matchingSteps,
    this.divergencePoint,
    required this.missingSteps,
    required this.extraSteps,
  });
}

class ErrorPoint {
  final int stepNumber;
  final SolutionStep? studentStep;
  final SolutionStep? expectedStep;

  ErrorPoint({
    required this.stepNumber,
    this.studentStep,
    this.expectedStep,
  });
}

class ThinkingAnalysis {
  final String approach;
  final List<String> misconceptions;
  final List<String> strengthsShown;
  final String processingPattern;

  ThinkingAnalysis({
    required this.approach,
    required this.misconceptions,
    required this.strengthsShown,
    required this.processingPattern,
  });
}

class Hint {
  final String content;
  final String level;
  final String? focusArea;

  Hint({
    required this.content,
    required this.level,
    this.focusArea,
  });
}

class CorrectionApproach {
  final List<String> steps;
  final List<String> focusConcepts;
  final int estimatedTime;

  CorrectionApproach({
    required this.steps,
    required this.focusConcepts,
    required this.estimatedTime,
  });
}

class MistakeImprovementReport {
  final String userId;
  final String conceptId;
  final DateTimeRange period;
  final ImprovementMetrics improvementMetrics;
  final List<PersistentIssue> persistentIssues;
  final ImprovementFactors improvementFactors;
  final FutureProjection futureProjection;
  final List<ImprovementRecommendation> recommendations;
  final List<String> celebrateAchievements;

  MistakeImprovementReport({
    required this.userId,
    required this.conceptId,
    required this.period,
    required this.improvementMetrics,
    required this.persistentIssues,
    required this.improvementFactors,
    required this.futureProjection,
    required this.recommendations,
    required this.celebrateAchievements,
  });
}

class ImprovementMetrics {
  final double mistakeRateChange;
  final double accuracyImprovement;
  final double conceptMastery;
  final double timeToCorrectImprovement;

  ImprovementMetrics({
    required this.mistakeRateChange,
    required this.accuracyImprovement,
    required this.conceptMastery,
    required this.timeToCorrectImprovement,
  });
}

class PersistentIssue {
  final String type;
  final int occurrences;
  final DateTime lastOccurrence;
  final String severity;

  PersistentIssue({
    required this.type,
    required this.occurrences,
    required this.lastOccurrence,
    required this.severity,
  });
}

class ImprovementFactors {
  final double rate;
  final List<String> acceleratingFactors;
  final List<String> impedingFactors;

  ImprovementFactors({
    required this.rate,
    required this.acceleratingFactors,
    required this.impedingFactors,
  });
}

class FutureProjection {
  final DateTime expectedMasteryDate;
  final double projectedAccuracy;
  final List<double> confidenceInterval;

  FutureProjection({
    required this.expectedMasteryDate,
    required this.projectedAccuracy,
    required this.confidenceInterval,
  });
}

class ImprovementRecommendation {
  final String title;
  final String description;
  final int priority;
  final String expectedImpact;

  ImprovementRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedImpact,
  });
}

class CollectiveMistakeInsights {
  final String conceptId;
  final int sampleSize;
  final List<CommonPattern> commonPatterns;
  final List<DifficultyIndicator> difficultyIndicators;
  final List<EffectiveSolution> effectiveSolutions;
  final List<TeachingInsight> teachingInsights;
  final Map<String, double> mistakeDistribution;

  CollectiveMistakeInsights({
    required this.conceptId,
    required this.sampleSize,
    required this.commonPatterns,
    required this.difficultyIndicators,
    required this.effectiveSolutions,
    required this.teachingInsights,
    required this.mistakeDistribution,
  });
}

class CollectiveMistake {
  final String type;
  final String description;
  final DateTime timestamp;

  CollectiveMistake({
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

class CommonPattern {
  final String type;
  final double frequency;
  final String description;
  final List<String> examples;

  CommonPattern({
    required this.type,
    required this.frequency,
    required this.description,
    required this.examples,
  });
}

class DifficultyIndicator {
  final String aspect;
  final String level;
  final String evidence;

  DifficultyIndicator({
    required this.aspect,
    required this.level,
    required this.evidence,
  });
}

class EffectiveSolution {
  final String approach;
  final double successRate;
  final String description;

  EffectiveSolution({
    required this.approach,
    required this.successRate,
    required this.description,
  });
}

class TeachingInsight {
  final String insight;
  final String recommendation;
  final String evidence;

  TeachingInsight({
    required this.insight,
    required this.recommendation,
    required this.evidence,
  });
}

// Supporting classes
class ConceptMistake {
  final String conceptId;
  final bool wasMistake;
  final String mistakeType;
  final DateTime timestamp;

  ConceptMistake({
    required this.conceptId,
    required this.wasMistake,
    required this.mistakeType,
    required this.timestamp,
  });
}

class SimilarProblem {
  final String problemId;
  final bool hadMistake;
  final double similarity;

  SimilarProblem({
    required this.problemId,
    required this.hadMistake,
    required this.similarity,
  });
}