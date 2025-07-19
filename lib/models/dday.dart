import 'package:flutter/material.dart';

class DDay {
  final String id;
  final String title;
  final DateTime targetDate;
  final Color color;
  final IconData icon;
  final bool isImportant;
  
  DDay({
    required this.id,
    required this.title,
    required this.targetDate,
    this.color = Colors.blue,
    this.icon = Icons.event,
    this.isImportant = false,
  });
  
  DDay copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    Color? color,
    IconData? icon,
    bool? isImportant,
  }) {
    return DDay(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isImportant: isImportant ?? this.isImportant,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'color': color.value,
      'icon': icon.codePoint,
      'isImportant': isImportant,
    };
  }
  
  factory DDay.fromJson(Map<String, dynamic> json) {
    return DDay(
      id: json['id'],
      title: json['title'],
      targetDate: DateTime.parse(json['targetDate']),
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      isImportant: json['isImportant'] ?? false,
    );
  }
  
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }
  
  String get daysLeftText {
    final days = daysLeft;
    if (days == 0) return 'D-DAY';
    if (days > 0) return 'D-$days';
    return 'D+${days.abs()}';
  }
}