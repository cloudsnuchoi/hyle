import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class StopwatchScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? sessionData;
  
  const StopwatchScreen({super.key, this.sessionData});

  @override
  ConsumerState<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends ConsumerState<StopwatchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  final List<String> _laps = [];
  
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
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    if (_isRunning) {
      _pauseStopwatch();
    } else {
      setState(() {
        _isRunning = true;
      });
      _animationController.forward();
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
  }

  void _pauseStopwatch() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    _animationController.reverse();
  }

  void _resetStopwatch() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
      _laps.clear();
    });
    _animationController.reset();
  }

  void _addLap() {
    if (_isRunning && _seconds > 0) {
      setState(() {
        _laps.add(_formatTime(_seconds));
      });
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F3FA),
              Color(0xFFDFE7F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_subject != null || _todo != null) _buildSessionInfo(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimerDisplay(),
                    const SizedBox(height: 60),
                    _buildControls(),
                    if (_laps.isNotEmpty) _buildLaps(),
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
              '스톱워치',
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

  Widget _buildTimerDisplay() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF638ECB).withValues(alpha: 0.2),
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
                _formatTime(_seconds),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF395886),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              if (_isRunning)
                const Text(
                  '측정 중',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF638ECB),
                  ),
                ),
            ],
          ),
        ),
      ),
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
            onPressed: _resetStopwatch,
          ),
        ),
        const SizedBox(width: 40),
        
        // Start/Pause button
        GestureDetector(
          onTap: _startStopwatch,
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
                    : [const Color(0xFF638ECB), const Color(0xFF8AAEE0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _isRunning
                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.3)
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
        
        // Lap button
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
            icon: const Icon(Icons.flag, color: Color(0xFF638ECB)),
            iconSize: 28,
            onPressed: _addLap,
          ),
        ),
      ],
    );
  }

  Widget _buildLaps() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      height: 150,
      child: Column(
        children: [
          const Text(
            '랩 타임',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lap ${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF8AAEE0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _laps[index],
                        style: const TextStyle(
                          color: Color(0xFF395886),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}