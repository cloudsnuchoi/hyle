// Temporary stub for TimerEvent model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class TimerEvent extends amplify_core.Model {
  static const classType = const _TimerEventModelType();
  final String id;
  final String? sessionID;
  final EventType? eventType;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const TimerEvent._internal({
    required this.id,
    this.sessionID,
    this.eventType,
    this.timestamp,
    this.metadata,
  });
  
  factory TimerEvent({
    String? id,
    String? sessionID,
    EventType? eventType,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return TimerEvent._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      sessionID: sessionID,
      eventType: eventType,
      timestamp: timestamp,
      metadata: metadata,
    );
  }
  
  TimerEvent.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      sessionID = json['sessionID'],
      eventType = json['eventType'] != null ? EventType.values.byName(json['eventType']) : null,
      timestamp = json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      metadata = json['metadata'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionID': sessionID,
    'eventType': eventType?.name,
    'timestamp': timestamp?.toIso8601String(),
    'metadata': metadata,
  };
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "TimerEvent";
    modelSchemaDefinition.pluralName = "TimerEvents";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _TimerEventModelType extends amplify_core.ModelType<TimerEvent> {
  const _TimerEventModelType();
  
  @override
  TimerEvent fromJson(Map<String, dynamic> jsonData) {
    return TimerEvent.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'TimerEvent';
  }
}

enum EventType { START, PAUSE, RESUME, END, BREAK }