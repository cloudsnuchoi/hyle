# Amplify 멀티 환경 설정 가이드

## 🔄 다른 개발 환경에서 Amplify 프로젝트 연결하기

### 문제 상황
- `amplify_outputs.json` 파일이 `.gitignore`에 포함되어 Git에 업로드되지 않음
- 다른 개발 환경(예: Windows → MacBook)에서 같은 Amplify 백엔드에 연결 필요

### 해결 방법

#### 방법 1: Amplify Sandbox 사용 (개발 환경)
```bash
# 1. 프로젝트 클론 후
git clone [repository-url]
cd hyle

# 2. 의존성 설치
npm install

# 3. AWS 자격 증명 설정
aws configure

# 4. Amplify Sandbox 실행
npx ampx sandbox

# 5. amplify_outputs.json 파일이 자동 생성됨
```

#### 방법 2: Amplify Pull 사용 (기존 환경 연결)
```bash
# 1. Amplify CLI 설치
npm install -g @aws-amplify/cli

# 2. 기존 Amplify 앱 정보 확인 (AWS Console에서)
# - App ID 확인
# - Environment name 확인

# 3. Amplify pull 실행
amplify pull --appId [YOUR_APP_ID] --envName [ENV_NAME]

# 예시:
# amplify pull --appId d2vq8bh3example --envName dev
```

#### 방법 3: 팀 협업 설정 (권장)
```bash
# Windows (처음 설정하는 환경)
amplify init
amplify add auth
amplify add storage
amplify push

# MacBook (이어서 작업하는 환경)
amplify pull
amplify env checkout dev
```

### 📁 중요 파일 설명

| 파일 | Git 포함 | 설명 |
|------|----------|------|
| `amplify_outputs.json` | ❌ | 환경별 설정, 자동 생성됨 |
| `amplify/backend/` | ✅ | 인프라 코드 |
| `amplify/team-provider-info.json` | ❌ | 팀 환경 정보 |
| `.amplify/` | ❌ | 로컬 캐시 |

### 🔐 보안 주의사항
- `amplify_outputs.json`은 API 엔드포인트 등 민감한 정보 포함
- 절대 공개 저장소에 커밋하지 말 것
- AWS 자격 증명도 안전하게 관리

### 🛠️ 문제 해결

#### "No Amplify backend found" 오류
```bash
# Sandbox 재실행
npx ampx sandbox --once
```

#### "Invalid configuration" 오류
```bash
# 캐시 삭제 후 재시도
rm -rf .amplify
amplify pull
```

### 📱 Flutter 앱 실행
```bash
# Amplify 설정 완료 후
flutter clean
flutter pub get
flutter run -d chrome
```

### 💡 팁
- 각 개발자는 자신의 Sandbox 환경 사용 가능
- Production 환경은 별도로 관리
- CI/CD 파이프라인에서는 환경 변수로 설정 주입

---
*마지막 업데이트: 2025년 1월 23일*