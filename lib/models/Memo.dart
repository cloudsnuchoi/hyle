// Temporary stub for Memo model
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Memo extends amplify_core.Model {
  static const classType = const _MemoModelType();
  final String id;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const Memo._internal({required this.id});
  
  factory Memo({String? id}) {
    return Memo._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
    );
  }
  
  Memo.fromJson(Map<String, dynamic> json) : id = json['id'];
  
  Map<String, dynamic> toJson() => {'id': id};
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Memo";
    modelSchemaDefinition.pluralName = "Memos";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _MemoModelType extends amplify_core.ModelType<Memo> {
  const _MemoModelType();
  
  @override
  Memo fromJson(Map<String, dynamic> jsonData) {
    return Memo.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Memo';
  }
}