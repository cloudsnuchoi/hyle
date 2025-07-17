import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ModelProvider.dart';

// Mission Repository Provider
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository();
});

class MissionRepository {
  // Get all active missions
  Future<List<Mission>> getActiveMissions() async {
    try {
      final missions = await Amplify.DataStore.query(
        Mission.classType,
        where: Mission.IS_ACTIVE.eq(true),
        sortBy: [Mission.ORDER.ascending()],
      );

      return missions;
    } catch (e) {
      safePrint('Error getting active missions: $e');
      return [];
    }
  }

  // Get user's mission progress
  Future<List<MissionProgress>> getUserMissionProgress({
    required String userId,
    MissionFrequency? frequency,
    bool? completed,
  }) async {
    try {
      var query = MissionProgress.USER_ID.eq(userId);
      
      if (completed != null) {
        query = query.and(MissionProgress.COMPLETED.eq(completed));
      }

      final progressList = await Amplify.DataStore.query(
        MissionProgress.classType,
        where: query,
      );

      // Filter by frequency if specified
      if (frequency != null) {
        final missionIds = progressList.map((p) => p.missionID).toSet();
        final missions = await Amplify.DataStore.query(
          Mission.classType,
          where: Mission.ID.oneOf(missionIds.toList())
              .and(Mission.FREQUENCY.eq(frequency)),
        );
        
        final frequencyMissionIds = missions.map((m) => m.id).toSet();
        return progressList.where((p) => 
          frequencyMissionIds.contains(p.missionID)
        ).toList();
      }

      return progressList;
    } catch (e) {
      safePrint('Error getting user mission progress: $e');
      return [];
    }
  }

  // Initialize daily missions for user
  Future<void> initializeDailyMissions(String userId) async {
    try {
      // Get all daily missions
      final dailyMissions = await Amplify.DataStore.query(
        Mission.classType,
        where: Mission.FREQUENCY.eq(MissionFrequency.DAILY)
            .and(Mission.IS_ACTIVE.eq(true)),
      );

      // Check existing progress for today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      for (final mission in dailyMissions) {
        final existingProgress = await Amplify.DataStore.query(
          MissionProgress.classType,
          where: MissionProgress.USER_ID.eq(userId)
              .and(MissionProgress.MISSION_ID.eq(mission.id))
              .and(MissionProgress.CREATED_AT.ge(
                TemporalDateTime(startOfDay),
              )),
        );

        // Create new progress if not exists
        if (existingProgress.isEmpty) {
          final requirement = mission.requirement as Map<String, dynamic>?;
          final target = requirement?['target'] ?? 1;
          
          final progress = MissionProgress(
            progress: 0,
            target: target,
            completed: false,
            userID: userId,
            missionID: mission.id,
          );

          await Amplify.DataStore.save(progress);
        }
      }
    } catch (e) {
      safePrint('Error initializing daily missions: $e');
    }
  }

  // Update mission progress
  Future<MissionUpdateResult> updateMissionProgress({
    required String userId,
    required String missionType,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Find relevant missions
      final missions = await Amplify.DataStore.query(
        Mission.classType,
        where: Mission.IS_ACTIVE.eq(true),
      );

      final results = <MissionUpdateResult>[];

      for (final mission in missions) {
        final requirement = mission.requirement as Map<String, dynamic>?;
        if (requirement == null) continue;

        // Check if this mission is relevant to the update
        if (!_isMissionRelevant(mission, missionType, requirement)) {
          continue;
        }

        // Get user's progress for this mission
        final progressList = await Amplify.DataStore.query(
          MissionProgress.classType,
          where: MissionProgress.USER_ID.eq(userId)
              .and(MissionProgress.MISSION_ID.eq(mission.id))
              .and(MissionProgress.COMPLETED.eq(false)),
        );

        if (progressList.isEmpty) continue;
        
        final progress = progressList.first;

        // Calculate new progress
        final increment = _calculateProgressIncrement(
          mission: mission,
          requirement: requirement,
          data: data,
        );

        if (increment <= 0) continue;

        final newProgress = progress.progress + increment;
        final isCompleted = newProgress >= progress.target;

        // Update progress
        final updatedProgress = progress.copyWith(
          progress: newProgress.clamp(0, progress.target),
          completed: isCompleted,
          completedAt: isCompleted ? TemporalDateTime.now() : null,
        );

        await Amplify.DataStore.save(updatedProgress);

        // Prepare rewards if completed
        MissionReward? reward;
        if (isCompleted) {
          reward = MissionReward(
            xp: mission.xpReward,
            coins: mission.coinReward,
            badge: mission.badgeReward,
          );
        }

        results.add(MissionUpdateResult(
          mission: mission,
          progress: updatedProgress,
          completed: isCompleted,
          reward: reward,
        ));
      }

      // Return the most significant update
      if (results.isEmpty) {
        return MissionUpdateResult.noUpdate();
      }

      // Prioritize completed missions
      final completed = results.where((r) => r.completed).toList();
      if (completed.isNotEmpty) {
        return completed.first;
      }

      return results.first;
    } catch (e) {
      safePrint('Error updating mission progress: $e');
      return MissionUpdateResult.noUpdate();
    }
  }

  // Claim mission reward
  Future<bool> claimMissionReward({
    required String progressId,
  }) async {
    try {
      final progressList = await Amplify.DataStore.query(
        MissionProgress.classType,
        where: MissionProgress.ID.eq(progressId),
      );

      if (progressList.isEmpty) return false;
      
      final progress = progressList.first;
      
      if (!progress.completed || progress.claimedAt != null) {
        return false;
      }

      final updatedProgress = progress.copyWith(
        claimedAt: TemporalDateTime.now(),
      );

      await Amplify.DataStore.save(updatedProgress);
      return true;
    } catch (e) {
      safePrint('Error claiming mission reward: $e');
      return false;
    }
  }

  // Get weekly missions summary
  Future<WeeklyMissionsSummary> getWeeklyMissionsSummary({
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Get all mission progress for the week
      final allProgress = await Amplify.DataStore.query(
        MissionProgress.classType,
        where: MissionProgress.USER_ID.eq(userId)
            .and(MissionProgress.CREATED_AT.between(
              TemporalDateTime(weekStart),
              TemporalDateTime(weekEnd),
            )),
      );

      // Get mission details
      final missionIds = allProgress.map((p) => p.missionID).toSet();
      final missions = await Amplify.DataStore.query(
        Mission.classType,
        where: Mission.ID.oneOf(missionIds.toList()),
      );

      final missionMap = {for (var m in missions) m.id: m};

      // Calculate statistics
      int totalCompleted = 0;
      int dailyCompleted = 0;
      int weeklyCompleted = 0;
      int totalXPEarned = 0;
      int totalCoinsEarned = 0;
      List<String> badgesEarned = [];

      for (final progress in allProgress) {
        if (!progress.completed) continue;
        
        final mission = missionMap[progress.missionID];
        if (mission == null) continue;

        totalCompleted++;
        
        if (mission.frequency == MissionFrequency.DAILY) {
          dailyCompleted++;
        } else if (mission.frequency == MissionFrequency.WEEKLY) {
          weeklyCompleted++;
        }

        if (progress.claimedAt != null) {
          totalXPEarned += mission.xpReward;
          totalCoinsEarned += mission.coinReward;
          if (mission.badgeReward != null) {
            badgesEarned.add(mission.badgeReward!);
          }
        }
      }

      // Calculate daily completion rate
      final daysInWeek = now.difference(weekStart).inDays + 1;
      final expectedDailyMissions = await Amplify.DataStore.query(
        Mission.classType,
        where: Mission.FREQUENCY.eq(MissionFrequency.DAILY)
            .and(Mission.IS_ACTIVE.eq(true)),
      );
      
      final dailyCompletionRate = expectedDailyMissions.isNotEmpty
          ? (dailyCompleted / (expectedDailyMissions.length * daysInWeek)) * 100
          : 0.0;

      return WeeklyMissionsSummary(
        totalCompleted: totalCompleted,
        dailyCompleted: dailyCompleted,
        weeklyCompleted: weeklyCompleted,
        dailyCompletionRate: dailyCompletionRate,
        totalXPEarned: totalXPEarned,
        totalCoinsEarned: totalCoinsEarned,
        badgesEarned: badgesEarned,
      );
    } catch (e) {
      safePrint('Error getting weekly missions summary: $e');
      return WeeklyMissionsSummary.empty();
    }
  }

  // Subscribe to mission updates
  Stream<List<MissionProgress>> subscribeMissionProgress(String userId) {
    return Amplify.DataStore.observeQuery(
      MissionProgress.classType,
      where: MissionProgress.USER_ID.eq(userId),
      sortBy: [MissionProgress.CREATED_AT.descending()],
    ).map((event) => event.items);
  }

  // Helper methods
  bool _isMissionRelevant(
    Mission mission,
    String updateType,
    Map<String, dynamic> requirement,
  ) {
    final missionType = requirement['type'] as String?;
    return missionType == updateType;
  }

  int _calculateProgressIncrement(
    {
      required Mission mission,
      required Map<String, dynamic> requirement,
      required Map<String, dynamic> data,
    }
  ) {
    final missionType = requirement['type'] as String?;
    
    switch (missionType) {
      case 'study_time':
        final minutes = data['minutes'] as int? ?? 0;
        return minutes;
        
      case 'complete_todos':
        final completed = data['completed'] as bool? ?? false;
        return completed ? 1 : 0;
        
      case 'study_sessions':
        final sessionCompleted = data['sessionCompleted'] as bool? ?? false;
        return sessionCompleted ? 1 : 0;
        
      case 'streak_days':
        final currentStreak = data['currentStreak'] as int? ?? 0;
        final requiredStreak = requirement['streakDays'] as int? ?? 1;
        return currentStreak >= requiredStreak ? 1 : 0;
        
      case 'xp_earned':
        final xp = data['xp'] as int? ?? 0;
        return xp;
        
      case 'subject_study':
        final subject = data['subject'] as String?;
        final requiredSubject = requirement['subject'] as String?;
        final minutes = data['minutes'] as int? ?? 0;
        return subject == requiredSubject ? minutes : 0;
        
      case 'morning_study':
        final hour = data['hour'] as int? ?? 0;
        final minutes = data['minutes'] as int? ?? 0;
        return (hour >= 5 && hour < 9) ? minutes : 0;
        
      case 'group_study':
        final isGroupStudy = data['isGroupStudy'] as bool? ?? false;
        return isGroupStudy ? 1 : 0;
        
      default:
        return 0;
    }
  }
}

// Result classes
class MissionUpdateResult {
  final Mission? mission;
  final MissionProgress? progress;
  final bool completed;
  final MissionReward? reward;

  MissionUpdateResult({
    this.mission,
    this.progress,
    this.completed = false,
    this.reward,
  });

  factory MissionUpdateResult.noUpdate() {
    return MissionUpdateResult();
  }
}

class MissionReward {
  final int xp;
  final int coins;
  final String? badge;

  MissionReward({
    required this.xp,
    required this.coins,
    this.badge,
  });
}

class WeeklyMissionsSummary {
  final int totalCompleted;
  final int dailyCompleted;
  final int weeklyCompleted;
  final double dailyCompletionRate;
  final int totalXPEarned;
  final int totalCoinsEarned;
  final List<String> badgesEarned;

  WeeklyMissionsSummary({
    required this.totalCompleted,
    required this.dailyCompleted,
    required this.weeklyCompleted,
    required this.dailyCompletionRate,
    required this.totalXPEarned,
    required this.totalCoinsEarned,
    required this.badgesEarned,
  });

  factory WeeklyMissionsSummary.empty() {
    return WeeklyMissionsSummary(
      totalCompleted: 0,
      dailyCompleted: 0,
      weeklyCompleted: 0,
      dailyCompletionRate: 0.0,
      totalXPEarned: 0,
      totalCoinsEarned: 0,
      badgesEarned: [],
    );
  }
}