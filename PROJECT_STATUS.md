# Hyle - AI Learning Companion 개발 현황

## 📋 프로젝트 개요
- **프로젝트명**: Hyle (AI 학습 동반자 플랫폼)
- **목표**: 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로 만드는 AI 학습 플랫폼
- **핵심 철학**: "모든 기능이 AI로 연결되어 사용자를 누구보다 잘 아는 지능형 학습 동반자"

## ✅ 완료된 작업 (2025-01-16)

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
1. 투두 시스템 구현
2. 게이미피케이션 시스템 구현
3. 학습자 유형 테스트 구현
4. 로컬 데이터 저장 (SharedPreferences)
5. 모든 기능 완성 후 AWS 연동

## 📌 주의사항
- AWS Amplify는 모든 기능이 로컬에서 완성된 후 마지막에 연동
- 현재는 모든 데이터를 로컬 메모리/SharedPreferences에 저장
- UI/UX 우선으로 개발 진행

## 🐛 알려진 이슈
- drift 패키지 관련 컴파일 에러 (amplify_datastore 제거로 해결)
- 일부 레거시 네이밍 호환성 문제 (해결 중)

---
*Last Updated: 2025-01-16*