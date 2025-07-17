import 'dart:async';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for tracking and managing learning achievements
class AchievementTrackingService {
  static final AchievementTrackingService _instance = AchievementTrackingService._internal();
  factory AchievementTrackingService() => _instance;
  AchievementTrackingService._internal();

  // Achievement system configuration
  static const int _maxLevel = 100;
  static const double _baseXpRequirement = 100;
  static const double _xpGrowthFactor = 1.2;
  
  // Achievement tracking state
  final Map<String, UserAchievementProfile> _userProfiles = {};
  final Map<String, StreamController<AchievementUpdate>> _updateControllers = {};
  final Map<String, List<Achievement>> _achievementRegistry = {};
  
  /// Initialize achievement system
  Future<void> initialize() async {
    try {
      // Load achievement definitions
      await _loadAchievementDefinitions();
      
      // Set up periodic achievement checks
      Timer.periodic(const Duration(hours: 1), (_) => _performPeriodicChecks());
      
      safePrint('Achievement tracking service initialized');
    } catch (e) {
      safePrint('Error initializing achievement service: $e');
    }
  }

  /// Get or create user achievement profile
  Future<UserAchievementProfile> getUserProfile(String userId) async {
    try {
      if (_userProfiles.containsKey(userId)) {
        return _userProfiles[userId]!;
      }
      
      // Load from storage or create new
      final profile = await _loadOrCreateProfile(userId);
      _userProfiles[userId] = profile;
      
      // Create update stream
      _updateControllers[userId] = StreamController<AchievementUpdate>.broadcast();
      
      return profile;
    } catch (e) {
      safePrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Get achievement updates stream
  Stream<AchievementUpdate> getAchievementUpdates(String userId) {
    if (!_updateControllers.containsKey(userId)) {
      _updateControllers[userId] = StreamController<AchievementUpdate>.broadcast();
    }
    return _updateControllers[userId]!.stream;
  }

  /// Record learning activity and check for achievements
  Future<AchievementCheckResult> recordActivity({
    required String userId,
    required LearningActivity activity,
  }) async {
    try {
      final profile = await getUserProfile(userId);
      
      // Update stats based on activity
      _updateStats(profile, activity);
      
      // Award XP
      final xpAwarded = _calculateXpReward(activity);
      await _awardXp(profile, xpAwarded, activity.description);
      
      // Check for achievements
      final unlockedAchievements = await _checkAchievements(profile, activity);
      
      // Update streaks
      _updateStreaks(profile, activity);
      
      // Check for milestones
      final milestones = _checkMilestones(profile);
      
      // Save updated profile
      await _saveProfile(profile);
      
      // Emit updates
      if (unlockedAchievements.isNotEmpty || milestones.isNotEmpty) {
        _emitUpdate(userId, AchievementUpdate(
          type: AchievementUpdateType.unlocked,
          achievements: unlockedAchievements,
          milestones: milestones,
          newLevel: profile.level,
          totalXp: profile.totalXp,
          timestamp: DateTime.now(),
        ));
      }
      
      return AchievementCheckResult(
        xpAwarded: xpAwarded,
        unlockedAchievements: unlockedAchievements,
        milestones: milestones,
        newLevel: profile.level,
        levelProgress: _calculateLevelProgress(profile),
      );
    } catch (e) {
      safePrint('Error recording activity: $e');
      rethrow;
    }
  }

  /// Check specific achievement progress
  Future<AchievementProgress> checkAchievementProgress({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final profile = await getUserProfile(userId);
      final achievement = _achievementRegistry['all']?.firstWhere(
        (a) => a.id == achievementId,
        orElse: () => throw Exception('Achievement not found'),
      );
      
      if (achievement == null) {
        throw Exception('Achievement not found');
      }
      
      // Check if already unlocked
      if (profile.unlockedAchievements.contains(achievementId)) {
        return AchievementProgress(
          achievement: achievement,
          isUnlocked: true,
          progress: 1.0,
          currentValue: achievement.requirement,
          targetValue: achievement.requirement,
          unlockedAt: profile.achievementDates[achievementId],
        );
      }
      
      // Calculate current progress
      final progress = _calculateProgress(profile, achievement);
      
      return AchievementProgress(
        achievement: achievement,
        isUnlocked: false,
        progress: progress.percentage,
        currentValue: progress.current,
        targetValue: progress.target,
        estimatedUnlockDate: _estimateUnlockDate(profile, achievement, progress),
      );
    } catch (e) {
      safePrint('Error checking achievement progress: $e');
      rethrow;
    }
  }

  /// Get achievement leaderboard
  Future<AchievementLeaderboard> getLeaderboard({
    required LeaderboardType type,
    required DateTimeRange period,
    int limit = 50,
  }) async {
    try {
      // Fetch leaderboard data based on type
      final entries = await _fetchLeaderboardData(type, period, limit);
      
      // Calculate user's rank if available
      final userRank = await _calculateUserRank(type, period);
      
      return AchievementLeaderboard(
        type: type,
        period: period,
        entries: entries,
        userRank: userRank,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error fetching leaderboard: $e');
      rethrow;
    }
  }

  /// Generate achievement summary
  Future<AchievementSummary> generateSummary({
    required String userId,
    DateTimeRange? period,
  }) async {
    try {
      final profile = await getUserProfile(userId);
      
      // Filter achievements by period if specified
      final relevantAchievements = period != null
          ? _filterAchievementsByPeriod(profile, period)
          : profile.unlockedAchievements;
      
      // Calculate statistics
      final stats = _calculateAchievementStats(profile, relevantAchievements);
      
      // Get rarest achievements
      final rarestAchievements = await _getRarestAchievements(
        profile.unlockedAchievements,
        limit: 5,
      );
      
      // Get close achievements
      final closeAchievements = await _getCloseAchievements(profile, limit: 5);
      
      // Calculate completion rate by category
      final categoryCompletion = _calculateCategoryCompletion(profile);
      
      return AchievementSummary(
        userId: userId,
        totalAchievements: _achievementRegistry['all']?.length ?? 0,
        unlockedCount: profile.unlockedAchievements.length,
        completionRate: stats.completionRate,
        totalXp: profile.totalXp,
        currentLevel: profile.level,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        rarestAchievements: rarestAchievements,
        closeAchievements: closeAchievements,
        categoryCompletion: categoryCompletion,
        recentUnlocks: _getRecentUnlocks(profile, limit: 10),
        period: period,
      );
    } catch (e) {
      safePrint('Error generating achievement summary: $e');
      rethrow;
    }
  }

  /// Award manual achievement
  Future<void> awardManualAchievement({
    required String userId,
    required String achievementId,
    String? reason,
  }) async {
    try {
      final profile = await getUserProfile(userId);
      final achievement = _achievementRegistry['all']?.firstWhere(
        (a) => a.id == achievementId,
      );
      
      if (achievement == null) {
        throw Exception('Achievement not found');
      }
      
      if (!profile.unlockedAchievements.contains(achievementId)) {
        // Unlock achievement
        profile.unlockedAchievements.add(achievementId);
        profile.achievementDates[achievementId] = DateTime.now();
        
        // Award bonus XP
        await _awardXp(profile, achievement.xpReward, achievement.name);
        
        // Save profile
        await _saveProfile(profile);
        
        // Emit update
        _emitUpdate(userId, AchievementUpdate(
          type: AchievementUpdateType.unlocked,
          achievements: [achievement],
          reason: reason,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      safePrint('Error awarding manual achievement: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _loadAchievementDefinitions() async {
    // Load achievement definitions from configuration
    _achievementRegistry['all'] = [
      // Study streaks
      Achievement(
        id: 'streak_7',
        name: '일주일 연속 학습',
        description: '7일 연속으로 학습을 진행했습니다',
        category: AchievementCategory.streak,
        rarity: AchievementRarity.common,
        xpReward: 100,
        requirement: 7,
        icon: Icons.local_fire_department,
      ),
      Achievement(
        id: 'streak_30',
        name: '한달 연속 학습',
        description: '30일 연속으로 학습을 진행했습니다',
        category: AchievementCategory.streak,
        rarity: AchievementRarity.rare,
        xpReward: 500,
        requirement: 30,
        icon: Icons.local_fire_department,
      ),
      Achievement(
        id: 'streak_100',
        name: '백일 연속 학습',
        description: '100일 연속으로 학습을 진행했습니다',
        category: AchievementCategory.streak,
        rarity: AchievementRarity.legendary,
        xpReward: 2000,
        requirement: 100,
        icon: Icons.local_fire_department,
      ),
      
      // Study time achievements
      Achievement(
        id: 'time_10h',
        name: '초보 학습자',
        description: '총 10시간 학습을 완료했습니다',
        category: AchievementCategory.time,
        rarity: AchievementRarity.common,
        xpReward: 50,
        requirement: 600, // minutes
        icon: Icons.timer,
      ),
      Achievement(
        id: 'time_100h',
        name: '열정적인 학습자',
        description: '총 100시간 학습을 완료했습니다',
        category: AchievementCategory.time,
        rarity: AchievementRarity.rare,
        xpReward: 500,
        requirement: 6000,
        icon: Icons.timer,
      ),
      Achievement(
        id: 'time_1000h',
        name: '학습의 달인',
        description: '총 1000시간 학습을 완료했습니다',
        category: AchievementCategory.time,
        rarity: AchievementRarity.legendary,
        xpReward: 5000,
        requirement: 60000,
        icon: Icons.timer,
      ),
      
      // Mastery achievements
      Achievement(
        id: 'mastery_first',
        name: '첫 완벽 이해',
        description: '하나의 주제를 완벽하게 마스터했습니다',
        category: AchievementCategory.mastery,
        rarity: AchievementRarity.common,
        xpReward: 200,
        requirement: 1,
        icon: Icons.star,
      ),
      Achievement(
        id: 'mastery_10',
        name: '다재다능',
        description: '10개의 주제를 마스터했습니다',
        category: AchievementCategory.mastery,
        rarity: AchievementRarity.rare,
        xpReward: 1000,
        requirement: 10,
        icon: Icons.stars,
      ),
      
      // Performance achievements
      Achievement(
        id: 'perfect_week',
        name: '완벽한 한 주',
        description: '일주일 동안 모든 학습 목표를 달성했습니다',
        category: AchievementCategory.performance,
        rarity: AchievementRarity.rare,
        xpReward: 300,
        requirement: 7,
        icon: Icons.emoji_events,
      ),
      Achievement(
        id: 'efficiency_master',
        name: '효율성의 달인',
        description: '학습 효율성 90% 이상 달성',
        category: AchievementCategory.performance,
        rarity: AchievementRarity.epic,
        xpReward: 800,
        requirement: 90,
        icon: Icons.trending_up,
      ),
      
      // Social achievements
      Achievement(
        id: 'helper_10',
        name: '도움의 손길',
        description: '다른 학습자를 10번 도와주었습니다',
        category: AchievementCategory.social,
        rarity: AchievementRarity.common,
        xpReward: 150,
        requirement: 10,
        icon: Icons.handshake,
      ),
      Achievement(
        id: 'study_group_leader',
        name: '스터디 그룹 리더',
        description: '성공적인 스터디 그룹을 이끌었습니다',
        category: AchievementCategory.social,
        rarity: AchievementRarity.rare,
        xpReward: 400,
        requirement: 1,
        icon: Icons.groups,
      ),
      
      // Special achievements
      Achievement(
        id: 'night_owl',
        name: '올빼미 학습자',
        description: '자정 이후 50시간 학습 완료',
        category: AchievementCategory.special,
        rarity: AchievementRarity.rare,
        xpReward: 250,
        requirement: 3000, // minutes
        icon: Icons.nightlight,
      ),
      Achievement(
        id: 'early_bird',
        name: '아침형 인간',
        description: '오전 6시 이전 50시간 학습 완료',
        category: AchievementCategory.special,
        rarity: AchievementRarity.rare,
        xpReward: 250,
        requirement: 3000,
        icon: Icons.wb_sunny,
      ),
      Achievement(
        id: 'comeback_king',
        name: '컴백의 제왕',
        description: '30일 이상 쉬었다가 다시 학습 시작',
        category: AchievementCategory.special,
        rarity: AchievementRarity.epic,
        xpReward: 500,
        requirement: 1,
        icon: Icons.replay,
      ),
    ];
    
    // Organize by category
    for (final achievement in _achievementRegistry['all']!) {
      final categoryKey = achievement.category.toString();
      _achievementRegistry[categoryKey] ??= [];
      _achievementRegistry[categoryKey]!.add(achievement);
    }
  }

  void _updateStats(UserAchievementProfile profile, LearningActivity activity) {
    // Update basic stats
    profile.totalStudyTime += activity.duration;
    profile.totalSessions++;
    
    // Update subject stats
    profile.subjectTime[activity.subject] = 
        (profile.subjectTime[activity.subject] ?? 0) + activity.duration;
    
    // Update activity stats
    profile.activityCounts[activity.type] = 
        (profile.activityCounts[activity.type] ?? 0) + 1;
    
    // Update time-based stats
    final hour = activity.timestamp.hour;
    if (hour < 6) {
      profile.earlyMorningMinutes += activity.duration;
    } else if (hour >= 22) {
      profile.lateNightMinutes += activity.duration;
    }
    
    // Update efficiency stats
    if (activity.efficiency != null) {
      profile.efficiencyHistory.add(EfficiencyRecord(
        value: activity.efficiency!,
        timestamp: activity.timestamp,
      ));
    }
  }

  double _calculateXpReward(LearningActivity activity) {
    double baseXp = activity.duration * 0.5; // 0.5 XP per minute
    
    // Apply multipliers
    double multiplier = 1.0;
    
    // Efficiency bonus
    if (activity.efficiency != null && activity.efficiency! > 0.8) {
      multiplier += 0.2;
    }
    
    // Difficulty bonus
    if (activity.difficulty == DifficultyLevel.hard) {
      multiplier += 0.3;
    } else if (activity.difficulty == DifficultyLevel.medium) {
      multiplier += 0.15;
    }
    
    // Completion bonus
    if (activity.completed) {
      multiplier += 0.1;
    }
    
    // Perfect score bonus
    if (activity.score != null && activity.score! >= 0.95) {
      multiplier += 0.5;
    }
    
    return baseXp * multiplier;
  }

  Future<void> _awardXp(
    UserAchievementProfile profile,
    double xp,
    String source,
  ) async {
    profile.totalXp += xp;
    profile.xpHistory.add(XpRecord(
      amount: xp,
      source: source,
      timestamp: DateTime.now(),
    ));
    
    // Check for level up
    while (profile.totalXp >= _calculateXpForLevel(profile.level + 1)) {
      profile.level++;
      
      // Emit level up event
      _emitUpdate(profile.userId, AchievementUpdate(
        type: AchievementUpdateType.levelUp,
        newLevel: profile.level,
        totalXp: profile.totalXp,
        timestamp: DateTime.now(),
      ));
    }
  }

  double _calculateXpForLevel(int level) {
    return _baseXpRequirement * math.pow(_xpGrowthFactor, level - 1);
  }

  double _calculateLevelProgress(UserAchievementProfile profile) {
    final currentLevelXp = _calculateXpForLevel(profile.level);
    final nextLevelXp = _calculateXpForLevel(profile.level + 1);
    final progressXp = profile.totalXp - currentLevelXp;
    final requiredXp = nextLevelXp - currentLevelXp;
    
    return progressXp / requiredXp;
  }

  Future<List<Achievement>> _checkAchievements(
    UserAchievementProfile profile,
    LearningActivity activity,
  ) async {
    final unlockedAchievements = <Achievement>[];
    
    for (final achievement in _achievementRegistry['all'] ?? []) {
      if (profile.unlockedAchievements.contains(achievement.id)) {
        continue; // Already unlocked
      }
      
      final isUnlocked = await _checkAchievementCondition(
        profile,
        achievement,
        activity,
      );
      
      if (isUnlocked) {
        profile.unlockedAchievements.add(achievement.id);
        profile.achievementDates[achievement.id] = DateTime.now();
        unlockedAchievements.add(achievement);
        
        // Award achievement XP
        await _awardXp(profile, achievement.xpReward, achievement.name);
      }
    }
    
    return unlockedAchievements;
  }

  Future<bool> _checkAchievementCondition(
    UserAchievementProfile profile,
    Achievement achievement,
    LearningActivity activity,
  ) async {
    switch (achievement.category) {
      case AchievementCategory.streak:
        return profile.currentStreak >= achievement.requirement;
        
      case AchievementCategory.time:
        return profile.totalStudyTime >= achievement.requirement;
        
      case AchievementCategory.mastery:
        return profile.masteredTopics.length >= achievement.requirement;
        
      case AchievementCategory.performance:
        return await _checkPerformanceAchievement(profile, achievement);
        
      case AchievementCategory.social:
        return await _checkSocialAchievement(profile, achievement);
        
      case AchievementCategory.special:
        return await _checkSpecialAchievement(profile, achievement, activity);
    }
  }

  void _updateStreaks(UserAchievementProfile profile, LearningActivity activity) {
    final today = DateTime.now();
    final lastActivity = profile.lastActivityDate;
    
    if (lastActivity == null || 
        !_isSameDay(lastActivity, today)) {
      // Check if streak continues
      if (lastActivity != null && 
          _isYesterday(lastActivity, today)) {
        profile.currentStreak++;
      } else if (lastActivity == null || 
                 _daysBetween(lastActivity, today) > 1) {
        profile.currentStreak = 1;
      }
      
      // Update longest streak
      if (profile.currentStreak > profile.longestStreak) {
        profile.longestStreak = profile.currentStreak;
      }
      
      profile.lastActivityDate = today;
    }
  }

  List<Milestone> _checkMilestones(UserAchievementProfile profile) {
    final milestones = <Milestone>[];
    
    // Check study time milestones
    final studyHours = profile.totalStudyTime ~/ 60;
    final timeMilestones = [10, 25, 50, 100, 250, 500, 1000];
    
    for (final milestone in timeMilestones) {
      if (studyHours >= milestone && 
          !profile.reachedMilestones.contains('time_$milestone')) {
        profile.reachedMilestones.add('time_$milestone');
        milestones.add(Milestone(
          id: 'time_$milestone',
          type: MilestoneType.studyTime,
          value: milestone,
          name: '$milestone 시간 학습 달성',
          icon: Icons.schedule,
        ));
      }
    }
    
    // Check level milestones
    final levelMilestones = [10, 25, 50, 75, 100];
    for (final milestone in levelMilestones) {
      if (profile.level >= milestone && 
          !profile.reachedMilestones.contains('level_$milestone')) {
        profile.reachedMilestones.add('level_$milestone');
        milestones.add(Milestone(
          id: 'level_$milestone',
          type: MilestoneType.level,
          value: milestone,
          name: '레벨 $milestone 달성',
          icon: Icons.military_tech,
        ));
      }
    }
    
    // Check achievement milestones
    final achievementCount = profile.unlockedAchievements.length;
    final achievementMilestones = [5, 10, 25, 50, 100];
    
    for (final milestone in achievementMilestones) {
      if (achievementCount >= milestone && 
          !profile.reachedMilestones.contains('achievement_$milestone')) {
        profile.reachedMilestones.add('achievement_$milestone');
        milestones.add(Milestone(
          id: 'achievement_$milestone',
          type: MilestoneType.achievements,
          value: milestone,
          name: '$milestone개 업적 달성',
          icon: Icons.emoji_events,
        ));
      }
    }
    
    return milestones;
  }

  void _emitUpdate(String userId, AchievementUpdate update) {
    _updateControllers[userId]?.add(update);
  }

  // Utility methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isYesterday(DateTime date1, DateTime date2) {
    final yesterday = date2.subtract(const Duration(days: 1));
    return _isSameDay(date1, yesterday);
  }

  int _daysBetween(DateTime date1, DateTime date2) {
    return date2.difference(date1).inDays;
  }

  // Additional helper methods would be implemented here...
  Future<void> _performPeriodicChecks() async {
    // Implementation for periodic achievement checks
  }

  Future<UserAchievementProfile> _loadOrCreateProfile(String userId) async {
    // Implementation to load or create profile
    return UserAchievementProfile(
      userId: userId,
      level: 1,
      totalXp: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalStudyTime: 0,
      totalSessions: 0,
      unlockedAchievements: [],
      achievementDates: {},
      masteredTopics: [],
      subjectTime: {},
      activityCounts: {},
      efficiencyHistory: [],
      xpHistory: [],
      reachedMilestones: [],
      earlyMorningMinutes: 0,
      lateNightMinutes: 0,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _saveProfile(UserAchievementProfile profile) async {
    // Implementation to save profile
  }

  // Stub implementations for various helper methods
  Future<bool> _checkPerformanceAchievement(
    UserAchievementProfile profile,
    Achievement achievement,
  ) async => false;

  Future<bool> _checkSocialAchievement(
    UserAchievementProfile profile,
    Achievement achievement,
  ) async => false;

  Future<bool> _checkSpecialAchievement(
    UserAchievementProfile profile,
    Achievement achievement,
    LearningActivity activity,
  ) async => false;

  _ProgressData _calculateProgress(
    UserAchievementProfile profile,
    Achievement achievement,
  ) => _ProgressData(current: 0, target: 1, percentage: 0);

  DateTime? _estimateUnlockDate(
    UserAchievementProfile profile,
    Achievement achievement,
    _ProgressData progress,
  ) => null;

  Future<List<LeaderboardEntry>> _fetchLeaderboardData(
    LeaderboardType type,
    DateTimeRange period,
    int limit,
  ) async => [];

  Future<int?> _calculateUserRank(
    LeaderboardType type,
    DateTimeRange period,
  ) async => null;

  List<String> _filterAchievementsByPeriod(
    UserAchievementProfile profile,
    DateTimeRange period,
  ) => [];

  _AchievementStats _calculateAchievementStats(
    UserAchievementProfile profile,
    List<String> achievements,
  ) => _AchievementStats(completionRate: 0);

  Future<List<Achievement>> _getRarestAchievements(
    List<String> achievementIds,
    {required int limit}
  ) async => [];

  Future<List<AchievementProgress>> _getCloseAchievements(
    UserAchievementProfile profile,
    {required int limit}
  ) async => [];

  Map<AchievementCategory, double> _calculateCategoryCompletion(
    UserAchievementProfile profile,
  ) => {};

  List<Achievement> _getRecentUnlocks(
    UserAchievementProfile profile,
    {required int limit}
  ) => [];
}

// Data models
class UserAchievementProfile {
  final String userId;
  int level;
  double totalXp;
  int currentStreak;
  int longestStreak;
  int totalStudyTime; // minutes
  int totalSessions;
  final List<String> unlockedAchievements;
  final Map<String, DateTime> achievementDates;
  final List<String> masteredTopics;
  final Map<String, int> subjectTime; // subject -> minutes
  final Map<String, int> activityCounts;
  final List<EfficiencyRecord> efficiencyHistory;
  final List<XpRecord> xpHistory;
  final List<String> reachedMilestones;
  int earlyMorningMinutes;
  int lateNightMinutes;
  DateTime? lastActivityDate;
  final DateTime createdAt;

  UserAchievementProfile({
    required this.userId,
    required this.level,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStudyTime,
    required this.totalSessions,
    required this.unlockedAchievements,
    required this.achievementDates,
    required this.masteredTopics,
    required this.subjectTime,
    required this.activityCounts,
    required this.efficiencyHistory,
    required this.xpHistory,
    required this.reachedMilestones,
    required this.earlyMorningMinutes,
    required this.lateNightMinutes,
    this.lastActivityDate,
    required this.createdAt,
  });
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final double xpReward;
  final double requirement;
  final IconData icon;
  final Map<String, dynamic>? metadata;

  Achievement({
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

class LearningActivity {
  final String type;
  final String subject;
  final int duration; // minutes
  final DateTime timestamp;
  final DifficultyLevel? difficulty;
  final double? efficiency;
  final bool completed;
  final double? score;
  final String description;

  LearningActivity({
    required this.type,
    required this.subject,
    required this.duration,
    required this.timestamp,
    this.difficulty,
    this.efficiency,
    required this.completed,
    this.score,
    required this.description,
  });
}

class AchievementUpdate {
  final AchievementUpdateType type;
  final List<Achievement>? achievements;
  final List<Milestone>? milestones;
  final int? newLevel;
  final double? totalXp;
  final String? reason;
  final DateTime timestamp;

  AchievementUpdate({
    required this.type,
    this.achievements,
    this.milestones,
    this.newLevel,
    this.totalXp,
    this.reason,
    required this.timestamp,
  });
}

class AchievementCheckResult {
  final double xpAwarded;
  final List<Achievement> unlockedAchievements;
  final List<Milestone> milestones;
  final int newLevel;
  final double levelProgress;

  AchievementCheckResult({
    required this.xpAwarded,
    required this.unlockedAchievements,
    required this.milestones,
    required this.newLevel,
    required this.levelProgress,
  });
}

class AchievementProgress {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;
  final double currentValue;
  final double targetValue;
  final DateTime? unlockedAt;
  final DateTime? estimatedUnlockDate;

  AchievementProgress({
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    this.unlockedAt,
    this.estimatedUnlockDate,
  });
}

class AchievementLeaderboard {
  final LeaderboardType type;
  final DateTimeRange period;
  final List<LeaderboardEntry> entries;
  final int? userRank;
  final DateTime lastUpdated;

  AchievementLeaderboard({
    required this.type,
    required this.period,
    required this.entries,
    this.userRank,
    required this.lastUpdated,
  });
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int rank;
  final double value;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.rank,
    required this.value,
    this.avatarUrl,
    this.metadata,
  });
}

class AchievementSummary {
  final String userId;
  final int totalAchievements;
  final int unlockedCount;
  final double completionRate;
  final double totalXp;
  final int currentLevel;
  final int currentStreak;
  final int longestStreak;
  final List<Achievement> rarestAchievements;
  final List<AchievementProgress> closeAchievements;
  final Map<AchievementCategory, double> categoryCompletion;
  final List<Achievement> recentUnlocks;
  final DateTimeRange? period;

  AchievementSummary({
    required this.userId,
    required this.totalAchievements,
    required this.unlockedCount,
    required this.completionRate,
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.rarestAchievements,
    required this.closeAchievements,
    required this.categoryCompletion,
    required this.recentUnlocks,
    this.period,
  });
}

class Milestone {
  final String id;
  final MilestoneType type;
  final int value;
  final String name;
  final IconData icon;

  Milestone({
    required this.id,
    required this.type,
    required this.value,
    required this.name,
    required this.icon,
  });
}

class EfficiencyRecord {
  final double value;
  final DateTime timestamp;

  EfficiencyRecord({
    required this.value,
    required this.timestamp,
  });
}

class XpRecord {
  final double amount;
  final String source;
  final DateTime timestamp;

  XpRecord({
    required this.amount,
    required this.source,
    required this.timestamp,
  });
}

// Enums
enum AchievementCategory {
  streak,
  time,
  mastery,
  performance,
  social,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

enum AchievementUpdateType {
  unlocked,
  levelUp,
  progress,
}

enum LeaderboardType {
  xp,
  level,
  achievements,
  streak,
  efficiency,
}

enum MilestoneType {
  studyTime,
  level,
  achievements,
  streak,
}

// Private helper classes
class _ProgressData {
  final double current;
  final double target;
  final double percentage;

  _ProgressData({
    required this.current,
    required this.target,
    required this.percentage,
  });
}

class _AchievementStats {
  final double completionRate;

  _AchievementStats({
    required this.completionRate,
  });
}