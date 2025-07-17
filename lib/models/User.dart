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

// ModelFieldValue definition for User model
class ModelFieldValue<T> {
  final T? value;
  const ModelFieldValue.value(this.value);
}

class User extends amplify_core.Model {
  static const classType = const _UserModelType();
  final String id;
  final String? _email;
  final String? _name;
  final String? _learningType;
  final String? _gradeLevel;
  final List<String>? _focusAreas;
  final Map<String, dynamic>? _preferences;
  final Map<String, dynamic>? _learningProfile;
  final PremiumTier? _premiumTier;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UserModelIdentifier get modelIdentifier {
      return UserModelIdentifier(
        id: id
      );
  }
  
  String? get email {
    return _email;
  }
  
  String? get name {
    return _name;
  }
  
  String? get learningType {
    return _learningType;
  }
  
  String? get gradeLevel {
    return _gradeLevel;
  }
  
  List<String>? get focusAreas {
    return _focusAreas;
  }
  
  Map<String, dynamic>? get preferences {
    return _preferences;
  }
  
  Map<String, dynamic>? get learningProfile {
    return _learningProfile;
  }
  
  PremiumTier? get premiumTier {
    return _premiumTier;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const User._internal({required this.id, email, name, learningType, gradeLevel, focusAreas, preferences, learningProfile, premiumTier, createdAt, updatedAt}): _email = email, _name = name, _learningType = learningType, _gradeLevel = gradeLevel, _focusAreas = focusAreas, _preferences = preferences, _learningProfile = learningProfile, _premiumTier = premiumTier, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory User({String? id, String? email, String? name, String? learningType, String? gradeLevel, List<String>? focusAreas, Map<String, dynamic>? preferences, Map<String, dynamic>? learningProfile, PremiumTier? premiumTier}) {
    return User._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      email: email,
      name: name,
      learningType: learningType,
      gradeLevel: gradeLevel,
      focusAreas: focusAreas != null ? List<String>.unmodifiable(focusAreas) : focusAreas,
      preferences: preferences != null ? Map<String, dynamic>.unmodifiable(preferences) : preferences,
      learningProfile: learningProfile != null ? Map<String, dynamic>.unmodifiable(learningProfile) : learningProfile,
      premiumTier: premiumTier);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
      id == other.id &&
      _email == other._email &&
      _name == other._name &&
      _learningType == other._learningType &&
      _gradeLevel == other._gradeLevel &&
      DeepCollectionEquality().equals(_focusAreas, other._focusAreas) &&
      DeepCollectionEquality().equals(_preferences, other._preferences) &&
      DeepCollectionEquality().equals(_learningProfile, other._learningProfile);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("User {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("learningType=" + "$_learningType" + ", ");
    buffer.write("gradeLevel=" + "$_gradeLevel" + ", ");
    buffer.write("focusAreas=" + (_focusAreas != null ? _focusAreas!.toString() : "null") + ", ");
    buffer.write("preferences=" + (_preferences != null ? _preferences!.toString() : "null") + ", ");
    buffer.write("learningProfile=" + (_learningProfile != null ? _learningProfile!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  User copyWith({String? email, String? name, String? learningType, String? gradeLevel, List<String>? focusAreas, Map<String, dynamic>? preferences, Map<String, dynamic>? learningProfile}) {
    return User._internal(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      learningType: learningType ?? this.learningType,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      focusAreas: focusAreas ?? this.focusAreas,
      preferences: preferences ?? this.preferences,
      learningProfile: learningProfile ?? this.learningProfile);
  }
  
  User copyWithModelFieldValues({
    ModelFieldValue<String?>? email,
    ModelFieldValue<String?>? name,
    ModelFieldValue<String?>? learningType,
    ModelFieldValue<String?>? gradeLevel,
    ModelFieldValue<List<String>?>? focusAreas,
    ModelFieldValue<Map<String, dynamic>?>? preferences,
    ModelFieldValue<Map<String, dynamic>?>? learningProfile
  }) {
    return User._internal(
      id: id,
      email: email == null ? this.email : email.value,
      name: name == null ? this.name : name.value,
      learningType: learningType == null ? this.learningType : learningType.value,
      gradeLevel: gradeLevel == null ? this.gradeLevel : gradeLevel.value,
      focusAreas: focusAreas == null ? this.focusAreas : focusAreas.value,
      preferences: preferences == null ? this.preferences : preferences.value,
      learningProfile: learningProfile == null ? this.learningProfile : learningProfile.value
    );
  }
  
  User.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _email = json['email'],
      _name = json['name'],
      _learningType = json['learningType'],
      _gradeLevel = json['gradeLevel'],
      _focusAreas = json['focusAreas']?.cast<String>(),
      _preferences = json['preferences'],
      _learningProfile = json['learningProfile'],
      _premiumTier = json['premiumTier'] != null ? PremiumTier.values.firstWhere((e) => e.name == json['premiumTier']) : PremiumTier.free,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'email': _email, 'name': _name, 'learningType': _learningType, 'gradeLevel': _gradeLevel, 'focusAreas': _focusAreas, 'preferences': _preferences, 'learningProfile': _learningProfile, 'premiumTier': _premiumTier?.name, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'email': _email,
    'name': _name,
    'learningType': _learningType,
    'gradeLevel': _gradeLevel,
    'focusAreas': _focusAreas,
    'preferences': _preferences,
    'learningProfile': _learningProfile,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final LEARNINGTYPE = amplify_core.QueryField(fieldName: "learningType");
  static final GRADELEVEL = amplify_core.QueryField(fieldName: "gradeLevel");
  static final FOCUSAREAS = amplify_core.QueryField(fieldName: "focusAreas");
  static final PREFERENCES = amplify_core.QueryField(fieldName: "preferences");
  static final LEARNINGPROFILE = amplify_core.QueryField(fieldName: "learningProfile");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "User";
    modelSchemaDefinition.pluralName = "Users";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.EMAIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.LEARNINGTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.GRADELEVEL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.FOCUSAREAS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.PREFERENCES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.LEARNINGPROFILE,
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

class _UserModelType extends amplify_core.ModelType<User> {
  const _UserModelType();
  
  @override
  User fromJson(Map<String, dynamic> jsonData) {
    return User.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'User';
  }
}

class UserModelIdentifier extends amplify_core.ModelIdentifier<User> {
  final String id;

  UserModelIdentifier({
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
  String toString() => 'UserModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}

enum PremiumTier { free, basic, pro, enterprise }
enum LearningType { visual, auditory, kinesthetic, reading }