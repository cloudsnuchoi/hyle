import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/learning_type_provider.dart';
import '../../todo/screens/todo_screen_with_categories.dart';
import '../../learning_type/screens/learning_type_test_screen.dart';
import '../../notes/screens/notes_screen_enhanced.dart';
import '../../flashcards/screens/flashcards_screen.dart';
import '../../timer/screens/timer_screen_gamified.dart';
import '../../schedule/screens/schedule_screen_improved.dart';
import '../../ai/screens/ai_assistant_screen.dart';
import '../../profile/screens/profile_screen_simple.dart';
import '../../statistics/screens/learning_statistics_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/integrated_dashboard.dart';

class HomeScreenMobile extends ConsumerStatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  ConsumerState<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends ConsumerState<HomeScreenMobile> {
  int _selectedIndex = 0;

  // 메인 탭 5개만 표시
  final List<Widget> _pages = [
    const IntegratedDashboard(),
    const TodoScreenWithCategories(),
    const TimerScreenGamified(),
    const _MoreScreen(), // 더보기 화면
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Todo',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// 더보기 화면
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('더보기'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuItem(
            context,
            icon: Icons.analytics,
            label: '학습 통계',
            color: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LearningStatisticsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.calendar_today,
            label: 'Schedule',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleScreenImproved()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.note,
            label: 'Notes',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotesScreenEnhanced()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.quiz,
            label: 'Flashcards',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlashcardsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.psychology,
            label: 'AI Assistant',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.person,
            label: 'Profile',
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreenSimple()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            label: 'Settings',
            color: Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}