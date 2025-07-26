# Hyle Documentation

## 📚 문서 구조

### 1. 개발 환경 설정
- [크로스 플랫폼 개발 가이드](./setup/CROSS_PLATFORM_GUIDE.md) - Windows/macOS 환경 설정
- [로컬 테스트 가이드](./setup/LOCAL_TESTING_GUIDE.md) - 로컬 환경에서 테스트

### 2. AWS 설정
- [AWS 빠른 시작 가이드](./aws/QUICK_START.md) - AWS Amplify 설정 요약
- [AWS 상세 설정 가이드](./aws/DETAILED_SETUP.md) - 단계별 상세 가이드
- [Amazon Q 활용 가이드](./aws/AMAZON_Q_GUIDE.md) - Amazon Q로 설정 가속화
- [AWS 아키텍처](./aws/AWS_ARCHITECTURE.md) - 백엔드 아키텍처 설계
- [Amplify Gen2 환경 공유](./aws/AMPLIFY_GEN2_SHARING.md) - 팀 협업 설정
- [Amplify 멀티 환경 설정](./aws/AMPLIFY_MULTI_ENV_SETUP.md) - 개발/운영 환경 분리

### 3. 개발 가이드
- [프로젝트 구조](./development/ARCHITECTURE.md) - 앱 아키텍처 및 구조
- [디자인 시스템](./development/DESIGN_SYSTEM.md) - UI/UX 가이드라인
- [AI 기능 개발](./development/AI_FEATURES.md) - AI 서비스 통합

### 4. 테스트 및 배포
- [테스트 체크리스트](./testing/TEST_CHECKLIST.md) - 필수 테스트 항목
- [베타 테스트 가이드](./testing/BETA_GUIDE.md) - 베타 버전 테스트

### 5. 프로젝트 관리
- [프로젝트 현황](../PROJECT_STATUS.md) - 현재 개발 상황
- [개발 로그](./logs/) - 일별 개발 로그

## 🚀 빠른 시작

1. **개발 환경 설정**
   ```bash
   # Windows PowerShell
   cd C:\dev\git\hyle
   flutter run -d chrome -t lib/main_dev.dart
   ```

2. **AWS 설정 (Amazon Q 활용)**
   - VSCode에서 AWS Toolkit 설치
   - Amazon Q로 Amplify 설정 자동화

3. **테스트**
   - 로컬 테스트: `main_test_local.dart`
   - Mock 데이터: `main_test.dart`
   - 개발 모드: `main_dev.dart`

## 📌 중요 사항

- **Claude Code 사용자**: WSL 제한으로 별도 PowerShell 필요
- **크로스 플랫폼**: Windows(메인) + macOS(보조)
- **Amazon Q**: AWS 설정 시간 70% 단축