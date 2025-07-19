import 'package:flutter/material.dart';

enum QuestType { daily, weekly, special, achievement }
enum QuestDifficulty { easy, medium, hard }
enum QuestStatus { available, accepted, completed, claimed }

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final int xpReward;
  final int coinReward;
  final String? specialReward; // 칭호 등
  final int targetValue;
  final int currentValue;
  final QuestStatus status;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? deadline;
  final IconData icon;
  final Color color;
  final String? trackingType; // 'study_time', 'todo_complete', 'pomodoro', etc.
  
  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.xpReward,
    this.coinReward = 0,
    this.specialReward,
    required this.targetValue,
    this.currentValue = 0,
    this.status = QuestStatus.available,
    this.acceptedAt,
    this.completedAt,
    this.deadline,
    required this.icon,
    required this.color,
    this.trackingType,
  });
  
  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    QuestDifficulty? difficulty,
    int? xpReward,
    int? coinReward,
    String? specialReward,
    int? targetValue,
    int? currentValue,
    QuestStatus? status,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? deadline,
    IconData? icon,
    Color? color,
    String? trackingType,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      specialReward: specialReward ?? this.specialReward,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      trackingType: trackingType ?? this.trackingType,
    );
  }
  
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  
  String get difficultyText {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return '쉬움';
      case QuestDifficulty.medium:
        return '보통';
      case QuestDifficulty.hard:
        return '어려움';
    }
  }
  
  Color get difficultyColor {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return Colors.green;
      case QuestDifficulty.medium:
        return Colors.orange;
      case QuestDifficulty.hard:
        return Colors.red;
    }
  }
  
  int get difficultyStars {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 1;
      case QuestDifficulty.medium:
        return 2;
      case QuestDifficulty.hard:
        return 3;
    }
  }
}