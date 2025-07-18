import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/todo_category_provider.dart';

class LearningStatisticsScreen extends ConsumerWidget {
  const LearningStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final todayCompleted = ref.watch(todayCompletedTodosProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 통계'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주요 통계 카드
            _buildMainStatsCard(context, stats, todayCompleted),
            const SizedBox(height: 20),
            
            // 주간 학습 그래프
            _buildWeeklyChart(context),
            const SizedBox(height: 20),
            
            // 과목별 통계
            _buildSubjectStats(context),
            const SizedBox(height: 20),
            
            // 성취도
            _buildAchievements(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainStatsCard(BuildContext context, UserStats stats, int todayCompleted) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 학습',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.timer,
                  label: '학습 시간',
                  value: '${stats.todayStudyMinutes ~/ 60}시간 ${stats.todayStudyMinutes % 60}분',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: '완료한 할 일',
                  value: '$todayCompleted개',
                  color: Colors.green,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: '연속 학습',
                  value: '${stats.currentStreak}일',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.access_time,
                  label: '총 학습 시간',
                  value: '${stats.totalStudyTime ~/ 60}시간',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeeklyChart(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주간 학습 현황',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDayBar('월', 0.7, theme.colorScheme.primary),
                  _buildDayBar('화', 0.9, theme.colorScheme.primary),
                  _buildDayBar('수', 0.5, theme.colorScheme.primary),
                  _buildDayBar('목', 0.8, theme.colorScheme.primary),
                  _buildDayBar('금', 0.6, theme.colorScheme.primary),
                  _buildDayBar('토', 0.4, theme.colorScheme.primary),
                  _buildDayBar('일', 0.3, theme.colorScheme.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDayBar(String day, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 150 * value,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: AppTypography.caption),
      ],
    );
  }
  
  Widget _buildSubjectStats(BuildContext context) {
    final subjects = [
      {'name': '수학', 'hours': 12, 'color': Colors.blue},
      {'name': '영어', 'hours': 8, 'color': Colors.purple},
      {'name': '과학', 'hours': 6, 'color': Colors.green},
      {'name': '국어', 'hours': 5, 'color': Colors.orange},
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '과목별 학습 시간',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 16),
            ...subjects.map((subject) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: subject['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subject['name'] as String,
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  Text(
                    '${subject['hours']}시간',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievements(BuildContext context) {
    final achievements = [
      {'icon': Icons.emoji_events, 'title': '일주일 연속 학습', 'desc': '7일 연속 학습 달성', 'earned': true},
      {'icon': Icons.timer, 'title': '집중왕', 'desc': '하루 5시간 이상 학습', 'earned': true},
      {'icon': Icons.task_alt, 'title': 'Todo 마스터', 'desc': '100개 할 일 완료', 'earned': false},
      {'icon': Icons.school, 'title': '우등생', 'desc': '모든 과목 90점 이상', 'earned': false},
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '성취 뱃지',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final earned = achievement['earned'] as bool;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: earned 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: earned 
                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                        : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        achievement['icon'] as IconData,
                        size: 32,
                        color: earned 
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement['title'] as String,
                        style: AppTypography.labelLarge.copyWith(
                          color: earned ? null : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}