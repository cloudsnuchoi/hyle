# Hyle 프로젝트 아키텍처

## 🏗️ 전체 구조

```
hyle/
├── lib/                      # Flutter 소스 코드
│   ├── core/                # 핵심 공통 모듈
│   │   ├── theme/          # 디자인 시스템
│   │   └── widgets/        # 공통 위젯
│   ├── data/               # 데이터 레이어
│   │   ├── repositories/   # 데이터 저장소
│   │   └── services/       # 비즈니스 로직
│   ├── features/           # 기능별 모듈
│   │   ├── auth/          # 인증
│   │   ├── home/          # 홈/대시보드
│   │   ├── timer/         # 타이머
│   │   ├── todo/          # 할일 관리
│   │   └── profile/       # 프로필
│   ├── models/            # 데이터 모델
│   ├── providers/         # 상태 관리
│   └── routes/            # 네비게이션
├── amplify/               # AWS Amplify 백엔드
│   ├── auth/             # Cognito 설정
│   ├── api/              # GraphQL API
│   └── storage/          # S3 설정
└── docs/                 # 문서

```

## 🎯 핵심 원칙

### 1. Feature-First Architecture
- 각 기능은 독립적인 모듈로 구성
- 화면(screens), 위젯(widgets), 로직이 함께 위치
- 기능 간 의존성 최소화

### 2. Clean Architecture Layers
```
Presentation (UI) ← Provider ← Repository ← Service ← Data Source
```

### 3. State Management
- **Riverpod**: 전역 상태 관리
- **Provider Pattern**: 반응형 UI 업데이트
- **Local State**: StatefulWidget for 단순 UI 상태

## 🔧 주요 컴포넌트

### 1. Entry Points
```dart
main.dart          // 프로덕션 (AWS 연동)
main_dev.dart      // 개발 모드
main_test.dart     // 테스트 (Mock 데이터)
main_test_local.dart // 로컬 스토리지 테스트
```

### 2. 라우팅 시스템
```dart
// lib/routes/app_router.dart
- go_router 사용
- 인증 가드 구현
- 딥링크 지원
- 중첩 라우팅
```

### 3. 데이터 플로우

#### 로컬 모드
```
UI → Provider → Repository → Local Storage (SharedPreferences)
```

#### AWS 모드
```
UI → Provider → Repository → Amplify Service → AWS (Cognito/AppSync/S3)
```

### 4. AI 서비스 아키텍처
```
26개 AI Services
    ↓
3개 Orchestrators (AI Tutor, Learning Data, Realtime)
    ↓
AWS Lambda Functions
    ↓
Neptune (Graph DB) + Pinecone (Vector DB)
```

## 📦 주요 패키지

### 상태 관리
- `flutter_riverpod`: 상태 관리
- `provider`: Provider 패턴

### 네비게이션
- `go_router`: 선언적 라우팅

### AWS 통합
- `amplify_flutter`: AWS 통합
- `amplify_auth_cognito`: 인증
- `amplify_api`: GraphQL API
- `amplify_storage_s3`: 파일 저장

### UI/UX
- `flutter_animate`: 애니메이션
- `cached_network_image`: 이미지 캐싱
- `flutter_svg`: SVG 지원

## 🔐 보안 아키텍처

### 1. 인증 플로우
```
Login → Cognito → JWT Token → Secure Storage → Auto Refresh
```

### 2. API 보안
- GraphQL with @auth directives
- Row-level security
- API Key for public data

### 3. 데이터 암호화
- At rest: S3 & DynamoDB encryption
- In transit: HTTPS/WSS

## 🚀 확장성 고려사항

### 1. 모듈화
- 새 기능은 features/ 아래 독립 모듈로 추가
- 공통 기능은 core/로 추출

### 2. 성능 최적화
- Lazy loading for routes
- Image caching
- API response caching
- Pagination for lists

### 3. 다국어 지원
- l10n/ 폴더에 번역 파일
- 동적 언어 변경 지원

## 🧪 테스트 전략

### 1. 단위 테스트
- Services & Repositories
- Providers
- Utilities

### 2. 위젯 테스트
- Custom widgets
- Screen components

### 3. 통합 테스트
- User flows
- API integration
- Authentication flow

## 📱 플랫폼별 고려사항

### Web
- Responsive design
- PWA support
- Web-specific navigation

### Mobile (iOS/Android)
- Native permissions
- Push notifications
- Platform-specific UI

### Desktop (Windows/macOS/Linux)
- Window management
- File system access
- Native menus