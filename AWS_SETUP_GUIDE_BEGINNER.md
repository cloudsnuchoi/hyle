# AWS 초보자 설정 가이드

## 터미널에서 AWS CLI 설정하기

1. 다음 명령어 실행:
```bash
/mnt/c/Program\ Files/Amazon/AWSCLIV2/aws.exe configure
```

2. 순서대로 입력:
   - AWS Access Key ID [None]: (위에서 복사한 AKIA로 시작하는 키)
   - AWS Secret Access Key [None]: (위에서 복사한 긴 Secret Key)
   - Default region name [None]: us-east-1
   - Default output format [None]: json

3. 설정 확인:
```bash
/mnt/c/Program\ Files/Amazon/AWSCLIV2/aws.exe configure list
```

## 다음 단계

설정이 완료되면 Amplify CLI를 설치하고 프로젝트를 시작할 수 있습니다!