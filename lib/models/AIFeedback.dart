// Temporary stub for AIFeedback model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class AIFeedback extends amplify_core.Model {
  static const classType = const _AIFeedbackModelType();
  final String id;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const AIFeedback._internal({required this.id});
  
  factory AIFeedback({String? id}) {
    return AIFeedback._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
    );
  }
  
  AIFeedback.fromJson(Map<String, dynamic> json) : id = json['id'];
  
  Map<String, dynamic> toJson() => {'id': id};
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "AIFeedback";
    modelSchemaDefinition.pluralName = "AIFeedbacks";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _AIFeedbackModelType extends amplify_core.ModelType<AIFeedback> {
  const _AIFeedbackModelType();
  
  @override
  AIFeedback fromJson(Map<String, dynamic> jsonData) {
    return AIFeedback.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'AIFeedback';
  }
}