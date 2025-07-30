import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_stats_provider.dart';
import '../features/todo/screens/todo_screen.dart';

class LocalStorageService {
  static const String _userStatsKey = 'user_stats';
  static const String _todoItemsKey = 'todo_items';
  static const String _dailyMissionsKey = 'daily_missions';
  static const String _lastMissionResetKey = 'last_mission_reset';
  
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }
  
  // User Stats
  static Future<void> saveUserStats(UserStats stats) async {
    final json = {
      'totalXP': stats.totalXP,
      'level': stats.level,
      'totalStudyTime': stats.totalStudyTime,
      'currentStreak': stats.currentStreak,
      'longestStreak': stats.longestStreak,
      'completedQuests': stats.completedQuests,
      'lastStudyDate': stats.lastStudyDate.toIso8601String(),
      'subjectStats': stats.subjectStats,
    };
    
    await prefs.setString(_userStatsKey, jsonEncode(json));
  }
  
  static UserStats? loadUserStats() {
    final jsonString = prefs.getString(_userStatsKey);
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString);
      return UserStats(
        totalXP: json['totalXP'] ?? 0,
        level: json['level'] ?? 1,
        totalStudyTime: json['totalStudyTime'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        longestStreak: json['longestStreak'] ?? 0,
        completedQuests: json['completedQuests'] ?? 0,
        lastStudyDate: DateTime.parse(json['lastStudyDate'] ?? DateTime.now().toIso8601String()),
        subjectStats: Map<String, int>.from(json['subjectStats'] ?? {}),
      );
    } catch (e) {
      print('Error loading user stats: $e');
      return null;
    }
  }
  
  // Todo Items
  static Future<void> saveTodoItems(List<TodoItem> todos) async {
    final jsonList = todos.map((todo) => {
      'id': todo.id,
      'title': todo.title,
      'subject': todo.subject,
      'estimatedTime': todo.estimatedTime?.inMinutes,
      'actualTime': todo.actualTime.inMinutes,
      'isCompleted': todo.isCompleted,
      'completedAt': todo.completedAt?.toIso8601String(),
      'xpReward': todo.xpReward,
      'isActive': todo.isActive,
    }).toList();
    
    await prefs.setString(_todoItemsKey, jsonEncode(jsonList));
  }
  
  static List<TodoItem> loadTodoItems() {
    final jsonString = prefs.getString(_todoItemsKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => TodoItem(
        id: json['id'],
        title: json['title'],
        subject: json['subject'],
        estimatedTime: json['estimatedTime'] != null 
          ? Duration(minutes: json['estimatedTime']) 
          : null,
        actualTime: Duration(minutes: json['actualTime'] ?? 0),
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
        xpReward: json['xpReward'] ?? 10,
        isActive: json['isActive'] ?? false,
      )).toList();
    } catch (e) {
      print('Error loading todo items: $e');
      return [];
    }
  }
  
  // Daily Missions
  static Future<void> saveDailyMissions(List<Mission> missions) async {
    final jsonList = missions.map((mission) => {
      'id': mission.id,
      'title': mission.title,
      'description': mission.description,
      'targetValue': mission.targetValue,
      'currentValue': mission.currentValue,
      'xpReward': mission.xpReward,
      'coinReward': mission.coinReward,
      'type': mission.type.name,
      'isCompleted': mission.isCompleted,
    }).toList();
    
    await prefs.setString(_dailyMissionsKey, jsonEncode(jsonList));
  }
  
  static List<Mission> loadDailyMissions() {
    final jsonString = prefs.getString(_dailyMissionsKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Mission(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        targetValue: json['targetValue'],
        currentValue: json['currentValue'] ?? 0,
        xpReward: json['xpReward'],
        coinReward: json['coinReward'] ?? 0,
        type: MissionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MissionType.daily,
        ),
        isCompleted: json['isCompleted'] ?? false,
      )).toList();
    } catch (e) {
      print('Error loading daily missions: $e');
      return [];
    }
  }
  
  // Mission Reset Tracking
  static Future<void> saveLastMissionReset() async {
    await prefs.setString(_lastMissionResetKey, DateTime.now().toIso8601String());
  }
  
  static DateTime? getLastMissionReset() {
    final dateString = prefs.getString(_lastMissionResetKey);
    if (dateString == null) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing last mission reset date: $e');
      return null;
    }
  }
  
  // Check if missions should be reset (daily at 4 AM)
  static bool shouldResetMissions() {
    final lastReset = getLastMissionReset();
    if (lastReset == null) return true;
    
    final now = DateTime.now();
    final today4AM = DateTime(now.year, now.month, now.day, 4);
    final yesterday4AM = today4AM.subtract(const Duration(days: 1));
    
    // If current time is after 4 AM today and last reset was before 4 AM today
    if (now.isAfter(today4AM) && lastReset.isBefore(today4AM)) {
      return true;
    }
    
    // If current time is before 4 AM today and last reset was before 4 AM yesterday
    if (now.isBefore(today4AM) && lastReset.isBefore(yesterday4AM)) {
      return true;
    }
    
    return false;
  }
  
  // Generic methods for int values
  static int? getInt(String key) {
    return prefs.getInt(key);
  }
  
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }
  
  // Clear all data
  static Future<void> clearAllData() async {
    await prefs.remove(_userStatsKey);
    await prefs.remove(_todoItemsKey);
    await prefs.remove(_dailyMissionsKey);
    await prefs.remove(_lastMissionResetKey);
  }
}