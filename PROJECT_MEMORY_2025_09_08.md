# 📚 HYLE 프로젝트 통합 메모리
*최종 업데이트: 2025년 9월 8일*

## 🎯 프로젝트 개요
- **프로젝트명**: HYLE (AI Learning Companion)
- **비전**: 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로
- **개발 시작**: 2025년 1월
- **현재 단계**: MVP 개발 중 (Flutter 앱 + Admin Dashboard)

## 🗂️ 프로젝트 구조

### 1️⃣ HYLE (메인 Flutter 앱)
- **경로**: `/Users/junhoochoi/dev/github desktop/hyle`
- **기술 스택**: Flutter 3.32.7, Dart, Riverpod
- **백엔드**: Supabase (2025-08-23 마이그레이션 완료)
- **UI 구조**: 19개 Feature 모듈, 41개 스크린
- **현재 상태**: 
  - ✅ `main.dart` 실행 중 (Chrome)
  - ✅ `LoginScreenEnhanced` 사용 중
  - ⚠️ 타입 에러 약 400개 존재

### 2️⃣ HYLE-Admin (관리자 대시보드)
- **경로**: `/Users/junhoochoi/dev/github desktop/hyle-admin`
- **기술 스택**: Next.js 14, TypeScript, Tailwind CSS
- **배포**: ✅ Vercel (hyle-admin-2c3w.vercel.app)
- **현재 상태**: 완전 작동 중

### 3️⃣ HYLE-Essay-Analysis (논술 분석)
- **경로**: `/Users/junhoochoi/dev/github desktop/hyle-essay-analysis`
- **목적**: 인문논술 AI 채점 시스템
- **현재 상태**: 데이터 수집 및 DB 설계 완료

## 📱 Flutter 앱 UI 구조

### 핵심 화면 (Enhanced 버전 사용)
1. **인증**: `LoginScreenEnhanced` (애니메이션 배경, 떠다니는 도형)
2. **홈**: `HomeScreen` → `IntegratedDashboard`
3. **투두**: `TodoScreenEnhanced`
4. **타이머**: `TimerScreenEnhanced` / `TimerScreenGamified`
5. **노트**: `NotesScreenEnhanced`
6. **프로필**: `ProfileScreenImproved`

### 네비게이션 구조
```
SplashScreen → LoginScreenEnhanced → HomeScreen
                                         ↓
                              [대시보드, 투두, 타이머, 더보기]
```

## 🔄 최근 작업 내역

### 2025-09-08 (오늘)
- Flutter 앱 실행 (`main.dart` 사용)
- UI 구조 분석 완료 (19개 모듈, 41개 스크린)
- Enhanced UI 버전들 확인 및 적용
- `AppColors.tertiary` 에러 수정

### 2025-09-02
- 인문논술 AI 시스템 DB 설계
- 온톨로지 + GraphRAG 기반 채점 시스템
- 10개 대학 데이터 구조 설계

### 2025-08-31
- HYLE Admin Dashboard Vercel 배포 성공
- 환경 변수 설정 완료
- 로그인 기능 정상 작동

### 2025-08-23
- AWS Amplify → Supabase 마이그레이션 완료
- PostgreSQL + 실시간 기능 전환
- 에러 대폭 감소 (1500개 → 400개)

## ⚠️ 현재 이슈

### 긴급
1. Flutter 타입 에러 약 400개 수정 필요
2. Supabase 실제 연동 테스트 필요

### 중요
1. AI 기능 실제 구현 필요
2. 논술 기출문제 데이터 입력 필요
3. 사용자 테스트 준비

## 🎯 다음 목표

### 단기 (1주일)
- [ ] Flutter 타입 에러 모두 해결
- [ ] Supabase 연동 완전 테스트
- [ ] 핵심 기능 3개 완성 (투두, 타이머, 노트)

### 중기 (1개월)
- [ ] AI 튜터 기능 구현
- [ ] 학습 유형 테스트 완성
- [ ] 베타 테스트 시작

### 장기 (3개월)
- [ ] 논술 AI 채점 시스템 완성
- [ ] 정식 출시
- [ ] 사용자 1000명 확보

## 📁 핵심 문서 위치

### 프로젝트 현황
- `PROJECT_STATUS.md` - 전체 현황
- `HYLE_PROJECT_OVERVIEW.md` - 시스템 아키텍처
- `PROJECT_MEMORY_2025_09_08.md` - 최신 통합 메모리 (이 파일)

### Claude 가이드
- `CLAUDE.md` - Claude Code 개발 가이드
- `CLAUDE_PLAN_MODE_GUIDE.md` - 계획 모드 사용법

### 개발 로그
- `docs/logs/` - 모든 개발 로그
- `MEMORY_2025_09_02_ESSAY_AI_DEVELOPMENT.md` - 논술 AI 개발

### 설정 가이드
- `SUPABASE_QUICKSTART.md` - Supabase 설정
- `docs/setup/` - 각종 환경 설정 가이드

## 🔑 중요 정보

### Supabase 프로젝트
- URL: [Supabase Dashboard에서 확인]
- Anon Key: `.env` 파일 참조
- Service Key: `.env.local` 파일 참조

### GitHub
- HYLE: https://github.com/cloudsnuchoi/hyle
- Admin: https://github.com/cloudsnuchoi/hyle-admin

### 배포 URL
- Admin: https://hyle-admin-2c3w.vercel.app

## 💡 개발 팁

### Flutter 실행
```bash
# 개발 모드 (Supabase 연결)
flutter run -d chrome -t lib/main.dart

# 테스트 모드 (Mock 데이터)
flutter run -d chrome -t lib/main_test.dart

# 로컬 테스트 (오프라인)
flutter run -d chrome -t lib/main_test_local.dart
```

### 에러 확인
```bash
flutter analyze
```

## 📌 Remember
1. **항상 `main.dart` 사용** (main_test.dart 아님!)
2. **Enhanced UI 버전 우선 사용**
3. **불필요한 파일 생성 금지**
4. **기존 코드 수정 우선**
5. **Context 유지를 위해 이 파일 참조**