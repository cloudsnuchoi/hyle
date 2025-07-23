# Amplify Gen2 환경 공유 가이드

## 📅 작성일: 2025년 7월 24일

## 🔄 Amplify Gen2 환경 공유 방법

### 현재 상황
- Windows WSL에서 Amplify Sandbox 실행 중
- MacBook에서 동일한 백엔드 환경 사용하려고 함
- `amplify_outputs.json`은 보안상 Git에 포함 안 됨

### 방법 1: Sandbox 공유 (개발 환경) ✅
```bash
# Windows (현재 실행 중)
npx ampx sandbox

# Sandbox는 개인 개발 환경이므로 각자 실행
# MacBook에서도 동일하게:
npx ampx sandbox
```

### 방법 2: Branch 환경 배포 (팀 협업) 🚀
```bash
# 1. Branch 환경 생성 (Windows에서)
npx ampx branch create feature-branch

# 2. 환경 정보 확인
npx ampx info

# 3. MacBook에서 같은 branch 연결
git checkout feature-branch
npx ampx generate outputs --branch feature-branch
```

### 방법 3: Pipeline 배포 (Production) 🏭
```bash
# 1. 배포 파이프라인 생성
npx ampx pipeline init

# 2. GitHub Actions 또는 AWS CodePipeline 설정
# 3. main branch push 시 자동 배포
```

## 🎯 MacBook에서 작업 이어가기

### Step 1: 코드 받기
```bash
git pull origin main
cd hyle
```

### Step 2: 의존성 설치
```bash
npm install
flutter pub get
```

### Step 3: AWS 설정
```bash
# AWS CLI 설치 (Homebrew 사용)
brew install awscli

# AWS 자격 증명 설정
aws configure
# Access Key ID: [Windows와 동일]
# Secret Access Key: [Windows와 동일]
# Default region: ap-northeast-2
# Default output: json
```

### Step 4: Amplify 환경 생성
```bash
# 옵션 A: 개인 Sandbox (권장)
npx ampx sandbox

# 옵션 B: 공유 Branch
npx ampx generate outputs --branch main

# 옵션 C: 기존 Stack 연결
npx ampx generate outputs --stack [STACK_NAME]
```

### Step 5: Flutter 실행
```bash
flutter run -d chrome
```

## 📝 중요 참고사항

### Amplify Gen2 vs Gen1 차이점
| 기능 | Gen1 | Gen2 |
|------|------|------|
| 환경 관리 | `amplify env` | Git branch 기반 |
| 배포 | `amplify push` | `npx ampx` |
| 설정 파일 | `amplify/` 폴더 | TypeScript 코드 |
| 팀 협업 | `team-provider-info.json` | Branch/Pipeline |

### 파일 구조
```
hyle/
├── amplify/
│   ├── backend.ts          # ✅ Git 포함 (인프라 코드)
│   ├── auth/resource.ts    # ✅ Git 포함
│   ├── data/resource.ts    # ✅ Git 포함
│   └── storage/resource.ts # ✅ Git 포함
├── amplify_outputs.json    # ❌ Git 제외 (자동 생성)
└── .amplify/               # ❌ Git 제외 (로컬 캐시)
```

## 🔧 문제 해결

### "No outputs file found" 오류
```bash
# Sandbox 재실행
npx ampx sandbox --once

# 또는 수동 생성
npx ampx generate outputs
```

### "Stack not found" 오류
```bash
# Stack 목록 확인
npx ampx info --list-stacks

# 새 Sandbox 생성
npx ampx sandbox --identifier my-sandbox
```

## 🌟 권장 워크플로우

1. **개발 중**: 각자 Sandbox 사용
2. **PR 생성**: Branch 환경 자동 생성
3. **Merge**: Main 환경 자동 업데이트
4. **Production**: 별도 Pipeline 배포

## 📚 참고 자료
- [Amplify Gen2 Docs](https://docs.amplify.aws/gen2/)
- [Team Workflows](https://docs.amplify.aws/gen2/deploy-and-host/team-workflows/)
- [Sandbox Environments](https://docs.amplify.aws/gen2/deploy-and-host/sandbox/)

---
*마지막 업데이트: 2025년 7월 24일*