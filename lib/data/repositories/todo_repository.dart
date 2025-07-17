import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ModelProvider.dart';
import '../services/ai_service.dart';

// Todo Repository Provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref.read(aiServiceProvider));
});

class TodoRepository {
  final AIService _aiService;

  TodoRepository(this._aiService);

  // Create new todo
  Future<Todo> createTodo({
    required String userId,
    required String title,
    String? description,
    required Priority priority,
    DateTime? dueDate,
    String? subject,
    int? estimatedTime,
    bool aiSuggested = false,
  }) async {
    try {
      // If no estimated time provided, use AI to predict
      int finalEstimatedTime = estimatedTime ?? 
          await _aiService.predictTaskDuration(
            taskTitle: title,
            subject: subject ?? 'General',
            userId: userId,
          );

      // Calculate XP reward based on estimated time and priority
      final xpReward = _calculateXPReward(
        estimatedTime: finalEstimatedTime,
        priority: priority,
      );

      final todo = Todo(
        title: title,
        description: description,
        completed: false,
        priority: priority,
        dueDate: dueDate != null ? TemporalDateTime(dueDate) : null,
        subject: subject,
        estimatedTime: finalEstimatedTime,
        aiSuggested: aiSuggested,
        xpReward: xpReward,
        userID: userId,
      );

      final response = await Amplify.DataStore.save(todo);
      return response;
    } catch (e) {
      safePrint('Error creating todo: $e');
      rethrow;
    }
  }

  // Update todo
  Future<Todo> updateTodo({
    required Todo todo,
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    String? subject,
    int? estimatedTime,
    int? actualTime,
    bool? completed,
    DateTime? completedAt,
  }) async {
    try {
      final updatedTodo = todo.copyWith(
        title: title ?? todo.title,
        description: description ?? todo.description,
        priority: priority ?? todo.priority,
        dueDate: dueDate != null ? TemporalDateTime(dueDate) : todo.dueDate,
        subject: subject ?? todo.subject,
        estimatedTime: estimatedTime ?? todo.estimatedTime,
        actualTime: actualTime ?? todo.actualTime,
        completed: completed ?? todo.completed,
        completedAt: completedAt != null ? TemporalDateTime(completedAt) : todo.completedAt,
      );

      final response = await Amplify.DataStore.save(updatedTodo);
      return response;
    } catch (e) {
      safePrint('Error updating todo: $e');
      rethrow;
    }
  }

  // Complete todo
  Future<TodoCompletionResult> completeTodo({
    required String todoId,
    required int actualTime,
  }) async {
    try {
      final todos = await Amplify.DataStore.query(
        Todo.classType,
        where: Todo.ID.eq(todoId),
      );

      if (todos.isEmpty) throw Exception('Todo not found');
      
      final todo = todos.first;
      
      // Calculate efficiency bonus
      final efficiencyBonus = _calculateEfficiencyBonus(
        estimatedTime: todo.estimatedTime ?? 30,
        actualTime: actualTime,
      );

      final totalXP = todo.xpReward + efficiencyBonus;

      final updatedTodo = todo.copyWith(
        completed: true,
        completedAt: TemporalDateTime.now(),
        actualTime: actualTime,
      );

      await Amplify.DataStore.save(updatedTodo);

      return TodoCompletionResult(
        todo: updatedTodo,
        baseXP: todo.xpReward,
        efficiencyBonus: efficiencyBonus,
        totalXP: totalXP,
      );
    } catch (e) {
      safePrint('Error completing todo: $e');
      rethrow;
    }
  }

  // Delete todo
  Future<void> deleteTodo(String todoId) async {
    try {
      final todos = await Amplify.DataStore.query(
        Todo.classType,
        where: Todo.ID.eq(todoId),
      );

      if (todos.isEmpty) throw Exception('Todo not found');
      
      await Amplify.DataStore.delete(todos.first);
    } catch (e) {
      safePrint('Error deleting todo: $e');
      rethrow;
    }
  }

  // Get user's todos
  Future<List<Todo>> getUserTodos({
    required String userId,
    bool? completed,
    Priority? priority,
    String? subject,
    DateTime? dueBefore,
    int? limit,
  }) async {
    try {
      var query = Todo.USER_ID.eq(userId);
      
      if (completed != null) {
        query = query.and(Todo.COMPLETED.eq(completed));
      }
      
      if (priority != null) {
        query = query.and(Todo.PRIORITY.eq(priority));
      }
      
      if (subject != null) {
        query = query.and(Todo.SUBJECT.eq(subject));
      }
      
      if (dueBefore != null) {
        query = query.and(Todo.DUE_DATE.le(
          TemporalDateTime(dueBefore),
        ));
      }

      final todos = await Amplify.DataStore.query(
        Todo.classType,
        where: query,
        sortBy: [
          Todo.COMPLETED.ascending(),
          Todo.PRIORITY.descending(),
          Todo.DUE_DATE.ascending(),
        ],
        pagination: limit != null ? QueryPagination(limit: limit) : null,
      );

      return todos;
    } catch (e) {
      safePrint('Error getting user todos: $e');
      return [];
    }
  }

  // Get today's todos
  Future<List<Todo>> getTodaysTodos(String userId) async {
    try {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final todos = await getUserTodos(
        userId: userId,
        completed: false,
        dueBefore: tomorrow,
      );

      // Sort by priority and estimated time
      todos.sort((a, b) {
        // First by priority
        final priorityCompare = _priorityValue(b.priority)
            .compareTo(_priorityValue(a.priority));
        if (priorityCompare != 0) return priorityCompare;
        
        // Then by estimated time (shorter tasks first)
        final aTime = a.estimatedTime ?? 30;
        final bTime = b.estimatedTime ?? 30;
        return aTime.compareTo(bTime);
      });

      return todos;
    } catch (e) {
      safePrint('Error getting today\'s todos: $e');
      return [];
    }
  }

  // Get AI suggested todos
  Future<List<PlannedTask>> getAISuggestedTodos({
    required String userId,
    required UserContext context,
  }) async {
    try {
      final plan = await _aiService.generateStudyPlan(
        userPrompt: 'Generate daily study tasks based on my learning patterns',
        context: context,
      );

      return plan.tasks;
    } catch (e) {
      safePrint('Error getting AI suggested todos: $e');
      return [];
    }
  }

  // Subscribe to todo updates
  Stream<List<Todo>> subscribeToUserTodos(String userId) {
    return Amplify.DataStore.observeQuery(
      Todo.classType,
      where: Todo.USER_ID.eq(userId),
      sortBy: [
        Todo.COMPLETED.ascending(),
        Todo.PRIORITY.descending(),
        Todo.DUE_DATE.ascending(),
      ],
    ).map((event) => event.items);
  }

  // Get todo statistics
  Future<TodoStatistics> getTodoStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final todos = await Amplify.DataStore.query(
        Todo.classType,
        where: Todo.USER_ID.eq(userId)
            .and(Todo.CREATED_AT.between(
              TemporalDateTime(startDate),
              TemporalDateTime(endDate),
            )),
      );

      int totalTodos = todos.length;
      int completedTodos = 0;
      int overdueTodos = 0;
      int totalEstimatedTime = 0;
      int totalActualTime = 0;
      Map<String, int> todosBySubject = {};
      Map<Priority, int> todosByPriority = {};

      final now = DateTime.now();

      for (final todo in todos) {
        if (todo.completed) {
          completedTodos++;
          if (todo.actualTime != null) {
            totalActualTime += todo.actualTime!;
          }
        } else if (todo.dueDate != null && 
                   todo.dueDate!.toDateTime().isBefore(now)) {
          overdueTodos++;
        }

        if (todo.estimatedTime != null) {
          totalEstimatedTime += todo.estimatedTime!;
        }

        // Count by subject
        if (todo.subject != null) {
          todosBySubject[todo.subject!] = 
              (todosBySubject[todo.subject!] ?? 0) + 1;
        }

        // Count by priority
        todosByPriority[todo.priority] = 
            (todosByPriority[todo.priority] ?? 0) + 1;
      }

      final completionRate = totalTodos > 0 
          ? (completedTodos / totalTodos) * 100 
          : 0.0;

      final timeAccuracy = totalEstimatedTime > 0 && totalActualTime > 0
          ? (totalActualTime / totalEstimatedTime) * 100
          : 100.0;

      return TodoStatistics(
        totalTodos: totalTodos,
        completedTodos: completedTodos,
        overdueTodos: overdueTodos,
        completionRate: completionRate,
        totalEstimatedTime: totalEstimatedTime,
        totalActualTime: totalActualTime,
        timeAccuracy: timeAccuracy,
        todosBySubject: todosBySubject,
        todosByPriority: todosByPriority,
      );
    } catch (e) {
      safePrint('Error getting todo statistics: $e');
      return TodoStatistics.empty();
    }
  }

  // Helper methods
  int _calculateXPReward({
    required int estimatedTime,
    required Priority priority,
  }) {
    // Base XP based on time
    int baseXP = (estimatedTime / 10).round() * 5; // 5 XP per 10 minutes
    
    // Priority multiplier
    double multiplier = 1.0;
    switch (priority) {
      case Priority.HIGH:
        multiplier = 1.5;
        break;
      case Priority.MEDIUM:
        multiplier = 1.2;
        break;
      case Priority.LOW:
        multiplier = 1.0;
        break;
    }
    
    return (baseXP * multiplier).round().clamp(10, 100);
  }

  int _calculateEfficiencyBonus({
    required int estimatedTime,
    required int actualTime,
  }) {
    if (actualTime <= 0) return 0;
    
    final efficiency = estimatedTime / actualTime;
    
    if (efficiency >= 1.5) {
      // Completed 50% faster than estimated
      return 20;
    } else if (efficiency >= 1.2) {
      // Completed 20% faster than estimated
      return 10;
    } else if (efficiency >= 0.8) {
      // Completed within reasonable time
      return 5;
    } else {
      // Took longer than estimated
      return 0;
    }
  }

  int _priorityValue(Priority priority) {
    switch (priority) {
      case Priority.HIGH:
        return 3;
      case Priority.MEDIUM:
        return 2;
      case Priority.LOW:
        return 1;
    }
  }
}

// Result classes
class TodoCompletionResult {
  final Todo todo;
  final int baseXP;
  final int efficiencyBonus;
  final int totalXP;

  TodoCompletionResult({
    required this.todo,
    required this.baseXP,
    required this.efficiencyBonus,
    required this.totalXP,
  });
}

class TodoStatistics {
  final int totalTodos;
  final int completedTodos;
  final int overdueTodos;
  final double completionRate;
  final int totalEstimatedTime;
  final int totalActualTime;
  final double timeAccuracy;
  final Map<String, int> todosBySubject;
  final Map<Priority, int> todosByPriority;

  TodoStatistics({
    required this.totalTodos,
    required this.completedTodos,
    required this.overdueTodos,
    required this.completionRate,
    required this.totalEstimatedTime,
    required this.totalActualTime,
    required this.timeAccuracy,
    required this.todosBySubject,
    required this.todosByPriority,
  });

  factory TodoStatistics.empty() {
    return TodoStatistics(
      totalTodos: 0,
      completedTodos: 0,
      overdueTodos: 0,
      completionRate: 0.0,
      totalEstimatedTime: 0,
      totalActualTime: 0,
      timeAccuracy: 100.0,
      todosBySubject: {},
      todosByPriority: {},
    );
  }
}