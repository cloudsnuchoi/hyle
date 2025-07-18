import 'package:flutter/material.dart';

// Flashcard Model
class Flashcard {
  final String id;
  final String front;
  final String back;
  final String subject;
  final String difficulty; // easy, medium, hard
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastReviewed;
  final int timesReviewed;
  final int correctAnswers;
  final List<String> tags;
  final bool isFavorite;
  final bool isArchived;
  
  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.subject,
    this.difficulty = 'medium',
    required this.createdAt,
    required this.updatedAt,
    this.lastReviewed,
    this.timesReviewed = 0,
    this.correctAnswers = 0,
    this.tags = const [],
    this.isFavorite = false,
    this.isArchived = false,
  });
  
  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    String? subject,
    String? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastReviewed,
    int? timesReviewed,
    int? correctAnswers,
    List<String>? tags,
    bool? isFavorite,
    bool? isArchived,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
    );
  }
  
  double get accuracyRate {
    if (timesReviewed == 0) return 0.0;
    return correctAnswers / timesReviewed;
  }
  
  Color get difficultyColor {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'subject': subject,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastReviewed': lastReviewed?.toIso8601String(),
      'timesReviewed': timesReviewed,
      'correctAnswers': correctAnswers,
      'tags': tags,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
    };
  }
  
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      front: json['front'],
      back: json['back'],
      subject: json['subject'],
      difficulty: json['difficulty'] ?? 'medium',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastReviewed: json['lastReviewed'] != null ? DateTime.parse(json['lastReviewed']) : null,
      timesReviewed: json['timesReviewed'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      isArchived: json['isArchived'] ?? false,
    );
  }
}

// Flashcard Deck Model
class FlashcardDeck {
  final String id;
  final String name;
  final String description;
  final String subject;
  final List<String> cardIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Color color;
  final bool isFavorite;
  final bool isArchived;
  
  const FlashcardDeck({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.cardIds,
    required this.createdAt,
    required this.updatedAt,
    this.color = Colors.blue,
    this.isFavorite = false,
    this.isArchived = false,
  });
  
  FlashcardDeck copyWith({
    String? id,
    String? name,
    String? description,
    String? subject,
    List<String>? cardIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Color? color,
    bool? isFavorite,
    bool? isArchived,
  }) {
    return FlashcardDeck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      cardIds: cardIds ?? this.cardIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'cardIds': cardIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color.value,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
    };
  }
  
  factory FlashcardDeck.fromJson(Map<String, dynamic> json) {
    return FlashcardDeck(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      subject: json['subject'],
      cardIds: List<String>.from(json['cardIds']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      color: Color(json['color'] ?? Colors.blue.value),
      isFavorite: json['isFavorite'] ?? false,
      isArchived: json['isArchived'] ?? false,
    );
  }
}

// Study Session Model
class StudySession {
  final String id;
  final String deckId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> cardIds;
  final Map<String, bool> answers; // cardId -> correct/incorrect
  final int totalCards;
  final int correctAnswers;
  
  const StudySession({
    required this.id,
    required this.deckId,
    required this.startTime,
    this.endTime,
    required this.cardIds,
    required this.answers,
    required this.totalCards,
    required this.correctAnswers,
  });
  
  StudySession copyWith({
    String? id,
    String? deckId,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? cardIds,
    Map<String, bool>? answers,
    int? totalCards,
    int? correctAnswers,
  }) {
    return StudySession(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cardIds: cardIds ?? this.cardIds,
      answers: answers ?? this.answers,
      totalCards: totalCards ?? this.totalCards,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }
  
  double get accuracyRate {
    if (totalCards == 0) return 0.0;
    return correctAnswers / totalCards;
  }
  
  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'cardIds': cardIds,
      'answers': answers,
      'totalCards': totalCards,
      'correctAnswers': correctAnswers,
    };
  }
  
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      deckId: json['deckId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      cardIds: List<String>.from(json['cardIds']),
      answers: Map<String, bool>.from(json['answers']),
      totalCards: json['totalCards'],
      correctAnswers: json['correctAnswers'],
    );
  }
}

// Flashcard Statistics
class FlashcardStats {
  final int totalCards;
  final int activeCards;
  final int archivedCards;
  final int favoriteCards;
  final int totalDecks;
  final int studySessionsToday;
  final double averageAccuracy;
  final Map<String, int> subjectCounts;
  final Map<String, int> difficultyCounts;
  
  const FlashcardStats({
    required this.totalCards,
    required this.activeCards,
    required this.archivedCards,
    required this.favoriteCards,
    required this.totalDecks,
    required this.studySessionsToday,
    required this.averageAccuracy,
    required this.subjectCounts,
    required this.difficultyCounts,
  });
}

// Deck Colors
class DeckColors {
  static const List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];
  
  static Color getColor(int index) {
    return colors[index % colors.length];
  }
}