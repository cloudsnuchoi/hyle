import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth screens
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/signup_screen.dart';
import '../../auth/screens/email_verification_screen.dart';
import '../../auth/screens/forgot_password_screen.dart';

// Onboarding screens
import '../../onboarding/screens/onboarding_screen.dart';
import '../../onboarding/screens/personalization_screen.dart';
import '../../onboarding/screens/learning_type_test_screen.dart';

// Home screens
import '../../home/screens/home_screen_new.dart';

// Profile screens (using settings)
import '../../settings/screens/profile_screen.dart';

// Todo screens
import '../../todo/screens/todo_screen.dart';

// Study screens
import '../../study/screens/lesson_screen.dart';
import '../../study/screens/quiz_screen.dart';
import '../../study/screens/flashcard_screen.dart';
import '../../study/screens/topic_screen.dart';
import '../../study/screens/schedule_screen.dart';
import '../../study/screens/video_player_screen.dart';
import '../../study/screens/pdf_viewer_screen.dart';
import '../../study/screens/resource_screen.dart';

// Progress screens
import '../../progress/screens/progress_screen.dart';
import '../../progress/screens/goals_screen.dart';
import '../../progress/screens/statistics_screen.dart';

// AI screens
import '../../ai/screens/ai_tutor_screen.dart';
import '../../ai/screens/ai_analysis_screen.dart';
import '../../ai/screens/ai_chat_screen.dart';

// Community screens
import '../../community/screens/community_screen.dart';
import '../../community/screens/forum_screen.dart';

// Social screens
import '../../social/screens/ranking_screen.dart';
import '../../social/screens/mentor_screen.dart';

// Gamification screens
import '../../gamification/screens/quest_screen.dart';
import '../../gamification/screens/daily_mission_screen.dart';
import '../../gamification/screens/reward_screen.dart';
import '../../gamification/screens/shop_screen.dart';

// Tools screens
import '../../tools/screens/timer_screen.dart';
import '../../tools/screens/note_screen.dart';
import '../../tools/screens/bookmark_screen.dart';
import '../../tools/screens/history_screen.dart';

// Settings screens
import '../../settings/screens/settings_screen.dart';
import '../../settings/screens/notification_settings_screen.dart';
import '../../settings/screens/privacy_screen.dart';
import '../../settings/screens/subscription_screen.dart';
import '../../settings/screens/help_screen.dart';

// Achievement screens
import '../../achievement/screens/badge_screen.dart';
import '../../achievement/screens/certificate_screen.dart';

class ScreenGallery extends ConsumerStatefulWidget {
  const ScreenGallery({super.key});

  @override
  ConsumerState<ScreenGallery> createState() => _ScreenGalleryState();
}

class _ScreenGalleryState extends ConsumerState<ScreenGallery> {
  String _searchQuery = '';
  String _selectedCategory = '전체';

  final Map<String, List<ScreenInfo>> _screensByCategory = {
    '인증': [
      ScreenInfo('로그인', const LoginScreen(), Icons.login),
      ScreenInfo('회원가입', const SignupScreen(), Icons.person_add),
      ScreenInfo('이메일 인증', const EmailVerificationScreen(), Icons.email),
      ScreenInfo('비밀번호 찾기', const ForgotPasswordScreen(), Icons.lock_reset),
    ],
    '온보딩': [
      ScreenInfo('온보딩', const OnboardingScreen(), Icons.start),
      ScreenInfo('개인화 설정', const PersonalizationScreen(), Icons.tune),
      ScreenInfo('학습 유형 테스트', const LearningTypeTestScreen(), Icons.psychology),
    ],
    '홈': [
      ScreenInfo('홈', const HomeScreenNew(), Icons.home),
      ScreenInfo('프로필', const ProfileScreen(), Icons.person),
      ScreenInfo('할 일', const TodoScreen(), Icons.checklist),
    ],
    '학습': [
      ScreenInfo('수업', const LessonScreen(), Icons.school),
      ScreenInfo('퀴즈', const QuizScreen(), Icons.quiz),
      ScreenInfo('플래시카드', const FlashcardScreen(), Icons.style),
      ScreenInfo('주제', const TopicScreen(), Icons.topic),
      ScreenInfo('일정', const ScheduleScreen(), Icons.schedule),
      ScreenInfo('비디오 플레이어', const VideoPlayerScreen(), Icons.play_circle),
      ScreenInfo('PDF 뷰어', const PDFViewerScreen(), Icons.picture_as_pdf),
      ScreenInfo('자료', const ResourceScreen(), Icons.folder),
    ],
    '진행상황': [
      ScreenInfo('진행 상황', const ProgressScreen(), Icons.trending_up),
      ScreenInfo('목표', const GoalsScreen(), Icons.flag),
      ScreenInfo('통계', const StatisticsScreen(), Icons.bar_chart),
    ],
    'AI': [
      ScreenInfo('AI 튜터', const AITutorScreen(), Icons.smart_toy),
      ScreenInfo('AI 분석', const AIAnalysisScreen(), Icons.analytics),
      ScreenInfo('AI 채팅', const AIChatScreen(), Icons.chat_bubble),
    ],
    '커뮤니티': [
      ScreenInfo('커뮤니티', const CommunityScreen(), Icons.people),
      ScreenInfo('포럼', const ForumScreen(), Icons.forum),
    ],
    '소셜': [
      ScreenInfo('랭킹', const RankingScreen(), Icons.leaderboard),
      ScreenInfo('멘토', const MentorScreen(), Icons.supervisor_account),
    ],
    '게임화': [
      ScreenInfo('퀘스트', const QuestScreen(), Icons.explore),
      ScreenInfo('일일 미션', const DailyMissionScreen(), Icons.today),
      ScreenInfo('보상', const RewardScreen(), Icons.card_giftcard),
      ScreenInfo('상점', const ShopScreen(), Icons.shopping_cart),
    ],
    '도구': [
      ScreenInfo('타이머', const TimerScreen(), Icons.timer),
      ScreenInfo('노트', const NoteScreen(), Icons.note),
      ScreenInfo('북마크', const BookmarkScreen(), Icons.bookmark),
      ScreenInfo('기록', const HistoryScreen(), Icons.history),
    ],
    '설정': [
      ScreenInfo('설정', const SettingsScreen(), Icons.settings),
      ScreenInfo('알림 설정', const NotificationSettingsScreen(), Icons.notifications),
      ScreenInfo('개인정보', const PrivacyScreen(), Icons.privacy_tip),
      ScreenInfo('구독', const SubscriptionScreen(), Icons.subscriptions),
      ScreenInfo('도움말', const HelpScreen(), Icons.help),
    ],
    '성취': [
      ScreenInfo('배지', const BadgeScreen(), Icons.military_tech),
      ScreenInfo('인증서', const CertificateScreen(), Icons.workspace_premium),
    ],
  };

  List<ScreenInfo> get _filteredScreens {
    List<ScreenInfo> allScreens = [];
    
    if (_selectedCategory == '전체') {
      _screensByCategory.forEach((category, screens) {
        allScreens.addAll(screens);
      });
    } else {
      allScreens = _screensByCategory[_selectedCategory] ?? [];
    }
    
    if (_searchQuery.isEmpty) {
      return allScreens;
    }
    
    return allScreens.where((screen) {
      return screen.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalScreens = _screensByCategory.values
        .expand((screens) => screens)
        .length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F3FA),
              Color(0xFF395886),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(totalScreens),
              _buildSearchBar(),
              _buildCategoryFilter(),
              Expanded(child: _buildScreenGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalScreens) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            '🎨 HYLE Screen Gallery',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalScreens개 MVP 스크린 준비 완료',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF638ECB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          hintText: '스크린 검색...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF8AAEE0)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['전체', ..._screensByCategory.keys];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.all(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: const Color(0xFF638ECB),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF395886),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenGrid() {
    final screens = _filteredScreens;
    
    if (screens.isEmpty) {
      return const Center(
        child: Text(
          '스크린을 찾을 수 없습니다',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF8AAEE0),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: screens.length,
      itemBuilder: (context, index) {
        return _buildScreenCard(screens[index]);
      },
    );
  }

  Widget _buildScreenCard(ScreenInfo screen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen.widget),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  screen.icon,
                  size: 30,
                  color: const Color(0xFF638ECB),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  screen.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF395886),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenInfo {
  final String name;
  final Widget widget;
  final IconData icon;

  ScreenInfo(this.name, this.widget, this.icon);
}