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
import '../../home/screens/home_screen.dart';

// Profile screens (using settings)
import '../../settings/screens/profile_screen.dart';

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
  String _selectedCategory = 'All';

  final Map<String, List<ScreenInfo>> _screensByCategory = {
    'Auth': [
      ScreenInfo('Login', const LoginScreen(), Icons.login),
      ScreenInfo('Signup', const SignupScreen(), Icons.person_add),
      ScreenInfo('Email Verification', const EmailVerificationScreen(), Icons.email),
      ScreenInfo('Forgot Password', const ForgotPasswordScreen(), Icons.lock_reset),
    ],
    'Onboarding': [
      ScreenInfo('Onboarding', const OnboardingScreen(), Icons.start),
      ScreenInfo('Personalization', const PersonalizationScreen(), Icons.tune),
      ScreenInfo('Learning Type Test', const LearningTypeTestScreen(), Icons.psychology),
    ],
    'Home': [
      ScreenInfo('Home', const HomeScreen(), Icons.home),
      ScreenInfo('Profile', const ProfileScreen(), Icons.person),
    ],
    'Study': [
      ScreenInfo('Lesson', const LessonScreen(), Icons.school),
      ScreenInfo('Quiz', const QuizScreen(), Icons.quiz),
      ScreenInfo('Flashcard', const FlashcardScreen(), Icons.style),
      ScreenInfo('Topic', const TopicScreen(), Icons.topic),
      ScreenInfo('Schedule', const ScheduleScreen(), Icons.schedule),
      ScreenInfo('Video Player', const VideoPlayerScreen(), Icons.play_circle),
      ScreenInfo('PDF Viewer', const PDFViewerScreen(), Icons.picture_as_pdf),
      ScreenInfo('Resource', const ResourceScreen(), Icons.folder),
    ],
    'Progress': [
      ScreenInfo('Progress', const ProgressScreen(), Icons.trending_up),
      ScreenInfo('Goals', const GoalsScreen(), Icons.flag),
      ScreenInfo('Statistics', const StatisticsScreen(), Icons.bar_chart),
    ],
    'AI': [
      ScreenInfo('AI Tutor', const AITutorScreen(), Icons.smart_toy),
      ScreenInfo('AI Analysis', const AIAnalysisScreen(), Icons.analytics),
      ScreenInfo('AI Chat', const AIChatScreen(), Icons.chat_bubble),
    ],
    'Community': [
      ScreenInfo('Community', const CommunityScreen(), Icons.people),
      ScreenInfo('Forum', const ForumScreen(), Icons.forum),
    ],
    'Social': [
      ScreenInfo('Ranking', const RankingScreen(), Icons.leaderboard),
      ScreenInfo('Mentor', const MentorScreen(), Icons.supervisor_account),
    ],
    'Gamification': [
      ScreenInfo('Quest', const QuestScreen(), Icons.explore),
      ScreenInfo('Daily Mission', const DailyMissionScreen(), Icons.today),
      ScreenInfo('Reward', const RewardScreen(), Icons.card_giftcard),
      ScreenInfo('Shop', const ShopScreen(), Icons.shopping_cart),
    ],
    'Tools': [
      ScreenInfo('Timer', const TimerScreen(), Icons.timer),
      ScreenInfo('Note', const NoteScreen(), Icons.note),
      ScreenInfo('Bookmark', const BookmarkScreen(), Icons.bookmark),
      ScreenInfo('History', const HistoryScreen(), Icons.history),
    ],
    'Settings': [
      ScreenInfo('Settings', const SettingsScreen(), Icons.settings),
      ScreenInfo('Notification Settings', const NotificationSettingsScreen(), Icons.notifications),
      ScreenInfo('Privacy', const PrivacyScreen(), Icons.privacy_tip),
      ScreenInfo('Subscription', const SubscriptionScreen(), Icons.subscriptions),
      ScreenInfo('Help', const HelpScreen(), Icons.help),
    ],
    'Achievement': [
      ScreenInfo('Badge', const BadgeScreen(), Icons.military_tech),
      ScreenInfo('Certificate', const CertificateScreen(), Icons.workspace_premium),
    ],
  };

  List<ScreenInfo> get _filteredScreens {
    List<ScreenInfo> allScreens = [];
    
    if (_selectedCategory == 'All') {
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
            '$totalScreens MVP Screens Ready',
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
          hintText: 'Search screens...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF8AAEE0)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ..._screensByCategory.keys];
    
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
          'No screens found',
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