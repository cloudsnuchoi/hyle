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

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'User.dart';
import 'StudySession.dart';
import 'Todo.dart';
import 'Planner.dart';
import 'Memo.dart';
import 'FlashCard.dart';
import 'StudyTimer.dart';
import 'LearningGoal.dart';
import 'AIFeedback.dart';
import 'Mission.dart';
import 'MissionProgress.dart';
import 'TimerSession.dart';
import 'TimerEvent.dart';
import 'Review.dart';
import 'Curriculum.dart';

export 'User.dart' show User, PremiumTier, LearningType;
export 'StudySession.dart';
export 'Todo.dart' show Todo, Priority;
export 'Planner.dart';
export 'Memo.dart';
export 'FlashCard.dart';
export 'StudyTimer.dart';
export 'LearningGoal.dart';
export 'AIFeedback.dart';
export 'Mission.dart' show Mission, MissionFrequency;
export 'MissionProgress.dart';
export 'TimerSession.dart' show TimerSession, TimerType;
export 'TimerEvent.dart' show TimerEvent, EventType;
export 'Review.dart';
export 'Curriculum.dart' show Curriculum, CurriculumType;

class ModelProvider implements amplify_core.ModelProviderInterface {
  @override
  String version = "0e58c8a7e9c4f8a9b9c6d1e2f3a4b5c6";
  
  @override
  List<amplify_core.ModelSchema> modelSchemas = [
    User.schema,
    StudySession.schema,
    Todo.schema,
    Planner.schema,
    Memo.schema,
    FlashCard.schema,
    StudyTimer.schema,
    LearningGoal.schema,
    AIFeedback.schema,
    Mission.schema,
    MissionProgress.schema,
    TimerSession.schema,
    TimerEvent.schema,
    Review.schema,
    Curriculum.schema
  ];
  
  @override
  List<amplify_core.ModelSchema> customTypeSchemas = [];
  
  static final ModelProvider _instance = ModelProvider();
  
  static ModelProvider get instance => _instance;
  
  amplify_core.ModelType getModelTypeByModelName(String modelName) {
    switch(modelName) {
      case "User":
        return User.classType;
      case "StudySession":
        return StudySession.classType;
      case "Todo":
        return Todo.classType;
      case "Planner":
        return Planner.classType;
      case "Memo":
        return Memo.classType;
      case "FlashCard":
        return FlashCard.classType;
      case "StudyTimer":
        return StudyTimer.classType;
      case "LearningGoal":
        return LearningGoal.classType;
      case "AIFeedback":
        return AIFeedback.classType;
      case "Mission":
        return Mission.classType;
      case "MissionProgress":
        return MissionProgress.classType;
      case "TimerSession":
        return TimerSession.classType;
      case "TimerEvent":
        return TimerEvent.classType;
      case "Review":
        return Review.classType;
      case "Curriculum":
        return Curriculum.classType;
      default:
        throw Exception("Failed to find model in model provider for model name: " + modelName);
    }
  }
}