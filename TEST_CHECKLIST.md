# Hyle 테스트 체크리스트

## 🔵 Phase 1: Mock 데이터로 테스트 (AWS 없이)

Windows PowerShell 또는 터미널에서:

```bash
cd C:\dev\git\hyle
flutter pub get
flutter run -d chrome
```

### 테스트 항목:

1. **기본 네비게이션**
   - [ ] 로그인 화면 표시
   - [ ] 회원가입으로 이동
   - [ ] 학습 유형 테스트 접근

2. **AI 기능 테스트 (Mock)**
   - [ ] 프로필 탭 → "AI 기능 베타 테스트" 버튼
   - [ ] "AI 기능 테스트" 클릭
   - [ ] Mock 학습 계획 생성 확인

3. **대시보드 위젯**
   - [ ] 오늘 할 일 진행률
   - [ ] 퀘스트 시스템
   - [ ] D-Day 위젯
   - [ ] 학습 통계

4. **언어 설정**
   - [ ] 설정에서 한국어/영어 전환
   - [ ] UI 텍스트 변경 확인

## 🟡 Phase 2: Amplify 기본 설정 후 테스트

### 사전 준비:
1. AWS 계정 생성 (https://aws.amazon.com/)
2. AWS CLI 설치
3. Amplify CLI 설치

### 명령어:
```bash
# 1. AWS 자격 증명
aws configure

# 2. Amplify 초기화
amplify init

# 3. 인증 추가
amplify add auth

# 4. 배포
amplify push
```

### 테스트 항목:
- [ ] 실제 회원가입 (이메일 인증)
- [ ] 로그인/로그아웃
- [ ] 비밀번호 재설정
- [ ] 사용자 프로필 저장

## 🟢 Phase 3: 전체 AWS 서비스 연동 후 테스트

### 추가 설정:
```bash
# GraphQL API
amplify add api

# Storage
amplify add storage

# Lambda Functions
amplify add function

# 모두 배포
amplify push
```

### 고급 테스트:
1. **AI 학습 플래너**
   - [ ] "내일 수학 시험 준비해줘" 입력
   - [ ] 실제 AI 응답 확인
   - [ ] 생성된 계획을 Todo에 추가

2. **실시간 모니터링**
   - [ ] 타이머 시작 → Kinesis 이벤트
   - [ ] 30분 이상 학습 → 휴식 알림
   - [ ] 집중도 저하 감지

3. **데이터 동기화**
   - [ ] 오프라인에서 작업
   - [ ] 온라인 복귀 시 동기화
   - [ ] 여러 기기에서 접속

## 🔴 Phase 4: 프로덕션 테스트

### 성능 테스트:
- [ ] 100개 이상 Todo 처리
- [ ] 긴 학습 세션 (2시간+)
- [ ] 동시 사용자 시뮬레이션

### 보안 테스트:
- [ ] API 권한 검증
- [ ] 데이터 암호화 확인
- [ ] Rate limiting 테스트

## 📱 모바일 테스트 (선택사항)

### Android:
```bash
flutter run -d android
```

### iOS:
```bash
flutter run -d ios
```

## 🐛 일반적인 문제 해결

### "Amplify has not been configured" 오류
```dart
// lib/main.dart 확인
await _configureAmplify(); // 이 줄이 있는지 확인
```

### CORS 오류 (웹)
```bash
# amplify/backend/api/hyle/schema.graphql 수정 후
amplify push
```

### 인증 토큰 만료
```dart
// 자동 갱신 확인
Amplify.Auth.fetchAuthSession(
  options: CognitoSessionOptions(getAWSCredentials: true),
);
```

## 📊 테스트 결과 기록

| 기능 | 상태 | 문제점 | 해결방법 |
|------|------|--------|----------|
| 로그인 | ✅ | - | - |
| AI 플래너 | 🔄 | Mock 데이터만 | AWS 연동 필요 |
| 타이머 | ✅ | - | - |
| 퀘스트 | ✅ | - | - |

---

테스트 중 발견한 문제는 GitHub Issues에 기록해주세요!