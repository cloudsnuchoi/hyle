import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/local_storage_service.dart';
import 'core/theme/app_theme.dart';

// ===== Auth Screens (10개) =====
import 'features/auth/screens/login_screen.dart' as basic;
import 'features/auth/screens/login_screen_enhanced.dart';
import 'features/auth/screens/login_screen_minimal.dart';
import 'features/auth/screens/login_screen_simple.dart' as simple;
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/beta_signup_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/beta_reset_password_screen.dart';
import 'features/auth/screens/confirmation_screen.dart';
import 'features/auth/screens/splash_screen.dart';

// ===== Home Screens (3개) =====
import 'features/home/screens/home_screen.dart';
import 'features/home/screens/home_screen_minimal.dart';
import 'features/home/screens/home_screen_mobile.dart';

// ===== Profile Screens (5개) =====
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/profile_screen_improved.dart';
import 'features/profile/screens/profile_screen_simple.dart';
import 'features/profile/screens/user_profile_screen.dart';
import 'features/profile/screens/user_profile_screen_enhanced.dart';

// ===== Timer Screens (3개) =====
import 'features/timer/screens/timer_screen.dart';
import 'features/timer/screens/timer_screen_enhanced.dart';
import 'features/timer/screens/timer_screen_gamified.dart';

// ===== Todo Screens (3개) =====
import 'features/todo/screens/todo_screen.dart';
import 'features/todo/screens/todo_screen_enhanced.dart';
import 'features/todo/screens/todo_screen_with_categories.dart';

// ===== Notes Screens (3개) =====
import 'features/notes/screens/notes_screen.dart';
import 'features/notes/screens/notes_screen_enhanced.dart';
import 'features/notes/screens/note_edit_screen.dart';

// ===== Flashcards Screens (4개) =====
import 'features/flashcards/screens/flashcards_screen.dart';
import 'features/flashcards/screens/deck_screen.dart';
import 'features/flashcards/screens/study_screen.dart';
import 'features/flashcards/screens/flashcard_edit_screen.dart';

// ===== AI Screens (4개) =====
import 'features/ai/screens/ai_assistant_screen.dart';
import 'features/ai/screens/ai_features_screen.dart';
import 'presentation/screens/ai/ai_insights_screen.dart';
import 'presentation/screens/ai/ai_planner_screen.dart';

// ===== Learning Type Screens (2개) =====
import 'features/learning_type/screens/learning_type_test_screen.dart' as features_learning;
import 'features/learning_type/screens/learning_type_result_detail_screen.dart';
// presentation 버전도 있지만 features 버전 사용

// ===== Schedule Screens (2개) =====
import 'features/schedule/screens/schedule_screen.dart';
import 'features/schedule/screens/schedule_screen_improved.dart';

// ===== Settings Screens (2개) =====
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/theme_settings_screen.dart';

// ===== Statistics Screens (1개) =====
import 'features/statistics/screens/learning_statistics_screen.dart';

// ===== Mission Screens (1개) =====
import 'presentation/screens/missions/missions_screen.dart';

// ===== Social Screens (3개) =====
import 'presentation/screens/social/friends_screen.dart';
// import 'presentation/screens/social/study_groups_screen.dart'; // 컴파일 에러
// import 'presentation/screens/social/study_reels_screen.dart'; // 컴파일 에러

// ===== Admin Screens (1개) =====
import 'features/admin/screens/beta_admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const ProviderScope(child: ScreenTestApp()));
}

class ScreenTestApp extends StatelessWidget {
  const ScreenTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HYLE Screen Test',
      theme: AppTheme.lightTheme(),
      themeMode: ThemeMode.light,
      home: const ScreenGallery(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScreenGallery extends StatelessWidget {
  const ScreenGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      // ===== 🔐 Auth Screens (10개) =====
      ScreenInfo('🔐 Login - Basic', const basic.LoginScreen()),
      ScreenInfo('🔐 Login - Enhanced', const LoginScreenEnhanced()),
      ScreenInfo('🔐 Login - Minimal', const LoginScreenMinimal()),
      ScreenInfo('🔐 Login - Simple', const simple.LoginScreen()),
      ScreenInfo('🔐 Signup', const SignupScreen()),
      ScreenInfo('🔐 Beta Signup', const BetaSignupScreen()),
      ScreenInfo('🔐 Forgot Password', const ForgotPasswordScreen()),
      ScreenInfo('🔐 Reset Password (Beta)', const BetaResetPasswordScreen()),
      ScreenInfo('🔐 Confirmation', const ConfirmationScreen(email: 'test@example.com')), // 필수 파라미터 추가
      ScreenInfo('🔐 Splash', const SplashScreen()),
      
      // ===== 🏠 Home Screens (3개) =====
      ScreenInfo('🏠 Home - Basic', const HomeScreen()),
      ScreenInfo('🏠 Home - Minimal', const HomeScreenMinimal()),
      ScreenInfo('🏠 Home - Mobile', const HomeScreenMobile()),
      
      // ===== 👤 Profile Screens (5개) =====
      ScreenInfo('👤 Profile - Basic', const ProfileScreen()),
      ScreenInfo('👤 Profile - Improved', const ProfileScreenImproved()),
      ScreenInfo('👤 Profile - Simple', const ProfileScreenSimple()),
      ScreenInfo('👤 User Profile - Basic', const UserProfileScreen()),
      ScreenInfo('👤 User Profile - Enhanced', const UserProfileScreenEnhanced()),
      
      // ===== ⏰ Timer Screens (3개) =====
      ScreenInfo('⏰ Timer - Basic', const TimerScreen()),
      ScreenInfo('⏰ Timer - Enhanced', const TimerScreenEnhanced()),
      ScreenInfo('⏰ Timer - Gamified', const TimerScreenGamified()),
      
      // ===== ✅ Todo Screens (3개) =====
      ScreenInfo('✅ Todo - Basic', const TodoScreen()),
      ScreenInfo('✅ Todo - Enhanced', const TodoScreenEnhanced()),
      ScreenInfo('✅ Todo - With Categories', const TodoScreenWithCategories()),
      
      // ===== 📝 Notes Screens (3개) =====
      ScreenInfo('📝 Notes - Basic', const NotesScreen()),
      ScreenInfo('📝 Notes - Enhanced', const NotesScreenEnhanced()),
      // NoteEditScreen은 필수 파라미터가 필요하므로 제외
      
      // ===== 🎴 Flashcards Screens (4개) =====
      ScreenInfo('🎴 Flashcards', const FlashcardsScreen()),
      // DeckScreen, StudyScreen, FlashcardEditScreen은 필수 파라미터가 필요하므로 제외
      
      // ===== 🤖 AI Screens (4개) =====
      ScreenInfo('🤖 AI Assistant', const AIAssistantScreen()), // 클래스명 수정
      ScreenInfo('🤖 AI Features', const AIFeaturesScreen()), // 클래스명 수정
      ScreenInfo('🤖 AI Insights', const AIInsightsScreen()), // 클래스명 수정
      ScreenInfo('🤖 AI Planner', const AIPlannerScreen()), // 클래스명 수정
      
      // ===== 🧠 Learning Type Screens (2개) =====
      ScreenInfo('🧠 Learning Type Test', const features_learning.LearningTypeTestScreen()),
      ScreenInfo('🧠 Learning Type Result', const LearningTypeResultDetailScreen()),
      
      // ===== 📅 Schedule Screens (2개) =====
      ScreenInfo('📅 Schedule - Basic', const ScheduleScreen()),
      ScreenInfo('📅 Schedule - Improved', const ScheduleScreenImproved()),
      
      // ===== ⚙️ Settings Screens (2개) =====
      ScreenInfo('⚙️ Settings', const SettingsScreen()),
      ScreenInfo('⚙️ Theme Settings', const ThemeSettingsScreen()),
      
      // ===== 📊 Statistics Screens (1개) =====
      ScreenInfo('📊 Learning Statistics', const LearningStatisticsScreen()),
      
      // ===== 🎯 Mission Screens (1개) =====
      ScreenInfo('🎯 Missions', const MissionsScreen()),
      
      // ===== 👥 Social Screens (1개) =====
      ScreenInfo('👥 Friends', const FriendsScreen()),
      // ScreenInfo('👥 Study Groups', const StudyGroupsScreen()), // 컴파일 에러
      // ScreenInfo('👥 Study Reels', const StudyReelsScreen()), // 컴파일 에러
      
      // ===== 👨‍💼 Admin Screens (1개) =====
      ScreenInfo('👨‍💼 Beta Admin', const BetaAdminScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('HYLE Screen Gallery'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: screens.length,
        itemBuilder: (context, index) {
          final screen = screens[index];
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(screen.title),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      body: screen.widget,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForScreen(screen.title),
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    screen.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForScreen(String title) {
    if (title.contains('Login')) return Icons.login;
    if (title.contains('Home')) return Icons.home;
    if (title.contains('Profile')) return Icons.person;
    if (title.contains('Timer')) return Icons.timer;
    if (title.contains('Todo')) return Icons.check_box;
    if (title.contains('Notes')) return Icons.note;
    return Icons.widgets;
  }
}

class ScreenInfo {
  final String title;
  final Widget widget;

  ScreenInfo(this.title, this.widget);
}