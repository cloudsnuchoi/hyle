# Hyle 디자인 시스템

## 🎨 디자인 원칙

### 1. 게임화된 학습 경험
- 재미있고 몰입감 있는 UI
- 성취감을 주는 시각적 피드백
- 프로그레스와 레벨 시각화

### 2. 개인화
- 6가지 테마 프리셋
- 다크/라이트 모드
- 커스터마이징 가능한 스킨

### 3. 접근성
- 명확한 대비
- 읽기 쉬운 타이포그래피
- 직관적인 네비게이션

## 🎨 색상 시스템

### 테마 프리셋
```dart
// lib/core/theme/theme_presets.dart
1. Ocean (기본) - 차분한 블루 계열
2. Forest - 자연친화적 그린
3. Sunset - 따뜻한 오렌지/핑크
4. Galaxy - 신비로운 퍼플/다크
5. Sakura - 부드러운 핑크
6. Mint - 상쾌한 민트/청록
```

### 색상 구조
```dart
primary: 주요 액션, 브랜드 색상
secondary: 보조 액션, 강조
tertiary: 추가 강조, 장식
error: 오류, 경고
background: 배경색
surface: 카드, 모달 배경
onPrimary: primary 위 텍스트
onSecondary: secondary 위 텍스트
onBackground: 배경 위 텍스트
onSurface: surface 위 텍스트
```

## 📝 타이포그래피

### 폰트 계층
```dart
// lib/core/theme/app_typography.dart
displayLarge: 57sp - 메인 타이틀
displayMedium: 45sp - 서브 타이틀
displaySmall: 36sp - 섹션 타이틀

titleLarge: 28sp - 페이지 제목
titleMedium: 24sp - 카드 제목
titleSmall: 20sp - 리스트 제목

bodyLarge: 18sp - 본문
bodyMedium: 16sp - 일반 텍스트
bodySmall: 14sp - 보조 텍스트

labelLarge: 16sp - 버튼 텍스트
labelMedium: 14sp - 태그
labelSmall: 12sp - 캡션
```

### 폰트 스타일
- **Heading**: Bold, 높은 대비
- **Body**: Regular, 읽기 편한 행간
- **Caption**: Light, 부가 정보

## 📏 간격 시스템

### 8px 기반 그리드
```dart
// lib/core/theme/app_spacing.dart
xxxs: 2px
xxs: 4px
xs: 8px
sm: 12px
md: 16px
lg: 24px
xl: 32px
xxl: 48px
xxxl: 64px
```

### 사용 예시
```dart
// Padding
padding: AppSpacing.paddingMd, // 16px
padding: AppSpacing.paddingSymmetricHorizontal(lg), // 가로 24px

// Gap
Gap.xs,  // 8px 간격
Gap.md,  // 16px 간격

// Border Radius
borderRadius: AppSpacing.radiusMd, // 12px
```

## 🎯 컴포넌트 스타일

### 버튼
```dart
// Primary Button
- 배경: primary color
- 텍스트: onPrimary
- 높이: 48px
- 모서리: 12px radius
- 그림자: elevation 2

// Secondary Button
- 배경: transparent
- 테두리: primary color
- 텍스트: primary

// Text Button
- 배경: none
- 텍스트: primary
- 언더라인: hover 시
```

### 카드
```dart
// 기본 카드
- 배경: surface color
- 모서리: 16px radius
- 그림자: soft shadow
- 패딩: 16px

// 게임화 카드 (퀘스트, 미션)
- 그라데이션 배경
- 아이콘 장식
- 프로그레스 바
- 보상 표시
```

### 입력 필드
```dart
// TextField
- 높이: 56px
- 테두리: 1px, outline color
- Focus: primary color border
- 에러: error color border
- 힌트: 연한 회색
```

## 🎮 게임화 요소

### 레벨 & XP
```dart
// 레벨 배지
- 원형 또는 육각형
- 그라데이션 배경
- 숫자 + 아이콘
- 광택 효과

// XP 바
- 그라데이션 진행바
- 애니메이션 채우기
- 마일스톤 표시
```

### 스트릭 & 업적
```dart
// 스트릭 카운터
- 불꽃 아이콘
- 숫자 강조
- 연속 일수 표시

// 업적 배지
- 메탈릭 효과
- 3단계: 브론즈, 실버, 골드
- 잠금/해제 상태
```

### 타이머 스킨
```dart
// 기본 스킨들
1. Default - 깔끔한 디지털
2. Retro Digital - 레트로 LED
3. Ocean Wave - 물결 애니메이션
4. Forest - 자연 테마
5. Galaxy - 우주 테마
6. Minimalist - 미니멀
7. Neon - 네온 효과
8. Vintage - 빈티지 시계
```

## 📱 반응형 디자인

### 브레이크포인트
```dart
mobile: < 600px
tablet: 600px - 1024px
desktop: > 1024px
```

### 레이아웃 전략
```dart
// Mobile First
- 세로 스택 레이아웃
- 풀 너비 컴포넌트
- 하단 네비게이션

// Tablet
- 2열 그리드
- 사이드바 네비게이션
- 모달 다이얼로그

// Desktop
- 3열 그리드
- 고정 사이드바
- 멀티 패널 뷰
```

## 🌈 다크 모드

### 색상 조정
```dart
// Light Mode
- 배경: 흰색/연한 회색
- 텍스트: 진한 회색/검정
- 그림자: 부드러운 그림자

// Dark Mode
- 배경: 진한 회색/검정
- 텍스트: 밝은 회색/흰색
- 그림자: 광택 효과
- 채도 낮춤
```

## 🎭 애니메이션

### 마이크로 인터랙션
```dart
// 버튼 탭
- Scale: 0.95
- Duration: 150ms
- Curve: easeInOut

// 카드 호버
- Elevation 증가
- 살짝 위로 이동
- Duration: 200ms

// 페이지 전환
- Slide + Fade
- Duration: 300ms
- Curve: easeInOutCubic
```

### 게임화 애니메이션
```dart
// 레벨업
- 파티클 효과
- 숫자 카운트업
- 빛나는 효과

// 퀘스트 완료
- 체크 애니메이션
- 코인 획득 효과
- 진동 피드백

// 스트릭 유지
- 불꽃 애니메이션
- 숫자 바운스
- 글로우 효과
```

## 📐 아이콘 시스템

### 아이콘 스타일
- Outlined 기본
- Rounded 모서리
- 일관된 두께 (2px)
- 24x24 기본 크기

### 주요 아이콘
```
홈: home_outlined
타이머: timer_outlined
할일: checklist_outlined
프로필: person_outlined
설정: settings_outlined
친구: people_outlined
업적: emoji_events_outlined
레벨: grade_outlined
```

## 🎯 접근성

### 색상 대비
- WCAG AA 기준 충족
- 텍스트: 4.5:1 이상
- 큰 텍스트: 3:1 이상

### 터치 타겟
- 최소 48x48px
- 충분한 간격
- 명확한 피드백

### 스크린 리더
- Semantic 레이블
- 이미지 대체 텍스트
- 논리적 탐색 순서