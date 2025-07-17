// Educational content models that don't need to be Amplify models
import 'ModelProvider.dart';

class UniversityCourse {
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'instructorName': instructorName,
    'academy': academy,
    'subject': subject,
    'targetExam': targetExam,
    'modules': modules.map((m) => m.toJson()).toList(),
    'totalDuration': totalDuration,
    'difficulty': difficulty,
    'targetGrade': targetGrade,
    'reviews': reviews.map((r) => r.toJson()).toList(),
    'rating': rating,
    'enrollmentCount': enrollmentCount,
  };
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'order': order,
    'estimatedHours': estimatedHours,
    'topics': topics,
    'materials': materials,
  };
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'isbn': isbn,
    'title': title,
    'publisher': publisher,
    'authors': authors,
    'subject': subject,
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'totalPages': totalPages,
    'targetExam': targetExam,
    'difficulty': difficulty,
    'keywords': keywords,
  };
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

  Map<String, dynamic> toJson() => {
    'number': number,
    'title': title,
    'startPage': startPage,
    'endPage': endPage,
    'sections': sections.map((s) => s.toJson()).toList(),
    'keywords': keywords,
  };
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'startPage': startPage,
    'endPage': endPage,
  };
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

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'contentType': contentType,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'subject': subject,
    'course': course,
    'extractedText': extractedText,
    'metadata': metadata,
    'uploadedAt': uploadedAt.toIso8601String(),
    'isProcessed': isProcessed,
  };
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