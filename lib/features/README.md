# HYLE Features Structure

## 📁 폴더 구조

```
lib/features/
├── 🚀 onboarding/       # 온보딩 & 초기 설정
├── 🔐 auth/             # 인증 & 계정 관리
├── 🏠 home/             # 홈 대시보드
├── 📚 study/            # 학습 기능
├── 📊 progress/         # 진도 & 통계
├── 👥 community/        # 커뮤니티 & 소셜
├── 🤖 ai/               # AI 기능
├── ⚙️ settings/         # 설정 & 프로필
├── 📖 content/          # 콘텐츠 뷰어
├── 🎮 gamification/    # 게이미피케이션
└── 🔍 utility/         # 유틸리티

```

## 📂 각 Feature 폴더 구조

각 feature 폴더는 다음과 같은 하위 구조를 가집니다:

```
feature_name/
├── screens/     # 화면 컴포넌트
├── widgets/     # 재사용 가능한 위젯
├── providers/   # 상태 관리 (Riverpod)
└── models/      # 데이터 모델
```

## 🎯 Feature별 주요 스크린

### 1. 🚀 **onboarding/** (5개 스크린)
- `splash_screen.dart` - 앱 시작 화면
- `onboarding_screen.dart` - 앱 소개
- `learning_type_test_screen.dart` - 학습 유형 진단
- `personalization_screen.dart` - 맞춤 설정
- `welcome_screen.dart` - 환영 화면

### 2. 🔐 **auth/** (5개 스크린)
- `login_screen.dart` - 로그인
- `signup_screen.dart` - 회원가입
- `forgot_password_screen.dart` - 비밀번호 찾기
- `email_verification_screen.dart` - 이메일 인증
- `password_reset_screen.dart` - 비밀번호 재설정

### 3. 🏠 **home/** (1개 메인 + 컴포넌트)
- `home_screen.dart` - 메인 대시보드
- widgets/
  - `quick_actions.dart`
  - `study_streak.dart`
  - `daily_missions.dart`
  - `ai_recommendations.dart`

### 4. 📚 **study/** (8개 스크린)
- `study_screen.dart` - 학습 허브
- `subject_list_screen.dart` - 과목 목록
- `topic_screen.dart` - 주제별 학습
- `lesson_screen.dart` - 개별 수업
- `practice_screen.dart` - 문제 풀이
- `flashcard_screen.dart` - 플래시카드
- `quiz_screen.dart` - 퀴즈/시험
- `review_screen.dart` - 복습

### 5. 📊 **progress/** (6개 스크린)
- `progress_screen.dart` - 진도 메인
- `statistics_screen.dart` - 통계
- `achievements_screen.dart` - 업적/배지
- `leaderboard_screen.dart` - 리더보드
- `goals_screen.dart` - 목표 관리
- `report_screen.dart` - 학습 리포트

### 6. 👥 **community/** (6개 스크린)
- `community_screen.dart` - 커뮤니티 메인
- `study_groups_screen.dart` - 스터디 그룹
- `group_chat_screen.dart` - 그룹 채팅
- `forum_screen.dart` - 포럼/Q&A
- `mentor_screen.dart` - 멘토링
- `events_screen.dart` - 이벤트/챌린지

### 7. 🤖 **ai/** (6개 스크린)
- `ai_assistant_screen.dart` - AI 도우미 메인
- `ai_chat_screen.dart` - 대화형 학습
- `ai_tutor_screen.dart` - AI 튜터
- `ai_summary_screen.dart` - 요약 생성
- `ai_analysis_screen.dart` - 학습 분석
- `ai_question_screen.dart` - 질문 생성

### 8. ⚙️ **settings/** (8개 스크린)
- `settings_screen.dart` - 설정 메인
- `edit_profile_screen.dart` - 프로필 편집
- `theme_settings_screen.dart` - 테마 설정
- `notification_settings_screen.dart` - 알림 설정
- `privacy_screen.dart` - 개인정보 관리
- `subscription_screen.dart` - 구독 관리
- `language_screen.dart` - 언어 설정
- `help_screen.dart` - 도움말

### 9. 📖 **content/** (5개 스크린)
- `video_player_screen.dart` - 동영상 플레이어
- `pdf_viewer_screen.dart` - PDF 뷰어
- `note_editor_screen.dart` - 노트 에디터
- `whiteboard_screen.dart` - 화이트보드
- `audio_player_screen.dart` - 오디오 플레이어

### 10. 🎮 **gamification/** (5개 스크린)
- `daily_mission_screen.dart` - 일일 미션
- `quest_screen.dart` - 장기 퀘스트
- `reward_screen.dart` - 보상 센터
- `shop_screen.dart` - 아이템 샵
- `badge_gallery_screen.dart` - 배지 갤러리

### 11. 🔍 **utility/** (4개 스크린)
- `search_screen.dart` - 통합 검색
- `notification_screen.dart` - 알림 센터
- `calendar_screen.dart` - 학습 캘린더
- `timer_screen.dart` - 학습 타이머

## 🎨 개발 가이드

### 네이밍 컨벤션
- **스크린**: `feature_name_screen.dart`
- **위젯**: `widget_name.dart`
- **프로바이더**: `feature_name_provider.dart`
- **모델**: `feature_name_model.dart`

### 파일 구조 예시
```dart
// screens/login_screen.dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  // ...
}

// widgets/login_form.dart
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});
  // ...
}

// providers/auth_provider.dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);

// models/user_model.dart
class UserModel {
  // ...
}
```

## 📱 Import 경로
```dart
// Feature 내부에서
import '../widgets/widget_name.dart';
import '../models/model_name.dart';

// Feature 간 import
import 'package:hyle/features/auth/providers/auth_provider.dart';
import 'package:hyle/features/home/screens/home_screen.dart';

// Core imports
import 'package:hyle/core/theme/app_theme.dart';
import 'package:hyle/core/widgets/common_button.dart';
```

## 🚀 개발 우선순위

### Phase 1 (MVP) - 필수
- ✅ auth (login, signup)
- ✅ onboarding (splash, onboarding)
- ✅ home (dashboard)
- ✅ study (basic features)
- ✅ ai (chat only)

### Phase 2 - 확장
- progress (statistics, achievements)
- community (basic features)
- settings (essential settings)

### Phase 3 - 고급
- gamification (all features)
- content (advanced viewers)
- utility (all utilities)

---

각 feature 폴더에 필요한 스크린을 단계적으로 구현해나가면 됩니다.