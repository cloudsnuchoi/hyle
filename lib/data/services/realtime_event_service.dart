import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final realtimeEventServiceProvider = Provider<RealtimeEventService>((ref) {
  return RealtimeEventService();
});

/// Service for publishing real-time events to Kinesis
class RealtimeEventService {
  static final RealtimeEventService _instance = RealtimeEventService._internal();
  factory RealtimeEventService() => _instance;
  RealtimeEventService._internal();

  final String _streamName = 'hyle-study-events-${const String.fromEnvironment('ENV', defaultValue: 'dev')}';
  
  // Event buffer for batch processing
  final List<StudyEvent> _eventBuffer = [];
  Timer? _flushTimer;
  static const int _maxBatchSize = 25;
  static const Duration _flushInterval = Duration(seconds: 5);

  /// Initialize the event service
  Future<void> initialize() async {
    // Start the flush timer
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flushEvents());
    
    safePrint('Realtime event service initialized');
  }

  /// Publish a study event
  Future<void> publishEvent(StudyEvent event) async {
    try {
      _eventBuffer.add(event);
      
      // Flush immediately if buffer is full
      if (_eventBuffer.length >= _maxBatchSize) {
        await _flushEvents();
      }
    } catch (e) {
      safePrint('Error adding event to buffer: $e');
    }
  }

  /// Flush events to Kinesis
  Future<void> _flushEvents() async {
    if (_eventBuffer.isEmpty) return;
    
    final eventsToSend = List<StudyEvent>.from(_eventBuffer);
    _eventBuffer.clear();
    
    try {
      // In production, this would use AWS SDK to send to Kinesis
      // For now, we'll send via Lambda
      await _sendEventsViaLambda(eventsToSend);
    } catch (e) {
      safePrint('Error flushing events: $e');
      // Re-add events to buffer on failure
      _eventBuffer.insertAll(0, eventsToSend);
    }
  }

  /// Send events via Lambda function
  Future<void> _sendEventsViaLambda(List<StudyEvent> events) async {
    final operation = Amplify.API.mutate(
      request: GraphQLRequest<String>(
        document: '''
          mutation PublishEvents(\$events: [EventInput!]!) {
            publishStudyEvents(events: \$events) {
              success
              processedCount
            }
          }
        ''',
        variables: {
          'events': events.map((e) => e.toJson()).toList(),
        },
      ),
    );
    
    await operation.response;
  }

  /// Track timer session start
  Future<void> trackTimerStart({
    required String userId,
    required String sessionId,
    required String timerType,
    String? subject,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.timerStart,
      userId: userId,
      sessionId: sessionId,
      data: {
        'timerType': timerType,
        'subject': subject,
      },
    ));
  }

  /// Track timer session pause
  Future<void> trackTimerPause({
    required String userId,
    required String sessionId,
    required int elapsedSeconds,
    String? reason,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.timerPause,
      userId: userId,
      sessionId: sessionId,
      data: {
        'elapsedSeconds': elapsedSeconds,
        'reason': reason,
      },
    ));
  }

  /// Track timer session end
  Future<void> trackTimerEnd({
    required String userId,
    required String sessionId,
    required int totalSeconds,
    required double productivityScore,
    int? xpEarned,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.timerEnd,
      userId: userId,
      sessionId: sessionId,
      data: {
        'totalSeconds': totalSeconds,
        'productivityScore': productivityScore,
        'xpEarned': xpEarned,
      },
    ));
  }

  /// Track todo creation
  Future<void> trackTodoCreated({
    required String userId,
    required String todoId,
    required String title,
    String? subject,
    int? estimatedMinutes,
    bool aiSuggested = false,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.todoCreated,
      userId: userId,
      data: {
        'todoId': todoId,
        'title': title,
        'subject': subject,
        'estimatedMinutes': estimatedMinutes,
        'aiSuggested': aiSuggested,
      },
    ));
  }

  /// Track todo completion
  Future<void> trackTodoCompleted({
    required String userId,
    required String todoId,
    required int actualMinutes,
    int? xpEarned,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.todoCompleted,
      userId: userId,
      data: {
        'todoId': todoId,
        'actualMinutes': actualMinutes,
        'xpEarned': xpEarned,
      },
    ));
  }

  /// Track note added
  Future<void> trackNoteAdded({
    required String userId,
    required String noteId,
    required String sessionId,
    required String content,
    String? subject,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.noteAdded,
      userId: userId,
      sessionId: sessionId,
      data: {
        'noteId': noteId,
        'contentLength': content.length,
        'subject': subject,
      },
    ));
  }

  /// Track break taken
  Future<void> trackBreakTaken({
    required String userId,
    required int breakDuration,
    required String breakType,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.breakTaken,
      userId: userId,
      data: {
        'breakDuration': breakDuration,
        'breakType': breakType,
      },
    ));
  }

  /// Track focus score calculated
  Future<void> trackFocusScore({
    required String userId,
    required String sessionId,
    required double focusScore,
    required Map<String, dynamic> metrics,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.focusScoreCalculated,
      userId: userId,
      sessionId: sessionId,
      data: {
        'focusScore': focusScore,
        'metrics': metrics,
      },
    ));
  }

  /// Track achievement unlocked
  Future<void> trackAchievementUnlocked({
    required String userId,
    required String achievementId,
    required String achievementName,
    int? xpReward,
    int? coinReward,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.achievementUnlocked,
      userId: userId,
      data: {
        'achievementId': achievementId,
        'achievementName': achievementName,
        'xpReward': xpReward,
        'coinReward': coinReward,
      },
    ));
  }

  /// Track AI interaction
  Future<void> trackAIInteraction({
    required String userId,
    required String interactionType,
    required String prompt,
    required String response,
    double? confidence,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.aiInteraction,
      userId: userId,
      data: {
        'interactionType': interactionType,
        'promptLength': prompt.length,
        'responseLength': response.length,
        'confidence': confidence,
      },
    ));
  }

  /// Track learning pattern detected
  Future<void> trackPatternDetected({
    required String userId,
    required String patternType,
    required Map<String, dynamic> patternData,
    required double confidence,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.patternDetected,
      userId: userId,
      data: {
        'patternType': patternType,
        'patternData': patternData,
        'confidence': confidence,
      },
    ));
  }

  /// Track intervention triggered
  Future<void> trackInterventionTriggered({
    required String userId,
    required String interventionType,
    required String reason,
    required Map<String, dynamic> context,
  }) async {
    await publishEvent(StudyEvent(
      type: EventType.interventionTriggered,
      userId: userId,
      data: {
        'interventionType': interventionType,
        'reason': reason,
        'context': context,
      },
    ));
  }

  /// Dispose the service
  void dispose() {
    _flushTimer?.cancel();
    _flushEvents(); // Final flush
  }
}

// Data Models
class StudyEvent {
  final EventType type;
  final String userId;
  final String? sessionId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  StudyEvent({
    required this.type,
    required this.userId,
    this.sessionId,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'userId': userId,
    'sessionId': sessionId,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
}

enum EventType {
  timerStart,
  timerPause,
  timerResume,
  timerEnd,
  todoCreated,
  todoCompleted,
  todoDeleted,
  noteAdded,
  noteUpdated,
  breakTaken,
  focusScoreCalculated,
  achievementUnlocked,
  levelUp,
  streakUpdated,
  missionCompleted,
  aiInteraction,
  patternDetected,
  interventionTriggered,
  socialInteraction,
  groupJoined,
  postCreated,
  studyReelViewed,
}