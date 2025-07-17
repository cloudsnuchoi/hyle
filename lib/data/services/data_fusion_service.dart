import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ontology_service.dart';
import 'ai_service.dart';
import '../repositories/user_repository.dart';
import '../repositories/timer_repository.dart';
import '../repositories/todo_repository.dart';

/// Service that fuses data from multiple sources for AI insights
class DataFusionService {
  static final DataFusionService _instance = DataFusionService._internal();
  factory DataFusionService() => _instance;
  DataFusionService._internal();

  final OntologyService _ontologyService = OntologyService();
  final AIService _aiService = AIService();

  // Stream controllers for real-time data fusion
  final _learningEventController = StreamController<LearningEvent>.broadcast();
  final _insightController = StreamController<FusionInsight>.broadcast();

  Stream<LearningEvent> get learningEventStream => _learningEventController.stream;
  Stream<FusionInsight> get insightStream => _insightController.stream;

  // Buffers for aggregating events
  final List<LearningEvent> _eventBuffer = [];
  Timer? _aggregationTimer;

  /// Initialize the data fusion service
  Future<void> initialize() async {
    try {
      // Start event aggregation timer
      _aggregationTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _processEventBuffer(),
      );

      safePrint('Data fusion service initialized');
    } catch (e) {
      safePrint('Error initializing data fusion service: $e');
    }
  }

  /// Create a comprehensive learning context from multiple data sources
  Future<LearningContext> createLearningContext({
    required String userId,
    required WidgetRef ref,
  }) async {
    try {
      // Gather data from all repositories
      final userRepo = ref.read(userRepositoryProvider);
      final timerRepo = ref.read(timerRepositoryProvider);
      final todoRepo = ref.read(todoRepositoryProvider);

      // Get user data
      final user = await userRepo.getUser(userId);
      final userStats = await userRepo.getUserStatistics(userId);

      // Get recent timer sessions
      final recentSessions = await timerRepo.getRecentSessions(
        userId: userId,
        limit: 20,
      );

      // Get active and recent todos
      final activeTodos = await todoRepo.getUserTodos(userId);
      final completedTodos = activeTodos.where((t) => t.isCompleted).toList();

      // Get knowledge graph
      final knowledgeGraph = await _ontologyService.getUserKnowledgeGraph(userId);

      // Analyze patterns
      final patterns = _analyzePatterns(recentSessions, completedTodos);

      // Create comprehensive context
      return LearningContext(
        userId: userId,
        learningType: user?.learningType ?? 'UNKNOWN',
        currentLevel: user?.level ?? 1,
        totalXP: user?.totalXP ?? 0,
        statistics: userStats,
        recentSessions: recentSessions,
        activeTodos: activeTodos.where((t) => !t.isCompleted).toList(),
        completedTodos: completedTodos,
        knowledgeGraph: knowledgeGraph,
        patterns: patterns,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error creating learning context: $e');
      rethrow;
    }
  }

  /// Track a learning event and trigger fusion analysis
  Future<void> trackLearningEvent(LearningEvent event) async {
    // Add to stream
    _learningEventController.add(event);

    // Add to buffer for batch processing
    _eventBuffer.add(event);

    // Process immediately for critical events
    if (_isCriticalEvent(event)) {
      await _processSingleEvent(event);
    }
  }

  /// Fuse timer and todo data for session insights
  Future<SessionFusionData> fuseSessionData({
    required String sessionId,
    required String userId,
    required List<String> completedTodoIds,
    required int duration,
    required Map<String, dynamic> sessionMetrics,
  }) async {
    try {
      // Get todo details
      final todos = await Future.wait(
        completedTodoIds.map((id) => _getTodoDetails(id)),
      );

      // Extract concepts from todos
      final concepts = <String>{};
      final subjects = <String>{};
      
      for (final todo in todos) {
        if (todo != null) {
          subjects.add(todo['subject'] ?? 'General');
          concepts.addAll(_extractConcepts(todo['title'] ?? ''));
        }
      }

      // Calculate session performance
      final performance = _calculateSessionPerformance(
        duration: duration,
        todosCompleted: todos.length,
        metrics: sessionMetrics,
      );

      // Generate session embedding for RAG
      final sessionText = _createSessionText(
        subjects: subjects.toList(),
        concepts: concepts.toList(),
        duration: duration,
        performance: performance,
      );

      // Store in vector DB
      await _storeSessionEmbedding(
        sessionId: sessionId,
        userId: userId,
        sessionText: sessionText,
        metadata: {
          'subjects': subjects.toList(),
          'concepts': concepts.toList(),
          'duration': duration,
          'performance': performance,
          'todosCompleted': todos.length,
        },
      );

      // Update knowledge graph
      for (final concept in concepts) {
        await _ontologyService.updateConceptMastery(
          userId: userId,
          conceptId: concept.toLowerCase().replaceAll(' ', '_'),
          performance: performance,
          duration: duration,
        );
      }

      return SessionFusionData(
        sessionId: sessionId,
        subjects: subjects.toList(),
        concepts: concepts.toList(),
        performance: performance,
        insights: await _generateSessionInsights(
          subjects: subjects.toList(),
          concepts: concepts.toList(),
          performance: performance,
          duration: duration,
        ),
      );
    } catch (e) {
      safePrint('Error fusing session data: $e');
      rethrow;
    }
  }

  /// Generate real-time insights by fusing multiple data streams
  Future<FusionInsight> generateRealTimeInsight({
    required String userId,
    required String currentActivity,
    required Map<String, dynamic> contextData,
  }) async {
    try {
      // Get current learning context
      final context = contextData['learningContext'] as LearningContext?;
      if (context == null) {
        throw Exception('Learning context not available');
      }

      // Analyze current state
      final analysis = _analyzeCurrentState(
        activity: currentActivity,
        context: context,
        additionalData: contextData,
      );

      // Generate insight based on fusion
      final insight = FusionInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _determineInsightType(analysis),
        title: analysis['title'] ?? 'Learning Insight',
        description: analysis['description'] ?? '',
        actionable: analysis['actionable'] ?? false,
        priority: analysis['priority'] ?? 'medium',
        data: analysis,
        timestamp: DateTime.now(),
      );

      // Broadcast insight
      _insightController.add(insight);

      return insight;
    } catch (e) {
      safePrint('Error generating real-time insight: $e');
      rethrow;
    }
  }

  /// Predict optimal next action by fusing historical and current data
  Future<NextActionPrediction> predictNextAction({
    required String userId,
    required LearningContext context,
  }) async {
    try {
      // Analyze current state
      final currentState = {
        'timeOfDay': DateTime.now().hour,
        'dayOfWeek': DateTime.now().weekday,
        'recentPerformance': _calculateRecentPerformance(context.recentSessions),
        'activeSubjects': _getActiveSubjects(context.activeTodos),
        'energyLevel': _estimateEnergyLevel(context),
      };

      // Find similar historical patterns
      final similarPatterns = await _findSimilarPatterns(
        userId: userId,
        currentState: currentState,
      );

      // Generate predictions
      final predictions = await _generateActionPredictions(
        context: context,
        currentState: currentState,
        historicalPatterns: similarPatterns,
      );

      // Rank predictions
      final rankedPredictions = _rankPredictions(predictions, context);

      return NextActionPrediction(
        recommendedAction: rankedPredictions.first,
        alternatives: rankedPredictions.skip(1).take(2).toList(),
        confidence: _calculatePredictionConfidence(rankedPredictions.first, similarPatterns),
        reasoning: _generatePredictionReasoning(rankedPredictions.first, context),
      );
    } catch (e) {
      safePrint('Error predicting next action: $e');
      rethrow;
    }
  }

  /// Analyze multi-modal learning data (text, timer, todo, social)
  Future<MultiModalAnalysis> analyzeMultiModalData({
    required String userId,
    required Duration timeWindow,
  }) async {
    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Gather data from all modalities
      final timerData = await _getTimerDataInWindow(userId, startTime, endTime);
      final todoData = await _getTodoDataInWindow(userId, startTime, endTime);
      final socialData = await _getSocialDataInWindow(userId, startTime, endTime);
      final noteData = await _getNoteDataInWindow(userId, startTime, endTime);

      // Perform cross-modal analysis
      final crossModalPatterns = _analyzeCrossModalPatterns({
        'timer': timerData,
        'todo': todoData,
        'social': socialData,
        'notes': noteData,
      });

      // Generate unified insights
      final unifiedInsights = await _generateUnifiedInsights(
        patterns: crossModalPatterns,
        userId: userId,
      );

      return MultiModalAnalysis(
        timeWindow: timeWindow,
        modalityData: {
          'timer': timerData,
          'todo': todoData,
          'social': socialData,
          'notes': noteData,
        },
        crossModalPatterns: crossModalPatterns,
        unifiedInsights: unifiedInsights,
        recommendations: await _generateMultiModalRecommendations(
          analysis: crossModalPatterns,
          userId: userId,
        ),
      );
    } catch (e) {
      safePrint('Error analyzing multi-modal data: $e');
      rethrow;
    }
  }

  // Private helper methods

  Map<String, dynamic> _analyzePatterns(
    List<dynamic> sessions,
    List<dynamic> todos,
  ) {
    // Time patterns
    final hourCounts = <int, int>{};
    for (final session in sessions) {
      final hour = DateTime.parse(session['startTime']).hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    // Subject patterns
    final subjectCounts = <String, int>{};
    for (final todo in todos) {
      final subject = todo['subject'] ?? 'General';
      subjectCounts[subject] = (subjectCounts[subject] ?? 0) + 1;
    }

    // Performance patterns
    final performances = sessions
        .where((s) => s['productivity'] != null)
        .map((s) => s['productivity'] as double)
        .toList();
    
    final avgPerformance = performances.isEmpty
        ? 0.0
        : performances.reduce((a, b) => a + b) / performances.length;

    return {
      'peakHours': _findPeakHours(hourCounts),
      'favoriteSubjects': _rankSubjects(subjectCounts),
      'averagePerformance': avgPerformance,
      'consistencyScore': _calculateConsistency(sessions),
    };
  }

  List<int> _findPeakHours(Map<int, int> hourCounts) {
    final sorted = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  List<String> _rankSubjects(Map<String, int> subjectCounts) {
    final sorted = subjectCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  double _calculateConsistency(List<dynamic> sessions) {
    if (sessions.length < 2) return 0.0;

    // Calculate standard deviation of session intervals
    final timestamps = sessions
        .map((s) => DateTime.parse(s['startTime']).millisecondsSinceEpoch)
        .toList()
      ..sort();

    final intervals = <double>[];
    for (int i = 1; i < timestamps.length; i++) {
      intervals.add((timestamps[i] - timestamps[i - 1]) / (1000 * 60 * 60)); // hours
    }

    if (intervals.isEmpty) return 1.0;

    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    final variance = intervals
        .map((i) => (i - mean) * (i - mean))
        .reduce((a, b) => a + b) / intervals.length;
    
    final stdDev = variance.sqrt();
    
    // Lower standard deviation means higher consistency
    return 1.0 / (1.0 + stdDev);
  }

  bool _isCriticalEvent(LearningEvent event) {
    return event.type == EventType.struggleDetected ||
           event.type == EventType.breakthroughAchieved ||
           event.type == EventType.motivationDrop;
  }

  Future<void> _processSingleEvent(LearningEvent event) async {
    try {
      // Generate immediate insight
      final insight = await generateRealTimeInsight(
        userId: event.userId,
        currentActivity: event.metadata?['activity'] ?? 'unknown',
        contextData: event.metadata ?? {},
      );

      // Trigger appropriate action
      switch (event.type) {
        case EventType.struggleDetected:
          await _handleStruggle(event);
          break;
        case EventType.breakthroughAchieved:
          await _handleBreakthrough(event);
          break;
        case EventType.motivationDrop:
          await _handleMotivationDrop(event);
          break;
        default:
          break;
      }
    } catch (e) {
      safePrint('Error processing single event: $e');
    }
  }

  Future<void> _processEventBuffer() async {
    if (_eventBuffer.isEmpty) return;

    try {
      // Group events by user
      final eventsByUser = <String, List<LearningEvent>>{};
      for (final event in _eventBuffer) {
        eventsByUser[event.userId] ??= [];
        eventsByUser[event.userId]!.add(event);
      }

      // Process each user's events
      for (final entry in eventsByUser.entries) {
        await _processUserEvents(entry.key, entry.value);
      }

      // Clear buffer
      _eventBuffer.clear();
    } catch (e) {
      safePrint('Error processing event buffer: $e');
    }
  }

  Future<void> _processUserEvents(String userId, List<LearningEvent> events) async {
    // Aggregate patterns
    final patterns = _aggregateEventPatterns(events);

    // Generate insights
    if (patterns.isNotEmpty) {
      final insight = FusionInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: InsightType.pattern,
        title: 'Learning Pattern Detected',
        description: _describePatterns(patterns),
        actionable: true,
        priority: 'medium',
        data: patterns,
        timestamp: DateTime.now(),
      );

      _insightController.add(insight);
    }
  }

  Map<String, dynamic> _aggregateEventPatterns(List<LearningEvent> events) {
    final patterns = <String, dynamic>{};

    // Count event types
    final typeCounts = <EventType, int>{};
    for (final event in events) {
      typeCounts[event.type] = (typeCounts[event.type] ?? 0) + 1;
    }

    patterns['eventTypes'] = typeCounts;

    // Extract common subjects
    final subjects = <String>{};
    for (final event in events) {
      if (event.metadata?['subject'] != null) {
        subjects.add(event.metadata!['subject']);
      }
    }
    patterns['subjects'] = subjects.toList();

    return patterns;
  }

  String _describePatterns(Map<String, dynamic> patterns) {
    final descriptions = <String>[];

    final eventTypes = patterns['eventTypes'] as Map<EventType, int>?;
    if (eventTypes != null && eventTypes.isNotEmpty) {
      final mostCommon = eventTypes.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      descriptions.add('Frequent ${mostCommon.key.name} events detected');
    }

    final subjects = patterns['subjects'] as List<String>?;
    if (subjects != null && subjects.isNotEmpty) {
      descriptions.add('Focus on ${subjects.join(', ')}');
    }

    return descriptions.join('. ');
  }

  List<String> _extractConcepts(String text) {
    // Simple concept extraction - in production use NLP
    final concepts = <String>[];
    
    // Math concepts
    if (text.toLowerCase().contains('equation')) concepts.add('Equations');
    if (text.toLowerCase().contains('calculus')) concepts.add('Calculus');
    if (text.toLowerCase().contains('algebra')) concepts.add('Algebra');
    
    // Science concepts
    if (text.toLowerCase().contains('physics')) concepts.add('Physics');
    if (text.toLowerCase().contains('chemistry')) concepts.add('Chemistry');
    
    return concepts;
  }

  double _calculateSessionPerformance(
    {required int duration,
    required int todosCompleted,
    required Map<String, dynamic> metrics}
  ) {
    double performance = 0.0;

    // Todo completion rate (40%)
    final expectedTodos = duration / 30; // One todo per 30 minutes
    final todoScore = (todosCompleted / expectedTodos).clamp(0.0, 1.0);
    performance += todoScore * 0.4;

    // Focus score (30%)
    final focusScore = (metrics['focusScore'] ?? 0.7) as double;
    performance += focusScore * 0.3;

    // Productivity score (30%)
    final productivityScore = (metrics['productivity'] ?? 0.7) as double;
    performance += productivityScore * 0.3;

    return performance.clamp(0.0, 1.0);
  }

  String _createSessionText({
    required List<String> subjects,
    required List<String> concepts,
    required int duration,
    required double performance,
  }) {
    return '''
Study session summary:
Subjects: ${subjects.join(', ')}
Concepts: ${concepts.join(', ')}
Duration: $duration minutes
Performance: ${(performance * 100).round()}%
''';
  }

  Future<void> _storeSessionEmbedding({
    required String sessionId,
    required String userId,
    required String sessionText,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await Amplify.API.post(
        '/embeddings',
        apiName: 'aiTutorAPI',
        body: HttpPayload.json({
          'operation': 'storeSessionEmbedding',
          'sessionId': sessionId,
          'userId': userId,
          'text': sessionText,
          'metadata': metadata,
        }),
      ).response;
    } catch (e) {
      safePrint('Error storing session embedding: $e');
    }
  }

  Future<Map<String, dynamic>?> _getTodoDetails(String todoId) async {
    // In production, fetch from repository
    return {
      'id': todoId,
      'title': 'Sample Todo',
      'subject': 'Mathematics',
    };
  }

  Future<List<String>> _generateSessionInsights({
    required List<String> subjects,
    required List<String> concepts,
    required double performance,
    required int duration,
  }) async {
    final insights = <String>[];

    if (performance > 0.8) {
      insights.add('Excellent performance! You mastered ${concepts.join(', ')}');
    } else if (performance < 0.5) {
      insights.add('Consider breaking down ${concepts.join(', ')} into smaller chunks');
    }

    if (duration > 90) {
      insights.add('Long study session - remember to take breaks!');
    }

    return insights;
  }

  void dispose() {
    _aggregationTimer?.cancel();
    _learningEventController.close();
    _insightController.close();
  }
}

// Data models
class LearningContext {
  final String userId;
  final String learningType;
  final int currentLevel;
  final int totalXP;
  final Map<String, dynamic>? statistics;
  final List<dynamic> recentSessions;
  final List<dynamic> activeTodos;
  final List<dynamic> completedTodos;
  final KnowledgeGraph? knowledgeGraph;
  final Map<String, dynamic> patterns;
  final DateTime timestamp;

  LearningContext({
    required this.userId,
    required this.learningType,
    required this.currentLevel,
    required this.totalXP,
    this.statistics,
    required this.recentSessions,
    required this.activeTodos,
    required this.completedTodos,
    this.knowledgeGraph,
    required this.patterns,
    required this.timestamp,
  });
}

class LearningEvent {
  final String userId;
  final EventType type;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  LearningEvent({
    required this.userId,
    required this.type,
    required this.metadata,
    required this.timestamp,
  });
}

enum EventType {
  sessionStarted,
  sessionEnded,
  todoCompleted,
  conceptMastered,
  struggleDetected,
  breakthroughAchieved,
  motivationDrop,
  socialInteraction,
  contentCreated,
}

class FusionInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final bool actionable;
  final String priority;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  FusionInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actionable,
    required this.priority,
    required this.data,
    required this.timestamp,
  });
}

enum InsightType {
  performance,
  pattern,
  recommendation,
  warning,
  achievement,
}

class SessionFusionData {
  final String sessionId;
  final List<String> subjects;
  final List<String> concepts;
  final double performance;
  final List<String> insights;

  SessionFusionData({
    required this.sessionId,
    required this.subjects,
    required this.concepts,
    required this.performance,
    required this.insights,
  });
}

class NextActionPrediction {
  final ActionRecommendation recommendedAction;
  final List<ActionRecommendation> alternatives;
  final double confidence;
  final String reasoning;

  NextActionPrediction({
    required this.recommendedAction,
    required this.alternatives,
    required this.confidence,
    required this.reasoning,
  });
}

class ActionRecommendation {
  final String action;
  final String subject;
  final int estimatedDuration;
  final double expectedValue;
  final Map<String, dynamic> metadata;

  ActionRecommendation({
    required this.action,
    required this.subject,
    required this.estimatedDuration,
    required this.expectedValue,
    required this.metadata,
  });
}

class MultiModalAnalysis {
  final Duration timeWindow;
  final Map<String, dynamic> modalityData;
  final Map<String, dynamic> crossModalPatterns;
  final List<String> unifiedInsights;
  final List<ActionRecommendation> recommendations;

  MultiModalAnalysis({
    required this.timeWindow,
    required this.modalityData,
    required this.crossModalPatterns,
    required this.unifiedInsights,
    required this.recommendations,
  });
}

// Additional helper methods would be implemented here...
extension on double {
  double sqrt() => 0.0; // Placeholder - use dart:math
}