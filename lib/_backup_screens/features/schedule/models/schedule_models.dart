import 'package:flutter/material.dart';

class StudyEvent {
  final String id;
  final String title;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String? description;
  final bool isCompleted;
  
  StudyEvent({
    required this.id,
    required this.title,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.description,
    this.isCompleted = false,
  });
  
  Duration get duration => endTime.difference(startTime);
  
  StudyEvent copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    String? description,
    bool? isCompleted,
  }) {
    return StudyEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum CalendarView { week, threeDay, day, month }