# HYLE PROJECT MEMORY - 2025-09-10

## 📅 오늘의 개발 세션 요약

### 🏃‍♂️ 개발 세션 타임라인

#### 오전 세션 (네비게이션 재구성)
1. **플로팅 메뉴 문제 해결**
   - 메뉴 외부 클릭 시 자동 닫힘 구현
   - GestureDetector로 body 전체 감싸기
   - 햄버거 메뉴 Scaffold.of() 에러 수정 (Builder 위젯 사용)

2. **스크린 한국어화 작업**
   - RankingScreen: 'Leaderboard' → '리더보드'
   - NoteScreen, BookmarkScreen, HistoryScreen, HelpScreen 한국어 번역
   - 일관된 한국어 UI 적용

3. **라우팅 문제 해결**
   - 소셜 버튼: `/social/ranking` → `/social/study-groups` 변경
   - 56개 전체 스크린 라우팅 점검

#### 오후 세션 (타이머 시스템 구현)
1. **학습 세션 시작 플로우 재설계**
   - 기존: 타이머 모드 선택만 있었음 (의미 없는 동일 화면)
   - 개선: 2단계 프로세스 (과목/투두 선택 → 타이머 모드 선택)
   - ChoiceChip과 Radio 버튼 활용한 선택 UI

2. **스톱워치 스크린 개발**
   - 경로: `/timer/stopwatch`
   - 파일: `lib/features/timer/screens/stopwatch_screen.dart`
   - 기능: 시작/일시정지/리셋, 랩 타임, 애니메이션

3. **뽀모도로 타이머 개발**
   - 경로: `/timer/pomodoro`
   - 파일: `lib/features/timer/screens/pomodoro_screen.dart`
   - 기능: 25-5-15분 사이클, 원형 프로그레스, 세션 카운터

4. **AI 스크린 통합**
   - 4개 분리된 AI 스크린을 TabController로 통합
   - AI 튜터, AI 채팅, AI 분석, AI 요약 탭

5. **학습 스크린 확장**
   - 과목 카드 클릭 시 6개 학습 옵션 표시
   - 플래시카드, 퀴즈, 수업, 연습, 비디오, PDF

## 🔧 기술적 구현 상세

### 주요 Flutter 패턴 사용
```dart
// 1. StatefulBuilder for modal state management
showModalBottomSheet(
  builder: (context) => StatefulBuilder(
    builder: (context, setModalState) => ...
  )
)

// 2. GestureDetector for outside tap detection
GestureDetector(
  onTap: () {
    if (_isMenuExpanded) {
      setState(() => _isMenuExpanded = false);
    }
  },
  child: ...
)

// 3. Builder widget for correct context
Builder(
  builder: (BuildContext context) {
    return IconButton(
      onPressed: () => Scaffold.of(context).openEndDrawer(),
    );
  },
)

// 4. AnimationController with SingleTickerProviderStateMixin
late AnimationController _animationController;
late Animation<double> _scaleAnimation;

// 5. CustomPainter for circular progress
CustomPaint(
  painter: CircularProgressPainter(
    progress: _progressController.value,
    color: _isBreak ? Color(0xFF4CAF50) : Color(0xFF638ECB),
  ),
)
```

### 라우터 설정 패턴
```dart
// Extra data passing with go_router
GoRoute(
  path: '/timer/stopwatch',
  builder: (context, state) {
    final sessionData = state.extra as Map<String, dynamic>?;
    return StopwatchScreen(sessionData: sessionData);
  },
)

// Navigation with extra data
context.push('/timer/stopwatch', extra: {
  'subject': subject,
  'todo': todo,
});
```

## 🐛 해결한 문제들

1. **Scaffold.of() 에러**
   - 문제: "Scaffold.of() called with a context that does not contain a Scaffold"
   - 해결: Builder 위젯으로 올바른 context 제공

2. **플로팅 메뉴 닫힘 문제**
   - 문제: 메뉴 밖 클릭해도 닫히지 않음
   - 해결: body를 GestureDetector로 감싸서 외부 탭 감지

3. **타입 에러**
   - 문제: String? 타입을 String 파라미터에 전달
   - 해결: null assertion operator (!) 사용

4. **RenderFlex overflow**
   - 문제: 플로팅 메뉴 아이템 너비 초과
   - 해결: 아이템 너비 70px → 60px 조정

## 📦 프로젝트 구조 변경

### 새로 추가된 파일
```
lib/features/timer/
  └── screens/
      ├── stopwatch_screen.dart
      └── pomodoro_screen.dart
```

### 수정된 주요 파일
- `lib/features/home/screens/home_screen_new.dart` - 세션 설정 플로우
- `lib/features/ai/screens/ai_tutor_screen.dart` - TabController 추가
- `lib/features/study/screens/study_screen.dart` - 학습 옵션 바텀시트
- `lib/routes/app_router_clean.dart` - 타이머 라우트 추가

## 🎯 다음 단계 제안

1. **세션 데이터 저장**
   - 학습 세션 시작/종료 시간 기록
   - 과목별 누적 시간 데이터베이스 저장
   - 통계 화면에 반영

2. **알림 기능**
   - 뽀모도로 세션 완료 알림
   - 투두 마감일 알림
   - 학습 목표 달성 알림

3. **데이터 시각화**
   - 주간/월간 학습 시간 차트
   - 과목별 진행률 그래프
   - 뽀모도로 세션 히트맵

## 💡 중요 인사이트

1. **UX 개선 포인트**
   - 2단계 선택 프로세스가 사용자 의도를 명확히 함
   - 세션 정보 표시로 현재 학습 내용 인지 향상
   - 한국어 UI로 일관성 확보

2. **기술적 배움**
   - StatefulBuilder로 모달 내부 상태 관리
   - AnimationController 활용한 부드러운 전환
   - CustomPainter로 복잡한 UI 구현

3. **프로젝트 관리**
   - Task tool 활용한 병렬 작업 효율성
   - 점진적 개선 방식의 효과
   - 컨텍스트 유지의 중요성

## 📝 커밋 메시지 템플릿
```
feat: 학습 세션 및 타이머 시스템 구현

- 2단계 학습 세션 시작 플로우 구현
- 스톱워치 및 뽀모도로 타이머 스크린 추가
- AI 스크린 TabController로 통합
- 학습 스크린 확장 (6개 학습 옵션)
- 5개 스크린 한국어화 완료
```

## 🔄 백업 상태
- 마지막 커밋: (예정)
- 브랜치: main
- 변경 파일: 14개
- 새 파일: 3개