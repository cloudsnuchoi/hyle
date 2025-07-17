import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';

// Study Groups Provider
final studyGroupsProvider = StateNotifierProvider<StudyGroupsNotifier, StudyGroupsState>((ref) {
  return StudyGroupsNotifier();
});

class StudyGroupsState {
  final List<StudyGroupData> myGroups;
  final List<StudyGroupData> recommendedGroups;
  final List<StudyGroupData> trendingGroups;
  final bool isLoading;

  StudyGroupsState({
    this.myGroups = const [],
    this.recommendedGroups = const [],
    this.trendingGroups = const [],
    this.isLoading = false,
  });

  StudyGroupsState copyWith({
    List<StudyGroupData>? myGroups,
    List<StudyGroupData>? recommendedGroups,
    List<StudyGroupData>? trendingGroups,
    bool? isLoading,
  }) {
    return StudyGroupsState(
      myGroups: myGroups ?? this.myGroups,
      recommendedGroups: recommendedGroups ?? this.recommendedGroups,
      trendingGroups: trendingGroups ?? this.trendingGroups,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StudyGroupsNotifier extends StateNotifier<StudyGroupsState> {
  StudyGroupsNotifier() : super(StudyGroupsState()) {
    loadGroups();
  }

  void loadGroups() {
    // Mock data
    state = state.copyWith(
      myGroups: [
        StudyGroupData(
          id: '1',
          name: 'Math Masters',
          description: 'Advanced mathematics study group',
          type: GroupType.studyGroup,
          memberCount: 12,
          maxMembers: 20,
          level: 15,
          totalXP: 5420,
          weeklyGoal: 600,
          weeklyProgress: 420,
          isPublic: true,
          tags: ['Math', 'Calculus', 'Advanced'],
          avatar: '🧮',
          activeNow: 3,
        ),
        StudyGroupData(
          id: '2',
          name: 'Code Warriors Guild',
          description: 'Programming and CS enthusiasts',
          type: GroupType.guild,
          memberCount: 89,
          maxMembers: 200,
          level: 28,
          totalXP: 24500,
          weeklyGoal: 2000,
          weeklyProgress: 1650,
          isPublic: false,
          tags: ['Programming', 'CS', 'Tech'],
          avatar: '💻',
          activeNow: 15,
        ),
      ],
      recommendedGroups: [
        StudyGroupData(
          id: '3',
          name: 'CSAT Prep Squad',
          description: 'Preparing for Korean SAT together',
          type: GroupType.examPrep,
          memberCount: 45,
          maxMembers: 50,
          level: 20,
          totalXP: 12000,
          weeklyGoal: 1000,
          weeklyProgress: 780,
          isPublic: true,
          tags: ['CSAT', 'Exam', 'Korean'],
          avatar: '📝',
          activeNow: 8,
        ),
      ],
      trendingGroups: [
        StudyGroupData(
          id: '4',
          name: 'Morning Study Club',
          description: 'Early birds who study before 8 AM',
          type: GroupType.studyGroup,
          memberCount: 18,
          maxMembers: 20,
          level: 10,
          totalXP: 3200,
          weeklyGoal: 400,
          weeklyProgress: 380,
          isPublic: true,
          tags: ['Morning', 'Productivity'],
          avatar: '🌅',
          activeNow: 5,
        ),
      ],
    );
  }

  void joinGroup(String groupId) {
    final group = [...state.recommendedGroups, ...state.trendingGroups]
        .firstWhere((g) => g.id == groupId);
    
    state = state.copyWith(
      myGroups: [...state.myGroups, group],
      recommendedGroups: state.recommendedGroups.where((g) => g.id != groupId).toList(),
      trendingGroups: state.trendingGroups.where((g) => g.id != groupId).toList(),
    );
  }
}

// Data models
enum GroupType { studyGroup, guild, schoolOfficial, examPrep }

class StudyGroupData {
  final String id;
  final String name;
  final String description;
  final GroupType type;
  final int memberCount;
  final int maxMembers;
  final int level;
  final int totalXP;
  final int weeklyGoal;
  final int weeklyProgress;
  final bool isPublic;
  final List<String> tags;
  final String avatar;
  final int activeNow;

  StudyGroupData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.memberCount,
    required this.maxMembers,
    required this.level,
    required this.totalXP,
    required this.weeklyGoal,
    required this.weeklyProgress,
    required this.isPublic,
    required this.tags,
    required this.avatar,
    required this.activeNow,
  });
}

class StudyGroupsScreen extends ConsumerWidget {
  const StudyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Show search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Create new group
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Groups
            if (state.myGroups.isNotEmpty) ...[
              _SectionHeader(
                title: 'My Groups',
                subtitle: 'Groups you\'re part of',
              ),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.myGroups.length,
                  itemBuilder: (context, index) {
                    final group = state.myGroups[index];
                    return _MyGroupCard(group: group);
                  },
                ),
              ),
              AppSpacing.verticalGapXL,
            ],

            // Recommended Groups
            if (state.recommendedGroups.isNotEmpty) ...[
              _SectionHeader(
                title: 'Recommended for You',
                subtitle: 'Based on your learning type and subjects',
              ),
              ...state.recommendedGroups.map((group) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _GroupListTile(group: group),
              )),
              AppSpacing.verticalGapXL,
            ],

            // Trending Groups
            if (state.trendingGroups.isNotEmpty) ...[
              _SectionHeader(
                title: 'Trending Groups',
                subtitle: 'Popular groups this week',
              ),
              ...state.trendingGroups.map((group) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _GroupListTile(group: group),
              )),
              AppSpacing.verticalGapXL,
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
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
    );
  }
}

class _MyGroupCard extends StatelessWidget {
  final StudyGroupData group;

  const _MyGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weeklyProgress = group.weeklyGoal > 0 
        ? group.weeklyProgress / group.weeklyGoal 
        : 0.0;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to group detail
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          group.avatar,
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
                            group.name,
                            style: AppTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(group.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getTypeLabel(group.type),
                                  style: AppTypography.caption.copyWith(
                                    color: _getTypeColor(group.type),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalGapSM,
                              Text(
                                'Lv.${group.level}',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                AppSpacing.verticalGapMD,
                
                // Active members
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${group.activeNow} studying now',
                        style: AppTypography.caption.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Weekly goal progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Goal',
                          style: AppTypography.caption,
                        ),
                        Text(
                          '${group.weeklyProgress}/${group.weeklyGoal} min',
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
                        value: weeklyProgress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          weeklyProgress >= 1.0 ? Colors.green : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                AppSpacing.verticalGapMD,
                
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Start group session
                        },
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Study'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Open chat
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * group.id.hashCode % 3))
      .slideX(begin: 0.1, end: 0);
  }

  Color _getTypeColor(GroupType type) {
    switch (type) {
      case GroupType.studyGroup:
        return Colors.blue;
      case GroupType.guild:
        return Colors.purple;
      case GroupType.schoolOfficial:
        return Colors.green;
      case GroupType.examPrep:
        return Colors.orange;
    }
  }

  String _getTypeLabel(GroupType type) {
    switch (type) {
      case GroupType.studyGroup:
        return 'Study Group';
      case GroupType.guild:
        return 'Guild';
      case GroupType.schoolOfficial:
        return 'School';
      case GroupType.examPrep:
        return 'Exam Prep';
    }
  }
}

class _GroupListTile extends ConsumerWidget {
  final StudyGroupData group;

  const _GroupListTile({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showGroupPreview(context, ref, group);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    group.avatar,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              
              AppSpacing.horizontalGapMD,
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: AppTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (group.isPublic)
                          const Icon(Icons.public, size: 16)
                        else
                          const Icon(Icons.lock, size: 16),
                      ],
                    ),
                    Text(
                      group.description,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalGapXS,
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount}/${group.maxMembers}',
                          style: AppTypography.caption,
                        ),
                        AppSpacing.horizontalGapMD,
                        Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lv.${group.level}',
                          style: AppTypography.caption.copyWith(
                            color: Colors.amber.shade700,
                          ),
                        ),
                        if (group.activeNow > 0) ...[
                          AppSpacing.horizontalGapMD,
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.activeNow} active',
                            style: AppTypography.caption.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Join button
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0);
  }

  void _showGroupPreview(BuildContext context, WidgetRef ref, StudyGroupData group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingXL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              group.avatar,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        AppSpacing.horizontalGapMD,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: AppTypography.titleLarge,
                              ),
                              Text(
                                _getTypeLabel(group.type),
                                style: AppTypography.caption.copyWith(
                                  color: _getTypeColor(group.type),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    AppSpacing.verticalGapXL,
                    
                    // Description
                    Text(
                      'About',
                      style: AppTypography.titleMedium,
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      group.description,
                      style: AppTypography.body,
                    ),
                    
                    AppSpacing.verticalGapXL,
                    
                    // Stats
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.people,
                          label: 'Members',
                          value: '${group.memberCount}/${group.maxMembers}',
                        ),
                        AppSpacing.horizontalGapMD,
                        _StatCard(
                          icon: Icons.emoji_events,
                          label: 'Level',
                          value: '${group.level}',
                        ),
                        AppSpacing.horizontalGapMD,
                        _StatCard(
                          icon: Icons.bolt,
                          label: 'Total XP',
                          value: '${group.totalXP}',
                        ),
                      ],
                    ),
                    
                    AppSpacing.verticalGapXL,
                    
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: group.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      )).toList(),
                    ),
                    
                    AppSpacing.verticalGapXL,
                    
                    // Join button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () {
                          ref.read(studyGroupsProvider.notifier).joinGroup(group.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Joined ${group.name}!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Join Group'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(GroupType type) {
    switch (type) {
      case GroupType.studyGroup:
        return Colors.blue;
      case GroupType.guild:
        return Colors.purple;
      case GroupType.schoolOfficial:
        return Colors.green;
      case GroupType.examPrep:
        return Colors.orange;
    }
  }

  String _getTypeLabel(GroupType type) {
    switch (type) {
      case GroupType.studyGroup:
        return 'Study Group';
      case GroupType.guild:
        return 'Guild';
      case GroupType.schoolOfficial:
        return 'School';
      case GroupType.examPrep:
        return 'Exam Prep';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.titleSmall,
            ),
            Text(
              label,
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}