import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// Timer State Provider
final timerStateProvider = StateNotifierProvider<TimerStateNotifier, TimerState>((ref) {
  return TimerStateNotifier();
});

// Timer Mode
enum TimerMode { stopwatch, timer, pomodoro }

// Pomodoro Phase
enum PomodoroPhase { focus, shortBreak, longBreak }

class TimerState {
  final TimerMode mode;
  final Duration currentTime;
  final Duration totalTime;
  final bool isRunning;
  final PomodoroPhase pomodoroPhase;
  final int pomodoroCount;
  
  TimerState({
    this.mode = TimerMode.pomodoro,
    this.currentTime = const Duration(minutes: 25),
    this.totalTime = const Duration(minutes: 25),
    this.isRunning = false,
    this.pomodoroPhase = PomodoroPhase.focus,
    this.pomodoroCount = 0,
  });
  
  TimerState copyWith({
    TimerMode? mode,
    Duration? currentTime,
    Duration? totalTime,
    bool? isRunning,
    PomodoroPhase? pomodoroPhase,
    int? pomodoroCount,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      currentTime: currentTime ?? this.currentTime,
      totalTime: totalTime ?? this.totalTime,
      isRunning: isRunning ?? this.isRunning,
      pomodoroPhase: pomodoroPhase ?? this.pomodoroPhase,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
    );
  }
}

class TimerStateNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  
  TimerStateNotifier() : super(TimerState());
  
  void setMode(TimerMode mode) {
    stop();
    switch (mode) {
      case TimerMode.stopwatch:
        state = state.copyWith(
          mode: mode,
          currentTime: Duration.zero,
          totalTime: Duration.zero,
        );
        break;
      case TimerMode.timer:
        state = state.copyWith(
          mode: mode,
          currentTime: const Duration(minutes: 5),
          totalTime: const Duration(minutes: 5),
        );
        break;
      case TimerMode.pomodoro:
        state = state.copyWith(
          mode: mode,
          currentTime: const Duration(minutes: 25),
          totalTime: const Duration(minutes: 25),
          pomodoroPhase: PomodoroPhase.focus,
        );
        break;
    }
  }
  
  void start() {
    if (state.isRunning) return;
    
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      switch (state.mode) {
        case TimerMode.stopwatch:
          state = state.copyWith(
            currentTime: state.currentTime + const Duration(seconds: 1),
          );
          break;
        case TimerMode.timer:
        case TimerMode.pomodoro:
          if (state.currentTime.inSeconds > 0) {
            state = state.copyWith(
              currentTime: state.currentTime - const Duration(seconds: 1),
            );
          } else {
            // 타이머 완료
            stop();
            if (state.mode == TimerMode.pomodoro) {
              _handlePomodoroComplete();
            }
          }
          break;
      }
    });
  }
  
  void stop() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }
  
  void reset() {
    stop();
    switch (state.mode) {
      case TimerMode.stopwatch:
        state = state.copyWith(currentTime: Duration.zero);
        break;
      case TimerMode.timer:
      case TimerMode.pomodoro:
        state = state.copyWith(currentTime: state.totalTime);
        break;
    }
  }
  
  void setTimerDuration(Duration duration) {
    stop();
    state = state.copyWith(
      currentTime: duration,
      totalTime: duration,
    );
  }
  
  void _handlePomodoroComplete() {
    switch (state.pomodoroPhase) {
      case PomodoroPhase.focus:
        final newCount = state.pomodoroCount + 1;
        if (newCount % 4 == 0) {
          // 긴 휴식
          state = state.copyWith(
            pomodoroPhase: PomodoroPhase.longBreak,
            currentTime: const Duration(minutes: 15),
            totalTime: const Duration(minutes: 15),
            pomodoroCount: newCount,
          );
        } else {
          // 짧은 휴식
          state = state.copyWith(
            pomodoroPhase: PomodoroPhase.shortBreak,
            currentTime: const Duration(minutes: 5),
            totalTime: const Duration(minutes: 5),
            pomodoroCount: newCount,
          );
        }
        break;
      case PomodoroPhase.shortBreak:
      case PomodoroPhase.longBreak:
        // 다시 집중 시간으로
        state = state.copyWith(
          pomodoroPhase: PomodoroPhase.focus,
          currentTime: const Duration(minutes: 25),
          totalTime: const Duration(minutes: 25),
        );
        break;
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class TimerScreenGamified extends ConsumerWidget {
  const TimerScreenGamified({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerStateProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 타이머'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showTimerSettings(context, ref),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            // 모드 선택
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildModeButton(
                    context,
                    ref,
                    TimerMode.stopwatch,
                    Icons.timer,
                    '스톱워치',
                    timerState.mode == TimerMode.stopwatch,
                  ),
                  _buildModeButton(
                    context,
                    ref,
                    TimerMode.timer,
                    Icons.hourglass_empty,
                    '타이머',
                    timerState.mode == TimerMode.timer,
                  ),
                  _buildModeButton(
                    context,
                    ref,
                    TimerMode.pomodoro,
                    Icons.av_timer,
                    '뽀모도로',
                    timerState.mode == TimerMode.pomodoro,
                  ),
                ],
              ),
            ),
            
            // 타이머 디스플레이
            Expanded(
              child: Center(
                child: _buildTimerDisplay(context, ref, timerState),
              ),
            ),
            
            // 컨트롤 버튼
            _buildControls(context, ref, timerState),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeButton(
    BuildContext context,
    WidgetRef ref,
    TimerMode mode,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(timerStateProvider.notifier).setMode(mode),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : theme.iconTheme.color,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTimerDisplay(BuildContext context, WidgetRef ref, TimerState state) {
    switch (state.mode) {
      case TimerMode.stopwatch:
        return _buildStopwatchDisplay(context, state);
      case TimerMode.timer:
        return _buildTimerCountdownDisplay(context, state);
      case TimerMode.pomodoro:
        return _buildPomodoroDisplay(context, state);
    }
  }
  
  Widget _buildStopwatchDisplay(BuildContext context, TimerState state) {
    final theme = Theme.of(context);
    final time = state.currentTime;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withOpacity(0.2),
                theme.primaryColor.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              // 시간 표시
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: theme.primaryColor,
                    ),
                  ),
                  Text(
                    '.${(time.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'monospace',
                      color: theme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              // 장식 원
              ...List.generate(60, (index) {
                return Transform.rotate(
                  angle: (index * 6) * math.pi / 180,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 2,
                      height: index % 5 == 0 ? 12 : 8,
                      color: theme.primaryColor.withOpacity(index % 5 == 0 ? 0.5 : 0.3),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 랩 타임
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'LAP ${state.pomodoroCount}',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimerCountdownDisplay(BuildContext context, TimerState state) {
    final theme = Theme.of(context);
    final progress = state.totalTime.inSeconds > 0
        ? state.currentTime.inSeconds / state.totalTime.inSeconds
        : 0.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 배경 원
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.1),
                    Colors.orange.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            // 진행 표시
            SizedBox(
              width: 260,
              height: 260,
              child: CircularProgressIndicator(
                value: 1 - progress,
                strokeWidth: 20,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(Colors.red, Colors.orange, progress)!,
                ),
              ),
            ),
            // 시간 표시
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 40,
                      color: Colors.orange.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(state.currentTime),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color.lerp(Colors.red, Colors.orange, progress),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 진행률 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${((1 - progress) * 100).toInt()}% 완료',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPomodoroDisplay(BuildContext context, TimerState state) {
    final theme = Theme.of(context);
    final progress = state.totalTime.inSeconds > 0
        ? state.currentTime.inSeconds / state.totalTime.inSeconds
        : 0.0;
    
    Color getPhaseColor() {
      switch (state.pomodoroPhase) {
        case PomodoroPhase.focus:
          return Colors.red;
        case PomodoroPhase.shortBreak:
          return Colors.green;
        case PomodoroPhase.longBreak:
          return Colors.blue;
      }
    }
    
    String getPhaseText() {
      switch (state.pomodoroPhase) {
        case PomodoroPhase.focus:
          return '집중 시간';
        case PomodoroPhase.shortBreak:
          return '짧은 휴식';
        case PomodoroPhase.longBreak:
          return '긴 휴식';
      }
    }
    
    final phaseColor = getPhaseColor();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 뽀모도로 카운트
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < state.pomodoroCount % 4
                    ? phaseColor
                    : phaseColor.withOpacity(0.3),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        // 원형 타이머
        Stack(
          alignment: Alignment.center,
          children: [
            // 토마토 배경
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    phaseColor.withOpacity(0.2),
                    phaseColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: TomatoPainter(phaseColor),
              ),
            ),
            // 진행 표시
            SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: PomodoroProgressPainter(
                  progress: progress,
                  color: phaseColor,
                ),
              ),
            ),
            // 시간 표시
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.cardColor.withOpacity(0.9),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getPhaseText(),
                      style: TextStyle(
                        fontSize: 18,
                        color: phaseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(state.currentTime),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: phaseColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '세션 ${state.pomodoroCount}',
                      style: TextStyle(
                        fontSize: 16,
                        color: phaseColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildControls(BuildContext context, WidgetRef ref, TimerState state) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset 버튼
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              iconSize: 32,
              onPressed: () => ref.read(timerStateProvider.notifier).reset(),
            ),
          ),
          const SizedBox(width: 32),
          // Play/Pause 버튼
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: state.isRunning
                    ? [Colors.orange.shade400, Colors.orange.shade600]
                    : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: state.isRunning
                      ? Colors.orange.withOpacity(0.5)
                      : theme.primaryColor.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                state.isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              iconSize: 48,
              padding: const EdgeInsets.all(16),
              onPressed: () {
                if (state.isRunning) {
                  ref.read(timerStateProvider.notifier).stop();
                } else {
                  ref.read(timerStateProvider.notifier).start();
                }
              },
            ),
          ),
          const SizedBox(width: 32),
          // Skip 버튼 (뽀모도로만)
          if (state.mode == TimerMode.pomodoro)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                iconSize: 32,
                onPressed: () {
                  ref.read(timerStateProvider.notifier).reset();
                  ref.read(timerStateProvider.notifier)._handlePomodoroComplete();
                },
              ),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }
  
  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  void _showTimerSettings(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerStateProvider);
    
    if (state.mode == TimerMode.timer) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('타이머 시간 설정', style: AppTypography.titleLarge),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTimeChip(context, ref, const Duration(minutes: 1), '1분'),
                  _buildTimeChip(context, ref, const Duration(minutes: 3), '3분'),
                  _buildTimeChip(context, ref, const Duration(minutes: 5), '5분'),
                  _buildTimeChip(context, ref, const Duration(minutes: 10), '10분'),
                  _buildTimeChip(context, ref, const Duration(minutes: 15), '15분'),
                  _buildTimeChip(context, ref, const Duration(minutes: 30), '30분'),
                  _buildTimeChip(context, ref, const Duration(minutes: 45), '45분'),
                  _buildTimeChip(context, ref, const Duration(hours: 1), '1시간'),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildTimeChip(BuildContext context, WidgetRef ref, Duration duration, String label) {
    return InkWell(
      onTap: () {
        ref.read(timerStateProvider.notifier).setTimerDuration(duration);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 뽀모도로 진행 표시 Painter
class PomodoroProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  PomodoroProgressPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 배경 원
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    canvas.drawCircle(center, radius - 10, backgroundPaint);
    
    // 진행 아크
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 토마토 모양 Painter
class TomatoPainter extends CustomPainter {
  final Color color;
  
  TomatoPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 토마토 잎
    final leafPaint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final leafPath = Path();
    leafPath.moveTo(center.dx, center.dy - 100);
    leafPath.quadraticBezierTo(
      center.dx - 20, center.dy - 120,
      center.dx - 30, center.dy - 100,
    );
    leafPath.quadraticBezierTo(
      center.dx - 15, center.dy - 110,
      center.dx, center.dy - 100,
    );
    leafPath.quadraticBezierTo(
      center.dx + 15, center.dy - 110,
      center.dx + 30, center.dy - 100,
    );
    leafPath.quadraticBezierTo(
      center.dx + 20, center.dy - 120,
      center.dx, center.dy - 100,
    );
    
    canvas.drawPath(leafPath, leafPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}