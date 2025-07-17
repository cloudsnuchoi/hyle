// Temporary stub for TimerSession model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class TimerSession extends amplify_core.Model {
  static const classType = const _TimerSessionModelType();
  final String id;
  final String? userID;
  final String? subject;
  final TimerType? timerType;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? duration;
  final int? plannedDuration;
  final bool? completed;
  final String? type;
  final int? xpEarned;
  final String? location;
  final String? mood;
  final double? productivityScore;
  final int? distractionCount;
  final String? notes;
  final int? pausedDuration;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const TimerSession._internal({
    required this.id,
    this.userID,
    this.subject,
    this.timerType,
    this.startTime,
    this.endTime,
    this.duration,
    this.plannedDuration,
    this.completed,
    this.type,
    this.xpEarned,
    this.location,
    this.mood,
    this.productivityScore,
    this.distractionCount,
    this.notes,
    this.pausedDuration,
  });
  
  factory TimerSession({
    String? id,
    String? userID,
    String? subject,
    TimerType? timerType,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    int? plannedDuration,
    bool? completed,
    String? type,
    int? xpEarned,
    String? location,
    String? mood,
    double? productivityScore,
    int? distractionCount,
    String? notes,
    int? pausedDuration,
  }) {
    return TimerSession._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userID: userID,
      subject: subject,
      timerType: timerType,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      plannedDuration: plannedDuration,
      completed: completed,
      type: type,
      xpEarned: xpEarned,
      location: location,
      mood: mood,
      productivityScore: productivityScore,
      distractionCount: distractionCount,
      notes: notes,
      pausedDuration: pausedDuration,
    );
  }
  
  TimerSession copyWith({
    String? userID,
    String? subject,
    TimerType? timerType,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    int? plannedDuration,
    bool? completed,
    String? type,
    int? xpEarned,
    String? location,
    String? mood,
    double? productivityScore,
    int? distractionCount,
    String? notes,
    int? pausedDuration,
  }) {
    return TimerSession._internal(
      id: id,
      userID: userID ?? this.userID,
      subject: subject ?? this.subject,
      timerType: timerType ?? this.timerType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      completed: completed ?? this.completed,
      type: type ?? this.type,
      xpEarned: xpEarned ?? this.xpEarned,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      productivityScore: productivityScore ?? this.productivityScore,
      distractionCount: distractionCount ?? this.distractionCount,
      notes: notes ?? this.notes,
      pausedDuration: pausedDuration ?? this.pausedDuration,
    );
  }
  
  TimerSession.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      userID = json['userID'],
      subject = json['subject'],
      timerType = json['timerType'] != null ? TimerType.values.byName(json['timerType']) : null,
      startTime = json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime = json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration = json['duration'],
      plannedDuration = json['plannedDuration'],
      completed = json['completed'],
      type = json['type'],
      xpEarned = json['xpEarned'],
      location = json['location'],
      mood = json['mood'],
      productivityScore = json['productivityScore']?.toDouble(),
      distractionCount = json['distractionCount'],
      notes = json['notes'],
      pausedDuration = json['pausedDuration'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'userID': userID,
    'subject': subject,
    'timerType': timerType?.name,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'duration': duration,
    'plannedDuration': plannedDuration,
    'completed': completed,
    'type': type,
    'xpEarned': xpEarned,
    'location': location,
    'mood': mood,
    'productivityScore': productivityScore,
    'distractionCount': distractionCount,
    'notes': notes,
    'pausedDuration': pausedDuration,
  };
  
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER_ID = amplify_core.QueryField(fieldName: "userID");
  static final START_TIME = amplify_core.QueryField(fieldName: "startTime");
  static final END_TIME = amplify_core.QueryField(fieldName: "endTime");
  static final TYPE = amplify_core.QueryField(fieldName: "timerType");
  static final SUBJECT = amplify_core.QueryField(fieldName: "subject");
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "TimerSession";
    modelSchemaDefinition.pluralName = "TimerSessions";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _TimerSessionModelType extends amplify_core.ModelType<TimerSession> {
  const _TimerSessionModelType();
  
  @override
  TimerSession fromJson(Map<String, dynamic> jsonData) {
    return TimerSession.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'TimerSession';
  }
}

enum TimerType { STOPWATCH, TIMER, POMODORO }