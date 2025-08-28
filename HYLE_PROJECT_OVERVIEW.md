# Hyle Project Overview - 통합 현황 문서

> 이 문서는 Hyle 프로젝트의 모든 현황을 한 곳에 정리한 통합 문서입니다.
> Claude나 다른 AI에 붙여넣기하여 프로젝트 컨텍스트를 즉시 전달할 수 있습니다.

## 📌 프로젝트 정보

- **프로젝트명**: Hyle (AI Learning Companion)
- **설명**: 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로 만드는 AI 학습 플랫폼
- **개발 시작**: 2025년 1월
- **현재 날짜**: 2025년 7월 26일
- **GitHub**: https://github.com/cloudsnuchoi/hyle

## 🏗️ 전체 시스템 아키텍처

```
┌──────────────────────────────────────────────────────┐
│                    사용자 앱 (Flutter)                 │
│         iOS / Android / Web / Desktop                 │
└──────────────────────┬───────────────────────────────┘
                       │
┌──────────────────────▼───────────────────────────────┐
│                    Supabase                          │
│          (공통 백엔드 - PostgreSQL + Realtime)        │
│                                                      │
│  • 사용자 데이터    • AI 메모리                       │
│  • 학습 기록       • 실시간 동기화                    │
│  • 콘텐츠 관리     • 파일 스토리지                    │
└──────────────────────┬───────────────────────────────┘
                       │
┌──────────────────────▼───────────────────────────────┐
│              관리자 대시보드 (Next.js)                 │
│                   admin.hyle.ai                      │
│                                                      │
│  • 사용자 관리     • 실시간 모니터링                   │
│  • 콘텐츠 관리     • AI 설정                         │
│  • 비즈니스 분석   • 시스템 설정                      │
└──────────────────────────────────────────────────────┘
```

## 🛠️ 기술 스택

### Frontend
- **사용자 앱 (Flutter)**
  - Framework: Flutter 3.22.2
  - Language: Dart 3.4.0
  - State Management: Riverpod + Provider
  - Navigation: go_router
  - 플랫폼: Web, iOS, Android, macOS, Windows

- **관리자 대시보드 (Next.js)**
  - Framework: Next.js 14 (App Router)
  - Language: TypeScript
  - UI: shadcn/ui + Tailwind CSS
  - State: TanStack Query
  - Charts: Recharts

### Backend (Supabase - 2025-08-23 변경)
- **Infrastructure**: Supabase
- **Authentication**: Supabase Auth (사용자 + 관리자)
- **Database**: PostgreSQL
- **Real-time**: Supabase Realtime
- **Storage**: Supabase Storage
- **AI Services**: 
  - OpenAI API (AI 모델)
  - pgvector (벡터 DB)
  - Edge Functions (서버리스)

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

### 1. Supabase 연동 (30%)
- [x] 패키지 설치
- [x] 스키마 설계
- [ ] 프로젝트 생성
- [ ] 실제 연동

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
- OpenAI API 연동
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
- **Flutter 에러 수백개**: 주로 타입 미스매치, import 누락
- **Supabase 미연동**: Mock 데이터만 사용 중
- **AI 기능 미구현**: OpenAI API 연동 필요

### 2. 구조적 이슈
- 일부 서비스 간 의존성 복잡
- 모델 클래스 중복 (부분 해결)
- 테스트 코드 부재

### 3. UX 이슈
- 모바일 반응형 미완성
- 일부 애니메이션 미구현
- 오프라인 모드 제한적

## 🎯 즉시 해야 할 작업 (Priority)

### 1. 관리자 대시보드 생성 (Critical)
```bash
# Next.js 프로젝트 생성
npx create-next-app@latest hyle-admin --typescript --tailwind --app
cd hyle-admin
npm install @supabase/supabase-js @tanstack/react-query recharts
npx shadcn-ui@latest init
```

### 2. Supabase 연동 (High)
```bash
# 1. Supabase 프로젝트 생성 (supabase.com)
# 2. 환경 변수 설정
cp .env.example .env
# 3. 데이터베이스 설정
# Supabase 대시보드에서 SQL Editor로 schema.sql 실행
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

**마지막 업데이트**: 2025년 8월 23일
**다음 액션**: Supabase 프로젝트 생성 후 연동

## 🔄 최근 변경사항 (2025-08-23)

### 2025-08-23 Supabase 마이그레이션
1. **백엔드 완전 전환**
   - AWS Amplify 제거
   - Supabase로 전환 완료
   - 설정 시간: 1-2시간 → 5분

2. **온톨로지 데이터베이스 설계**
   - 지식 그래프 구조
   - 사용자 패턴 분석
   - AI 대화 메모리
   - pgvector 임베딩

3. **요금제 전략**
   - 무료: 기본 기능 무제한
   - 프리미엄: AI 기능

### 2025-08-05 업데이트
1. **Flutter 로컬 테스트 환경 실행**
   - `main_test_local.dart`로 성공적으로 실행
   - Chrome에서 테스트 가능 상태
   - AWS 연동 없이 Mock 데이터로 작동

2. **Flutter 에러 현황 분석**
   - 총 1541개 이슈 (대부분 info/warning)
   - 실제 error 약 400개
   - 주요 에러 타입:
     - undefined_named_parameter (85개)
     - undefined_method (85개)
     - argument_type_not_assignable (77개)
     - undefined_getter (35개)

3. **개발 환경 현황**
   - Windows 네이티브 Claude Code 사용 중
   - Flutter 3.32.7 (구버전, 업데이트 가능)
   - Git 2.47.1.windows.1 정상 작동

### 2025-07-26 변경사항
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