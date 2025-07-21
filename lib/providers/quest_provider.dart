import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quest.dart';
import 'user_stats_provider.dart';
import 'todo_category_provider.dart';
import 'notes_provider.dart';
import 'daily_goal_provider.dart';
import 'locale_provider.dart';
import '../l10n/quest_translations.dart';

class QuestNotifier extends StateNotifier<List<Quest>> {
  final Ref ref;
  static const int maxDailyQuests = 3;
  static const int maxWeeklyQuests = 2;
  
  QuestNotifier(this.ref) : super([]) {
    state = _generateQuests();
    _loadAcceptedQuests();
    _setupListeners();
  }
  
  void _setupListeners() {
    // Timer 상태 변화 감지
    ref.listen(userStatsProvider, (previous, current) {
      if (previous != null && current.todayStudyMinutes > previous.todayStudyMinutes) {
        final minutesAdded = current.todayStudyMinutes - previous.todayStudyMinutes;
        _updateQuestProgress('study_time', minutesAdded);
      }
    });
    
    // Todo 완료 감지
    ref.listen(todoItemsProvider, (previous, current) {
      if (previous != null) {
        final prevCompleted = previous.where((t) => t.isCompleted).length;
        final currCompleted = current.where((t) => t.isCompleted).length;
        if (currCompleted > prevCompleted) {
          _updateQuestProgress('todo_complete', currCompleted - prevCompleted);
        }
      }
    });
    
    // 노트 생성 감지
    ref.listen(notesProvider, (previous, current) {
      if (previous != null && current.length > previous.length) {
        _updateQuestProgress('note_create', current.length - previous.length);
      }
    });
    
    // 일일 목표 달성 감지
    ref.listen(dailyGoalProvider, (previous, current) {
      // 나중에 구현: 목표 달성 시 goal_complete 업데이트
    });
  }
  
  void _updateQuestProgress(String trackingType, int value) {
    state = state.map((quest) {
      if (quest.status == QuestStatus.accepted && 
          quest.trackingType == trackingType &&
          quest.currentValue < quest.targetValue) {
        final newValue = (quest.currentValue + value).clamp(0, quest.targetValue);
        final completed = newValue >= quest.targetValue;
        
        return quest.copyWith(
          currentValue: newValue,
          status: completed ? QuestStatus.completed : quest.status,
          completedAt: completed ? DateTime.now() : null,
        );
      }
      return quest;
    }).toList();
    _saveAcceptedQuests();
  }
  
  Future<void> _loadAcceptedQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final acceptedData = prefs.getString('accepted_quests');
    if (acceptedData != null) {
      final acceptedList = jsonDecode(acceptedData) as List;
      final acceptedQuestIds = acceptedList.map((e) => e['id'] as String).toSet();
      final acceptedQuestProgress = Map<String, int>.from(
        acceptedList.fold({}, (map, e) => {...map, e['id']: e['progress']})
      );
      
      state = state.map((quest) {
        if (acceptedQuestIds.contains(quest.id)) {
          return quest.copyWith(
            status: QuestStatus.accepted,
            currentValue: acceptedQuestProgress[quest.id] ?? 0,
            acceptedAt: DateTime.now(),
          );
        }
        return quest;
      }).toList();
    }
  }
  
  Future<void> _saveAcceptedQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final acceptedQuests = state.where((q) => q.status == QuestStatus.accepted).toList();
    final data = acceptedQuests.map((q) => {
      'id': q.id,
      'progress': q.currentValue,
    }).toList();
    await prefs.setString('accepted_quests', jsonEncode(data));
  }
  
  List<Quest> _generateQuests() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    final locale = ref.read(localeProvider).languageCode;
    
    // TODO: In production, these will be fetched from AdminService
    // For now, use localized hardcoded quests
    return [
      // 일일 퀘스트
      Quest(
        id: 'daily_study_1',
        title: '첫 발걸음',
        description: '오늘 30분 이상 공부하기',
        type: QuestType.daily,
        difficulty: QuestDifficulty.easy,
        xpReward: 50,
        coinReward: 20,
        targetValue: 30,
        deadline: endOfDay,
        icon: Icons.timer,
        color: Colors.blue,
        trackingType: 'study_time',
      ),
      Quest(
        id: 'daily_todo_1',
        title: '할 일 마스터',
        description: '오늘 3개 이상의 할 일 완료하기',
        type: QuestType.daily,
        difficulty: QuestDifficulty.easy,
        xpReward: 60,
        coinReward: 25,
        targetValue: 3,
        deadline: endOfDay,
        icon: Icons.task_alt,
        color: Colors.green,
        trackingType: 'todo_complete',
      ),
      Quest(
        id: 'daily_pomodoro_1',
        title: '집중의 달인',
        description: '뽀모도로 2사이클 완료하기',
        type: QuestType.daily,
        difficulty: QuestDifficulty.medium,
        xpReward: 80,
        coinReward: 35,
        targetValue: 2,
        deadline: endOfDay,
        icon: Icons.av_timer,
        color: Colors.orange,
        trackingType: 'pomodoro',
      ),
      
      // 주간 퀘스트
      Quest(
        id: 'weekly_study_1',
        title: '꾸준한 학습자',
        description: '이번 주 10시간 이상 공부하기',
        type: QuestType.weekly,
        difficulty: QuestDifficulty.medium,
        xpReward: 200,
        coinReward: 100,
        targetValue: 600, // 분 단위
        deadline: endOfWeek,
        icon: Icons.trending_up,
        color: Colors.purple,
        trackingType: 'study_time',
      ),
      Quest(
        id: 'weekly_streak_1',
        title: '연속 학습 챌린지',
        description: '5일 연속 학습하기',
        type: QuestType.weekly,
        difficulty: QuestDifficulty.hard,
        xpReward: 300,
        coinReward: 150,
        specialReward: '🔥 불타는 학습자',
        targetValue: 5,
        deadline: endOfWeek,
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
        trackingType: 'streak',
      ),
      
      // 특별 퀘스트
      Quest(
        id: 'special_note_1',
        title: '지식 기록자',
        description: '이번 주 노트 10개 작성하기',
        type: QuestType.special,
        difficulty: QuestDifficulty.medium,
        xpReward: 150,
        coinReward: 75,
        targetValue: 10,
        icon: Icons.note_add,
        color: Colors.teal,
        trackingType: 'note_create',
      ),
      Quest(
        id: 'special_perfect_1',
        title: '완벽한 하루',
        description: '하루 목표 100% 달성하기',
        type: QuestType.special,
        difficulty: QuestDifficulty.hard,
        xpReward: 250,
        coinReward: 125,
        specialReward: '⭐ 목표 달성자',
        targetValue: 1,
        icon: Icons.emoji_events,
        color: Colors.amber,
        trackingType: 'goal_complete',
      ),
    ];
  }
  
  void updateQuestProgress(String questId, int progress) {
    final questIndex = state.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return;
    
    final quest = state[questIndex];
    if (quest.status == QuestStatus.accepted && quest.currentValue < quest.targetValue) {
      final newValue = (quest.currentValue + progress).clamp(0, quest.targetValue);
      final completed = newValue >= quest.targetValue;
      
      state = [
        ...state.sublist(0, questIndex),
        quest.copyWith(
          currentValue: newValue,
          status: completed ? QuestStatus.completed : quest.status,
          completedAt: completed ? DateTime.now() : null,
        ),
        ...state.sublist(questIndex + 1),
      ];
      
      if (completed) {
        _showQuestCompleteNotification(quest);
      }
      
      _saveAcceptedQuests();
    }
  }
  
  void _showQuestCompleteNotification(Quest quest) {
    // TODO: 퀘스트 완료 알림 표시
  }
  
  bool canAcceptDailyQuest() {
    final acceptedDailyQuests = state.where((q) => 
      q.type == QuestType.daily && 
      (q.status == QuestStatus.accepted || q.status == QuestStatus.completed)
    ).length;
    return acceptedDailyQuests < maxDailyQuests;
  }
  
  bool canAcceptWeeklyQuest() {
    final acceptedWeeklyQuests = state.where((q) => 
      q.type == QuestType.weekly && 
      (q.status == QuestStatus.accepted || q.status == QuestStatus.completed)
    ).length;
    return acceptedWeeklyQuests < maxWeeklyQuests;
  }
  
  Future<bool> acceptQuest(String questId) async {
    final questIndex = state.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return false;
    
    final quest = state[questIndex];
    
    // 이미 수락했거나 완료한 퀘스트는 다시 수락할 수 없음
    if (quest.status != QuestStatus.available) return false;
    
    // 일일/주간 퀘스트 제한 확인
    if (quest.type == QuestType.daily && !canAcceptDailyQuest()) {
      return false;
    }
    if (quest.type == QuestType.weekly && !canAcceptWeeklyQuest()) {
      return false;
    }
    
    // 퀘스트 수락
    state = [
      ...state.sublist(0, questIndex),
      quest.copyWith(
        status: QuestStatus.accepted,
        acceptedAt: DateTime.now(),
      ),
      ...state.sublist(questIndex + 1),
    ];
    
    await _saveAcceptedQuests();
    return true;
  }
  
  void claimReward(String questId) {
    final questIndex = state.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return;
    
    final quest = state[questIndex];
    if (quest.status == QuestStatus.completed) {
      // 보상 지급
      ref.read(userStatsProvider.notifier).addXP(quest.xpReward);
      if (quest.coinReward > 0) {
        ref.read(userStatsProvider.notifier).addCoins(quest.coinReward);
      }
      
      // 퀘스트 상태 업데이트
      state = [
        ...state.sublist(0, questIndex),
        quest.copyWith(status: QuestStatus.claimed),
        ...state.sublist(questIndex + 1),
      ];
      
      _saveAcceptedQuests();
    }
  }
  
  List<Quest> getDailyQuests() {
    return state.where((q) => q.type == QuestType.daily).toList();
  }
  
  List<Quest> getWeeklyQuests() {
    return state.where((q) => q.type == QuestType.weekly).toList();
  }
  
  List<Quest> getActiveQuests() {
    return state.where((q) => q.status == QuestStatus.accepted).toList();
  }
  
  List<Quest> getAvailableQuests() {
    return state.where((q) => q.status == QuestStatus.available).toList();
  }
  
  List<Quest> getCompletedQuests() {
    return state.where((q) => q.status == QuestStatus.completed).toList();
  }
  
  int getAcceptedDailyQuestCount() {
    return state.where((q) => 
      q.type == QuestType.daily && 
      (q.status == QuestStatus.accepted || q.status == QuestStatus.completed)
    ).length;
  }
  
  int getAcceptedWeeklyQuestCount() {
    return state.where((q) => 
      q.type == QuestType.weekly && 
      (q.status == QuestStatus.accepted || q.status == QuestStatus.completed)
    ).length;
  }
  
  void resetDailyQuests() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    state = state.map((quest) {
      if (quest.type == QuestType.daily) {
        return quest.copyWith(
          currentValue: 0,
          status: QuestStatus.available,
          acceptedAt: null,
          completedAt: null,
          deadline: endOfDay,
        );
      }
      return quest;
    }).toList();
  }
}

// Providers
final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>(
  (ref) => QuestNotifier(ref),
);

final activeQuestsProvider = Provider<List<Quest>>((ref) {
  final quests = ref.watch(questProvider);
  return quests.where((q) => q.status == QuestStatus.accepted).toList();
});

final availableQuestsProvider = Provider<List<Quest>>((ref) {
  final quests = ref.watch(questProvider);
  return quests.where((q) => q.status == QuestStatus.available).toList();
});

final completedQuestsProvider = Provider<List<Quest>>((ref) {
  final quests = ref.watch(questProvider);
  return quests.where((q) => q.status == QuestStatus.completed).toList();
});

final dailyQuestsProvider = Provider<List<Quest>>((ref) {
  final quests = ref.watch(questProvider);
  return quests.where((q) => q.type == QuestType.daily).toList();
});

final weeklyQuestsProvider = Provider<List<Quest>>((ref) {
  final quests = ref.watch(questProvider);
  return quests.where((q) => q.type == QuestType.weekly).toList();
});