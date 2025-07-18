import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? todoId; // 연결된 Todo ID
  final String? categoryId; // Todo 카테고리 ID
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final Color? color;
  
  Note({
    required this.id,
    required this.title,
    required this.content,
    this.todoId,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.color,
  });
  
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? todoId,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Color? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      todoId: todoId ?? this.todoId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'todoId': todoId,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'color': color?.value,
    };
  }
  
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      todoId: json['todoId'],
      categoryId: json['categoryId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }
}