import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../../models/ModelProvider.dart';

/// Service for managing flashcards with spaced repetition
class FlashcardService {
  static final FlashcardService _instance = FlashcardService._internal();
  factory FlashcardService() => _instance;
  FlashcardService._internal();

  // Spaced Repetition Algorithm constants (SM-2)
  static const double _initialEaseFactor = 2.5;
  static const int _initialInterval = 1;
  static const double _minEaseFactor = 1.3;

  /// Create a flashcard
  Future<FlashCard> createFlashcard({
    required String userId,
    required String front,
    required String back,
    String? deck,
    List<String>? tags,
    String? source,
  }) async {
    try {
      final flashcard = FlashCard(
        userId: userId,
        front: front,
        back: back,
        deck: deck ?? 'Default',
        tags: tags?.join(','),
        interval: _initialInterval,
        easeFactor: _initialEaseFactor,
        repetitions: 0,
        nextReview: TemporalDateTime.now(),
        isActive: true,
        source: source,
      );

      final savedFlashcard = await Amplify.DataStore.save(flashcard);
      return savedFlashcard;
    } catch (e) {
      safePrint('Error creating flashcard: $e');
      rethrow;
    }
  }

  /// Get flashcards due for review
  Future<List<FlashCard>> getDueFlashcards({
    required String userId,
    String? deck,
    int limit = 20,
  }) async {
    try {
      final now = TemporalDateTime.now();
      
      var filter = FlashCard.USERID.eq(userId)
          .and(FlashCard.ISACTIVE.eq(true))
          .and(FlashCard.NEXTREVIEW.le(now));
      
      if (deck != null) {
        filter = filter.and(FlashCard.DECK.eq(deck));
      }

      final flashcards = await Amplify.DataStore.query(
        FlashCard.classType,
        where: filter,
        pagination: QueryPagination(limit: limit),
      );

      return flashcards;
    } catch (e) {
      safePrint('Error getting due flashcards: $e');
      return [];
    }
  }

  /// Review a flashcard with spaced repetition algorithm
  Future<FlashCard> reviewFlashcard({
    required FlashCard flashcard,
    required int quality, // 0-5 rating of how well the user remembered
  }) async {
    try {
      // SM-2 Algorithm implementation
      double easeFactor = flashcard.easeFactor ?? _initialEaseFactor;
      int repetitions = flashcard.repetitions ?? 0;
      int interval = flashcard.interval ?? _initialInterval;

      if (quality >= 3) {
        // Correct response
        if (repetitions == 0) {
          interval = 1;
        } else if (repetitions == 1) {
          interval = 6;
        } else {
          interval = (interval * easeFactor).round();
        }
        repetitions += 1;
      } else {
        // Incorrect response
        repetitions = 0;
        interval = 1;
      }

      // Update ease factor
      easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      easeFactor = math.max(easeFactor, _minEaseFactor);

      // Calculate next review date
      final nextReview = TemporalDateTime(
        DateTime.now().add(Duration(days: interval)),
      );

      // Update flashcard
      final updatedFlashcard = flashcard.copyWith(
        interval: interval,
        easeFactor: easeFactor,
        repetitions: repetitions,
        nextReview: nextReview,
        lastReviewed: TemporalDateTime.now(),
      );

      final savedFlashcard = await Amplify.DataStore.save(updatedFlashcard);
      return savedFlashcard;
    } catch (e) {
      safePrint('Error reviewing flashcard: $e');
      rethrow;
    }
  }

  /// Generate flashcards from content
  Future<List<FlashCard>> generateFlashcardsFromContent({
    required String userId,
    required String content,
    required String source,
    String? deck,
    String? subject,
  }) async {
    try {
      // Use AI to extract Q&A pairs from content
      final flashcardData = await _extractFlashcardsFromContent(content, subject);
      
      final flashcards = <FlashCard>[];
      
      for (final data in flashcardData) {
        final flashcard = await createFlashcard(
          userId: userId,
          front: data['question']!,
          back: data['answer']!,
          deck: deck ?? subject ?? 'Generated',
          tags: data['tags']?.split(','),
          source: source,
        );
        flashcards.add(flashcard);
      }
      
      return flashcards;
    } catch (e) {
      safePrint('Error generating flashcards: $e');
      return [];
    }
  }

  /// Get flashcard statistics
  Future<FlashcardStatistics> getStatistics({
    required String userId,
    String? deck,
  }) async {
    try {
      var filter = FlashCard.USERID.eq(userId).and(FlashCard.ISACTIVE.eq(true));
      
      if (deck != null) {
        filter = filter.and(FlashCard.DECK.eq(deck));
      }

      final flashcards = await Amplify.DataStore.query(
        FlashCard.classType,
        where: filter,
      );
      
      final now = DateTime.now();
      int dueToday = 0;
      int newCards = 0;
      int learned = 0;
      double averageEaseFactor = 0;
      
      for (final card in flashcards) {
        if (card.repetitions == 0) {
          newCards++;
        } else {
          learned++;
        }
        
        if (card.nextReview != null && card.nextReview!.getDateTime().isBefore(now)) {
          dueToday++;
        }
        
        averageEaseFactor += card.easeFactor ?? _initialEaseFactor;
      }
      
      if (flashcards.isNotEmpty) {
        averageEaseFactor /= flashcards.length;
      }
      
      return FlashcardStatistics(
        totalCards: flashcards.length,
        dueToday: dueToday,
        newCards: newCards,
        learnedCards: learned,
        averageEaseFactor: averageEaseFactor,
        retention: _calculateRetention(flashcards),
      );
    } catch (e) {
      safePrint('Error getting flashcard statistics: $e');
      return FlashcardStatistics.empty();
    }
  }

  /// Get learning progress over time
  Future<List<LearningProgress>> getLearningProgress({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? deck,
  }) async {
    try {
      var filter = FlashCard.USERID.eq(userId)
          .and(FlashCard.ISACTIVE.eq(true))
          .and(FlashCard.LASTREVIEWED.between(
            TemporalDateTime(startDate),
            TemporalDateTime(endDate),
          ));
      
      if (deck != null) {
        filter = filter.and(FlashCard.DECK.eq(deck));
      }

      final flashcards = await Amplify.DataStore.query(
        FlashCard.classType,
        where: filter,
      );
      
      // Group by date and calculate daily statistics
      final progressMap = <DateTime, LearningProgress>{};
      
      for (final card in flashcards) {
        if (card.lastReviewed != null) {
          final date = DateTime(
            card.lastReviewed!.getDateTime().year,
            card.lastReviewed!.getDateTime().month,
            card.lastReviewed!.getDateTime().day,
          );
          
          progressMap[date] ??= LearningProgress(
            date: date,
            cardsReviewed: 0,
            newCardsLearned: 0,
            averageEaseFactor: 0,
          );
          
          progressMap[date] = progressMap[date]!.copyWith(
            cardsReviewed: progressMap[date]!.cardsReviewed + 1,
            newCardsLearned: card.repetitions == 1 
                ? progressMap[date]!.newCardsLearned + 1 
                : progressMap[date]!.newCardsLearned,
          );
        }
      }
      
      return progressMap.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      safePrint('Error getting learning progress: $e');
      return [];
    }
  }

  /// Archive flashcard
  Future<void> archiveFlashcard(String flashcardId) async {
    try {
      final request = ModelQueries.get(
        FlashCard.classType,
        FlashCardModelIdentifier(id: flashcardId),
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final updatedCard = response.data!.copyWith(isActive: false);
        final updateRequest = ModelMutations.update(updatedCard);
        await Amplify.API.mutate(request: updateRequest).response;
      }
    } catch (e) {
      safePrint('Error archiving flashcard: $e');
      rethrow;
    }
  }

  /// Create Leitner box system
  Future<LeitnerBoxSystem> createLeitnerSystem({
    required String userId,
    required String deck,
  }) async {
    try {
      // Get all active flashcards for the deck
      final filter = FlashCard.USERID.eq(userId)
          .and(FlashCard.DECK.eq(deck))
          .and(FlashCard.ISACTIVE.eq(true));

      final request = ModelQueries.list(
        FlashCard.classType,
        where: filter,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data == null) {
        return LeitnerBoxSystem.empty();
      }

      final flashcards = response.data!.items.whereType<FlashCard>().toList();
      
      // Distribute cards into Leitner boxes based on interval
      final boxes = List<List<FlashCard>>.generate(5, (_) => []);
      
      for (final card in flashcards) {
        final boxIndex = _calculateLeitnerBox(card.interval ?? 1);
        boxes[boxIndex].add(card);
      }
      
      return LeitnerBoxSystem(
        userId: userId,
        deck: deck,
        boxes: boxes,
        lastReview: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error creating Leitner system: $e');
      return LeitnerBoxSystem.empty();
    }
  }

  // Private helper methods

  Future<List<Map<String, String>>> _extractFlashcardsFromContent(
    String content,
    String? subject,
  ) async {
    // In production, use AI service to extract Q&A pairs
    // For now, return sample data
    return [
      {
        'question': 'Sample question from content',
        'answer': 'Sample answer',
        'tags': subject ?? 'general',
      },
    ];
  }

  double _calculateRetention(List<FlashCard> flashcards) {
    if (flashcards.isEmpty) return 0;
    
    int wellRemembered = 0;
    for (final card in flashcards) {
      if ((card.repetitions ?? 0) > 0 && (card.easeFactor ?? _initialEaseFactor) > 2.0) {
        wellRemembered++;
      }
    }
    
    return wellRemembered / flashcards.length;
  }

  int _calculateLeitnerBox(int interval) {
    if (interval <= 1) return 0;
    if (interval <= 3) return 1;
    if (interval <= 7) return 2;
    if (interval <= 21) return 3;
    return 4;
  }
}

// Data models for flashcard service

class FlashcardStatistics {
  final int totalCards;
  final int dueToday;
  final int newCards;
  final int learnedCards;
  final double averageEaseFactor;
  final double retention;

  FlashcardStatistics({
    required this.totalCards,
    required this.dueToday,
    required this.newCards,
    required this.learnedCards,
    required this.averageEaseFactor,
    required this.retention,
  });

  factory FlashcardStatistics.empty() {
    return FlashcardStatistics(
      totalCards: 0,
      dueToday: 0,
      newCards: 0,
      learnedCards: 0,
      averageEaseFactor: 2.5,
      retention: 0,
    );
  }
}

class LearningProgress {
  final DateTime date;
  final int cardsReviewed;
  final int newCardsLearned;
  final double averageEaseFactor;

  LearningProgress({
    required this.date,
    required this.cardsReviewed,
    required this.newCardsLearned,
    required this.averageEaseFactor,
  });

  LearningProgress copyWith({
    DateTime? date,
    int? cardsReviewed,
    int? newCardsLearned,
    double? averageEaseFactor,
  }) {
    return LearningProgress(
      date: date ?? this.date,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      newCardsLearned: newCardsLearned ?? this.newCardsLearned,
      averageEaseFactor: averageEaseFactor ?? this.averageEaseFactor,
    );
  }
}

class LeitnerBoxSystem {
  final String userId;
  final String deck;
  final List<List<FlashCard>> boxes; // 5 boxes for Leitner system
  final DateTime lastReview;

  LeitnerBoxSystem({
    required this.userId,
    required this.deck,
    required this.boxes,
    required this.lastReview,
  });

  factory LeitnerBoxSystem.empty() {
    return LeitnerBoxSystem(
      userId: '',
      deck: '',
      boxes: List.generate(5, (_) => []),
      lastReview: DateTime.now(),
    );
  }

  int get totalCards => boxes.fold(0, (sum, box) => sum + box.length);
  
  int getBoxCount(int boxIndex) => 
      boxIndex >= 0 && boxIndex < boxes.length ? boxes[boxIndex].length : 0;
}