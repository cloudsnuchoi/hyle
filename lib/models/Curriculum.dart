/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';

class Curriculum extends amplify_core.Model {
  static const classType = const _CurriculumModelType();
  final String id;
  final CurriculumType? _type;
  final String? _name;
  final String? _country;
  final String? _description;
  final List<int>? _gradeRange;
  final List<String>? _subjects;
  final Map<String, dynamic>? _examFormat;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CurriculumModelIdentifier get modelIdentifier {
      return CurriculumModelIdentifier(
        id: id
      );
  }
  
  CurriculumType? get type {
    return _type;
  }
  
  String? get name {
    return _name;
  }
  
  String? get country {
    return _country;
  }
  
  String? get description {
    return _description;
  }
  
  List<int>? get gradeRange {
    return _gradeRange;
  }
  
  List<String>? get subjects {
    return _subjects;
  }
  
  Map<String, dynamic>? get examFormat {
    return _examFormat;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Curriculum._internal({required this.id, type, name, country, description, gradeRange, subjects, examFormat, createdAt, updatedAt}): _type = type, _name = name, _country = country, _description = description, _gradeRange = gradeRange, _subjects = subjects, _examFormat = examFormat, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Curriculum({String? id, CurriculumType? type, String? name, String? country, String? description, List<int>? gradeRange, List<String>? subjects, Map<String, dynamic>? examFormat}) {
    return Curriculum._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      type: type,
      name: name,
      country: country,
      description: description,
      gradeRange: gradeRange != null ? List<int>.unmodifiable(gradeRange) : gradeRange,
      subjects: subjects != null ? List<String>.unmodifiable(subjects) : subjects,
      examFormat: examFormat != null ? Map<String, dynamic>.unmodifiable(examFormat) : examFormat);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Curriculum &&
      id == other.id &&
      _type == other._type &&
      _name == other._name &&
      _country == other._country &&
      _description == other._description &&
      DeepCollectionEquality().equals(_gradeRange, other._gradeRange) &&
      DeepCollectionEquality().equals(_subjects, other._subjects) &&
      DeepCollectionEquality().equals(_examFormat, other._examFormat);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Curriculum {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("type=" + (_type != null ? _type!.name : "null") + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("country=" + "$_country" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("gradeRange=" + (_gradeRange != null ? _gradeRange!.toString() : "null") + ", ");
    buffer.write("subjects=" + (_subjects != null ? _subjects!.toString() : "null") + ", ");
    buffer.write("examFormat=" + (_examFormat != null ? _examFormat!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Curriculum copyWith({CurriculumType? type, String? name, String? country, String? description, List<int>? gradeRange, List<String>? subjects, Map<String, dynamic>? examFormat}) {
    return Curriculum._internal(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      country: country ?? this.country,
      description: description ?? this.description,
      gradeRange: gradeRange ?? this.gradeRange,
      subjects: subjects ?? this.subjects,
      examFormat: examFormat ?? this.examFormat);
  }
  
  Curriculum copyWithModelFieldValues({
    ModelFieldValue<CurriculumType?>? type,
    ModelFieldValue<String?>? name,
    ModelFieldValue<String?>? country,
    ModelFieldValue<String?>? description,
    ModelFieldValue<List<int>?>? gradeRange,
    ModelFieldValue<List<String>?>? subjects,
    ModelFieldValue<Map<String, dynamic>?>? examFormat
  }) {
    return Curriculum._internal(
      id: id,
      type: type == null ? this.type : type.value,
      name: name == null ? this.name : name.value,
      country: country == null ? this.country : country.value,
      description: description == null ? this.description : description.value,
      gradeRange: gradeRange == null ? this.gradeRange : gradeRange.value,
      subjects: subjects == null ? this.subjects : subjects.value,
      examFormat: examFormat == null ? this.examFormat : examFormat.value
    );
  }
  
  Curriculum.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _type = json['type'] != null ? CurriculumType.values.firstWhere((e) => e.name == json['type']) : null,
      _name = json['name'],
      _country = json['country'],
      _description = json['description'],
      _gradeRange = (json['gradeRange'] as List?)?.map((e) => (e as num).toInt()).toList(),
      _subjects = json['subjects']?.cast<String>(),
      _examFormat = json['examFormat'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'type': _type?.name, 'name': _name, 'country': _country, 'description': _description, 'gradeRange': _gradeRange, 'subjects': _subjects, 'examFormat': _examFormat, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'type': _type,
    'name': _name,
    'country': _country,
    'description': _description,
    'gradeRange': _gradeRange,
    'subjects': _subjects,
    'examFormat': _examFormat,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CurriculumModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CurriculumModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TYPE = amplify_core.QueryField(fieldName: "type");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final COUNTRY = amplify_core.QueryField(fieldName: "country");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final GRADERANGE = amplify_core.QueryField(fieldName: "gradeRange");
  static final SUBJECTS = amplify_core.QueryField(fieldName: "subjects");
  static final EXAMFORMAT = amplify_core.QueryField(fieldName: "examFormat");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Curriculum";
    modelSchemaDefinition.pluralName = "Curricula";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Curriculum.TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Curriculum.NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Curriculum.COUNTRY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Curriculum.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Curriculum.GRADERANGE,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.int.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Curriculum.SUBJECTS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Curriculum.EXAMFORMAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CurriculumModelType extends amplify_core.ModelType<Curriculum> {
  const _CurriculumModelType();
  
  @override
  Curriculum fromJson(Map<String, dynamic> jsonData) {
    return Curriculum.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Curriculum';
  }
}

class CurriculumModelIdentifier extends amplify_core.ModelIdentifier<Curriculum> {
  final String id;

  CurriculumModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'CurriculumModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CurriculumModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}

enum CurriculumType { korean_sat, ap, sat, ib, a_level, gcse, custom }

// ModelFieldValue definition
class ModelFieldValue<T> {
  final T? value;
  const ModelFieldValue.value(this.value);
}