import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
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
              _buildStatCard(
                context,
                'Study Streak',
                '7 Days',
                Icons.local_fire_department,
                Colors.orange,
              ),
              AppSpacing.verticalGapMD,
              _buildStatCard(
                context,
                'Total Study Time',
                '24h 35m',
                Icons.access_time,
                Colors.blue,
              ),
              AppSpacing.verticalGapMD,
              _buildStatCard(
                context,
                'Level',
                '12',
                Icons.star,
                Colors.purple,
              ),
              AppSpacing.verticalGapMD,
              _buildStatCard(
                context,
                'XP Points',
                '2,450',
                Icons.bolt,
                Colors.green,
              ),
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