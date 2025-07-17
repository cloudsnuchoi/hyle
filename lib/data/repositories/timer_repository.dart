import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ModelProvider.dart';

// Timer Repository Provider
final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});

class TimerRepository {
  // Create new timer session
  Future<TimerSession> createTimerSession({
    required String userId,
    required TimerType type,
    String? subject,
    String? todoId,
    String? location,
    String? mood,
  }) async {
    try {
      final session = TimerSession(
        startTime: TemporalDateTime.now(),
        duration: 0,
        type: type,
        subject: subject,
        todoID: todoId,
        xpEarned: 0,
        location: location,
        mood: mood,
        userID: userId,
      );

      final response = await Amplify.DataStore.save(session);
      
      // Create start event
      await createTimerEvent(
        sessionId: response.id,
        type: EventType.START,
      );
      
      return response;
    } catch (e) {
      safePrint('Error creating timer session: $e');
      rethrow;
    }
  }

  // Update timer session
  Future<TimerSession> updateTimerSession({
    required TimerSession session,
    Duration? pausedDuration,
    int? duration,
    double? productivityScore,
    int? distractionCount,
    String? notes,
  }) async {
    try {
      final updatedSession = session.copyWith(
        pausedDuration: pausedDuration?.inSeconds ?? session.pausedDuration,
        duration: duration ?? session.duration,
        productivityScore: productivityScore ?? session.productivityScore,
        distractionCount: distractionCount ?? session.distractionCount,
        notes: notes ?? session.notes,
      );

      final response = await Amplify.DataStore.save(updatedSession);
      return response;
    } catch (e) {
      safePrint('Error updating timer session: $e');
      rethrow;
    }
  }

  // End timer session
  Future<TimerSession> endTimerSession({
    required String sessionId,
    required int totalDuration,
    required int xpEarned,
  }) async {
    try {
      final sessions = await Amplify.DataStore.query(
        TimerSession.classType,
        where: TimerSession.ID.eq(sessionId),
      );
      
      if (sessions.isEmpty) throw Exception('Session not found');
      
      final session = sessions.first;
      final updatedSession = session.copyWith(
        endTime: TemporalDateTime.now(),
        duration: totalDuration,
        xpEarned: xpEarned,
      );

      final response = await Amplify.DataStore.save(updatedSession);
      
      // Create end event
      await createTimerEvent(
        sessionId: sessionId,
        type: EventType.END,
      );
      
      return response;
    } catch (e) {
      safePrint('Error ending timer session: $e');
      rethrow;
    }
  }

  // Create timer event
  Future<TimerEvent> createTimerEvent({
    required String sessionId,
    required EventType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final event = TimerEvent(
        type: type,
        timestamp: TemporalDateTime.now(),
        data: data,
        sessionID: sessionId,
      );

      final response = await Amplify.DataStore.save(event);
      return response;
    } catch (e) {
      safePrint('Error creating timer event: $e');
      rethrow;
    }
  }

  // Get user's timer sessions
  Future<List<TimerSession>> getUserSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TimerType? type,
    String? subject,
    int? limit,
  }) async {
    try {
      var query = TimerSession.USER_ID.eq(userId);
      
      if (startDate != null) {
        query = query.and(TimerSession.START_TIME.ge(
          TemporalDateTime(startDate),
        ));
      }
      
      if (endDate != null) {
        query = query.and(TimerSession.START_TIME.le(
          TemporalDateTime(endDate),
        ));
      }
      
      if (type != null) {
        query = query.and(TimerSession.TYPE.eq(type));
      }
      
      if (subject != null) {
        query = query.and(TimerSession.SUBJECT.eq(subject));
      }

      final sessions = await Amplify.DataStore.query(
        TimerSession.classType,
        where: query,
        sortBy: [TimerSession.START_TIME.descending()],
        pagination: limit != null ? QueryPagination(limit: limit) : null,
      );

      return sessions;
    } catch (e) {
      safePrint('Error getting user sessions: $e');
      return [];
    }
  }

  // Get session statistics
  Future<SessionStatistics> getSessionStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final sessions = await getUserSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (sessions.isEmpty) {
        return SessionStatistics.empty();
      }

      // Calculate statistics
      int totalTime = 0;
      int totalSessions = sessions.length;
      Map<String, int> timeBySubject = {};
      Map<TimerType, int> timeByType = {};
      Map<int, int> hourDistribution = {};
      double totalProductivity = 0;
      int productivityCount = 0;

      for (final session in sessions) {
        totalTime += session.duration;
        
        // Time by subject
        if (session.subject != null) {
          timeBySubject[session.subject!] = 
              (timeBySubject[session.subject!] ?? 0) + session.duration;
        }
        
        // Time by type
        timeByType[session.type] = 
            (timeByType[session.type] ?? 0) + session.duration;
        
        // Hour distribution
        final hour = session.startTime.toDateTime().hour;
        hourDistribution[hour] = (hourDistribution[hour] ?? 0) + 1;
        
        // Productivity
        if (session.productivityScore != null) {
          totalProductivity += session.productivityScore!;
          productivityCount++;
        }
      }

      // Find peak hours
      final sortedHours = hourDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final peakHours = sortedHours.take(3).map((e) => e.key).toList();

      // Calculate averages
      final avgSessionLength = totalTime ~/ totalSessions;
      final avgProductivity = productivityCount > 0 
          ? totalProductivity / productivityCount 
          : 0.0;

      return SessionStatistics(
        totalTime: totalTime,
        totalSessions: totalSessions,
        averageSessionLength: avgSessionLength,
        timeBySubject: timeBySubject,
        timeByType: timeByType,
        peakHours: peakHours,
        averageProductivity: avgProductivity,
      );
    } catch (e) {
      safePrint('Error getting session statistics: $e');
      return SessionStatistics.empty();
    }
  }

  // Get active session
  Future<TimerSession?> getActiveSession(String userId) async {
    try {
      final sessions = await Amplify.DataStore.query(
        TimerSession.classType,
        where: TimerSession.USER_ID.eq(userId)
            .and(TimerSession.END_TIME.eq(null)),
        sortBy: [TimerSession.START_TIME.descending()],
        pagination: const QueryPagination(limit: 1),
      );

      return sessions.isNotEmpty ? sessions.first : null;
    } catch (e) {
      safePrint('Error getting active session: $e');
      return null;
    }
  }

  // Subscribe to session updates
  Stream<TimerSession> subscribeToSessionUpdates(String sessionId) {
    return Amplify.DataStore.observeQuery(
      TimerSession.classType,
      where: TimerSession.ID.eq(sessionId),
    ).map((event) => event.items.first);
  }

  // Calculate XP for session
  int calculateSessionXP({
    required int duration,
    required TimerType type,
    double? productivityScore,
    bool hasCompletedTodo = false,
    int streak = 0,
    DateTime? sessionTime,
  }) {
    // Base XP: 1 XP per minute
    int baseXP = duration ~/ 60;
    
    // Type multiplier
    double typeMultiplier = 1.0;
    switch (type) {
      case TimerType.POMODORO:
        typeMultiplier = 1.2; // 20% bonus for using Pomodoro
        break;
      case TimerType.TIMER:
        typeMultiplier = 1.1; // 10% bonus for timed sessions
        break;
      case TimerType.STOPWATCH:
        typeMultiplier = 1.0; // No bonus
        break;
    }
    
    // Productivity multiplier
    double productivityMultiplier = 1.0;
    if (productivityScore != null) {
      productivityMultiplier = 0.8 + (productivityScore * 0.4); // 0.8x to 1.2x
    }
    
    // Todo completion bonus
    int todoBonus = hasCompletedTodo ? 10 : 0;
    
    // Streak multiplier
    double streakMultiplier = 1.0 + (streak * 0.02); // 2% per day
    streakMultiplier = streakMultiplier.clamp(1.0, 2.0); // Max 100% bonus
    
    // Time of day bonus (morning bonus)
    double timeBonus = 1.0;
    if (sessionTime != null) {
      final hour = sessionTime.hour;
      if (hour >= 5 && hour < 9) {
        timeBonus = 1.1; // 10% morning bonus
      }
    }
    
    // Calculate total XP
    double totalXP = baseXP * typeMultiplier * productivityMultiplier * 
                     streakMultiplier * timeBonus + todoBonus;
    
    return totalXP.round();
  }

  // Analyze productivity patterns
  Future<ProductivityAnalysis> analyzeProductivity({
    required String userId,
    required int days,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final sessions = await getUserSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (sessions.isEmpty) {
        return ProductivityAnalysis.empty();
      }

      // Group sessions by day
      Map<String, List<TimerSession>> sessionsByDay = {};
      for (final session in sessions) {
        final day = _formatDate(session.startTime.toDateTime());
        sessionsByDay[day] = (sessionsByDay[day] ?? [])..add(session);
      }

      // Calculate daily productivity
      Map<String, double> dailyProductivity = {};
      Map<String, int> dailyTime = {};
      
      sessionsByDay.forEach((day, daySessions) {
        int totalTime = 0;
        double totalProductivity = 0;
        int productivityCount = 0;
        
        for (final session in daySessions) {
          totalTime += session.duration;
          if (session.productivityScore != null) {
            totalProductivity += session.productivityScore!;
            productivityCount++;
          }
        }
        
        dailyTime[day] = totalTime;
        if (productivityCount > 0) {
          dailyProductivity[day] = totalProductivity / productivityCount;
        }
      });

      // Find best and worst days
      final sortedByProductivity = dailyProductivity.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final bestDays = sortedByProductivity.take(3)
          .map((e) => e.key)
          .toList();
      final worstDays = sortedByProductivity.reversed.take(3)
          .map((e) => e.key)
          .toList();

      // Calculate trend
      double trend = 0;
      if (dailyProductivity.length > 1) {
        final values = dailyProductivity.values.toList();
        final firstHalf = values.take(values.length ~/ 2).toList();
        final secondHalf = values.skip(values.length ~/ 2).toList();
        
        final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
        final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
        
        trend = ((secondAvg - firstAvg) / firstAvg) * 100;
      }

      return ProductivityAnalysis(
        dailyProductivity: dailyProductivity,
        dailyTime: dailyTime,
        bestDays: bestDays,
        worstDays: worstDays,
        trend: trend,
        totalSessions: sessions.length,
      );
    } catch (e) {
      safePrint('Error analyzing productivity: $e');
      return ProductivityAnalysis.empty();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Data classes
class SessionStatistics {
  final int totalTime; // in seconds
  final int totalSessions;
  final int averageSessionLength; // in seconds
  final Map<String, int> timeBySubject;
  final Map<TimerType, int> timeByType;
  final List<int> peakHours;
  final double averageProductivity;

  SessionStatistics({
    required this.totalTime,
    required this.totalSessions,
    required this.averageSessionLength,
    required this.timeBySubject,
    required this.timeByType,
    required this.peakHours,
    required this.averageProductivity,
  });

  factory SessionStatistics.empty() {
    return SessionStatistics(
      totalTime: 0,
      totalSessions: 0,
      averageSessionLength: 0,
      timeBySubject: {},
      timeByType: {},
      peakHours: [],
      averageProductivity: 0.0,
    );
  }
}

class ProductivityAnalysis {
  final Map<String, double> dailyProductivity;
  final Map<String, int> dailyTime;
  final List<String> bestDays;
  final List<String> worstDays;
  final double trend; // percentage change
  final int totalSessions;

  ProductivityAnalysis({
    required this.dailyProductivity,
    required this.dailyTime,
    required this.bestDays,
    required this.worstDays,
    required this.trend,
    required this.totalSessions,
  });

  factory ProductivityAnalysis.empty() {
    return ProductivityAnalysis(
      dailyProductivity: {},
      dailyTime: {},
      bestDays: [],
      worstDays: [],
      trend: 0.0,
      totalSessions: 0,
    );
  }
}