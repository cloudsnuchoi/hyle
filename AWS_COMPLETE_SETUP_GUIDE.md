# Hyle AWS 전체 시스템 설정 가이드

## 🏗️ 아키텍처 개요

Hyle은 팔란티어 AIP 수준의 AI 학습 플랫폼으로, 다음 AWS 서비스들을 통합합니다:

### 핵심 서비스
- **AWS Amplify**: 인증, API, 스토리지, 분석
- **Amazon Bedrock**: Claude 3 Opus를 통한 AI 튜터
- **Amazon Neptune**: 온톨로지 지식 그래프
- **Amazon Kinesis**: 실시간 이벤트 처리
- **Amazon SageMaker**: 커스텀 ML 모델
- **Amazon Personalize**: 개인화 추천
- **Pinecone**: 벡터 임베딩 검색

## 📋 사전 준비사항

1. **AWS CLI 설치 및 구성**
```bash
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json
```

2. **필수 도구 설치**
```bash
# Amplify CLI
npm install -g @aws-amplify/cli

# AWS CDK
npm install -g aws-cdk

# Python (for Lambda layers)
python3 -m pip install boto3 pinecone-client langchain
```

## 🚀 단계별 설정

### 1단계: Amplify 기본 설정

```bash
# 프로젝트 디렉토리에서 실행
cd /path/to/hyle

# Amplify 초기화
amplify init

# 설정값:
# ? Enter a name for the project: hyle
# ? Initialize the project with the above configuration? No
# ? Enter a name for the environment: dev
# ? Choose your default editor: Visual Studio Code
# ? Choose the type of app: flutter
# ? Where is your Res directory: lib/
# ? Select the authentication method: AWS profile
# ? Please choose the profile you want to use: default
```

### 2단계: 인증 설정 (Cognito)

```bash
amplify add auth

# 설정값:
# ? Do you want to use the default authentication configuration? Default configuration
# ? How do you want users to sign in? Email
# ? Do you want to configure advanced settings? Yes
# ? What attributes are required for signing up? Email, Name
# ? Do you want to enable any of the following capabilities? 
#   ✓ Add User to Group
#   ✓ Email Verification Link with Redirect
# ? Enter the subject: Welcome to Hyle!
# ? Enter the body: Please verify your email to complete registration.
```

### 3단계: GraphQL API 설정

```bash
amplify add api

# 설정값:
# ? Select from one of the below mentioned services: GraphQL
# ? Here is the GraphQL API that we will create: hyle
# ? Choose the default authorization type: Amazon Cognito User Pool
# ? Do you want to configure advanced settings? Yes
# ? Configure additional auth types? Yes
# ? Choose the additional authorization types: API key
# ? Enter a description for the API key: Development API Key
# ? After how many days should the API key expire? 365
# ? Configure conflict detection? Yes
# ? Select the default resolution strategy: Auto Merge
```

스키마 파일을 다음으로 교체:
```bash
cp amplify/backend/api/hyle/schema.graphql amplify/backend/api/hyle/schema.graphql.backup
# 그리고 CLAUDE_PLAN_MODE_GUIDE.md의 GraphQL 스키마로 교체
```

### 4단계: Lambda 함수 설정

각 Lambda 함수에 대해:

```bash
# AI Tutor Function
amplify add function
# Category: Lambda function
# Name: aiTutorFunction
# Runtime: NodeJS
# Template: Hello World
# Advanced settings: Yes
# Environment variables:
#   BEDROCK_MODEL_ID: anthropic.claude-3-opus-20240229
#   NEPTUNE_ENDPOINT: (나중에 설정)
#   PINECONE_API_KEY: (나중에 설정)
# Layers: Add layer
# Permissions: API (GraphQL), Storage (S3)

# 나머지 함수들도 동일하게 추가:
# - embeddingFunction
# - graphQueryFunction  
# - curriculumFunction
# - realtimeProcessingFunction
```

### 5단계: 스토리지 설정 (S3)

```bash
amplify add storage

# 설정값:
# ? Select from one of the below mentioned services: Content
# ? Provide a friendly name: hyleStorage
# ? Provide bucket name: hyle-storage-{random}
# ? Who should have access: Auth users only
# ? What kind of access: create/update, read, delete
# ? Do you want to add a Lambda Trigger? No
```

### 6단계: 분석 설정 (Pinpoint)

```bash
amplify add analytics

# 설정값:
# ? Select an Analytics provider: Amazon Pinpoint
# ? Provide your pinpoint resource name: hyleAnalytics
# ? Apps need authorization to send analytics events. Do you want to allow guests to send analytics events? No
```

### 7단계: 추가 인프라 배포 (CloudFormation)

```bash
# CloudFormation 스택 배포
aws cloudformation create-stack \
  --stack-name hyle-infrastructure-dev \
  --template-body file://amplify/backend/custom/infrastructure.yaml \
  --capabilities CAPABILITY_IAM \
  --parameters ParameterKey=env,ParameterValue=dev
```

### 8단계: Neptune 설정

스택 배포 후:

```bash
# Neptune 엔드포인트 가져오기
NEPTUNE_ENDPOINT=$(aws cloudformation describe-stacks \
  --stack-name hyle-infrastructure-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`NeptuneEndpoint`].OutputValue' \
  --output text)

# Lambda 환경 변수 업데이트
amplify update function
# graphQueryFunction 선택
# Environment variables 업데이트
# NEPTUNE_ENDPOINT: $NEPTUNE_ENDPOINT
```

### 9단계: Pinecone 설정

1. [Pinecone Console](https://console.pinecone.io)에서 계정 생성
2. API 키 생성
3. 인덱스 생성:

```python
import pinecone

pinecone.init(api_key="YOUR_API_KEY", environment="us-east1-gcp")

# Study patterns index
pinecone.create_index(
    name="hyle-study-patterns",
    dimension=768,
    metric="cosine",
    pod_type="p1"
)

# Content embeddings index  
pinecone.create_index(
    name="hyle-content-embeddings",
    dimension=1536,
    metric="dotproduct",
    pod_type="p1"
)
```

### 10단계: Bedrock 활성화

AWS Console에서:
1. Amazon Bedrock 서비스로 이동
2. Model access 클릭
3. Claude 3 Opus 활성화 요청
4. 승인 대기 (보통 즉시 승인)

### 11단계: 환경 변수 설정

`.env` 파일 생성:
```bash
cp .env.example .env
# 실제 값으로 업데이트
```

### 12단계: Amplify 배포

```bash
# 모든 리소스 배포
amplify push

# 설정 확인:
# ? Are you sure you want to continue? Yes
# ? Do you want to generate code for your newly created GraphQL API? Yes
# ? Choose the code generation language target: dart
# ? Enter the file name pattern: lib/models/*
# ? Do you want to generate/update all possible GraphQL operations? Yes
```

### 13단계: Flutter 앱 구성

```bash
# Amplify 구성 파일 업데이트
amplify pull --appId YOUR_APP_ID --envName dev

# 패키지 설치
flutter pub get

# 실행
flutter run -d chrome
```

## 🧪 테스트 체크리스트

### 기본 기능
- [ ] 회원가입/로그인
- [ ] 프로필 생성
- [ ] 학습 유형 테스트

### AI 기능
- [ ] AI 학습 계획 생성
- [ ] 실시간 학습 조언
- [ ] 패턴 분석

### 실시간 기능
- [ ] 타이머 이벤트 추적
- [ ] 실시간 개입
- [ ] 친구 상태 업데이트

### 데이터 파이프라인
- [ ] Kinesis 이벤트 스트리밍
- [ ] Neptune 지식 그래프 쿼리
- [ ] Pinecone 유사도 검색

## 🔧 문제 해결

### Amplify 오류
```bash
# 캐시 정리
amplify delete
amplify init

# 환경 재설정
amplify env remove dev
amplify env add dev
```

### Lambda 오류
```bash
# 로그 확인
amplify logs function --name aiTutorFunction

# 로컬 테스트
amplify mock function aiTutorFunction
```

### Neptune 연결 오류
- VPC 보안 그룹 확인
- Lambda가 VPC 내에 있는지 확인
- IAM 역할 권한 확인

## 📊 모니터링

### CloudWatch 대시보드
```bash
# 대시보드 생성 스크립트
aws cloudwatch put-dashboard \
  --dashboard-name HyleDashboard \
  --dashboard-body file://monitoring/dashboard.json
```

### 알람 설정
- Lambda 오류율 > 1%
- API 지연시간 > 1초
- DynamoDB 읽기/쓰기 제한
- Kinesis 레코드 처리 지연

## 💰 비용 최적화

### 개발 환경
- Neptune: t3.medium (최소 사양)
- Lambda: 128-256MB 메모리
- DynamoDB: On-demand 모드
- Kinesis: 1-2 샤드

### 프로덕션 환경
- Neptune: r5.large 이상
- Lambda: 512MB-1GB 메모리
- DynamoDB: Provisioned with Auto-scaling
- Kinesis: Auto-scaling 활성화

## 🚀 다음 단계

1. **보안 강화**
   - WAF 규칙 설정
   - API 속도 제한
   - 데이터 암호화

2. **성능 최적화**
   - CloudFront 캐싱
   - Lambda 예약 동시성
   - DynamoDB 글로벌 테이블

3. **CI/CD 파이프라인**
   - GitHub Actions 설정
   - 자동 테스트
   - 스테이징/프로덕션 환경 분리

## 📞 지원

문제가 발생하면:
1. AWS Support 티켓 생성
2. Amplify Discord 커뮤니티
3. 프로젝트 GitHub Issues

---

이 가이드를 따라 Hyle의 전체 AWS 인프라를 설정할 수 있습니다. 
팔란티어 AIP 수준의 실시간 AI 학습 플랫폼이 준비됩니다! 🎓✨