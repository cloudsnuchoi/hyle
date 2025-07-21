# Claude Code 세션 메모리 - Hyle 프로젝트

## 📅 2025년 1월 19일 세션

### 🔄 현재 진행 상황
- **사용자**: AWS 초보자, 프리 티어로 베타테스트 진행 중
- **목표**: Hyle 앱에 AWS Amplify 연결
- **문제**: VSCode PowerShell 터미널에서 AWS CLI 인식 안 됨 (외부 PowerShell에서는 작동)

### ✅ 완료된 작업
1. **프로젝트 전체 리뷰 완료**
   - Hyle: AI 기반 학습 동반자 플랫폼 (팔란티어 AIP 스타일)
   - Flutter 앱 + AWS 백엔드 (Neptune, Pinecone, Kinesis 등)
   - 26개 AI 서비스 파일 구현 완료

2. **AWS 설정 진행**
   - ✅ AWS 프리 티어 계정 로그인
   - ✅ IAM 사용자 생성: `hyle-dev`
   - ✅ AdministratorAccess 권한 부여
   - ✅ Access Key 생성 완료
   - ✅ .gitignore 보안 파일 추가

3. **GitHub 푸시 완료**
   - 커밋: `08cdbb7`
   - 50개 파일 변경, 개발 로그 생성

### ✅ 완료된 작업 (2025년 1월 20일)
1. **AWS CLI 설정 완료**
   - Region: ap-northeast-2 (서울)
   - Output: json

2. **Amplify Gen 2 설정 완료**
   - ✅ Amplify CLI 설치
   - ✅ Amplify Gen 2 프로젝트 생성
   - ✅ CDK Bootstrap 완료
   - ✅ Sandbox 환경 구축

3. **AWS 리소스 생성 완료 (프리 티어)**
   - ✅ Cognito User Pool (인증)
   - ✅ AppSync GraphQL API
   - ✅ S3 Storage Bucket
   - ✅ DynamoDB Tables (User, StudySession, LearningGoal, FlashCard, Mission, Todo)

4. **Flutter 앱 통합**
   - ✅ AmplifyService 생성
   - ✅ amplify_outputs.dart 파일 생성
   - ✅ main.dart에서 Amplify 초기화

### ✅ 완료된 작업 (2025년 1월 21일)
1. **AWS Amplify 인증 통합 완료**
   - ✅ 회원가입 기능 테스트 성공 (이메일 인증 포함)
   - ✅ 로그인 기능 테스트 성공
   - ✅ AWS Cognito에서 사용자 등록 확인
   - ✅ 메인 앱에 인증 통합

2. **Flutter 앱 오류 해결**
   - ✅ 패키지 버전 충돌 해결 (Amplify v2.6.4로 업그레이드)
   - ✅ LocalStorageService 초기화 오류 수정
   - ✅ 학습 유형 테스트 Skip 기능 수정
   - ✅ 학습 유형 결과 후 사용자 정보 업데이트

3. **UI/UX 개선**
   - ✅ 4탭 네비게이션 복원 (대시보드, 투두, 타이머, 더보기)
   - ✅ 더보기 페이지에 메뉴 통합
   - ✅ 스케줄 화면 뷰 전환 기능 수정
   - ✅ 스케줄 이벤트 수정 기능 복원

### 🚧 현재 작업 중
- CLAUDE_CODE_MEMORY.md 업데이트 및 GitHub 푸시

### 📝 Todo List (현재 상태)
1. [completed] AWS CLI 설정
2. [completed] Amplify CLI 설치
3. [completed] AWS Amplify Gen 2 초기화
4. [completed] Hyle 앱에 맞게 Amplify 리소스 커스터마이징
5. [completed] Flutter 앱과 Amplify 연결
6. [completed] 인증 플로우 테스트 (회원가입, 이메일 인증, 로그인)
7. [completed] 메인 앱에 AWS Amplify 인증 통합
8. [completed] UI/UX 버그 수정 (네비게이션, 스케줄)
9. [pending] 실제 데이터 CRUD 테스트

### 🔧 해결 방법들
**VSCode PowerShell에서 AWS 사용하기:**
```powershell
# 임시 alias
Set-Alias aws "C:\Program Files\Amazon\AWSCLIV2\aws.exe"

# 또는 직접 경로 사용
& "C:\Program Files\Amazon\AWSCLIV2\aws.exe" configure
```

**WSL에서 AWS 사용하기:**
```bash
/mnt/c/Program\ Files/Amazon/AWSCLIV2/aws.exe configure
# 또는
./aws-cli.sh configure
```

### 🎯 다음 단계
1. AWS CLI로 자격 증명 설정
   - Access Key ID: (사용자가 보관)
   - Secret Access Key: (사용자가 보관)
   - Region: us-east-1
   - Output: json

2. Amplify CLI 설치
   ```bash
   npm install -g @aws-amplify/cli
   ```

3. Amplify 초기화
   ```bash
   amplify init
   ```

### 💡 중요 참고사항
- 실행 명령어: `flutter run -d chrome -t lib/main_test_local.dart`
- 프로젝트 경로: `C:\dev\git\hyle` (Windows) 또는 `/mnt/c/dev/git/hyle` (WSL)
- AWS가 외부 PowerShell에서는 작동함: `aws-cli/2.27.55`
- Access Key는 절대 코드나 채팅에 포함하지 말 것

### 🚀 다음 단계
1. Flutter 앱 실행
   ```bash
   flutter run -d chrome -t lib/main_test_local.dart
   ```

2. 인증 플로우 테스트
   - 회원가입 → 이메일 인증 → 로그인
   - 로그아웃

3. 데이터 CRUD 테스트
   - User 프로필 생성/수정
   - StudySession 기록
   - Todo 생성/수정/삭제

### 📌 중요 정보
- **Amplify Sandbox 실행 중**: PowerShell 터미널에서 계속 실행 유지
- **AppSync Endpoint**: https://txph7fmx7jetnb2uxc5c5e5hkm.appsync-api.ap-northeast-2.amazonaws.com/graphql
- **Cognito User Pool ID**: ap-northeast-2_fGuO7nfAZ
- **S3 Bucket**: amplify-hyle-administrato-hylestoragebucket910e707-fv2noeex8wow

### 🎯 해결된 주요 문제들
1. **패스워드 정책 불일치**
   - 문제: "No user pool registered for this account"
   - 원인: Amplify 설정과 Cognito 정책 불일치
   - 해결: 패스워드 정책 설정 (8자 이상, 대소문자, 숫자, 특수문자 포함)

2. **패키지 버전 충돌**
   - 문제: drift, web 등 패키지 버전 충돌
   - 해결: Amplify v2.6.4로 업그레이드, 의존성 해결

3. **학습 유형 테스트 후 네비게이션**
   - 문제: 테스트 완료 후 홈으로 이동 안 됨
   - 해결: 사용자 정보 업데이트 및 라우팅 수정

### 🔄 세션 재개 시
이 파일을 읽고 위의 "현재 작업 중" 부분부터 이어서 진행하면 됩니다.

---
*마지막 업데이트: 2025-01-21 AWS Amplify 인증 통합 완료 및 UI/UX 개선*