import 'dart:async';
import 'dart:math';

class LocalAISimulationService {
  static final _random = Random();
  
  // Simulate AI tutor responses
  static Future<String> getAITutorResponse(String question) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    final responses = [
      '좋은 질문이에요! 이 문제를 단계별로 살펴볼까요?\n\n1. 먼저 주어진 조건을 정리해보면...\n2. 다음으로 핵심 개념을 적용하면...\n3. 따라서 답은...\n\n이해가 되셨나요? 추가 설명이 필요하면 말씀해주세요!',
      '이 개념을 이해하는 좋은 방법이 있어요!\n\n예를 들어, 일상생활에서...\n이와 비슷하게, 이 문제에서도...\n\n한번 직접 연습해보시겠어요?',
      '훌륭한 시도예요! 조금만 수정하면 될 것 같아요.\n\n여기서 주의할 점은:\n- 첫 번째로...\n- 두 번째로...\n\n다시 한번 도전해보세요!',
      '정답입니다! 🎉\n\n특히 이 부분을 잘 이해하신 것 같아요:\n- ${question.substring(0, min(20, question.length))}...\n\n다음 단계로 더 어려운 문제도 도전해보시겠어요?',
    ];
    
    return responses[_random.nextInt(responses.length)];
  }
  
  // Simulate learning recommendations
  static Future<List<String>> getLearningRecommendations(String subject) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final recommendations = {
      'Math': [
        '기초 대수학 개념 복습하기',
        '매일 10문제씩 문제 풀이 연습',
        '공식 암기보다 원리 이해에 집중',
        '실생활 예제로 응용력 기르기',
      ],
      'English': [
        '매일 영어 일기 쓰기 (5문장)',
        '좋아하는 영어 콘텐츠 시청하기',
        '새로운 단어 5개씩 학습하고 문장 만들기',
        '원어민 발음 따라하기 연습',
      ],
      'Science': [
        '실험 영상 보며 과학 원리 이해하기',
        '일상에서 과학 현상 찾아보기',
        '핵심 용어 정리 노트 만들기',
        '그림으로 개념 시각화하기',
      ],
      'default': [
        '매일 30분씩 꾸준히 학습하기',
        '학습 내용을 요약 정리하기',
        '친구와 함께 토론하며 학습하기',
        '정기적으로 복습 시간 갖기',
      ],
    };
    
    return recommendations[subject] ?? recommendations['default']!;
  }
  
  // Simulate performance analysis
  static Future<Map<String, dynamic>> analyzePerformance(Map<String, int> subjectStats) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Find strongest and weakest subjects
    String? strongestSubject;
    String? weakestSubject;
    int maxTime = 0;
    int minTime = 999999;
    
    subjectStats.forEach((subject, time) {
      if (time > maxTime) {
        maxTime = time;
        strongestSubject = subject;
      }
      if (time < minTime && time > 0) {
        minTime = time;
        weakestSubject = subject;
      }
    });
    
    return {
      'strongestSubject': strongestSubject ?? 'None',
      'weakestSubject': weakestSubject ?? 'None',
      'totalStudyTime': subjectStats.values.fold(0, (sum, time) => sum + time),
      'averageSessionTime': subjectStats.isEmpty ? 0 : 
        subjectStats.values.fold(0, (sum, time) => sum + time) ~/ subjectStats.length,
      'insights': [
        if (strongestSubject != null) '$strongestSubject 과목에 가장 많은 시간을 투자하고 있어요!',
        if (weakestSubject != null) '$weakestSubject 과목도 조금 더 관심을 가져보는 건 어떨까요?',
        '꾸준한 학습 습관을 유지하고 계시네요. 훌륭해요!',
        '다양한 학습 방법을 시도해보면 더 효과적일 거예요.',
      ],
      'suggestions': _generateSuggestions(subjectStats),
    };
  }
  
  // Simulate mistake pattern analysis
  static Future<List<MistakePattern>> analyzeMistakes(String subject) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    final patterns = {
      'Math': [
        MistakePattern(
          type: '계산 실수',
          frequency: 0.3,
          description: '간단한 연산에서 자주 실수가 발생합니다',
          solution: '천천히 계산하고 검산하는 습관을 들이세요',
        ),
        MistakePattern(
          type: '공식 적용 오류',
          frequency: 0.2,
          description: '공식을 잘못 적용하는 경우가 있습니다',
          solution: '공식의 원리를 이해하고 조건을 확인하세요',
        ),
      ],
      'English': [
        MistakePattern(
          type: '시제 오류',
          frequency: 0.4,
          description: '동사 시제를 혼동하는 경우가 많습니다',
          solution: '시간 표현과 함께 시제를 연습하세요',
        ),
        MistakePattern(
          type: '전치사 사용',
          frequency: 0.3,
          description: '적절한 전치사 선택에 어려움이 있습니다',
          solution: '전치사와 함께 쓰이는 표현을 통째로 암기하세요',
        ),
      ],
    };
    
    return patterns[subject] ?? [
      MistakePattern(
        type: '일반적인 실수',
        frequency: 0.25,
        description: '주의력 부족으로 인한 실수가 있습니다',
        solution: '문제를 꼼꼼히 읽고 차분히 풀어보세요',
      ),
    ];
  }
  
  // Simulate study plan generation
  static Future<StudyPlan> generateStudyPlan(String learningType, List<String> subjects) async {
    await Future.delayed(const Duration(milliseconds: 900));
    
    final now = DateTime.now();
    final sessions = <StudySessionPlan>[];
    
    // Generate weekly study sessions
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final daySubjects = subjects.take(2 + (i % 2)).toList();
      
      for (int j = 0; j < daySubjects.length; j++) {
        sessions.add(StudySessionPlan(
          date: date,
          subject: daySubjects[j],
          duration: 25 + _random.nextInt(20), // 25-45 minutes
          time: '${14 + j * 2}:00', // 2PM, 4PM, etc.
          focus: _getFocusArea(daySubjects[j]),
        ));
      }
    }
    
    return StudyPlan(
      title: '$learningType 맞춤형 주간 학습 계획',
      description: '당신의 학습 스타일에 최적화된 계획입니다',
      sessions: sessions,
      tips: _getStudyTips(learningType),
    );
  }
  
  // Simulate flashcard generation from notes
  static Future<List<Map<String, String>>> generateFlashcardsFromNote(String content) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Simple simulation: extract sentences and create Q&A pairs
    final sentences = content.split('. ').where((s) => s.length > 20).toList();
    final flashcards = <Map<String, String>>[];
    
    for (int i = 0; i < min(5, sentences.length); i++) {
      final sentence = sentences[i];
      flashcards.add({
        'front': '다음을 설명하세요: ${sentence.substring(0, min(30, sentence.length))}...',
        'back': sentence,
      });
    }
    
    // Add some generic cards if not enough content
    if (flashcards.length < 3) {
      flashcards.addAll([
        {
          'front': '이 노트의 핵심 내용은 무엇인가요?',
          'back': content.substring(0, min(100, content.length)) + '...',
        },
        {
          'front': '이 주제에서 가장 중요한 개념은?',
          'back': '노트를 다시 읽고 핵심 개념을 정리해보세요.',
        },
      ]);
    }
    
    return flashcards;
  }
  
  // Helper methods
  static List<String> _generateSuggestions(Map<String, int> subjectStats) {
    final suggestions = <String>[];
    
    if (subjectStats.isEmpty) {
      suggestions.add('학습을 시작해보세요! 작은 목표부터 설정하면 좋아요.');
    } else {
      suggestions.add('매일 조금씩이라도 꾸준히 학습하는 것이 중요해요.');
      suggestions.add('다양한 과목을 균형있게 학습해보세요.');
      suggestions.add('학습 후에는 꼭 복습 시간을 가지세요.');
    }
    
    return suggestions;
  }
  
  static String _getFocusArea(String subject) {
    final focusAreas = {
      'Math': ['문제 풀이', '개념 이해', '공식 암기', '응용 문제'],
      'English': ['단어 암기', '문법 연습', '독해 연습', '작문 연습'],
      'Science': ['이론 학습', '실험 이해', '용어 정리', '현상 분석'],
    };
    
    final areas = focusAreas[subject] ?? ['기본 개념', '문제 연습', '복습'];
    return areas[_random.nextInt(areas.length)];
  }
  
  static List<String> _getStudyTips(String learningType) {
    return [
      '짧은 휴식을 자주 가지며 집중력을 유지하세요',
      '학습 내용을 다른 사람에게 설명해보세요',
      '시각적 자료를 활용하면 기억에 도움이 됩니다',
      '실제 예제와 연결지어 생각해보세요',
    ];
  }
}

// Models for AI simulation
class MistakePattern {
  final String type;
  final double frequency;
  final String description;
  final String solution;
  
  MistakePattern({
    required this.type,
    required this.frequency,
    required this.description,
    required this.solution,
  });
}

class StudyPlan {
  final String title;
  final String description;
  final List<StudySessionPlan> sessions;
  final List<String> tips;
  
  StudyPlan({
    required this.title,
    required this.description,
    required this.sessions,
    required this.tips,
  });
}

class StudySessionPlan {
  final DateTime date;
  final String subject;
  final int duration;
  final String time;
  final String focus;
  
  StudySessionPlan({
    required this.date,
    required this.subject,
    required this.duration,
    required this.time,
    required this.focus,
  });
}