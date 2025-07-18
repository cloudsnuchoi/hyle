import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/note.dart';
import 'todo_category_provider.dart';

// Notes 상태 관리
class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]) {
    _loadNotes();
  }

  static const String _storageKey = 'notes';

  // 노트 불러오기
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString(_storageKey);
    
    if (notesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(notesJson);
        state = decoded.map((json) => Note.fromJson(json)).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } catch (e) {
        state = [];
      }
    }
  }

  // 노트 저장
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String notesJson = jsonEncode(
      state.map((note) => note.toJson()).toList(),
    );
    await prefs.setString(_storageKey, notesJson);
  }

  // 노트 추가
  Future<String> addNote({
    required String title,
    required String content,
    String? todoId,
    String? categoryId,
    List<String> tags = const [],
    Color? color,
  }) async {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      todoId: todoId,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
      color: color,
    );
    
    state = [newNote, ...state];
    await _saveNotes();
    return newNote.id;
  }

  // 노트 수정
  Future<void> updateNote(Note note) async {
    state = state.map((n) => n.id == note.id 
      ? note.copyWith(updatedAt: DateTime.now())
      : n
    ).toList();
    await _saveNotes();
  }

  // 노트 삭제
  Future<void> deleteNote(String noteId) async {
    state = state.where((n) => n.id != noteId).toList();
    await _saveNotes();
  }

  // Todo와 연결된 노트 생성
  Future<String> createNoteForTodo(String todoId, String categoryId) async {
    return await addNote(
      title: '할 일 노트',
      content: '',
      todoId: todoId,
      categoryId: categoryId,
    );
  }

  // Todo ID로 노트 가져오기
  Note? getNoteByTodoId(String todoId) {
    try {
      return state.firstWhere((note) => note.todoId == todoId);
    } catch (e) {
      return null;
    }
  }

  // 카테고리별 노트 가져오기
  List<Note> getNotesByCategory(String? categoryId) {
    if (categoryId == null) {
      return state.where((note) => note.categoryId == null).toList();
    }
    return state.where((note) => note.categoryId == categoryId).toList();
  }

  // 태그로 검색
  List<Note> searchByTags(List<String> tags) {
    return state.where((note) {
      return tags.any((tag) => note.tags.contains(tag));
    }).toList();
  }

  // 텍스트로 검색
  List<Note> searchNotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Todo 삭제 시 연결된 노트 연결 해제
  Future<void> unlinkTodo(String todoId) async {
    state = state.map((note) {
      if (note.todoId == todoId) {
        return note.copyWith(todoId: null);
      }
      return note;
    }).toList();
    await _saveNotes();
  }
}

// Providers
final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>(
  (ref) => NotesNotifier(),
);

// 카테고리별 노트 개수
final notesCountByCategoryProvider = Provider.family<int, String?>((ref, categoryId) {
  final notes = ref.watch(notesProvider);
  return notes.where((note) => note.categoryId == categoryId).length;
});

// Todo와 연결된 노트
final noteByTodoIdProvider = Provider.family<Note?, String>((ref, todoId) {
  final notes = ref.watch(notesProvider);
  try {
    return notes.firstWhere((note) => note.todoId == todoId);
  } catch (e) {
    return null;
  }
});

// 최근 노트
final recentNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesProvider);
  final sorted = [...notes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.take(5).toList();
});

// 모든 태그
final allTagsProvider = Provider<Set<String>>((ref) {
  final notes = ref.watch(notesProvider);
  final tags = <String>{};
  for (final note in notes) {
    tags.addAll(note.tags);
  }
  return tags;
});