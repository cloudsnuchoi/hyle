import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'ontology_service.dart';
import 'curriculum_service.dart';
import 'data_fusion_service.dart';
import '../../models/educational_content_models.dart';
import '../../models/ModelProvider.dart';

/// Service for managing personalized learning profiles and AI interactions
class PersonalizedLearningService {
  static final PersonalizedLearningService _instance = PersonalizedLearningService._internal();
  factory PersonalizedLearningService() => _instance;
  PersonalizedLearningService._internal();

  final AIService _aiService = AIService();
  final OntologyService _ontologyService = OntologyService();
  final DataFusionService _dataFusionService = DataFusionService();

  // User's personalized learning profiles
  final Map<String, PersonalizedLearningProfile> _userProfiles = {};
  
  // AI conversation memory
  final Map<String, List<AIConversation>> _conversationHistory = {};

  /// Initialize or get user's personalized profile
  Future<PersonalizedLearningProfile> getOrCreateProfile(String userId) async {
    if (_userProfiles.containsKey(userId)) {
      return _userProfiles[userId]!;
    }

    try {
      // Try to load from storage
      final profile = await _loadProfileFromStorage(userId);
      if (profile != null) {
        _userProfiles[userId] = profile;
        return profile;
      }

      // Create new profile
      final newProfile = PersonalizedLearningProfile(
        userId: userId,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        learningGoals: [],
        examPreparations: [],
        customCurricula: [],
        studyPreferences: StudyPreferences.defaultPreferences(),
        knowledgeMap: {},
        conversationInsights: [],
      );

      _userProfiles[userId] = newProfile;
      await _saveProfile(newProfile);
      
      return newProfile;
    } catch (e) {
      safePrint('Error getting/creating profile: $e');
      rethrow;
    }
  }

  /// Process AI tutor conversation to update profile
  Future<ProfileUpdateResult> processAIConversation({
    required String userId,
    required String userMessage,
    required String aiResponse,
    ConversationType type = ConversationType.general,
  }) async {
    try {
      final profile = await getOrCreateProfile(userId);
      
      // Store conversation
      final conversation = AIConversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userMessage: userMessage,
        aiResponse: aiResponse,
        type: type,
        timestamp: DateTime.now(),
        extractedInfo: {},
      );

      _addConversation(userId, conversation);

      // Extract information based on conversation type
      Map<String, dynamic> extractedInfo = {};
      List<ProfileUpdate> updates = [];

      switch (type) {
        case ConversationType.examSetup:
          extractedInfo = await _extractExamInfo(userMessage, aiResponse);
          if (extractedInfo.isNotEmpty) {
            updates.add(await _updateExamPreparation(profile, extractedInfo));
          }
          break;
          
        case ConversationType.curriculumPlanning:
          extractedInfo = await _extractCurriculumInfo(userMessage, aiResponse);
          if (extractedInfo.isNotEmpty) {
            updates.add(await _updateCustomCurriculum(profile, extractedInfo));
          }
          break;
          
        case ConversationType.progressReview:
          extractedInfo = await _extractProgressInfo(userMessage, aiResponse);
          if (extractedInfo.isNotEmpty) {
            updates.add(await _updateLearningProgress(profile, extractedInfo));
          }
          break;
          
        case ConversationType.studyPlanning:
          extractedInfo = await _extractStudyPlanInfo(userMessage, aiResponse);
          if (extractedInfo.isNotEmpty) {
            updates.add(await _updateStudyPlan(profile, extractedInfo));
          }
          break;
          
        default:
          // General conversation - extract any relevant learning info
          extractedInfo = await _extractGeneralLearningInfo(userMessage, aiResponse);
      }

      // Update conversation with extracted info
      conversation.extractedInfo = extractedInfo;

      // Generate insights from conversation
      final insights = await _generateConversationInsights(
        profile: profile,
        conversation: conversation,
      );

      // Update profile
      profile.conversationInsights.addAll(insights);
      profile.lastUpdated = DateTime.now();
      await _saveProfile(profile);

      // Update knowledge graph
      if (extractedInfo.containsKey('concepts')) {
        await _updateUserKnowledgeGraph(
          userId: userId,
          concepts: extractedInfo['concepts'],
        );
      }

      return ProfileUpdateResult(
        updates: updates,
        insights: insights,
        extractedInfo: extractedInfo,
        suggestedActions: await _generateSuggestedActions(profile, updates),
      );
    } catch (e) {
      safePrint('Error processing AI conversation: $e');
      rethrow;
    }
  }

  /// Add or update exam preparation
  Future<ExamPreparation> addExamPreparation({
    required String userId,
    required String examName,
    required DateTime targetDate,
    Map<String, dynamic>? examDetails,
    bool isCustomExam = false,
  }) async {
    try {
      final profile = await getOrCreateProfile(userId);
      
      final exam = ExamPreparation(
        id: '${examName}_${targetDate.millisecondsSinceEpoch}',
        examName: examName,
        examType: _determineExamType(examName),
        targetDate: targetDate,
        subjects: examDetails?['subjects'] ?? [],
        currentLevel: examDetails?['currentLevel'] ?? 'beginner',
        targetScore: examDetails?['targetScore'],
        studyPlan: null, // Will be generated
        progress: {},
        isCustom: isCustomExam,
        customDetails: isCustomExam ? examDetails : null,
        createdAt: DateTime.now(),
      );

      // Generate initial study plan
      exam.studyPlan = await _generateExamStudyPlan(
        userId: userId,
        exam: exam,
        profile: profile,
      );

      // Add to profile
      profile.examPreparations.add(exam);
      await _saveProfile(profile);

      return exam;
    } catch (e) {
      safePrint('Error adding exam preparation: $e');
      rethrow;
    }
  }

  /// Create custom curriculum
  Future<CustomCurriculum> createCustomCurriculum({
    required String userId,
    required String name,
    required String description,
    required List<CurriculumModule> modules,
    String? baseTemplate, // e.g., "korean_sat", "toeic", etc.
  }) async {
    try {
      final profile = await getOrCreateProfile(userId);
      
      final curriculum = CustomCurriculum(
        id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        baseTemplate: baseTemplate,
        modules: modules,
        totalHours: modules.fold(0, (sum, m) => sum + m.estimatedHours),
        progress: {},
        isActive: true,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Add to profile
      profile.customCurricula.add(curriculum);
      await _saveProfile(profile);

      // Create initial todos based on curriculum
      await _createTodosFromCurriculum(userId, curriculum);

      return curriculum;
    } catch (e) {
      safePrint('Error creating custom curriculum: $e');
      rethrow;
    }
  }

  /// Update curriculum progress
  Future<void> updateCurriculumProgress({
    required String userId,
    required String curriculumId,
    required String moduleId,
    required double progress,
    Map<String, dynamic>? performanceData,
  }) async {
    try {
      final profile = await getOrCreateProfile(userId);
      final curriculum = profile.customCurricula.firstWhere(
        (c) => c.id == curriculumId,
      );

      // Update progress
      curriculum.progress[moduleId] = ModuleProgress(
        moduleId: moduleId,
        completionPercentage: progress,
        lastStudied: DateTime.now(),
        performance: performanceData?['performance'] ?? 0.8,
        timeSpent: performanceData?['timeSpent'] ?? 0,
      );

      curriculum.lastModified = DateTime.now();
      
      // Check if module completed
      if (progress >= 100.0) {
        await _handleModuleCompletion(
          userId: userId,
          curriculum: curriculum,
          moduleId: moduleId,
        );
      }

      await _saveProfile(profile);
    } catch (e) {
      safePrint('Error updating curriculum progress: $e');
      rethrow;
    }
  }

  /// Get AI recommendations based on profile
  Future<PersonalizedRecommendations> getPersonalizedRecommendations({
    required String userId,
    required RecommendationType type,
    Map<String, dynamic>? context,
  }) async {
    try {
      final profile = await getOrCreateProfile(userId);
      final learningContext = await _dataFusionService.createLearningContext(
        userId: userId,
        ref: context?['ref'], // If using Riverpod ref
      );

      switch (type) {
        case RecommendationType.dailyTasks:
          return await _getDailyTaskRecommendations(profile, learningContext);
          
        case RecommendationType.studyMaterials:
          return await _getStudyMaterialRecommendations(profile, context);
          
        case RecommendationType.scheduleOptimization:
          return await _getScheduleOptimizationRecommendations(profile, learningContext);
          
        case RecommendationType.conceptReview:
          return await _getConceptReviewRecommendations(profile, learningContext);
          
        case RecommendationType.examStrategy:
          return await _getExamStrategyRecommendations(profile, context);
      }
    } catch (e) {
      safePrint('Error getting personalized recommendations: $e');
      rethrow;
    }
  }

  /// Update study preferences based on behavior
  Future<void> updateStudyPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
    bool fromAIAnalysis = false,
  }) async {
    try {
      final profile = await getOrCreateProfile(userId);
      
      // Update preferences
      if (preferences.containsKey('preferredStudyTimes')) {
        profile.studyPreferences.preferredStudyTimes = 
            List<String>.from(preferences['preferredStudyTimes']);
      }
      
      if (preferences.containsKey('sessionDuration')) {
        profile.studyPreferences.preferredSessionDuration = 
            preferences['sessionDuration'];
      }
      
      if (preferences.containsKey('breakFrequency')) {
        profile.studyPreferences.breakFrequency = 
            preferences['breakFrequency'];
      }
      
      if (preferences.containsKey('learningStyle')) {
        profile.studyPreferences.learningStyle = 
            preferences['learningStyle'];
      }
      
      if (preferences.containsKey('difficulty')) {
        profile.studyPreferences.difficultyPreference = 
            preferences['difficulty'];
      }

      profile.studyPreferences.lastUpdated = DateTime.now();
      profile.studyPreferences.aiOptimized = fromAIAnalysis;
      
      await _saveProfile(profile);
    } catch (e) {
      safePrint('Error updating study preferences: $e');
      rethrow;
    }
  }

  /// Get learning analytics
  Future<PersonalizedAnalytics> getLearningAnalytics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final profile = await getOrCreateProfile(userId);
      
      // Gather data from multiple sources
      final studyTime = await _calculateTotalStudyTime(userId, startDate, endDate);
      final completionRates = await _calculateCompletionRates(profile, startDate, endDate);
      final conceptMastery = await _calculateConceptMastery(userId);
      final examReadiness = await _calculateExamReadiness(profile);
      final strengths = await _identifyStrengths(profile);
      final weaknesses = await _identifyWeaknesses(profile);
      
      return PersonalizedAnalytics(
        userId: userId,
        period: DateTimeRange(start: startDate, end: endDate),
        totalStudyTime: studyTime,
        completionRates: completionRates,
        conceptMastery: conceptMastery,
        examReadiness: examReadiness,
        strengths: strengths,
        weaknesses: weaknesses,
        insights: await _generateAnalyticsInsights(
          profile: profile,
          studyTime: studyTime,
          completionRates: completionRates,
        ),
      );
    } catch (e) {
      safePrint('Error getting learning analytics: $e');
      rethrow;
    }
  }

  // Private helper methods

  Future<Map<String, dynamic>> _extractExamInfo(String userMessage, String aiResponse) async {
    // Use AI to extract exam information from conversation
    try {
      final prompt = '''
Extract exam preparation information from this conversation:
User: $userMessage
AI: $aiResponse

Extract: exam name, target date, subjects, current level, target score
Return as JSON.
      ''';

      // In production, call AI service
      return {
        'examName': 'extracted_exam_name',
        'targetDate': DateTime.now().add(const Duration(days: 90)),
        'subjects': ['Math', 'English'],
        'currentLevel': 'intermediate',
        'targetScore': '90%',
      };
    } catch (e) {
      return {};
    }
  }

  ExamType _determineExamType(String examName) {
    final lowerName = examName.toLowerCase();
    
    if (lowerName.contains('수능') || lowerName.contains('ksat')) {
      return ExamType.koreanSAT;
    } else if (lowerName.contains('toeic')) {
      return ExamType.toeic;
    } else if (lowerName.contains('toefl')) {
      return ExamType.toefl;
    } else if (lowerName.contains('공무원')) {
      return ExamType.civilService;
    } else if (lowerName.contains('sat')) {
      return ExamType.sat;
    } else {
      return ExamType.custom;
    }
  }

  Future<StudyPlan> _generateExamStudyPlan({
    required String userId,
    required ExamPreparation exam,
    required PersonalizedLearningProfile profile,
  }) async {
    // Generate personalized study plan based on exam and profile
    final daysUntilExam = exam.targetDate.difference(DateTime.now()).inDays;
    
    return StudyPlan(
      examId: exam.id,
      phases: [
        StudyPhase(
          name: 'Foundation',
          duration: (daysUntilExam * 0.3).round(),
          goals: ['Build core concepts', 'Identify weak areas'],
          modules: [],
        ),
        StudyPhase(
          name: 'Intensive Practice',
          duration: (daysUntilExam * 0.5).round(),
          goals: ['Practice problems', 'Improve speed'],
          modules: [],
        ),
        StudyPhase(
          name: 'Final Review',
          duration: (daysUntilExam * 0.2).round(),
          goals: ['Mock exams', 'Review mistakes'],
          modules: [],
        ),
      ],
      dailySchedule: _generateDailySchedule(profile.studyPreferences),
      milestones: [],
    );
  }

  Map<String, List<TimeSlot>> _generateDailySchedule(StudyPreferences preferences) {
    final schedule = <String, List<TimeSlot>>{};
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (final day in days) {
      schedule[day] = preferences.preferredStudyTimes.map((time) {
        final hour = int.parse(time.split(':')[0]);
        return TimeSlot(
          startTime: time,
          duration: preferences.preferredSessionDuration,
          subject: '', // Will be filled based on curriculum
        );
      }).toList();
    }
    
    return schedule;
  }

  Future<void> _saveProfile(PersonalizedLearningProfile profile) async {
    try {
      await Amplify.API.post(
        '/profiles',
        apiName: 'profileAPI',
        body: HttpPayload.json(profile.toJson()),
      ).response;
    } catch (e) {
      safePrint('Error saving profile: $e');
    }
  }

  void _addConversation(String userId, AIConversation conversation) {
    _conversationHistory[userId] ??= [];
    _conversationHistory[userId]!.add(conversation);
    
    // Keep only last 100 conversations in memory
    if (_conversationHistory[userId]!.length > 100) {
      _conversationHistory[userId]!.removeAt(0);
    }
  }

  // Missing helper method implementations
  
  Future<PersonalizedLearningProfile?> _loadProfileFromStorage(String userId) async {
    try {
      final response = await Amplify.API.get(
        '/profiles/$userId',
        apiName: 'profileAPI',
      ).response;
      
      if (response.body != null) {
        final data = json.decode(response.body);
        // Parse the profile data - simplified for now
        return null;
      }
      return null;
    } catch (e) {
      safePrint('Error loading profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _extractCurriculumInfo(String userMessage, String aiResponse) async {
    // Use AI to extract curriculum planning information
    return {
      'curriculumType': 'custom',
      'modules': [],
      'duration': 90,
    };
  }

  Future<Map<String, dynamic>> _extractProgressInfo(String userMessage, String aiResponse) async {
    // Extract progress review information
    return {
      'completionRate': 0.75,
      'strengths': ['Problem solving'],
      'weaknesses': ['Time management'],
    };
  }

  Future<Map<String, dynamic>> _extractStudyPlanInfo(String userMessage, String aiResponse) async {
    // Extract study planning information
    return {
      'dailyGoals': 2,
      'focusAreas': ['Mathematics', 'Physics'],
      'studyHours': 3,
    };
  }

  Future<Map<String, dynamic>> _extractGeneralLearningInfo(String userMessage, String aiResponse) async {
    // Extract general learning information from conversation
    return {
      'topics': [],
      'concepts': [],
      'preferences': {},
    };
  }

  Future<ProfileUpdate> _updateExamPreparation(
    PersonalizedLearningProfile profile,
    Map<String, dynamic> extractedInfo,
  ) async {
    // Update exam preparation based on extracted info
    return ProfileUpdate(
      type: 'exam_preparation',
      description: 'Updated exam preparation',
      data: extractedInfo,
      timestamp: DateTime.now(),
    );
  }

  Future<ProfileUpdate> _updateCustomCurriculum(
    PersonalizedLearningProfile profile,
    Map<String, dynamic> extractedInfo,
  ) async {
    // Update custom curriculum
    return ProfileUpdate(
      type: 'curriculum',
      description: 'Updated curriculum',
      data: extractedInfo,
      timestamp: DateTime.now(),
    );
  }

  Future<ProfileUpdate> _updateLearningProgress(
    PersonalizedLearningProfile profile,
    Map<String, dynamic> extractedInfo,
  ) async {
    // Update learning progress
    return ProfileUpdate(
      type: 'progress',
      description: 'Updated learning progress',
      data: extractedInfo,
      timestamp: DateTime.now(),
    );
  }

  Future<ProfileUpdate> _updateStudyPlan(
    PersonalizedLearningProfile profile,
    Map<String, dynamic> extractedInfo,
  ) async {
    // Update study plan
    return ProfileUpdate(
      type: 'study_plan',
      description: 'Updated study plan',
      data: extractedInfo,
      timestamp: DateTime.now(),
    );
  }

  Future<List<ConversationInsight>> _generateConversationInsights({
    required PersonalizedLearningProfile profile,
    required AIConversation conversation,
  }) async {
    // Generate insights from conversation
    return [
      ConversationInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        insight: 'User shows interest in structured learning',
        type: InsightType.pattern,
        confidence: 0.8,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> _updateUserKnowledgeGraph({
    required String userId,
    required List<dynamic> concepts,
  }) async {
    // Update user's knowledge graph with new concepts
    try {
      // Would integrate with Neptune graph DB
      safePrint('Updating knowledge graph for user $userId');
    } catch (e) {
      safePrint('Error updating knowledge graph: $e');
    }
  }

  Future<List<SuggestedAction>> _generateSuggestedActions(
    PersonalizedLearningProfile profile,
    List<ProfileUpdate> updates,
  ) async {
    // Generate suggested actions based on profile updates
    return [
      SuggestedAction(
        action: 'Review fundamentals',
        reason: 'Strengthen foundation before advancing',
        parameters: {'subject': 'mathematics', 'duration': 30},
      ),
    ];
  }

  Future<void> _createTodosFromCurriculum(String userId, CustomCurriculum curriculum) async {
    // Create initial todos based on curriculum modules
    for (final module in curriculum.modules) {
      // Create todos for each module
      safePrint('Creating todos for module: ${module.name}');
    }
  }

  Future<void> _handleModuleCompletion({
    required String userId,
    required CustomCurriculum curriculum,
    required String moduleId,
  }) async {
    // Handle module completion logic
    safePrint('Module $moduleId completed for user $userId');
  }

  Future<List<UserUploadedContent>> _getUserContent(String userId) async {
    // Fetch user's uploaded content
    return [];
  }

  Future<List<InstructorCurriculum>> _findRelevantInstructorCurricula(
    String targetExam,
    List<String> subjects,
    Map<String, dynamic>? preferences,
  ) async {
    // Find relevant instructor curricula
    return [];
  }

  Future<List<Textbook>> _findRecommendedTextbooks(
    List<String> subjects,
    String targetExam,
    String? difficulty,
  ) async {
    // Find recommended textbooks
    return [];
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
    // Generate integrated study path
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

  Future<PersonalizedRecommendations> _getDailyTaskRecommendations(
    PersonalizedLearningProfile profile,
    dynamic learningContext,
  ) async {
    return PersonalizedRecommendations(
      type: RecommendationType.dailyTasks,
      recommendations: [
        Recommendation(
          id: '1',
          title: 'Morning Math Practice',
          description: 'Focus on calculus problems',
          reason: 'Based on your study schedule',
          priority: 0.9,
          actionData: {'duration': 45, 'subject': 'mathematics'},
        ),
      ],
      context: {'profile': profile.userId},
      generatedAt: DateTime.now(),
    );
  }

  Future<PersonalizedRecommendations> _getStudyMaterialRecommendations(
    PersonalizedLearningProfile profile,
    Map<String, dynamic>? context,
  ) async {
    return PersonalizedRecommendations(
      type: RecommendationType.studyMaterials,
      recommendations: [],
      context: context ?? {},
      generatedAt: DateTime.now(),
    );
  }

  Future<PersonalizedRecommendations> _getScheduleOptimizationRecommendations(
    PersonalizedLearningProfile profile,
    dynamic learningContext,
  ) async {
    return PersonalizedRecommendations(
      type: RecommendationType.scheduleOptimization,
      recommendations: [],
      context: {'profile': profile.userId},
      generatedAt: DateTime.now(),
    );
  }

  Future<PersonalizedRecommendations> _getConceptReviewRecommendations(
    PersonalizedLearningProfile profile,
    dynamic learningContext,
  ) async {
    return PersonalizedRecommendations(
      type: RecommendationType.conceptReview,
      recommendations: [],
      context: {'profile': profile.userId},
      generatedAt: DateTime.now(),
    );
  }

  Future<PersonalizedRecommendations> _getExamStrategyRecommendations(
    PersonalizedLearningProfile profile,
    Map<String, dynamic>? context,
  ) async {
    return PersonalizedRecommendations(
      type: RecommendationType.examStrategy,
      recommendations: [],
      context: context ?? {},
      generatedAt: DateTime.now(),
    );
  }

  Future<int> _calculateTotalStudyTime(String userId, DateTime startDate, DateTime endDate) async {
    // Calculate total study time in minutes
    return 1200; // Placeholder
  }

  Future<Map<String, double>> _calculateCompletionRates(
    PersonalizedLearningProfile profile,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Calculate completion rates by subject
    return {
      'mathematics': 0.75,
      'physics': 0.80,
      'chemistry': 0.65,
    };
  }

  Future<Map<String, double>> _calculateConceptMastery(String userId) async {
    // Calculate concept mastery levels
    return {
      'calculus': 0.85,
      'algebra': 0.90,
      'geometry': 0.70,
    };
  }

  Future<Map<String, double>> _calculateExamReadiness(PersonalizedLearningProfile profile) async {
    // Calculate exam readiness by exam type
    final readiness = <String, double>{};
    
    for (final exam in profile.examPreparations) {
      readiness[exam.examName] = 0.75; // Simplified calculation
    }
    
    return readiness;
  }

  Future<List<String>> _identifyStrengths(PersonalizedLearningProfile profile) async {
    // Identify user's strengths
    return ['Problem solving', 'Time management', 'Consistent practice'];
  }

  Future<List<String>> _identifyWeaknesses(PersonalizedLearningProfile profile) async {
    // Identify areas for improvement
    return ['Complex word problems', 'Test anxiety'];
  }

  Future<List<AnalyticsInsight>> _generateAnalyticsInsights({
    required PersonalizedLearningProfile profile,
    required int studyTime,
    required Map<String, double> completionRates,
  }) async {
    // Generate analytics insights
    return [
      AnalyticsInsight(
        insight: 'Study time increased by 20% this week',
        category: 'engagement',
        impact: 0.8,
        recommendation: 'Maintain this momentum',
      ),
    ];
  }
}

// Data models
class PersonalizedLearningProfile {
  final String userId;
  final DateTime createdAt;
  DateTime lastUpdated;
  List<LearningGoal> learningGoals;
  List<ExamPreparation> examPreparations;
  List<CustomCurriculum> customCurricula;
  StudyPreferences studyPreferences;
  Map<String, ConceptMastery> knowledgeMap;
  List<ConversationInsight> conversationInsights;

  PersonalizedLearningProfile({
    required this.userId,
    required this.createdAt,
    required this.lastUpdated,
    required this.learningGoals,
    required this.examPreparations,
    required this.customCurricula,
    required this.studyPreferences,
    required this.knowledgeMap,
    required this.conversationInsights,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'learningGoals': learningGoals.map((g) => g.toJson()).toList(),
    'examPreparations': examPreparations.map((e) => e.toJson()).toList(),
    'customCurricula': customCurricula.map((c) => c.toJson()).toList(),
    'studyPreferences': studyPreferences.toJson(),
    'knowledgeMap': knowledgeMap.map((k, v) => MapEntry(k, v.toJson())),
    'conversationInsights': conversationInsights.map((i) => i.toJson()).toList(),
  };
}

class LearningGoal {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final GoalType type;
  final Map<String, dynamic> metadata;
  double progress;
  bool isActive;

  LearningGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.type,
    required this.metadata,
    this.progress = 0.0,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'targetDate': targetDate.toIso8601String(),
    'type': type.name,
    'metadata': metadata,
    'progress': progress,
    'isActive': isActive,
  };
}

enum GoalType {
  exam,
  skill,
  certification,
  personal,
  academic,
}

class ExamPreparation {
  final String id;
  final String examName;
  final ExamType examType;
  final DateTime targetDate;
  final List<String> subjects;
  final String currentLevel;
  final String? targetScore;
  StudyPlan? studyPlan;
  Map<String, SubjectProgress> progress;
  final bool isCustom;
  final Map<String, dynamic>? customDetails;
  final DateTime createdAt;

  ExamPreparation({
    required this.id,
    required this.examName,
    required this.examType,
    required this.targetDate,
    required this.subjects,
    required this.currentLevel,
    this.targetScore,
    this.studyPlan,
    required this.progress,
    required this.isCustom,
    this.customDetails,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'examName': examName,
    'examType': examType.name,
    'targetDate': targetDate.toIso8601String(),
    'subjects': subjects,
    'currentLevel': currentLevel,
    'targetScore': targetScore,
    'studyPlan': studyPlan?.toJson(),
    'progress': progress.map((k, v) => MapEntry(k, v.toJson())),
    'isCustom': isCustom,
    'customDetails': customDetails,
    'createdAt': createdAt.toIso8601String(),
  };
}

enum ExamType {
  koreanSAT,
  sat,
  toeic,
  toefl,
  ielts,
  civilService,
  certification,
  custom,
}

class CustomCurriculum {
  final String id;
  final String name;
  final String description;
  final String? baseTemplate;
  List<CurriculumModule> modules;
  final int totalHours;
  Map<String, ModuleProgress> progress;
  bool isActive;
  final DateTime createdAt;
  DateTime lastModified;

  CustomCurriculum({
    required this.id,
    required this.name,
    required this.description,
    this.baseTemplate,
    required this.modules,
    required this.totalHours,
    required this.progress,
    required this.isActive,
    required this.createdAt,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'baseTemplate': baseTemplate,
    'modules': modules.map((m) => m.toJson()).toList(),
    'totalHours': totalHours,
    'progress': progress.map((k, v) => MapEntry(k, v.toJson())),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'lastModified': lastModified.toIso8601String(),
  };
}

class CurriculumModule {
  final String id;
  final String name;
  final String description;
  final int order;
  final int estimatedHours;
  final List<String> topics;
  final List<String> resources;
  final Map<String, dynamic>? customData;

  CurriculumModule({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.estimatedHours,
    required this.topics,
    required this.resources,
    this.customData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'order': order,
    'estimatedHours': estimatedHours,
    'topics': topics,
    'resources': resources,
    'customData': customData,
  };
}

class StudyPreferences {
  List<String> preferredStudyTimes;
  int preferredSessionDuration; // minutes
  int breakFrequency; // minutes between breaks
  String learningStyle; // visual, auditory, kinesthetic, reading/writing
  String difficultyPreference; // easy_start, challenging, mixed
  bool notificationsEnabled;
  Map<String, bool> featurePreferences;
  DateTime lastUpdated;
  bool aiOptimized;

  StudyPreferences({
    required this.preferredStudyTimes,
    required this.preferredSessionDuration,
    required this.breakFrequency,
    required this.learningStyle,
    required this.difficultyPreference,
    required this.notificationsEnabled,
    required this.featurePreferences,
    required this.lastUpdated,
    required this.aiOptimized,
  });

  factory StudyPreferences.defaultPreferences() {
    return StudyPreferences(
      preferredStudyTimes: ['09:00', '14:00', '19:00'],
      preferredSessionDuration: 45,
      breakFrequency: 45,
      learningStyle: 'mixed',
      difficultyPreference: 'mixed',
      notificationsEnabled: true,
      featurePreferences: {
        'aiSuggestions': true,
        'gamification': true,
        'socialFeatures': true,
      },
      lastUpdated: DateTime.now(),
      aiOptimized: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'preferredStudyTimes': preferredStudyTimes,
    'preferredSessionDuration': preferredSessionDuration,
    'breakFrequency': breakFrequency,
    'learningStyle': learningStyle,
    'difficultyPreference': difficultyPreference,
    'notificationsEnabled': notificationsEnabled,
    'featurePreferences': featurePreferences,
    'lastUpdated': lastUpdated.toIso8601String(),
    'aiOptimized': aiOptimized,
  };
}

class AIConversation {
  final String id;
  final String userId;
  final String userMessage;
  final String aiResponse;
  final ConversationType type;
  final DateTime timestamp;
  Map<String, dynamic> extractedInfo;

  AIConversation({
    required this.id,
    required this.userId,
    required this.userMessage,
    required this.aiResponse,
    required this.type,
    required this.timestamp,
    required this.extractedInfo,
  });
}

enum ConversationType {
  general,
  examSetup,
  curriculumPlanning,
  progressReview,
  studyPlanning,
  conceptExplanation,
  problemSolving,
}

class ProfileUpdateResult {
  final List<ProfileUpdate> updates;
  final List<ConversationInsight> insights;
  final Map<String, dynamic> extractedInfo;
  final List<SuggestedAction> suggestedActions;

  ProfileUpdateResult({
    required this.updates,
    required this.insights,
    required this.extractedInfo,
    required this.suggestedActions,
  });
}

class ProfileUpdate {
  final String type;
  final String description;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  ProfileUpdate({
    required this.type,
    required this.description,
    required this.data,
    required this.timestamp,
  });
}

class ConversationInsight {
  final String id;
  final String insight;
  final InsightType type;
  final double confidence;
  final DateTime timestamp;

  ConversationInsight({
    required this.id,
    required this.insight,
    required this.type,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'insight': insight,
    'type': type.name,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
  };
}

enum InsightType {
  strength,
  weakness,
  pattern,
  recommendation,
  warning,
}

class PersonalizedRecommendations {
  final RecommendationType type;
  final List<Recommendation> recommendations;
  final Map<String, dynamic> context;
  final DateTime generatedAt;

  PersonalizedRecommendations({
    required this.type,
    required this.recommendations,
    required this.context,
    required this.generatedAt,
  });
}

enum RecommendationType {
  dailyTasks,
  studyMaterials,
  scheduleOptimization,
  conceptReview,
  examStrategy,
}

class Recommendation {
  final String id;
  final String title;
  final String description;
  final String reason;
  final double priority;
  final Map<String, dynamic> actionData;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.reason,
    required this.priority,
    required this.actionData,
  });
}

class SuggestedAction {
  final String action;
  final String reason;
  final Map<String, dynamic> parameters;

  SuggestedAction({
    required this.action,
    required this.reason,
    required this.parameters,
  });
}

// Additional supporting classes...
class StudyPlan {
  final String examId;
  final List<StudyPhase> phases;
  final Map<String, List<TimeSlot>> dailySchedule;
  final List<Milestone> milestones;

  StudyPlan({
    required this.examId,
    required this.phases,
    required this.dailySchedule,
    required this.milestones,
  });

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'phases': phases.map((p) => p.toJson()).toList(),
    'dailySchedule': dailySchedule.map((k, v) => 
      MapEntry(k, v.map((t) => t.toJson()).toList())),
    'milestones': milestones.map((m) => m.toJson()).toList(),
  };
}

class StudyPhase {
  final String name;
  final int duration; // days
  final List<String> goals;
  final List<String> modules;

  StudyPhase({
    required this.name,
    required this.duration,
    required this.goals,
    required this.modules,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'duration': duration,
    'goals': goals,
    'modules': modules,
  };
}

class TimeSlot {
  final String startTime;
  final int duration; // minutes
  final String subject;

  TimeSlot({
    required this.startTime,
    required this.duration,
    required this.subject,
  });

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'duration': duration,
    'subject': subject,
  };
}

class Milestone {
  final String id;
  final String title;
  final DateTime targetDate;
  final String description;
  bool isCompleted;

  Milestone({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetDate': targetDate.toIso8601String(),
    'description': description,
    'isCompleted': isCompleted,
  };
}

class ConceptMastery {
  final String conceptId;
  final double masteryLevel; // 0-1
  final DateTime lastStudied;
  final int totalStudyTime; // minutes
  final int reviewCount;

  ConceptMastery({
    required this.conceptId,
    required this.masteryLevel,
    required this.lastStudied,
    required this.totalStudyTime,
    required this.reviewCount,
  });

  Map<String, dynamic> toJson() => {
    'conceptId': conceptId,
    'masteryLevel': masteryLevel,
    'lastStudied': lastStudied.toIso8601String(),
    'totalStudyTime': totalStudyTime,
    'reviewCount': reviewCount,
  };
}

class SubjectProgress {
  final String subject;
  final double completionPercentage;
  final double averagePerformance;
  final int totalHoursStudied;
  final DateTime lastStudied;

  SubjectProgress({
    required this.subject,
    required this.completionPercentage,
    required this.averagePerformance,
    required this.totalHoursStudied,
    required this.lastStudied,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'completionPercentage': completionPercentage,
    'averagePerformance': averagePerformance,
    'totalHoursStudied': totalHoursStudied,
    'lastStudied': lastStudied.toIso8601String(),
  };
}

class ModuleProgress {
  final String moduleId;
  final double completionPercentage;
  final DateTime lastStudied;
  final double performance;
  final int timeSpent; // minutes

  ModuleProgress({
    required this.moduleId,
    required this.completionPercentage,
    required this.lastStudied,
    required this.performance,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() => {
    'moduleId': moduleId,
    'completionPercentage': completionPercentage,
    'lastStudied': lastStudied.toIso8601String(),
    'performance': performance,
    'timeSpent': timeSpent,
  };
}

class PersonalizedAnalytics {
  final String userId;
  final DateTimeRange period;
  final int totalStudyTime; // minutes
  final Map<String, double> completionRates;
  final Map<String, double> conceptMastery;
  final Map<String, double> examReadiness;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<AnalyticsInsight> insights;

  PersonalizedAnalytics({
    required this.userId,
    required this.period,
    required this.totalStudyTime,
    required this.completionRates,
    required this.conceptMastery,
    required this.examReadiness,
    required this.strengths,
    required this.weaknesses,
    required this.insights,
  });
}

class AnalyticsInsight {
  final String insight;
  final String category;
  final double impact; // 0-1
  final String recommendation;

  AnalyticsInsight({
    required this.insight,
    required this.category,
    required this.impact,
    required this.recommendation,
  });
}