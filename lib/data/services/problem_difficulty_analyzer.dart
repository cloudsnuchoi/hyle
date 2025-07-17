import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../../models/service_models.dart' as models;

/// Service for analyzing and adjusting problem difficulty
class ProblemDifficultyAnalyzer {
  static final ProblemDifficultyAnalyzer _instance = ProblemDifficultyAnalyzer._internal();
  factory ProblemDifficultyAnalyzer() => _instance;
  ProblemDifficultyAnalyzer._internal();

  // Item Response Theory (IRT) parameters
  static const double _discriminationDefault = 1.0;
  static const double _guessingDefault = 0.25;
  static const double _irtTheta = 3.0; // Ability range (-3 to 3)
  
  // Difficulty adjustment parameters
  static const double _targetSuccessRate = 0.7;
  static const double _adjustmentFactor = 0.1;
  static const int _minAttemptsForAnalysis = 5;

  /// Analyze problem difficulty based on user performance
  Future<ProblemDifficultyAnalysis> analyzeProblem({
    required String problemId,
    required List<AttemptRecord> attempts,
    Map<String, dynamic>? problemMetadata,
  }) async {
    try {
      if (attempts.isEmpty) {
        return ProblemDifficultyAnalysis(
          problemId: problemId,
          estimatedDifficulty: 0.5,
          confidence: 0.0,
          successRate: 0.0,
          averageTime: 0,
          recommendation: DifficultyRecommendation.maintain,
        );
      }

      // Calculate basic statistics
      final stats = _calculateBasicStats(attempts);
      
      // Estimate difficulty using IRT
      final irtAnalysis = _performIRTAnalysis(attempts);
      
      // Analyze time patterns
      final timeAnalysis = _analyzeTimingPatterns(attempts);
      
      // Analyze error patterns
      final errorPatterns = _analyzeErrorPatterns(attempts);
      
      // Calculate discrimination index
      final discrimination = _calculateDiscrimination(attempts);
      
      // Generate difficulty recommendation
      final recommendation = _generateRecommendation(
        successRate: stats.successRate,
        irtDifficulty: irtAnalysis.difficulty,
        timeAnalysis: timeAnalysis,
      );
      
      // Calculate confidence based on sample size
      final confidence = _calculateConfidence(attempts.length);
      
      return ProblemDifficultyAnalysis(
        problemId: problemId,
        estimatedDifficulty: irtAnalysis.difficulty,
        confidence: confidence,
        successRate: stats.successRate,
        averageTime: stats.averageTime,
        medianTime: stats.medianTime,
        discrimination: discrimination,
        irtParameters: irtAnalysis,
        timeDistribution: timeAnalysis.distribution,
        commonErrors: errorPatterns,
        recommendation: recommendation,
        metadata: {
          'totalAttempts': attempts.length,
          'uniqueUsers': _countUniqueUsers(attempts),
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      safePrint('Error analyzing problem difficulty: $e');
      rethrow;
    }
  }

  /// Calculate optimal difficulty for a user
  Future<OptimalDifficultyRange> calculateOptimalDifficulty({
    required String userId,
    required UserAbilityProfile abilityProfile,
    required String subject,
    LearningObjective? objective,
  }) async {
    try {
      // Get user's current ability level
      final ability = abilityProfile.getAbilityForSubject(subject);
      
      // Consider user's learning style
      final learningStyle = abilityProfile.learningStyle;
      
      // Calculate base optimal difficulty (Zone of Proximal Development)
      double optimalCenter = ability + 0.3; // Slightly above current ability
      
      // Adjust based on learning style
      switch (learningStyle) {
        case LearningStyle.challenger:
          optimalCenter += 0.2; // Prefers harder problems
          break;
        case LearningStyle.steady:
          optimalCenter += 0.1; // Moderate challenge
          break;
        case LearningStyle.cautious:
          optimalCenter -= 0.1; // Prefers easier start
          break;
      }
      
      // Adjust based on recent performance
      final recentPerformance = abilityProfile.recentPerformance;
      if (recentPerformance < 0.5) {
        optimalCenter -= 0.15; // Struggling, reduce difficulty
      } else if (recentPerformance > 0.85) {
        optimalCenter += 0.15; // Excelling, increase difficulty
      }
      
      // Consider cognitive load
      final cognitiveLoad = abilityProfile.currentCognitiveLoad;
      if (cognitiveLoad > 0.8) {
        optimalCenter -= 0.1; // High load, reduce difficulty
      }
      
      // Define range
      final range = 0.3; // ±0.3 from center
      
      return OptimalDifficultyRange(
        userId: userId,
        subject: subject,
        optimalCenter: optimalCenter.clamp(0.0, 1.0),
        lowerBound: (optimalCenter - range).clamp(0.0, 1.0),
        upperBound: (optimalCenter + range).clamp(0.0, 1.0),
        confidence: _calculateAbilityConfidence(abilityProfile),
        factors: {
          'baseAbility': ability,
          'learningStyle': learningStyle.toString(),
          'recentPerformance': recentPerformance,
          'cognitiveLoad': cognitiveLoad,
        },
      );
    } catch (e) {
      safePrint('Error calculating optimal difficulty: $e');
      rethrow;
    }
  }

  /// Recommend next problems based on difficulty
  Future<List<ProblemRecommendation>> recommendProblems({
    required String userId,
    required String subject,
    required OptimalDifficultyRange difficultyRange,
    required List<Problem> availableProblems,
    int count = 5,
    List<String>? excludeProblemIds,
  }) async {
    try {
      // Filter out excluded problems
      var candidates = availableProblems;
      if (excludeProblemIds != null) {
        candidates = candidates.where(
          (p) => !excludeProblemIds.contains(p.id)
        ).toList();
      }
      
      // Score each problem based on difficulty match
      final scoredProblems = <ScoredProblem>[];
      
      for (final problem in candidates) {
        final score = _scoreProblem(
          problem: problem,
          difficultyRange: difficultyRange,
          subject: subject,
        );
        
        scoredProblems.add(ScoredProblem(
          problem: problem,
          score: score.totalScore,
          difficultyMatch: score.difficultyMatch,
          topicRelevance: score.topicRelevance,
          varietyScore: score.varietyScore,
        ));
      }
      
      // Sort by score
      scoredProblems.sort((a, b) => b.score.compareTo(a.score));
      
      // Select top problems with diversity
      final selected = _selectWithDiversity(
        scoredProblems: scoredProblems,
        count: count,
      );
      
      // Convert to recommendations
      final recommendations = <ProblemRecommendation>[];
      for (int i = 0; i < selected.length; i++) {
        final scored = selected[i];
        recommendations.add(ProblemRecommendation(
          problem: scored.problem,
          recommendationScore: scored.score,
          difficulty: scored.problem.difficulty,
          estimatedSuccessProbability: _calculateSuccessProbability(
            userAbility: difficultyRange.optimalCenter,
            problemDifficulty: scored.problem.difficulty,
          ),
          reasons: _generateRecommendationReasons(scored),
          order: i + 1,
        ));
      }
      
      return recommendations;
    } catch (e) {
      safePrint('Error recommending problems: $e');
      rethrow;
    }
  }

  /// Calibrate problem difficulty based on new data
  Future<DifficultyCalibrationResult> calibrateDifficulty({
    required String problemId,
    required double currentDifficulty,
    required List<AttemptRecord> newAttempts,
    CalibrationMethod method = CalibrationMethod.bayesian,
  }) async {
    try {
      switch (method) {
        case CalibrationMethod.bayesian:
          return await _bayesianCalibration(
            problemId: problemId,
            priorDifficulty: currentDifficulty,
            newAttempts: newAttempts,
          );
          
        case CalibrationMethod.irt:
          return await _irtCalibration(
            problemId: problemId,
            currentDifficulty: currentDifficulty,
            attempts: newAttempts,
          );
          
        case CalibrationMethod.elo:
          return await _eloCalibration(
            problemId: problemId,
            currentDifficulty: currentDifficulty,
            attempts: newAttempts,
          );
      }
    } catch (e) {
      safePrint('Error calibrating difficulty: $e');
      rethrow;
    }
  }

  /// Analyze difficulty progression for a user
  Future<DifficultyProgressionAnalysis> analyzeProgression({
    required String userId,
    required String subject,
    required List<ProblemAttempt> attempts,
    required DateTimeRange period,
  }) async {
    try {
      // Group attempts by time periods
      final weeklyGroups = _groupAttemptsByWeek(attempts, period);
      
      // Calculate difficulty progression
      final progression = <DifficultyProgressionPoint>[];
      
      for (final entry in weeklyGroups.entries) {
        final weekAttempts = entry.value;
        final avgDifficulty = _calculateAverageDifficulty(weekAttempts);
        final successRate = _calculateSuccessRate(weekAttempts);
        
        progression.add(DifficultyProgressionPoint(
          week: entry.key,
          averageDifficulty: avgDifficulty,
          successRate: successRate,
          attemptCount: weekAttempts.length,
          masteryLevel: _calculateMasteryLevel(avgDifficulty, successRate),
        ));
      }
      
      // Analyze trends
      final trend = _analyzeDifficultyTrend(progression);
      
      // Calculate optimal progression rate
      final optimalRate = _calculateOptimalProgressionRate(
        currentProgression: progression,
        userProfile: userId,
      );
      
      // Generate insights
      final insights = _generateProgressionInsights(
        progression: progression,
        trend: trend,
        optimalRate: optimalRate,
      );
      
      return DifficultyProgressionAnalysis(
        userId: userId,
        subject: subject,
        period: period,
        progression: progression,
        currentDifficulty: progression.isNotEmpty ? progression.last.averageDifficulty : 0.5,
        trend: trend,
        optimalProgressionRate: optimalRate,
        insights: insights,
        recommendations: _generateProgressionRecommendations(trend, optimalRate),
      );
    } catch (e) {
      safePrint('Error analyzing difficulty progression: $e');
      rethrow;
    }
  }

  /// Validate problem difficulty consistency
  Future<DifficultyValidation> validateDifficulty({
    required String problemId,
    required double assignedDifficulty,
    required List<AttemptRecord> attempts,
    required Map<String, double> similarProblemDifficulties,
  }) async {
    try {
      // Calculate empirical difficulty
      final empiricalAnalysis = await analyzeProblem(
        problemId: problemId,
        attempts: attempts,
      );
      
      // Compare with assigned difficulty
      final difference = (assignedDifficulty - empiricalAnalysis.estimatedDifficulty).abs();
      
      // Check consistency with similar problems
      final similarityScore = _calculateSimilarityConsistency(
        assignedDifficulty: assignedDifficulty,
        similarDifficulties: similarProblemDifficulties,
      );
      
      // Identify anomalies
      final anomalies = _detectDifficultyAnomalies(
        assignedDifficulty: assignedDifficulty,
        empiricalDifficulty: empiricalAnalysis.estimatedDifficulty,
        attempts: attempts,
      );
      
      // Generate validation result
      final isValid = difference < 0.2 && similarityScore > 0.7 && anomalies.isEmpty;
      
      return DifficultyValidation(
        problemId: problemId,
        isValid: isValid,
        assignedDifficulty: assignedDifficulty,
        empiricalDifficulty: empiricalAnalysis.estimatedDifficulty,
        difference: difference,
        similarityScore: similarityScore,
        anomalies: anomalies,
        suggestedDifficulty: _calculateSuggestedDifficulty(
          assigned: assignedDifficulty,
          empirical: empiricalAnalysis.estimatedDifficulty,
          similar: similarProblemDifficulties,
        ),
        confidence: empiricalAnalysis.confidence,
      );
    } catch (e) {
      safePrint('Error validating difficulty: $e');
      rethrow;
    }
  }

  // Private helper methods
  _BasicStats _calculateBasicStats(List<AttemptRecord> attempts) {
    final successCount = attempts.where((a) => a.isCorrect).length;
    final times = attempts.map((a) => a.timeSpent).toList()..sort();
    
    return _BasicStats(
      successRate: successCount / attempts.length,
      averageTime: times.reduce((a, b) => a + b) / times.length,
      medianTime: times[times.length ~/ 2],
    );
  }

  IRTAnalysis _performIRTAnalysis(List<AttemptRecord> attempts) {
    // Simplified 2-parameter IRT model
    // P(correct) = c + (1-c) / (1 + e^(-a(θ-b)))
    // where: a = discrimination, b = difficulty, c = guessing, θ = ability
    
    // Group by user ability
    final abilityGroups = <double, List<bool>>{};
    for (final attempt in attempts) {
      final ability = attempt.userAbility ?? 0.5;
      abilityGroups[ability] ??= [];
      abilityGroups[ability]!.add(attempt.isCorrect);
    }
    
    // Estimate parameters using method of moments
    double sumDifficulty = 0;
    double count = 0;
    
    abilityGroups.forEach((ability, results) {
      final successRate = results.where((r) => r).length / results.length;
      // Inverse logit to estimate difficulty
      if (successRate > 0 && successRate < 1) {
        final logit = math.log(successRate / (1 - successRate));
        sumDifficulty += ability - (logit / _discriminationDefault);
        count++;
      }
    });
    
    final difficulty = count > 0 ? sumDifficulty / count : 0.5;
    
    return IRTAnalysis(
      difficulty: difficulty.clamp(0.0, 1.0),
      discrimination: _discriminationDefault,
      guessing: _guessingDefault,
    );
  }

  _TimeAnalysis _analyzeTimingPatterns(List<AttemptRecord> attempts) {
    final times = attempts.map((a) => a.timeSpent.toDouble()).toList();
    times.sort();
    
    // Calculate distribution
    final distribution = <String, double>{};
    if (times.isNotEmpty) {
      distribution['min'] = times.first;
      distribution['q1'] = times[times.length ~/ 4];
      distribution['median'] = times[times.length ~/ 2];
      distribution['q3'] = times[(times.length * 3) ~/ 4];
      distribution['max'] = times.last;
      distribution['mean'] = times.reduce((a, b) => a + b) / times.length;
    }
    
    return _TimeAnalysis(distribution: distribution);
  }

  List<ErrorPattern> _analyzeErrorPatterns(List<AttemptRecord> attempts) {
    final errorPatterns = <String, int>{};
    
    for (final attempt in attempts) {
      if (!attempt.isCorrect && attempt.errorType != null) {
        errorPatterns[attempt.errorType!] = 
            (errorPatterns[attempt.errorType!] ?? 0) + 1;
      }
    }
    
    return errorPatterns.entries
        .map((e) => ErrorPattern(
          type: e.key,
          frequency: e.value,
          percentage: e.value / attempts.length,
        ))
        .toList()
      ..sort((a, b) => b.frequency.compareTo(a.frequency));
  }

  double _calculateDiscrimination(List<AttemptRecord> attempts) {
    if (attempts.length < _minAttemptsForAnalysis) return 0.5;
    
    // Sort by user ability
    final sorted = List<AttemptRecord>.from(attempts)
      ..sort((a, b) => (a.userAbility ?? 0.5).compareTo(b.userAbility ?? 0.5));
    
    // Calculate success rate for top and bottom quartiles
    final quartileSize = sorted.length ~/ 4;
    if (quartileSize == 0) return 0.5;
    
    final topQuartile = sorted.sublist(sorted.length - quartileSize);
    final bottomQuartile = sorted.sublist(0, quartileSize);
    
    final topSuccess = topQuartile.where((a) => a.isCorrect).length / quartileSize;
    final bottomSuccess = bottomQuartile.where((a) => a.isCorrect).length / quartileSize;
    
    return (topSuccess - bottomSuccess).clamp(0.0, 1.0);
  }

  DifficultyRecommendation _generateRecommendation(
      {required double successRate,
      required double irtDifficulty,
      required _TimeAnalysis timeAnalysis}) {
    if (successRate < 0.5) {
      return DifficultyRecommendation.decrease;
    } else if (successRate > 0.85) {
      return DifficultyRecommendation.increase;
    } else {
      return DifficultyRecommendation.maintain;
    }
  }

  double _calculateConfidence(int sampleSize) {
    // Confidence increases with sample size, asymptotically approaching 1
    return 1 - math.exp(-sampleSize / 20);
  }

  int _countUniqueUsers(List<AttemptRecord> attempts) {
    return attempts.map((a) => a.userId).toSet().length;
  }

  double _calculateAbilityConfidence(UserAbilityProfile profile) {
    // Based on number of attempts and recency
    final recentAttempts = profile.recentAttemptCount;
    final consistency = profile.performanceConsistency;
    
    return (0.7 * (1 - math.exp(-recentAttempts / 10)) + 
            0.3 * consistency).clamp(0.0, 1.0);
  }

  _ProblemScore _scoreProblem({
    required Problem problem,
    required OptimalDifficultyRange difficultyRange,
    required String subject,
  }) {
    // Difficulty match score (Gaussian curve)
    final difficultyDiff = (problem.difficulty - difficultyRange.optimalCenter).abs();
    final difficultyMatch = math.exp(-math.pow(difficultyDiff * 5, 2));
    
    // Topic relevance (simplified - would use actual topic matching)
    final topicRelevance = problem.subject == subject ? 1.0 : 0.5;
    
    // Variety score (prefer problems from different categories)
    final varietyScore = 0.8; // Simplified
    
    final totalScore = 0.5 * difficultyMatch + 
                      0.3 * topicRelevance + 
                      0.2 * varietyScore;
    
    return _ProblemScore(
      totalScore: totalScore,
      difficultyMatch: difficultyMatch,
      topicRelevance: topicRelevance,
      varietyScore: varietyScore,
    );
  }

  List<ScoredProblem> _selectWithDiversity({
    required List<ScoredProblem> scoredProblems,
    required int count,
  }) {
    if (scoredProblems.length <= count) return scoredProblems;
    
    final selected = <ScoredProblem>[];
    final remaining = List<ScoredProblem>.from(scoredProblems);
    
    // Select first problem (highest score)
    selected.add(remaining.removeAt(0));
    
    // Select remaining with diversity consideration
    while (selected.length < count && remaining.isNotEmpty) {
      // Find problem that maximizes score + diversity
      ScoredProblem? best;
      double bestCombinedScore = -1;
      
      for (final candidate in remaining) {
        final diversity = _calculateDiversity(candidate, selected);
        final combinedScore = 0.7 * candidate.score + 0.3 * diversity;
        
        if (combinedScore > bestCombinedScore) {
          bestCombinedScore = combinedScore;
          best = candidate;
        }
      }
      
      if (best != null) {
        selected.add(best);
        remaining.remove(best);
      }
    }
    
    return selected;
  }

  double _calculateDiversity(
    ScoredProblem candidate,
    List<ScoredProblem> selected,
  ) {
    if (selected.isEmpty) return 1.0;
    
    // Calculate diversity based on problem types and difficulties
    double totalDiversity = 0;
    
    for (final existing in selected) {
      final typeDiff = candidate.problem.type != existing.problem.type ? 1.0 : 0.0;
      final difficultyDiff = (candidate.problem.difficulty - 
                             existing.problem.difficulty).abs();
      
      totalDiversity += 0.5 * typeDiff + 0.5 * difficultyDiff;
    }
    
    return totalDiversity / selected.length;
  }

  double _calculateSuccessProbability({
    required double userAbility,
    required double problemDifficulty,
  }) {
    // 2PL IRT model
    final exponent = _discriminationDefault * (userAbility - problemDifficulty);
    return 1 / (1 + math.exp(-exponent));
  }

  List<String> _generateRecommendationReasons(ScoredProblem scored) {
    final reasons = <String>[];
    
    if (scored.difficultyMatch > 0.8) {
      reasons.add('난이도가 현재 실력에 적합합니다');
    }
    if (scored.topicRelevance > 0.8) {
      reasons.add('학습 중인 주제와 직접적으로 관련됩니다');
    }
    if (scored.varietyScore > 0.8) {
      reasons.add('다양한 문제 유형을 경험할 수 있습니다');
    }
    
    return reasons;
  }

  // Additional helper methods would be implemented here...
  Future<DifficultyCalibrationResult> _bayesianCalibration({
    required String problemId,
    required double priorDifficulty,
    required List<AttemptRecord> newAttempts,
  }) async {
    // Bayesian update implementation
    final priorWeight = 10.0; // Prior strength
    final newData = await analyzeProblem(
      problemId: problemId,
      attempts: newAttempts,
    );
    
    final posteriorDifficulty = 
        (priorWeight * priorDifficulty + newAttempts.length * newData.estimatedDifficulty) /
        (priorWeight + newAttempts.length);
    
    return DifficultyCalibrationResult(
      problemId: problemId,
      oldDifficulty: priorDifficulty,
      newDifficulty: posteriorDifficulty,
      confidence: newData.confidence,
      method: CalibrationMethod.bayesian,
      adjustmentMagnitude: (posteriorDifficulty - priorDifficulty).abs(),
    );
  }

  Future<DifficultyCalibrationResult> _irtCalibration({
    required String problemId,
    required double currentDifficulty,
    required List<AttemptRecord> attempts,
  }) async {
    // IRT calibration implementation
    final irtAnalysis = _performIRTAnalysis(attempts);
    
    return DifficultyCalibrationResult(
      problemId: problemId,
      oldDifficulty: currentDifficulty,
      newDifficulty: irtAnalysis.difficulty,
      confidence: _calculateConfidence(attempts.length),
      method: CalibrationMethod.irt,
      adjustmentMagnitude: (irtAnalysis.difficulty - currentDifficulty).abs(),
    );
  }

  Future<DifficultyCalibrationResult> _eloCalibration({
    required String problemId,
    required double currentDifficulty,
    required List<AttemptRecord> attempts,
  }) async {
    // ELO-style calibration
    double eloDifficulty = currentDifficulty * 1000; // Convert to ELO scale
    const double k = 32; // K-factor
    
    for (final attempt in attempts) {
      final userRating = (attempt.userAbility ?? 0.5) * 1000;
      final expectedScore = 1 / (1 + math.pow(10, (eloDifficulty - userRating) / 400));
      final actualScore = attempt.isCorrect ? 1.0 : 0.0;
      
      eloDifficulty = eloDifficulty + k * (actualScore - expectedScore);
    }
    
    final newDifficulty = (eloDifficulty / 1000).clamp(0.0, 1.0);
    
    return DifficultyCalibrationResult(
      problemId: problemId,
      oldDifficulty: currentDifficulty,
      newDifficulty: newDifficulty,
      confidence: _calculateConfidence(attempts.length),
      method: CalibrationMethod.elo,
      adjustmentMagnitude: (newDifficulty - currentDifficulty).abs(),
    );
  }

  // Stub implementations for remaining helper methods
  Map<String, List<ProblemAttempt>> _groupAttemptsByWeek(
    List<ProblemAttempt> attempts,
    DateTimeRange period,
  ) => {};

  double _calculateAverageDifficulty(List<ProblemAttempt> attempts) => 0.5;
  double _calculateSuccessRate(List<ProblemAttempt> attempts) => 0.7;
  double _calculateMasteryLevel(double difficulty, double successRate) => 0.6;
  
  DifficultyTrend _analyzeDifficultyTrend(
    List<DifficultyProgressionPoint> progression,
  ) => DifficultyTrend.increasing;

  double _calculateOptimalProgressionRate({
    required List<DifficultyProgressionPoint> currentProgression,
    required String userProfile,
  }) => 0.05;

  List<String> _generateProgressionInsights({
    required List<DifficultyProgressionPoint> progression,
    required DifficultyTrend trend,
    required double optimalRate,
  }) => [];

  List<String> _generateProgressionRecommendations(
    DifficultyTrend trend,
    double optimalRate,
  ) => [];

  double _calculateSimilarityConsistency({
    required double assignedDifficulty,
    required Map<String, double> similarDifficulties,
  }) => 0.8;

  List<DifficultyAnomaly> _detectDifficultyAnomalies({
    required double assignedDifficulty,
    required double empiricalDifficulty,
    required List<AttemptRecord> attempts,
  }) => [];

  double _calculateSuggestedDifficulty({
    required double assigned,
    required double empirical,
    required Map<String, double> similar,
  }) => empirical;
}

// Data models
class ProblemDifficultyAnalysis {
  final String problemId;
  final double estimatedDifficulty;
  final double confidence;
  final double successRate;
  final double averageTime;
  final double? medianTime;
  final double? discrimination;
  final IRTAnalysis? irtParameters;
  final Map<String, double>? timeDistribution;
  final List<ErrorPattern>? commonErrors;
  final DifficultyRecommendation recommendation;
  final Map<String, dynamic>? metadata;

  ProblemDifficultyAnalysis({
    required this.problemId,
    required this.estimatedDifficulty,
    required this.confidence,
    required this.successRate,
    required this.averageTime,
    this.medianTime,
    this.discrimination,
    this.irtParameters,
    this.timeDistribution,
    this.commonErrors,
    required this.recommendation,
    this.metadata,
  });
}

class AttemptRecord {
  final String userId;
  final bool isCorrect;
  final int timeSpent; // seconds
  final double? userAbility;
  final String? errorType;
  final DateTime timestamp;

  AttemptRecord({
    required this.userId,
    required this.isCorrect,
    required this.timeSpent,
    this.userAbility,
    this.errorType,
    required this.timestamp,
  });
}

class UserAbilityProfile {
  final String userId;
  final Map<String, double> subjectAbilities;
  final LearningStyle learningStyle;
  final double recentPerformance;
  final double currentCognitiveLoad;
  final int recentAttemptCount;
  final double performanceConsistency;

  UserAbilityProfile({
    required this.userId,
    required this.subjectAbilities,
    required this.learningStyle,
    required this.recentPerformance,
    required this.currentCognitiveLoad,
    required this.recentAttemptCount,
    required this.performanceConsistency,
  });

  double getAbilityForSubject(String subject) {
    return subjectAbilities[subject] ?? 0.5;
  }
}

class OptimalDifficultyRange {
  final String userId;
  final String subject;
  final double optimalCenter;
  final double lowerBound;
  final double upperBound;
  final double confidence;
  final Map<String, dynamic> factors;

  OptimalDifficultyRange({
    required this.userId,
    required this.subject,
    required this.optimalCenter,
    required this.lowerBound,
    required this.upperBound,
    required this.confidence,
    required this.factors,
  });
}

class Problem {
  final String id;
  final String subject;
  final String type;
  final double difficulty;
  final List<String> topics;
  final Map<String, dynamic>? metadata;

  Problem({
    required this.id,
    required this.subject,
    required this.type,
    required this.difficulty,
    required this.topics,
    this.metadata,
  });
}

class ProblemRecommendation {
  final Problem problem;
  final double recommendationScore;
  final double difficulty;
  final double estimatedSuccessProbability;
  final List<String> reasons;
  final int order;

  ProblemRecommendation({
    required this.problem,
    required this.recommendationScore,
    required this.difficulty,
    required this.estimatedSuccessProbability,
    required this.reasons,
    required this.order,
  });
}

class DifficultyCalibrationResult {
  final String problemId;
  final double oldDifficulty;
  final double newDifficulty;
  final double confidence;
  final CalibrationMethod method;
  final double adjustmentMagnitude;

  DifficultyCalibrationResult({
    required this.problemId,
    required this.oldDifficulty,
    required this.newDifficulty,
    required this.confidence,
    required this.method,
    required this.adjustmentMagnitude,
  });
}

class ProblemAttempt {
  final String problemId;
  final String userId;
  final double difficulty;
  final bool isCorrect;
  final DateTime timestamp;

  ProblemAttempt({
    required this.problemId,
    required this.userId,
    required this.difficulty,
    required this.isCorrect,
    required this.timestamp,
  });
}

class DifficultyProgressionAnalysis {
  final String userId;
  final String subject;
  final DateTimeRange period;
  final List<DifficultyProgressionPoint> progression;
  final double currentDifficulty;
  final DifficultyTrend trend;
  final double optimalProgressionRate;
  final List<String> insights;
  final List<String> recommendations;

  DifficultyProgressionAnalysis({
    required this.userId,
    required this.subject,
    required this.period,
    required this.progression,
    required this.currentDifficulty,
    required this.trend,
    required this.optimalProgressionRate,
    required this.insights,
    required this.recommendations,
  });
}

class DifficultyProgressionPoint {
  final String week;
  final double averageDifficulty;
  final double successRate;
  final int attemptCount;
  final double masteryLevel;

  DifficultyProgressionPoint({
    required this.week,
    required this.averageDifficulty,
    required this.successRate,
    required this.attemptCount,
    required this.masteryLevel,
  });
}

class DifficultyValidation {
  final String problemId;
  final bool isValid;
  final double assignedDifficulty;
  final double empiricalDifficulty;
  final double difference;
  final double similarityScore;
  final List<DifficultyAnomaly> anomalies;
  final double suggestedDifficulty;
  final double confidence;

  DifficultyValidation({
    required this.problemId,
    required this.isValid,
    required this.assignedDifficulty,
    required this.empiricalDifficulty,
    required this.difference,
    required this.similarityScore,
    required this.anomalies,
    required this.suggestedDifficulty,
    required this.confidence,
  });
}

class IRTAnalysis {
  final double difficulty;
  final double discrimination;
  final double guessing;

  IRTAnalysis({
    required this.difficulty,
    required this.discrimination,
    required this.guessing,
  });
}

class ErrorPattern {
  final String type;
  final int frequency;
  final double percentage;

  ErrorPattern({
    required this.type,
    required this.frequency,
    required this.percentage,
  });
}

class ScoredProblem {
  final Problem problem;
  final double score;
  final double difficultyMatch;
  final double topicRelevance;
  final double varietyScore;

  ScoredProblem({
    required this.problem,
    required this.score,
    required this.difficultyMatch,
    required this.topicRelevance,
    required this.varietyScore,
  });
}

class DifficultyAnomaly {
  final String type;
  final String description;
  final double severity;

  DifficultyAnomaly({
    required this.type,
    required this.description,
    required this.severity,
  });
}

// Enums
enum DifficultyRecommendation {
  increase,
  maintain,
  decrease,
}

enum LearningStyle {
  challenger,
  steady,
  cautious,
}

enum CalibrationMethod {
  bayesian,
  irt,
  elo,
}

enum DifficultyTrend {
  increasing,
  stable,
  decreasing,
  erratic,
}

enum LearningObjective {
  mastery,
  exploration,
  review,
  assessment,
}

// Private helper classes
class _BasicStats {
  final double successRate;
  final double averageTime;
  final double medianTime;

  _BasicStats({
    required this.successRate,
    required this.averageTime,
    required this.medianTime,
  });
}

class _TimeAnalysis {
  final Map<String, double> distribution;

  _TimeAnalysis({required this.distribution});
}

class _ProblemScore {
  final double totalScore;
  final double difficultyMatch;
  final double topicRelevance;
  final double varietyScore;

  _ProblemScore({
    required this.totalScore,
    required this.difficultyMatch,
    required this.topicRelevance,
    required this.varietyScore,
  });
}