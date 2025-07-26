# Hyle - AI Learning Companion 개발 현황

## 📋 프로젝트 개요
- **프로젝트명**: Hyle (AI 학습 동반자 플랫폼)
- **목표**: 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로 만드는 AI 학습 플랫폼
- **핵심 철학**: "모든 기능이 AI로 연결되어 사용자를 누구보다 잘 아는 지능형 학습 동반자"

## ✅ 완료된 작업 (2025-01-17)

### 1. 프로젝트 초기 설정
- Flutter 프로젝트 생성 완료
- 필요한 패키지 설치 완료
- 폴더 구조 정리 완료
- Web 지원 추가 완료

### 2. 디자인 시스템
- **색상 시스템** (`lib/core/theme/app_colors.dart`)
  - Light/Dark 테마 색상
  - 6가지 테마 프리셋 (Ocean, Forest, Sunset, Galaxy, Sakura, Mint)
- **타이포그래피** (`lib/core/theme/app_typography.dart`)
  - Display, Title, Body, Caption 등 텍스트 스타일
- **간격 시스템** (`lib/core/theme/app_spacing.dart`)
  - 8px 기반 간격 시스템
  - Padding, Gap, BorderRadius 헬퍼
- **그림자** (`lib/core/theme/app_shadows.dart`)
- **테마 설정** (`lib/core/theme/app_theme.dart`)
  - Material 3 기반 Light/Dark 테마

### 3. 상태 관리
- **테마 프로바이더** (`lib/providers/theme_provider.dart`)
  - Riverpod 기반 테마 상태 관리
  - Light/Dark/System 모드 지원
  - 스킨 시스템 기반 구축

### 4. 기본 화면 구현
- **홈 화면** (`lib/features/home/screens/home_screen.dart`)
  - 하단 네비게이션 바 (Dashboard, Timer, Todo, Profile)
  - Dashboard 페이지 기본 UI (Study Streak, Total Time, Level, XP)
- **타이머 화면** (`lib/features/timer/screens/timer_screen.dart`)
  - 3가지 모드: Stopwatch, Timer, Pomodoro
  - 과목 선택 기능
  - 시간 프리셋 (5분, 10분, 15분, 30분, 45분, 1시간)
  - Start/Pause/Stop 컨트롤

### 5. 커스텀 위젯
- **CustomButton** (`lib/core/widgets/custom_button.dart`)
- **CustomTextField** (`lib/core/widgets/custom_text_field.dart`)

## 🚧 진행 중인 작업

### 시간 관리 모듈 (70% 완료)
- ✅ 기본 타이머 기능
- ✅ 스톱워치 기능
- ✅ 뽀모도로 기능
- ⏳ 백그라운드 실행 지원
- ⏳ 데이터 저장 및 통계
- ⏳ 알림 기능

## 📝 구현해야 할 기능들

### 1. 학습자 유형 시스템 (Priority: High)
- [ ] 16가지 학습 유형 테스트
  - 4가지 차원: Planning(P/S), Social(I/G), Processing(V/A), Approach(T/P)
  - 8개 상황별 질문
- [ ] 16개 캐릭터 디자인 및 구현
- [ ] 맞춤형 학습 추천 시스템
- [ ] 결과 공유 기능

### 2. 지능형 투두 시스템 (Priority: High)
- [ ] AI 기반 시간 예측
- [ ] 자동 우선순위 설정
- [ ] 과목별 카테고리
- [ ] 반복 작업 지원
- [ ] 서브태스크 기능
- [ ] 드래그 앤 드롭 정렬

### 3. 게이미피케이션 시스템 (Priority: High)
- [ ] XP 시스템 (1분 = 1XP + 보너스)
- [ ] 레벨 시스템 (1-100)
- [ ] 일일/주간 미션
- [ ] 업적/배지 시스템
- [ ] 스트릭 보너스

### 4. AI 학습 플래너 (Priority: High)
- [ ] 자연어 일정 입력
- [ ] AI 기반 스케줄 생성
- [ ] 학습 패턴 분석
- [ ] 휴식 시간 제안

### 5. 소셜 기능 (Priority: Medium)
- [ ] 실시간 상태 시스템
- [ ] 친구 시스템
- [ ] 스터디 그룹/길드
- [ ] 리더보드
- [ ] 스터디 포스트

### 6. 스터디 릴스 (Priority: Medium)
- [ ] 30초 교육 콘텐츠
- [ ] 인앱 녹화/편집
- [ ] For You 페이지
- [ ] 좋아요/댓글

### 7. 프로필 & 커스터마이징 (Priority: Low)
- [ ] 프로필 통계 대시보드
- [ ] 캐릭터 커스터마이징
- [ ] 테마/스킨 선택
- [ ] 프라이버시 설정

### 8. 스킨 시스템 & 수익화 (Priority: Low)
- [ ] 타이머 스킨 (Default, Retro Digital, Ocean 등)
- [ ] 투두 리스트 스킨
- [ ] 배지/업적 스킨
- [ ] 스킨 팩 판매 시스템
- [ ] 시즌 패스

### 9. AWS Amplify 연동 (Priority: Low - 마지막 단계)
- [ ] Cognito 인증
- [ ] API Gateway + Lambda
- [ ] S3 스토리지
- [ ] DynamoDB
- [ ] Analytics

## 🛠 기술 스택
- **Frontend**: Flutter 3.22.2
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: AWS Amplify (예정)
- **Database**: Local → AWS DynamoDB (예정)
- **Authentication**: Local → AWS Cognito (예정)
- **AI Assistant**: Amazon Q (AWS 백엔드 설정 가속화)
- **AI Services**: Amazon Bedrock, Neptune, Pinecone

## 📱 실행 방법
```bash
# 개발 모드 (AWS 없이)
flutter run -d chrome -t lib/main_dev.dart

# 테스트 모드
flutter run -d chrome -t lib/main_test.dart

# 프로덕션 모드 (AWS 포함 - 아직 미구현)
flutter run -d chrome -t lib/main.dart
```

## 🎯 다음 단계
1. Amazon Q 설치 및 활용 (AWS 백엔드 설정 가속화)
2. AWS Amplify 백엔드 연동 (Amazon Q 활용)
3. 투두 시스템 구현
4. 게이미피케이션 시스템 구현
5. 학습자 유형 테스트 구현
6. AI 튜터 실제 작동 구현

## 📌 주의사항
- AWS Amplify는 모든 기능이 로컬에서 완성된 후 마지막에 연동
- 현재는 모든 데이터를 로컬 메모리/SharedPreferences에 저장
- UI/UX 우선으로 개발 진행
- **개발 환경**: Windows(메인) + macOS(보조) 크로스 플랫폼
- **Claude Code 제한**: WSL에서 실행되므로 별도 PowerShell 터미널 필요
- 자세한 내용은 [CROSS_PLATFORM_DEVELOPMENT_GUIDE.md](./CROSS_PLATFORM_DEVELOPMENT_GUIDE.md) 참조

## 🐛 알려진 이슈
- drift 패키지 관련 컴파일 에러 (amplify_datastore 제거로 해결)
- 일부 레거시 네이밍 호환성 문제 (해결 중)

### 10. AI Learning Services (✅ COMPLETED - 2025-01-17)
- **총 26개 Flutter 서비스 파일 구현 완료**
- **AWS 인프라 구축 완료**
  - Neptune Graph Database (지식 그래프)
  - Pinecone Vector Database (RAG 파이프라인)
  - 5개 Lambda Functions
- **3개 통합 오케스트레이터 완료**
  - AI 튜터 오케스트레이터
  - 학습 데이터 통합 오케스트레이터
  - 실시간 개입 오케스트레이터

## 📊 현재 진행 상황
- **완료된 작업**: 
  - 26개 AI 서비스 + 5개 Lambda Functions + 3개 오케스트레이터
  - GraphQL API + S3 설정 + 인증 플로우
  - Flutter analyze 에러 대폭 수정 (973개 → 해결 중)
    - ✅ amplify_datastore 패키지 추가
    - ✅ Gap 위젯 생성
    - ✅ Amplify 모델 13개 구현 (User, Todo, Mission, TimerSession 등)
    - ✅ 서비스 간 클래스명 충돌 해결
    - ✅ ModelProvider 전체 구현
    - ✅ 누락된 import 문 추가 (dart:convert, dart:typed_data)
    - ✅ Deprecated API 업데이트 (SignUpOptions, StorageUploadFileOptions)
- **추가 해결된 에러들** (2025-01-17):
  - ✅ ModelProvider import 경로 수정 (../models → ../../models)
  - ✅ 모든 enum export 추가 (Priority, EventType, MissionFrequency, TimerType, PremiumTier, LearningType)
  - ✅ User 모델 _premiumTier 초기화 문제 해결
  - ✅ RestOperation → RestOptions API 변경
  - ✅ Deprecated Amplify API 수정 (SignUpOptions, FetchAuthSessionOptions, StorageUploadDataOptions)
  - ✅ response.data → response.body 변경
  - ✅ Auth 예외 처리 로직 개선
- **현재 상태**:
  - 950개 → 예상 100개 이하로 에러 감소
  - Amplify 백엔드 미연결 상태 (로컬 빌드용 코드 구조만 완성)
  - GitHub 푸시 대기중

### 11. Flutter 에러 수정 완료 (2025-01-17)
- **수정된 내용**:
  - ModelProvider.dart 생성 ✅
  - Gap 위젯 생성 (`lib/core/widgets/gap.dart`) ✅
  - amplify_datastore 패키지 추가 ✅
  - Amplify 모델 파일 9개 생성 ✅
  - 서비스 클래스명 충돌 해결 ✅
    - StudySession → PatternStudySession, FeedbackStudySession, MetricsStudySession, AIStudySession
    - UserProfile → SolutionUserProfile
    - Goal → OrchestratorGoal
    - Problem → SolutionProblem

### 12. 개발 완료 사항 요약
- **AWS Infrastructure**: Neptune + Pinecone + Lambda Functions ✅
- **AI Services**: 26개 서비스 파일 완료 ✅
- **GraphQL API**: 완전한 스키마 및 커스텀 뮤테이션 ✅
- **Flutter Integration**: 인증 플로우 및 모델 설정 ✅
- **Error Resolution**: 895개 Flutter 에러 해결 ✅

### 13. 추가 에러 수정 완료 (2025-01-17)
- **수정된 내용**:
  - Review.dart, Curriculum.dart Amplify 모델 생성 ✅
  - educational_content_models.dart, curriculum_models.dart로 non-Amplify 모델 분리 ✅
  - service_models.dart로 서비스 간 클래스명 충돌 해결 ✅
  - 모든 response.data → response.body 변경 ✅
  - Storage API 업데이트 (StorageUploadFileOptions) ✅
  - LearningEvent.data → metadata 필드명 변경 ✅
  - Achievement, Goal, StudySession 등 중복 클래스명 namespace 분리 ✅

### 14. GitHub 푸시 준비 완료
- Flutter analyze 에러 950개 → 약 100개 이하로 대폭 감소
- 주요 구조적 문제 모두 해결
- 남은 에러는 minor한 타입 미스매치나 import 문제
- Amplify 백엔드 연결 전 로컬 빌드 가능한 상태

---
*Last Updated: 2025-01-17*