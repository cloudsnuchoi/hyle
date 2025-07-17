import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ModelProvider.dart';

// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository {
  // Create new user
  Future<User> createUser({
    required String email,
    required String nickname,
  }) async {
    try {
      final user = User(
        email: email,
        nickname: nickname,
        level: 1,
        xp: 0,
        totalStudyTime: 0,
        currentStreak: 0,
        longestStreak: 0,
        coins: 0,
        badges: [],
        premiumTier: PremiumTier.FREE,
        skinInventory: ['default'],
        currentTheme: 'default',
      );

      final response = await Amplify.DataStore.save(user);
      
      return response;
    } catch (e) {
      safePrint('Error creating user: $e');
      rethrow;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      final users = await Amplify.DataStore.query(
        User.classType,
        where: User.ID.eq(authUser.userId),
      );
      
      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      safePrint('Error getting current user: $e');
      return null;
    }
  }

  // Update user profile
  Future<User> updateUser(User user) async {
    try {
      final updatedUser = await Amplify.DataStore.save(user);
      return updatedUser;
    } catch (e) {
      safePrint('Error updating user: $e');
      rethrow;
    }
  }

  // Update learning type
  Future<void> updateLearningType({
    required String userId,
    required LearningType learningType,
    required Map<String, dynamic> details,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      final updatedUser = user.copyWith(
        learningType: learningType,
        learningTypeDetails: details,
      );

      await Amplify.DataStore.save(updatedUser);
    } catch (e) {
      safePrint('Error updating learning type: $e');
      rethrow;
    }
  }

  // Add XP and handle level up
  Future<LevelUpResult> addXP({
    required String userId,
    required int xpAmount,
    required String source,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      final oldLevel = user.level;
      final newXP = user.xp + xpAmount;
      final newLevel = _calculateLevel(newXP);
      
      final updatedUser = user.copyWith(
        xp: newXP,
        level: newLevel,
      );

      await Amplify.DataStore.save(updatedUser);

      // Check for level up
      final leveledUp = newLevel > oldLevel;
      final rewards = leveledUp ? _getLevelUpRewards(newLevel) : null;

      return LevelUpResult(
        leveledUp: leveledUp,
        newLevel: newLevel,
        totalXP: newXP,
        rewards: rewards,
      );
    } catch (e) {
      safePrint('Error adding XP: $e');
      rethrow;
    }
  }

  // Update study time
  Future<void> updateStudyTime({
    required String userId,
    required Duration duration,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      final updatedUser = user.copyWith(
        totalStudyTime: user.totalStudyTime + duration.inMinutes,
      );

      await Amplify.DataStore.save(updatedUser);
    } catch (e) {
      safePrint('Error updating study time: $e');
      rethrow;
    }
  }

  // Update streak
  Future<StreakResult> updateStreak({
    required String userId,
    required DateTime lastStudyDate,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      
      int newStreak = user.currentStreak;
      int newLongestStreak = user.longestStreak;
      bool streakBroken = false;

      // Check if streak continues
      if (_isSameDay(lastStudyDate, yesterday)) {
        // Studied yesterday, increment streak
        newStreak++;
      } else if (_isSameDay(lastStudyDate, today)) {
        // Already studied today, no change
      } else {
        // Streak broken
        streakBroken = true;
        newStreak = 1;
      }

      // Update longest streak if needed
      if (newStreak > newLongestStreak) {
        newLongestStreak = newStreak;
      }

      final updatedUser = user.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
      );

      await Amplify.DataStore.save(updatedUser);

      return StreakResult(
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        streakBroken: streakBroken,
      );
    } catch (e) {
      safePrint('Error updating streak: $e');
      rethrow;
    }
  }

  // Add coins
  Future<void> addCoins({
    required String userId,
    required int amount,
    required String source,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      final updatedUser = user.copyWith(
        coins: user.coins + amount,
      );

      await Amplify.DataStore.save(updatedUser);
    } catch (e) {
      safePrint('Error adding coins: $e');
      rethrow;
    }
  }

  // Purchase skin
  Future<bool> purchaseSkin({
    required String userId,
    required String skinId,
    required int cost,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      // Check if user has enough coins
      if (user.coins < cost) {
        return false;
      }

      // Check if user already owns the skin
      if (user.skinInventory.contains(skinId)) {
        return false;
      }

      final updatedUser = user.copyWith(
        coins: user.coins - cost,
        skinInventory: [...user.skinInventory, skinId],
      );

      await Amplify.DataStore.save(updatedUser);
      return true;
    } catch (e) {
      safePrint('Error purchasing skin: $e');
      rethrow;
    }
  }

  // Add badge
  Future<void> addBadge({
    required String userId,
    required String badgeId,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      // Check if user already has the badge
      if (user.badges.contains(badgeId)) {
        return;
      }

      final updatedUser = user.copyWith(
        badges: [...user.badges, badgeId],
      );

      await Amplify.DataStore.save(updatedUser);
    } catch (e) {
      safePrint('Error adding badge: $e');
      rethrow;
    }
  }

  // Update premium tier
  Future<void> updatePremiumTier({
    required String userId,
    required PremiumTier tier,
  }) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      final updatedUser = user.copyWith(
        premiumTier: tier,
      );

      await Amplify.DataStore.save(updatedUser);
    } catch (e) {
      safePrint('Error updating premium tier: $e');
      rethrow;
    }
  }

  // Subscribe to user updates
  Stream<User> subscribeToUserUpdates(String userId) {
    return Amplify.DataStore.observeQuery(
      User.classType,
      where: User.ID.eq(userId),
    ).map((event) => event.items.first);
  }

  // Private helper methods
  Future<User?> _getUserById(String userId) async {
    try {
      final users = await Amplify.DataStore.query(
        User.classType,
        where: User.ID.eq(userId),
      );
      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      safePrint('Error getting user by ID: $e');
      return null;
    }
  }

  int _calculateLevel(int xp) {
    // Level calculation formula
    // Level 1: 0-99 XP
    // Level 2: 100-299 XP
    // Level 3: 300-599 XP
    // etc.
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    
    // For levels 6+, require 500 XP per level
    return 5 + ((xp - 1500) ~/ 500) + 1;
  }

  LevelUpReward? _getLevelUpRewards(int level) {
    final rewards = <int, LevelUpReward>{
      5: LevelUpReward(coins: 50, badge: 'novice_learner'),
      10: LevelUpReward(coins: 100, badge: 'dedicated_student', skin: 'ocean_timer'),
      15: LevelUpReward(coins: 150, badge: 'study_master'),
      20: LevelUpReward(coins: 200, badge: 'knowledge_seeker', skin: 'galaxy_theme'),
      25: LevelUpReward(coins: 300, badge: 'learning_legend'),
      30: LevelUpReward(coins: 400, badge: 'wisdom_warrior', skin: 'premium_pack'),
      40: LevelUpReward(coins: 500, badge: 'scholar'),
      50: LevelUpReward(coins: 1000, badge: 'grandmaster', skin: 'legendary_pack'),
    };

    return rewards[level];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

// Result classes
class LevelUpResult {
  final bool leveledUp;
  final int newLevel;
  final int totalXP;
  final LevelUpReward? rewards;

  LevelUpResult({
    required this.leveledUp,
    required this.newLevel,
    required this.totalXP,
    this.rewards,
  });
}

class LevelUpReward {
  final int coins;
  final String? badge;
  final String? skin;

  LevelUpReward({
    required this.coins,
    this.badge,
    this.skin,
  });
}

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final bool streakBroken;

  StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakBroken,
  });
}