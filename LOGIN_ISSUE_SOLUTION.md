# 크로스플랫폼 로그인 문제 해결 가이드

## 현재 문제
- Windows Sandbox User Pool: `ap-northeast-2_J52hM6HVc`
- Mac이 같은 User Pool 사용 시도
- Windows가 꺼져있으면 접근 불가 → 로그인 실패

## 즉시 해결 방법

### 방법 1: Mac에서 자체 Sandbox 실행 (가장 빠름)
```bash
# 1. 기존 outputs 백업
mv amplify_outputs.json amplify_outputs.json.windows

# 2. Mac용 Sandbox 실행
npx ampx sandbox

# 3. 새로운 User Pool 생성됨
# 4. Mac에서 새로 회원가입 필요
```

### 방법 2: Windows Sandbox 접근 가능하게 만들기
Windows가 켜져있고 같은 네트워크에 있다면:
- Windows 방화벽 설정 확인
- WSL2 네트워크 브리지 설정
- 하지만 복잡하고 불안정함

### 방법 3: Production 배포 (영구 해결) ✅

## Production 배포로 영구 해결

### Windows에서 (1회만)
1. GitHub에 최신 코드 push
2. AWS Amplify Console 접속
3. "Host web app" → GitHub 연결
4. 배포 완료 후 Production User Pool 생성됨

### Mac에서
```bash
# Production 백엔드 연결
npx ampx generate outputs --branch main

# 새로운 amplify_outputs.json 생성됨:
# User Pool: ap-northeast-2_PROD123 (Production)
```

### 결과
- Windows/Mac 모두 같은 Production User Pool 사용
- 한 번 가입한 계정으로 어디서든 로그인 가능
- 24/7 접근 가능

## 정리

### 문제 원인
```
Windows Sandbox User Pool ← Windows만 접근 가능
           ↑
    Mac이 접근 시도 → 실패
```

### 해결 후
```
AWS Production User Pool ← Windows 접근 ✅
           ↑
         Mac 접근 ✅
```

## 당장 테스트하려면

### 옵션 A: 각자 Sandbox (빠르지만 데이터 분리)
```bash
# Mac에서
rm amplify_outputs.json
npx ampx sandbox
# 새로 회원가입 필요
```

### 옵션 B: Production 배포 (시간 걸리지만 완벽)
- Windows에서 Amplify Console 설정
- Mac에서 Production 연결
- 같은 계정으로 로그인 가능