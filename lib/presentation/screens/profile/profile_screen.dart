import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';

// Profile Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileState {
  final UserProfile? profile;
  final StudyStats? stats;
  final List<Achievement> achievements;
  final bool isLoading;

  ProfileState({
    this.profile,
    this.stats,
    this.achievements = const [],
    this.isLoading = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    StudyStats? stats,
    List<Achievement>? achievements,
    bool? isLoading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState()) {
    loadProfile();
  }

  void loadProfile() {
    // Mock data
    state = state.copyWith(
      profile: UserProfile(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        learningType: 'PIVT',
        learningTypeName: 'The Strategic Scholar',
        level: 23,
        xp: 2350,
        xpToNextLevel: 150,
        totalStudyTime: 12450, // minutes
        currentStreak: 15,
        longestStreak: 23,
        coins: 456,
        premiumTier: 'FREE',
        profileImage: '🧑‍🎓',
        joinedDate: DateTime.now().subtract(const Duration(days: 45)),
      ),
      stats: StudyStats(
        todayMinutes: 125,
        weekMinutes: 580,
        monthMinutes: 2340,
        averageDaily: 78,
        mostProductiveHour: 14,
        favoriteSubject: 'Mathematics',
        completedTodos: 145,
        totalSessions: 234,
      ),
      achievements: [
        Achievement(
          id: 'first_steps',
          title: 'First Steps',
          description: 'Complete your first study session',
          icon: '👶',
          unlockedDate: DateTime.now().subtract(const Duration(days: 45)),
        ),
        Achievement(
          id: 'week_warrior',
          title: 'Week Warrior',
          description: '7 day study streak',
          icon: '🔥',
          unlockedDate: DateTime.now().subtract(const Duration(days: 20)),
        ),
        Achievement(
          id: 'century_club',
          title: 'Century Club',
          description: 'Study for 100 hours total',
          icon: '💯',
          unlockedDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    );
  }
}

// Data models
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String learningType;
  final String learningTypeName;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int totalStudyTime;
  final int currentStreak;
  final int longestStreak;
  final int coins;
  final String premiumTier;
  final String profileImage;
  final DateTime joinedDate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.learningType,
    required this.learningTypeName,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.totalStudyTime,
    required this.currentStreak,
    required this.longestStreak,
    required this.coins,
    required this.premiumTier,
    required this.profileImage,
    required this.joinedDate,
  });
}

class StudyStats {
  final int todayMinutes;
  final int weekMinutes;
  final int monthMinutes;
  final int averageDaily;
  final int mostProductiveHour;
  final String favoriteSubject;
  final int completedTodos;
  final int totalSessions;

  StudyStats({
    required this.todayMinutes,
    required this.weekMinutes,
    required this.monthMinutes,
    required this.averageDaily,
    required this.mostProductiveHour,
    required this.favoriteSubject,
    required this.completedTodos,
    required this.totalSessions,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedDate,
  });
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final theme = Theme.of(context);

    if (state.profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(profile: state.profile!),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Navigate to settings
                },
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Study Stats
                  _StudyStatsSection(stats: state.stats!),
                  
                  AppSpacing.verticalGapXL,
                  
                  // Weekly Activity Chart
                  _WeeklyActivityChart(),
                  
                  AppSpacing.verticalGapXL,
                  
                  // Achievements
                  _AchievementsSection(achievements: state.achievements),
                  
                  AppSpacing.verticalGapXL,
                  
                  // Actions
                  _ProfileActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final xpProgress = profile.xp / (profile.xp + profile.xpToNextLevel);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingXL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    profile.profileImage,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
              
              AppSpacing.verticalGapMD,
              
              // Name and learning type
              Text(
                profile.name,
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${profile.learningType} • ${profile.learningTypeName}',
                style: AppTypography.body.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              AppSpacing.verticalGapMD,
              
              // Level and XP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Text(
                      'Level ${profile.level}',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.xp} / ${profile.xp + profile.xpToNextLevel} XP',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              AppSpacing.verticalGapMD,
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _HeaderStat(
                    icon: Icons.local_fire_department,
                    value: '${profile.currentStreak}',
                    label: 'Streak',
                  ),
                  _HeaderStat(
                    icon: Icons.timer,
                    value: '${(profile.totalStudyTime / 60).round()}h',
                    label: 'Total',
                  ),
                  _HeaderStat(
                    icon: Icons.monetization_on,
                    value: '${profile.coins}',
                    label: 'Coins',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

class _StudyStatsSection extends StatelessWidget {
  final StudyStats stats;

  const _StudyStatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Statistics',
          style: AppTypography.titleLarge,
        ),
        
        AppSpacing.verticalGapMD,
        
        // Time stats
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Today',
                value: '${(stats.todayMinutes / 60).toStringAsFixed(1)}h',
                icon: Icons.today,
                color: Colors.blue,
              ),
            ),
            AppSpacing.horizontalGapMD,
            Expanded(
              child: _StatCard(
                title: 'This Week',
                value: '${(stats.weekMinutes / 60).toStringAsFixed(1)}h',
                icon: Icons.calendar_view_week,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        
        AppSpacing.verticalGapMD,
        
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Daily Average',
                value: '${stats.averageDaily}m',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            AppSpacing.horizontalGapMD,
            Expanded(
              child: _StatCard(
                title: 'Peak Hour',
                value: '${stats.mostProductiveHour}:00',
                icon: Icons.access_time,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        
        AppSpacing.verticalGapMD,
        
        // Additional stats
        Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _StatRow(
                label: 'Favorite Subject',
                value: stats.favoriteSubject,
                icon: Icons.favorite,
              ),
              const Divider(),
              _StatRow(
                label: 'Completed Quests',
                value: '${stats.completedTodos}',
                icon: Icons.check_circle,
              ),
              const Divider(),
              _StatRow(
                label: 'Study Sessions',
                value: '${stats.totalSessions}',
                icon: Icons.history,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          AppSpacing.verticalGapSM,
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTypography.caption,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0);
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          AppSpacing.horizontalGapMD,
          Text(label, style: AppTypography.body),
          const Spacer(),
          Text(
            value,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Activity',
          style: AppTypography.titleLarge,
        ),
        
        AppSpacing.verticalGapMD,
        
        Container(
          height: 200,
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 180,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      return Text(
                        days[value.toInt()],
                        style: AppTypography.caption,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}m',
                        style: AppTypography.caption,
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 60,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _makeGroupData(0, 120, theme.colorScheme.primary),
                _makeGroupData(1, 90, theme.colorScheme.primary),
                _makeGroupData(2, 150, theme.colorScheme.primary),
                _makeGroupData(3, 60, theme.colorScheme.primary),
                _makeGroupData(4, 180, theme.colorScheme.primary),
                _makeGroupData(5, 45, theme.colorScheme.primary),
                _makeGroupData(6, 75, theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
      ],
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsSection({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Achievements',
              style: AppTypography.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all achievements
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        AppSpacing.verticalGapMD,
        
        ...achievements.map((achievement) => _AchievementCard(
          achievement: achievement,
        )),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          
          AppSpacing.horizontalGapMD,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.titleMedium,
                ),
                Text(
                  achievement.description,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          
          Text(
            _formatDate(achievement.unlockedDate),
            style: AppTypography.caption,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.1, end: 0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    return '${(difference / 30).round()} months ago';
  }
}

class _ProfileActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          onPressed: () {
            // TODO: Share profile
          },
          variant: ButtonVariant.outline,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share),
              SizedBox(width: 8),
              Text('Share Profile'),
            ],
          ),
        ),
        
        AppSpacing.verticalGapMD,
        
        CustomButton(
          onPressed: () {
            // TODO: Export data
          },
          variant: ButtonVariant.outline,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download),
              SizedBox(width: 8),
              Text('Export Study Data'),
            ],
          ),
        ),
      ],
    );
  }
}