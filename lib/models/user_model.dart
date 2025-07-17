import 'dart:math' as math;
import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String learningType;
  final Map<String, dynamic> learningTypeDetails;
  final int level;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final Map<String, int> subjectXP;
  final List<String> achievements;
  final Map<String, String> componentSkins;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  User({
    String? id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.learningType = '',
    Map<String, dynamic>? learningTypeDetails,
    this.level = 1,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    Map<String, int>? subjectXP,
    List<String>? achievements,
    Map<String, String>? componentSkins,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       learningTypeDetails = learningTypeDetails ?? {},
       subjectXP = subjectXP ?? {},
       achievements = achievements ?? [],
       componentSkins = componentSkins ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? learningType,
    Map<String, dynamic>? learningTypeDetails,
    int? level,
    int? totalXP,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    Map<String, int>? subjectXP,
    List<String>? achievements,
    Map<String, String>? componentSkins,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      learningType: learningType ?? this.learningType,
      learningTypeDetails: learningTypeDetails ?? this.learningTypeDetails,
      level: level ?? this.level,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      subjectXP: subjectXP ?? this.subjectXP,
      achievements: achievements ?? this.achievements,
      componentSkins: componentSkins ?? this.componentSkins,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'profileImageUrl': profileImageUrl,
    'learningType': learningType,
    'learningTypeDetails': learningTypeDetails,
    'level': level,
    'totalXP': totalXP,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastStudyDate': lastStudyDate?.toIso8601String(),
    'subjectXP': subjectXP,
    'achievements': achievements,
    'componentSkins': componentSkins,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    profileImageUrl: json['profileImageUrl'],
    learningType: json['learningType'] ?? '',
    learningTypeDetails: json['learningTypeDetails'] ?? {},
    level: json['level'] ?? 1,
    totalXP: json['totalXP'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    lastStudyDate: json['lastStudyDate'] != null 
      ? DateTime.parse(json['lastStudyDate']) 
      : null,
    subjectXP: Map<String, int>.from(json['subjectXP'] ?? {}),
    achievements: List<String>.from(json['achievements'] ?? []),
    componentSkins: Map<String, String>.from(json['componentSkins'] ?? {}),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
  
  // Calculate level from XP
  int calculateLevel() {
    // Level = sqrt(Total XP / 50)
    return math.sqrt(totalXP / 50).floor() + 1;
  }
  
  // Get XP required for next level
  int getXPForNextLevel() {
    final nextLevel = level + 1;
    return (nextLevel * nextLevel * 50) - totalXP;
  }
  
  // Get level progress percentage
  double getLevelProgress() {
    final currentLevelXP = ((level - 1) * (level - 1) * 50);
    final nextLevelXP = (level * level * 50);
    final progressXP = totalXP - currentLevelXP;
    final requiredXP = nextLevelXP - currentLevelXP;
    
    return progressXP / requiredXP;
  }
}