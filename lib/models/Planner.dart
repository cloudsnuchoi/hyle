// Temporary stub for Planner model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Planner extends amplify_core.Model {
  static const classType = const _PlannerModelType();
  final String id;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const Planner._internal({required this.id});
  
  factory Planner({String? id}) {
    return Planner._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
    );
  }
  
  Planner.fromJson(Map<String, dynamic> json) : id = json['id'];
  
  Map<String, dynamic> toJson() => {'id': id};
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Planner";
    modelSchemaDefinition.pluralName = "Planners";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _PlannerModelType extends amplify_core.ModelType<Planner> {
  const _PlannerModelType();
  
  @override
  Planner fromJson(Map<String, dynamic> jsonData) {
    return Planner.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Planner';
  }
}