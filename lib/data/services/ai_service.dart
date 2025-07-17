import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_models.dart';

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  // AI Study Planner - Natural language input
  Future<StudyPlan> generateStudyPlan({
    required String userPrompt,
    required UserContext context,
  }) async {
    try {
      // Call Lambda function that connects to Bedrock
      final operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: '''
            mutation GenerateStudyPlan(\$input: GenerateStudyPlanInput!) {
              generateStudyPlan(input: \$input) {
                id
                tasks {
                  title
                  subject
                  estimatedMinutes
                  priority
                  suggestedTime
                }
                totalHours
                recommendations
              }
            }
          ''',
          variables: {
            'input': {
              'prompt': userPrompt,
              'userLevel': context.level,
              'learningType': context.learningType,
              'availableHours': context.availableHours,
              'subjects': context.subjects,
              'examDate': context.examDate?.toIso8601String(),
            }
          },
        ),
      );
      
      final response = await operation.response;
      final data = json.decode(response.data!);
      return StudyPlan.fromJson(data['generateStudyPlan']);
    } catch (e) {
      safePrint('Error generating study plan: $e');
      rethrow;
    }
  }

  // Real-time Study Session Analysis
  Future<SessionFeedback> analyzeStudySession({
    required String sessionId,
    required SessionMetrics metrics,
  }) async {
    try {
      final operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: '''
            mutation AnalyzeSession(\$input: AnalyzeSessionInput!) {
              analyzeSession(input: \$input) {
                productivityScore
                focusLevel
                suggestions
                breakRecommended
                nextBestAction
              }
            }
          ''',
          variables: {
            'input': {
              'sessionId': sessionId,
              'duration': metrics.duration.inMinutes,
              'pauseCount': metrics.pauseCount,
              'taskCompletionRate': metrics.taskCompletionRate,
              'timeOfDay': metrics.timeOfDay,
              'subject': metrics.subject,
            }
          },
        ),
      );
      
      final response = await operation.response;
      final data = json.decode(response.data!);
      return SessionFeedback.fromJson(data['analyzeSession']);
    } catch (e) {
      safePrint('Error analyzing session: $e');
      rethrow;
    }
  }

  // Predict task completion time based on historical data
  Future<int> predictTaskDuration({
    required String taskTitle,
    required String subject,
    required String userId,
  }) async {
    try {
      final operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: '''
            query PredictDuration(\$input: PredictDurationInput!) {
              predictTaskDuration(input: \$input) {
                estimatedMinutes
                confidence
                basedOnSessions
              }
            }
          ''',
          variables: {
            'input': {
              'taskTitle': taskTitle,
              'subject': subject,
              'userId': userId,
            }
          },
        ),
      );
      
      final response = await operation.response;
      final data = json.decode(response.data!);
      return data['predictTaskDuration']['estimatedMinutes'];
    } catch (e) {
      safePrint('Error predicting duration: $e');
      return 30; // Default fallback
    }
  }

  // Get personalized learning insights
  Future<List<StudyInsight>> getPersonalizedInsights({
    required String userId,
    required InsightType type,
  }) async {
    try {
      final operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: '''
            query GetInsights(\$userId: ID!, \$type: InsightType) {
              listStudyInsights(
                filter: {
                  userID: {eq: \$userId}
                  type: {eq: \$type}
                  dismissed: {eq: false}
                }
                sortDirection: DESC
                limit: 10
              ) {
                items {
                  id
                  type
                  title
                  description
                  data
                  importance
                  actionable
                  createdAt
                }
              }
            }
          ''',
          variables: {
            'userId': userId,
            'type': type.toString().split('.').last,
          },
        ),
      );
      
      final response = await operation.response;
      final data = json.decode(response.data!);
      return (data['listStudyInsights']['items'] as List)
          .map((item) => StudyInsight.fromJson(item))
          .toList();
    } catch (e) {
      safePrint('Error getting insights: $e');
      return [];
    }
  }

  // Real-time decision support
  Future<String> getRealtimeAdvice({
    required StudyContext context,
    required String question,
  }) async {
    try {
      final operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: '''
            mutation GetAdvice(\$input: GetAdviceInput!) {
              getRealtimeAdvice(input: \$input) {
                advice
                confidence
                reasoning
              }
            }
          ''',
          variables: {
            'input': {
              'question': question,
              'currentActivity': context.currentActivity,
              'timeStudied': context.timeStudied.inMinutes,
              'energyLevel': context.energyLevel,
              'upcomingDeadlines': context.upcomingDeadlines,
              'recentPerformance': context.recentPerformance,
            }
          },
        ),
      );
      
      final response = await operation.response;
      final data = json.decode(response.data!);
      return data['getRealtimeAdvice']['advice'];
    } catch (e) {
      safePrint('Error getting advice: $e');
      return 'Keep up the good work! Take a break if you feel tired.';
    }
  }

  // Learning pattern analysis
  Future<LearningPattern> analyzeLearningPattern({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: '''
            query AnalyzePattern(\$input: AnalyzePatternInput!) {
              analyzeLearningPattern(input: \$input) {
                peakHours
                bestSubjects
                averageSessionLength
                consistencyScore
                recommendations
                strengths
                areasForImprovement
              }
            }
          ''',
          variables: {
            'input': {
              'userId': userId,
              'startDate': startDate.toIso8601String(),
              'endDate': endDate.toIso8601String(),
            }
          },
        ),
      );
      
      final response = await operation.response;
      final data = json.decode(response.data!);
      return LearningPattern.fromJson(data['analyzeLearningPattern']);
    } catch (e) {
      safePrint('Error analyzing pattern: $e');
      rethrow;
    }
  }
}

// Data Models
class StudyPlan {
  final String id;
  final List<PlannedTask> tasks;
  final double totalHours;
  final List<String> recommendations;

  StudyPlan({
    required this.id,
    required this.tasks,
    required this.totalHours,
    required this.recommendations,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      id: json['id'],
      tasks: (json['tasks'] as List)
          .map((task) => PlannedTask.fromJson(task))
          .toList(),
      totalHours: json['totalHours'].toDouble(),
      recommendations: List<String>.from(json['recommendations']),
    );
  }
}

class PlannedTask {
  final String title;
  final String subject;
  final int estimatedMinutes;
  final String priority;
  final DateTime? suggestedTime;

  PlannedTask({
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    required this.priority,
    this.suggestedTime,
  });

  factory PlannedTask.fromJson(Map<String, dynamic> json) {
    return PlannedTask(
      title: json['title'],
      subject: json['subject'],
      estimatedMinutes: json['estimatedMinutes'],
      priority: json['priority'],
      suggestedTime: json['suggestedTime'] != null
          ? DateTime.parse(json['suggestedTime'])
          : null,
    );
  }
}

class SessionFeedback {
  final double productivityScore;
  final String focusLevel;
  final List<String> suggestions;
  final bool breakRecommended;
  final String nextBestAction;

  SessionFeedback({
    required this.productivityScore,
    required this.focusLevel,
    required this.suggestions,
    required this.breakRecommended,
    required this.nextBestAction,
  });

  factory SessionFeedback.fromJson(Map<String, dynamic> json) {
    return SessionFeedback(
      productivityScore: json['productivityScore'].toDouble(),
      focusLevel: json['focusLevel'],
      suggestions: List<String>.from(json['suggestions']),
      breakRecommended: json['breakRecommended'],
      nextBestAction: json['nextBestAction'],
    );
  }
}

class UserContext {
  final int level;
  final String learningType;
  final double availableHours;
  final List<String> subjects;
  final DateTime? examDate;

  UserContext({
    required this.level,
    required this.learningType,
    required this.availableHours,
    required this.subjects,
    this.examDate,
  });
}

class SessionMetrics {
  final Duration duration;
  final int pauseCount;
  final double taskCompletionRate;
  final String timeOfDay;
  final String subject;

  SessionMetrics({
    required this.duration,
    required this.pauseCount,
    required this.taskCompletionRate,
    required this.timeOfDay,
    required this.subject,
  });
}

class StudyContext {
  final String currentActivity;
  final Duration timeStudied;
  final int energyLevel;
  final List<String> upcomingDeadlines;
  final Map<String, double> recentPerformance;

  StudyContext({
    required this.currentActivity,
    required this.timeStudied,
    required this.energyLevel,
    required this.upcomingDeadlines,
    required this.recentPerformance,
  });
}

class LearningPattern {
  final List<int> peakHours;
  final List<String> bestSubjects;
  final int averageSessionLength;
  final double consistencyScore;
  final List<String> recommendations;
  final List<String> strengths;
  final List<String> areasForImprovement;

  LearningPattern({
    required this.peakHours,
    required this.bestSubjects,
    required this.averageSessionLength,
    required this.consistencyScore,
    required this.recommendations,
    required this.strengths,
    required this.areasForImprovement,
  });

  factory LearningPattern.fromJson(Map<String, dynamic> json) {
    return LearningPattern(
      peakHours: List<int>.from(json['peakHours']),
      bestSubjects: List<String>.from(json['bestSubjects']),
      averageSessionLength: json['averageSessionLength'],
      consistencyScore: json['consistencyScore'].toDouble(),
      recommendations: List<String>.from(json['recommendations']),
      strengths: List<String>.from(json['strengths']),
      areasForImprovement: List<String>.from(json['areasForImprovement']),
    );
  }
}

// Placeholder for StudyInsight model
class StudyInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final int importance;
  final bool actionable;
  final DateTime createdAt;

  StudyInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.data,
    required this.importance,
    required this.actionable,
    required this.createdAt,
  });

  factory StudyInsight.fromJson(Map<String, dynamic> json) {
    return StudyInsight(
      id: json['id'],
      type: InsightType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'],
      description: json['description'],
      data: json['data'],
      importance: json['importance'],
      actionable: json['actionable'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum InsightType {
  PATTERN,
  WARNING,
  ACHIEVEMENT,
  RECOMMENDATION,
  MILESTONE,
}