# Hyle 빠른 명령어 가이드 (PowerShell용)

> 이 파일을 PowerShell 터미널 옆에 열어두고 필요한 명령어를 복사해서 사용하세요.

## 🚀 Flutter 명령어

```powershell
# 개발 모드 실행
cd C:\dev\git\hyle
flutter run -d chrome -t lib/main_dev.dart

# 테스트 모드 실행
flutter run -d chrome -t lib/main_test_local.dart

# 코드 분석
flutter analyze

# 의존성 설치
flutter pub get

# 클린 빌드
flutter clean
flutter pub get
```

## 🔧 AWS Amplify 명령어

```powershell
# Amplify 초기화
cd C:\dev\git\hyle
amplify init

# 인증 추가
amplify add auth

# API 추가
amplify add api

# 스토리지 추가
amplify add storage

# 변경사항 배포
amplify push

# 현재 상태 확인
amplify status

# 로컬 환경 시작
amplify mock
```

## ⚙️ AWS CLI 명령어

```powershell
# AWS 설정
aws configure --profile hyle

# 프로필 확인
aws configure list --profile hyle

# S3 버킷 목록
aws s3 ls --profile hyle

# CloudFormation 스택 확인
aws cloudformation list-stacks --profile hyle
```

## 📱 개발 워크플로우

### 1. 프로젝트 시작
```powershell
# PowerShell Terminal 1
cd C:\dev\git\hyle
flutter run -d chrome -t lib/main_dev.dart

# PowerShell Terminal 2 (선택사항)
cd C:\dev\git\hyle
flutter analyze --watch
```

### 2. AWS 백엔드 설정
```powershell
# Step 1: Amplify 초기화
amplify init
# - Name: hyle
# - Environment: dev
# - Editor: Visual Studio Code
# - App type: flutter

# Step 2: 인증 추가
amplify add auth
# - Default configuration with email

# Step 3: API 추가
amplify add api
# - GraphQL
# - Authorization: Amazon Cognito User Pool

# Step 4: 배포
amplify push
```

### 3. 환경 변수 설정
```powershell
# Windows 환경 변수 설정
[Environment]::SetEnvironmentVariable("AWS_PROFILE", "hyle", "User")
```

## 🛠️ 문제 해결

### Flutter 웹 포트 충돌
```powershell
# 3000번 포트 사용 중인 프로세스 확인
netstat -ano | findstr :3000

# 프로세스 종료
taskkill /PID <프로세스ID> /F
```

### Amplify 에러
```powershell
# 캐시 클리어
amplify env remove dev
amplify init
```

### 크롬 실행 안 될 때
```powershell
# 다른 브라우저로 실행
flutter run -d edge -t lib/main_dev.dart
```

## 📌 자주 사용하는 조합

```powershell
# 새로운 기능 개발 시작
git pull origin main
flutter pub get
flutter run -d chrome -t lib/main_dev.dart

# 코드 수정 후 확인
flutter analyze
git add .
git commit -m "feat: 새 기능 추가"
git push origin main

# AWS 리소스 추가 후
amplify add <service>
amplify push
git add .
git commit -m "feat: AWS <service> 추가"
```

---
💡 **팁**: 이 파일을 PowerShell 터미널과 함께 열어두면 명령어를 빠르게 찾아 사용할 수 있습니다!