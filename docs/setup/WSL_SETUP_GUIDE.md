# WSL에서 Flutter & AWS 개발 환경 설정 가이드

## 🎯 목표
WSL 환경에서 Flutter, AWS CLI, Amplify를 모두 사용할 수 있도록 설정

## 📋 현재 상황
- **Node.js**: ✅ 작동 (v22.16.0)
- **npm**: ✅ 작동 (10.9.2)
- **Flutter**: ⚠️ Windows 버전 감지됨 (줄바꿈 문자 이슈)
- **AWS/Amplify**: 설치 가능

## 🛠️ 해결 방법

### 방법 1: WSL 네이티브 설치 (권장)

#### 1. Flutter WSL 네이티브 설치
```bash
# WSL Ubuntu에서 실행
cd ~
mkdir development
cd development

# Flutter 다운로드
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Flutter 초기 설정
flutter doctor
flutter config --enable-web
```

#### 2. Chrome 브라우저 연결
```bash
# Windows Chrome을 WSL에서 사용
echo 'export CHROME_EXECUTABLE="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"' >> ~/.bashrc
source ~/.bashrc
```

#### 3. AWS CLI 설치
```bash
# WSL에 AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

#### 4. Amplify CLI 설치
```bash
# npm으로 Amplify CLI 설치
npm install -g @aws-amplify/cli
amplify --version
```

### 방법 2: Windows 실행 파일 래핑

#### 1. Flutter 래퍼 스크립트
```bash
# ~/.local/bin/flutter 생성
mkdir -p ~/.local/bin
cat > ~/.local/bin/flutter << 'EOF'
#!/bin/bash
/mnt/c/flutter/bin/flutter.bat "$@"
EOF
chmod +x ~/.local/bin/flutter
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### 2. AWS CLI 래퍼
```bash
# ~/.local/bin/aws 생성
cat > ~/.local/bin/aws << 'EOF'
#!/bin/bash
"/mnt/c/Program Files/Amazon/AWSCLIV2/aws.exe" "$@"
EOF
chmod +x ~/.local/bin/aws
```

### 방법 3: Docker 활용

#### Flutter 개발 컨테이너
```dockerfile
# .devcontainer/Dockerfile
FROM ubuntu:22.04

# Flutter 설치
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Chrome 설치
RUN apt-get update && apt-get install -y \
    wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI & Amplify
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g @aws-amplify/cli
```

### 방법 4: Claude Code + 외부 터미널 조합 (현재 방식 개선)

#### 1. VSCode 터미널 프로필 설정
```json
// .vscode/settings.json
{
  "terminal.integrated.profiles.windows": {
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell"
    },
    "WSL": {
      "path": "C:\\Windows\\System32\\wsl.exe",
      "args": ["-d", "Ubuntu"],
      "icon": "terminal-linux"
    }
  },
  "terminal.integrated.defaultProfile.windows": "PowerShell"
}
```

#### 2. 작업 자동화 스크립트
```bash
# run-flutter.sh (WSL에서 생성)
#!/bin/bash
echo "Flutter 명령어를 PowerShell에서 실행하세요:"
echo "cd /mnt/c/dev/git/hyle && cmd.exe /c 'flutter run -d chrome -t lib/main_dev.dart'"
```

## 🚀 권장 설정

### WSL2 성능 최적화
```bash
# ~/.wslconfig (Windows 사용자 폴더)
[wsl2]
memory=8GB
processors=4
localhostForwarding=true
```

### Git 설정
```bash
# WSL에서 Git 줄바꿈 설정
git config --global core.autocrlf input
git config --global core.eol lf
```

### X Server 설정 (GUI 앱용)
```bash
# VcXsrv 또는 X410 설치 후
echo 'export DISPLAY=:0' >> ~/.bashrc
source ~/.bashrc
```

## 📝 추천 워크플로우

### 1. 하이브리드 접근 (현실적)
- **코드 편집**: Claude Code (WSL)
- **Flutter 실행**: PowerShell
- **Git 작업**: WSL
- **AWS/Amplify**: WSL (네이티브 설치)

### 2. WSL 완전 통합 (이상적)
- 모든 도구를 WSL에 네이티브 설치
- VSCode Remote-WSL 확장 사용
- Windows 도구 의존성 제거

### 3. 컨테이너 기반 (팀 작업)
- Docker/Podman 사용
- 일관된 개발 환경
- 플랫폼 독립적

## 🔧 문제 해결

### Flutter 줄바꿈 문자 오류
```bash
# dos2unix 설치
sudo apt-get install dos2unix

# Flutter 스크립트 변환
find /mnt/c/flutter -name "*.sh" -exec dos2unix {} \;
```

### 권한 문제
```bash
# WSL에서 Windows 파일 실행 권한
chmod +x /mnt/c/flutter/bin/flutter
```

### 포트 접근 문제
```bash
# Windows 방화벽 규칙 추가
netsh advfirewall firewall add rule name="Flutter Web" dir=in action=allow protocol=TCP localport=3000-3999
```

## 💡 최종 권장사항

**단기적 해결책**: 
- AWS/Amplify는 WSL 네이티브 설치 ✅
- Flutter는 PowerShell 사용 유지

**장기적 해결책**:
- WSL2에 모든 도구 네이티브 설치
- VSCode Remote-WSL 전환
- 또는 개발 컨테이너 도입

## 🚀 즉시 사용 가능한 명령어 (WSL에서)

### Amplify 명령어 (✅ 작동)
```bash
# Amplify는 이미 WSL에 설치됨 (v14.0.0)
amplify init
amplify add auth
amplify add api
amplify push
amplify status
```

### AWS CLI (Windows 버전 활용)
```bash
# Windows AWS CLI를 WSL에서 사용
"/mnt/c/Program Files/Amazon/AWSCLIV2/aws.exe" configure
"/mnt/c/Program Files/Amazon/AWSCLIV2/aws.exe" s3 ls
```

### Flutter (cmd.exe 통해 실행)
```bash
# Windows Flutter를 WSL에서 실행
cmd.exe /c "cd C:\\dev\\git\\hyle && flutter run -d chrome -t lib/main_dev.dart"
```

## 📝 .bashrc에 추가할 별칭 (영구 설정)

```bash
# ~/.bashrc 파일 끝에 추가
echo '# WSL Development Aliases' >> ~/.bashrc
echo 'alias aws="/mnt/c/Program\ Files/Amazon/AWSCLIV2/aws.exe"' >> ~/.bashrc
echo 'alias flutter-dev="cmd.exe /c \"cd C:\\dev\\git\\hyle && flutter run -d chrome -t lib/main_dev.dart\""' >> ~/.bashrc
echo 'alias flutter-analyze="cmd.exe /c \"cd C:\\dev\\git\\hyle && flutter analyze\""' >> ~/.bashrc
source ~/.bashrc
```

이제 Claude Code에서도 `amplify`는 바로 사용할 수 있고, Flutter는 별칭으로 간편하게 실행할 수 있습니다!