import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../services/local_storage_service.dart';

// Todo Model (Local version for UI)
class TodoItem {
  final String id;
  final String title;
  final String subject;
  final Duration? estimatedTime;
  final Duration actualTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final int xpReward;
  final bool isActive;
  
  TodoItem({
    required this.id,
    required this.title,
    required this.subject,
    this.estimatedTime,
    this.actualTime = const Duration(),
    this.isCompleted = false,
    this.completedAt,
    this.xpReward = 10,
    this.isActive = false,
  });
  
  TodoItem copyWith({
    String? id,
    String? title,
    String? subject,
    Duration? estimatedTime,
    Duration? actualTime,
    bool? isCompleted,
    DateTime? completedAt,
    int? xpReward,
    bool? isActive,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTime: actualTime ?? this.actualTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      xpReward: xpReward ?? this.xpReward,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Todo List Provider
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<TodoItem>>((ref) {
  return TodoListNotifier();
});

// Active Todo Timer Provider
final activeTodoTimerProvider = StateNotifierProvider<ActiveTodoTimer, ActiveTodoState>((ref) {
  return ActiveTodoTimer(ref);
});

class TodoListNotifier extends StateNotifier<List<TodoItem>> {
  TodoListNotifier() : super([]) {
    _loadFromStorage();
  }
  
  void _loadFromStorage() {
    final savedTodos = LocalStorageService.loadTodoItems();
    if (savedTodos.isNotEmpty) {
      state = savedTodos;
    } else {
      // Initialize with sample todos if no saved data
      state = [
        TodoItem(
      id: '1',
      title: 'Complete Math Chapter 5',
      subject: 'Math',
      estimatedTime: const Duration(minutes: 45),
      xpReward: 50,
    ),
    TodoItem(
      id: '2', 
      title: 'Read English Literature pp. 120-150',
      subject: 'English',
      estimatedTime: const Duration(minutes: 30),
      xpReward: 35,
    ),
    TodoItem(
      id: '3',
      title: 'Physics Problem Set',
      subject: 'Science',
      estimatedTime: const Duration(hours: 1),
      xpReward: 60,
    ),
  ];
      _saveToStorage();
    }
  }
  
  void addTodo(TodoItem todo) {
    state = [...state, todo];
    _saveToStorage();
  }
  
  void updateTodo(String id, TodoItem Function(TodoItem) update) {
    state = state.map((todo) {
      if (todo.id == id) {
        return update(todo);
      }
      return todo;
    }).toList();
    _saveToStorage();
  }
  
  void _saveToStorage() {
    LocalStorageService.saveTodoItems(state);
  }
  
  void deleteTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
    _saveToStorage();
  }
  
  void completeTodo(String id) {
    updateTodo(id, (todo) => todo.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    ));
  }
}

// Active Todo Timer State
class ActiveTodoState {
  final TodoItem? activeTodo;
  final Duration elapsedTime;
  final bool isRunning;
  final bool isPaused;
  
  ActiveTodoState({
    this.activeTodo,
    this.elapsedTime = const Duration(),
    this.isRunning = false,
    this.isPaused = false,
  });
  
  ActiveTodoState copyWith({
    TodoItem? activeTodo,
    Duration? elapsedTime,
    bool? isRunning,
    bool? isPaused,
  }) {
    return ActiveTodoState(
      activeTodo: activeTodo ?? this.activeTodo,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class ActiveTodoTimer extends StateNotifier<ActiveTodoState> {
  final Ref ref;
  Timer? _timer;
  
  ActiveTodoTimer(this.ref) : super(ActiveTodoState());
  
  void startTodo(TodoItem todo) {
    // Mark todo as active
    ref.read(todoListProvider.notifier).updateTodo(
      todo.id,
      (t) => t.copyWith(isActive: true),
    );
    
    state = state.copyWith(
      activeTodo: todo,
      isRunning: true,
      isPaused: false,
      elapsedTime: const Duration(),
    );
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        elapsedTime: state.elapsedTime + const Duration(seconds: 1),
      );
    });
  }
  
  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isPaused: true, isRunning: false);
  }
  
  void resumeTimer() {
    state = state.copyWith(isPaused: false, isRunning: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        elapsedTime: state.elapsedTime + const Duration(seconds: 1),
      );
    });
  }
  
  void completeTodo() {
    _timer?.cancel();
    
    if (state.activeTodo != null) {
      // Update todo with actual time and mark as completed
      ref.read(todoListProvider.notifier).updateTodo(
        state.activeTodo!.id,
        (todo) => todo.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          actualTime: state.elapsedTime,
          isActive: false,
        ),
      );
      
      // Calculate XP bonus based on time efficiency
      _calculateXPBonus();
    }
    
    state = ActiveTodoState();
  }
  
  void cancelTodo() {
    _timer?.cancel();
    
    if (state.activeTodo != null) {
      // Update todo to save progress but not complete
      ref.read(todoListProvider.notifier).updateTodo(
        state.activeTodo!.id,
        (todo) => todo.copyWith(
          actualTime: state.elapsedTime,
          isActive: false,
        ),
      );
    }
    
    state = ActiveTodoState();
  }
  
  void _calculateXPBonus() {
    if (state.activeTodo == null) return;
    
    final todo = state.activeTodo!;
    final studyMinutes = state.elapsedTime.inMinutes;
    
    // Add XP to user stats
    ref.read(userStatsProvider.notifier).addXP(
      todo.xpReward,
      subject: todo.subject,
      studyMinutes: studyMinutes,
    );
    
    // Increment completed quests
    ref.read(userStatsProvider.notifier).incrementCompletedQuests();
    
    // Update daily missions
    ref.read(dailyMissionsProvider.notifier).updateMissionProgress('daily_study_time', studyMinutes);
    ref.read(dailyMissionsProvider.notifier).updateMissionProgress('complete_quests', 1);
    
    // Morning study bonus (before 10 AM)
    if (DateTime.now().hour < 10) {
      ref.read(dailyMissionsProvider.notifier).updateMissionProgress('morning_study', 1);
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Main Todo Screen
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final activeTimer = ref.watch(activeTodoTimerProvider);
    
    // If there's an active todo, show timer screen
    if (activeTimer.activeTodo != null) {
      return _ActiveTodoScreen(
        todo: activeTimer.activeTodo!,
        elapsedTime: activeTimer.elapsedTime,
        isRunning: activeTimer.isRunning,
        isPaused: activeTimer.isPaused,
      );
    }
    
    // Otherwise show todo list
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddTodoDialog(context, ref);
            },
          ),
        ],
      ),
      body: todos.isEmpty
        ? _EmptyState()
        : ListView.builder(
            padding: AppSpacing.paddingMD,
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return _TodoCard(todo: todo);
            },
          ),
    );
  }
}

// Todo Card Widget
class _TodoCard extends ConsumerWidget {
  final TodoItem todo;
  
  const _TodoCard({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: todo.isCompleted ? null : () {
          ref.read(activeTodoTimerProvider.notifier).startTodo(todo);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Subject Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getSubjectColor(todo.subject).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSubjectIcon(todo.subject),
                  color: _getSubjectColor(todo.subject),
                ),
              ),
              
              AppSpacing.horizontalGapMD,
              
              // Todo Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: AppTypography.titleMedium.copyWith(
                        decoration: todo.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                      ),
                    ),
                    AppSpacing.verticalGapXS,
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(todo.estimatedTime ?? const Duration()),
                          style: AppTypography.caption,
                        ),
                        AppSpacing.horizontalGapMD,
                        Icon(
                          Icons.bolt,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${todo.xpReward} XP',
                          style: AppTypography.caption.copyWith(
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action Button
              if (!todo.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'START',
                        style: AppTypography.button.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2, end: 0);
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math': return Colors.blue;
      case 'English': return Colors.purple;
      case 'Science': return Colors.green;
      case 'History': return Colors.orange;
      default: return Colors.grey;
    }
  }
  
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Math': return Icons.calculate;
      case 'English': return Icons.menu_book;
      case 'Science': return Icons.science;
      case 'History': return Icons.history_edu;
      default: return Icons.school;
    }
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

// Active Todo Timer Screen
class _ActiveTodoScreen extends ConsumerWidget {
  final TodoItem todo;
  final Duration elapsedTime;
  final bool isRunning;
  final bool isPaused;
  
  const _ActiveTodoScreen({
    required this.todo,
    required this.elapsedTime,
    required this.isRunning,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timerNotifier = ref.read(activeTodoTimerProvider.notifier);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Show confirmation dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Quest?'),
                content: const Text('Your progress will be saved but the quest won\'t be completed.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Keep Going'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      timerNotifier.cancelTodo();
                    },
                    child: const Text('Cancel Quest'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quest Title
            Padding(
              padding: AppSpacing.paddingXL,
              child: Column(
                children: [
                  Text(
                    'QUEST IN PROGRESS',
                    style: AppTypography.overline.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  AppSpacing.verticalGapMD,
                  Text(
                    todo.title,
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalGapSM,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(todo.subject).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      todo.subject,
                      style: AppTypography.caption.copyWith(
                        color: _getSubjectColor(todo.subject),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Timer Display
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress Ring
                  if (todo.estimatedTime != null)
                    SizedBox(
                      width: 230,
                      height: 230,
                      child: CircularProgressIndicator(
                        value: elapsedTime.inSeconds / todo.estimatedTime!.inSeconds,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          elapsedTime > todo.estimatedTime!
                            ? Colors.orange
                            : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  
                  // Time Display
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(elapsedTime),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (todo.estimatedTime != null)
                        Text(
                          'Est: ${_formatDuration(todo.estimatedTime!)}',
                          style: AppTypography.caption,
                        ),
                    ],
                  ),
                ],
              ),
            ).animate()
              .scale(duration: 300.ms, curve: Curves.elasticOut)
              .then()
              .shimmer(duration: 1500.ms, delay: 1000.ms),
            
            AppSpacing.verticalGapXL,
            
            // XP Reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${todo.xpReward} XP',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            AppSpacing.verticalGapXL,
            
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pause/Resume Button
                if (isRunning || isPaused)
                  _ControlButton(
                    icon: isPaused ? Icons.play_arrow : Icons.pause,
                    label: isPaused ? 'Resume' : 'Pause',
                    onPressed: () {
                      if (isPaused) {
                        timerNotifier.resumeTimer();
                      } else {
                        timerNotifier.pauseTimer();
                      }
                    },
                    color: Colors.orange,
                  ),
                
                AppSpacing.horizontalGapMD,
                
                // Complete Button
                _ControlButton(
                  icon: Icons.check,
                  label: 'Complete',
                  onPressed: () {
                    timerNotifier.completeTodo();
                    // TODO: Show completion animation/dialog
                  },
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math': return Colors.blue;
      case 'English': return Colors.purple;
      case 'Science': return Colors.green;
      case 'History': return Colors.orange;
      default: return Colors.grey;
    }
  }
  
  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

// Control Button Widget
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Empty State
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey.shade300,
          ),
          AppSpacing.verticalGapMD,
          Text(
            'No Quests Yet',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          AppSpacing.verticalGapSM,
          Text(
            'Add your first quest to start your journey!',
            style: AppTypography.body.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// Add Todo Dialog
void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => const _AddTodoDialog(),
  );
}

class _AddTodoDialog extends ConsumerStatefulWidget {
  const _AddTodoDialog();

  @override
  ConsumerState<_AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<_AddTodoDialog> {
  final _titleController = TextEditingController();
  String _selectedSubject = 'Math';
  int _estimatedMinutes = 30;
  
  final List<String> _subjects = ['Math', 'English', 'Science', 'History', 'Other'];
  final List<int> _timeOptions = [15, 30, 45, 60, 90, 120];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Quest'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Input
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Quest Title',
              hintText: 'What do you want to accomplish?',
            ),
            autofocus: true,
          ),
          
          AppSpacing.verticalGapMD,
          
          // Subject Selection
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Subject',
            ),
            items: _subjects.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Row(
                  children: [
                    Icon(
                      _getSubjectIcon(subject),
                      color: _getSubjectColor(subject),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(subject),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubject = value!;
              });
            },
          ),
          
          AppSpacing.verticalGapMD,
          
          // Estimated Time
          DropdownButtonFormField<int>(
            value: _estimatedMinutes,
            decoration: const InputDecoration(
              labelText: 'Estimated Time',
            ),
            items: _timeOptions.map((minutes) {
              return DropdownMenuItem(
                value: minutes,
                child: Text('${minutes}m'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _estimatedMinutes = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.trim().isEmpty ? null : () {
            final newTodo = TodoItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              subject: _selectedSubject,
              estimatedTime: Duration(minutes: _estimatedMinutes),
              xpReward: _calculateXPReward(_estimatedMinutes),
            );
            
            ref.read(todoListProvider.notifier).addTodo(newTodo);
            Navigator.of(context).pop();
          },
          child: const Text('Add Quest'),
        ),
      ],
    );
  }
  
  int _calculateXPReward(int minutes) {
    // Base XP: 1 per minute + bonus for longer tasks
    int baseXP = minutes;
    if (minutes >= 60) baseXP += 20; // 1 hour bonus
    if (minutes >= 120) baseXP += 30; // 2 hour bonus
    return baseXP;
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math': return Colors.blue;
      case 'English': return Colors.purple;
      case 'Science': return Colors.green;
      case 'History': return Colors.orange;
      default: return Colors.grey;
    }
  }
  
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Math': return Icons.calculate;
      case 'English': return Icons.book;
      case 'Science': return Icons.science;
      case 'History': return Icons.history_edu;
      default: return Icons.assignment;
    }
  }
}