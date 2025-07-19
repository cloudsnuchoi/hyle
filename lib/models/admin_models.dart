// Admin Dashboard Models for future Amplify integration

class AdminQuest {
  final String id;
  final Map<String, String> title; // {'ko': '한국어 제목', 'en': 'English Title'}
  final Map<String, String> description; // {'ko': '한국어 설명', 'en': 'English Description'}
  final String type; // daily, weekly, special
  final String difficulty; // easy, medium, hard
  final int xpReward;
  final int coinReward;
  final String? specialReward;
  final int targetValue;
  final String trackingType; // 'study_time', 'todo_complete', etc.
  final String iconName; // Icon name as string for DB storage
  final String colorHex; // Color as hex string for DB storage
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, dynamic>? metadata; // For future extensions
  
  AdminQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.xpReward,
    required this.coinReward,
    this.specialReward,
    required this.targetValue,
    required this.trackingType,
    required this.iconName,
    required this.colorHex,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.metadata,
  });
  
  // For Amplify/DynamoDB
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type,
    'difficulty': difficulty,
    'xpReward': xpReward,
    'coinReward': coinReward,
    'specialReward': specialReward,
    'targetValue': targetValue,
    'trackingType': trackingType,
    'iconName': iconName,
    'colorHex': colorHex,
    'isActive': isActive,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'metadata': metadata,
  };
  
  factory AdminQuest.fromJson(Map<String, dynamic> json) => AdminQuest(
    id: json['id'],
    title: Map<String, String>.from(json['title']),
    description: Map<String, String>.from(json['description']),
    type: json['type'],
    difficulty: json['difficulty'],
    xpReward: json['xpReward'],
    coinReward: json['coinReward'],
    specialReward: json['specialReward'],
    targetValue: json['targetValue'],
    trackingType: json['trackingType'],
    iconName: json['iconName'],
    colorHex: json['colorHex'],
    isActive: json['isActive'] ?? true,
    startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    metadata: json['metadata'],
  );
}

// Analytics data for admin dashboard
class QuestAnalytics {
  final String questId;
  final int totalAccepted;
  final int totalCompleted;
  final int totalAbandoned;
  final double completionRate;
  final double averageCompletionTime; // in hours
  final Map<String, int> completionByDifficulty;
  final Map<String, int> completionByUserLevel;
  final List<DailyMetric> dailyMetrics;
  
  QuestAnalytics({
    required this.questId,
    required this.totalAccepted,
    required this.totalCompleted,
    required this.totalAbandoned,
    required this.completionRate,
    required this.averageCompletionTime,
    required this.completionByDifficulty,
    required this.completionByUserLevel,
    required this.dailyMetrics,
  });
}

class DailyMetric {
  final DateTime date;
  final int accepted;
  final int completed;
  final int abandoned;
  
  DailyMetric({
    required this.date,
    required this.accepted,
    required this.completed,
    required this.abandoned,
  });
}

// User analytics for admin
class UserAnalytics {
  final String userId;
  final String username;
  final int level;
  final int totalXP;
  final int totalStudyMinutes;
  final int currentStreak;
  final int questsCompleted;
  final DateTime lastActiveDate;
  final Map<String, int> questCompletionByType;
  final List<String> achievements;
  final Map<String, dynamic> learningPatterns;
  
  UserAnalytics({
    required this.userId,
    required this.username,
    required this.level,
    required this.totalXP,
    required this.totalStudyMinutes,
    required this.currentStreak,
    required this.questsCompleted,
    required this.lastActiveDate,
    required this.questCompletionByType,
    required this.achievements,
    required this.learningPatterns,
  });
}

// Admin notification/announcement model
class AdminAnnouncement {
  final String id;
  final Map<String, String> title;
  final Map<String, String> content;
  final String type; // 'info', 'warning', 'success', 'event'
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? targetUserGroups; // null means all users
  final bool isActive;
  final int priority; // For ordering
  
  AdminAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.targetUserGroups,
    this.isActive = true,
    this.priority = 0,
  });
}

// Configuration for app features
class AppConfiguration {
  final Map<String, bool> features; // Feature flags
  final Map<String, dynamic> limits; // Rate limits, quest limits, etc.
  final Map<String, dynamic> rewards; // XP/coin multipliers, etc.
  final Map<String, String> endpoints; // API endpoints
  final DateTime lastUpdated;
  
  AppConfiguration({
    required this.features,
    required this.limits,
    required this.rewards,
    required this.endpoints,
    required this.lastUpdated,
  });
  
  // Default configuration
  factory AppConfiguration.defaults() => AppConfiguration(
    features: {
      'quests': true,
      'social': true,
      'ai_tutor': true,
      'achievements': true,
      'leaderboard': false, // Can be toggled by admin
    },
    limits: {
      'daily_quests': 3,
      'weekly_quests': 2,
      'max_friends': 50,
      'daily_ai_queries': 100,
    },
    rewards: {
      'xp_multiplier': 1.0,
      'coin_multiplier': 1.0,
      'weekend_bonus': 1.5,
      'streak_bonus': 0.1, // 10% per day
    },
    endpoints: {
      'api': 'https://api.hyle.app',
      'analytics': 'https://analytics.hyle.app',
    },
    lastUpdated: DateTime.now(),
  );
}