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
  final String subject;
  final int pomodoroCount;
  final bool isBreak;
  
  TimerState({
    required this.duration,
    required this.isRunning,
    required this.mode,
    required this.subject,
    required this.pomodoroCount,
    required this.isBreak,
  });
  
  TimerState copyWith({
    Duration? duration,
    bool? isRunning,
    TimerMode? mode,
    String? subject,
    int? pomodoroCount,
    bool? isBreak,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      isRunning: isRunning ?? this.isRunning,
      mode: mode ?? this.mode,
      subject: subject ?? this.subject,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      isBreak: isBreak ?? this.isBreak,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref _ref;
  
  TimerNotifier(this._ref) : super(TimerState(
    duration: const Duration(),
    isRunning: false,
    mode: TimerMode.stopwatch,
    subject: '',
    pomodoroCount: 0,
    isBreak: false,
  ));
  
  void setMode(TimerMode mode) {
    stop();
    state = state.copyWith(
      mode: mode,
      duration: mode == TimerMode.pomodoro 
        ? const Duration(minutes: 25)
        : const Duration(),
      pomodoroCount: 0,
      isBreak: false,
    );
  }
  
  void setSubject(String subject) {
    state = state.copyWith(subject: subject);
  }
  
  void start() {
    if (state.isRunning) return;
    
    state = state.copyWith(isRunning: true);
    
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
  }
  
  void stop() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      duration: state.mode == TimerMode.pomodoro
        ? const Duration(minutes: 25)
        : const Duration(),
    );
  }
  
  void setTimerDuration(Duration duration) {
    if (state.mode == TimerMode.timer) {
      state = state.copyWith(duration: duration);
    }
  }
  
  void _handlePomodoroComplete() {
    pause();
    
    // Play notification sound
    SystemSound.play(SystemSound.alert);
    
    if (state.isBreak) {
      // Break completed, start work session
      state = state.copyWith(
        isBreak: false,
        duration: const Duration(minutes: 25),
        pomodoroCount: state.pomodoroCount + 1,
      );
      
      // Show break completion notification
      _showCompletionNotification('휴식 완료!', '집중 시간을 시작하세요');
    } else {
      // Work completed, start break
      final breakDuration = state.pomodoroCount % 4 == 3
        ? const Duration(minutes: 15) // Long break
        : const Duration(minutes: 5);  // Short break
      
      state = state.copyWith(
        isBreak: true,
        duration: breakDuration,
      );
      
      // Give XP reward for completing focus session
      final xpReward = 25; // 25 XP for 25 minutes of focused work
      _ref.read(userStatsProvider.notifier).addXP(
        xpReward,
        subject: state.subject.isNotEmpty ? state.subject : 'Focus Session',
        studyMinutes: 25,
      );
      
      // Show focus completion notification
      final isLongBreak = state.pomodoroCount % 4 == 3;
      _showCompletionNotification(
        '집중 세션 완료! (+${xpReward} XP)',
        isLongBreak ? '긴 휴식을 취하세요 (15분)' : '짧은 휴식을 취하세요 (5분)',
      );
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

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            
            // Subject Selector
            _SubjectSelector(
              selectedSubject: timerState.subject,
              onSubjectChanged: timerNotifier.setSubject,
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
          label: Text('Stopwatch'),
          icon: Icon(Icons.timer),
        ),
        ButtonSegment(
          value: TimerMode.timer,
          label: Text('Timer'),
          icon: Icon(Icons.hourglass_empty),
        ),
        ButtonSegment(
          value: TimerMode.pomodoro,
          label: Text('Pomodoro'),
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

class _SubjectSelector extends StatelessWidget {
  final String selectedSubject;
  final Function(String) onSubjectChanged;
  
  const _SubjectSelector({
    required this.selectedSubject,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = ['Math', 'English', 'Science', 'History', 'Other'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject', style: AppTypography.titleMedium),
        AppSpacing.verticalGapSM,
        Wrap(
          spacing: 8,
          children: subjects.map((subject) {
            final isSelected = selectedSubject == subject;
            return ChoiceChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSubjectChanged(subject);
                }
              },
            );
          }).toList(),
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
              'BREAK TIME',
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
        final label = minutes < 60 ? '$minutes min' : '${duration.inHours} hour';
        
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
  
  const _PomodoroInfo({
    required this.pomodoroCount,
    required this.isBreak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                Text('$pomodoroCount', style: AppTypography.titleLarge),
                Text('Pomodoros', style: AppTypography.caption),
              ],
            ),
            Column(
              children: [
                Icon(
                  isBreak ? Icons.coffee : Icons.work,
                  color: isBreak ? Colors.green : Colors.blue,
                ),
                Text(
                  isBreak ? 'Break' : 'Focus',
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
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
            text: 'Start',
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            width: 150,
          )
        else
          CustomButton(
            text: 'Pause',
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            width: 150,
            color: Colors.orange,
          ),
        
        AppSpacing.horizontalGapMD,
        
        CustomButton(
          text: 'Stop',
          onPressed: onStop,
          icon: const Icon(Icons.stop),
          width: 150,
          isOutlined: true,
        ),
      ],
    );
  }
}