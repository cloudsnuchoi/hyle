import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;

class PomodoroScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? sessionData;
  
  const PomodoroScreen({super.key, this.sessionData});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  Timer? _timer;
  int _totalSeconds = 25 * 60; // 25분
  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _pomodoroCount = 0;
  int _breakDuration = 5 * 60; // 5분 휴식
  int _longBreakDuration = 15 * 60; // 15분 긴 휴식
  
  String? _subject;
  String? _todo;

  @override
  void initState() {
    super.initState();
    
    // 세션 데이터 설정
    if (widget.sessionData != null) {
      _subject = widget.sessionData!['subject'];
      _todo = widget.sessionData!['todo'];
    }
    
    _progressController = AnimationController(
      duration: Duration(seconds: _totalSeconds),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPomodoro() {
    if (_isRunning) {
      _pausePomodoro();
    } else {
      setState(() {
        _isRunning = true;
      });
      
      _progressController.duration = Duration(seconds: _currentSeconds);
      _progressController.forward(from: 1 - (_currentSeconds / _totalSeconds));
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentSeconds > 0) {
            _currentSeconds--;
          } else {
            _completeSession();
          }
        });
      });
    }
  }

  void _pausePomodoro() {
    _timer?.cancel();
    _progressController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetPomodoro() {
    _timer?.cancel();
    _progressController.reset();
    setState(() {
      _currentSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _progressController.reset();
    
    setState(() {
      _isRunning = false;
      
      if (!_isBreak) {
        // 뽀모도로 완료
        _pomodoroCount++;
        _isBreak = true;
        
        // 4번째 뽀모도로 후 긴 휴식
        if (_pomodoroCount % 4 == 0) {
          _totalSeconds = _longBreakDuration;
          _currentSeconds = _longBreakDuration;
          _showNotification('긴 휴식 시간! 15분간 충분히 쉬세요.');
        } else {
          _totalSeconds = _breakDuration;
          _currentSeconds = _breakDuration;
          _showNotification('휴식 시간! 5분간 쉬세요.');
        }
      } else {
        // 휴식 완료
        _isBreak = false;
        _totalSeconds = 25 * 60;
        _currentSeconds = 25 * 60;
        _showNotification('집중 시간! 25분간 집중하세요.');
      }
    });
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _isBreak ? const Color(0xFF4CAF50) : const Color(0xFF638ECB),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isBreak
                ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
                : [const Color(0xFFF0F3FA), const Color(0xFFDFE7F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_subject != null || _todo != null) _buildSessionInfo(),
              _buildPomodoroCounter(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimerDisplay(),
                    const SizedBox(height: 60),
                    _buildControls(),
                    const SizedBox(height: 40),
                    _buildSettings(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF395886)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              '뽀모도로',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_subject != null) ...[
            Icon(Icons.book, color: const Color(0xFF638ECB), size: 20),
            const SizedBox(width: 8),
            Text(
              _subject!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF395886),
              ),
            ),
          ],
          if (_subject != null && _todo != null) 
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('|', style: TextStyle(color: Color(0xFFD5DEEF))),
            ),
          if (_todo != null) ...[
            Icon(Icons.task_alt, color: const Color(0xFF638ECB), size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _todo!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF395886),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPomodoroCounter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < (_pomodoroCount % 4) && !_isBreak
                  ? const Color(0xFF638ECB)
                  : Colors.white.withValues(alpha: 0.5),
              border: Border.all(
                color: const Color(0xFF638ECB),
                width: 2,
              ),
            ),
            child: index < (_pomodoroCount % 4) && !_isBreak
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          );
        }),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress Circle
              SizedBox(
                width: 280,
                height: 280,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CircularProgressPainter(
                        progress: _progressController.value,
                        color: _isBreak 
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF638ECB),
                      ),
                    );
                  },
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
                      color: (_isBreak 
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF638ECB)).withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isBreak ? '휴식' : '집중',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _isBreak 
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF638ECB),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(_currentSeconds),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF395886),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '세션 ${_pomodoroCount + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8AAEE0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF395886).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8AAEE0)),
            iconSize: 28,
            onPressed: _resetPomodoro,
          ),
        ),
        const SizedBox(width: 40),
        
        // Start/Pause button
        GestureDetector(
          onTap: _startPomodoro,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isRunning
                    ? [const Color(0xFFFF6B6B), const Color(0xFFFF8787)]
                    : _isBreak
                        ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                        : [const Color(0xFF638ECB), const Color(0xFF8AAEE0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _isRunning
                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.3)
                      : _isBreak
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                          : const Color(0xFF638ECB).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 40),
        
        // Skip button
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF395886).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_next, color: Color(0xFF638ECB)),
            iconSize: 28,
            onPressed: _completeSession,
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSettingItem('집중', '25분'),
              _buildSettingItem('휴식', '5분'),
              _buildSettingItem('긴 휴식', '15분'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8AAEE0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
        ),
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw background circle
    canvas.drawCircle(center, radius, paint);

    // Draw progress arc
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}