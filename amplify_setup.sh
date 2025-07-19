#!/bin/bash
# Hyle AWS Amplify Setup Script

echo "🚀 Hyle AWS Amplify 설정 시작..."

# 1. Amplify CLI 설치 확인
if ! command -v amplify &> /dev/null; then
    echo "📦 Amplify CLI 설치 중..."
    npm install -g @aws-amplify/cli
fi

# 2. Amplify 프로젝트 초기화
echo "📋 Amplify 프로젝트 초기화..."
amplify init \
  --amplify '{"projectName":"hyle","appId":"hylelearning","envName":"dev","defaultEditor":"code"}' \
  --categories '{"auth":{"userPoolName":"hyleuserpool","identityPoolName":"hyleidentitypool"}}'

# 3. 인증 추가 (Cognito)
echo "🔐 Cognito 인증 설정..."
amplify add auth << EOF
Default configuration
Email
No, I am done.
EOF

# 4. GraphQL API 추가 (AppSync)
echo "📊 GraphQL API 설정..."
amplify add api << EOF
GraphQL
hyle
API key
API key for development
365
No, I am done
Single object with fields
No
EOF

# 5. 스토리지 추가 (S3)
echo "💾 S3 스토리지 설정..."
amplify add storage << EOF
Content (Images, audio, video, etc.)
hyleStorage
hyleStorageBucket
Auth users only
read/write
read/write
No
EOF

# 6. 분석 추가 (Pinpoint)
echo "📈 Analytics 설정..."
amplify add analytics << EOF
Amazon Pinpoint
hyleAnalytics
EOF

# 7. Lambda 함수 추가
echo "⚡ Lambda 함수 설정..."

# AI Tutor Function
amplify add function << EOF
Lambda function (serverless function)
aiTutorFunction
NodeJS
lambda-helper
aiTutorFunction
advanced settings
Yes
access-key
create
Yes
api
hyle
create
read
update
delete
No
120
512
No
No
No
No
No
No
EOF

# Embedding Function
amplify add function << EOF
Lambda function (serverless function)
embeddingFunction
NodeJS
lambda-helper
embeddingFunction
advanced settings
Yes
access-key
create
Yes
api
hyle
create
read
No
60
256
No
No
No
No
No
No
EOF

# Graph Query Function
amplify add function << EOF
Lambda function (serverless function)
graphQueryFunction
NodeJS
lambda-helper
graphQueryFunction
advanced settings
Yes
access-key
create
Yes
api
hyle
read
No
60
512
No
No
No
No
No
No
EOF

# Curriculum Function
amplify add function << EOF
Lambda function (serverless function)
curriculumFunction
NodeJS
lambda-helper
curriculumFunction
advanced settings
Yes
access-key
create
Yes
api
hyle
create
read
update
No
60
256
No
No
No
No
No
No
EOF

# Realtime Processing Function
amplify add function << EOF
Lambda function (serverless function)
realtimeProcessingFunction
NodeJS
lambda-helper
realtimeProcessingFunction
advanced settings
Yes
access-key
create
Yes
api
hyle
create
read
update
No
30
256
No
No
No
No
No
No
EOF

echo "✅ Amplify 기본 설정 완료!"
echo "다음 명령어를 실행하여 AWS에 배포하세요:"
echo "amplify push"