# AWS Amplify 상세 설정 가이드

## 📋 목차
1. [AWS 계정 및 IAM 설정](#1-aws-계정-및-iam-설정)
2. [Amplify CLI 설치 및 설정](#2-amplify-cli-설치-및-설정)
3. [Amplify 프로젝트 초기화](#3-amplify-프로젝트-초기화)
4. [인증 서비스 설정](#4-인증-서비스-설정)
5. [API 및 데이터베이스 설정](#5-api-및-데이터베이스-설정)
6. [스토리지 설정](#6-스토리지-설정)
7. [고급 서비스 설정](#7-고급-서비스-설정)

## 1. AWS 계정 및 IAM 설정

### AWS 계정 생성
1. https://aws.amazon.com/ 접속
2. "Create an AWS Account" 클릭
3. 이메일, 비밀번호 입력
4. 신용카드 정보 입력 (프리 티어 사용 가능)

### IAM 사용자 생성
```bash
# AWS Console에서
1. IAM 서비스 접속
2. Users → Add User
3. User name: hyle-dev
4. Access type: Programmatic access ✓
5. Permissions: AdministratorAccess
6. Access Key ID와 Secret Access Key 저장
```

### AWS CLI 설정
```bash
# PowerShell
aws configure --profile hyle
AWS Access Key ID: [입력]
AWS Secret Access Key: [입력]
Default region name: ap-northeast-2
Default output format: json
```

## 2. Amplify CLI 설치 및 설정

### 설치
```bash
npm install -g @aws-amplify/cli
```

### 설정
```bash
amplify configure

# 브라우저에서 AWS Console 로그인
# 리전 선택: ap-northeast-2 (Seoul)
# IAM 사용자 생성 과정 진행
```

## 3. Amplify 프로젝트 초기화

```bash
cd C:\dev\git\hyle
amplify init

? Enter a name for the project: hyle
? Initialize the project with the above configuration? No
? Enter a name for the environment: dev
? Choose your default editor: Visual Studio Code
? Choose the type of app that you're building: flutter
? Where is your Res directory: lib
? Do you want to use an AWS profile? Yes
? Please choose the profile you want to use: hyle
```

## 4. 인증 서비스 설정

### Cognito 추가
```bash
amplify add auth

? Do you want to use the default authentication? Manual configuration
? Select the authentication/authorization services: Username
? Enable sign-in with: Email
? Do you want to configure advanced settings? Yes
  - Password minimum length: 8
  - Password character requirements: 
    ✓ Requires lowercase
    ✓ Requires uppercase 
    ✓ Requires numbers
  - User attributes: email, name, picture
  - Email verification: Enabled
  - MFA: Optional
```

### 소셜 로그인 추가 (선택사항)
```bash
? Do you want to enable 3rd party authentication? Yes
? Select providers:
  ✓ Google
  ✓ Apple
  ✓ Facebook
```

## 5. API 및 데이터베이스 설정

### GraphQL API 추가
```bash
amplify add api

? Select from one of the below mentioned services: GraphQL
? Here is the GraphQL API that we will create: hyleapi
? Choose the default authorization type: Amazon Cognito User Pool
? Do you want to configure advanced settings? Yes
? Configure additional auth types? Yes
? Choose the additional authorization types:
  ✓ API key (for public data)
? Configure conflict detection? Yes
? Select the default resolution strategy: Auto Merge
? Do you have an annotated GraphQL schema? No
? Choose a schema template: Single object with fields
```

### 스키마 정의
`amplify/backend/api/hyle/schema.graphql`:
```graphql
type User @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  email: String!
  username: String!
  learningType: String
  level: Int!
  xp: Int!
  streak: Int!
  todos: [Todo] @hasMany
  missions: [Mission] @hasMany
  timerSessions: [TimerSession] @hasMany
}

type Todo @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  title: String!
  description: String
  category: String!
  priority: Priority!
  dueDate: AWSDateTime
  completed: Boolean!
  estimatedMinutes: Int
  actualMinutes: Int
  aiTimeEstimate: Int
  owner: String
  user: User @belongsTo
}

enum Priority {
  LOW
  MEDIUM
  HIGH
  URGENT
}

# ... 더 많은 모델 정의
```

## 6. 스토리지 설정

### S3 버킷 추가
```bash
amplify add storage

? Select from one of the below mentioned services: Content
? Provide a friendly name: hylestorage
? Provide bucket name: hyle-storage-{unique-id}
? Who should have access: Auth users only
? What kind of access: create/update, read, delete
? Do you want to add a Lambda Trigger? No
```

## 7. 고급 서비스 설정

### Lambda 함수 추가
```bash
amplify add function

? Select which capability: Lambda function
? Provide an AWS Lambda function name: aiTutorFunction
? Choose the runtime: NodeJS
? Choose the function template: Hello World
? Configure advanced settings? Yes
? Do you want to access other resources? Yes
? Select categories:
  ✓ api
  ✓ storage
```

### Neptune 그래프 DB (Custom CloudFormation)
`amplify/backend/custom/infrastructure.yaml`:
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  NeptuneCluster:
    Type: AWS::Neptune::DBCluster
    Properties:
      DBClusterIdentifier: hyle-knowledge-graph
      EngineVersion: 1.2.0.0
      DBSubnetGroupName: !Ref NeptuneSubnetGroup
      VpcSecurityGroupIds:
        - !Ref NeptuneSecurityGroup
```

### Kinesis 실시간 처리
```bash
amplify add analytics

? Select an Analytics provider: Amazon Kinesis
? Provide a Stream name: hyle-study-stream
? Number of shards: 1
```

## 8. 배포

### 모든 리소스 배포
```bash
amplify push

? Are you sure you want to continue? Yes
? Do you want to generate code for your newly created GraphQL API? Yes
? Choose the code generation language target: flutter
? Enter the file name pattern: lib/models/*
? Do you want to generate/update all possible GraphQL operations? Yes
```

### 호스팅 추가 (선택사항)
```bash
amplify add hosting

? Select the plugin module to execute: Hosting with Amplify Console
? Choose a type: Manual deployment
```

## 9. Flutter 통합

### 패키지 추가
```yaml
# pubspec.yaml
dependencies:
  amplify_flutter: ^1.0.0
  amplify_auth_cognito: ^1.0.0
  amplify_api: ^1.0.0
  amplify_storage_s3: ^1.0.0
  amplify_datastore: ^1.0.0
  amplify_analytics_pinpoint: ^1.0.0
```

### 초기화 코드
```dart
// lib/services/amplify_service.dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import '../models/ModelProvider.dart';
import '../amplify_outputs.dart';

class AmplifyService {
  static Future<void> configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(modelProvider: ModelProvider.instance),
        AmplifyStorageS3(),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
      ]);
      
      await Amplify.configure(amplifyConfig);
      print('Amplify configured successfully');
    } catch (e) {
      print('Error configuring Amplify: $e');
    }
  }
}
```

## 10. 환경별 설정

### 개발/스테이징/프로덕션 환경
```bash
# 새 환경 추가
amplify env add

? Enter a name for the environment: staging
? Do you want to use an AWS profile? Yes
? Please choose the profile: hyle-staging

# 환경 전환
amplify env checkout staging

# 현재 환경 확인
amplify env list
```

## 🚨 주의사항

1. **비용 관리**
   - CloudWatch에서 비용 알림 설정
   - 불필요한 리소스는 즉시 삭제
   - 프리 티어 한도 모니터링

2. **보안**
   - API Key를 코드에 하드코딩하지 않기
   - IAM 권한은 최소한으로
   - 민감한 데이터는 암호화

3. **백업**
   - DynamoDB 자동 백업 활성화
   - S3 버전 관리 활성화
   - 정기적인 스냅샷

## 📚 참고 자료

- [Amplify Flutter 공식 문서](https://docs.amplify.aws/lib/q/platform/flutter/)
- [GraphQL 변환 지시자](https://docs.amplify.aws/cli/graphql/directives/)
- [Amplify 보안 모범 사례](https://docs.amplify.aws/lib/auth/getting-started/q/platform/flutter/)