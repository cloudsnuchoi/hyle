import 'package:flutter/material.dart';

// Note Model
class Note {
  final String id;
  final String title;
  final String content;
  final String subject;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final Color color;
  final bool isFavorite;
  final bool isArchived;
  
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.subject,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.color = Colors.white,
    this.isFavorite = false,
    this.isArchived = false,
  });
  
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? subject,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Color? color,
    bool? isFavorite,
    bool? isArchived,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'subject': subject,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'color': color.value,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
    };
  }
  
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      subject: json['subject'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      color: Color(json['color'] ?? Colors.white.value),
      isFavorite: json['isFavorite'] ?? false,
      isArchived: json['isArchived'] ?? false,
    );
  }
}

// Note Template
class NoteTemplate {
  final String id;
  final String name;
  final String template;
  final String subject;
  final IconData icon;
  final String description;
  
  const NoteTemplate({
    required this.id,
    required this.name,
    required this.template,
    required this.subject,
    required this.icon,
    required this.description,
  });
}

// Predefined Note Templates
class NoteTemplates {
  static const List<NoteTemplate> templates = [
    NoteTemplate(
      id: 'basic',
      name: '기본 노트',
      template: '제목: \n\n내용:\n\n',
      subject: 'General',
      icon: Icons.note,
      description: '자유형식 노트',
    ),
    NoteTemplate(
      id: 'lecture',
      name: '강의 노트',
      template: '강의: \n날짜: \n\n주요 내용:\n\n핵심 포인트:\n• \n• \n• \n\n질문사항:\n\n',
      subject: 'Lecture',
      icon: Icons.school,
      description: '강의 내용 정리',
    ),
    NoteTemplate(
      id: 'summary',
      name: '요약 노트',
      template: '주제: \n\n핵심 내용:\n\n세부 사항:\n\n결론:\n\n',
      subject: 'Summary',
      icon: Icons.summarize,
      description: '내용 요약 정리',
    ),
    NoteTemplate(
      id: 'problem',
      name: '문제 해결',
      template: '문제: \n\n해결 과정:\n1. \n2. \n3. \n\n답: \n\n참고 사항:\n\n',
      subject: 'Problem',
      icon: Icons.psychology,
      description: '문제 해결 과정',
    ),
    NoteTemplate(
      id: 'vocabulary',
      name: '단어 정리',
      template: '단어: \n발음: \n의미: \n\n예문:\n\n관련 단어:\n\n',
      subject: 'Vocabulary',
      icon: Icons.translate,
      description: '단어 학습 정리',
    ),
    NoteTemplate(
      id: 'formula',
      name: '공식 정리',
      template: '공식명: \n\n공식: \n\n적용 범위:\n\n예제:\n\n주의사항:\n\n',
      subject: 'Formula',
      icon: Icons.functions,
      description: '수학/과학 공식',
    ),
  ];
  
  static NoteTemplate getTemplate(String id) {
    return templates.firstWhere(
      (template) => template.id == id,
      orElse: () => templates.first,
    );
  }
}

// Note Colors
class NoteColors {
  static const List<Color> colors = [
    Colors.white,
    Color(0xFFFFF3E0), // Light Orange
    Color(0xFFE8F5E8), // Light Green
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFFCE4EC), // Light Pink
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFE0F2F1), // Light Teal
    Color(0xFFFFF8E1), // Light Yellow
  ];
  
  static Color getColor(int index) {
    return colors[index % colors.length];
  }
}