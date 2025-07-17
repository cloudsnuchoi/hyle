// Temporary stub for StudyTimer model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class StudyTimer extends amplify_core.Model {
  static const classType = const _StudyTimerModelType();
  final String id;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const StudyTimer._internal({required this.id});
  
  factory StudyTimer({String? id}) {
    return StudyTimer._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
    );
  }
  
  StudyTimer.fromJson(Map<String, dynamic> json) : id = json['id'];
  
  Map<String, dynamic> toJson() => {'id': id};
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "StudyTimer";
    modelSchemaDefinition.pluralName = "StudyTimers";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _StudyTimerModelType extends amplify_core.ModelType<StudyTimer> {
  const _StudyTimerModelType();
  
  @override
  StudyTimer fromJson(Map<String, dynamic> jsonData) {
    return StudyTimer.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'StudyTimer';
  }
}