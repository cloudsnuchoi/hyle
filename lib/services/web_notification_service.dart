import 'package:flutter/material.dart';

class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._internal();
  factory WebNotificationService() => _instance;
  WebNotificationService._internal();
  
  // 글로벌 컨텍스트를 위한 키
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
  
  // 알림 표시
  void showNotification({
    required String title,
    required String message,
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) return;
    
    final theme = Theme.of(context);
    
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? theme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration,
        margin: const EdgeInsets.all(20),
      ),
    );
  }
  
  // 목표 진행률 알림
  void showGoalProgress({
    required int percentage,
    required String goalType,
    String? encouragement,
  }) {
    String title;
    String body;
    Color color;
    IconData icon;
    
    if (percentage >= 100) {
      title = '🎉 목표 달성!';
      body = '$goalType 목표를 완료했어요!';
      color = Colors.purple;
      icon = Icons.emoji_events;
    } else if (percentage >= 70) {
      title = '💪 거의 다 왔어요!';
      body = '$goalType 목표 $percentage% 달성!';
      color = Colors.orange;
      icon = Icons.trending_up;
    } else {
      title = '📊 오늘의 진행률';
      body = '$goalType 목표 $percentage% 진행 중';
      color = Colors.blue;
      icon = Icons.show_chart;
    }
    
    if (encouragement != null) {
      body += '\n$encouragement';
    }
    
    showNotification(
      title: title,
      message: body,
      backgroundColor: color,
      icon: icon,
    );
  }
  
  // 휴식 시간 알림
  void showBreakReminder({
    required int studyMinutes,
    required int breakMinutes,
  }) {
    showNotification(
      title: '☕ 휴식 시간!',
      message: '$studyMinutes분 집중했어요! $breakMinutes분 휴식하세요',
      backgroundColor: Colors.green,
      icon: Icons.coffee,
    );
  }
  
  // 연속 학습 알림
  void showStreakNotification({
    required int currentStreak,
    required int nextMilestone,
  }) {
    String title;
    String body;
    
    if (currentStreak == nextMilestone) {
      title = '🏆 새로운 기록 달성!';
      body = '$currentStreak일 연속 학습 달성! 정말 대단해요!';
    } else {
      final daysLeft = nextMilestone - currentStreak;
      title = '🔥 $currentStreak일 연속 학습 중!';
      body = '$daysLeft일만 더하면 $nextMilestone일 달성!';
    }
    
    showNotification(
      title: title,
      message: body,
      backgroundColor: Colors.deepOrange,
      icon: Icons.local_fire_department,
    );
  }
  
  // 스마트 제안
  void showSmartSuggestion({
    required String suggestion,
    required String reason,
  }) {
    showNotification(
      title: '💡 AI 학습 제안',
      message: '$suggestion\n$reason',
      backgroundColor: Colors.purple,
      icon: Icons.lightbulb,
      duration: const Duration(seconds: 6),
    );
  }
}