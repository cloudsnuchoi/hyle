import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';

// Missions Provider
final missionsProvider = StateNotifierProvider<MissionsNotifier, MissionsState>((ref) {
  return MissionsNotifier();
});

class MissionsState {
  final List<MissionData> dailyMissions;
  final List<MissionData> weeklyMissions;
  final List<MissionData> specialMissions;
  final bool isLoading;
  final DateTime? lastRefresh;

  MissionsState({
    this.dailyMissions = const [],
    this.weeklyMissions = const [],
    this.specialMissions = const [],
    this.isLoading = false,
    this.lastRefresh,
  });

  MissionsState copyWith({
    List<MissionData>? dailyMissions,
    List<MissionData>? weeklyMissions,
    List<MissionData>? specialMissions,
    bool? isLoading,
    DateTime? lastRefresh,
  }) {
    return MissionsState(
      dailyMissions: dailyMissions ?? this.dailyMissions,
      weeklyMissions: weeklyMissions ?? this.weeklyMissions,
      specialMissions: specialMissions ?? this.specialMissions,
      isLoading: isLoading ?? this.isLoading,
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }
}

class MissionsNotifier extends StateNotifier<MissionsState> {
  MissionsNotifier() : super(MissionsState()) {
    loadMissions();
  }

  void loadMissions() {
    // Mock data - replace with actual API call
    state = state.copyWith(
      dailyMissions: [
        MissionData(
          id: 'd1',
          title: 'Morning Bird',
          description: 'Start studying before 9 AM',
          type: MissionType.daily,
          progress: 0,
          target: 1,
          xpReward: 20,
          coinReward: 5,
          icon: '🌅',
          isCompleted: false,
        ),
        MissionData(
          id: 'd2',
          title: 'Study Streak',
          description: 'Complete 60 minutes of focused study',
          type: MissionType.daily,
          progress: 35,
          target: 60,
          xpReward: 50,
          coinReward: 10,
          icon: '⏱️',
          isCompleted: false,
        ),
        MissionData(
          id: 'd3',
          title: 'Quest Master',
          description: 'Complete 3 study quests',
          type: MissionType.daily,
          progress: 1,
          target: 3,
          xpReward: 30,
          coinReward: 8,
          icon: '✅',
          isCompleted: false,
        ),
      ],
      weeklyMissions: [
        MissionData(
          id: 'w1',
          title: 'Consistency King',
          description: 'Study for 5 days this week',
          type: MissionType.weekly,
          progress: 3,
          target: 5,
          xpReward: 200,
          coinReward: 50,
          icon: '👑',
          isCompleted: false,
        ),
        MissionData(
          id: 'w2',
          title: 'Subject Master',
          description: 'Study 3 different subjects',
          type: MissionType.weekly,
          progress: 2,
          target: 3,
          xpReward: 150,
          coinReward: 30,
          icon: '📚',
          isCompleted: false,
        ),
      ],
      specialMissions: [
        MissionData(
          id: 's1',
          title: 'Exam Warrior',
          description: 'Study 300 minutes this week for upcoming exams',
          type: MissionType.special,
          progress: 180,
          target: 300,
          xpReward: 500,
          coinReward: 100,
          icon: '⚔️',
          isCompleted: false,
          badge: 'exam_warrior',
        ),
      ],
      lastRefresh: DateTime.now(),
    );
  }

  void updateProgress(String missionId, int newProgress) {
    state = state.copyWith(
      dailyMissions: state.dailyMissions.map((m) {
        if (m.id == missionId) {
          final isCompleted = newProgress >= m.target;
          return m.copyWith(
            progress: newProgress.clamp(0, m.target),
            isCompleted: isCompleted,
          );
        }
        return m;
      }).toList(),
      weeklyMissions: state.weeklyMissions.map((m) {
        if (m.id == missionId) {
          final isCompleted = newProgress >= m.target;
          return m.copyWith(
            progress: newProgress.clamp(0, m.target),
            isCompleted: isCompleted,
          );
        }
        return m;
      }).toList(),
    );
  }

  void claimReward(String missionId) {
    state = state.copyWith(
      dailyMissions: state.dailyMissions.map((m) {
        if (m.id == missionId && m.isCompleted && !m.isClaimed) {
          return m.copyWith(isClaimed: true);
        }
        return m;
      }).toList(),
      weeklyMissions: state.weeklyMissions.map((m) {
        if (m.id == missionId && m.isCompleted && !m.isClaimed) {
          return m.copyWith(isClaimed: true);
        }
        return m;
      }).toList(),
    );
  }
}

// Data models
enum MissionType { daily, weekly, special }

class MissionData {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int progress;
  final int target;
  final int xpReward;
  final int coinReward;
  final String icon;
  final bool isCompleted;
  final bool isClaimed;
  final String? badge;

  MissionData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.progress,
    required this.target,
    required this.xpReward,
    required this.coinReward,
    required this.icon,
    required this.isCompleted,
    this.isClaimed = false,
    this.badge,
  });

  MissionData copyWith({
    int? progress,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return MissionData(
      id: id,
      title: title,
      description: description,
      type: type,
      progress: progress ?? this.progress,
      target: target,
      xpReward: xpReward,
      coinReward: coinReward,
      icon: icon,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      badge: badge,
    );
  }
}

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(missionsProvider.notifier).loadMissions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(missionsProvider.notifier).loadMissions();
        },
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header stats
              _MissionStats(state: state),
              
              AppSpacing.verticalGapXL,
              
              // Daily missions
              _MissionSection(
                title: 'Daily Missions',
                subtitle: 'Resets at 4:00 AM',
                missions: state.dailyMissions,
                color: Colors.blue,
              ),
              
              AppSpacing.verticalGapXL,
              
              // Weekly missions
              _MissionSection(
                title: 'Weekly Missions',
                subtitle: 'Resets every Monday',
                missions: state.weeklyMissions,
                color: Colors.purple,
              ),
              
              // Special missions
              if (state.specialMissions.isNotEmpty) ...[
                AppSpacing.verticalGapXL,
                _MissionSection(
                  title: 'Special Events',
                  subtitle: 'Limited time only!',
                  missions: state.specialMissions,
                  color: Colors.orange,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionStats extends StatelessWidget {
  final MissionsState state;

  const _MissionStats({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate totals
    final allMissions = [
      ...state.dailyMissions,
      ...state.weeklyMissions,
      ...state.specialMissions,
    ];
    final completedCount = allMissions.where((m) => m.isCompleted).length;
    final totalXP = allMissions
        .where((m) => m.isCompleted && m.isClaimed)
        .fold(0, (sum, m) => sum + m.xpReward);
    final totalCoins = allMissions
        .where((m) => m.isCompleted && m.isClaimed)
        .fold(0, (sum, m) => sum + m.coinReward);

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.task_alt,
            label: 'Completed',
            value: '$completedCount/${allMissions.length}',
            color: Colors.green,
          ),
          _StatItem(
            icon: Icons.bolt,
            label: 'XP Earned',
            value: '$totalXP',
            color: Colors.amber,
          ),
          _StatItem(
            icon: Icons.monetization_on,
            label: 'Coins',
            value: '$totalCoins',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        AppSpacing.verticalGapXS,
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _MissionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<MissionData> missions;
  final Color color;

  const _MissionSection({
    required this.title,
    required this.subtitle,
    required this.missions,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge,
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${missions.where((m) => m.isCompleted).length}/${missions.length}',
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        AppSpacing.verticalGapMD,
        
        ...missions.asMap().entries.map((entry) => _MissionCard(
          mission: entry.value,
          index: entry.key,
          color: color,
        )),
      ],
    );
  }
}

class _MissionCard extends ConsumerWidget {
  final MissionData mission;
  final int index;
  final Color color;

  const _MissionCard({
    required this.mission,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = mission.target > 0 ? mission.progress / mission.target : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: mission.isCompleted && !mission.isClaimed
            ? () => _showClaimDialog(context, ref)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: mission.isCompleted && !mission.isClaimed
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        mission.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  
                  AppSpacing.horizontalGapMD,
                  
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.title,
                          style: AppTypography.titleMedium.copyWith(
                            decoration: mission.isClaimed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          mission.description,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  
                  // Rewards
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '+${mission.xpReward}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '+${mission.coinReward}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              AppSpacing.verticalGapMD,
              
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: AppTypography.caption,
                      ),
                      Text(
                        '${mission.progress}/${mission.target}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        mission.isCompleted ? Colors.green : color,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Status
              if (mission.isCompleted) ...[
                AppSpacing.verticalGapMD,
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: mission.isClaimed
                          ? Colors.grey.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mission.isClaimed ? 'Claimed ✓' : 'Tap to Claim!',
                      style: AppTypography.button.copyWith(
                        color: mission.isClaimed ? Colors.grey : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index))
      .slideX(begin: 0.2, end: 0);
  }

  void _showClaimDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: AppSpacing.paddingXL,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉',
                style: const TextStyle(fontSize: 64),
              ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
              
              AppSpacing.verticalGapMD,
              
              Text(
                'Mission Complete!',
                style: AppTypography.titleLarge,
              ),
              
              AppSpacing.verticalGapSM,
              
              Text(
                mission.title,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              
              AppSpacing.verticalGapMD,
              
              // Rewards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          '+${mission.xpReward} XP',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  AppSpacing.horizontalGapMD,
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          '+${mission.coinReward}',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (mission.badge != null) ...[
                AppSpacing.verticalGapMD,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.military_tech, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'New Badge Unlocked!',
                        style: AppTypography.body.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              AppSpacing.verticalGapXL,
              
              CustomButton(
                text: 'Claim Rewards',
                onPressed: () {
                  ref.read(missionsProvider.notifier).claimReward(mission.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}