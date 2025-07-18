# 🎨 Figma/UI 템플릿을 Flutter에 적용하는 방법

## 1. Figma 디자인을 Flutter로 변환하는 방법

### 방법 1: Figma 플러그인 사용
1. **Figma to Code (Figma to Flutter)**
   - Figma에서 플러그인 설치
   - 디자인 선택 → 플러그인 실행 → Flutter 코드 생성
   - 생성된 코드를 Claude Code에 붙여넣기

2. **Bravo Studio**
   - Figma 디자인을 앱으로 직접 변환
   - Flutter 코드 export 기능

3. **DhiWise**
   - Figma URL 입력 → Flutter 프로젝트 생성
   - 컴포넌트별 코드 생성

### 방법 2: 수동 변환 (Claude Code 활용) ⭐️ 추천
1. **Figma에서 스타일 추출**:
   ```
   1. Figma에서 디자인 선택
   2. 우측 패널에서 다음 정보 복사:
      - Colors (hex 코드)
      - Typography (폰트, 크기, weight)
      - Spacing (padding, margin)
      - Border Radius
      - Shadows
   ```

2. **Claude Code에 전달**:
   ```
   "Figma 스타일을 Flutter 테마로 변환해줘:
   Primary Color: #5E72E4
   Font: Inter
   Title Size: 24px, Weight: 700
   Body Size: 16px, Weight: 400
   Card Radius: 16px
   Shadow: 0px 4px 20px rgba(0,0,0,0.1)"
   ```

## 2. UI 템플릿 적용 방법

### 무료 Flutter UI 킷
1. **Flutter UI Challenges**
   - https://github.com/lohanidamodar/flutter_ui_challenges
   - 스크린샷 보고 원하는 UI 선택

2. **Best Flutter UI Templates**
   - https://github.com/mitesh77/Best-Flutter-UI-Templates
   - 교육 앱 템플릿 포함

3. **Flutter Catalog**
   - https://github.com/X-Wei/flutter_catalog
   - 컴포넌트별 예제

### Claude Code에 적용하는 단계

#### Step 1: 템플릿에서 원하는 화면 찾기
```
예시: "Study Timer Screen" 템플릿을 찾았다면
1. 해당 화면의 스크린샷 캡처
2. 코드가 있다면 주요 부분 복사
```

#### Step 2: Claude Code에 요청
```
"첨부한 이미지처럼 Timer 화면을 만들어줘.
특히 다음 요소들을 포함해줘:
- 원형 프로그레스바
- 그라데이션 배경
- 글래스모피즘 효과"
```

#### Step 3: 컴포넌트별로 적용
```
"이 CardWidget을 우리 앱의 모든 카드에 적용해줘"
```

## 3. 실전 예시: Dribbble 디자인 적용

### Step 1: Dribbble에서 디자인 찾기
- https://dribbble.com/search/study-app
- 마음에 드는 디자인 선택

### Step 2: 디자인 분석
```
1. 색상 팔레트 파악
2. 컴포넌트 스타일 분석
3. 레이아웃 구조 이해
```

### Step 3: Claude Code에 단계별 요청
```
1차: "이 색상 팔레트로 테마 만들어줘"
2차: "이 카드 디자인처럼 바꿔줘"
3차: "이 레이아웃으로 화면 구성해줘"
```

## 4. 폰트 적용 방법

### Google Fonts 사용
```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.1.0
```

```dart
// Claude Code에 요청:
"Poppins 폰트를 전체 앱에 적용해줘"
```

### 커스텀 폰트 사용
```
1. 폰트 파일(.ttf) 다운로드
2. assets/fonts/ 폴더에 저장
3. Claude Code에 요청:
   "Inter 폰트를 assets/fonts/Inter.ttf에서 불러와서 적용해줘"
```

## 5. 아이콘 팩 적용

### 인기 아이콘 팩
1. **Feather Icons**
   ```yaml
   feather_icons: ^1.2.0
   ```

2. **Font Awesome**
   ```yaml
   font_awesome_flutter: ^10.6.0
   ```

3. **Custom Icons**
   - https://www.fluttericon.com/
   - 원하는 아이콘 선택 → 다운로드 → Claude Code에 전달

## 6. 실전 팁

### 효과적인 요청 방법
```
❌ "예쁘게 만들어줘"
✅ "Material You 디자인 시스템처럼 다이나믹 컬러 적용해줘"

❌ "모던하게 바꿔줘"
✅ "Airbnb 앱처럼 미니멀하고 여백이 넓은 디자인으로"

❌ "애니메이션 추가해줘"
✅ "카드 클릭 시 스케일 0.95로 줄어드는 바운스 애니메이션"
```

### 단계별 접근
1. **색상/테마부터**: 전체적인 분위기 결정
2. **타이포그래피**: 가독성과 계층 구조
3. **컴포넌트**: 버튼, 카드, 입력창 등
4. **레이아웃**: 여백과 정렬
5. **애니메이션**: 마지막 터치

## 7. 추천 리소스

### 디자인 시스템
- **Material Design 3**: https://m3.material.io/
- **Apple HIG**: https://developer.apple.com/design/
- **Fluent Design**: https://fluent2.microsoft.design/

### Flutter UI 갤러리
- **Flutter Gallery**: 공식 위젯 쇼케이스
- **FlutterFlow Templates**: https://marketplace.flutterflow.io/
- **Rive**: 애니메이션 에셋

### 색상 도구
- **Coolors**: https://coolors.co/
- **Adobe Color**: https://color.adobe.com/
- **Material Theme Builder**: https://m3.material.io/theme-builder

## 8. Claude Code 활용 예시

### 전체 테마 변경
```
"Spotify 앱의 다크 테마처럼 만들어줘:
- 배경: #121212
- 카드: #282828
- 강조색: #1DB954
- 둥근 모서리
- 부드러운 그림자"
```

### 특정 화면 개선
```
"Pinterest의 그리드 레이아웃처럼
Staggered Grid로 노트 목록 보여줘"
```

### 애니메이션 추가
```
"Duolingo처럼 퀘스트 완료 시
confetti 애니메이션 추가해줘"
```