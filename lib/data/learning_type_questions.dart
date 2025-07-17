import '../models/learning_type_models.dart';

class LearningTypeQuestions {
  static const List<TestQuestion> questions = [
    // Planning Dimension - Question 1
    TestQuestion(
      id: 1,
      question: '새로운 과목을 배우게 되었을 때, 당신의 첫 번째 행동은?',
      situation: '📚 새 학기가 시작되고 처음 보는 과목이 생겼습니다.',
      dimension: TestDimension.planning,
      answers: [
        TestAnswer(
          id: 'q1a1',
          text: '전체 커리큘럼을 확인하고 학습 계획을 세운다',
          value: PlanningType.planned,
          score: 2,
        ),
        TestAnswer(
          id: 'q1a2',
          text: '일단 첫 번째 챕터부터 시작해본다',
          value: PlanningType.spontaneous,
          score: 2,
        ),
        TestAnswer(
          id: 'q1a3',
          text: '관심 있는 부분부터 먼저 살펴본다',
          value: PlanningType.spontaneous,
          score: 1,
        ),
        TestAnswer(
          id: 'q1a4',
          text: '학습 목표를 정하고 단계별로 준비한다',
          value: PlanningType.planned,
          score: 1,
        ),
      ],
    ),
    
    // Planning Dimension - Question 2
    TestQuestion(
      id: 2,
      question: '시험 준비를 할 때, 당신이 선호하는 방식은?',
      situation: '📝 중요한 시험이 한 달 후로 다가왔습니다.',
      dimension: TestDimension.planning,
      answers: [
        TestAnswer(
          id: 'q2a1',
          text: '30일 계획표를 만들어 매일 정해진 분량을 공부한다',
          value: PlanningType.planned,
          score: 2,
        ),
        TestAnswer(
          id: 'q2a2',
          text: '시험 날짜에 맞춰 역산으로 계획을 세운다',
          value: PlanningType.planned,
          score: 1,
        ),
        TestAnswer(
          id: 'q2a3',
          text: '그때그때 컨디션에 따라 유연하게 공부한다',
          value: PlanningType.spontaneous,
          score: 1,
        ),
        TestAnswer(
          id: 'q2a4',
          text: '마감 압박이 있을 때 더 집중이 잘 된다',
          value: PlanningType.spontaneous,
          score: 2,
        ),
      ],
    ),
    
    // Social Dimension - Question 1
    TestQuestion(
      id: 3,
      question: '어려운 문제를 만났을 때, 당신의 해결 방식은?',
      situation: '🤔 수학 문제가 너무 어려워서 한 시간째 고민하고 있습니다.',
      dimension: TestDimension.social,
      answers: [
        TestAnswer(
          id: 'q3a1',
          text: '친구나 선생님에게 도움을 요청한다',
          value: SocialType.group,
          score: 2,
        ),
        TestAnswer(
          id: 'q3a2',
          text: '스터디 그룹에서 함께 풀어본다',
          value: SocialType.group,
          score: 1,
        ),
        TestAnswer(
          id: 'q3a3',
          text: '혼자서 다양한 방법을 시도해본다',
          value: SocialType.individual,
          score: 2,
        ),
        TestAnswer(
          id: 'q3a4',
          text: '참고서나 인터넷을 검색해서 혼자 해결한다',
          value: SocialType.individual,
          score: 1,
        ),
      ],
    ),
    
    // Social Dimension - Question 2
    TestQuestion(
      id: 4,
      question: '새로운 개념을 학습할 때, 가장 효과적인 방법은?',
      situation: '💡 복잡한 새로운 개념을 이해해야 합니다.',
      dimension: TestDimension.social,
      answers: [
        TestAnswer(
          id: 'q4a1',
          text: '혼자 충분한 시간을 가지고 깊이 생각한다',
          value: SocialType.individual,
          score: 2,
        ),
        TestAnswer(
          id: 'q4a2',
          text: '조용한 곳에서 집중해서 이해한다',
          value: SocialType.individual,
          score: 1,
        ),
        TestAnswer(
          id: 'q4a3',
          text: '다른 사람들과 토론하며 이해한다',
          value: SocialType.group,
          score: 2,
        ),
        TestAnswer(
          id: 'q4a4',
          text: '친구에게 설명해보며 이해를 확인한다',
          value: SocialType.group,
          score: 1,
        ),
      ],
    ),
    
    // Processing Dimension - Question 1
    TestQuestion(
      id: 5,
      question: '강의를 들을 때, 당신이 더 집중하는 부분은?',
      situation: '🎓 교수님이 중요한 내용을 설명하고 있습니다.',
      dimension: TestDimension.processing,
      answers: [
        TestAnswer(
          id: 'q5a1',
          text: '칠판에 적힌 내용이나 PPT 슬라이드',
          value: ProcessingType.visual,
          score: 2,
        ),
        TestAnswer(
          id: 'q5a2',
          text: '교수님의 설명과 목소리 톤',
          value: ProcessingType.auditory,
          score: 2,
        ),
        TestAnswer(
          id: 'q5a3',
          text: '다이어그램이나 그래프 같은 시각적 자료',
          value: ProcessingType.visual,
          score: 1,
        ),
        TestAnswer(
          id: 'q5a4',
          text: '교수님이 강조하는 키워드나 억양',
          value: ProcessingType.auditory,
          score: 1,
        ),
      ],
    ),
    
    // Processing Dimension - Question 2
    TestQuestion(
      id: 6,
      question: '복잡한 내용을 암기할 때, 어떤 방법이 더 효과적인가요?',
      situation: '📖 외워야 할 내용이 너무 많고 복잡합니다.',
      dimension: TestDimension.processing,
      answers: [
        TestAnswer(
          id: 'q6a1',
          text: '마인드맵이나 도표로 정리해서 외운다',
          value: ProcessingType.visual,
          score: 2,
        ),
        TestAnswer(
          id: 'q6a2',
          text: '색깔별로 구분해서 시각적으로 정리한다',
          value: ProcessingType.visual,
          score: 1,
        ),
        TestAnswer(
          id: 'q6a3',
          text: '소리 내어 읽으면서 반복한다',
          value: ProcessingType.auditory,
          score: 2,
        ),
        TestAnswer(
          id: 'q6a4',
          text: '리듬이나 멜로디를 붙여서 외운다',
          value: ProcessingType.auditory,
          score: 1,
        ),
      ],
    ),
    
    // Approach Dimension - Question 1
    TestQuestion(
      id: 7,
      question: '새로운 기술을 배울 때, 당신이 선호하는 접근법은?',
      situation: '💻 새로운 프로그래밍 언어를 배워야 합니다.',
      dimension: TestDimension.approach,
      answers: [
        TestAnswer(
          id: 'q7a1',
          text: '기본 문법과 개념부터 차근차근 배운다',
          value: ApproachType.theoretical,
          score: 2,
        ),
        TestAnswer(
          id: 'q7a2',
          text: '이론적 배경을 충분히 이해한 후 실습한다',
          value: ApproachType.theoretical,
          score: 1,
        ),
        TestAnswer(
          id: 'q7a3',
          text: '간단한 프로젝트부터 만들어보며 배운다',
          value: ApproachType.practical,
          score: 2,
        ),
        TestAnswer(
          id: 'q7a4',
          text: '실무에 바로 적용할 수 있는 부분부터 배운다',
          value: ApproachType.practical,
          score: 1,
        ),
      ],
    ),
    
    // Approach Dimension - Question 2
    TestQuestion(
      id: 8,
      question: '학습의 목표를 설정할 때, 당신이 중요하게 생각하는 것은?',
      situation: '🎯 새로운 학습 목표를 설정해야 합니다.',
      dimension: TestDimension.approach,
      answers: [
        TestAnswer(
          id: 'q8a1',
          text: '깊이 있는 지식과 원리 이해',
          value: ApproachType.theoretical,
          score: 2,
        ),
        TestAnswer(
          id: 'q8a2',
          text: '체계적이고 논리적인 사고력 향상',
          value: ApproachType.theoretical,
          score: 1,
        ),
        TestAnswer(
          id: 'q8a3',
          text: '실무에 바로 적용할 수 있는 능력',
          value: ApproachType.practical,
          score: 2,
        ),
        TestAnswer(
          id: 'q8a4',
          text: '문제 해결 능력과 실행력',
          value: ApproachType.practical,
          score: 1,
        ),
      ],
    ),
  ];
  
  static List<TestQuestion> getQuestionsByDimension(TestDimension dimension) {
    return questions.where((q) => q.dimension == dimension).toList();
  }
  
  static TestQuestion getQuestionById(int id) {
    return questions.firstWhere((q) => q.id == id);
  }
}