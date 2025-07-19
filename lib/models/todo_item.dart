import 'package:flutter/material.dart';

class TodoItem {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final bool isCompleted;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? noteId; // 연결된 노트
  final Map<String, dynamic>? sessionSettings; // 타이머 설정
  final int estimatedMinutes; // 예상 소요 시간
  final int actualMinutes; // 실제 소요 시간
  final DateTime? dueDate; // 마감일
  final String? difficulty; // 난이도 (easy, medium, hard)
  
  TodoItem({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    this.isCompleted = false,
    required this.orderIndex,
    required this.createdAt,
    this.completedAt,
    this.noteId,
    this.sessionSettings,
    this.estimatedMinutes = 30,
    this.actualMinutes = 0,
    this.dueDate,
    this.difficulty,
  });
  
  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    bool? isCompleted,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? completedAt,
    String? noteId,
    Map<String, dynamic>? sessionSettings,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime? dueDate,
    String? difficulty,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      noteId: noteId ?? this.noteId,
      sessionSettings: sessionSettings ?? this.sessionSettings,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      dueDate: dueDate ?? this.dueDate,
      difficulty: difficulty ?? this.difficulty,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'isCompleted': isCompleted,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'noteId': noteId,
      'sessionSettings': sessionSettings,
      'estimatedMinutes': estimatedMinutes,
      'actualMinutes': actualMinutes,
      'dueDate': dueDate?.toIso8601String(),
      'difficulty': difficulty,
    };
  }
  
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      categoryId: json['categoryId'],
      isCompleted: json['isCompleted'] ?? false,
      orderIndex: json['orderIndex'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt']) 
        : null,
      noteId: json['noteId'],
      sessionSettings: json['sessionSettings'],
      estimatedMinutes: json['estimatedMinutes'] ?? 30,
      actualMinutes: json['actualMinutes'] ?? 0,
      dueDate: json['dueDate'] != null 
        ? DateTime.parse(json['dueDate']) 
        : null,
      difficulty: json['difficulty'],
    );
  }
}