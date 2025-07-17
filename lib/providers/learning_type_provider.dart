import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_type_models.dart';
import '../data/learning_type_questions.dart';
import '../services/local_storage_service.dart';

// Test State
class TestState {
  final int currentQuestionIndex;
  final Map<int, String> answers; // questionId -> answerId
  final bool isCompleted;
  final TestResult? result;
  final bool isLoading;
  
  const TestState({
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.isCompleted = false,
    this.result,
    this.isLoading = false,
  });
  
  TestState copyWith({
    int? currentQuestionIndex,
    Map<int, String>? answers,
    bool? isCompleted,
    TestResult? result,
    bool? isLoading,
  }) {
    return TestState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  double get progress => 
    LearningTypeQuestions.questions.isEmpty ? 0.0 : 
    (currentQuestionIndex / LearningTypeQuestions.questions.length);
}

// Learning Type Test Provider
final learningTypeTestProvider = StateNotifierProvider<LearningTypeTestNotifier, TestState>((ref) {
  return LearningTypeTestNotifier();
});

class LearningTypeTestNotifier extends StateNotifier<TestState> {
  LearningTypeTestNotifier() : super(const TestState()) {
    _loadSavedResult();
  }
  
  void _loadSavedResult() {
    final savedResult = _loadTestResultFromStorage();
    if (savedResult != null) {
      state = state.copyWith(
        isCompleted: true,
        result: savedResult,
      );
    }
  }
  
  void startTest() {
    state = const TestState(
      currentQuestionIndex: 0,
      answers: {},
      isCompleted: false,
      result: null,
    );
  }
  
  void answerQuestion(int questionId, String answerId) {
    final newAnswers = Map<int, String>.from(state.answers);
    newAnswers[questionId] = answerId;
    
    state = state.copyWith(answers: newAnswers);
    
    // Auto-advance to next question
    if (state.currentQuestionIndex < LearningTypeQuestions.questions.length - 1) {
      nextQuestion();
    } else {
      // Test completed
      _calculateResult();
    }
  }
  
  void nextQuestion() {
    if (state.currentQuestionIndex < LearningTypeQuestions.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }
  
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }
  
  void _calculateResult() {
    state = state.copyWith(isLoading: true);
    
    // Calculate scores for each dimension
    final Map<TestDimension, int> dimensionScores = {
      TestDimension.planning: 0,
      TestDimension.social: 0,
      TestDimension.processing: 0,
      TestDimension.approach: 0,
    };
    
    // Count preference scores
    final Map<TestDimension, Map<dynamic, int>> preferenceScores = {
      TestDimension.planning: {PlanningType.planned: 0, PlanningType.spontaneous: 0},
      TestDimension.social: {SocialType.individual: 0, SocialType.group: 0},
      TestDimension.processing: {ProcessingType.visual: 0, ProcessingType.auditory: 0},
      TestDimension.approach: {ApproachType.theoretical: 0, ApproachType.practical: 0},
    };
    
    // Process each answer
    for (final questionId in state.answers.keys) {
      final answerId = state.answers[questionId]!;
      final question = LearningTypeQuestions.getQuestionById(questionId);
      final answer = question.answers.firstWhere((a) => a.id == answerId);
      
      // Add score to dimension total
      dimensionScores[question.dimension] = 
        (dimensionScores[question.dimension] ?? 0) + answer.score;
      
      // Add score to preference
      preferenceScores[question.dimension]![answer.value] = 
        (preferenceScores[question.dimension]![answer.value] ?? 0) + answer.score;
    }
    
    // Determine preferences for each dimension
    final planning = preferenceScores[TestDimension.planning]![PlanningType.planned]! >= 
                    preferenceScores[TestDimension.planning]![PlanningType.spontaneous]!
                    ? PlanningType.planned : PlanningType.spontaneous;
    
    final social = preferenceScores[TestDimension.social]![SocialType.individual]! >= 
                  preferenceScores[TestDimension.social]![SocialType.group]!
                  ? SocialType.individual : SocialType.group;
    
    final processing = preferenceScores[TestDimension.processing]![ProcessingType.visual]! >= 
                      preferenceScores[TestDimension.processing]![ProcessingType.auditory]!
                      ? ProcessingType.visual : ProcessingType.auditory;
    
    final approach = preferenceScores[TestDimension.approach]![ApproachType.theoretical]! >= 
                    preferenceScores[TestDimension.approach]![ApproachType.practical]!
                    ? ApproachType.theoretical : ApproachType.practical;
    
    // Find matching learning type
    final learningType = LearningTypes.findByDimensions(
      planning: planning,
      social: social,
      processing: processing,
      approach: approach,
    );
    
    final result = TestResult(
      planning: planning,
      social: social,
      processing: processing,
      approach: approach,
      learningType: learningType,
      scores: dimensionScores,
      completedAt: DateTime.now(),
    );
    
    // Save result
    _saveTestResultToStorage(result);
    
    state = state.copyWith(
      isCompleted: true,
      result: result,
      isLoading: false,
    );
  }
  
  void retakeTest() {
    _clearTestResultFromStorage();
    startTest();
  }
  
  TestQuestion get currentQuestion => 
    LearningTypeQuestions.questions[state.currentQuestionIndex];
  
  bool get canGoNext => 
    state.currentQuestionIndex < LearningTypeQuestions.questions.length - 1;
  
  bool get canGoPrevious => state.currentQuestionIndex > 0;
  
  bool get hasAnsweredCurrent => 
    state.answers.containsKey(currentQuestion.id);
  
  String? get currentAnswer => 
    state.answers[currentQuestion.id];
  
  // Local Storage Methods
  void _saveTestResultToStorage(TestResult result) {
    try {
      final json = {
        'planning': result.planning.name,
        'social': result.social.name,
        'processing': result.processing.name,
        'approach': result.approach.name,
        'learningTypeId': result.learningType.id,
        'scores': result.scores.map((key, value) => MapEntry(key.name, value)),
        'completedAt': result.completedAt.toIso8601String(),
      };
      
      LocalStorageService.prefs.setString('learning_type_result', 
        json.toString().replaceAll('{', '').replaceAll('}', ''));
    } catch (e) {
      print('Error saving test result: $e');
    }
  }
  
  TestResult? _loadTestResultFromStorage() {
    try {
      final resultString = LocalStorageService.prefs.getString('learning_type_result');
      if (resultString == null) return null;
      
      // This is a simplified version - in real app, use proper JSON parsing
      // For now, we'll just return null to force retaking the test
      return null;
    } catch (e) {
      print('Error loading test result: $e');
      return null;
    }
  }
  
  void _clearTestResultFromStorage() {
    try {
      LocalStorageService.prefs.remove('learning_type_result');
    } catch (e) {
      print('Error clearing test result: $e');
    }
  }
}

// Current Learning Type Provider (for completed users)
final currentLearningTypeProvider = Provider<LearningType?>((ref) {
  final testState = ref.watch(learningTypeTestProvider);
  return testState.result?.learningType;
});

// Learning Type Recommendations Provider
final learningTypeRecommendationsProvider = Provider<List<String>>((ref) {
  final learningType = ref.watch(currentLearningTypeProvider);
  return learningType?.studyTips ?? [];
});