import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Navigation Shell removed - no bottom navigation

// 새로 만든 스크린들만 import
// Auth Screens
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/email_verification_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';

// Onboarding Screens  
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/personalization_screen.dart';
import '../features/onboarding/screens/learning_type_test_screen.dart';

// Home Screens
import '../features/home/screens/home_screen_new.dart';
import '../features/todo/screens/todo_screen.dart';

// Study Screens
import '../features/study/screens/study_screen.dart';
import '../features/study/screens/lesson_screen.dart';
import '../features/study/screens/quiz_screen.dart';
import '../features/study/screens/flashcard_screen.dart';
import '../features/study/screens/topic_screen.dart';
import '../features/study/screens/schedule_screen.dart';
import '../features/study/screens/video_player_screen.dart';
import '../features/study/screens/pdf_viewer_screen.dart';
import '../features/study/screens/resource_screen.dart';
import '../features/study/screens/subject_list_screen.dart';
import '../features/study/screens/practice_screen.dart';

// AI Screens
import '../features/ai/screens/ai_tutor_screen.dart';
import '../features/ai/screens/ai_analysis_screen.dart';
import '../features/ai/screens/ai_chat_screen.dart';

// Community Screens
import '../features/community/screens/community_screen.dart';
import '../features/community/screens/forum_screen.dart';

// Social Screens
import '../features/social/screens/ranking_screen.dart';
import '../features/social/screens/mentor_screen.dart';

// Profile & Settings Screens
import '../features/settings/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/notification_settings_screen.dart';
import '../features/settings/screens/privacy_screen.dart';
import '../features/settings/screens/subscription_screen.dart';
import '../features/settings/screens/help_screen.dart';

// Achievement Screens
import '../features/achievement/screens/badge_screen.dart';
import '../features/achievement/screens/certificate_screen.dart';

// Progress Screens
import '../features/progress/screens/progress_screen.dart';
import '../features/progress/screens/goals_screen.dart';
import '../features/progress/screens/statistics_screen.dart';

// Gamification Screens
import '../features/gamification/screens/quest_screen.dart';
import '../features/gamification/screens/daily_mission_screen.dart';
import '../features/gamification/screens/reward_screen.dart';
import '../features/gamification/screens/shop_screen.dart';

// Tools Screens
import '../features/tools/screens/timer_screen.dart';
import '../features/tools/screens/note_screen.dart';
import '../features/tools/screens/bookmark_screen.dart';
import '../features/tools/screens/history_screen.dart';

// Other Screens
import '../features/notifications/screens/notification_screen.dart';
import '../features/search/screens/search_screen.dart';

// Additional Screens (previously unconnected)
import '../features/auth/screens/splash_screen.dart';
import '../features/social/screens/study_groups_screen.dart';
import '../features/ai/screens/ai_summary_screen.dart';
import '../features/progress/screens/achievements_screen.dart';
import '../features/progress/screens/leaderboard_screen.dart';

// Simple auth state provider (나중에 실제 인증으로 교체)
final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier();
});

class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(true); // 임시로 true로 설정하여 로그인된 상태로 시작
  
  void login() => state = true;
  void logout() => state = false;
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: isAuthenticated ? '/home' : '/login',
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes (로그인 필요 없음)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        name: 'emailVerification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      
      // Onboarding Routes
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/personalization',
        name: 'personalization',
        builder: (context, state) => const PersonalizationScreen(),
      ),
      GoRoute(
        path: '/learning-type-test',
        name: 'learningTypeTest',
        builder: (context, state) => const LearningTypeTestScreen(),
      ),
      
      // Main Routes (no bottom navigation)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreenNew(),
        routes: [
          GoRoute(
            path: 'progress',
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: 'goals',
            name: 'goals',
            builder: (context, state) => const GoalsScreen(),
          ),
          GoRoute(
            path: 'timer',
            name: 'timer',
            builder: (context, state) => const TimerScreen(),
          ),
        ],
      ),
      
      // Todo Route
      GoRoute(
        path: '/todo',
        name: 'todo',
        builder: (context, state) => const TodoScreen(),
      ),
      
      // Calendar Route
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const ScheduleScreen(),
      ),
      
      // AI Routes
      GoRoute(
        path: '/ai',
        name: 'ai',
        builder: (context, state) => const AITutorScreen(),
        routes: [
          GoRoute(
            path: 'analysis',
            name: 'aiAnalysis',
            builder: (context, state) => const AIAnalysisScreen(),
          ),
          GoRoute(
            path: 'chat',
            name: 'aiChat',
            builder: (context, state) => const AIChatScreen(),
          ),
          GoRoute(
            path: 'summary',
            name: 'aiSummary',
            builder: (context, state) => const AISummaryScreen(),
          ),
        ],
      ),
      
      // Standalone Routes (전체 화면)
      // Study Routes
      GoRoute(
        path: '/study',
        name: 'study',
        builder: (context, state) => const StudyScreen(),
      ),
      GoRoute(
        path: '/study/lesson',
        name: 'lesson',
        builder: (context, state) => const LessonScreen(),
      ),
      GoRoute(
        path: '/study/quiz',
        name: 'quiz',
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: '/study/flashcard',
        name: 'flashcard',
        builder: (context, state) => const FlashcardScreen(),
      ),
      GoRoute(
        path: '/study/topic',
        name: 'topic',
        builder: (context, state) => const TopicScreen(),
      ),
      GoRoute(
        path: '/study/video',
        name: 'videoPlayer',
        builder: (context, state) => const VideoPlayerScreen(),
      ),
      GoRoute(
        path: '/study/pdf',
        name: 'pdfViewer',
        builder: (context, state) => const PDFViewerScreen(),
      ),
      GoRoute(
        path: '/study/resource',
        name: 'resource',
        builder: (context, state) => const ResourceScreen(),
      ),
      GoRoute(
        path: '/study/subjects',
        name: 'subjectList',
        builder: (context, state) => const SubjectListScreen(),
      ),
      GoRoute(
        path: '/study/practice',
        name: 'practice',
        builder: (context, state) => const PracticeScreen(),
      ),
      
      // Community Routes
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/community/forum',
        name: 'forum',
        builder: (context, state) => const ForumScreen(),
      ),
      
      // Social Routes
      GoRoute(
        path: '/social/ranking',
        name: 'ranking',
        builder: (context, state) => const RankingScreen(),
      ),
      GoRoute(
        path: '/social/mentor',
        name: 'mentor',
        builder: (context, state) => const MentorScreen(),
      ),
      
      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Settings Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/settings/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),
      
      // Achievement Routes
      GoRoute(
        path: '/achievement/badges',
        name: 'badges',
        builder: (context, state) => const BadgeScreen(),
      ),
      GoRoute(
        path: '/achievement/certificates',
        name: 'certificates',
        builder: (context, state) => const CertificateScreen(),
      ),
      
      // Statistics Routes
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      
      // Notification Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      
      // Search Routes
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      
      // Gamification Routes
      GoRoute(
        path: '/gamification/quest',
        name: 'quest',
        builder: (context, state) => const QuestScreen(),
      ),
      GoRoute(
        path: '/gamification/mission',
        name: 'dailyMission',
        builder: (context, state) => const DailyMissionScreen(),
      ),
      GoRoute(
        path: '/gamification/reward',
        name: 'reward',
        builder: (context, state) => const RewardScreen(),
      ),
      GoRoute(
        path: '/gamification/shop',
        name: 'shop',
        builder: (context, state) => const ShopScreen(),
      ),
      
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Study Groups
      GoRoute(
        path: '/social/study-groups',
        name: 'studyGroups',
        builder: (context, state) => const StudyGroupsScreen(),
      ),
      
      // Additional Progress Routes
      GoRoute(
        path: '/progress/achievements',
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/progress/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      
      // Tools Routes
      GoRoute(
        path: '/tools/note',
        name: 'note',
        builder: (context, state) => const NoteScreen(),
      ),
      GoRoute(
        path: '/tools/bookmark',
        name: 'bookmark',
        builder: (context, state) => const BookmarkScreen(),
      ),
      GoRoute(
        path: '/tools/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
    
    // 간단한 리다이렉트 로직
    redirect: (context, state) {
      final isAuth = ref.read(authStateProvider);
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/signup' ||
                         state.matchedLocation == '/forgot-password' ||
                         state.matchedLocation == '/email-verification';
      
      // 로그인 안됐는데 보호된 페이지 접근 시
      if (!isAuth && !isAuthRoute) {
        return '/login';
      }
      
      // 로그인 됐는데 로그인 페이지 접근 시
      if (isAuth && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
  );
});