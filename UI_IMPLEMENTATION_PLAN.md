# 🚀 HYLE UI 전면 재구현 계획서
*작성일: 2025년 9월 8일*
*업데이트: 실제 UI 스크린샷 178개 분석 완료*

## 📋 개요
기존 UI를 모두 폐기하고 실제 UI 스크린샷 178개와 업데이트된 스타일 가이드를 기반으로 처음부터 재구현

## ✅ 완료된 사전 작업
- [x] 178개 UI 스크린샷 실제 분석
- [x] general_style_guide.md 실제 UI 기반 업데이트
- [x] Pretendard 폰트 설정 완료
- [x] 컬러 시스템 확정 (초록 #4CD964, 보라 #8B5CF6 등)

## 🎯 구현 원칙
1. **No Duplication**: 중복 파일 절대 금지
2. **Clear Naming**: 명확한 파일명 규칙 준수
3. **Reference First**: 레퍼런스 스크린샷 우선 참조
4. **Style Guide Compliance**: 스타일 가이드 100% 준수

---

## 📁 파일명 규칙

### 화면 파일명 규칙
```
{number}_{feature}_{type}_screen.dart

예시:
01_splash_screen.dart           // 스플래시
02_onboarding_screen.dart       // 온보딩
03_login_screen.dart            // 로그인
10_home_main_screen.dart        // 홈 메인
11_home_dashboard_screen.dart   // 홈 대시보드
```

### 위젯 파일명 규칙
```
widgets/{feature}/{widget_name}_widget.dart

예시:
widgets/home/daily_goal_widget.dart
widgets/home/study_time_widget.dart
widgets/common/bottom_nav_widget.dart
```

---

## 🏗️ 구현 순서 (5단계)

### Phase 1: 기초 시스템 구축 (Day 1)
```
1. Font 설정
   - Pretendard 폰트 복사 및 pubspec.yaml 설정
   
2. Design System
   - design_system/
     ├── colors.dart         // 컬러 팔레트
     ├── typography.dart      // 텍스트 스타일
     ├── spacing.dart         // 간격 시스템
     ├── shadows.dart         // 그림자
     └── theme.dart          // 테마 통합

3. Common Widgets
   - widgets/common/
     ├── hy_button.dart      // 공통 버튼
     ├── hy_input.dart       // 입력 필드
     ├── hy_card.dart        // 카드
     └── hy_loading.dart     // 로딩
```

### Phase 2: 인증 & 온보딩 (Day 2)
```
screens/auth/
├── 01_splash_screen.dart
├── 02_onboarding_screen.dart
├── 03_login_screen.dart
├── 04_signup_screen.dart
├── 05_forgot_password_screen.dart
└── 06_learning_type_test_screen.dart

widgets/auth/
├── social_login_widget.dart
├── onboarding_page_widget.dart
└── learning_type_question_widget.dart
```

### Phase 3: 메인 네비게이션 & 홈 (Day 3)
```
screens/main/
├── 10_home_main_screen.dart
├── 11_home_dashboard_screen.dart
├── 20_statistics_screen.dart
├── 30_timer_main_screen.dart
├── 40_social_main_screen.dart
└── 50_profile_main_screen.dart

widgets/navigation/
├── bottom_nav_widget.dart
├── floating_menu_widget.dart
└── hamburger_menu_widget.dart

widgets/home/
├── daily_goal_circle_widget.dart
├── study_time_display_widget.dart
├── subject_time_chart_widget.dart
├── todo_summary_widget.dart
└── dday_counter_widget.dart
```

### Phase 4: 핵심 기능 (Day 4-5)
```
screens/study/
├── 31_timer_session_screen.dart
├── 32_pomodoro_screen.dart
├── 33_stopwatch_screen.dart
├── 60_todo_list_screen.dart
├── 61_todo_detail_screen.dart
├── 70_calendar_screen.dart
├── 80_notes_list_screen.dart
├── 81_note_editor_screen.dart
├── 90_flashcard_deck_screen.dart
└── 91_flashcard_study_screen.dart

widgets/study/
├── timer_circle_widget.dart
├── todo_item_widget.dart
├── calendar_day_widget.dart
├── note_card_widget.dart
└── flashcard_flip_widget.dart
```

### Phase 5: 게이미피케이션 & AI (Day 6-7)
```
screens/gamification/
├── 100_missions_screen.dart
├── 101_daily_quest_screen.dart
├── 110_leaderboard_screen.dart
├── 120_achievements_screen.dart
├── 130_store_screen.dart
└── 140_rewards_screen.dart

screens/ai/
├── 150_ai_tutor_chat_screen.dart
├── 151_ai_insights_screen.dart
├── 152_ai_planner_screen.dart
└── 153_ai_recommendation_screen.dart

screens/social/
├── 41_friends_list_screen.dart
├── 42_study_groups_screen.dart
├── 43_study_reels_screen.dart
├── 44_community_feed_screen.dart
└── 45_chat_room_screen.dart
```

---

## 🎨 레퍼런스 매핑

### 폴더별 스크린 매핑
```
1. 스플래시 화면, 온보딩/      → 01_splash, 02_onboarding
2. 로그인, 회원가입/          → 03_login, 04_signup, 05_forgot
3. 홈/                      → 10_home_main, 11_home_dashboard
4. 알림/                    → 12_notifications
5. 프로필/                  → 50_profile_main
6. 통계, 대시보드/           → 20_statistics
7. 투두리스트/               → 60_todo_list
8. 캘린더/                  → 70_calendar
9. 플래시카드/               → 90_flashcard_deck
10. 퀘스트, 미션/            → 100_missions, 101_daily_quest
11. 데일리 스택/             → 102_daily_streak
12. 리더보드/                → 110_leaderboard
13. 그룹, 클럽/              → 42_study_groups
14. SNS 커뮤니티/            → 44_community_feed
15. AI Chat/                → 150_ai_tutor_chat
timer, stopwatch/           → 30_timer_main, 31_timer_session
```

---

## 📱 화면 크기별 대응

### Breakpoints
```dart
const double mobileBreakpoint = 600;   // < 600px: 모바일
const double tabletBreakpoint = 900;   // 600-900px: 태블릿
const double desktopBreakpoint = 1200; // > 900px: 데스크톱
```

### Responsive Layout
- **Mobile First**: 모바일 우선 설계
- **Adaptive**: 화면 크기에 따른 레이아웃 변경
- **Flexible**: Flexible/Expanded 활용

---

## ✅ 구현 체크리스트

### Day 1 - Foundation
- [ ] Pretendard 폰트 설정
- [ ] Design System 파일 생성
- [ ] 공통 위젯 10개 구현
- [ ] 테마 시스템 구축

### Day 2 - Auth Flow
- [ ] Splash Screen
- [ ] Onboarding (3 pages)
- [ ] Login Screen
- [ ] Signup Screen
- [ ] Password Recovery
- [ ] Learning Type Test

### Day 3 - Main Navigation
- [ ] Bottom Navigation
- [ ] Home Screen
- [ ] Dashboard Widgets
- [ ] Statistics Screen
- [ ] Profile Screen

### Day 4 - Study Features
- [ ] Timer/Stopwatch/Pomodoro
- [ ] Todo List & Detail
- [ ] Calendar View
- [ ] Notes System

### Day 5 - Advanced Features
- [ ] Flashcards
- [ ] Missions & Quests
- [ ] Leaderboard
- [ ] Achievements

### Day 6 - Social & AI
- [ ] Friends System
- [ ] Study Groups
- [ ] Community Feed
- [ ] AI Tutor Chat
- [ ] AI Insights

### Day 7 - Polish & Testing
- [ ] Animation 추가
- [ ] Error States
- [ ] Empty States
- [ ] Loading States
- [ ] Responsive Testing

---

## 🚫 폐기할 기존 파일들

### 삭제 대상 (screens 폴더)
```
lib/features/*/screens/*.dart  // 모든 기존 스크린
lib/presentation/screens/       // 모든 프레젠테이션 스크린
```

### 유지할 파일
```
lib/services/               // 서비스 로직
lib/models/                 // 데이터 모델
lib/providers/              // 상태 관리 (일부 수정 필요)
```

---

## 📝 주의사항

1. **절대 기존 스크린 파일 재사용 금지**
2. **레퍼런스 스크린샷 필수 확인**
3. **파일명 규칙 엄격 준수**
4. **매일 진행상황 문서화**
5. **테스트 파일 동시 작성**

---

## 🎯 성공 기준

- ✅ 모든 화면이 스타일 가이드 준수
- ✅ 178개 레퍼런스 반영률 90% 이상
- ✅ 중복 파일 0개
- ✅ 네이밍 규칙 100% 준수
- ✅ 반응형 디자인 구현
- ✅ 애니메이션 적용
- ✅ 에러/로딩/빈 상태 처리

---

**이 계획서를 기준으로 7일 안에 전체 UI 재구현 완료**