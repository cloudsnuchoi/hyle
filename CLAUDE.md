# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
# Run development mode (recommended)
flutter run -d chrome -t lib/main_dev.dart

# Run test mode
flutter run -d chrome -t lib/main_test.dart

# Run test mode with local data
flutter run -d chrome -t lib/main_test_local.dart

# Analyze code
flutter analyze
# or
./analyze.sh

# Install dependencies
flutter pub get

# Supabase backend setup (NEW - 2025-08-23)
# 1. Create project at supabase.com
# 2. Copy .env.example to .env and add your credentials
# 3. Apply database schema: supabase/schema.sql
```

## Development Environment Notes

### ~~WSL/Claude Code Limitations~~ (해결됨 2025-07-26)
- ~~Claude Code runs in WSL and may not execute Flutter/Amplify commands properly~~
- **해결**: Windows 네이티브 Claude Code 사용 시 모든 명령어 정상 작동
- 참고: [CROSS_PLATFORM_DEVELOPMENT_GUIDE.md](./CROSS_PLATFORM_DEVELOPMENT_GUIDE.md)

### Cross-Platform Development
- Primary: Windows (Claude Code Native)
- Secondary: macOS (for mobile work)
- Claude Code에서 모든 명령어 직접 실행 가능

## High-Level Architecture

### Frontend (Flutter)
- **State Management**: Riverpod + Provider pattern
- **Navigation**: go_router with authentication guards
- **Entry Points**: 
  - `main.dart` - Production with Supabase
  - `main_dev.dart` - Development mode
  - `main_test.dart` - Test mode with mock data
  - `main_test_local.dart` - Test mode with local storage

### Backend (Supabase) - 100% Supabase 전환 완료
- **Authentication**: Supabase Auth (이메일, 소셜 로그인)
- **Database**: PostgreSQL with real-time subscriptions
- **Storage**: Supabase Storage for file uploads
- **AI Features**: OpenAI API integration (planned)
- **Configuration**: `.env` file for credentials
- **Schema**: `supabase/schema.sql` defines database structure
- **Admin**: HYLE Admin Dashboard로 모든 데이터 관리

### Key Architectural Patterns
1. **Feature-based structure**: Each feature in `/lib/features/` has its own screens, widgets, and logic
2. **Service layer**: Business logic separated in `/lib/services/`
3. **Provider pattern**: State management uses providers for reactive UI updates
4. **Mock services**: Test modes use mock implementations for offline development

### Critical Files for Understanding
- `lib/routes/app_router.dart` - Navigation structure and guards
- `lib/services/supabase_service.dart` - Supabase integration (NEW)
- `lib/providers/auth_provider.dart` - Authentication state management
- `supabase/schema.sql` - Database schema definition (NEW)
- `lib/core/theme/app_theme.dart` - Design system implementation

### Testing Approach
- No traditional test directory structure
- Test entry points in root: `main_test.dart`, `main_test_local.dart`
- Use `flutter analyze` or `./analyze.sh` for linting
- Manual testing through different entry points recommended

## Recent Updates (2025-08-23)

### 2025-08-23 Supabase 마이그레이션 완료
- **백엔드 완전 전환**
  - AWS Amplify → Supabase로 전환
  - PostgreSQL + 실시간 기능 사용
  - 설정 시간: AWS 1-2시간 → Supabase 5분
- **요금제 전략 수립**
  - 무료: 기본 기능 (학습 로그, 투두, 타이머 무제한)
  - 프리미엄: AI 기능 (대화 메모리, 패턴 분석, 개인화)
- **온톨로지 구조 설계**
  - 지식 그래프 (knowledge_nodes)
  - 사용자 패턴 분석 (user_patterns)
  - AI 대화 메모리 (ai_conversations)
  - pgvector로 임베딩 저장
- **파일 정리**
  - AWS 관련 파일 모두 삭제
  - Supabase 서비스 클래스 생성
  - 에러 대폭 감소 (1500개 → 수백개)

## Recent Updates (2025-08-05)

### 2025-08-05 업데이트
- **Flutter 로컬 테스트 실행 성공**
  - `main_test_local.dart`로 Chrome에서 정상 실행
  - Mock 데이터로 모든 기능 테스트 가능
- **Flutter 에러 분석 완료**
  - 총 1541개 이슈 (대부분 info/warning)
  - 실제 error 약 400개
  - 주요 에러: undefined_named_parameter, undefined_method, argument_type_not_assignable
- **개발 환경 상태**
  - Windows 네이티브 Claude Code 사용 중
  - Git 2.47.1 정상 작동
  - Flutter 3.32.7 (업데이트 권장)

## Recent Updates (2025-07-26)

### Windows 네이티브 Claude Code 전환 완료
- Claude Desktop Windows 네이티브 버전 설치 및 전환
- 모든 CLI 도구가 Claude Code 내에서 정상 작동 확인
- 설치된 도구 버전:
  - Flutter 3.32.7 (업데이트 가능)
  - AWS CLI 2.27.55
  - Amplify CLI 14.0.0 (새로 설치)
  - Vercel CLI 44.6.3 (새로 설치)
  - v0 CLI (새로 설치)
  - Python 3.13.1 (최신 안정 버전: 3.13.5)
- 더 이상 별도 PowerShell 터미널 불필요

### 문서 구조 개선 완료
- 모든 문서가 `docs/` 폴더로 체계적으로 재구성됨
- Amazon Q 개발 가이드 추가 (AWS 설정 시간 70% 단축)
- 크로스 플랫폼 개발 가이드 추가 (Windows/macOS)
- 20개 이상의 중복 문서 정리 및 통합
- `HYLE_PROJECT_OVERVIEW.md` - 통합 프로젝트 현황 문서 생성
- `QUICK_COMMANDS.md` - PowerShell 빠른 명령어 가이드 추가

### 개발 환경 결정
- ~~WSL에서 코드 편집 (Claude Code)~~ → Windows 네이티브 Claude Code로 전환 완료 (2025-07-26)
- ~~PowerShell에서 명령어 실행~~ → Claude Code에서 직접 실행 가능
- Claude Desktop Windows 네이티브 버전으로 전환 완료
- 모든 CLI 도구가 Claude Code 내에서 정상 작동

### 현재 작업 상태
- Flutter 로컬 테스트 모드 정상 실행 중
- Flutter analyze 에러 약 400개 (타입 관련)
- Supabase 백엔드 연동 진행 중
- 문서 구조 정리 완료 (docs/ 폴더)
- Windows 네이티브 Claude Code 사용 중

### 다음 작업 계획 (24시간 내 출시)
1. Supabase 프로젝트 생성 및 설정
2. Flutter 타입 에러 수정 + Supabase 연동
3. HYLE Admin Dashboard 배포 (Vercel)
4. 학습자 유형 테스트 (16가지 타입) 구현
5. AI 튜터 실제 작동 연결

### 주요 파일 위치
- 통합 현황: `HYLE_PROJECT_OVERVIEW.md`
- 빠른 명령어: `QUICK_COMMANDS.md`
- Supabase 가이드: `SUPABASE_QUICKSTART.md`
- 개발 로그: `docs/logs/DEVELOPMENT_LOG_2025_08_05.md`