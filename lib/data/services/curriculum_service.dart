import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../../models/curriculum_models.dart';
import '../../models/ModelProvider.dart';

/// Service for managing educational curriculum data
class CurriculumService {
  static final CurriculumService _instance = CurriculumService._internal();
  factory CurriculumService() => _instance;
  CurriculumService._internal();

  // Cache for curriculum data
  final Map<String, Curriculum> _curriculumCache = {};
  final Map<String, Subject> _subjectCache = {};
  final Map<String, List<Topic>> _topicCache = {};
  final Map<String, List<LearningStandard>> _standardsCache = {};

  /// Initialize curriculum service with standard curricula
  Future<void> initialize() async {
    try {
      // Load standard curricula
      await _loadStandardCurricula();
      
      // Load subjects and topics
      await _loadSubjectsAndTopics();
      
      // Load learning standards
      await _loadLearningStandards();
      
      safePrint('Curriculum service initialized');
    } catch (e) {
      safePrint('Error initializing curriculum service: $e');
    }
  }

  /// Get curriculum by type
  Curriculum? getCurriculum(CurriculumType type) {
    return _curriculumCache[type.name];
  }

  /// Get subject details
  Subject? getSubject(String subjectId) {
    return _subjectCache[subjectId];
  }

  /// Get topics for a subject
  List<Topic> getTopicsForSubject(String subjectId) {
    return _topicCache[subjectId] ?? [];
  }

  /// Get topic by path (e.g., "math.algebra.linear_equations")
  Topic? getTopicByPath(String path) {
    final parts = path.split('.');
    if (parts.length < 3) return null;
    
    final subjectId = parts[0];
    final topics = getTopicsForSubject(subjectId);
    
    return topics.firstWhere(
      (t) => t.id == path,
      orElse: () => Topic(
        id: path,
        name: parts.last.replaceAll('_', ' ').capitalize(),
        subjectId: subjectId,
        unitId: parts[1],
        order: 0,
        estimatedHours: 5,
        keywords: [],
        prerequisites: [],
        learningObjectives: [],
      ),
    );
  }

  /// Find topics by keywords
  List<Topic> findTopicsByKeywords(List<String> keywords) {
    final results = <Topic>[];
    
    for (final topics in _topicCache.values) {
      for (final topic in topics) {
        final matchCount = keywords.where((keyword) =>
          topic.keywords.any((k) => k.toLowerCase().contains(keyword.toLowerCase()))
        ).length;
        
        if (matchCount > 0) {
          results.add(topic);
        }
      }
    }
    
    // Sort by relevance
    results.sort((a, b) {
      final aMatch = keywords.where((k) => 
        a.keywords.any((ak) => ak.toLowerCase().contains(k.toLowerCase()))
      ).length;
      final bMatch = keywords.where((k) => 
        b.keywords.any((bk) => bk.toLowerCase().contains(k.toLowerCase()))
      ).length;
      return bMatch.compareTo(aMatch);
    });
    
    return results;
  }

  /// Get learning standards for curriculum and grade
  List<LearningStandard> getLearningStandards({
    required CurriculumType curriculum,
    required String subject,
    int? grade,
  }) {
    final key = '${curriculum.name}_$subject${grade != null ? '_$grade' : ''}';
    return _standardsCache[key] ?? [];
  }

  /// Get exam syllabus
  Future<ExamSyllabus?> getExamSyllabus(String examType, String subject) async {
    try {
      final response = await Amplify.API.get(
        '/syllabus/$examType/$subject',
        apiName: 'curriculumAPI',
      ).response;

      if (response.body != null) {
        final data = json.decode(response.body);
        return ExamSyllabus.fromJson(data);
      }
      return null;
    } catch (e) {
      safePrint('Error getting exam syllabus: $e');
      return null;
    }
  }

  /// Get assessment criteria
  Future<List<AssessmentCriteria>> getAssessmentCriteria({
    required String examType,
    required String subject,
    required String topicId,
  }) async {
    try {
      final response = await Amplify.API.get(
        '/criteria/$examType/$subject/$topicId',
        apiName: 'curriculumAPI',
      ).response;

      if (response.body != null) {
        final data = json.decode(response.body) as List;
        return data.map((item) => AssessmentCriteria.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      safePrint('Error getting assessment criteria: $e');
      return [];
    }
  }

  /// Map user activity to curriculum standards
  Future<CurriculumMapping> mapActivityToCurriculum({
    required String activityDescription,
    required String subject,
    CurriculumType? preferredCurriculum,
  }) async {
    try {
      // Extract keywords from activity
      final keywords = _extractKeywords(activityDescription);
      
      // Find matching topics
      final matchingTopics = findTopicsByKeywords(keywords);
      
      // Filter by subject if specified
      final subjectTopics = subject.isNotEmpty
          ? matchingTopics.where((t) => t.subjectId == subject).toList()
          : matchingTopics;
      
      if (subjectTopics.isEmpty) {
        return CurriculumMapping(
          activityDescription: activityDescription,
          mappedTopics: [],
          confidence: 0.0,
        );
      }
      
      // Calculate confidence based on keyword matches
      final topTopic = subjectTopics.first;
      final confidence = _calculateMappingConfidence(keywords, topTopic);
      
      // Get learning standards
      final standards = preferredCurriculum != null
          ? getLearningStandards(
              curriculum: preferredCurriculum,
              subject: subject,
            )
          : [];
      
      // Find matching standards
      final matchingStandards = standards.where((s) =>
        s.topics.contains(topTopic.id)
      ).toList();
      
      return CurriculumMapping(
        activityDescription: activityDescription,
        mappedTopics: subjectTopics.take(3).toList(),
        mappedStandards: matchingStandards,
        confidence: confidence,
        suggestedKeywords: topTopic.keywords,
      );
    } catch (e) {
      safePrint('Error mapping activity to curriculum: $e');
      return CurriculumMapping(
        activityDescription: activityDescription,
        mappedTopics: [],
        confidence: 0.0,
      );
    }
  }

  /// Get curriculum progress for user
  Future<CurriculumProgress> getUserProgress({
    required String userId,
    required CurriculumType curriculum,
    required String subject,
  }) async {
    try {
      final response = await Amplify.API.post(
        '/progress',
        apiName: 'curriculumAPI',
        body: HttpPayload.json({
          'userId': userId,
          'curriculum': curriculum.name,
          'subject': subject,
        }),
      ).response;

      if (response.body != null) {
        final data = json.decode(response.body);
        return CurriculumProgress.fromJson(data);
      }
      
      return CurriculumProgress(
        userId: userId,
        curriculum: curriculum,
        subject: subject,
        completedTopics: [],
        inProgressTopics: [],
        totalTopics: getTopicsForSubject(subject).length,
        completionPercentage: 0.0,
      );
    } catch (e) {
      safePrint('Error getting curriculum progress: $e');
      rethrow;
    }
  }

  /// Load standard curricula
  Future<void> _loadStandardCurricula() async {
    // Korean Curriculum (수능)
    _curriculumCache['korean_sat'] = Curriculum(
      id: 'korean_sat',
      type: CurriculumType.korean_sat,
      name: '대학수학능력시험 (수능)',
      country: 'Korea',
      description: 'Korean College Scholastic Ability Test',
      gradeRange: [10, 12],
      subjects: [
        'korean_language',
        'mathematics',
        'english',
        'korean_history',
        'social_studies',
        'science',
        'second_foreign_language',
      ],
      examFormat: ExamFormat(
        totalDuration: 510, // minutes
        sections: [
          ExamSection(name: '국어', duration: 80, questions: 45),
          ExamSection(name: '수학', duration: 100, questions: 30),
          ExamSection(name: '영어', duration: 70, questions: 45),
          ExamSection(name: '한국사', duration: 30, questions: 20),
          ExamSection(name: '탐구', duration: 120, questions: 40),
        ],
      ),
    );

    // AP Curriculum
    _curriculumCache['ap'] = Curriculum(
      id: 'ap',
      type: CurriculumType.ap,
      name: 'Advanced Placement',
      country: 'USA',
      description: 'College-level courses and exams',
      gradeRange: [9, 12],
      subjects: [
        'ap_calculus_ab',
        'ap_calculus_bc',
        'ap_statistics',
        'ap_physics_1',
        'ap_physics_2',
        'ap_physics_c',
        'ap_chemistry',
        'ap_biology',
        'ap_computer_science_a',
        'ap_english_language',
        'ap_english_literature',
        'ap_us_history',
        'ap_world_history',
        'ap_european_history',
      ],
      examFormat: ExamFormat(
        totalDuration: 180, // minutes per exam
        sections: [
          ExamSection(name: 'Multiple Choice', duration: 90, questions: 45),
          ExamSection(name: 'Free Response', duration: 90, questions: 6),
        ],
      ),
    );

    // SAT Curriculum
    _curriculumCache['sat'] = Curriculum(
      id: 'sat',
      type: CurriculumType.sat,
      name: 'SAT',
      country: 'USA',
      description: 'Standardized test for college admissions',
      gradeRange: [11, 12],
      subjects: [
        'sat_reading',
        'sat_writing',
        'sat_math',
      ],
      examFormat: ExamFormat(
        totalDuration: 180,
        sections: [
          ExamSection(name: 'Reading', duration: 65, questions: 52),
          ExamSection(name: 'Writing and Language', duration: 35, questions: 44),
          ExamSection(name: 'Math (No Calculator)', duration: 25, questions: 20),
          ExamSection(name: 'Math (Calculator)', duration: 55, questions: 38),
        ],
      ),
    );

    // IB Curriculum
    _curriculumCache['ib'] = Curriculum(
      id: 'ib',
      type: CurriculumType.ib,
      name: 'International Baccalaureate',
      country: 'International',
      description: 'International education program',
      gradeRange: [11, 12],
      subjects: [
        'ib_math_aa_hl',
        'ib_math_aa_sl',
        'ib_math_ai_hl',
        'ib_math_ai_sl',
        'ib_physics_hl',
        'ib_physics_sl',
        'ib_chemistry_hl',
        'ib_chemistry_sl',
        'ib_biology_hl',
        'ib_biology_sl',
        'ib_english_a_hl',
        'ib_english_a_sl',
      ],
      examFormat: ExamFormat(
        totalDuration: 0, // Varies by subject
        sections: [], // Subject-specific
      ),
    );

    // A-Level Curriculum
    _curriculumCache['a_level'] = Curriculum(
      id: 'a_level',
      type: CurriculumType.a_level,
      name: 'A-Level',
      country: 'UK',
      description: 'Advanced Level qualifications',
      gradeRange: [11, 12],
      subjects: [
        'a_level_mathematics',
        'a_level_further_mathematics',
        'a_level_physics',
        'a_level_chemistry',
        'a_level_biology',
        'a_level_english_literature',
        'a_level_history',
        'a_level_economics',
      ],
      examFormat: ExamFormat(
        totalDuration: 0, // Varies
        sections: [], // Subject-specific
      ),
    );
  }

  /// Load subjects and topics
  Future<void> _loadSubjectsAndTopics() async {
    // Example: Korean SAT Mathematics
    _subjectCache['mathematics'] = Subject(
      id: 'mathematics',
      name: '수학',
      nameEn: 'Mathematics',
      description: 'High school mathematics',
      curriculumTypes: [CurriculumType.korean_sat, CurriculumType.ap, CurriculumType.sat],
      units: [
        Unit(
          id: 'algebra',
          name: '대수',
          nameEn: 'Algebra',
          order: 1,
          estimatedHours: 40,
        ),
        Unit(
          id: 'geometry',
          name: '기하',
          nameEn: 'Geometry',
          order: 2,
          estimatedHours: 35,
        ),
        Unit(
          id: 'calculus',
          name: '미적분',
          nameEn: 'Calculus',
          order: 3,
          estimatedHours: 50,
        ),
        Unit(
          id: 'probability_statistics',
          name: '확률과 통계',
          nameEn: 'Probability & Statistics',
          order: 4,
          estimatedHours: 30,
        ),
      ],
    );

    // Load topics for mathematics
    _topicCache['mathematics'] = [
      // Algebra topics
      Topic(
        id: 'mathematics.algebra.polynomials',
        name: '다항식',
        nameEn: 'Polynomials',
        subjectId: 'mathematics',
        unitId: 'algebra',
        order: 1,
        estimatedHours: 8,
        keywords: ['polynomial', 'factor', 'root', 'degree', '다항식', '인수분해', '근'],
        prerequisites: [],
        learningObjectives: [
          'Understand polynomial operations',
          'Factor polynomials',
          'Find roots of polynomials',
        ],
        assessmentWeight: 0.15,
      ),
      Topic(
        id: 'mathematics.algebra.equations_inequalities',
        name: '방정식과 부등식',
        nameEn: 'Equations and Inequalities',
        subjectId: 'mathematics',
        unitId: 'algebra',
        order: 2,
        estimatedHours: 10,
        keywords: ['equation', 'inequality', 'solve', '방정식', '부등식', '해'],
        prerequisites: ['mathematics.algebra.polynomials'],
        learningObjectives: [
          'Solve linear and quadratic equations',
          'Solve systems of equations',
          'Solve inequalities',
        ],
        assessmentWeight: 0.20,
      ),
      
      // Calculus topics
      Topic(
        id: 'mathematics.calculus.limits',
        name: '극한',
        nameEn: 'Limits',
        subjectId: 'mathematics',
        unitId: 'calculus',
        order: 1,
        estimatedHours: 8,
        keywords: ['limit', 'continuity', 'asymptote', '극한', '연속', '점근선'],
        prerequisites: ['mathematics.algebra.equations_inequalities'],
        learningObjectives: [
          'Understand the concept of limits',
          'Calculate limits algebraically',
          'Determine continuity',
        ],
        assessmentWeight: 0.10,
      ),
      Topic(
        id: 'mathematics.calculus.derivatives',
        name: '미분',
        nameEn: 'Derivatives',
        subjectId: 'mathematics',
        unitId: 'calculus',
        order: 2,
        estimatedHours: 12,
        keywords: ['derivative', 'differentiation', 'rate of change', '미분', '도함수', '변화율'],
        prerequisites: ['mathematics.calculus.limits'],
        learningObjectives: [
          'Understand the concept of derivatives',
          'Apply differentiation rules',
          'Solve optimization problems',
        ],
        assessmentWeight: 0.25,
      ),
      Topic(
        id: 'mathematics.calculus.integrals',
        name: '적분',
        nameEn: 'Integrals',
        subjectId: 'mathematics',
        unitId: 'calculus',
        order: 3,
        estimatedHours: 12,
        keywords: ['integral', 'integration', 'area', 'volume', '적분', '넓이', '부피'],
        prerequisites: ['mathematics.calculus.derivatives'],
        learningObjectives: [
          'Understand the concept of integrals',
          'Apply integration techniques',
          'Calculate areas and volumes',
        ],
        assessmentWeight: 0.25,
      ),
    ];

    // Load more subjects...
    // English, Physics, Chemistry, etc.
  }

  /// Load learning standards
  Future<void> _loadLearningStandards() async {
    // Korean SAT Mathematics Standards
    _standardsCache['korean_sat_mathematics'] = [
      LearningStandard(
        id: 'ksat_math_1',
        curriculum: CurriculumType.korean_sat,
        subject: 'mathematics',
        grade: 12,
        code: 'KSAT-M-12.1',
        description: '다항식의 연산과 인수분해를 할 수 있다',
        topics: ['mathematics.algebra.polynomials'],
        blooms: BloomsTaxonomy.applying,
        weight: 0.15,
      ),
      LearningStandard(
        id: 'ksat_math_2',
        curriculum: CurriculumType.korean_sat,
        subject: 'mathematics',
        grade: 12,
        code: 'KSAT-M-12.2',
        description: '함수의 극한과 연속성을 이해하고 계산할 수 있다',
        topics: ['mathematics.calculus.limits'],
        blooms: BloomsTaxonomy.understanding,
        weight: 0.10,
      ),
      LearningStandard(
        id: 'ksat_math_3',
        curriculum: CurriculumType.korean_sat,
        subject: 'mathematics',
        grade: 12,
        code: 'KSAT-M-12.3',
        description: '도함수를 활용하여 함수의 성질을 파악하고 문제를 해결할 수 있다',
        topics: ['mathematics.calculus.derivatives'],
        blooms: BloomsTaxonomy.analyzing,
        weight: 0.25,
      ),
    ];

    // AP Calculus Standards
    _standardsCache['ap_calculus'] = [
      LearningStandard(
        id: 'ap_calc_1',
        curriculum: CurriculumType.ap,
        subject: 'ap_calculus_ab',
        grade: 12,
        code: 'AP-CALC-1.A',
        description: 'Determine limits using algebraic manipulation',
        topics: ['mathematics.calculus.limits'],
        blooms: BloomsTaxonomy.applying,
        weight: 0.10,
      ),
      // More standards...
    ];
  }

  /// Extract keywords from text
  List<String> _extractKeywords(String text) {
    // Simple keyword extraction - in production use NLP
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final keywords = <String>[];
    
    // Common math keywords
    final mathKeywords = [
      'equation', 'solve', 'factor', 'derivative', 'integral', 'limit',
      'function', 'graph', 'polynomial', 'quadratic', 'linear',
      '방정식', '미분', '적분', '극한', '함수', '그래프', '다항식',
    ];
    
    for (final word in words) {
      if (mathKeywords.any((k) => word.contains(k))) {
        keywords.add(word);
      }
    }
    
    return keywords;
  }

  /// Calculate mapping confidence
  double _calculateMappingConfidence(List<String> keywords, Topic topic) {
    if (keywords.isEmpty) return 0.0;
    
    int matches = 0;
    for (final keyword in keywords) {
      if (topic.keywords.any((k) => k.toLowerCase().contains(keyword.toLowerCase()))) {
        matches++;
      }
    }
    
    return matches / keywords.length;
  }
}

// Data models moved to curriculum_models.dart and ModelProvider.dart
/* enum CurriculumType {
  korean_sat, // 수능
  ap,         // Advanced Placement
  sat,        // SAT
  ib,         // International Baccalaureate
  a_level,    // A-Level
  gcse,       // GCSE
  custom,     // Custom curriculum
}

class Curriculum {
  final String id;
  final CurriculumType type;
  final String name;
  final String country;
  final String description;
  final List<int> gradeRange;
  final List<String> subjects;
  final ExamFormat examFormat;

  Curriculum({
    required this.id,
    required this.type,
    required this.name,
    required this.country,
    required this.description,
    required this.gradeRange,
    required this.subjects,
    required this.examFormat,
  });
}

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
} */