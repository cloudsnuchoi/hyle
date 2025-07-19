import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import '../providers/todo_category_provider.dart';
import '../providers/user_stats_provider.dart';
import '../models/todo_item.dart';
import '../features/timer/screens/timer_screen_gamified.dart';
import '../features/schedule/providers/schedule_provider.dart';
import '../features/schedule/models/schedule_models.dart';

// Smart Notification Manager Provider
final smartNotificationManagerProvider = Provider((ref) {
  return SmartNotificationManager(ref);
});

class SmartNotificationManager {
  final Ref ref;
  final NotificationService _notificationService = NotificationService();
  
  SmartNotificationManager(this.ref) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
    
    // 리스너 설정
    _setupListeners();
    
    // 초기 알림 스케줄링
    _scheduleInitialNotifications();
  }
  
  void _setupListeners() {
    // Timer 상태 변화 감지
    ref.listen(timerStateProvider, (previous, current) {
      _handleTimerStateChange(previous, current);
    });
    
    // Todo 변화 감지
    ref.listen(todoItemsProvider, (previous, current) {
      _handleTodoChange(previous ?? [], current);
    });
    
    // 학습 통계 변화 감지
    ref.listen(userStatsProvider, (previous, current) {
      _handleStatsChange(previous, current);
    });
    
    // 스케줄 변화 감지
    ref.listen(scheduleProvider, (previous, current) {
      _handleScheduleChange(previous ?? [], current);
    });
  }
  
  // Timer 상태 변화 처리
  void _handleTimerStateChange(TimerState? previous, TimerState current) {
    // 뽀모도로 휴식 시간 알림
    if (current.mode == TimerMode.pomodoro && 
        current.pomodoroPhase != PomodoroPhase.focus &&
        previous?.pomodoroPhase == PomodoroPhase.focus) {
      
      final breakMinutes = current.pomodoroPhase == PomodoroPhase.shortBreak ? 5 : 15;
      _notificationService.showBreakReminder(
        studyMinutes: 25,
        breakMinutes: breakMinutes,
      );
    }
    
    // 뽀모도로 세션 완료 시 동기부여
    if (current.pomodoroCount > 0 && 
        previous != null && 
        current.pomodoroCount > previous.pomodoroCount) {
      
      if (current.pomodoroCount % 4 == 0) {
        _notificationService.showGoalProgress(
          percentage: 100,
          goalType: '뽀모도로 사이클',
          encouragement: '4개의 뽀모도로를 완료했어요! 잠시 긴 휴식을 가져보세요.',
        );
      }
    }
  }
  
  // Todo 변화 처리
  void _handleTodoChange(List<TodoItem> previous, List<TodoItem> current) {
    // 새로운 Todo 추가 시 알림 스케줄링
    final newTodos = current.where((todo) => 
      !previous.any((prev) => prev.id == todo.id)
    ).toList();
    
    for (final todo in newTodos) {
      if (todo.dueDate != null && !todo.isCompleted) {
        _scheduleTodoReminder(todo);
      }
    }
    
    // 완료된 Todo 확인
    final completedCount = current.where((t) => t.isCompleted).length;
    final previousCompletedCount = previous.where((t) => t.isCompleted).length;
    
    if (completedCount > previousCompletedCount) {
      final totalCount = current.length;
      final percentage = (completedCount / totalCount * 100).round();
      
      _notificationService.showGoalProgress(
        percentage: percentage,
        goalType: '오늘의 할 일',
        encouragement: percentage >= 100 
            ? '모든 할 일을 완료했어요! 🎉' 
            : '잘하고 있어요! 계속 힘내세요!',
      );
    }
  }
  
  // 학습 통계 변화 처리
  void _handleStatsChange(UserStats? previous, UserStats current) {
    // 연속 학습 기록 갱신
    if (previous != null && current.currentStreak > previous.currentStreak) {
      final milestones = [3, 7, 14, 30, 50, 100];
      final nextMilestone = milestones.firstWhere(
        (m) => m > current.currentStreak,
        orElse: () => current.currentStreak + 10,
      );
      
      _notificationService.showStreakNotification(
        currentStreak: current.currentStreak,
        nextMilestone: nextMilestone,
      );
    }
    
    // 일일 목표 달성률 체크 (매 시간마다)
    if (DateTime.now().minute == 0) {
      final dailyGoalMinutes = 180; // 3시간
      final percentage = (current.todayStudyMinutes / dailyGoalMinutes * 100).round();
      
      if (percentage > 0 && percentage < 100) {
        _notificationService.showGoalProgress(
          percentage: percentage,
          goalType: '일일 학습',
          encouragement: _getEncouragementMessage(percentage),
        );
      }
    }
  }
  
  // 스케줄 변화 처리
  void _handleScheduleChange(List<StudyEvent> previous, List<StudyEvent> current) {
    // 새로운 일정에 대한 알림 스케줄링
    final newEvents = current.where((event) => 
      !previous.any((prev) => prev.id == event.id)
    ).toList();
    
    for (final event in newEvents) {
      if (event.startTime.isAfter(DateTime.now())) {
        _notificationService.scheduleStudyReminder(
          subject: event.subject,
          scheduledTime: event.startTime.subtract(const Duration(minutes: 10)),
          description: event.title,
        );
      }
    }
  }
  
  // Todo 리마인더 스케줄링
  void _scheduleTodoReminder(TodoItem todo) {
    if (todo.dueDate == null || todo.isCompleted) return;
    
    final category = ref.read(todoCategoryProvider)
        .firstWhere((cat) => cat.id == todo.categoryId,
            orElse: () => ref.read(todoCategoryProvider).first);
    
    _notificationService.scheduleTodoReminder(
      todoTitle: todo.title,
      dueTime: todo.dueDate!,
      category: category.name,
    );
  }
  
  // 초기 알림 스케줄링
  void _scheduleInitialNotifications() async {
    // 아침 학습 시작 알림 (매일 오전 8시)
    final now = DateTime.now();
    var morningTime = DateTime(now.year, now.month, now.day, 8, 0);
    if (morningTime.isBefore(now)) {
      morningTime = morningTime.add(const Duration(days: 1));
    }
    
    _notificationService.scheduleStudyReminder(
      subject: '오늘의 학습',
      scheduledTime: morningTime,
      description: '새로운 하루를 시작해볼까요? 💪',
    );
    
    // 저녁 학습 정리 알림 (매일 오후 9시)
    var eveningTime = DateTime(now.year, now.month, now.day, 21, 0);
    if (eveningTime.isBefore(now)) {
      eveningTime = eveningTime.add(const Duration(days: 1));
    }
    
    _notificationService.showSmartSuggestion(
      suggestion: '오늘 하루도 수고했어요! 학습 내용을 정리해보는 건 어떨까요?',
      reason: '저녁 시간에 복습하면 기억에 더 오래 남아요',
      actionText: '복습 시작',
    );
  }
  
  // 스마트 제안 생성
  void generateSmartSuggestion() async {
    final stats = ref.read(userStatsProvider);
    final todos = ref.read(todoItemsProvider);
    final currentHour = DateTime.now().hour;
    
    // 시간대별 제안
    if (currentHour >= 14 && currentHour <= 16) {
      // 오후 2-4시: 졸린 시간대
      _notificationService.showSmartSuggestion(
        suggestion: '잠깐 스트레칭하고 가벼운 문제부터 풀어볼까요?',
        reason: '오후 시간대는 집중력이 떨어지기 쉬워요. 쉬운 것부터 시작해보세요!',
        actionText: '쉬운 문제 풀기',
      );
    } else if (currentHour >= 19 && currentHour <= 21) {
      // 저녁 7-9시: 골든타임
      final difficultTodos = todos.where((t) => 
        !t.isCompleted && t.difficulty == 'hard'
      ).toList();
      
      if (difficultTodos.isNotEmpty) {
        _notificationService.showSmartSuggestion(
          suggestion: '지금이 어려운 문제를 해결하기 좋은 시간이에요!',
          reason: '저녁 시간대는 집중력이 높아 어려운 과제를 하기 좋아요',
          actionText: '어려운 문제 도전',
        );
      }
    }
    
    // 학습 패턴 기반 제안
    if (stats.currentStreak > 0 && stats.todayStudyMinutes == 0) {
      _notificationService.showSmartSuggestion(
        suggestion: '${stats.currentStreak}일 연속 기록이 끊기지 않도록 지금 시작해볼까요?',
        reason: '꾸준함이 가장 중요해요! 5분이라도 시작해보세요',
        actionText: '학습 시작',
      );
    }
  }
  
  // 격려 메시지 생성
  String _getEncouragementMessage(int percentage) {
    if (percentage < 30) {
      return '시작이 반이에요! 조금씩 해봐요 💪';
    } else if (percentage < 50) {
      return '잘하고 있어요! 절반이 눈앞이네요 🎯';
    } else if (percentage < 70) {
      return '대단해요! 목표 달성이 눈앞이에요 🚀';
    } else if (percentage < 90) {
      return '거의 다 왔어요! 조금만 더 힘내세요 🔥';
    } else {
      return '정말 대단해요! 곧 목표 달성이에요 🎉';
    }
  }
  
  // 알림 설정 토글
  Future<void> toggleNotificationSetting(String type, bool enabled) async {
    // SharedPreferences에 설정 저장
    // TODO: 설정에 따라 알림 활성화/비활성화
  }
  
  // 모든 알림 지우기
  Future<void> clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}