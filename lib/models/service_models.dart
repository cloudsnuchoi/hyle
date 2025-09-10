// Service-specific models that don't need to be Amplify models
import 'package:flutter/material.dart';
// import 'ModelProvider.dart'; // Removed - Amplify model no longer used

// Achievement models with namespace prefixes
class SessionAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String rarity;

  SessionAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
  });
}

class MotivationalAchievement {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final bool firstTime;
  final double percentile;

  MotivationalAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.firstTime,
    required this.percentile,
  });
}

enum Rarity { common, uncommon, rare, epic, legendary }

class ServiceAchievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final double xpReward;
  final double requirement;
  final IconData icon;
  final Map<String, dynamic>? metadata;

  ServiceAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.xpReward,
    required this.requirement,
    required this.icon,
    this.metadata,
  });
}

enum AchievementCategory { learning, social, consistency, mastery, challenge }
enum AchievementRarity { common, uncommon, rare, epic, legendary }

// Goal models with namespace prefixes
class MotivationalGoal {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;

  MotivationalGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
  });
}

class OrchestratorGoal {
  final String id;
  final String title;
  final String subject;
  final DateTime deadline;
  final String type;
  final double progress;

  OrchestratorGoal({
    required this.id,
    required this.title,
    required this.subject,
    required this.deadline,
    required this.type,
    required this.progress,
  });
}

// StudySession models with namespace prefixes
class PatternStudySession {
  final String id;
  final String userId;
  final String subject;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final Map<String, dynamic> metadata;

  PatternStudySession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.metadata,
  });
}

class FeedbackStudySession {
  final String id;
  final String userId;
  final String subject;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionMetrics metrics;
  final List<SessionActivity> activities;
  final String? feedback;
  final bool isActive;

  FeedbackStudySession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.startTime,
    this.endTime,
    required this.metrics,
    required this.activities,
    this.feedback,
    required this.isActive,
  });
}

class MetricsStudySession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String subject;
  final Map<String, dynamic> metrics;

  MetricsStudySession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.subject,
    required this.metrics,
  });
}

class AIStudySession {
  final String id;
  final String userId;
  final String subject;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> aiMetrics;

  AIStudySession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.startTime,
    this.endTime,
    required this.aiMetrics,
  });
}

// Performance metrics models
class PerformanceMetrics {
  final double accuracy;
  final double speed;
  final double consistency;
  final double improvement;
  final Map<String, dynamic>? details;

  PerformanceMetrics({
    required this.accuracy,
    required this.speed,
    required this.consistency,
    required this.improvement,
    this.details,
  });
}

// Problem context models
class SolutionProblemContext {
  final String problemType;
  final String subject;
  final List<String>? requiredConcepts;
  final Map<String, dynamic>? constraints;

  SolutionProblemContext({
    required this.problemType,
    required this.subject,
    this.requiredConcepts,
    this.constraints,
  });
}

class MistakeProblemContext {
  final double complexity;
  final bool hasTimeLimit;
  final bool isNewVariation;
  final bool requiresMultipleSteps;

  MistakeProblemContext({
    required this.complexity,
    required this.hasTimeLimit,
    required this.isNewVariation,
    required this.requiresMultipleSteps,
  });
}

// User profile models
class SolutionUserProfile {
  final String userId;
  final List<String> masteredConcepts;
  final List<String> strugglingConcepts;
  final Map<String, double> subjectProficiency;
  final LearningStyle preferredStyle;

  SolutionUserProfile({
    required this.userId,
    required this.masteredConcepts,
    required this.strugglingConcepts,
    required this.subjectProficiency,
    required this.preferredStyle,
  });
}

enum LearningStyle { visual, auditory, kinesthetic, reading }

// Problem models
class SolutionProblem {
  final String id;
  final String content;
  final String correctAnswer;
  final List<String> steps;
  final Map<String, dynamic>? metadata;

  SolutionProblem({
    required this.id,
    required this.content,
    required this.correctAnswer,
    required this.steps,
    this.metadata,
  });
}

// Session metrics and activity
class SessionMetrics {
  int problemsSolved = 0;
  int correctAnswers = 0;
  int conceptsStudied = 0;
  int notesTaken = 0;
  int resourcesUsed = 0;
  double focusScore = 1.0;
  double comprehensionScore = 1.0;
  double engagementScore = 1.0;
}

class SessionActivity {
  final ActivityType type;
  final DateTime timestamp;
  final int duration; // seconds
  final Map<String, dynamic> metadata;

  SessionActivity({
    required this.type,
    required this.timestamp,
    required this.duration,
    required this.metadata,
  });
}

enum ActivityType {
  problemSolved,
  conceptStudied,
  notesTaken,
  resourceAccessed,
  breakTaken,
  questionAsked,
  collaborationStarted,
  reviewCompleted,
}

// Other utility models
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final double requiredProgress;
  final DateTime? targetDate;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredProgress,
    this.targetDate,
  });
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final double score;
  final int rank;
  final Map<String, dynamic>? metadata;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.score,
    required this.rank,
    this.metadata,
  });
}

enum LeaderboardType { daily, weekly, monthly, allTime }

// Goal analysis models
class GoalAnalysis {
  final GoalType type;
  final GoalDifficulty difficulty;
  final List<Milestone> milestones;
  final List<String> expectedStruggles;

  GoalAnalysis({
    required this.type,
    required this.difficulty,
    required this.milestones,
    required this.expectedStruggles,
  });
}

enum GoalType { shortTerm, longTerm, exam, skill, habit }
enum GoalDifficulty { easy, moderate, hard, extreme }

// Other shared enums and classes
enum AchievementUpdateType {
  unlocked,
  progress,
  levelUp,
  milestoneReached,
}

class EffectivenessScore {
  final double overall;
  final double timing;
  final double relevance;
  final double impact;
  final Map<String, double> breakdown;

  EffectivenessScore({
    required this.overall,
    required this.timing,
    required this.relevance,
    required this.impact,
    required this.breakdown,
  });
}

// Missing models for todo_repository_enhanced.dart
class CurriculumMapping {
  final double confidence;
  final List<MappedTopic> mappedTopics;
  final Map<String, dynamic>? metadata;

  const CurriculumMapping({
    required this.confidence,
    required this.mappedTopics,
    this.metadata,
  });
}

class MappedTopic {
  final String id;
  final String name;
  final double relevance;

  const MappedTopic({
    required this.id,
    required this.name,
    required this.relevance,
  });
}

class IntegratedStudyPath {
  final String id;
  final String title;
  final List<StudyPathStep> steps;
  final Duration estimatedDuration;
  final Map<String, dynamic>? metadata;

  const IntegratedStudyPath({
    required this.id,
    required this.title,
    required this.steps,
    required this.estimatedDuration,
    this.metadata,
  });
}

class StudyPathStep {
  final String id;
  final String subject;
  final String topic;
  final Duration duration;
  final int order;

  const StudyPathStep({
    required this.id,
    required this.subject,
    required this.topic,
    required this.duration,
    required this.order,
  });
}

// Missing models for ai_tutor_orchestrator.dart
class OptimalTiming {
  final DateTime recommendedTime;
  final String reason;
  final double confidenceScore;
  final Map<String, dynamic>? factors;

  const OptimalTiming({
    required this.recommendedTime,
    required this.reason,
    required this.confidenceScore,
    this.factors,
  });
}

class ProgressDashboard {
  final String userId;
  final DateTime lastUpdated;
  final Map<String, SubjectProgress> subjectProgress;
  final OverallMetrics overallMetrics;
  final List<DashboardAchievement> recentAchievements;
  final List<InsightCard> insights;

  const ProgressDashboard({
    required this.userId,
    required this.lastUpdated,
    required this.subjectProgress,
    required this.overallMetrics,
    required this.recentAchievements,
    required this.insights,
  });
}

class SubjectProgress {
  final String subject;
  final double completionRate;
  final int totalHours;
  final double averageScore;
  final String trend; // 'up', 'down', 'stable'

  const SubjectProgress({
    required this.subject,
    required this.completionRate,
    required this.totalHours,
    required this.averageScore,
    required this.trend,
  });
}

class OverallMetrics {
  final int totalStudyHours;
  final int currentStreak;
  final double weeklyImprovement;
  final int completedGoals;

  const OverallMetrics({
    required this.totalStudyHours,
    required this.currentStreak,
    required this.weeklyImprovement,
    required this.completedGoals,
  });
}

class DashboardAchievement {
  final String id;
  final String title;
  final String description;
  final DateTime unlockedAt;
  final String iconUrl;

  const DashboardAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockedAt,
    required this.iconUrl,
  });
}

class InsightCard {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? actionUrl;
  final String? actionLabel;

  const InsightCard({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.actionUrl,
    this.actionLabel,
  });
}