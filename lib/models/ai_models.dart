// Common AI Service Models

import 'package:flutter/material.dart';

// User Context
class UserContext {
  final int level;
  final String learningType;
  final int availableHours;
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

// Study Plan
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
  final String title;
  final String subject;
  final int estimatedMinutes;
  final String priority;
  final DateTime? suggestedTime;

  StudyTask({
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    required this.priority,
    this.suggestedTime,
  });
}

// Progress Data
class ProgressDataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? metadata;

  ProgressDataPoint({
    required this.timestamp,
    required this.value,
    this.metadata,
  });
}

// Goal Prediction
class GoalPrediction {
  final DateTime estimatedCompletionDate;
  final double confidence;
  final List<String> recommendations;
  final Map<String, dynamic> factors;

  GoalPrediction({
    required this.estimatedCompletionDate,
    required this.confidence,
    required this.recommendations,
    required this.factors,
  });
}

// Learning Patterns
class LearningPattern {
  final String type;
  final double strength;
  final String description;
  final Map<String, dynamic> data;

  LearningPattern({
    required this.type,
    required this.strength,
    required this.description,
    required this.data,
  });
}

// Study Session
class AIStudySession {
  final String id;
  final String userId;
  final String subject;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final Map<String, dynamic> metrics;

  AIStudySession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.metrics,
  });
}

// Enums
enum Priority { low, medium, high, urgent }
enum NotificationType { 
  reminder, 
  achievement, 
  motivation, 
  warning,
  cognitiveBreak,
  motivational,
  studyReminder,
  goalReminder,
  social
}
enum LearningMode { visual, auditory, kinesthetic, reading }
enum StudyPhase { learning, practicing, reviewing, testing }

// Time Range
class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({required this.start, required this.end});
  
  Duration get duration => end.difference(start);
}

// Study Metrics
class StudyMetrics {
  final double focusScore;
  final double productivityScore;
  final int totalMinutes;
  final Map<String, int> subjectBreakdown;
  final List<String> achievements;

  StudyMetrics({
    required this.focusScore,
    required this.productivityScore,
    required this.totalMinutes,
    required this.subjectBreakdown,
    required this.achievements,
  });
}

// Learning Insight
class LearningInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final double importance;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  LearningInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.importance,
    required this.data,
    required this.createdAt,
  });
}

enum InsightType { 
  pattern, 
  warning, 
  achievement, 
  recommendation, 
  milestone 
}

// Cognitive State
class CognitiveState {
  final double load;
  final double attention;
  final double fatigue;
  final String mood;
  final DateTime timestamp;

  CognitiveState({
    required this.load,
    required this.attention,
    required this.fatigue,
    required this.mood,
    required this.timestamp,
  });
}

// Problem Analysis
class ProblemAnalysis {
  final String problemId;
  final double difficulty;
  final double estimatedTime;
  final List<String> requiredConcepts;
  final Map<String, dynamic> hints;

  ProblemAnalysis({
    required this.problemId,
    required this.difficulty,
    required this.estimatedTime,
    required this.requiredConcepts,
    required this.hints,
  });
}

// Achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final DateTime unlockedAt;
  final int xpReward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.unlockedAt,
    required this.xpReward,
  });
}

// Notification Payload
class NotificationPayload {
  final String id;
  final NotificationType type;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.id,
    required this.type,
    required this.data,
  });
}

// Study Group
class StudyGroup {
  final String id;
  final String name;
  final List<String> memberIds;
  final String ownerId;
  final Map<String, dynamic> settings;

  StudyGroup({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.ownerId,
    required this.settings,
  });
}