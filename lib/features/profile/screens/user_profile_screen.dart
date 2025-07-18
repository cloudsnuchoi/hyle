import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/learning_type_provider.dart';
import '../../learning_type/screens/learning_type_test_screen.dart';
import '../../learning_type/screens/learning_type_result_detail_screen.dart';
import '../../settings/screens/theme_settings_screen.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatsProvider);
    final learningType = ref.watch(currentLearningTypeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 기능은 곧 추가될 예정입니다')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: AppSpacing.paddingLG,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        'U',
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalGapMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('학습자', style: AppTypography.titleLarge),
                          Text(
                            '레벨 ${userStats.level} • ${userStats.totalXP} XP',
                            style: AppTypography.body.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          AppSpacing.verticalGapSM,
                          LinearProgressIndicator(
                            value: userStats.getLevelProgress(),
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // Learning Type Card
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Theme.of(context).primaryColor,
                        ),
                        AppSpacing.horizontalGapMD,
                        Text('학습 유형', style: AppTypography.titleMedium),
                        const Spacer(),
                        if (learningType != null)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LearningTypeTestScreen(),
                                ),
                              );
                            },
                            child: const Text('재검사'),
                          ),
                      ],
                    ),
                    AppSpacing.verticalGapMD,
                    if (learningType == null)
                      Column(
                        children: [
                          const Text('아직 학습 유형 테스트를 하지 않았습니다.'),
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
                              child: const Text('테스트 시작'),
                            ),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearningTypeResultDetailScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: AppSpacing.paddingMD,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    learningType.getTitle(),
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                              AppSpacing.verticalGapSM,
                              Text(
                                learningType.getDescription(),
                                style: AppTypography.body,
                              ),
                              AppSpacing.verticalGapSM,
                              Text(
                                '자세히 보기',
                                style: AppTypography.caption.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // Statistics Section
            Text('학습 통계', style: AppTypography.titleLarge),
            AppSpacing.verticalGapMD,
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  context,
                  '총 학습 시간',
                  userStats.getFormattedStudyTime(),
                  Icons.access_time,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  '연속 학습',
                  '${userStats.currentStreak}일',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  '완료한 퀘스트',
                  '${userStats.completedQuests}개',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  '최고 기록',
                  '${userStats.longestStreak}일',
                  Icons.emoji_events,
                  Colors.purple,
                ),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Achievements Section
            Text('업적', style: AppTypography.titleLarge),
            AppSpacing.verticalGapMD,
            
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  children: [
                    _buildAchievement(
                      context,
                      '첫 걸음',
                      '첫 퀘스트 완료',
                      userStats.completedQuests > 0,
                    ),
                    _buildAchievement(
                      context,
                      '꾸준한 학습자',
                      '7일 연속 학습',
                      userStats.longestStreak >= 7,
                    ),
                    _buildAchievement(
                      context,
                      '레벨 5 달성',
                      '레벨 5에 도달',
                      userStats.level >= 5,
                    ),
                    _buildAchievement(
                      context,
                      '다재다능',
                      '3개 이상 과목 학습',
                      userStats.subjectStats.length >= 3,
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // Subject Distribution
            if (userStats.subjectStats.isNotEmpty) ...[
              Text('과목별 학습 시간', style: AppTypography.titleLarge),
              AppSpacing.verticalGapMD,
              Card(
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: Column(
                    children: userStats.subjectStats.entries.map((entry) {
                      final totalMinutes = userStats.subjectStats.values.fold(0, (sum, val) => sum + val);
                      final percentage = totalMinutes > 0 ? (entry.value / totalMinutes) : 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: AppTypography.body),
                                Text(
                                  '${entry.value}분',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                            AppSpacing.verticalGapSM,
                            LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getSubjectColor(entry.key),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            AppSpacing.verticalGapSM,
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(color: color),
            ),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievement(
    BuildContext context,
    String title,
    String description,
    bool isUnlocked,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isUnlocked ? Icons.star : Icons.star_border,
            color: isUnlocked ? Colors.amber : Colors.grey,
            size: 32,
          ),
          AppSpacing.horizontalGapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: isUnlocked ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: isUnlocked ? Colors.black54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math':
        return Colors.blue;
      case 'English':
        return Colors.purple;
      case 'Science':
        return Colors.green;
      case 'History':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}