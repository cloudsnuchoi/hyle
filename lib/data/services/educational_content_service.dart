import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'curriculum_service.dart';
import '../../models/educational_content_models.dart';
import '../../models/ModelProvider.dart';

/// Service for managing educational content from various sources
class EducationalContentService {
  static final EducationalContentService _instance = EducationalContentService._internal();
  factory EducationalContentService() => _instance;
  EducationalContentService._internal();

  final CurriculumService _curriculumService = CurriculumService();

  // Cache for content data
  final Map<String, UniversityCourse> _universityCourseCache = {};
  final Map<String, InstructorCurriculum> _instructorCache = {};
  final Map<String, Textbook> _textbookCache = {};
  final Map<String, UserUploadedContent> _userContentCache = {};

  /// Initialize service
  Future<void> initialize() async {
    try {
      // Load popular instructor curricula
      await _loadPopularInstructors();
      
      // Load common textbooks
      await _loadCommonTextbooks();
      
      safePrint('Educational content service initialized');
    } catch (e) {
      safePrint('Error initializing educational content service: $e');
    }
  }

  /// Add university course syllabus
  Future<UniversityCourse> addUniversityCourse({
    required String universityName,
    required String courseCode,
    required String courseName,
    required String professor,
    required int year,
    required String semester,
    required List<WeeklyPlan> weeklyPlans,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final course = UniversityCourse(
        id: '${universityName}_${courseCode}_${year}_$semester'.toLowerCase(),
        universityName: universityName,
        courseCode: courseCode,
        courseName: courseName,
        professor: professor,
        year: year,
        semester: semester,
        weeklyPlans: weeklyPlans,
        assessmentStructure: additionalInfo?['assessmentStructure'],
        prerequisites: additionalInfo?['prerequisites'] ?? [],
        textbooks: additionalInfo?['textbooks'] ?? [],
        totalCredits: additionalInfo?['credits'] ?? 3,
      );

      // Store in cache
      _universityCourseCache[course.id] = course;

      // Store in database
      await _storeUniversityCourse(course);

      // Extract and map topics to standard curriculum
      await _mapCourseToStandardCurriculum(course);

      return course;
    } catch (e) {
      safePrint('Error adding university course: $e');
      rethrow;
    }
  }

  /// Add instructor curriculum (for 학원 강사)
  Future<InstructorCurriculum> addInstructorCurriculum({
    required String instructorName,
    required String academy, // 학원명
    required String subject,
    required String targetExam, // 수능, 내신, etc.
    required List<CourseModule> modules,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final curriculum = InstructorCurriculum(
        id: '${academy}_${instructorName}_$subject'.toLowerCase().replaceAll(' ', '_'),
        instructorName: instructorName,
        academy: academy,
        subject: subject,
        targetExam: targetExam,
        modules: modules,
        totalDuration: modules.fold(0, (sum, m) => sum + m.estimatedHours),
        difficulty: metadata['difficulty'] ?? 'intermediate',
        targetGrade: metadata['targetGrade'],
        reviews: [],
        rating: 0.0,
        enrollmentCount: 0,
      );

      // Store in cache
      _instructorCache[curriculum.id] = curriculum;

      // Store in database
      await _storeInstructorCurriculum(curriculum);

      // Map to standard curriculum for AI analysis
      await _mapInstructorCurriculumToStandard(curriculum);

      return curriculum;
    } catch (e) {
      safePrint('Error adding instructor curriculum: $e');
      rethrow;
    }
  }

  /// Add textbook/workbook information
  Future<Textbook> addTextbook({
    required String isbn,
    required String title,
    required String publisher,
    required List<String> authors,
    required String subject,
    required List<Chapter> chapters,
    String? targetExam,
    String? difficulty,
  }) async {
    try {
      final textbook = Textbook(
        id: isbn,
        isbn: isbn,
        title: title,
        publisher: publisher,
        authors: authors,
        subject: subject,
        chapters: chapters,
        totalPages: chapters.fold(0, (sum, c) => sum + (c.endPage - c.startPage + 1)),
        targetExam: targetExam,
        difficulty: difficulty ?? 'intermediate',
        keywords: _extractTextbookKeywords(chapters),
      );

      // Store in cache
      _textbookCache[isbn] = textbook;

      // Store in database
      await _storeTextbook(textbook);

      // Create embeddings for semantic search
      await _createTextbookEmbeddings(textbook);

      return textbook;
    } catch (e) {
      safePrint('Error adding textbook: $e');
      rethrow;
    }
  }

  /// Upload user's custom study material
  Future<UserUploadedContent> uploadUserContent({
    required String userId,
    required String title,
    required String contentType, // 'syllabus', 'notes', 'schedule', etc.
    required Uint8List fileData,
    required String fileName,
    String? subject,
    String? course,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final contentId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Upload file to S3
      final fileKey = await _uploadFileToS3(contentId, fileName, fileData);

      // Extract text content if possible
      final extractedText = await _extractTextFromFile(fileData, fileName);

      // Create content record
      final content = UserUploadedContent(
        id: contentId,
        userId: userId,
        title: title,
        contentType: contentType,
        fileUrl: fileKey,
        fileName: fileName,
        subject: subject,
        course: course,
        extractedText: extractedText,
        metadata: metadata ?? {},
        uploadedAt: DateTime.now(),
        isProcessed: false,
      );

      // Store in cache
      _userContentCache[contentId] = content;

      // Store in database
      await _storeUserContent(content);

      // Process content asynchronously
      _processUserContent(content);

      return content;
    } catch (e) {
      safePrint('Error uploading user content: $e');
      rethrow;
    }
  }

  /// Get recommended study path combining all sources
  Future<IntegratedStudyPath> getIntegratedStudyPath({
    required String userId,
    required String targetExam,
    required List<String> subjects,
    required DateTime targetDate,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      // Get user's uploaded materials
      final userContent = await _getUserContent(userId);

      // Get standard curriculum
      final standardCurriculum = await _curriculumService.getCurriculum(
        _mapExamToCurriculumType(targetExam),
      );

      // Find relevant instructor curricula
      final instructorCurricula = await _findRelevantInstructorCurricula(
        targetExam,
        subjects,
        preferences,
      );

      // Find recommended textbooks
      final textbooks = await _findRecommendedTextbooks(
        subjects,
        targetExam,
        preferences?['difficulty'],
      );

      // Generate integrated path
      final path = await _generateIntegratedPath(
        userId: userId,
        targetDate: targetDate,
        standardCurriculum: standardCurriculum,
        instructorCurricula: instructorCurricula,
        textbooks: textbooks,
        userContent: userContent,
        preferences: preferences,
      );

      return path;
    } catch (e) {
      safePrint('Error getting integrated study path: $e');
      rethrow;
    }
  }

  /// Search across all educational content
  Future<ContentSearchResults> searchContent({
    required String query,
    List<String>? contentTypes,
    String? subject,
    String? targetExam,
    int limit = 20,
  }) async {
    try {
      // Search in multiple sources
      final results = await Future.wait([
        _searchUniversityCourses(query, subject),
        _searchInstructorCurricula(query, subject, targetExam),
        _searchTextbooks(query, subject),
        _searchUserContent(query, contentTypes),
      ]);

      // Combine and rank results
      final combined = ContentSearchResults(
        universityCourses: results[0] as List<UniversityCourse>,
        instructorCurricula: results[1] as List<InstructorCurriculum>,
        textbooks: results[2] as List<Textbook>,
        userContent: results[3] as List<UserUploadedContent>,
      );

      return combined;
    } catch (e) {
      safePrint('Error searching content: $e');
      rethrow;
    }
  }

  /// Get popular instructor rankings
  Future<List<InstructorRanking>> getInstructorRankings({
    required String subject,
    required String targetExam,
  }) async {
    try {
      final response = await Amplify.API.get(
        '/instructors/rankings',
        apiName: 'educationalContentAPI',
        queryParameters: {
          'subject': subject,
          'targetExam': targetExam,
        },
      ).response;

      if (response.body != null) {
        final data = json.decode(response.body) as List;
        return data.map((item) => InstructorRanking.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      safePrint('Error getting instructor rankings: $e');
      return [];
    }
  }

  // Private helper methods

  Future<void> _loadPopularInstructors() async {
    // Load popular Korean 학원 instructors
    final megastudyMath = InstructorCurriculum(
      id: 'megastudy_hyunwoojin_math',
      instructorName: '현우진',
      academy: '메가스터디',
      subject: '수학',
      targetExam: '수능',
      modules: [
        CourseModule(
          id: 'module1',
          name: '뉴런 - 시발점',
          description: '수학 기본 개념',
          order: 1,
          estimatedHours: 40,
          topics: ['함수', '수열', '극한'],
          materials: ['뉴런 시발점 교재'],
        ),
        CourseModule(
          id: 'module2',
          name: '뉴런 - 수분감',
          description: '수능 문제 적용',
          order: 2,
          estimatedHours: 60,
          topics: ['미적분', '확률과통계'],
          materials: ['뉴런 수분감 교재'],
        ),
        CourseModule(
          id: 'module3',
          name: '킬링캠프',
          description: '킬러문항 대비',
          order: 3,
          estimatedHours: 30,
          topics: ['고난도 문제'],
          materials: ['킬링캠프 교재'],
        ),
      ],
      totalDuration: 130,
      difficulty: 'advanced',
      targetGrade: '1등급',
      reviews: [],
      rating: 4.8,
      enrollmentCount: 50000,
    );

    _instructorCache[megastudyMath.id] = megastudyMath;

    // Add more popular instructors...
  }

  Future<void> _loadCommonTextbooks() async {
    // Load common Korean textbooks
    final suneungTekst = Textbook(
      id: '9791162241356',
      isbn: '9791162241356',
      title: '수능특강 수학영역 수학Ⅰ',
      publisher: 'EBS',
      authors: ['EBS'],
      subject: '수학',
      chapters: [
        Chapter(
          number: 1,
          title: '지수함수와 로그함수',
          startPage: 8,
          endPage: 45,
          sections: [
            Section(title: '지수', startPage: 8, endPage: 20),
            Section(title: '로그', startPage: 21, endPage: 33),
            Section(title: '지수함수와 로그함수', startPage: 34, endPage: 45),
          ],
          keywords: ['지수', '로그', '함수'],
        ),
        Chapter(
          number: 2,
          title: '삼각함수',
          startPage: 46,
          endPage: 89,
          sections: [
            Section(title: '삼각함수의 정의', startPage: 46, endPage: 60),
            Section(title: '삼각함수의 그래프', startPage: 61, endPage: 75),
            Section(title: '삼각함수의 활용', startPage: 76, endPage: 89),
          ],
          keywords: ['삼각함수', '주기', '그래프'],
        ),
        // More chapters...
      ],
      totalPages: 240,
      targetExam: '수능',
      difficulty: 'intermediate',
      keywords: ['수능', 'EBS', '수학1'],
    );

    _textbookCache[suneungTekst.isbn] = suneungTekst;
  }

  Future<void> _storeUniversityCourse(UniversityCourse course) async {
    try {
      await Amplify.API.post(
        '/university-courses',
        apiName: 'educationalContentAPI',
        body: HttpPayload.json(course.toJson()),
      ).response;
    } catch (e) {
      safePrint('Error storing university course: $e');
    }
  }

  Future<void> _mapCourseToStandardCurriculum(UniversityCourse course) async {
    // Extract topics from weekly plans
    final topics = <String>[];
    for (final week in course.weeklyPlans) {
      topics.addAll(week.topics);
    }

    // Map to standard curriculum
    for (final topic in topics) {
      await _curriculumService.mapActivityToCurriculum(
        activityDescription: topic,
        subject: _mapCourseToSubject(course.courseCode),
      );
    }
  }

  String _mapCourseToSubject(String courseCode) {
    // Map university course codes to subjects
    if (courseCode.startsWith('MATH')) return 'mathematics';
    if (courseCode.startsWith('PHYS')) return 'physics';
    if (courseCode.startsWith('CHEM')) return 'chemistry';
    if (courseCode.startsWith('CS')) return 'computer_science';
    return 'general';
  }

  CurriculumType _mapExamToCurriculumType(String exam) {
    switch (exam.toLowerCase()) {
      case '수능':
      case 'ksat':
        return CurriculumType.korean_sat;
      case 'ap':
        return CurriculumType.ap;
      case 'sat':
        return CurriculumType.sat;
      case 'ib':
        return CurriculumType.ib;
      default:
        return CurriculumType.custom;
    }
  }

  Future<String> _uploadFileToS3(String contentId, String fileName, Uint8List data) async {
    final key = 'user-content/$contentId/$fileName';
    
    final result = await Amplify.Storage.uploadData(
      key: key,
      data: StorageDataPayload.bytes(data),
      options: const StorageUploadDataOptions(
        metadata: {'contentType': 'application/octet-stream'},
      ),
    ).result;

    return result.path;
  }

  Future<String?> _extractTextFromFile(Uint8List data, String fileName) async {
    // In production, use OCR or PDF extraction
    // For now, return null
    return null;
  }

  Future<void> _processUserContent(UserUploadedContent content) async {
    try {
      // Extract structured information
      if (content.contentType == 'syllabus' && content.extractedText != null) {
        // Parse syllabus structure
        final parsed = await _parseSyllabus(content.extractedText!);
        
        // Update content with parsed data
        content.metadata['parsed'] = parsed;
        content.isProcessed = true;
        
        // Create embeddings
        await _createContentEmbeddings(content);
      }
    } catch (e) {
      safePrint('Error processing user content: $e');
    }
  }

  Future<Map<String, dynamic>> _parseSyllabus(String text) async {
    // Use AI to parse syllabus structure
    // For now, return basic structure
    return {
      'weeks': [],
      'assessments': [],
      'topics': [],
    };
  }

  List<String> _extractTextbookKeywords(List<Chapter> chapters) {
    final keywords = <String>{};
    
    for (final chapter in chapters) {
      keywords.addAll(chapter.keywords);
      for (final section in chapter.sections) {
        keywords.add(section.title.toLowerCase());
      }
    }
    
    return keywords.toList();
  }

  Future<IntegratedStudyPath> _generateIntegratedPath({
    required String userId,
    required DateTime targetDate,
    required Curriculum? standardCurriculum,
    required List<InstructorCurriculum> instructorCurricula,
    required List<Textbook> textbooks,
    required List<UserUploadedContent> userContent,
    Map<String, dynamic>? preferences,
  }) async {
    // Complex path generation logic
    // This would use AI to create optimal path combining all sources
    
    return IntegratedStudyPath(
      userId: userId,
      targetDate: targetDate,
      phases: [],
      resources: StudyResources(
        standardCurriculum: standardCurriculum,
        instructorCurricula: instructorCurricula,
        textbooks: textbooks,
        userMaterials: userContent,
      ),
      estimatedCompletionRate: 0.85,
    );
  }

  // Missing private helper methods

  Future<void> _storeInstructorCurriculum(InstructorCurriculum curriculum) async {
    try {
      await Amplify.API.post(
        '/instructor-curricula',
        apiName: 'educationalContentAPI',
        body: HttpPayload.json(curriculum.toJson()),
      ).response;
    } catch (e) {
      safePrint('Error storing instructor curriculum: $e');
    }
  }

  Future<void> _mapInstructorCurriculumToStandard(InstructorCurriculum curriculum) async {
    // Map instructor curriculum to standard curriculum
    for (final module in curriculum.modules) {
      for (final topic in module.topics) {
        await _curriculumService.mapActivityToCurriculum(
          activityDescription: topic,
          subject: curriculum.subject.toLowerCase(),
        );
      }
    }
  }

  Future<void> _storeTextbook(Textbook textbook) async {
    try {
      await Amplify.API.post(
        '/textbooks',
        apiName: 'educationalContentAPI',
        body: HttpPayload.json(textbook.toJson()),
      ).response;
    } catch (e) {
      safePrint('Error storing textbook: $e');
    }
  }

  Future<void> _createTextbookEmbeddings(Textbook textbook) async {
    // Create embeddings for textbook content
    try {
      // Would use Amazon Titan for embeddings
      safePrint('Creating embeddings for textbook: ${textbook.title}');
    } catch (e) {
      safePrint('Error creating textbook embeddings: $e');
    }
  }

  Future<void> _storeUserContent(UserUploadedContent content) async {
    try {
      await Amplify.API.post(
        '/user-content',
        apiName: 'educationalContentAPI',
        body: HttpPayload.json(content.toJson()),
      ).response;
    } catch (e) {
      safePrint('Error storing user content: $e');
    }
  }

  Future<void> _createContentEmbeddings(UserUploadedContent content) async {
    // Create embeddings for user content
    try {
      safePrint('Creating embeddings for content: ${content.title}');
    } catch (e) {
      safePrint('Error creating content embeddings: $e');
    }
  }

  Future<List<UniversityCourse>> _searchUniversityCourses(String query, String? subject) async {
    // Search university courses
    return _universityCourseCache.values
        .where((course) => 
            course.courseName.toLowerCase().contains(query.toLowerCase()) ||
            (subject != null && course.courseCode.toLowerCase().contains(subject.toLowerCase())))
        .toList();
  }

  Future<List<InstructorCurriculum>> _searchInstructorCurricula(
    String query,
    String? subject,
    String? targetExam,
  ) async {
    // Search instructor curricula
    return _instructorCache.values
        .where((curriculum) =>
            curriculum.instructorName.toLowerCase().contains(query.toLowerCase()) ||
            curriculum.academy.toLowerCase().contains(query.toLowerCase()) ||
            (subject != null && curriculum.subject.toLowerCase() == subject.toLowerCase()) ||
            (targetExam != null && curriculum.targetExam.toLowerCase() == targetExam.toLowerCase()))
        .toList();
  }

  Future<List<Textbook>> _searchTextbooks(String query, String? subject) async {
    // Search textbooks
    return _textbookCache.values
        .where((textbook) =>
            textbook.title.toLowerCase().contains(query.toLowerCase()) ||
            textbook.keywords.any((k) => k.toLowerCase().contains(query.toLowerCase())) ||
            (subject != null && textbook.subject.toLowerCase() == subject.toLowerCase()))
        .toList();
  }

  Future<List<UserUploadedContent>> _searchUserContent(String query, List<String>? contentTypes) async {
    // Search user content
    return _userContentCache.values
        .where((content) =>
            content.title.toLowerCase().contains(query.toLowerCase()) ||
            (contentTypes != null && contentTypes.contains(content.contentType)))
        .toList();
  }
}

// Data models moved to educational_content_models.dart
/* class UniversityCourse {
  final String id;
  final String universityName;
  final String courseCode;
  final String courseName;
  final String professor;
  final int year;
  final String semester;
  final List<WeeklyPlan> weeklyPlans;
  final Map<String, double>? assessmentStructure;
  final List<String> prerequisites;
  final List<String> textbooks;
  final int totalCredits;

  UniversityCourse({
    required this.id,
    required this.universityName,
    required this.courseCode,
    required this.courseName,
    required this.professor,
    required this.year,
    required this.semester,
    required this.weeklyPlans,
    this.assessmentStructure,
    required this.prerequisites,
    required this.textbooks,
    required this.totalCredits,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'universityName': universityName,
    'courseCode': courseCode,
    'courseName': courseName,
    'professor': professor,
    'year': year,
    'semester': semester,
    'weeklyPlans': weeklyPlans.map((w) => w.toJson()).toList(),
    'assessmentStructure': assessmentStructure,
    'prerequisites': prerequisites,
    'textbooks': textbooks,
    'totalCredits': totalCredits,
  };
}

class WeeklyPlan {
  final int week;
  final String title;
  final List<String> topics;
  final List<String> readings;
  final List<String> assignments;

  WeeklyPlan({
    required this.week,
    required this.title,
    required this.topics,
    required this.readings,
    required this.assignments,
  });

  Map<String, dynamic> toJson() => {
    'week': week,
    'title': title,
    'topics': topics,
    'readings': readings,
    'assignments': assignments,
  };
}

class InstructorCurriculum {
  final String id;
  final String instructorName;
  final String academy;
  final String subject;
  final String targetExam;
  final List<CourseModule> modules;
  final int totalDuration; // hours
  final String difficulty;
  final String? targetGrade;
  final List<Review> reviews;
  final double rating;
  final int enrollmentCount;

  InstructorCurriculum({
    required this.id,
    required this.instructorName,
    required this.academy,
    required this.subject,
    required this.targetExam,
    required this.modules,
    required this.totalDuration,
    required this.difficulty,
    this.targetGrade,
    required this.reviews,
    required this.rating,
    required this.enrollmentCount,
  });
}

class CourseModule {
  final String id;
  final String name;
  final String description;
  final int order;
  final int estimatedHours;
  final List<String> topics;
  final List<String> materials;

  CourseModule({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.estimatedHours,
    required this.topics,
    required this.materials,
  });
}

class Textbook {
  final String id;
  final String isbn;
  final String title;
  final String publisher;
  final List<String> authors;
  final String subject;
  final List<Chapter> chapters;
  final int totalPages;
  final String? targetExam;
  final String difficulty;
  final List<String> keywords;

  Textbook({
    required this.id,
    required this.isbn,
    required this.title,
    required this.publisher,
    required this.authors,
    required this.subject,
    required this.chapters,
    required this.totalPages,
    this.targetExam,
    required this.difficulty,
    required this.keywords,
  });
}

class Chapter {
  final int number;
  final String title;
  final int startPage;
  final int endPage;
  final List<Section> sections;
  final List<String> keywords;

  Chapter({
    required this.number,
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.sections,
    required this.keywords,
  });
}

class Section {
  final String title;
  final int startPage;
  final int endPage;

  Section({
    required this.title,
    required this.startPage,
    required this.endPage,
  });
}

class UserUploadedContent {
  final String id;
  final String userId;
  final String title;
  final String contentType;
  final String fileUrl;
  final String fileName;
  final String? subject;
  final String? course;
  final String? extractedText;
  final Map<String, dynamic> metadata;
  final DateTime uploadedAt;
  bool isProcessed;

  UserUploadedContent({
    required this.id,
    required this.userId,
    required this.title,
    required this.contentType,
    required this.fileUrl,
    required this.fileName,
    this.subject,
    this.course,
    this.extractedText,
    required this.metadata,
    required this.uploadedAt,
    required this.isProcessed,
  });
}

class ContentSearchResults {
  final List<UniversityCourse> universityCourses;
  final List<InstructorCurriculum> instructorCurricula;
  final List<Textbook> textbooks;
  final List<UserUploadedContent> userContent;

  ContentSearchResults({
    required this.universityCourses,
    required this.instructorCurricula,
    required this.textbooks,
    required this.userContent,
  });
}

class InstructorRanking {
  final String instructorName;
  final String academy;
  final String subject;
  final double rating;
  final int reviewCount;
  final int enrollmentCount;
  final List<String> specialties;

  InstructorRanking({
    required this.instructorName,
    required this.academy,
    required this.subject,
    required this.rating,
    required this.reviewCount,
    required this.enrollmentCount,
    required this.specialties,
  });

  factory InstructorRanking.fromJson(Map<String, dynamic> json) {
    return InstructorRanking(
      instructorName: json['instructorName'],
      academy: json['academy'],
      subject: json['subject'],
      rating: json['rating'],
      reviewCount: json['reviewCount'],
      enrollmentCount: json['enrollmentCount'],
      specialties: List<String>.from(json['specialties']),
    );
  }
}

class IntegratedStudyPath {
  final String userId;
  final DateTime targetDate;
  final List<StudyPhase> phases;
  final StudyResources resources;
  final double estimatedCompletionRate;

  IntegratedStudyPath({
    required this.userId,
    required this.targetDate,
    required this.phases,
    required this.resources,
    required this.estimatedCompletionRate,
  });
}

class StudyPhase {
  final String name;
  final int durationDays;
  final List<String> focusTopics;
  final List<ResourceAllocation> resourceAllocations;

  StudyPhase({
    required this.name,
    required this.durationDays,
    required this.focusTopics,
    required this.resourceAllocations,
  });
}

class ResourceAllocation {
  final String resourceId;
  final String resourceType;
  final int allocatedHours;
  final List<String> chapters;

  ResourceAllocation({
    required this.resourceId,
    required this.resourceType,
    required this.allocatedHours,
    required this.chapters,
  });
}

class StudyResources {
  final Curriculum? standardCurriculum;
  final List<InstructorCurriculum> instructorCurricula;
  final List<Textbook> textbooks;
  final List<UserUploadedContent> userMaterials;

  StudyResources({
    this.standardCurriculum,
    required this.instructorCurricula,
    required this.textbooks,
    required this.userMaterials,
  });
}

class Review {
  final String userId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
} */