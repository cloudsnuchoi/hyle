# Hyle 크로스 플랫폼 개발 가이드

## 🖥️ 개발 환경 개요
- **메인 환경**: Windows (WSL 사용)
- **보조 환경**: macOS (외부 작업용)
- **IDE**: Claude Code (WSL), VSCode, Android Studio

## ⚠️ 중요 사항: Claude Code on WSL 제한사항

### 문제점
Claude Code가 WSL에서 실행될 때, Flutter/Amplify/AWS 명령어가 제대로 실행되지 않을 수 있습니다.

### 해결책
**별도의 PowerShell 터미널을 열어서 명령어 실행**

```powershell
# PowerShell에서 실행
cd C:\dev\git\hyle
flutter run -d chrome -t lib/main_dev.dart
```

## 📁 Windows 환경 설정

### 1. 필수 소프트웨어
- Flutter SDK (C:\flutter)
- Node.js & npm
- AWS CLI
- Git
- Chrome (Flutter 웹 개발용)

### 2. 환경 변수 설정
```powershell
# PowerShell 관리자 권한으로 실행
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\flutter\bin", "User")
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\Program Files\Amazon\AWSCLIV2", "User")
```

### 3. 작업 흐름
1. **Claude Code (WSL)**
   - 코드 작성 및 수정
   - 파일 탐색 및 읽기
   - Git 작업

2. **PowerShell (별도 터미널)**
   - Flutter 명령어 실행
   - Amplify CLI 실행
   - AWS CLI 실행
   - npm 명령어 실행

## 🍎 macOS 환경 설정

### 1. Homebrew로 설치
```bash
# Flutter
brew install --cask flutter

# Node.js
brew install node

# AWS CLI
brew install awscli

# Amplify CLI
npm install -g @aws-amplify/cli
```

### 2. 환경 동기화
```bash
# Git으로 최신 코드 받기
git pull origin main

# 의존성 설치
flutter pub get
npm install

# AWS 프로필 설정 (Windows와 동일하게)
aws configure --profile hyle
```

## 🔄 크로스 플랫폼 동기화 전략

### 1. Git 브랜치 전략
```bash
# Windows에서 작업 완료 후
git add .
git commit -m "feat: Windows에서 작업한 내용"
git push origin feature/your-feature

# macOS에서
git pull origin feature/your-feature
```

### 2. 환경별 설정 파일
```dart
// lib/config/environment.dart
class Environment {
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;
  
  static String get awsRegion {
    // 환경별 다른 설정 가능
    return 'ap-northeast-2';
  }
}
```

### 3. .gitignore 설정
```gitignore
# Windows specific
*.exe
thumbs.db

# macOS specific
.DS_Store
*.swp

# IDE specific
.idea/
.vscode/
*.iml

# AWS
amplify_outputs.json
amplify/.config/
amplify/backend/.temp/
```

## 💻 Claude Code + PowerShell 워크플로우

### 1. 프로젝트 시작
```powershell
# PowerShell Terminal 1
cd C:\dev\git\hyle
flutter run -d chrome -t lib/main_dev.dart

# PowerShell Terminal 2 (로그 확인용)
cd C:\dev\git\hyle
flutter analyze --watch
```

### 2. Amplify 작업
```powershell
# PowerShell에서 실행
amplify init
amplify add auth
amplify push

# 상태 확인
amplify status
```

### 3. 테스트 실행
```powershell
# PowerShell Terminal
flutter test
flutter analyze
```

## 🛠️ 유용한 스크립트

### Windows PowerShell 스크립트
`run-dev.ps1`:
```powershell
# 개발 환경 실행 스크립트
Write-Host "Starting Hyle Development Environment..." -ForegroundColor Green
Set-Location "C:\dev\git\hyle"

# Flutter 체크
Write-Host "Checking Flutter..." -ForegroundColor Yellow
flutter doctor

# 의존성 설치
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# 개발 서버 실행
Write-Host "Starting Flutter dev server..." -ForegroundColor Green
flutter run -d chrome -t lib/main_dev.dart
```

### macOS 스크립트
`run-dev.sh`:
```bash
#!/bin/bash
echo "Starting Hyle Development Environment..."
cd ~/dev/git/hyle

# Flutter 체크
echo "Checking Flutter..."
flutter doctor

# 의존성 설치
echo "Installing dependencies..."
flutter pub get

# 개발 서버 실행
echo "Starting Flutter dev server..."
flutter run -d chrome -t lib/main_dev.dart
```

## 📝 주의사항

### 1. 경로 차이
- **Windows**: `C:\dev\git\hyle`
- **WSL**: `/mnt/c/dev/git/hyle`
- **macOS**: `~/dev/git/hyle`

### 2. 줄바꿈 문자
```bash
# Git 설정으로 자동 변환
git config --global core.autocrlf true  # Windows
git config --global core.autocrlf input # macOS
```

### 3. 권한 문제
- Windows: 관리자 권한 PowerShell 사용
- macOS: sudo 필요한 경우 명시

## 🚀 Quick Commands

### Windows PowerShell
```powershell
# 개발 시작
cd C:\dev\git\hyle; flutter run -d chrome -t lib/main_dev.dart

# Amplify 상태
amplify status

# 분석
flutter analyze

# Git 상태
git status
```

### macOS Terminal
```bash
# 개발 시작
cd ~/dev/git/hyle && flutter run -d chrome -t lib/main_dev.dart

# Amplify 상태
amplify status

# 분석
flutter analyze

# Git 상태
git status
```

## 🔧 트러블슈팅

### WSL에서 Flutter 명령어가 안 될 때
```powershell
# PowerShell에서 실행
flutter doctor -v
```

### Amplify 인증 문제
```powershell
# Windows와 macOS 모두
amplify configure --profile hyle
```

### 포트 충돌
```powershell
# Windows
netstat -ano | findstr :3000

# macOS
lsof -i :3000
```

---

**Remember**: Claude Code는 코드 작성용, PowerShell/Terminal은 실행용!