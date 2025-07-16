# Hyle - AI Learning Companion

AI 기반 학습 동반자 플랫폼으로, 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로 만들어줍니다.

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK: 3.22.2 이상
- Dart SDK: 3.4.0 이상
- Chrome 브라우저 (웹 개발용)

### 설치 방법

#### 1. 저장소 클론
```bash
git clone https://github.com/[your-username]/hyle.git
cd hyle
```

#### 2. 의존성 설치
```bash
flutter pub get
```

#### 3. 플랫폼별 설정

**macOS:**
```bash
# iOS 개발을 위한 추가 설정 (선택사항)
cd ios && pod install && cd ..
```

**Windows:**
```bash
# Windows에서는 추가 설정 불필요
flutter doctor
```

### 실행 방법

```bash
# 개발 모드 실행 (권장)
flutter run -d chrome -t lib/main_dev.dart

# 테스트 모드 실행
flutter run -d chrome -t lib/main_test.dart

# 기본 실행 (AWS 연동 필요 - 아직 미구현)
flutter run -d chrome
```

## 🛠 개발 환경 설정

### VS Code (권장)
1. Flutter 확장 설치
2. Dart 확장 설치
3. `.vscode/launch.json` 사용 (저장소에 포함)

### Android Studio / IntelliJ
1. Flutter 플러그인 설치
2. Dart 플러그인 설치

## 📱 지원 플랫폼

- ✅ Web (Chrome)
- ✅ iOS
- ✅ Android
- 🚧 macOS (테스트 필요)
- 🚧 Windows (테스트 필요)

## 🏗 프로젝트 구조

```
lib/
├── core/               # 핵심 기능
│   ├── theme/         # 디자인 시스템
│   ├── widgets/       # 공통 위젯
│   └── utils/         # 유틸리티
├── features/          # 기능별 모듈
│   ├── auth/         # 인증
│   ├── home/         # 홈/대시보드
│   ├── todo/         # 투두(퀘스트)
│   └── timer/        # 타이머
├── models/           # 데이터 모델
├── providers/        # 상태 관리
└── routes/          # 라우팅

```

## 🔧 주요 기능

- **퀘스트 시스템**: 투두를 게임 퀘스트처럼 관리
- **통합 타이머**: 퀘스트 수행 시 자동 시간 측정
- **게이미피케이션**: XP, 레벨, 스트릭 시스템
- **학습 분석**: AI 기반 학습 패턴 분석 (예정)

## 📝 개발 현황

자세한 개발 현황은 [PROJECT_STATUS.md](PROJECT_STATUS.md) 참조

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.