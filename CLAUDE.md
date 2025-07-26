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

# AWS Amplify backend (from project root)
npm install
amplify sandbox  # Start development environment
```

## Development Environment Notes

### WSL/Claude Code Limitations
- Claude Code runs in WSL and may not execute Flutter/Amplify commands properly
- **Solution**: Open a separate PowerShell terminal for command execution
- See [CROSS_PLATFORM_DEVELOPMENT_GUIDE.md](./CROSS_PLATFORM_DEVELOPMENT_GUIDE.md) for details

### Cross-Platform Development
- Primary: Windows (with WSL for Claude Code)
- Secondary: macOS (for mobile work)
- Always use PowerShell on Windows for Flutter/AWS commands

## High-Level Architecture

### Frontend (Flutter)
- **State Management**: Riverpod + Provider pattern
- **Navigation**: go_router with authentication guards
- **Entry Points**: 
  - `main.dart` - Production with AWS Amplify
  - `main_dev.dart` - Development mode
  - `main_test.dart` - Test mode with mock data
  - `main_test_local.dart` - Test mode with local storage

### Backend (AWS Amplify Gen2)
- **Authentication**: AWS Cognito with email verification
- **Data API**: AppSync GraphQL with DynamoDB
- **Storage**: S3 for file uploads
- **Configuration**: `amplify/backend.ts` defines all resources
- **Output**: `amplify_outputs.json` contains runtime configuration

### Key Architectural Patterns
1. **Feature-based structure**: Each feature in `/lib/features/` has its own screens, widgets, and logic
2. **Service layer**: Business logic separated in `/lib/services/`
3. **Provider pattern**: State management uses providers for reactive UI updates
4. **Mock services**: Test modes use mock implementations for offline development

### Critical Files for Understanding
- `lib/routes/app_router.dart` - Navigation structure and guards
- `lib/services/amplify_service.dart` - AWS Amplify integration
- `lib/providers/auth_provider.dart` - Authentication state management
- `amplify/backend.ts` - Backend resource definitions
- `lib/core/theme/app_theme.dart` - Design system implementation

### Testing Approach
- No traditional test directory structure
- Test entry points in root: `main_test.dart`, `main_test_local.dart`
- Use `flutter analyze` or `./analyze.sh` for linting
- Manual testing through different entry points recommended

## Recent Updates (2025-07-26)

### 문서 구조 개선 완료
- 모든 문서가 `docs/` 폴더로 체계적으로 재구성됨
- Amazon Q 개발 가이드 추가 (AWS 설정 시간 70% 단축)
- 크로스 플랫폼 개발 가이드 추가 (Windows/macOS)
- 20개 이상의 중복 문서 정리 및 통합
- `HYLE_PROJECT_OVERVIEW.md` - 통합 프로젝트 현황 문서 생성
- `QUICK_COMMANDS.md` - PowerShell 빠른 명령어 가이드 추가

### 개발 환경 결정
- WSL에서 코드 편집 (Claude Code)
- PowerShell에서 명령어 실행 (Flutter, AWS, Amplify)
- WSL 내 도구 설정 시도했으나 PowerShell 사용이 더 안정적
- Claude Desktop Windows 네이티브 버전 출시됨 (전환 가능)

### 현재 작업 상태
- AWS Amplify 백엔드 연동 대기 중
- Flutter analyze 에러 약 100개 미만
- 로컬 테스트 모드로 개발 진행 중
- 문서 구조 정리 완료 (docs/ 폴더)
- Amplify CLI v14.0.0 WSL에 설치됨 (하지만 PowerShell 사용 권장)

### 다음 작업 계획
1. Amazon Q 설치 및 AWS Amplify 백엔드 연동
2. 학습자 유형 테스트 (16가지 타입) 구현
3. AI 튜터 실제 작동 연결
4. Flutter analyze 에러 수정

### 주요 파일 위치
- 통합 현황: `HYLE_PROJECT_OVERVIEW.md`
- 빠른 명령어: `QUICK_COMMANDS.md`
- AWS 가이드: `docs/aws/`
- 개발 로그: `docs/logs/DEVELOPMENT_LOG_2025_07_26.md`