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
import '../../timer/screens/timer_screen_enhanced.dart';
import '../../schedule/screens/schedule_screen.dart';
import '../../ai/screens/ai_assistant_screen.dart';
import '../../profile/screens/profile_screen_improved.dart';
import '../widgets/integrated_dashboard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const IntegratedDashboard(),
    const TodoScreenWithCategories(),
    const TimerScreenEnhanced(),
    const _MorePage(),
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
            label: '대시보드',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: '투두',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '타이머',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: '더보기',
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
    final learningType = ref.watch(currentLearningTypeProvider);
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
              // Learning Type Card (if not taken)
              if (learningType == null)
                _buildLearningTypePrompt(context, ref),
              if (learningType == null)
                AppSpacing.verticalGapMD,
              
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
      child: InkWell(
        onTap: () {
          // 통계 상세 페이지로 이동
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _StatDetailSheet(
              title: title,
              value: value,
              icon: icon,
              color: color,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
  
  Widget _buildLearningTypePrompt(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Theme.of(context).primaryColor),
                AppSpacing.horizontalGapSM,
                Expanded(
                  child: Text(
                    '당신의 학습 유형을 찾아보세요!',
                    style: AppTypography.titleMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapSM,
            Text(
              '8가지 질문으로 16가지 학습 유형 중 당신에게 맞는 학습법을 찾아드립니다.',
              style: AppTypography.body,
            ),
            AppSpacing.verticalGapMD,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LearningTypeTestScreen(),
                    ),
                  );
                },
                child: const Text('테스트 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 통계 상세 바텀시트
class _StatDetailSheet extends ConsumerWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatDetailSheet({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatsProvider);
    
    return Container(
      padding: AppSpacing.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들바
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.verticalGapLG,
          
          // 아이콘과 제목
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              AppSpacing.horizontalGapMD,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  Text(value, style: AppTypography.headlineMedium.copyWith(color: color)),
                ],
              ),
            ],
          ),
          
          AppSpacing.verticalGapXL,
          
          // 상세 정보
          if (title == 'Study Streak') ...[
            _buildDetailRow('현재 연속 학습', '${userStats.currentStreak}일'),
            _buildDetailRow('최고 기록', '${userStats.longestStreak}일'),
            _buildDetailRow('시작일', _formatDate(userStats.streakStartDate)),
            AppSpacing.verticalGapMD,
            LinearProgressIndicator(
              value: userStats.currentStreak / 30, // 30일 목표
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            AppSpacing.verticalGapSM,
            Text('30일 연속 학습 도전 중!', style: AppTypography.caption),
          ] else if (title == 'Total Time') ...[
            _buildDetailRow('오늘 학습 시간', '${userStats.todayStudyMinutes}분'),
            _buildDetailRow('이번 주 학습 시간', '${userStats.weeklyStudyMinutes}분'),
            _buildDetailRow('총 학습 시간', userStats.getFormattedStudyTime()),
            AppSpacing.verticalGapMD,
            // 과목별 학습 시간
            if (userStats.subjectStats.isNotEmpty) ...[
              Text('과목별 학습 시간', style: AppTypography.titleSmall),
              AppSpacing.verticalGapMD,
              ...userStats.subjectStats.entries.map((entry) {
                final totalMinutes = userStats.subjectStats.values.fold(0, (sum, val) => sum + val);
                final percentage = totalMinutes > 0 ? (entry.value / totalMinutes) : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(entry.key, style: AppTypography.body),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(_getSubjectColor(entry.key)),
                        ),
                      ),
                      AppSpacing.horizontalGapMD,
                      Text('${entry.value}분', style: AppTypography.caption),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
          
          AppSpacing.verticalGapXL,
          
          // 닫기 버튼
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(value, style: AppTypography.titleSmall),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
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
}

// More Page
class _MorePage extends StatelessWidget {
  const _MorePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('더보기'),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSpacing.paddingMD,
        children: [
          _buildMenuItem(
            context,
            icon: Icons.calendar_today,
            title: '스케줄',
            subtitle: '일정 관리',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.note,
            title: '노트',
            subtitle: '학습 노트 작성',
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
            title: '플래시카드',
            subtitle: '암기 학습',
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
            title: 'AI 어시스턴트',
            subtitle: 'AI 학습 도우미',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
              );
            },
          ),
          const Divider(height: 32),
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: '프로필',
            subtitle: '내 정보 관리',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreenImproved()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.school,
            title: '학습 유형 테스트',
            subtitle: '나의 학습 스타일 찾기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LearningTypeTestScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: '설정',
            subtitle: '앱 설정',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: AppTypography.titleSmall),
        subtitle: Text(subtitle, style: AppTypography.caption),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

