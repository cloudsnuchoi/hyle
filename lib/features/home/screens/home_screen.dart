import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../todo/screens/todo_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardPage(),
    const TodoScreen(),
    const _ProfilePage(),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Quests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard Page
class _DashboardPage extends ConsumerWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatsProvider);
    final dailyMissions = ref.watch(dailyMissionsProvider);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Dashboard'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.paddingMD,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // User Level Card
              _buildLevelCard(context, userStats),
              AppSpacing.verticalGapMD,
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Study Streak',
                      '${userStats.currentStreak} Days',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total Time',
                      userStats.getFormattedStudyTime(),
                      Icons.access_time,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalGapMD,
              
              // Daily Missions
              _buildDailyMissionsCard(context, dailyMissions),
              AppSpacing.verticalGapMD,
              
              // Subject Stats
              _buildSubjectStatsCard(context, userStats.subjectStats),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            AppSpacing.horizontalGapMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.caption),
                  Text(value, style: AppTypography.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLevelCard(BuildContext context, UserStats userStats) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: Colors.purple, size: 32),
                ),
                AppSpacing.horizontalGapMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Level ${userStats.level}', style: AppTypography.titleLarge),
                      Text('${userStats.totalXP} XP', style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapMD,
            LinearProgressIndicator(
              value: userStats.getLevelProgress(),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            AppSpacing.verticalGapSM,
            Text(
              'Next Level: ${userStats.getXPForNextLevel() - userStats.totalXP} XP to go',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDailyMissionsCard(BuildContext context, List<Mission> missions) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Missions', style: AppTypography.titleMedium),
            AppSpacing.verticalGapMD,
            ...missions.map((mission) => _buildMissionItem(context, mission)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMissionItem(BuildContext context, Mission mission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            mission.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: mission.isCompleted ? Colors.green : Colors.grey,
          ),
          AppSpacing.horizontalGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.title, style: AppTypography.body),
                LinearProgressIndicator(
                  value: mission.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Text(
                  '${mission.currentValue}/${mission.targetValue}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Text(
            '+${mission.xpReward} XP',
            style: AppTypography.caption.copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubjectStatsCard(BuildContext context, Map<String, int> subjectStats) {
    if (subjectStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject Stats', style: AppTypography.titleMedium),
            AppSpacing.verticalGapMD,
            ...subjectStats.entries.map((entry) => _buildSubjectItem(context, entry.key, entry.value)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectItem(BuildContext context, String subject, int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    final timeText = hours > 0 ? '${hours}h ${remainingMinutes}m' : '${remainingMinutes}m';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getSubjectIcon(subject),
            color: _getSubjectColor(subject),
          ),
          AppSpacing.horizontalGapMD,
          Expanded(
            child: Text(subject, style: AppTypography.body),
          ),
          Text(timeText, style: AppTypography.caption),
        ],
      ),
    );
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math': return Colors.blue;
      case 'English': return Colors.purple;
      case 'Science': return Colors.green;
      case 'History': return Colors.orange;
      default: return Colors.grey;
    }
  }
  
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Math': return Icons.calculate;
      case 'English': return Icons.book;
      case 'Science': return Icons.science;
      case 'History': return Icons.history_edu;
      default: return Icons.assignment;
    }
  }
}

// Timer Page
class _TimerPage extends StatelessWidget {
  const _TimerPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          AppSpacing.verticalGapLG,
          Text('Timer Feature', style: AppTypography.titleLarge),
          AppSpacing.verticalGapMD,
          Text('Coming Soon!', style: AppTypography.body),
        ],
      ),
    );
  }
}

// Todo Page
class _TodoPage extends StatelessWidget {
  const _TodoPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          AppSpacing.verticalGapLG,
          Text('Todo Feature', style: AppTypography.titleLarge),
          AppSpacing.verticalGapMD,
          Text('Coming Soon!', style: AppTypography.body),
        ],
      ),
    );
  }
}

// Profile Page
class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          AppSpacing.verticalGapLG,
          Text('Profile', style: AppTypography.titleLarge),
          AppSpacing.verticalGapMD,
          Text('Coming Soon!', style: AppTypography.body),
        ],
      ),
    );
  }
}