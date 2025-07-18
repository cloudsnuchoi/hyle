import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo_category.dart';
import '../models/todo_item.dart';

// 카테고리 상태 관리
class TodoCategoryNotifier extends StateNotifier<List<TodoCategory>> {
  TodoCategoryNotifier() : super(DefaultCategories.categories) {
    _loadCategories();
  }

  static const String _storageKey = 'todo_categories';

  // 카테고리 불러오기
  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesJson = prefs.getString(_storageKey);
    
    if (categoriesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(categoriesJson);
        state = decoded.map((json) => TodoCategory.fromJson(json)).toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      } catch (e) {
        // 에러 시 기본 카테고리 사용
        state = DefaultCategories.categories;
      }
    }
  }

  // 카테고리 저장
  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String categoriesJson = jsonEncode(
      state.map((category) => category.toJson()).toList(),
    );
    await prefs.setString(_storageKey, categoriesJson);
  }

  // 카테고리 추가
  Future<void> addCategory({
    required String name,
    required Color color,
    required IconData icon,
  }) async {
    final newCategory = TodoCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      icon: icon,
      orderIndex: state.length,
      createdAt: DateTime.now(),
    );
    
    state = [...state, newCategory];
    await _saveCategories();
  }

  // 카테고리 수정
  Future<void> updateCategory(TodoCategory category) async {
    state = state.map((c) => c.id == category.id ? category : c).toList();
    await _saveCategories();
  }

  // 카테고리 삭제
  Future<void> deleteCategory(String categoryId) async {
    state = state.where((c) => c.id != categoryId).toList();
    
    // orderIndex 재정렬
    for (int i = 0; i < state.length; i++) {
      state[i] = state[i].copyWith(orderIndex: i);
    }
    
    await _saveCategories();
  }

  // 카테고리 순서 변경
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final List<TodoCategory> categories = [...state];
    final TodoCategory movedCategory = categories.removeAt(oldIndex);
    categories.insert(newIndex, movedCategory);
    
    // orderIndex 재정렬
    for (int i = 0; i < categories.length; i++) {
      categories[i] = categories[i].copyWith(orderIndex: i);
    }
    
    state = categories;
    await _saveCategories();
  }

  // 카테고리 ID로 가져오기
  TodoCategory? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Todo 아이템 상태 관리
class TodoItemsNotifier extends StateNotifier<List<TodoItem>> {
  TodoItemsNotifier() : super([]) {
    _loadTodos();
  }

  static const String _storageKey = 'todo_items';

  // Todo 불러오기
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(_storageKey);
    
    if (todosJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(todosJson);
        state = decoded.map((json) => TodoItem.fromJson(json)).toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      } catch (e) {
        state = [];
      }
    }
  }

  // Todo 저장
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson = jsonEncode(
      state.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_storageKey, todosJson);
  }

  // Todo 추가
  Future<void> addTodo({
    required String title,
    String? description,
    required String categoryId,
    int estimatedMinutes = 30,
  }) async {
    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      categoryId: categoryId,
      orderIndex: state.length,
      createdAt: DateTime.now(),
      estimatedMinutes: estimatedMinutes,
    );
    
    state = [...state, newTodo];
    await _saveTodos();
  }

  // Todo 수정
  Future<void> updateTodo(TodoItem todo) async {
    state = state.map((t) => t.id == todo.id ? todo : t).toList();
    await _saveTodos();
  }

  // Todo 삭제
  Future<void> deleteTodo(String todoId) async {
    state = state.where((t) => t.id != todoId).toList();
    
    // orderIndex 재정렬
    for (int i = 0; i < state.length; i++) {
      state[i] = state[i].copyWith(orderIndex: i);
    }
    
    await _saveTodos();
  }

  // Todo 완료 토글
  Future<void> toggleTodoComplete(String todoId) async {
    state = state.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(
          isCompleted: !todo.isCompleted,
          completedAt: !todo.isCompleted ? DateTime.now() : null,
        );
      }
      return todo;
    }).toList();
    await _saveTodos();
  }

  // 카테고리별 Todo 순서 변경
  Future<void> reorderTodosInCategory(
    String categoryId,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // 카테고리별로 분리
    final categoryTodos = state
        .where((t) => t.categoryId == categoryId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final otherTodos = state.where((t) => t.categoryId != categoryId).toList();
    
    // 해당 카테고리 내에서 순서 변경
    final TodoItem movedTodo = categoryTodos.removeAt(oldIndex);
    categoryTodos.insert(newIndex, movedTodo);
    
    // 전체 state 재구성
    final List<TodoItem> newState = [];
    int orderIndex = 0;
    
    // 기존 순서대로 다시 조합
    for (final todo in state) {
      if (todo.categoryId == categoryId) {
        // 재정렬된 카테고리 todo 추가
        final reorderedTodo = categoryTodos.removeAt(0);
        newState.add(reorderedTodo.copyWith(orderIndex: orderIndex));
      } else {
        // 다른 카테고리 todo는 그대로
        newState.add(todo.copyWith(orderIndex: orderIndex));
      }
      orderIndex++;
    }
    
    state = newState;
    await _saveTodos();
  }

  // 카테고리 삭제 시 Todo 이동
  Future<void> moveTodosToOtherCategory(String fromCategoryId) async {
    state = state.map((todo) {
      if (todo.categoryId == fromCategoryId) {
        return todo.copyWith(categoryId: 'other');
      }
      return todo;
    }).toList();
    await _saveTodos();
  }

  // 카테고리별 Todo 가져오기
  List<TodoItem> getTodosByCategory(String categoryId) {
    return state
        .where((todo) => todo.categoryId == categoryId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  // 노트 연결
  Future<void> linkNoteToTodo(String todoId, String noteId) async {
    state = state.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(noteId: noteId);
      }
      return todo;
    }).toList();
    await _saveTodos();
  }

  // 세션 설정 업데이트
  Future<void> updateSessionSettings(
    String todoId,
    Map<String, dynamic> sessionSettings,
  ) async {
    state = state.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(sessionSettings: sessionSettings);
      }
      return todo;
    }).toList();
    await _saveTodos();
  }

  // 실제 소요 시간 업데이트
  Future<void> updateActualMinutes(String todoId, int minutes) async {
    state = state.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(
          actualMinutes: todo.actualMinutes + minutes,
        );
      }
      return todo;
    }).toList();
    await _saveTodos();
  }
}

// Providers
final todoCategoryProvider =
    StateNotifierProvider<TodoCategoryNotifier, List<TodoCategory>>(
  (ref) => TodoCategoryNotifier(),
);

final todoItemsProvider =
    StateNotifierProvider<TodoItemsNotifier, List<TodoItem>>(
  (ref) => TodoItemsNotifier(),
);

// 카테고리별 Todo 개수
final todosCountByCategoryProvider = Provider.family<int, String>((ref, categoryId) {
  final todos = ref.watch(todoItemsProvider);
  return todos.where((todo) => todo.categoryId == categoryId && !todo.isCompleted).length;
});

// 완료된 Todo 개수
final completedTodosCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoItemsProvider);
  return todos.where((todo) => todo.isCompleted).length;
});

// 오늘 완료한 Todo 개수
final todayCompletedTodosProvider = Provider<int>((ref) {
  final todos = ref.watch(todoItemsProvider);
  final now = DateTime.now();
  return todos.where((todo) {
    if (!todo.isCompleted || todo.completedAt == null) return false;
    return todo.completedAt!.year == now.year &&
        todo.completedAt!.month == now.month &&
        todo.completedAt!.day == now.day;
  }).length;
});