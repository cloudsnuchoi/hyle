import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_models.dart';
import '../services/local_storage_service.dart';

// Note Provider
final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});

class NoteNotifier extends StateNotifier<List<Note>> {
  NoteNotifier() : super([]) {
    _loadNotes();
  }
  
  void _loadNotes() {
    final savedNotes = _loadNotesFromStorage();
    if (savedNotes.isNotEmpty) {
      state = savedNotes;
    } else {
      // Initialize with sample notes
      state = [
        Note(
          id: 'sample1',
          title: 'Hyle 학습 앱 사용법',
          content: '1. 퀘스트 시스템으로 할 일 관리\n2. 타이머로 집중 시간 측정\n3. 학습 유형 테스트로 맞춤형 학습\n4. 노트로 중요한 내용 정리',
          subject: 'General',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['앱사용법', '가이드'],
          color: NoteColors.colors[1],
        ),
        Note(
          id: 'sample2',
          title: '오늘의 학습 목표',
          content: '• 수학 문제 20개 풀기\n• 영어 단어 30개 암기\n• 과학 실험 보고서 작성\n• 역사 연표 정리',
          subject: 'Planning',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
          tags: ['목표', '계획'],
          color: NoteColors.colors[2],
          isFavorite: true,
        ),
      ];
      _saveNotes();
    }
  }
  
  void addNote(Note note) {
    state = [note, ...state];
    _saveNotes();
  }
  
  void updateNote(Note updatedNote) {
    state = state.map((note) {
      if (note.id == updatedNote.id) {
        return updatedNote.copyWith(updatedAt: DateTime.now());
      }
      return note;
    }).toList();
    _saveNotes();
  }
  
  void deleteNote(String id) {
    state = state.where((note) => note.id != id).toList();
    _saveNotes();
  }
  
  void toggleFavorite(String id) {
    state = state.map((note) {
      if (note.id == id) {
        return note.copyWith(isFavorite: !note.isFavorite);
      }
      return note;
    }).toList();
    _saveNotes();
  }
  
  void archiveNote(String id) {
    state = state.map((note) {
      if (note.id == id) {
        return note.copyWith(isArchived: true);
      }
      return note;
    }).toList();
    _saveNotes();
  }
  
  void unarchiveNote(String id) {
    state = state.map((note) {
      if (note.id == id) {
        return note.copyWith(isArchived: false);
      }
      return note;
    }).toList();
    _saveNotes();
  }
  
  void _saveNotes() {
    try {
      final notesJson = state.map((note) => note.toJson()).toList();
      LocalStorageService.prefs.setString('notes', jsonEncode(notesJson));
    } catch (e) {
      print('Error saving notes: $e');
    }
  }
  
  List<Note> _loadNotesFromStorage() {
    try {
      final notesString = LocalStorageService.prefs.getString('notes');
      if (notesString == null) return [];
      
      final notesJson = jsonDecode(notesString) as List;
      return notesJson.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }
}

// Filtered Notes Providers
final activeNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(noteProvider);
  return notes.where((note) => !note.isArchived).toList();
});

final archivedNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(noteProvider);
  return notes.where((note) => note.isArchived).toList();
});

final favoriteNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(noteProvider);
  return notes.where((note) => note.isFavorite && !note.isArchived).toList();
});

// Search Provider
final noteSearchProvider = StateProvider<String>((ref) => '');

final filteredNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(activeNotesProvider);
  final searchQuery = ref.watch(noteSearchProvider);
  
  if (searchQuery.isEmpty) {
    return notes;
  }
  
  return notes.where((note) {
    final query = searchQuery.toLowerCase();
    return note.title.toLowerCase().contains(query) ||
           note.content.toLowerCase().contains(query) ||
           note.subject.toLowerCase().contains(query) ||
           note.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});

// Subject Filter Provider
final subjectFilterProvider = StateProvider<String?>((ref) => null);

final notesBySubjectProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(filteredNotesProvider);
  final subjectFilter = ref.watch(subjectFilterProvider);
  
  if (subjectFilter == null) {
    return notes;
  }
  
  return notes.where((note) => note.subject == subjectFilter).toList();
});

// Note Statistics Provider
final noteStatsProvider = Provider<NoteStats>((ref) {
  final notes = ref.watch(noteProvider);
  final activeNotes = notes.where((note) => !note.isArchived).length;
  final archivedNotes = notes.where((note) => note.isArchived).length;
  final favoriteNotes = notes.where((note) => note.isFavorite).length;
  
  final subjectCounts = <String, int>{};
  for (final note in notes) {
    if (!note.isArchived) {
      subjectCounts[note.subject] = (subjectCounts[note.subject] ?? 0) + 1;
    }
  }
  
  return NoteStats(
    totalNotes: notes.length,
    activeNotes: activeNotes,
    archivedNotes: archivedNotes,
    favoriteNotes: favoriteNotes,
    subjectCounts: subjectCounts,
  );
});

// Note Statistics Model
class NoteStats {
  final int totalNotes;
  final int activeNotes;
  final int archivedNotes;
  final int favoriteNotes;
  final Map<String, int> subjectCounts;
  
  const NoteStats({
    required this.totalNotes,
    required this.activeNotes,
    required this.archivedNotes,
    required this.favoriteNotes,
    required this.subjectCounts,
  });
}