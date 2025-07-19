#!/bin/bash
# AWS CLI alias for WSL
alias aws='/mnt/c/Program\ Files/Amazon/AWSCLIV2/aws.exe'

# Configure AWS credentials
echo "AWS CLI 설정을 시작합니다..."
/mnt/c/Program\ Files/Amazon/AWSCLIV2/aws.exe configure

# Install Amplify CLI
echo "Amplify CLI 설치 중..."
npm install -g @aws-amplify/cli

echo "설치 완료!"