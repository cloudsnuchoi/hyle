import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyGoal {
  final int todoCount;
  final int studyMinutes;
  
  DailyGoal({
    this.todoCount = 5,
    this.studyMinutes = 180, // 3시간
  });
  
  DailyGoal copyWith({
    int? todoCount,
    int? studyMinutes,
  }) {
    return DailyGoal(
      todoCount: todoCount ?? this.todoCount,
      studyMinutes: studyMinutes ?? this.studyMinutes,
    );
  }
}

class DailyGoalNotifier extends StateNotifier<DailyGoal> {
  DailyGoalNotifier() : super(DailyGoal()) {
    _loadGoals();
  }
  
  static const String _todoCountKey = 'daily_todo_goal';
  static const String _studyMinutesKey = 'daily_study_goal';
  
  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final todoCount = prefs.getInt(_todoCountKey) ?? 5;
    final studyMinutes = prefs.getInt(_studyMinutesKey) ?? 180;
    
    state = DailyGoal(
      todoCount: todoCount,
      studyMinutes: studyMinutes,
    );
  }
  
  Future<void> updateTodoGoal(int count) async {
    state = state.copyWith(todoCount: count);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todoCountKey, count);
  }
  
  Future<void> updateStudyGoal(int minutes) async {
    state = state.copyWith(studyMinutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_studyMinutesKey, minutes);
  }
  
  String get studyGoalHours {
    final hours = state.studyMinutes ~/ 60;
    final minutes = state.studyMinutes % 60;
    if (minutes == 0) {
      return '$hours시간';
    }
    return '$hours시간 $minutes분';
  }
}

// Provider
final dailyGoalProvider = StateNotifierProvider<DailyGoalNotifier, DailyGoal>(
  (ref) => DailyGoalNotifier(),
);