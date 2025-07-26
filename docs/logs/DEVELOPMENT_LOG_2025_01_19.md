# Hyle 개발 로그 - 2025년 1월 19일

## 🎯 오늘의 작업 목표
AWS Amplify 연결 및 베타테스트 환경 구축

## 📝 진행 상황

### 1. 프로젝트 현황 파악
- Hyle 프로젝트: AI 기반 학습 동반자 플랫폼
- 목표: 팔란티어 AIP처럼 학습 시 최상의 효율을 낼 수 있도록 돕는 에듀테크 앱
- Flutter 앱 기본 구조 완성
- AWS 백엔드 아키텍처 설계 완료 (Neptune, Pinecone, Kinesis 등)

### 2. 현재 구현 상태
✅ 완료된 기능:
- 통합 대시보드 (오늘의 목표, D-Day, 퀘스트)
- 카테고리 기반 할일 관리
- 게임화된 타이머 (스톱워치, 타이머, 뽀모도로)
- 레벨/XP 시스템
- 퀘스트 시스템 (일일/주간/특별)
- 친구 시스템 및 실시간 상태
- 26개 AI 서비스 파일 작성
- 5개 Lambda 함수 구현

🚧 미완성 기능:
- AWS 실제 연동 (현재 Mock 데이터)
- 학습자 유형 테스트 (16가지 타입)
- AI 튜터 실제 작동
- 스터디 그룹/길드
- 스킨 시스템

### 3. AWS 설정 진행
✅ 완료:
- VSCode(WSL) 터미널에서 Windows AWS CLI 접근 가능 확인
- AWS 프리 티어 계정으로 진행 결정
- IAM 사용자 생성 (Root 대신 보안 강화)
- AdministratorAccess 권한 부여
- Access Key 생성 완료
- .gitignore 업데이트 (보안 파일 제외)

⏳ 진행 중:
- AWS CLI 설정 (aws configure)

📋 예정:
- Amplify CLI 설치
- AWS Amplify 초기화
- Cognito, GraphQL API, S3 설정
- Lambda 함수 배포
- Neptune, Pinecone 등 고급 서비스 연동

### 4. 주요 결정 사항
- 프리 티어로 베타테스트 진행
- IAM 사용자로 안전하게 진행 (Root 사용 X)
- Access Key는 AWS CLI에 직접 설정 (코드에 포함 X)

### 5. 다음 단계
1. AWS CLI 설정 완료
2. Amplify CLI 설치
3. Amplify 프로젝트 초기화
4. 기본 서비스들 설정 및 배포

## 💡 참고 사항
- 실행 명령어: `flutter run -d chrome -t lib/main_test_local.dart`
- AWS CLI 경로 (WSL): `/mnt/c/Program\ Files/Amazon/AWSCLIV2/aws.exe`
- 프리 티어 한도 내에서 모든 기능 구현 가능
- Amazon Q 활용으로 AWS 백엔드 설정 시간 70% 단축 가능
- Amazon Q를 통한 자동 코드 생성 및 보안 설정 최적화

---
*마지막 업데이트: 2025-01-19 진행 중*