# Hyle Project Overview - 통합 현황 문서

> 이 문서는 Hyle 프로젝트의 모든 현황을 한 곳에 정리한 통합 문서입니다.
> Claude나 다른 AI에 붙여넣기하여 프로젝트 컨텍스트를 즉시 전달할 수 있습니다.

## 📌 프로젝트 정보

- **프로젝트명**: Hyle (AI Learning Companion)
- **설명**: 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로 만드는 AI 학습 플랫폼
- **개발 시작**: 2025년 1월
- **현재 날짜**: 2025년 7월 26일
- **GitHub**: https://github.com/cloudsnuchoi/hyle

## 🛠️ 기술 스택

### Frontend
- **Framework**: Flutter 3.22.2
- **Language**: Dart 3.4.0
- **State Management**: Riverpod + Provider
- **Navigation**: go_router
- **플랫폼**: Web (Chrome), iOS, Android, macOS, Windows

### Backend (예정)
- **Infrastructure**: AWS Amplify
- **Authentication**: AWS Cognito
- **API**: GraphQL (AppSync)
- **Database**: DynamoDB
- **Storage**: S3
- **AI Services**: 
  - Amazon Bedrock (AI 모델)
  - Neptune (지식 그래프)
  - Pinecone (벡터 DB)
  - Kinesis (실시간 처리)

### 개발 도구
- **주 개발 환경**: Windows + WSL (Claude Code)
- **보조 환경**: macOS
- **AI Assistant**: Amazon Q (AWS 설정 가속화)

## 📊 개발 현황 통계

### 코드 규모
- **총 파일 수**: 약 200개+
- **Flutter 소스 파일**: 150개+
- **AWS Lambda 함수**: 5개
- **AI 서비스 파일**: 26개
- **GraphQL 모델**: 13개

### 에러 현황
- **초기 Flutter 에러**: 973개
- **현재 Flutter 에러**: 약 100개 미만 (90% 해결)
- **주요 해결 사항**: 
  - Amplify 모델 통합
  - 클래스명 충돌 해결
  - Deprecated API 업데이트

## ✅ 완료된 기능 (70%)

### 1. UI/UX 구현 ✓
- 홈 대시보드 (스트릭, 총 학습시간, 레벨, XP)
- 하단 네비게이션 (Dashboard, Timer, Todo, Profile)
- 6가지 테마 프리셋 (Ocean, Forest, Sunset, Galaxy, Sakura, Mint)
- 다크/라이트 모드
- 반응형 디자인

### 2. 타이머 시스템 ✓
- 3가지 모드: Stopwatch, Timer, Pomodoro
- 과목별 시간 추적
- 시간 프리셋 (5분~1시간)
- 타이머 스킨 시스템 (8가지)

### 3. 투두/퀘스트 시스템 ✓
- 카테고리별 할일 관리
- 우선순위 설정 (Low, Medium, High, Urgent)
- D-Day 위젯
- 완료율 시각화

### 4. 게이미피케이션 ✓
- XP 시스템 (1분 = 1XP + 보너스)
- 레벨 시스템 (1-100)
- 일일/주간/특별 퀘스트
- 스트릭 시스템

### 5. 기본 인증 플로우 ✓
- 로그인/회원가입 UI
- 비밀번호 재설정
- Mock 인증 서비스

### 6. AI 서비스 설계 ✓
- 26개 서비스 파일 작성
- 3개 오케스트레이터 설계
- GraphQL 스키마 정의

## 🚧 진행 중인 작업 (20%)

### 1. AWS Amplify 연동 (0%)
- [ ] Amplify CLI 설정
- [ ] Cognito 실제 연동
- [ ] GraphQL API 배포
- [ ] S3 스토리지 연결

### 2. 학습자 유형 테스트 (30%)
- [x] 16가지 유형 정의
- [x] 테스트 질문 작성
- [ ] 결과 분석 로직
- [ ] UI 구현

### 3. 문서 정리 (90%)
- [x] docs/ 폴더 구조화
- [x] 중복 문서 제거
- [x] Amazon Q 가이드 추가
- [ ] API 문서 작성

## ❌ 미구현 기능 (10%)

### 1. AI 튜터 실제 작동
- Bedrock 연동
- 자연어 처리
- 학습 추천 시스템

### 2. 실시간 기능
- 친구 상태 실시간 업데이트
- 스터디 그룹 채팅
- 실시간 리더보드

### 3. 스터디 릴스
- 30초 교육 콘텐츠
- 동영상 업로드/편집
- For You 알고리즘

### 4. 고급 분석
- 학습 패턴 분석
- AI 기반 피드백
- 성과 예측

## 🐛 현재 문제점

### 1. 기술적 이슈
- **Flutter 에러 약 100개**: 주로 타입 미스매치, import 누락
- **WSL 제한**: Claude Code에서 Flutter 명령어 직접 실행 불가
- **AWS 미연동**: Mock 데이터만 사용 중

### 2. 구조적 이슈
- 일부 서비스 간 의존성 복잡
- 모델 클래스 중복 (부분 해결)
- 테스트 코드 부재

### 3. UX 이슈
- 모바일 반응형 미완성
- 일부 애니메이션 미구현
- 오프라인 모드 제한적

## 🎯 즉시 해야 할 작업 (Priority)

### 1. AWS Amplify 연동 (High)
```bash
# 1. Amazon Q 설치 (VSCode)
# 2. AWS CLI 설정
aws configure --profile hyle
# 3. Amplify 초기화
amplify init
# 4. 서비스 추가
amplify add auth
amplify add api
amplify push
```

### 2. Flutter 에러 수정 (High)
```bash
# PowerShell에서 실행
flutter analyze > error_log.txt
# 타입 에러 우선 수정
# import 문 정리
```

### 3. 학습자 유형 테스트 완성 (Medium)
- UI 구현 (이미 설계됨)
- 결과 저장 로직
- 프로필 연동

## 📂 프로젝트 구조

```
hyle/
├── lib/                    # Flutter 앱 코드
│   ├── core/              # 공통 모듈 (테마, 위젯)
│   ├── data/              # 데이터 레이어
│   │   ├── repositories/  # 데이터 저장소
│   │   └── services/      # 비즈니스 로직 (26개 AI 서비스)
│   ├── features/          # 기능별 화면
│   ├── models/            # 데이터 모델
│   ├── providers/         # 상태 관리
│   └── routes/            # 네비게이션
├── amplify/               # AWS 백엔드 설정
├── docs/                  # 프로젝트 문서
│   ├── aws/              # AWS 가이드
│   ├── development/      # 개발 가이드
│   └── testing/          # 테스트 가이드
└── 주요 파일
    ├── main_dev.dart      # 개발용 진입점
    ├── main_test.dart     # 테스트용 진입점
    ├── CLAUDE.md          # Claude Code 지침
    └── PROJECT_STATUS.md  # 상세 현황

```

## 💻 실행 방법

### 개발 환경 실행
```bash
# Windows PowerShell (WSL 아님!)
cd C:\dev\git\hyle
flutter pub get
flutter run -d chrome -t lib/main_dev.dart
```

### 테스트 환경 실행
```bash
flutter run -d chrome -t lib/main_test_local.dart
```

## 🔑 핵심 파일 위치

- **라우팅**: `lib/routes/app_router.dart`
- **테마**: `lib/core/theme/app_theme.dart`
- **인증**: `lib/providers/auth_provider.dart`
- **AI 서비스**: `lib/data/services/ai_*.dart`
- **AWS 설정**: `amplify/backend.ts`

## 📈 향후 로드맵

### Phase 1: 기반 구축 (현재)
- ✅ UI/UX 구현
- ✅ 기본 기능 구현
- ⏳ AWS 연동
- ⏳ 에러 수정

### Phase 2: AI 통합 (다음)
- AI 튜터 활성화
- 학습 분석 시스템
- 개인화 추천

### Phase 3: 소셜 기능
- 스터디 그룹
- 리더보드
- 스터디 릴스

### Phase 4: 수익화
- 프리미엄 기능
- 스킨 판매
- 구독 모델

## 🛡️ 보안 고려사항

- API Key 환경 변수 관리
- 사용자 데이터 암호화
- Row-level 보안 (GraphQL @auth)
- Rate limiting 구현 필요

## 📞 연락처 & 리소스

- GitHub: https://github.com/cloudsnuchoi/hyle
- 주요 문서: `/docs/README.md`
- Amazon Q 가이드: `/docs/aws/AMAZON_Q_GUIDE.md`
- 크로스 플랫폼 가이드: `/docs/setup/CROSS_PLATFORM_GUIDE.md`

---

**마지막 업데이트**: 2025년 7월 26일
**다음 액션**: AWS Amplify 연동 시작 (Amazon Q 활용)

## 🔄 최근 변경사항 (2025-07-26)

1. **문서 재구성 완료**
   - 20개+ MD 파일을 docs/ 폴더로 체계화
   - 중복 제거 및 통합

2. **개발 환경 정리**
   - Claude Code (WSL): 코드 편집
   - PowerShell: 명령어 실행
   - `QUICK_COMMANDS.md` 생성

3. **도구 설정**
   - Amplify CLI v14.0.0 설치 (WSL)
   - 하지만 PowerShell 사용 권장

4. **Claude Desktop**
   - Windows 네이티브 버전 출시
   - WSL 대신 직접 사용 가능