import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../models/todo_item.dart';

// Timer mode enum
enum TimerMode { stopwatch, timer, pomodoro }

// Timer state provider
final timerStateProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

class TimerState {
  final Duration duration;
  final bool isRunning;
  final TimerMode mode;
  final TodoItem? selectedTodo;
  final int pomodoroCount;
  final bool isBreak;
  final Map<String, dynamic>? sessionSettings;
  
  TimerState({
    required this.duration,
    required this.isRunning,
    required this.mode,
    this.selectedTodo,
    required this.pomodoroCount,
    required this.isBreak,
    this.sessionSettings,
  });
  
  TimerState copyWith({
    Duration? duration,
    bool? isRunning,
    TimerMode? mode,
    TodoItem? selectedTodo,
    int? pomodoroCount,
    bool? isBreak,
    Map<String, dynamic>? sessionSettings,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      isRunning: isRunning ?? this.isRunning,
      mode: mode ?? this.mode,
      selectedTodo: selectedTodo ?? this.selectedTodo,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      isBreak: isBreak ?? this.isBreak,
      sessionSettings: sessionSettings ?? this.sessionSettings,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref _ref;
  DateTime? _sessionStartTime;
  
  TimerNotifier(this._ref) : super(TimerState(
    duration: const Duration(),
    isRunning: false,
    mode: TimerMode.stopwatch,
    pomodoroCount: 0,
    isBreak: false,
  ));
  
  void setMode(TimerMode mode) {
    stop();
    state = state.copyWith(
      mode: mode,
      duration: mode == TimerMode.pomodoro 
        ? Duration(minutes: state.sessionSettings?['focusMinutes'] ?? 25)
        : const Duration(),
      pomodoroCount: 0,
      isBreak: false,
    );
  }
  
  void selectTodo(TodoItem? todo) {
    if (todo != null && todo.sessionSettings != null) {
      // Todo에 커스텀 세션 설정이 있으면 적용
      state = state.copyWith(
        selectedTodo: todo,
        sessionSettings: todo.sessionSettings,
        mode: TimerMode.pomodoro,
        duration: Duration(minutes: todo.sessionSettings!['focusMinutes'] ?? 25),
      );
    } else {
      state = state.copyWith(selectedTodo: todo);
    }
  }
  
  void start() {
    if (state.isRunning) return;
    
    state = state.copyWith(isRunning: true);
    _sessionStartTime = DateTime.now();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.mode == TimerMode.stopwatch) {
        state = state.copyWith(
          duration: state.duration + const Duration(seconds: 1),
        );
      } else if (state.mode == TimerMode.timer || state.mode == TimerMode.pomodoro) {
        if (state.duration.inSeconds > 0) {
          state = state.copyWith(
            duration: state.duration - const Duration(seconds: 1),
          );
        } else {
          // Timer completed
          if (state.mode == TimerMode.pomodoro) {
            _handlePomodoroComplete();
          } else {
            stop();
          }
        }
      }
    });
  }
  
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _updateTodoTime();
  }
  
  void stop() {
    _timer?.cancel();
    _updateTodoTime();
    
    state = state.copyWith(
      isRunning: false,
      duration: state.mode == TimerMode.pomodoro
        ? Duration(minutes: state.sessionSettings?['focusMinutes'] ?? 25)
        : const Duration(),
    );
  }
  
  void _updateTodoTime() {
    if (state.selectedTodo != null && _sessionStartTime != null) {
      final sessionMinutes = DateTime.now().difference(_sessionStartTime!).inMinutes;
      if (sessionMinutes > 0) {
        _ref.read(todoItemsProvider.notifier).updateActualMinutes(
          state.selectedTodo!.id,
          sessionMinutes,
        );
      }
    }
  }
  
  void setTimerDuration(Duration duration) {
    if (state.mode == TimerMode.timer) {
      state = state.copyWith(duration: duration);
    }
  }
  
  void _handlePomodoroComplete() {
    pause();
    
    // Play notification sound
    SystemSound.play(SystemSoundType.click);
    
    final settings = state.sessionSettings ?? {};
    final autoStartBreak = settings['autoStartBreak'] ?? true;
    final autoStartFocus = settings['autoStartFocus'] ?? false;
    
    if (state.isBreak) {
      // Break completed, start work session
      state = state.copyWith(
        isBreak: false,
        duration: Duration(minutes: settings['focusMinutes'] ?? 25),
        pomodoroCount: state.pomodoroCount + 1,
      );
      
      // Show break completion notification
      _showCompletionNotification('휴식 완료!', '집중 시간을 시작하세요');
      
      if (autoStartFocus) {
        Future.delayed(const Duration(seconds: 2), () => start());
      }
    } else {
      // Work completed, start break
      final sessions = settings['sessions'] ?? 4;
      final breakMinutes = settings['breakMinutes'] ?? 5;
      final isLongBreak = state.pomodoroCount % sessions == sessions - 1;
      final breakDuration = Duration(minutes: isLongBreak ? breakMinutes * 3 : breakMinutes);
      
      state = state.copyWith(
        isBreak: true,
        duration: breakDuration,
      );
      
      // Give XP reward for completing focus session
      final focusMinutes = settings['focusMinutes'] ?? 25;
      final xpReward = focusMinutes; // 1 XP per minute
      
      final category = state.selectedTodo != null
          ? _ref.read(todoCategoryProvider.notifier).getCategoryById(state.selectedTodo!.categoryId)
          : null;
      
      _ref.read(userStatsProvider.notifier).addXP(
        xpReward,
        subject: category?.name ?? 'Focus Session',
        studyMinutes: focusMinutes,
      );
      
      // Show focus completion notification
      _showCompletionNotification(
        '집중 세션 완료! (+${xpReward} XP)',
        isLongBreak ? '긴 휴식을 취하세요 (${breakDuration.inMinutes}분)' : '짧은 휴식을 취하세요 (${breakDuration.inMinutes}분)',
      );
      
      if (autoStartBreak) {
        Future.delayed(const Duration(seconds: 2), () => start());
      }
    }
  }
  
  void _showCompletionNotification(String title, String message) {
    // This would typically show a system notification
    // For now, we'll just print to console
    print('🔔 $title: $message');
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class TimerScreenEnhanced extends ConsumerStatefulWidget {
  final TodoItem? initialTodo;
  
  const TimerScreenEnhanced({super.key, this.initialTodo});

  @override
  ConsumerState<TimerScreenEnhanced> createState() => _TimerScreenEnhancedState();
}

class _TimerScreenEnhancedState extends ConsumerState<TimerScreenEnhanced> {
  @override
  void initState() {
    super.initState();
    // 초기 Todo 설정
    if (widget.initialTodo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timerStateProvider.notifier).selectTodo(widget.initialTodo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateProvider);
    final timerNotifier = ref.read(timerStateProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          children: [
            // Mode Selector
            _ModeSelector(
              selectedMode: timerState.mode,
              onModeChanged: timerNotifier.setMode,
            ),
            
            AppSpacing.verticalGapXL,
            
            // Todo Selector
            _TodoSelector(
              selectedTodo: timerState.selectedTodo,
              onTodoChanged: timerNotifier.selectTodo,
            ),
            
            AppSpacing.verticalGapXL,
            
            // Timer Display
            _TimerDisplay(
              duration: timerState.duration,
              mode: timerState.mode,
              isBreak: timerState.isBreak,
            ),
            
            AppSpacing.verticalGapXL,
            
            // Timer Preset (for timer mode)
            if (timerState.mode == TimerMode.timer && !timerState.isRunning)
              _TimerPresets(
                onDurationSelected: timerNotifier.setTimerDuration,
              ),
            
            // Pomodoro Info
            if (timerState.mode == TimerMode.pomodoro)
              _PomodoroInfo(
                pomodoroCount: timerState.pomodoroCount,
                isBreak: timerState.isBreak,
                sessionSettings: timerState.sessionSettings,
              ),
            
            AppSpacing.verticalGapXL,
            
            // Control Buttons
            _ControlButtons(
              isRunning: timerState.isRunning,
              onStart: timerNotifier.start,
              onPause: timerNotifier.pause,
              onStop: timerNotifier.stop,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final TimerMode selectedMode;
  final Function(TimerMode) onModeChanged;
  
  const _ModeSelector({
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimerMode>(
      segments: const [
        ButtonSegment(
          value: TimerMode.stopwatch,
          label: Text('스톱워치'),
          icon: Icon(Icons.timer),
        ),
        ButtonSegment(
          value: TimerMode.timer,
          label: Text('타이머'),
          icon: Icon(Icons.hourglass_empty),
        ),
        ButtonSegment(
          value: TimerMode.pomodoro,
          label: Text('뽀모도로'),
          icon: Icon(Icons.av_timer),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (Set<TimerMode> newSelection) {
        onModeChanged(newSelection.first);
      },
    );
  }
}

class _TodoSelector extends ConsumerWidget {
  final TodoItem? selectedTodo;
  final Function(TodoItem?) onTodoChanged;
  
  const _TodoSelector({
    required this.selectedTodo,
    required this.onTodoChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoItemsProvider);
    final categories = ref.watch(todoCategoryProvider);
    final incompleteTodos = todos.where((t) => !t.isCompleted).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('할 일 선택', style: AppTypography.titleMedium),
            const Spacer(),
            if (selectedTodo != null)
              TextButton(
                onPressed: () => onTodoChanged(null),
                child: const Text('선택 해제'),
              ),
          ],
        ),
        AppSpacing.verticalGapSM,
        if (incompleteTodos.isEmpty)
          Card(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: Text(
                      '진행 중인 할 일이 없습니다. Todo 탭에서 추가해주세요.',
                      style: AppTypography.body.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (selectedTodo == null)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: incompleteTodos.length,
              itemBuilder: (context, index) {
                final todo = incompleteTodos[index];
                final category = categories.firstWhere(
                  (c) => c.id == todo.categoryId,
                  orElse: () => categories.last,
                );
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => onTodoChanged(todo),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 200,
                      padding: AppSpacing.paddingMD,
                      decoration: BoxDecoration(
                        border: Border.all(color: category.color.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(category.icon, size: 16, color: category.color),
                              AppSpacing.horizontalGapSM,
                              Text(
                                category.name,
                                style: AppTypography.caption.copyWith(
                                  color: category.color,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalGapSM,
                          Text(
                            todo.title,
                            style: AppTypography.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${todo.estimatedMinutes}분',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Card(
            color: selectedTodo!.sessionSettings != null
                ? Colors.purple.withOpacity(0.1)
                : null,
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Row(
                children: [
                  if (categories.isNotEmpty) ...[
                    Icon(
                      categories.firstWhere(
                        (c) => c.id == selectedTodo!.categoryId,
                        orElse: () => categories.last,
                      ).icon,
                      color: categories.firstWhere(
                        (c) => c.id == selectedTodo!.categoryId,
                        orElse: () => categories.last,
                      ).color,
                    ),
                    AppSpacing.horizontalGapMD,
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTodo!.title,
                          style: AppTypography.titleMedium,
                        ),
                        if (selectedTodo!.description != null) ...[
                          AppSpacing.verticalGapXS,
                          Text(
                            selectedTodo!.description!,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (selectedTodo!.sessionSettings != null)
                    Chip(
                      label: const Text('커스텀 설정'),
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => onTodoChanged(null),
                    tooltip: '선택 해제',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final Duration duration;
  final TimerMode mode;
  final bool isBreak;
  
  const _TimerDisplay({
    required this.duration,
    required this.mode,
    required this.isBreak,
  });

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    String timeString;
    if (hours > 0) {
      timeString = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    
    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBreak 
            ? [Colors.green.shade400, Colors.green.shade600]
            : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            timeString,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          if (mode == TimerMode.pomodoro && isBreak)
            const Text(
              '휴식 시간',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimerPresets extends StatelessWidget {
  final Function(Duration) onDurationSelected;
  
  const _TimerPresets({required this.onDurationSelected});

  @override
  Widget build(BuildContext context) {
    final presets = [
      const Duration(minutes: 5),
      const Duration(minutes: 10),
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(hours: 1),
    ];
    
    return Wrap(
      spacing: 8,
      children: presets.map((duration) {
        final minutes = duration.inMinutes;
        final label = minutes < 60 ? '$minutes분' : '${duration.inHours}시간';
        
        return ActionChip(
          label: Text(label),
          onPressed: () => onDurationSelected(duration),
        );
      }).toList(),
    );
  }
}

class _PomodoroInfo extends StatelessWidget {
  final int pomodoroCount;
  final bool isBreak;
  final Map<String, dynamic>? sessionSettings;
  
  const _PomodoroInfo({
    required this.pomodoroCount,
    required this.isBreak,
    this.sessionSettings,
  });

  @override
  Widget build(BuildContext context) {
    final settings = sessionSettings ?? {};
    final sessions = settings['sessions'] ?? 4;
    final focusMinutes = settings['focusMinutes'] ?? 25;
    final breakMinutes = settings['breakMinutes'] ?? 5;
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange),
                    Text('$pomodoroCount/$sessions', style: AppTypography.titleLarge),
                    Text('세션', style: AppTypography.caption),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      isBreak ? Icons.coffee : Icons.work,
                      color: isBreak ? Colors.green : Colors.blue,
                    ),
                    Text(
                      isBreak ? '휴식' : '집중',
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            if (sessionSettings != null) ...[
              const Divider(),
              Text(
                '집중 ${focusMinutes}분 | 휴식 ${breakMinutes}분',
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ControlButtons extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  
  const _ControlButtons({
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isRunning)
          CustomButton(
            text: '시작',
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            width: 150,
          )
        else
          CustomButton(
            text: '일시정지',
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            width: 150,
            color: Colors.orange,
          ),
        
        AppSpacing.horizontalGapMD,
        
        CustomButton(
          text: '정지',
          onPressed: onStop,
          icon: const Icon(Icons.stop),
          width: 150,
          isOutlined: true,
        ),
      ],
    );
  }
}