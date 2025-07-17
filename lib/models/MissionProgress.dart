// Temporary stub for MissionProgress model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class MissionProgress extends amplify_core.Model {
  static const classType = const _MissionProgressModelType();
  final String id;
  final String? missionID;
  final String? userID;
  final bool? completed;
  final DateTime? claimedAt;
  final int? progress;
  final int? target;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const MissionProgress._internal({
    required this.id,
    this.missionID,
    this.userID,
    this.completed,
    this.claimedAt,
    this.progress,
    this.target,
  });
  
  factory MissionProgress({
    String? id,
    String? missionID,
    String? userID,
    bool? completed,
    DateTime? claimedAt,
    int? progress,
    int? target,
  }) {
    return MissionProgress._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      missionID: missionID,
      userID: userID,
      completed: completed,
      claimedAt: claimedAt,
      progress: progress,
      target: target,
    );
  }
  
  MissionProgress copyWith({
    String? missionID,
    String? userID,
    bool? completed,
    DateTime? claimedAt,
    int? progress,
    int? target,
  }) {
    return MissionProgress._internal(
      id: id,
      missionID: missionID ?? this.missionID,
      userID: userID ?? this.userID,
      completed: completed ?? this.completed,
      claimedAt: claimedAt ?? this.claimedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }
  
  MissionProgress.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      missionID = json['missionID'],
      userID = json['userID'],
      completed = json['completed'],
      claimedAt = json['claimedAt'] != null ? DateTime.parse(json['claimedAt']) : null,
      progress = json['progress'],
      target = json['target'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'missionID': missionID,
    'userID': userID,
    'completed': completed,
    'claimedAt': claimedAt?.toIso8601String(),
    'progress': progress,
    'target': target,
  };
  
  static final USER_ID = amplify_core.QueryField(fieldName: "userID");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "createdAt");
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "MissionProgress";
    modelSchemaDefinition.pluralName = "MissionProgresses";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _MissionProgressModelType extends amplify_core.ModelType<MissionProgress> {
  const _MissionProgressModelType();
  
  @override
  MissionProgress fromJson(Map<String, dynamic> jsonData) {
    return MissionProgress.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'MissionProgress';
  }
}