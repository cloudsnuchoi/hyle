import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_models.dart';
import '../services/local_storage_service.dart';

// Flashcard Provider
final flashcardProvider = StateNotifierProvider<FlashcardNotifier, List<Flashcard>>((ref) {
  return FlashcardNotifier();
});

class FlashcardNotifier extends StateNotifier<List<Flashcard>> {
  FlashcardNotifier() : super([]) {
    _loadFlashcards();
  }
  
  void _loadFlashcards() {
    final savedCards = _loadCardsFromStorage();
    if (savedCards.isNotEmpty) {
      state = savedCards;
    } else {
      // Initialize with sample flashcards
      state = [
        Flashcard(
          id: 'sample1',
          front: 'What is the capital of France?',
          back: 'Paris',
          subject: 'Geography',
          difficulty: 'easy',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          tags: ['geography', 'capitals', 'europe'],
        ),
        Flashcard(
          id: 'sample2',
          front: 'What is the formula for the area of a circle?',
          back: 'A = πr²',
          subject: 'Math',
          difficulty: 'medium',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['math', 'geometry', 'formulas'],
        ),
        Flashcard(
          id: 'sample3',
          front: 'What is photosynthesis?',
          back: 'The process by which plants convert light energy into chemical energy',
          subject: 'Science',
          difficulty: 'medium',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
          tags: ['biology', 'plants', 'science'],
          isFavorite: true,
        ),
      ];
      _saveCards();
    }
  }
  
  void addCard(Flashcard card) {
    state = [card, ...state];
    _saveCards();
  }
  
  void updateCard(Flashcard updatedCard) {
    state = state.map((card) {
      if (card.id == updatedCard.id) {
        return updatedCard.copyWith(updatedAt: DateTime.now());
      }
      return card;
    }).toList();
    _saveCards();
  }
  
  void deleteCard(String id) {
    state = state.where((card) => card.id != id).toList();
    _saveCards();
  }
  
  void toggleFavorite(String id) {
    state = state.map((card) {
      if (card.id == id) {
        return card.copyWith(isFavorite: !card.isFavorite);
      }
      return card;
    }).toList();
    _saveCards();
  }
  
  void archiveCard(String id) {
    state = state.map((card) {
      if (card.id == id) {
        return card.copyWith(isArchived: true);
      }
      return card;
    }).toList();
    _saveCards();
  }
  
  void unarchiveCard(String id) {
    state = state.map((card) {
      if (card.id == id) {
        return card.copyWith(isArchived: false);
      }
      return card;
    }).toList();
    _saveCards();
  }
  
  void recordAnswer(String cardId, bool isCorrect) {
    state = state.map((card) {
      if (card.id == cardId) {
        return card.copyWith(
          timesReviewed: card.timesReviewed + 1,
          correctAnswers: isCorrect ? card.correctAnswers + 1 : card.correctAnswers,
          lastReviewed: DateTime.now(),
        );
      }
      return card;
    }).toList();
    _saveCards();
  }
  
  void _saveCards() {
    try {
      final cardsJson = state.map((card) => card.toJson()).toList();
      LocalStorageService.prefs.setString('flashcards', jsonEncode(cardsJson));
    } catch (e) {
      print('Error saving flashcards: $e');
    }
  }
  
  List<Flashcard> _loadCardsFromStorage() {
    try {
      final cardsString = LocalStorageService.prefs.getString('flashcards');
      if (cardsString == null) return [];
      
      final cardsJson = jsonDecode(cardsString) as List;
      return cardsJson.map((json) => Flashcard.fromJson(json)).toList();
    } catch (e) {
      print('Error loading flashcards: $e');
      return [];
    }
  }
}

// Deck Provider
final deckProvider = StateNotifierProvider<DeckNotifier, List<FlashcardDeck>>((ref) {
  return DeckNotifier();
});

class DeckNotifier extends StateNotifier<List<FlashcardDeck>> {
  DeckNotifier() : super([]) {
    _loadDecks();
  }
  
  void _loadDecks() {
    final savedDecks = _loadDecksFromStorage();
    if (savedDecks.isNotEmpty) {
      state = savedDecks;
    } else {
      // Initialize with sample deck
      state = [
        FlashcardDeck(
          id: 'sample_deck',
          name: '기본 학습 데크',
          description: '샘플 플래시카드들이 포함된 기본 데크입니다',
          subject: 'General',
          cardIds: ['sample1', 'sample2', 'sample3'],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          color: DeckColors.colors[0],
        ),
      ];
      _saveDecks();
    }
  }
  
  void addDeck(FlashcardDeck deck) {
    state = [deck, ...state];
    _saveDecks();
  }
  
  void updateDeck(FlashcardDeck updatedDeck) {
    state = state.map((deck) {
      if (deck.id == updatedDeck.id) {
        return updatedDeck.copyWith(updatedAt: DateTime.now());
      }
      return deck;
    }).toList();
    _saveDecks();
  }
  
  void deleteDeck(String id) {
    state = state.where((deck) => deck.id != id).toList();
    _saveDecks();
  }
  
  void addCardToDeck(String deckId, String cardId) {
    state = state.map((deck) {
      if (deck.id == deckId && !deck.cardIds.contains(cardId)) {
        return deck.copyWith(cardIds: [...deck.cardIds, cardId]);
      }
      return deck;
    }).toList();
    _saveDecks();
  }
  
  void removeCardFromDeck(String deckId, String cardId) {
    state = state.map((deck) {
      if (deck.id == deckId) {
        return deck.copyWith(cardIds: deck.cardIds.where((id) => id != cardId).toList());
      }
      return deck;
    }).toList();
    _saveDecks();
  }
  
  void _saveDecks() {
    try {
      final decksJson = state.map((deck) => deck.toJson()).toList();
      LocalStorageService.prefs.setString('flashcard_decks', jsonEncode(decksJson));
    } catch (e) {
      print('Error saving decks: $e');
    }
  }
  
  List<FlashcardDeck> _loadDecksFromStorage() {
    try {
      final decksString = LocalStorageService.prefs.getString('flashcard_decks');
      if (decksString == null) return [];
      
      final decksJson = jsonDecode(decksString) as List;
      return decksJson.map((json) => FlashcardDeck.fromJson(json)).toList();
    } catch (e) {
      print('Error loading decks: $e');
      return [];
    }
  }
}

// Study Session Provider
final studySessionProvider = StateNotifierProvider<StudySessionNotifier, List<StudySession>>((ref) {
  return StudySessionNotifier();
});

class StudySessionNotifier extends StateNotifier<List<StudySession>> {
  StudySessionNotifier() : super([]) {
    _loadSessions();
  }
  
  void _loadSessions() {
    final savedSessions = _loadSessionsFromStorage();
    state = savedSessions;
  }
  
  void addSession(StudySession session) {
    state = [session, ...state];
    _saveSessions();
  }
  
  void updateSession(StudySession updatedSession) {
    state = state.map((session) {
      if (session.id == updatedSession.id) {
        return updatedSession;
      }
      return session;
    }).toList();
    _saveSessions();
  }
  
  void _saveSessions() {
    try {
      final sessionsJson = state.map((session) => session.toJson()).toList();
      LocalStorageService.prefs.setString('study_sessions', jsonEncode(sessionsJson));
    } catch (e) {
      print('Error saving study sessions: $e');
    }
  }
  
  List<StudySession> _loadSessionsFromStorage() {
    try {
      final sessionsString = LocalStorageService.prefs.getString('study_sessions');
      if (sessionsString == null) return [];
      
      final sessionsJson = jsonDecode(sessionsString) as List;
      return sessionsJson.map((json) => StudySession.fromJson(json)).toList();
    } catch (e) {
      print('Error loading study sessions: $e');
      return [];
    }
  }
}

// Filtered Providers
final activeFlashcardsProvider = Provider<List<Flashcard>>((ref) {
  final cards = ref.watch(flashcardProvider);
  return cards.where((card) => !card.isArchived).toList();
});

final archivedFlashcardsProvider = Provider<List<Flashcard>>((ref) {
  final cards = ref.watch(flashcardProvider);
  return cards.where((card) => card.isArchived).toList();
});

final favoriteFlashcardsProvider = Provider<List<Flashcard>>((ref) {
  final cards = ref.watch(flashcardProvider);
  return cards.where((card) => card.isFavorite && !card.isArchived).toList();
});

final activeDecksProvider = Provider<List<FlashcardDeck>>((ref) {
  final decks = ref.watch(deckProvider);
  return decks.where((deck) => !deck.isArchived).toList();
});

// Search Provider
final flashcardSearchProvider = StateProvider<String>((ref) => '');

final filteredFlashcardsProvider = Provider<List<Flashcard>>((ref) {
  final cards = ref.watch(activeFlashcardsProvider);
  final searchQuery = ref.watch(flashcardSearchProvider);
  
  if (searchQuery.isEmpty) {
    return cards;
  }
  
  return cards.where((card) {
    final query = searchQuery.toLowerCase();
    return card.front.toLowerCase().contains(query) ||
           card.back.toLowerCase().contains(query) ||
           card.subject.toLowerCase().contains(query) ||
           card.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});

// Statistics Provider
final flashcardStatsProvider = Provider<FlashcardStats>((ref) {
  final cards = ref.watch(flashcardProvider);
  final decks = ref.watch(deckProvider);
  final sessions = ref.watch(studySessionProvider);
  
  final activeCards = cards.where((card) => !card.isArchived).length;
  final archivedCards = cards.where((card) => card.isArchived).length;
  final favoriteCards = cards.where((card) => card.isFavorite).length;
  
  final today = DateTime.now();
  final todaySessionsCount = sessions.where((session) {
    return session.startTime.year == today.year &&
           session.startTime.month == today.month &&
           session.startTime.day == today.day;
  }).length;
  
  final subjectCounts = <String, int>{};
  final difficultyCounts = <String, int>{};
  
  for (final card in cards) {
    if (!card.isArchived) {
      subjectCounts[card.subject] = (subjectCounts[card.subject] ?? 0) + 1;
      difficultyCounts[card.difficulty] = (difficultyCounts[card.difficulty] ?? 0) + 1;
    }
  }
  
  final reviewedCards = cards.where((card) => card.timesReviewed > 0);
  final averageAccuracy = reviewedCards.isEmpty 
    ? 0.0 
    : reviewedCards.map((card) => card.accuracyRate).reduce((a, b) => a + b) / reviewedCards.length;
  
  return FlashcardStats(
    totalCards: cards.length,
    activeCards: activeCards,
    archivedCards: archivedCards,
    favoriteCards: favoriteCards,
    totalDecks: decks.length,
    studySessionsToday: todaySessionsCount,
    averageAccuracy: averageAccuracy,
    subjectCounts: subjectCounts,
    difficultyCounts: difficultyCounts,
  );
});

// Deck Cards Provider
final deckCardsProvider = Provider.family<List<Flashcard>, String>((ref, deckId) {
  final cards = ref.watch(flashcardProvider);
  final decks = ref.watch(deckProvider);
  
  final deck = decks.firstWhere((d) => d.id == deckId, orElse: () => FlashcardDeck(
    id: '',
    name: '',
    description: '',
    subject: '',
    cardIds: [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ));
  
  return cards.where((card) => deck.cardIds.contains(card.id)).toList();
});

// Study Mode Provider
final studyModeProvider = StateProvider<bool>((ref) => false);
final currentStudyDeckProvider = StateProvider<String?>((ref) => null);
final currentStudyCardIndexProvider = StateProvider<int>((ref) => 0);
final shuffledCardsProvider = StateProvider<List<Flashcard>>((ref) => []);

// Study Mode Helper
void startStudyMode(WidgetRef ref, String deckId) {
  final cards = ref.read(deckCardsProvider(deckId));
  final shuffledCards = List<Flashcard>.from(cards)..shuffle(Random());
  
  ref.read(currentStudyDeckProvider.notifier).state = deckId;
  ref.read(shuffledCardsProvider.notifier).state = shuffledCards;
  ref.read(currentStudyCardIndexProvider.notifier).state = 0;
  ref.read(studyModeProvider.notifier).state = true;
}

void endStudyMode(WidgetRef ref) {
  ref.read(studyModeProvider.notifier).state = false;
  ref.read(currentStudyDeckProvider.notifier).state = null;
  ref.read(currentStudyCardIndexProvider.notifier).state = 0;
  ref.read(shuffledCardsProvider.notifier).state = [];
}