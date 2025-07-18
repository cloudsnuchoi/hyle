// Learning Type Models for 16 unique learning types
class LearningType {
  final String id;
  final String name;
  final String description;
  final String character;
  final String emoji;
  final PlanningType planning;
  final SocialType social;
  final ProcessingType processing;
  final ApproachType approach;
  final List<String> studyTips;
  final List<String> strengths;
  final List<String> challenges;
  final String motivationalQuote;
  final String colorScheme;
  
  const LearningType({
    required this.id,
    required this.name,
    required this.description,
    required this.character,
    required this.emoji,
    required this.planning,
    required this.social,
    required this.processing,
    required this.approach,
    required this.studyTips,
    required this.strengths,
    required this.challenges,
    required this.motivationalQuote,
    required this.colorScheme,
  });
  
  String getTitle() => '$emoji $name';
  String getDescription() => description;
}

// 4 Dimensions
enum PlanningType { 
  planned, // P - 계획적
  spontaneous // S - 즉흥적
}

enum SocialType { 
  individual, // I - 개인형
  group // G - 그룹형
}

enum ProcessingType { 
  visual, // V - 시각형
  auditory // A - 청각형
}

enum ApproachType { 
  theoretical, // T - 이론형
  practical // P - 실무형
}

// Test Question Model
class TestQuestion {
  final int id;
  final String question;
  final String situation;
  final List<TestAnswer> answers;
  final TestDimension dimension;
  
  const TestQuestion({
    required this.id,
    required this.question,
    required this.situation,
    required this.answers,
    required this.dimension,
  });
}

class TestAnswer {
  final String id;
  final String text;
  final dynamic value; // PlanningType, SocialType, ProcessingType, ApproachType
  final int score;
  
  const TestAnswer({
    required this.id,
    required this.text,
    required this.value,
    required this.score,
  });
}

enum TestDimension { planning, social, processing, approach }

// Test Result Model
class TestResult {
  final PlanningType planning;
  final SocialType social;
  final ProcessingType processing;
  final ApproachType approach;
  final LearningType learningType;
  final Map<TestDimension, int> scores;
  final DateTime completedAt;
  
  const TestResult({
    required this.planning,
    required this.social,
    required this.processing,
    required this.approach,
    required this.learningType,
    required this.scores,
    required this.completedAt,
  });
  
  String get typeCode {
    final p = planning == PlanningType.planned ? 'P' : 'S';
    final s = social == SocialType.individual ? 'I' : 'G';
    final proc = processing == ProcessingType.visual ? 'V' : 'A';
    final app = approach == ApproachType.theoretical ? 'T' : 'P';
    return '$p$s$proc$app';
  }
}

// Learning Type Constants
class LearningTypes {
  static const List<LearningType> all = [
    // PIVT - 계획적 개인 시각 이론형
    LearningType(
      id: 'PIVT',
      name: '체계적 분석가',
      description: '계획적이고 분석적인 학습을 선호하며, 혼자서 이론을 깊이 탐구하는 것을 좋아합니다.',
      character: '🧠',
      emoji: '📊',
      planning: PlanningType.planned,
      social: SocialType.individual,
      processing: ProcessingType.visual,
      approach: ApproachType.theoretical,
      studyTips: [
        '상세한 학습 계획을 세우고 단계별로 진행하세요',
        '다이어그램과 차트를 활용한 시각적 학습',
        '조용한 개인 공간에서 집중 학습',
        '이론적 배경을 충분히 이해한 후 응용'
      ],
      strengths: ['체계적 사고', '깊이 있는 분석', '꼼꼼한 준비'],
      challenges: ['융통성 부족', '실무 적용 어려움', '즉흥적 상황 대응'],
      motivationalQuote: '계획 없는 목표는 단지 소망일 뿐이다.',
      colorScheme: 'blue',
    ),
    
    // PIVP - 계획적 개인 시각 실무형
    LearningType(
      id: 'PIVP',
      name: '실무형 기획자',
      description: '계획적이면서도 실무에 바로 적용할 수 있는 지식을 선호하는 실용적 학습자입니다.',
      character: '🛠️',
      emoji: '📋',
      planning: PlanningType.planned,
      social: SocialType.individual,
      processing: ProcessingType.visual,
      approach: ApproachType.practical,
      studyTips: [
        '학습 목표를 구체적인 성과물로 설정',
        '실습과 프로젝트 중심의 학습',
        '시각적 자료와 예시를 활용',
        '단계별 체크리스트로 진행 관리'
      ],
      strengths: ['실무 중심 사고', '체계적 실행', '목표 지향적'],
      challenges: ['이론적 깊이 부족', '창의적 발상 한계', '변화 적응 어려움'],
      motivationalQuote: '실행이 없는 계획은 무용지물이다.',
      colorScheme: 'green',
    ),
    
    // PIAT - 계획적 개인 청각 이론형
    LearningType(
      id: 'PIAT',
      name: '사색하는 이론가',
      description: '조용히 혼자서 이론을 깊이 탐구하며, 듣고 말하는 것을 통해 학습하는 것을 선호합니다.',
      character: '🤔',
      emoji: '🎧',
      planning: PlanningType.planned,
      social: SocialType.individual,
      processing: ProcessingType.auditory,
      approach: ApproachType.theoretical,
      studyTips: [
        '강의나 오디오북을 활용한 학습',
        '자신만의 속도로 반복 학습',
        '중요한 내용을 소리 내어 읽기',
        '이론적 배경을 체계적으로 정리'
      ],
      strengths: ['깊이 있는 사고', '논리적 분석', '집중력'],
      challenges: ['실무 적용 어려움', '소통 부족', '시각적 정보 처리 약함'],
      motivationalQuote: '지식은 힘이다. 하지만 적용된 지식이 진짜 힘이다.',
      colorScheme: 'purple',
    ),
    
    // PIAP - 계획적 개인 청각 실무형
    LearningType(
      id: 'PIAP',
      name: '실용적 청취자',
      description: '체계적으로 계획하되 실무에 바로 적용할 수 있는 지식을 청각적으로 습득하는 학습자입니다.',
      character: '🎯',
      emoji: '📻',
      planning: PlanningType.planned,
      social: SocialType.individual,
      processing: ProcessingType.auditory,
      approach: ApproachType.practical,
      studyTips: [
        '팟캐스트나 강의를 들으며 학습',
        '실무 사례 중심의 내용 선택',
        '학습한 내용을 즉시 적용해보기',
        '음성 녹음으로 중요 내용 정리'
      ],
      strengths: ['실무 적용력', '체계적 접근', '청취 능력'],
      challenges: ['이론적 깊이 부족', '시각적 학습 약함', '창의성 부족'],
      motivationalQuote: '듣고 실행하는 자가 성공한다.',
      colorScheme: 'orange',
    ),
    
    // PGVT - 계획적 그룹 시각 이론형
    LearningType(
      id: 'PGVT',
      name: '협력적 연구자',
      description: '팀과 함께 체계적으로 이론을 탐구하며, 시각적 자료를 활용한 깊이 있는 학습을 선호합니다.',
      character: '👥',
      emoji: '📚',
      planning: PlanningType.planned,
      social: SocialType.group,
      processing: ProcessingType.visual,
      approach: ApproachType.theoretical,
      studyTips: [
        '스터디 그룹을 조직하여 체계적 학습',
        '화이트보드나 차트를 활용한 토론',
        '역할 분담으로 심화 연구',
        '이론적 토론과 분석을 통한 이해'
      ],
      strengths: ['협업 능력', '체계적 사고', '깊이 있는 분석'],
      challenges: ['개인 학습 시간 부족', '실무 적용 어려움', '의견 조율 어려움'],
      motivationalQuote: '혼자 가면 빨리 가지만, 함께 가면 멀리 간다.',
      colorScheme: 'indigo',
    ),
    
    // PGVP - 계획적 그룹 시각 실무형
    LearningType(
      id: 'PGVP',
      name: '팀 프로젝트 리더',
      description: '팀과 함께 체계적으로 프로젝트를 진행하며, 시각적 자료를 활용한 실무 중심 학습을 선호합니다.',
      character: '👨‍💼',
      emoji: '📊',
      planning: PlanningType.planned,
      social: SocialType.group,
      processing: ProcessingType.visual,
      approach: ApproachType.practical,
      studyTips: [
        '프로젝트 기반 팀 학습',
        '시각적 자료를 활용한 발표와 토론',
        '실무 사례 중심의 그룹 스터디',
        '단계별 목표 설정과 성과 측정'
      ],
      strengths: ['리더십', '실무 적용력', '팀워크'],
      challenges: ['이론적 깊이 부족', '개인 성찰 시간 부족', '완벽주의 경향'],
      motivationalQuote: '팀워크는 평범한 사람들이 비범한 결과를 만든다.',
      colorScheme: 'teal',
    ),
    
    // PGAT - 계획적 그룹 청각 이론형
    LearningType(
      id: 'PGAT',
      name: '토론하는 학자',
      description: '체계적인 토론과 대화를 통해 이론을 깊이 탐구하며, 청각적 학습을 선호하는 학습자입니다.',
      character: '🗣️',
      emoji: '💬',
      planning: PlanningType.planned,
      social: SocialType.group,
      processing: ProcessingType.auditory,
      approach: ApproachType.theoretical,
      studyTips: [
        '토론 중심의 스터디 그룹 참여',
        '서로 가르치고 배우는 학습법',
        '이론적 주제로 깊이 있는 대화',
        '체계적인 발표와 질의응답'
      ],
      strengths: ['토론 능력', '깊이 있는 사고', '협업 능력'],
      challenges: ['실무 적용 어려움', '시각적 정보 처리 약함', '개인 학습 시간 부족'],
      motivationalQuote: '진정한 학습은 대화에서 시작된다.',
      colorScheme: 'pink',
    ),
    
    // PGAP - 계획적 그룹 청각 실무형
    LearningType(
      id: 'PGAP',
      name: '실무 협력자',
      description: '팀과 함께 실무 중심의 학습을 하며, 대화와 토론을 통해 실질적인 지식을 습득하는 학습자입니다.',
      character: '🤝',
      emoji: '🎙️',
      planning: PlanningType.planned,
      social: SocialType.group,
      processing: ProcessingType.auditory,
      approach: ApproachType.practical,
      studyTips: [
        '실무 사례 중심의 그룹 토론',
        '역할극이나 시뮬레이션 활용',
        '경험 공유와 피드백 중심 학습',
        '실제 프로젝트를 통한 협업 학습'
      ],
      strengths: ['실무 적용력', '협업 능력', '소통 능력'],
      challenges: ['이론적 깊이 부족', '개인 성찰 부족', '시각적 학습 약함'],
      motivationalQuote: '실무는 혼자가 아닌 함께 할 때 완성된다.',
      colorScheme: 'amber',
    ),
    
    // SIVT - 즉흥적 개인 시각 이론형
    LearningType(
      id: 'SIVT',
      name: '자유로운 탐험가',
      description: '자신의 호기심을 따라 자유롭게 이론을 탐구하며, 시각적 자료를 통해 깊이 있게 학습하는 학습자입니다.',
      character: '🔍',
      emoji: '🌟',
      planning: PlanningType.spontaneous,
      social: SocialType.individual,
      processing: ProcessingType.visual,
      approach: ApproachType.theoretical,
      studyTips: [
        '호기심을 따라 자유롭게 탐구',
        '다양한 시각적 자료와 참고서 활용',
        '관심 분야를 깊이 파고들기',
        '유연한 학습 스케줄 유지'
      ],
      strengths: ['창의적 사고', '깊이 있는 탐구', '자기주도 학습'],
      challenges: ['체계성 부족', '실무 적용 어려움', '일관성 부족'],
      motivationalQuote: '호기심은 학습의 엔진이다.',
      colorScheme: 'cyan',
    ),
    
    // SIVP - 즉흥적 개인 시각 실무형
    LearningType(
      id: 'SIVP',
      name: '창의적 실무자',
      description: '즉흥적이면서도 실무에 바로 적용할 수 있는 지식을 시각적으로 습득하는 창의적 학습자입니다.',
      character: '🎨',
      emoji: '💡',
      planning: PlanningType.spontaneous,
      social: SocialType.individual,
      processing: ProcessingType.visual,
      approach: ApproachType.practical,
      studyTips: [
        '프로젝트 기반의 자유로운 학습',
        '시각적 자료와 예시를 많이 활용',
        '즉흥적 아이디어를 바로 실행',
        '다양한 도구와 기법 실험'
      ],
      strengths: ['창의성', '실무 적용력', '유연성'],
      challenges: ['체계성 부족', '깊이 있는 학습 어려움', '일관성 부족'],
      motivationalQuote: '창의성은 제약 속에서 꽃핀다.',
      colorScheme: 'lime',
    ),
    
    // SIAT - 즉흥적 개인 청각 이론형
    LearningType(
      id: 'SIAT',
      name: '자유로운 사색가',
      description: '자신만의 방식으로 이론을 탐구하며, 청각적 학습을 통해 깊이 있는 사고를 하는 학습자입니다.',
      character: '🧘',
      emoji: '🎵',
      planning: PlanningType.spontaneous,
      social: SocialType.individual,
      processing: ProcessingType.auditory,
      approach: ApproachType.theoretical,
      studyTips: [
        '관심 있는 주제의 강의나 오디오북 활용',
        '자신만의 속도로 깊이 있게 탐구',
        '중요한 내용을 음성으로 녹음',
        '자유로운 환경에서 집중 학습'
      ],
      strengths: ['깊이 있는 사고', '독립적 학습', '집중력'],
      challenges: ['체계성 부족', '실무 적용 어려움', '시각적 학습 약함'],
      motivationalQuote: '진정한 지혜는 내면의 소리를 듣는 것이다.',
      colorScheme: 'deepPurple',
    ),
    
    // SIAP - 즉흥적 개인 청각 실무형
    LearningType(
      id: 'SIAP',
      name: '직감적 실행자',
      description: '직감을 따라 즉흥적으로 실무 지식을 습득하며, 청각적 학습을 통해 바로 적용하는 학습자입니다.',
      character: '⚡',
      emoji: '🚀',
      planning: PlanningType.spontaneous,
      social: SocialType.individual,
      processing: ProcessingType.auditory,
      approach: ApproachType.practical,
      studyTips: [
        '실무 중심의 팟캐스트나 강의 활용',
        '배운 내용을 즉시 실행',
        '직감을 믿고 빠르게 시도',
        '실패를 통한 학습 경험 축적'
      ],
      strengths: ['실행력', '유연성', '직감력'],
      challenges: ['체계성 부족', '깊이 있는 학습 어려움', '일관성 부족'],
      motivationalQuote: '행동하는 자가 기회를 잡는다.',
      colorScheme: 'red',
    ),
    
    // SGVT - 즉흥적 그룹 시각 이론형
    LearningType(
      id: 'SGVT',
      name: '사교적 탐구자',
      description: '팀과 함께 자유롭게 이론을 탐구하며, 시각적 자료를 활용한 역동적 학습을 선호하는 학습자입니다.',
      character: '🎭',
      emoji: '🔬',
      planning: PlanningType.spontaneous,
      social: SocialType.group,
      processing: ProcessingType.visual,
      approach: ApproachType.theoretical,
      studyTips: [
        '자유로운 분위기의 스터디 그룹',
        '시각적 자료를 활용한 브레인스토밍',
        '다양한 관점을 통한 이론 탐구',
        '즉흥적 토론과 아이디어 공유'
      ],
      strengths: ['창의적 사고', '협업 능력', '다양한 관점'],
      challenges: ['체계성 부족', '실무 적용 어려움', '집중력 부족'],
      motivationalQuote: '다양성이 창의성을 낳는다.',
      colorScheme: 'lightBlue',
    ),
    
    // SGVP - 즉흥적 그룹 시각 실무형
    LearningType(
      id: 'SGVP',
      name: '역동적 협력자',
      description: '팀과 함께 즉흥적으로 실무 프로젝트를 진행하며, 시각적 자료를 활용한 창의적 학습을 하는 학습자입니다.',
      character: '🎪',
      emoji: '🎨',
      planning: PlanningType.spontaneous,
      social: SocialType.group,
      processing: ProcessingType.visual,
      approach: ApproachType.practical,
      studyTips: [
        '즉흥적 프로젝트 팀 참여',
        '시각적 브레인스토밍과 아이디어 구현',
        '다양한 실무 도구 실험',
        '창의적 협업을 통한 실무 학습'
      ],
      strengths: ['창의성', '협업 능력', '실행력'],
      challenges: ['체계성 부족', '깊이 있는 학습 어려움', '일관성 부족'],
      motivationalQuote: '함께하면 불가능도 가능하다.',
      colorScheme: 'deepOrange',
    ),
    
    // SGAT - 즉흥적 그룹 청각 이론형
    LearningType(
      id: 'SGAT',
      name: '자유로운 토론자',
      description: '자유롭고 즉흥적인 토론을 통해 이론을 탐구하며, 청각적 학습을 선호하는 사교적 학습자입니다.',
      character: '🎪',
      emoji: '🎤',
      planning: PlanningType.spontaneous,
      social: SocialType.group,
      processing: ProcessingType.auditory,
      approach: ApproachType.theoretical,
      studyTips: [
        '자유로운 토론 그룹 참여',
        '즉흥적 아이디어 공유와 발전',
        '다양한 관점의 이론적 대화',
        '창의적 토론 기법 활용'
      ],
      strengths: ['토론 능력', '창의적 사고', '사교성'],
      challenges: ['체계성 부족', '실무 적용 어려움', '집중력 부족'],
      motivationalQuote: '대화는 생각의 춤이다.',
      colorScheme: 'brown',
    ),
    
    // SGAP - 즉흥적 그룹 청각 실무형
    LearningType(
      id: 'SGAP',
      name: '즉흥적 네트워커',
      description: '즉흥적이고 사교적인 환경에서 실무 지식을 습득하며, 대화와 네트워킹을 통해 학습하는 학습자입니다.',
      character: '🌐',
      emoji: '📢',
      planning: PlanningType.spontaneous,
      social: SocialType.group,
      processing: ProcessingType.auditory,
      approach: ApproachType.practical,
      studyTips: [
        '네트워킹 이벤트와 세미나 참여',
        '즉흥적 협업 프로젝트 참여',
        '실무 경험 공유와 피드백',
        '다양한 사람들과의 실무 대화'
      ],
      strengths: ['네트워킹', '실행력', '사교성'],
      challenges: ['체계성 부족', '깊이 있는 학습 어려움', '일관성 부족'],
      motivationalQuote: '네트워크가 순자산이다.',
      colorScheme: 'blueGrey',
    ),
  ];
  
  static LearningType findByCode(String code) {
    return all.firstWhere(
      (type) => type.id == code,
      orElse: () => all.first,
    );
  }
  
  static LearningType findByDimensions({
    required PlanningType planning,
    required SocialType social,
    required ProcessingType processing,
    required ApproachType approach,
  }) {
    return all.firstWhere(
      (type) => 
        type.planning == planning &&
        type.social == social &&
        type.processing == processing &&
        type.approach == approach,
      orElse: () => all.first,
    );
  }
}