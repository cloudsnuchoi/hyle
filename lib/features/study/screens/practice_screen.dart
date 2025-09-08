import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  late AnimationController _checkController;
  
  int _currentQuestion = 0;
  final int _totalQuestions = 10;
  int _correctAnswers = 0;
  int _timeRemaining = 300; // 5 minutes
  bool _isPracticeComplete = false;
  String? _selectedAnswer;
  bool? _isCorrect;
  
  // Mock questions
  final List<PracticeQuestion> _questions = [
    PracticeQuestion(
      question: 'x² + 5x + 6 = 0의 해는?',
      options: ['x = -2, -3', 'x = 2, 3', 'x = -1, -6', 'x = 1, 6'],
      correctAnswer: 0,
      explanation: '인수분해: (x+2)(x+3) = 0, 따라서 x = -2 또는 x = -3',
    ),
    PracticeQuestion(
      question: 'lim(x→2) (x² - 4)/(x - 2) = ?',
      options: ['2', '4', '0', '무한대'],
      correctAnswer: 1,
      explanation: '극한값은 4입니다. 인수분해하면 (x+2)(x-2)/(x-2) = x+2 = 4',
    ),
    // Add more questions...
  ];

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: Duration(seconds: _timeRemaining),
      vsync: this,
    )..forward();
    
    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.linear,
    ));
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _startTimer();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && !_isPracticeComplete) {
        setState(() {
          _timeRemaining--;
          if (_timeRemaining <= 0) {
            _completePractice();
          }
        });
        return _timeRemaining > 0 && !_isPracticeComplete;
      }
      return false;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    final question = _questions[_currentQuestion];
    final isCorrect = int.parse(_selectedAnswer!) == question.correctAnswer;
    
    setState(() {
      _isCorrect = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
      }
    });
    
    _checkController.forward();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _isCorrect = null;
        });
        _checkController.reset();
      } else {
        _completePractice();
      }
    });
  }

  void _completePractice() {
    setState(() {
      _isPracticeComplete = true;
    });
    _showResultDialog();
  }

  void _showResultDialog() {
    final score = (_correctAnswers / _questions.length * 100).round();
    final xpEarned = _correctAnswers * 10;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: score >= 70
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFFFFC107), const Color(0xFFF59E0B)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  score >= 70 ? '훌륭해요!' : '잘했어요!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_correctAnswers / ${_questions.length} 문제 정답',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF525252),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+$xpEarned XP',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Review answers
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF638ECB),
                          ),
                        ),
                        child: const Text('답안 확인'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF395886),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('완료'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _currentQuestion < _questions.length
        ? _questions[_currentQuestion]
        : _questions.last;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F3FA), // primary50
              Color(0xFFD5DEEF), // primary100
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Progress and Timer
              _buildProgressSection(),
              
              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildQuestionCard(currentQuestion),
                      const SizedBox(height: 20),
                      _buildAnswerOptions(currentQuestion),
                      if (_isCorrect != null) ...[
                        const SizedBox(height: 20),
                        _buildExplanation(currentQuestion),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('연습 종료'),
                    content: const Text('정말 연습을 종료하시겠습니까? 진행 상황이 저장되지 않습니다.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('종료'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Expanded(
            child: Text(
              '연습 문제',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626), // gray800
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            onPressed: () {
              // Bookmark question
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Question Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '문제 ${_currentQuestion + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF525252),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Color(0xFF737373),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _timeRemaining < 60
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF525252),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            backgroundColor: const Color(0xFFE5E5E5),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF638ECB),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          // Correct Answer Count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '정답 $_correctAnswers',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(PracticeQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '문제 ${_currentQuestion + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF638ECB),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(PracticeQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final isSelected = _selectedAnswer == index.toString();
        Color? backgroundColor;
        Color? borderColor;
        Color? textColor;
        
        if (_isCorrect != null) {
          if (index == question.correctAnswer) {
            backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1);
            borderColor = const Color(0xFF10B981);
            textColor = const Color(0xFF10B981);
          } else if (isSelected && !_isCorrect!) {
            backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
            borderColor = const Color(0xFFEF4444);
            textColor = const Color(0xFFEF4444);
          }
        } else if (isSelected) {
          backgroundColor = const Color(0xFF638ECB).withValues(alpha: 0.1);
          borderColor = const Color(0xFF638ECB);
          textColor = const Color(0xFF638ECB);
        }
        
        return GestureDetector(
          onTap: _isCorrect == null
              ? () {
                  setState(() {
                    _selectedAnswer = index.toString();
                  });
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor ?? const Color(0xFFE5E5E5),
                width: borderColor != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor ?? const Color(0xFFD4D4D4),
                      width: 2,
                    ),
                    color: isSelected
                        ? (borderColor ?? const Color(0xFF638ECB))
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: textColor ?? const Color(0xFF262626),
                    ),
                  ),
                ),
                if (_isCorrect != null && index == question.correctAnswer)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                  )
                else if (_isCorrect != null && isSelected && !_isCorrect!)
                  const Icon(
                    Icons.cancel_rounded,
                    color: Color(0xFFEF4444),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExplanation(PracticeQuestion question) {
    return AnimatedBuilder(
      animation: _checkController,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkController.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect!
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect!
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCorrect!
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                      color: _isCorrect!
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect! ? '정답입니다!' : '틀렸습니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect!
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF525252),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedAnswer != null && _isCorrect == null
              ? _submitAnswer
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF395886),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFD4D4D4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _isCorrect != null
                ? '다음 문제로...'
                : '답안 제출',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class PracticeQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  PracticeQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}