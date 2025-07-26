# AWS Amplify 빠른 시작 가이드

## 🚀 5분 안에 시작하기 (Amazon Q 활용)

### 1. 사전 준비
```bash
# Node.js 설치 확인
node --version  # v14 이상

# AWS CLI 설치
# Windows: https://aws.amazon.com/cli/ 다운로드
# macOS: brew install awscli

# Amplify CLI 설치
npm install -g @aws-amplify/cli
```

### 2. Amazon Q 설정
1. VSCode에서 AWS Toolkit Extension 설치
2. Amazon Q 패널 열기
3. AWS 계정 연결

### 3. Amazon Q로 Amplify 초기화
Amazon Q에 입력:
```
Initialize Amplify for Flutter edtech app called Hyle with:
- Cognito authentication (email/password)
- GraphQL API with real-time subscriptions
- S3 storage for user uploads
- DynamoDB for data persistence
```

### 4. Flutter 프로젝트에 통합
```bash
# PowerShell에서 실행
cd C:\dev\git\hyle
flutter pub add amplify_flutter amplify_auth_cognito amplify_api amplify_storage_s3
flutter pub get
```

### 5. 실행
```bash
# 개발 모드
flutter run -d chrome -t lib/main_dev.dart

# AWS 연동 모드
flutter run -d chrome -t lib/main.dart
```

## 📋 체크리스트

- [ ] AWS 계정 생성
- [ ] IAM 사용자 설정
- [ ] Amplify CLI 설치
- [ ] Amazon Q 연결
- [ ] Amplify 초기화
- [ ] Flutter 패키지 추가

## 🔗 다음 단계

- [상세 설정 가이드](./DETAILED_SETUP.md) - 수동 설정 방법
- [Amazon Q 고급 활용](./AMAZON_Q_GUIDE.md) - AI 서비스 연동