import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/learning_type_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../learning_type/screens/learning_type_test_screen.dart';
import '../../learning_type/screens/learning_type_result_detail_screen.dart';

class UserProfileScreenEnhanced extends ConsumerWidget {
  const UserProfileScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatsProvider);
    final learningType = ref.watch(currentLearningTypeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentPreset = ref.watch(themePresetProvider);
    final availablePresets = ref.watch(availablePresetsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
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
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalGapMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('학습자', style: AppTypography.titleLarge),
                          AppSpacing.verticalGapSM,
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              AppSpacing.horizontalGapSM,
                              Text(
                                'Level ${userStats.level}',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppSpacing.horizontalGapMD,
                              Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                              AppSpacing.horizontalGapSM,
                              Text(
                                '${userStats.currentStreak} 일',
                                style: AppTypography.body,
                              ),
                            ],
                          ),
                          AppSpacing.verticalGapSM,
                          LinearProgressIndicator(
                            value: userStats.getLevelProgress(),
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${userStats.totalXP} / ${userStats.getXPForNextLevel()} XP',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // Theme Settings Section
            Text('테마 설정', style: AppTypography.titleLarge),
            AppSpacing.verticalGapMD,
            
            // Dark Mode Toggle
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('다크 모드'),
                      subtitle: Text(
                        currentThemeMode == ThemeMode.dark ? '켜짐' :
                        currentThemeMode == ThemeMode.light ? '꺼짐' : '시스템 설정',
                      ),
                      trailing: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.settings_brightness),
                          ),
                        ],
                        selected: {currentThemeMode},
                        onSelectionChanged: (Set<ThemeMode> modes) {
                          ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapMD,
            
            // Theme Presets
            Text('테마 스타일', style: AppTypography.titleMedium),
            AppSpacing.verticalGapMD,
            
            ...availablePresets.map((preset) {
              final isSelected = currentPreset.name == preset.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    ref.read(themePresetProvider.notifier).setThemePreset(preset);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: AppSpacing.paddingMD,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                          ? preset.primary 
                          : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected 
                        ? preset.primary.withOpacity(0.1)
                        : null,
                    ),
                    child: Row(
                      children: [
                        // Color Preview
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [
                                preset.primary,
                                preset.secondary,
                                preset.accent,
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.horizontalGapMD,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    preset.name,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: isSelected ? preset.primary : null,
                                      fontWeight: isSelected ? FontWeight.bold : null,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    AppSpacing.horizontalGapSM,
                                    Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: preset.primary,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getPresetDescription(preset),
                                style: AppTypography.caption,
                              ),
                              if (preset.fontFamily != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '폰트: ${preset.fontFamily}',
                                  style: AppTypography.caption.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            
            AppSpacing.verticalGapLG,
            
            // Learning Type Section
            Text('학습 유형', style: AppTypography.titleLarge),
            AppSpacing.verticalGapMD,
            
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  children: [
                    if (learningType == null)
                      ListTile(
                        leading: Icon(
                          Icons.psychology_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: const Text('학습 유형 테스트'),
                        subtitle: const Text('나에게 맞는 학습법 찾기'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearningTypeTestScreen(),
                            ),
                          );
                        },
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
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: AppSpacing.paddingMD,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.psychology,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  AppSpacing.horizontalGapMD,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          learningType.name,
                                          style: AppTypography.titleMedium,
                                        ),
                                        Text(
                                          learningType.id,
                                          style: AppTypography.caption,
                                        ),
                                      ],
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
                  '완료한 퀘스트',
                  '${userStats.completedQuests}개',
                  Icons.task_alt,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  '최고 연속',
                  '${userStats.longestStreak}일',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  '총 XP',
                  '${userStats.totalXP}',
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
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
            Text(value, style: AppTypography.titleMedium),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}