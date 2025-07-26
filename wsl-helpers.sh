#!/bin/bash
# WSL에서 Windows 도구 사용을 위한 헬퍼 스크립트

# Flutter wrapper function
flutter() {
    echo "🚀 Running Flutter from Windows..."
    cmd.exe /c "cd $(wslpath -w $(pwd)) && flutter $*"
}

# AWS CLI wrapper function  
aws() {
    "/mnt/c/Program Files/Amazon/AWSCLIV2/aws.exe" "$@"
}

# Amplify는 이미 WSL에 설치됨
echo "✅ Amplify CLI: $(amplify --version)"

# 사용법 안내
echo "
🛠️  WSL Helper Functions Loaded!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Available commands:
  flutter  - Windows Flutter (via cmd.exe)
  aws      - Windows AWS CLI
  amplify  - Native WSL Amplify CLI

Example usage:
  flutter run -d chrome -t lib/main_dev.dart
  aws configure --profile hyle
  amplify init
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"

# Export functions for use
export -f flutter
export -f aws