import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ModelProvider.dart';
import '../../models/service_models.dart';
import '../services/ai_service.dart';
import '../services/curriculum_service.dart';
import '../services/educational_content_service.dart';

// Enhanced Todo Repository Provider
final todoRepositoryEnhancedProvider = Provider<TodoRepositoryEnhanced>((ref) {
  return TodoRepositoryEnhanced(
    ref.read(aiServiceProvider),
    CurriculumService(),
    EducationalContentService(),
  );
});

class TodoRepositoryEnhanced {
  final AIService _aiService;
  final CurriculumService _curriculumService;
  final EducationalContentService _educationalContentService;

  TodoRepositoryEnhanced(
    this._aiService,
    this._curriculumService,
    this._educationalContentService,
  );

  // Create new todo with curriculum mapping
  Future<EnhancedTodo> createTodo({
    required String userId,
    required String title,
    String? description,
    required Priority priority,
    DateTime? dueDate,
    String? subject,
    String? curriculumPath, // e.g., "mathematics.calculus.derivatives"
    String? textbookReference, // e.g., "9791162241356:chapter2:section3"
    String? instructorCurriculum, // e.g., "megastudy_hyunwoojin_math:module2"
    int? estimatedTime,
    bool aiSuggested = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Map to curriculum if path not provided
      CurriculumMapping? curriculumMapping;
      if (curriculumPath == null && subject != null) {
        curriculumMapping = await _curriculumService.mapActivityToCurriculum(
          activityDescription: title,
          subject: subject,
          preferredCurriculum: _getUserPreferredCurriculum(userId),
        );
        
        if (curriculumMapping.confidence > 0.6 && curriculumMapping.mappedTopics.isNotEmpty) {
          curriculumPath = curriculumMapping.mappedTopics.first.id;
        }
      }

      // If no estimated time provided, use AI to predict
      int finalEstimatedTime = estimatedTime ?? 
          await _getAITimeEstimation(
            title: title,
            subject: subject ?? 'General',
            userId: userId,
            curriculumPath: curriculumPath,
          );

      // Extract keywords and concepts
      final extractedData = await _extractKeywordsAndConcepts(
        title: title,
        description: description,
        curriculumPath: curriculumPath,
      );

      // Calculate XP reward based on multiple factors
      final xpReward = _calculateEnhancedXPReward(
        estimatedTime: finalEstimatedTime,
        priority: priority,
        curriculumLevel: curriculumMapping?.overallDifficulty,
        hasReferences: textbookReference != null || instructorCurriculum != null,
      );

      // Create base todo
      final todo = Todo(
        title: title,
        description: description,
        completed: false,
        priority: priority,
        dueDate: dueDate != null ? TemporalDateTime(dueDate) : null,
        subject: subject,
        estimatedTime: finalEstimatedTime,
        aiSuggested: aiSuggested,
        xpReward: xpReward,
        userID: userId,
      );

      final savedTodo = await Amplify.DataStore.save(todo);

      // Create enhanced todo with additional data
      final enhancedTodo = EnhancedTodo(
        todo: savedTodo,
        curriculumPath: curriculumPath,
        curriculumMapping: curriculumMapping,
        textbookReference: textbookReference,
        instructorCurriculum: instructorCurriculum,
        keywords: extractedData['keywords'] ?? [],
        concepts: extractedData['concepts'] ?? [],
        learningObjectives: curriculumMapping?.mappedTopics.first.learningObjectives ?? [],
        metadata: {
          ...?metadata,
          'mappingConfidence': curriculumMapping?.confidence,
          'suggestedKeywords': curriculumMapping?.suggestedKeywords,
        },
      );

      // Store enhanced data separately
      await _storeEnhancedTodoData(enhancedTodo);

      // Track curriculum progress
      if (curriculumPath != null) {
        await _trackCurriculumActivity(
          userId: userId,
          curriculumPath: curriculumPath,
          activityType: 'todo_created',
        );
      }

      return enhancedTodo;
    } catch (e) {
      safePrint('Error creating enhanced todo: $e');
      rethrow;
    }
  }

  // Complete todo with curriculum tracking
  Future<EnhancedTodoCompletionResult> completeTodo({
    required String todoId,
    required int actualTime,
    Map<String, dynamic>? completionData,
  }) async {
    try {
      final todos = await Amplify.DataStore.query(
        Todo.classType,
        where: Todo.ID.eq(todoId),
      );

      if (todos.isEmpty) throw Exception('Todo not found');
      
      final todo = todos.first;
      final enhancedData = await _getEnhancedTodoData(todoId);
      
      // Calculate efficiency bonus
      final efficiencyBonus = _calculateEfficiencyBonus(
        estimatedTime: todo.estimatedTime ?? 30,
        actualTime: actualTime,
      );

      // Calculate mastery progress
      double masteryProgress = 0.0;
      if (enhancedData?.curriculumPath != null) {
        masteryProgress = await _calculateMasteryProgress(
          userId: todo.userID,
          curriculumPath: enhancedData!.curriculumPath!,
          performance: completionData?['performance'] ?? 0.8,
          timeSpent: actualTime,
        );
      }

      // Calculate additional bonuses
      final conceptBonus = _calculateConceptBonus(
        concepts: enhancedData?.concepts ?? [],
        performance: completionData?['performance'] ?? 0.8,
      );

      final totalXP = todo.xpReward + efficiencyBonus + conceptBonus;

      final updatedTodo = todo.copyWith(
        completed: true,
        completedAt: TemporalDateTime.now(),
        actualTime: actualTime,
      );

      await Amplify.DataStore.save(updatedTodo);

      // Update curriculum progress
      if (enhancedData?.curriculumPath != null) {
        await _updateCurriculumProgress(
          userId: todo.userID,
          curriculumPath: enhancedData!.curriculumPath!,
          progress: masteryProgress,
          performance: completionData?['performance'] ?? 0.8,
          timeSpent: actualTime,
        );
      }

      // Generate insights
      final insights = await _generateCompletionInsights(
        todo: updatedTodo,
        enhancedData: enhancedData,
        actualTime: actualTime,
        performance: completionData?['performance'] ?? 0.8,
      );

      return EnhancedTodoCompletionResult(
        todo: updatedTodo,
        baseXP: todo.xpReward,
        efficiencyBonus: efficiencyBonus,
        conceptBonus: conceptBonus,
        totalXP: totalXP,
        masteryProgress: masteryProgress,
        insights: insights,
        nextRecommendations: await _getNextRecommendations(
          userId: todo.userID,
          completedTodo: enhancedData,
        ),
      );
    } catch (e) {
      safePrint('Error completing enhanced todo: $e');
      rethrow;
    }
  }

  // Get todos with curriculum context
  Future<List<EnhancedTodo>> getEnhancedTodos({
    required String userId,
    String? curriculumType,
    String? subject,
    String? textbookId,
    bool includeRecommendations = false,
  }) async {
    try {
      // Get base todos
      var query = Todo.USER_ID.eq(userId);
      
      if (subject != null) {
        query = query.and(Todo.SUBJECT.eq(subject));
      }

      final todos = await Amplify.DataStore.query(
        Todo.classType,
        where: query,
        sortBy: [
          Todo.COMPLETED.ascending(),
          Todo.PRIORITY.descending(),
          Todo.DUE_DATE.ascending(),
        ],
      );

      // Enhance todos with curriculum data
      final enhancedTodos = <EnhancedTodo>[];
      
      for (final todo in todos) {
        final enhancedData = await _getEnhancedTodoData(todo.id);
        if (enhancedData != null) {
          // Filter by curriculum type if specified
          if (curriculumType != null && 
              !enhancedData.curriculumPath?.contains(curriculumType) == true) {
            continue;
          }
          
          // Filter by textbook if specified
          if (textbookId != null && 
              enhancedData.textbookReference?.startsWith(textbookId) != true) {
            continue;
          }
          
          enhancedTodos.add(enhancedData);
        } else {
          // Create basic enhanced todo
          enhancedTodos.add(EnhancedTodo(
            todo: todo,
            keywords: [],
            concepts: [],
            learningObjectives: [],
            metadata: {},
          ));
        }
      }

      // Add AI recommendations if requested
      if (includeRecommendations && enhancedTodos.length < 10) {
        final recommendations = await _getAITodoRecommendations(
          userId: userId,
          existingTodos: enhancedTodos,
          subject: subject,
        );
        enhancedTodos.addAll(recommendations);
      }

      return enhancedTodos;
    } catch (e) {
      safePrint('Error getting enhanced todos: $e');
      return [];
    }
  }

  // Get study plan integrated with curriculum
  Future<IntegratedStudyPlan> getIntegratedStudyPlan({
    required String userId,
    required DateTime targetDate,
    required List<String> subjects,
    String? preferredInstructor,
    List<String>? preferredTextbooks,
  }) async {
    try {
      // Get user's curriculum preferences
      final preferences = await _getUserCurriculumPreferences(userId);
      
      // Get integrated study path from educational content service
      final studyPath = await _educationalContentService.getIntegratedStudyPath(
        userId: userId,
        targetExam: preferences['targetExam'] ?? 'general',
        subjects: subjects,
        targetDate: targetDate,
        preferences: {
          'instructor': preferredInstructor,
          'textbooks': preferredTextbooks,
          ...preferences,
        },
      );

      // Convert to todos
      final todos = await _convertStudyPathToTodos(
        studyPath: studyPath,
        userId: userId,
      );

      return IntegratedStudyPlan(
        studyPath: studyPath,
        todos: todos,
        estimatedCompletionRate: studyPath.estimatedCompletionRate,
      );
    } catch (e) {
      safePrint('Error getting integrated study plan: $e');
      rethrow;
    }
  }

  // Helper methods
  
  Future<int> _getAITimeEstimation({
    required String title,
    required String subject,
    required String userId,
    String? curriculumPath,
  }) async {
    try {
      final context = curriculumPath != null
          ? {'curriculumPath': curriculumPath}
          : null;
          
      final estimation = await _aiService.predictTaskDuration(
        taskTitle: title,
        subject: subject,
        userId: userId,
        context: context,
      );
      
      return estimation['estimatedMinutes'] ?? 30;
    } catch (e) {
      // Default fallback
      return 30;
    }
  }

  Future<Map<String, List<String>>> _extractKeywordsAndConcepts({
    required String title,
    String? description,
    String? curriculumPath,
  }) async {
    final keywords = <String>{};
    final concepts = <String>{};
    
    // Extract from title and description
    final text = '$title ${description ?? ''}'.toLowerCase();
    
    // Get topic if curriculum path provided
    if (curriculumPath != null) {
      final topic = _curriculumService.getTopicByPath(curriculumPath);
      if (topic != null) {
        keywords.addAll(topic.keywords);
        concepts.add(topic.name);
      }
    }
    
    // Simple keyword extraction
    final words = text.split(RegExp(r'\s+'));
    keywords.addAll(words.where((w) => w.length > 3));
    
    return {
      'keywords': keywords.toList(),
      'concepts': concepts.toList(),
    };
  }

  int _calculateEnhancedXPReward({
    required int estimatedTime,
    required Priority priority,
    int? curriculumLevel,
    bool hasReferences = false,
  }) {
    // Base XP based on time
    int baseXP = (estimatedTime / 10).round() * 5;
    
    // Priority multiplier
    double multiplier = 1.0;
    switch (priority) {
      case Priority.HIGH:
        multiplier = 1.5;
        break;
      case Priority.MEDIUM:
        multiplier = 1.2;
        break;
      case Priority.LOW:
        multiplier = 1.0;
        break;
    }
    
    // Curriculum level bonus
    if (curriculumLevel != null) {
      multiplier += curriculumLevel * 0.1;
    }
    
    // Reference bonus
    if (hasReferences) {
      multiplier += 0.2;
    }
    
    return (baseXP * multiplier).round().clamp(10, 200);
  }

  Future<void> _storeEnhancedTodoData(EnhancedTodo enhancedTodo) async {
    // Store in DynamoDB or custom table
    try {
      await Amplify.API.post(
        '/enhanced-todos',
        body: HttpPayload.json(enhancedTodo.toJson()),
      ).response;
    } catch (e) {
      safePrint('Error storing enhanced todo data: $e');
    }
  }

  Future<EnhancedTodo?> _getEnhancedTodoData(String todoId) async {
    // Retrieve from DynamoDB or custom table
    try {
      final response = await Amplify.API.get(
        '/enhanced-todos/$todoId',
      ).response;
      
      if (response.decodeBody().isNotEmpty) {
        final data = json.decode(response.decodeBody());
        return EnhancedTodo.fromJson(data);
      }
    } catch (e) {
      safePrint('Error getting enhanced todo data: $e');
    }
    return null;
  }

  CurriculumType? _getUserPreferredCurriculum(String userId) {
    // Get from user preferences
    // For now, return Korean SAT as default
    return CurriculumType.korean_sat;
  }

  Future<void> _trackCurriculumActivity({
    required String userId,
    required String curriculumPath,
    required String activityType,
  }) async {
    try {
      await Amplify.API.post(
        '/track-activity',
        body: HttpPayload.json({
          'userId': userId,
          'curriculumPath': curriculumPath,
          'activityType': activityType,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).response;
    } catch (e) {
      safePrint('Error tracking curriculum activity: $e');
    }
  }
}

// Enhanced data models
class EnhancedTodo {
  final Todo todo;
  final String? curriculumPath;
  final CurriculumMapping? curriculumMapping;
  final String? textbookReference;
  final String? instructorCurriculum;
  final List<String> keywords;
  final List<String> concepts;
  final List<String> learningObjectives;
  final Map<String, dynamic> metadata;

  EnhancedTodo({
    required this.todo,
    this.curriculumPath,
    this.curriculumMapping,
    this.textbookReference,
    this.instructorCurriculum,
    required this.keywords,
    required this.concepts,
    required this.learningObjectives,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'todoId': todo.id,
    'curriculumPath': curriculumPath,
    'textbookReference': textbookReference,
    'instructorCurriculum': instructorCurriculum,
    'keywords': keywords,
    'concepts': concepts,
    'learningObjectives': learningObjectives,
    'metadata': metadata,
  };

  factory EnhancedTodo.fromJson(Map<String, dynamic> json) {
    // Implementation needed
    throw UnimplementedError();
  }
}

class EnhancedTodoCompletionResult {
  final Todo todo;
  final int baseXP;
  final int efficiencyBonus;
  final int conceptBonus;
  final int totalXP;
  final double masteryProgress;
  final List<String> insights;
  final List<TodoRecommendation> nextRecommendations;

  EnhancedTodoCompletionResult({
    required this.todo,
    required this.baseXP,
    required this.efficiencyBonus,
    required this.conceptBonus,
    required this.totalXP,
    required this.masteryProgress,
    required this.insights,
    required this.nextRecommendations,
  });
}

class TodoRecommendation {
  final String title;
  final String reason;
  final String? curriculumPath;
  final Priority suggestedPriority;
  final int estimatedMinutes;

  TodoRecommendation({
    required this.title,
    required this.reason,
    this.curriculumPath,
    required this.suggestedPriority,
    required this.estimatedMinutes,
  });
}

class IntegratedStudyPlan {
  final IntegratedStudyPath studyPath;
  final List<EnhancedTodo> todos;
  final double estimatedCompletionRate;

  IntegratedStudyPlan({
    required this.studyPath,
    required this.todos,
    required this.estimatedCompletionRate,
  });
}