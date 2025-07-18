import 'package:flutter/material.dart';

class TodoCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final int orderIndex;
  final DateTime createdAt;
  
  TodoCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.orderIndex,
    required this.createdAt,
  });
  
  TodoCategory copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return TodoCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory TodoCategory.fromJson(Map<String, dynamic> json) {
    return TodoCategory(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      orderIndex: json['orderIndex'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// 기본 카테고리
class DefaultCategories {
  static final List<TodoCategory> categories = [
    TodoCategory(
      id: 'math',
      name: '수학',
      color: Colors.blue,
      icon: Icons.calculate,
      orderIndex: 0,
      createdAt: DateTime.now(),
    ),
    TodoCategory(
      id: 'korean',
      name: '국어',
      color: Colors.red,
      icon: Icons.menu_book,
      orderIndex: 1,
      createdAt: DateTime.now(),
    ),
    TodoCategory(
      id: 'english',
      name: '영어',
      color: Colors.purple,
      icon: Icons.language,
      orderIndex: 2,
      createdAt: DateTime.now(),
    ),
    TodoCategory(
      id: 'science',
      name: '과학',
      color: Colors.green,
      icon: Icons.science,
      orderIndex: 3,
      createdAt: DateTime.now(),
    ),
    TodoCategory(
      id: 'other',
      name: '기타',
      color: Colors.grey,
      icon: Icons.more_horiz,
      orderIndex: 4,
      createdAt: DateTime.now(),
    ),
  ];
}