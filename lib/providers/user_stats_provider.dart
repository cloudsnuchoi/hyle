import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

// User Stats Model
class UserStats {
  final int totalXP;
  final int level;
  final int totalStudyTime; // in minutes
  final int currentStreak;
  final int longestStreak;
  final DateTime lastStudyDate;
  final Map<String, int> subjectStats; // subject -> minutes studied
  
  UserStats({
    this.totalXP = 0,
    this.level = 1,
    this.totalStudyTime = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastStudyDate,
    Map<String, int>? subjectStats,
  }) : lastStudyDate = lastStudyDate ?? DateTime.now(),
       subjectStats = subjectStats ?? {};
  
  UserStats copyWith({
    int? totalXP,
    int? level,
    int? totalStudyTime,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    Map<String, int>? subjectStats,
  }) {
    return UserStats(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      subjectStats: subjectStats ?? Map.from(this.subjectStats),
    );
  }
  
  // Calculate level from XP
  int calculateLevel() {
    if (totalXP < 100) return 1;
    if (totalXP < 300) return 2;
    if (totalXP < 600) return 3;
    if (totalXP < 1000) return 4;
    if (totalXP < 1500) return 5;
    // Level 6+: 1000 XP per level
    return 5 + ((totalXP - 1500) ~/ 1000);
  }
  
  // Calculate XP needed for next level
  int getXPForNextLevel() {
    final currentLevel = calculateLevel();
    if (currentLevel == 1) return 100;
    if (currentLevel == 2) return 300;
    if (currentLevel == 3) return 600;
    if (currentLevel == 4) return 1000;
    if (currentLevel == 5) return 1500;
    return 1500 + ((currentLevel - 5) * 1000);
  }
  
  // Calculate progress to next level (0.0 to 1.0)
  double getLevelProgress() {
    final currentLevel = calculateLevel();
    final nextLevelXP = getXPForNextLevel();
    final prevLevelXP = currentLevel == 1 ? 0 : _getXPForLevel(currentLevel - 1);
    
    if (totalXP >= nextLevelXP) return 1.0;
    return (totalXP - prevLevelXP) / (nextLevelXP - prevLevelXP);
  }
  
  int _getXPForLevel(int level) {
    if (level <= 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 300;
    if (level == 4) return 600;
    if (level == 5) return 1000;
    return 1500 + ((level - 6) * 1000);
  }
  
  // Format study time
  String getFormattedStudyTime() {
    final hours = totalStudyTime ~/ 60;
    final minutes = totalStudyTime % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

// User Stats Provider
final userStatsProvider = StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier();
});

class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier() : super(UserStats()) {
    _loadFromStorage();
  }
  
  void addXP(int xp, {String? subject, int? studyMinutes}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudyDay = DateTime(
      state.lastStudyDate.year,
      state.lastStudyDate.month,
      state.lastStudyDate.day,
    );
    
    // Update streak
    int newStreak = state.currentStreak;
    if (today.isAfter(lastStudyDay)) {
      final dayDifference = today.difference(lastStudyDay).inDays;
      if (dayDifference == 1) {
        newStreak += 1; // Consecutive day
      } else if (dayDifference > 1) {
        newStreak = 1; // Reset streak
      }
    }
    
    // Update subject stats
    Map<String, int> newSubjectStats = Map.from(state.subjectStats);
    if (subject != null && studyMinutes != null) {
      newSubjectStats[subject] = (newSubjectStats[subject] ?? 0) + studyMinutes;
    }
    
    final newTotalXP = state.totalXP + xp;
    final newLevel = UserStats(totalXP: newTotalXP).calculateLevel();
    
    // Check for level up
    if (newLevel > state.level) {
      _showLevelUpDialog(newLevel);
    }
    
    state = state.copyWith(
      totalXP: newTotalXP,
      level: newLevel,
      totalStudyTime: state.totalStudyTime + (studyMinutes ?? 0),
      currentStreak: newStreak,
      longestStreak: newStreak > state.longestStreak ? newStreak : state.longestStreak,
      lastStudyDate: now,
      subjectStats: newSubjectStats,
    );
    
    _saveToStorage();
  }
  
  void _showLevelUpDialog(int newLevel) {
    // TODO: Implement level up dialog/animation
    print('Level up! New level: $newLevel');
  }
  
  void resetStats() {
    state = UserStats();
    _saveToStorage();
  }
  
  void _loadFromStorage() {
    final savedStats = LocalStorageService.loadUserStats();
    if (savedStats != null) {
      state = savedStats;
    }
  }
  
  void _saveToStorage() {
    LocalStorageService.saveUserStats(state);
  }
}

// Daily Mission Provider
final dailyMissionsProvider = StateNotifierProvider<DailyMissionsNotifier, List<Mission>>((ref) {
  return DailyMissionsNotifier();
});

class Mission {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final int coinReward;
  final MissionType type;
  final bool isCompleted;
  
  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    required this.xpReward,
    this.coinReward = 0,
    required this.type,
    this.isCompleted = false,
  });
  
  Mission copyWith({
    String? id,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    int? xpReward,
    int? coinReward,
    MissionType? type,
    bool? isCompleted,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
}

enum MissionType { daily, weekly, special }

class DailyMissionsNotifier extends StateNotifier<List<Mission>> {
  DailyMissionsNotifier() : super([]) {
    _loadFromStorage();
  }
  
  static List<Mission> _generateDailyMissions() {
    return [
      Mission(
        id: 'daily_study_time',
        title: '일일 학습 시간',
        description: '오늘 60분 이상 공부하기',
        targetValue: 60,
        xpReward: 100,
        coinReward: 50,
        type: MissionType.daily,
      ),
      Mission(
        id: 'complete_quests',
        title: '퀘스트 완료',
        description: '오늘 3개 퀘스트 완료하기',
        targetValue: 3,
        xpReward: 75,
        coinReward: 30,
        type: MissionType.daily,
      ),
      Mission(
        id: 'morning_study',
        title: '아침 공부',
        description: '오전 10시 이전에 공부 시작하기',
        targetValue: 1,
        xpReward: 50,
        coinReward: 25,
        type: MissionType.daily,
      ),
    ];
  }
  
  void updateMissionProgress(String missionId, int progress) {
    state = state.map((mission) {
      if (mission.id == missionId) {
        final newValue = mission.currentValue + progress;
        final completed = newValue >= mission.targetValue;
        return mission.copyWith(
          currentValue: newValue,
          isCompleted: completed,
        );
      }
      return mission;
    }).toList();
    
    _saveToStorage();
  }
  
  void resetDailyMissions() {
    state = _generateDailyMissions();
    LocalStorageService.saveLastMissionReset();
    _saveToStorage();
  }
  
  void _loadFromStorage() {
    if (LocalStorageService.shouldResetMissions()) {
      resetDailyMissions();
    } else {
      final savedMissions = LocalStorageService.loadDailyMissions();
      if (savedMissions.isNotEmpty) {
        state = savedMissions;
      } else {
        state = _generateDailyMissions();
      }
    }
  }
  
  void _saveToStorage() {
    LocalStorageService.saveDailyMissions(state);
  }
}