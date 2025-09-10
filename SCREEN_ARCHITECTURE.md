# HYLE App Screen Architecture

## 🎯 핵심 설계 원칙
1. **Mobile-First Design**: 모바일 우선, 태블릿/데스크톱 반응형
2. **Gamification**: 학습을 게임처럼 재미있게
3. **AI Integration**: 모든 화면에서 AI 도우미 접근 가능
4. **Minimalism**: 깔끔하고 집중력 있는 인터페이스
5. **Accessibility**: WCAG 2.1 AA 준수

## 📱 Screen Structure

### 1. 🚀 Onboarding Flow (첫 사용자 경험)
```
SplashScreen
    ↓
OnboardingScreen (3-4 steps)
    ↓
LearningTypeTestScreen (학습 유형 진단)
    ↓
PersonalizationScreen (맞춤 설정)
    ↓
HomeScreen
```

#### 1.1 SplashScreen
- 앱 로고 애니메이션
- 로딩 프로그레스
- 자동 로그인 체크

#### 1.2 OnboardingScreen
- Step 1: HYLE 소개 (AI 학습 도우미)
- Step 2: 주요 기능 설명
- Step 3: 권한 요청 (알림, 카메라 등)
- Step 4: 계정 생성/로그인

#### 1.3 LearningTypeTestScreen
- 16가지 학습 유형 진단
- 인터랙티브 퀴즈 형식
- 프로그레스 표시
- 결과 즉시 확인

#### 1.4 PersonalizationScreen
- 학습 목표 설정
- 선호 과목 선택
- 일일 학습 시간 설정
- 알림 설정

### 2. 🔐 Authentication Screens
```
LoginScreen ←→ SignupScreen
     ↓           ↓
ForgotPasswordScreen
     ↓
EmailVerificationScreen
```

#### 2.1 LoginScreen
- 소셜 로그인 (Google, Apple, Kakao)
- 이메일/비밀번호 로그인
- 생체 인증 (지문, Face ID)
- Remember me 옵션

#### 2.2 SignupScreen
- 단계별 가입 (이메일 → 비밀번호 → 프로필)
- 실시간 유효성 검사
- 약관 동의
- 추천인 코드

### 3. 🏠 Main Navigation Structure
```
HomeScreen (Dashboard)
    ├── StudyScreen (학습)
    ├── ProgressScreen (진도)
    ├── CommunityScreen (커뮤니티)
    └── ProfileScreen (프로필)
```

#### 3.1 HomeScreen (Dashboard)
- **Hero Section**: 오늘의 학습 목표
- **Quick Actions**: 빠른 시작 버튼들
- **Study Streak**: 연속 학습 일수
- **Daily Missions**: 일일 미션 3개
- **AI Recommendations**: AI 추천 콘텐츠
- **Recent Activity**: 최근 학습 기록

#### 3.2 StudyScreen (학습 허브)
```
StudyScreen
    ├── SubjectListScreen (과목 선택)
    ├── TopicScreen (주제별 학습)
    ├── PracticeScreen (문제 풀이)
    ├── FlashcardScreen (플래시카드)
    └── QuizScreen (퀴즈/시험)
```

##### StudyScreen 하위 화면들:
- **SubjectListScreen**: 과목 그리드/리스트
- **TopicScreen**: 챕터별 진도율 표시
- **PracticeScreen**: 
  - 문제 풀이 인터페이스
  - 힌트 시스템
  - 즉시 피드백
- **FlashcardScreen**: 
  - 스와이프 카드 UI
  - 암기 상태 표시
  - 스페이스드 리피티션
- **QuizScreen**: 
  - 타이머
  - 진도 표시
  - 결과 분석

#### 3.3 ProgressScreen (진도 관리)
```
ProgressScreen
    ├── StatisticsScreen (통계)
    ├── AchievementsScreen (업적)
    ├── LeaderboardScreen (리더보드)
    └── GoalsScreen (목표 관리)
```

##### ProgressScreen 하위 화면들:
- **StatisticsScreen**: 
  - 학습 시간 차트
  - 과목별 성취도
  - 주/월/년 통계
- **AchievementsScreen**: 
  - 배지 컬렉션
  - 레벨 시스템
  - 보상 시스템
- **LeaderboardScreen**: 
  - 친구 순위
  - 전체 순위
  - 주간 챌린지
- **GoalsScreen**: 
  - SMART 목표 설정
  - 진도 트래킹
  - 마일스톤

#### 3.4 CommunityScreen (커뮤니티)
```
CommunityScreen
    ├── StudyGroupsScreen (스터디 그룹)
    ├── ForumScreen (포럼/Q&A)
    ├── MentorScreen (멘토링)
    └── EventsScreen (이벤트/챌린지)
```

##### CommunityScreen 하위 화면들:
- **StudyGroupsScreen**: 
  - 그룹 생성/참여
  - 그룹 채팅
  - 공동 목표
- **ForumScreen**: 
  - 질문/답변
  - 베스트 답변
  - 태그 시스템
- **MentorScreen**: 
  - 멘토 매칭
  - 1:1 채팅
  - 멘토링 일정
- **EventsScreen**: 
  - 학습 챌린지
  - 경쟁 이벤트
  - 보상 시스템

### 4. 🤖 AI Features Screens
```
AIAssistantScreen (AI 도우미)
    ├── AIChatScreen (대화형 학습)
    ├── AITutorScreen (AI 튜터)
    ├── AISummaryScreen (요약 생성)
    └── AIAnalysisScreen (학습 분석)
```

#### AI 기능 화면들:
- **AIChatScreen**: 
  - 채팅 인터페이스
  - 음성 입력
  - 이미지 인식
- **AITutorScreen**: 
  - 맞춤형 설명
  - 단계별 풀이
  - 오답 분석
- **AISummaryScreen**: 
  - 노트 요약
  - 핵심 포인트
  - 마인드맵 생성
- **AIAnalysisScreen**: 
  - 학습 패턴 분석
  - 취약점 진단
  - 개선 제안

### 5. ⚙️ Settings & Profile
```
ProfileScreen
    ├── EditProfileScreen
    ├── SettingsScreen
    ├── NotificationSettingsScreen
    ├── PrivacyScreen
    ├── SubscriptionScreen
    └── HelpScreen
```

#### 설정 관련 화면들:
- **EditProfileScreen**: 프로필 수정
- **SettingsScreen**: 
  - 테마 설정 (라이트/다크/자동)
  - 언어 설정
  - 폰트 크기
- **NotificationSettingsScreen**: 알림 상세 설정
- **PrivacyScreen**: 개인정보 관리
- **SubscriptionScreen**: 구독 관리
- **HelpScreen**: FAQ, 문의하기

### 6. 📚 Content Screens
```
ContentScreen
    ├── VideoPlayerScreen (동영상 강의)
    ├── PDFViewerScreen (PDF 뷰어)
    ├── NoteEditorScreen (노트 작성)
    └── WhiteboardScreen (화이트보드)
```

### 7. 🎮 Gamification Screens
```
GameScreen
    ├── DailyMissionScreen (일일 미션)
    ├── QuestScreen (퀘스트)
    ├── RewardScreen (보상)
    └── ShopScreen (아이템 샵)
```

## 🎨 UI/UX 특징

### 공통 컴포넌트
1. **Bottom Navigation Bar**: 5개 주요 메뉴
2. **Floating AI Button**: 모든 화면에서 AI 접근
3. **Progress Indicator**: 학습 진도 표시
4. **Notification Badge**: 알림 표시

### 애니메이션 & 트랜지션
1. **Hero Animations**: 화면 전환 시
2. **Micro-interactions**: 버튼, 카드 상호작용
3. **Skeleton Loading**: 콘텐츠 로딩
4. **Pull-to-refresh**: 새로고침

### 접근성
1. **Dark Mode**: 시스템 설정 연동
2. **Font Scaling**: 가독성 향상
3. **Screen Reader**: 지원
4. **High Contrast**: 모드 지원

## 📊 화면 우선순위

### Phase 1 (MVP) - 핵심 기능
1. SplashScreen ✅
2. LoginScreen ✅
3. SignupScreen ✅
4. HomeScreen ✅
5. StudyScreen ✅
6. ProfileScreen ✅

### Phase 2 - 학습 기능 강화
1. PracticeScreen
2. FlashcardScreen
3. QuizScreen
4. ProgressScreen
5. StatisticsScreen

### Phase 3 - AI & 커뮤니티
1. AIChatScreen
2. AITutorScreen
3. StudyGroupsScreen
4. ForumScreen

### Phase 4 - 게이미피케이션
1. AchievementsScreen
2. LeaderboardScreen
3. DailyMissionScreen
4. RewardScreen

## 🔄 Navigation Flow
```yaml
entry_point: SplashScreen
auth_flow:
  - LoginScreen
  - SignupScreen
  - ForgotPasswordScreen
main_flow:
  - HomeScreen (hub)
  - StudyScreen (학습)
  - ProgressScreen (진도)
  - CommunityScreen (소셜)
  - ProfileScreen (설정)
modal_screens:
  - AIAssistantScreen (overlay)
  - NotificationScreen (overlay)
  - SearchScreen (overlay)
```

## 💡 개발 가이드라인
1. **Component-based**: 재사용 가능한 컴포넌트
2. **Responsive**: MediaQuery 활용
3. **State Management**: Riverpod
4. **Navigation**: go_router
5. **Theme**: Material 3 Design System

---

이 구조를 기반으로 체계적으로 스크린을 개발해나가겠습니다.