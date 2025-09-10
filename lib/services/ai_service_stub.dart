import 'package:flutter_riverpod/flutter_riverpod.dart';

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  // Additional methods for real-time feedback
  Future<SessionFeedback> analyzeStudySession({
    required String sessionId,
    required SessionMetrics metrics,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return SessionFeedback(
      id: sessionId,
      summary: 'Good study session!',
      focusScore: 0.8,
      suggestions: ['Take a 5-minute break', 'Stay hydrated'],
      metrics: {'productivity': 0.75},
      breakRecommended: false,
      productivityScore: 0.75,
      focusLevel: 0.8,
    );
  }

  Future<String> getRealtimeAdvice({
    required StudyContext context,
    required String question,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'Keep up the good work! Consider taking a short break soon.';
  }

  // Stub implementation for AI service
  Future<StudyPlan> generateStudyPlan({
    required String userPrompt,
    required UserContext context,
  }) async {
    // Return mock data for now
    await Future.delayed(const Duration(seconds: 1));
    return StudyPlan(
      id: 'mock_plan_1',
      tasks: [
        StudyTask(
          title: '학습 계획 1',
          subject: '수학',
          estimatedMinutes: 30,
          priority: 'high',
        ),
      ],
      totalHours: 1.0,
      recommendations: ['열심히 공부하세요!'],
    );
  }
}

class StudyPlan {
  final String id;
  final List<StudyTask> tasks;
  final double totalHours;
  final List<String> recommendations;

  StudyPlan({
    required this.id,
    required this.tasks,
    required this.totalHours,
    required this.recommendations,
  });
}

class StudyTask {
  final String id;
  final String title;
  final String subject;
  final int estimatedMinutes;
  final String priority;
  final String? suggestedTime;

  StudyTask({
    String? id,
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    required this.priority,
    this.suggestedTime,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

// PlannedTask is an alias for StudyTask
class PlannedTask extends StudyTask {
  PlannedTask({
    String? id,
    required super.title,
    required super.subject,
    required super.estimatedMinutes,
    required super.priority,
    super.suggestedTime,
  }) : super(id: id);
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


class SessionFeedback {
  final String id;
  final String summary;
  final double focusScore;
  final List<String> suggestions;
  final Map<String, dynamic> metrics;
  final bool breakRecommended;
  final double productivityScore;
  final double focusLevel;
  final String? nextBestAction;

  SessionFeedback({
    required this.id,
    required this.summary,
    required this.focusScore,
    required this.suggestions,
    required this.metrics,
    this.breakRecommended = false,
    this.productivityScore = 0.0,
    this.focusLevel = 0.0,
    this.nextBestAction,
  });
}

class SessionMetrics {
  final double focusScore;
  final double completionRate;
  final int timeSpent;
  final int distractions;
  final int breaksTaken;
  final int? duration;
  final int? pauseCount;
  final double? taskCompletionRate;
  final String? timeOfDay;
  final String? subject;

  SessionMetrics({
    this.focusScore = 0.0,
    this.completionRate = 0.0,
    this.timeSpent = 0,
    this.distractions = 0,
    this.breaksTaken = 0,
    this.duration,
    this.pauseCount,
    this.taskCompletionRate,
    this.timeOfDay,
    this.subject,
  });
}

class StudyContext {
  final String currentActivity;
  final Duration timeElapsed;
  final double focusLevel;
  final double energyLevel;

  StudyContext({
    required this.currentActivity,
    required this.timeElapsed,
    required this.focusLevel,
    required this.energyLevel,
  });
}