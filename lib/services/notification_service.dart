import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 알림 채널 ID
  static const String _channelId = 'hyle_notifications';
  static const String _channelName = 'Hyle 학습 알림';
  static const String _channelDescription = 'AI 학습 동반자 Hyle의 알림';
  
  // 알림 ID (각 알림 유형별로 고유 ID)
  static const int _studyReminderBaseId = 1000;
  static const int _breakReminderBaseId = 2000;
  static const int _goalProgressBaseId = 3000;
  static const int _streakBaseId = 4000;
  static const int _todoReminderBaseId = 5000;
  
  // 초기화
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // 초기화
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Android 알림 채널 생성
    await _createNotificationChannel();
  }
  
  // 알림 채널 생성
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  
  // 알림 탭 핸들러
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: 알림 클릭 시 해당 화면으로 이동
    debugPrint('Notification tapped: ${response.payload}');
  }
  
  // 권한 요청
  Future<bool> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    final iOS = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return false;
  }
  
  // 1. 학습 시작 리마인더
  Future<void> scheduleStudyReminder({
    required String subject,
    required DateTime scheduledTime,
    String? description,
  }) async {
    final id = _studyReminderBaseId + Random().nextInt(100);
    
    await _notifications.zonedSchedule(
      id,
      '🎯 학습 시간입니다!',
      '$subject 공부할 시간이에요${description != null ? ' - $description' : ''}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.blue,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '$subject 공부할 시간이에요${description != null ? '\n$description' : ''}',
            contentTitle: '🎯 학습 시간입니다!',
            summaryText: 'Hyle AI 학습 도우미',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'study_reminder_$subject',
    );
  }
  
  // 2. 휴식 시간 알림
  Future<void> showBreakReminder({
    required int studyMinutes,
    required int breakMinutes,
  }) async {
    await _notifications.show(
      _breakReminderBaseId + Random().nextInt(100),
      '☕ 휴식 시간!',
      '$studyMinutes분 집중했어요! $breakMinutes분 휴식하세요',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.green,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '$studyMinutes분 동안 열심히 공부했어요!\n이제 $breakMinutes분 동안 휴식하면서 에너지를 충전하세요 🔋',
            contentTitle: '☕ 휴식 시간!',
            summaryText: 'Hyle AI 학습 도우미',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'break_reminder',
    );
  }
  
  // 3. 목표 진행률 알림
  Future<void> showGoalProgress({
    required int percentage,
    required String goalType,
    String? encouragement,
  }) async {
    String title;
    String body;
    Color color;
    
    if (percentage >= 100) {
      title = '🎉 목표 달성!';
      body = '$goalType 목표를 완료했어요!';
      color = Colors.purple;
    } else if (percentage >= 70) {
      title = '💪 거의 다 왔어요!';
      body = '$goalType 목표 $percentage% 달성!';
      color = Colors.orange;
    } else {
      title = '📊 오늘의 진행률';
      body = '$goalType 목표 $percentage% 진행 중';
      color = Colors.blue;
    }
    
    if (encouragement != null) {
      body += '\n$encouragement';
    }
    
    await _notifications.show(
      _goalProgressBaseId + Random().nextInt(100),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: color,
          enableVibration: true,
          showProgress: percentage < 100,
          progress: percentage,
          maxProgress: 100,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'goal_progress',
    );
  }
  
  // 4. 연속 학습 동기부여
  Future<void> showStreakNotification({
    required int currentStreak,
    required int nextMilestone,
  }) async {
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
    
    await _notifications.show(
      _streakBaseId + Random().nextInt(100),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.deepOrange,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'Hyle AI 학습 도우미',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'streak_notification',
    );
  }
  
  // 5. 미완료 할 일 알림
  Future<void> scheduleTodoReminder({
    required String todoTitle,
    required DateTime dueTime,
    String? category,
  }) async {
    final id = _todoReminderBaseId + Random().nextInt(100);
    
    await _notifications.zonedSchedule(
      id,
      '📝 할 일 마감 임박!',
      '${category != null ? '[$category] ' : ''}$todoTitle',
      tz.TZDateTime.from(dueTime.subtract(const Duration(hours: 1)), tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.red,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '1시간 후 마감: ${category != null ? '[$category] ' : ''}$todoTitle\n지금 시작하면 충분히 완료할 수 있어요!',
            contentTitle: '📝 할 일 마감 임박!',
            summaryText: 'Hyle AI 학습 도우미',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'todo_reminder_$todoTitle',
    );
  }
  
  // 6. 학습 패턴 기반 제안
  Future<void> showSmartSuggestion({
    required String suggestion,
    required String reason,
    String? actionText,
  }) async {
    await _notifications.show(
      Random().nextInt(1000),
      '💡 AI 학습 제안',
      suggestion,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.purple,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '$suggestion\n\n$reason',
            contentTitle: '💡 AI 학습 제안',
            summaryText: 'Hyle AI 학습 도우미',
          ),
          actions: actionText != null
              ? [
                  AndroidNotificationAction(
                    'action_accept',
                    actionText,
                    showsUserInterface: true,
                  ),
                ]
              : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'smart_suggestion',
    );
  }
  
  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // 예약된 알림 목록 가져오기
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}