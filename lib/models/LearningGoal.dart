// Temporary stub for LearningGoal model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class LearningGoal extends amplify_core.Model {
  static const classType = const _LearningGoalModelType();
  final String id;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const LearningGoal._internal({required this.id});
  
  factory LearningGoal({String? id}) {
    return LearningGoal._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
    );
  }
  
  LearningGoal.fromJson(Map<String, dynamic> json) : id = json['id'];
  
  Map<String, dynamic> toJson() => {'id': id};
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "LearningGoal";
    modelSchemaDefinition.pluralName = "LearningGoals";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _LearningGoalModelType extends amplify_core.ModelType<LearningGoal> {
  const _LearningGoalModelType();
  
  @override
  LearningGoal fromJson(Map<String, dynamic> jsonData) {
    return LearningGoal.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'LearningGoal';
  }
}