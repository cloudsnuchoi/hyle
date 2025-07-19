# AWS 설정 명령어 가이드

## 1. AWS CLI 설치 (아직 없다면)

### Windows
```powershell
# PowerShell 관리자 권한으로 실행
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

### macOS
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### Linux
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## 2. AWS 계정 설정

```bash
# AWS 자격 증명 구성
aws configure

# 입력할 정보:
# AWS Access Key ID [None]: YOUR_ACCESS_KEY
# AWS Secret Access Key [None]: YOUR_SECRET_KEY
# Default region name [None]: us-east-1
# Default output format [None]: json
```

## 3. Amplify CLI 설치

```bash
# Node.js가 설치되어 있어야 함 (v14.x 이상)
npm install -g @aws-amplify/cli
```

## 4. Amplify 초기화

```bash
cd /path/to/hyle

# Amplify 초기화
amplify init

# 대화형 프롬프트 응답:
? Enter a name for the project: hyle
? Initialize the project with the above configuration? No
? Enter a name for the environment: dev
? Choose your default editor: Visual Studio Code
? Choose the type of app that you're building: flutter
? Where is your Res directory: lib/
? Select the authentication method you want to use: AWS profile
? Please choose the profile you want to use: default
```

## 5. 인증 추가 (Cognito)

```bash
amplify add auth

# 대화형 프롬프트 응답:
? Do you want to use the default authentication and security configuration? Default configuration
? How do you want users to be able to sign in? Email
? Do you want to configure advanced settings? Yes, I want to make some additional changes.
? What attributes are required for signing up? Email, Name
? Do you want to enable any of the following capabilities? (선택사항)
```

## 6. GraphQL API 추가

```bash
amplify add api

# 대화형 프롬프트 응답:
? Select from one of the below mentioned services: GraphQL
? Here is the GraphQL API that we will create. Select a setting to edit or continue: Continue
? Choose a schema template: Single object with fields
? Do you want to edit the schema now? Yes
```

이때 열리는 schema.graphql 파일을 다음 내용으로 교체:

```graphql
# 기본 User 타입 (간단 버전)
type User @model @auth(rules: [{allow: owner}]) {
  id: ID!
  email: String!
  nickname: String!
  learningType: String
  level: Int!
  xp: Int!
  totalStudyTime: Int!
  currentStreak: Int!
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

type Todo @model @auth(rules: [{allow: owner}]) {
  id: ID!
  title: String!
  completed: Boolean!
  priority: String!
  dueDate: AWSDateTime
  subject: String
  estimatedTime: Int
  actualTime: Int
  xpReward: Int!
  userID: ID! @index(name: "byUser")
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

type TimerSession @model @auth(rules: [{allow: owner}]) {
  id: ID!
  startTime: AWSDateTime!
  endTime: AWSDateTime
  duration: Int!
  subject: String
  type: String!
  productivityScore: Float
  xpEarned: Int!
  userID: ID! @index(name: "byUser")
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}
```

## 7. 스토리지 추가 (S3)

```bash
amplify add storage

# 대화형 프롬프트 응답:
? Select from one of the below mentioned services: Content (Images, audio, video, etc.)
? Provide a friendly name for your resource that will be used to label this category in the project: hyleStorage
? Provide bucket name: hyle-storage-{RANDOM}
? Who should have access? Auth users only
? What kind of access do you want for Authenticated users? create/update, read, delete
? Do you want to add a Lambda Trigger for your S3 Bucket? No
```

## 8. 분석 추가 (Pinpoint)

```bash
amplify add analytics

# 대화형 프롬프트 응답:
? Select an Analytics provider: Amazon Pinpoint
? Provide your pinpoint resource name: hyleAnalytics
? Apps need authorization to send analytics events. Do you want to allow guests to send analytics events? No
```

## 9. Lambda 함수 추가 (AI Tutor)

```bash
amplify add function

# 대화형 프롬프트 응답:
? Select which capability you want to add: Lambda function (serverless function)
? Provide an AWS Lambda function name: aiTutorFunction
? Choose the runtime that you want to use: NodeJS
? Choose the function template that you want to use: Hello World
? Do you want to configure advanced settings? Yes
? Do you want to access other resources in this project from your Lambda function? Yes
? Select the categories you want this function to have access to: api, storage
? Select the operations you want to permit on hyle: Query, Mutation
? Do you want to edit the local lambda function now? No
```

## 10. 모든 리소스 배포

```bash
# 변경사항 확인
amplify status

# AWS에 배포
amplify push

# 프롬프트:
? Are you sure you want to continue? Yes
? Do you want to generate code for your newly created GraphQL API? Yes
? Choose the code generation language target: dart
? Enter the file name pattern of graphql queries, mutations and subscriptions: lib/graphql/*.dart
? Do you want to generate/update all possible GraphQL operations? Yes
? Enter maximum statement depth: 2
```

## 11. Flutter 앱에 설정 파일 가져오기

```bash
# Amplify 설정 파일 업데이트
amplify pull

# 이 명령어는 amplifyconfiguration.dart 파일을 자동으로 업데이트합니다
```

## 12. 테스트 실행

```bash
# Flutter 패키지 업데이트
flutter pub get

# 웹에서 실행
flutter run -d chrome
```

## 문제 해결

### "Amplify has not been configured correctly" 오류
```bash
amplify pull --appId YOUR_APP_ID --envName dev
```

### 인증 오류
```bash
# Cognito User Pool ID 확인
amplify status
# Auth 리소스의 세부 정보 확인
```

### API 연결 오류
```bash
# GraphQL 엔드포인트 확인
amplify api console
# GraphQL을 선택하면 AppSync 콘솔이 열림
```