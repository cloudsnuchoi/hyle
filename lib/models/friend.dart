import 'package:flutter/material.dart';

enum OnlineStatus { online, studying, rest, offline }

class Friend {
  final String id;
  final String name;
  final String? profileImage;
  final OnlineStatus status;
  final String? currentActivity; // 현재 공부 중인 과목/활동
  final int todayStudyMinutes;
  final int streak;
  final DateTime lastSeen;
  final int level;
  final String? grade; // 학년 (예: 중3, 고2)
  final String? studyGoal; // 공부 목표 (예: 수능, 중간고사)
  final String? title; // 칭호
  
  Friend({
    required this.id,
    required this.name,
    this.profileImage,
    this.status = OnlineStatus.offline,
    this.currentActivity,
    this.todayStudyMinutes = 0,
    this.streak = 0,
    required this.lastSeen,
    this.level = 1,
    this.grade,
    this.studyGoal,
    this.title,
  });
  
  Friend copyWith({
    String? id,
    String? name,
    String? profileImage,
    OnlineStatus? status,
    String? currentActivity,
    int? todayStudyMinutes,
    int? streak,
    DateTime? lastSeen,
    int? level,
    String? grade,
    String? studyGoal,
    String? title,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      currentActivity: currentActivity ?? this.currentActivity,
      todayStudyMinutes: todayStudyMinutes ?? this.todayStudyMinutes,
      streak: streak ?? this.streak,
      lastSeen: lastSeen ?? this.lastSeen,
      level: level ?? this.level,
      grade: grade ?? this.grade,
      studyGoal: studyGoal ?? this.studyGoal,
      title: title ?? this.title,
    );
  }
  
  String get statusText {
    switch (status) {
      case OnlineStatus.online:
        return '온라인';
      case OnlineStatus.studying:
        return currentActivity ?? '공부 중';
      case OnlineStatus.rest:
        return '휴식 중';
      case OnlineStatus.offline:
        return '오프라인';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case OnlineStatus.online:
        return Colors.green;
      case OnlineStatus.studying:
        return Colors.blue;
      case OnlineStatus.rest:
        return Colors.orange;
      case OnlineStatus.offline:
        return Colors.grey;
    }
  }
  
  IconData get statusIcon {
    switch (status) {
      case OnlineStatus.online:
        return Icons.circle;
      case OnlineStatus.studying:
        return Icons.menu_book;
      case OnlineStatus.rest:
        return Icons.coffee;
      case OnlineStatus.offline:
        return Icons.circle_outlined;
    }
  }
  
  String get lastSeenText {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '오래 전';
    }
  }
}