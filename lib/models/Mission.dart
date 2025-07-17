// Temporary stub for Mission model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Mission extends amplify_core.Model {
  static const classType = const _MissionModelType();
  final String id;
  final String? title;
  final String? description;
  final MissionFrequency? frequency;
  final int? xpReward;
  final int? coinReward;
  final String? badgeReward;
  final String? requirement;
  final bool? isActive;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const Mission._internal({
    required this.id,
    this.title,
    this.description,
    this.frequency,
    this.xpReward,
    this.coinReward,
    this.badgeReward,
    this.requirement,
    this.isActive,
  });
  
  factory Mission({
    String? id,
    String? title,
    String? description,
    MissionFrequency? frequency,
    int? xpReward,
    int? coinReward,
    String? badgeReward,
    String? requirement,
    bool? isActive,
  }) {
    return Mission._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      description: description,
      frequency: frequency,
      xpReward: xpReward,
      coinReward: coinReward,
      badgeReward: badgeReward,
      requirement: requirement,
      isActive: isActive,
    );
  }
  
  Mission.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      description = json['description'],
      frequency = json['frequency'] != null ? MissionFrequency.values.byName(json['frequency']) : null,
      xpReward = json['xpReward'],
      coinReward = json['coinReward'],
      badgeReward = json['badgeReward'],
      requirement = json['requirement'],
      isActive = json['isActive'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'frequency': frequency?.name,
    'xpReward': xpReward,
    'coinReward': coinReward,
    'badgeReward': badgeReward,
    'requirement': requirement,
    'isActive': isActive,
  };
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Mission";
    modelSchemaDefinition.pluralName = "Missions";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Mission.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
  });
  
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final FREQUENCY = amplify_core.QueryField(fieldName: "frequency");
  static final IS_ACTIVE = amplify_core.QueryField(fieldName: "isActive");
}

class _MissionModelType extends amplify_core.ModelType<Mission> {
  const _MissionModelType();
  
  @override
  Mission fromJson(Map<String, dynamic> jsonData) {
    return Mission.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Mission';
  }
}

enum MissionFrequency { DAILY, WEEKLY, MONTHLY }