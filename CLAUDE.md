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