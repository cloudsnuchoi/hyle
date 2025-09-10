// Curriculum-related models that don't need to be Amplify models
// import 'ModelProvider.dart'; // Removed - no longer using Amplify

// Define CurriculumType enum here
enum CurriculumType {
  MIDDLE_SCHOOL,
  HIGH_SCHOOL,
  CSAT,
  AP,
  IB,
  CUSTOM
}

// Data models
class Subject {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final List<CurriculumType> curriculumTypes;
  final List<Unit> units;

  Subject({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.curriculumTypes,
    required this.units,
  });
}

class Unit {
  final String id;
  final String name;
  final String nameEn;
  final int order;
  final int estimatedHours;

  Unit({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.order,
    required this.estimatedHours,
  });
}

class Topic {
  final String id; // Format: subject.unit.topic
  final String name;
  final String? nameEn;
  final String subjectId;
  final String unitId;
  final int order;
  final int estimatedHours;
  final List<String> keywords;
  final List<String> prerequisites;
  final List<String> learningObjectives;
  final double? assessmentWeight;

  Topic({
    required this.id,
    required this.name,
    this.nameEn,
    required this.subjectId,
    required this.unitId,
    required this.order,
    required this.estimatedHours,
    required this.keywords,
    required this.prerequisites,
    required this.learningObjectives,
    this.assessmentWeight,
  });
}

class LearningStandard {
  final String id;
  final CurriculumType curriculum;
  final String subject;
  final int grade;
  final String code;
  final String description;
  final List<String> topics;
  final BloomsTaxonomy blooms;
  final double weight;

  LearningStandard({
    required this.id,
    required this.curriculum,
    required this.subject,
    required this.grade,
    required this.code,
    required this.description,
    required this.topics,
    required this.blooms,
    required this.weight,
  });
}

enum BloomsTaxonomy {
  remembering,
  understanding,
  applying,
  analyzing,
  evaluating,
  creating,
}

class ExamFormat {
  final int totalDuration; // minutes
  final List<ExamSection> sections;

  ExamFormat({
    required this.totalDuration,
    required this.sections,
  });
}

class ExamSection {
  final String name;
  final int duration;
  final int questions;

  ExamSection({
    required this.name,
    required this.duration,
    required this.questions,
  });
}

class ExamSyllabus {
  final String examType;
  final String subject;
  final List<SyllabusUnit> units;
  final List<String> allowedCalculators;
  final Map<String, double> scoringRubric;

  ExamSyllabus({
    required this.examType,
    required this.subject,
    required this.units,
    required this.allowedCalculators,
    required this.scoringRubric,
  });

  factory ExamSyllabus.fromJson(Map<String, dynamic> json) {
    return ExamSyllabus(
      examType: json['examType'],
      subject: json['subject'],
      units: (json['units'] as List)
          .map((u) => SyllabusUnit.fromJson(u))
          .toList(),
      allowedCalculators: List<String>.from(json['allowedCalculators']),
      scoringRubric: Map<String, double>.from(json['scoringRubric']),
    );
  }
}

class SyllabusUnit {
  final String id;
  final String name;
  final double weight;
  final List<String> topics;
  final List<String> skills;

  SyllabusUnit({
    required this.id,
    required this.name,
    required this.weight,
    required this.topics,
    required this.skills,
  });

  factory SyllabusUnit.fromJson(Map<String, dynamic> json) {
    return SyllabusUnit(
      id: json['id'],
      name: json['name'],
      weight: json['weight'],
      topics: List<String>.from(json['topics']),
      skills: List<String>.from(json['skills']),
    );
  }
}

class AssessmentCriteria {
  final String id;
  final String topicId;
  final String criterion;
  final String description;
  final int maxScore;
  final List<String> descriptors;

  AssessmentCriteria({
    required this.id,
    required this.topicId,
    required this.criterion,
    required this.description,
    required this.maxScore,
    required this.descriptors,
  });

  factory AssessmentCriteria.fromJson(Map<String, dynamic> json) {
    return AssessmentCriteria(
      id: json['id'],
      topicId: json['topicId'],
      criterion: json['criterion'],
      description: json['description'],
      maxScore: json['maxScore'],
      descriptors: List<String>.from(json['descriptors']),
    );
  }
}

class CurriculumMapping {
  final String activityDescription;
  final List<Topic> mappedTopics;
  final List<LearningStandard>? mappedStandards;
  final double confidence;
  final List<String>? suggestedKeywords;

  CurriculumMapping({
    required this.activityDescription,
    required this.mappedTopics,
    this.mappedStandards,
    required this.confidence,
    this.suggestedKeywords,
  });
}

class CurriculumProgress {
  final String userId;
  final CurriculumType curriculum;
  final String subject;
  final List<String> completedTopics;
  final List<String> inProgressTopics;
  final int totalTopics;
  final double completionPercentage;
  final Map<String, double>? topicMastery;
  final DateTime? lastUpdated;

  CurriculumProgress({
    required this.userId,
    required this.curriculum,
    required this.subject,
    required this.completedTopics,
    required this.inProgressTopics,
    required this.totalTopics,
    required this.completionPercentage,
    this.topicMastery,
    this.lastUpdated,
  });

  factory CurriculumProgress.fromJson(Map<String, dynamic> json) {
    return CurriculumProgress(
      userId: json['userId'],
      curriculum: CurriculumType.values.firstWhere(
        (e) => e.name == json['curriculum'],
      ),
      subject: json['subject'],
      completedTopics: List<String>.from(json['completedTopics']),
      inProgressTopics: List<String>.from(json['inProgressTopics']),
      totalTopics: json['totalTopics'],
      completionPercentage: json['completionPercentage'],
      topicMastery: json['topicMastery'] != null
          ? Map<String, double>.from(json['topicMastery'])
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}