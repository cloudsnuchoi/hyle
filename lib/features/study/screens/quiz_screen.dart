import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _totalTimeSpent = 0;
  int _timeRemaining = 30; // 30 seconds per question
  Timer? _timer;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isQuizComplete = false;
  
  // Mock quiz data
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      id: '1',
      question: '다음 중 프로그래밍 언어가 아닌 것은?',
      options: ['Python', 'Java', 'HTML', 'C++'],
      correctAnswer: 2,
      explanation: 'HTML은 마크업 언어로, 프로그래밍 언어가 아닙니다.',
      category: '코딩',
      difficulty: 'easy',
      points: 10,
    ),
    QuizQuestion(
      id: '2',
      question: '조선왕조의 수도는?',
      options: ['개성', '한양', '평양', '경주'],
      correctAnswer: 1,
      explanation: '조선왕조의 수도는 한양(현재의 서울)입니다.',
      category: '역사',
      difficulty: 'easy',
      points: 10,
    ),
    QuizQuestion(
      id: '3',
      question: '(x + 3)² = ?',
      options: ['x² + 9', 'x² + 6x + 9', 'x² + 3x + 9', 'x² + 6x + 3'],
      correctAnswer: 1,
      explanation: '(x + 3)² = x² + 2(3)(x) + 3² = x² + 6x + 9',
      category: '수학',
      difficulty: 'medium',
      points: 15,
    ),
    QuizQuestion(
      id: '4',
      question: '광합성의 주요 산물은?',
      options: ['이산화탄소', '물', '포도당', '질소'],
      correctAnswer: 2,
      explanation: '광합성을 통해 식물은 포도당(C₆H₁₂O₆)을 생성합니다.',
      category: '과학',
      difficulty: 'medium',
      points: 15,
    ),
    QuizQuestion(
      id: '5',
      question: '"Hello"를 프랑스어로?',
      options: ['Hola', 'Bonjour', 'Guten Tag', 'Ciao'],
      correctAnswer: 1,
      explanation: 'Bonjour는 프랑스어로 안녕하세요를 의미합니다.',
      category: '언어',
      difficulty: 'easy',
      points: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0 / _questions.length,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
    
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.linear,
    ));
    
    _startTimer();
    _timerController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining--;
          if (_timeRemaining <= 0) {
            _handleTimeout();
          }
        });
      }
    });
  }

  void _handleTimeout() {
    if (!_isAnswered) {
      setState(() {
        _isAnswered = true;
        _wrongAnswers++;
      });
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _isAnswered) return;
    
    _timer?.cancel();
    final question = _questions[_currentQuestionIndex];
    final isCorrect = int.parse(_selectedAnswer!) == question.correctAnswer;
    
    setState(() {
      _isAnswered = true;
      if (isCorrect) {
        _correctAnswers++;
      } else {
        _wrongAnswers++;
      }
      _totalTimeSpent += (30 - _timeRemaining);
    });
    
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
        _timeRemaining = 30;
      });
      
      _progressAnimation = Tween<double>(
        begin: _currentQuestionIndex / _questions.length,
        end: (_currentQuestionIndex + 1) / _questions.length,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController.forward(from: 0);
      
      _timerController.reset();
      _timerController.forward();
      _startTimer();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      _isQuizComplete = true;
    });
    _timer?.cancel();
    _showResultDialog();
  }

  void _showResultDialog() {
    final score = _correctAnswers * 10 + (_correctAnswers * 5); // Bonus points
    final accuracy = (_correctAnswers / _questions.length * 100).round();
    final avgTime = (_totalTimeSpent / _questions.length).round();
    
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
                // Trophy Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: accuracy >= 80
                          ? [const Color(0xFFFFC107), const Color(0xFFFF9800)]
                          : accuracy >= 60
                              ? [const Color(0xFF9CA3AF), const Color(0xFF6B7280)]
                              : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  accuracy >= 80 ? '최고예요!' : accuracy >= 60 ? '잘했어요!' : '더 연습해요!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 24),
                // Score Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF395886),
                        ),
                      ),
                      const Text(
                        '포인트',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.check_circle_outline,
                      value: '$_correctAnswers',
                      label: '정답',
                      color: const Color(0xFF10B981),
                    ),
                    _buildStatItem(
                      icon: Icons.cancel_outlined,
                      value: '$_wrongAnswers',
                      label: '오답',
                      color: const Color(0xFFEF4444),
                    ),
                    _buildStatItem(
                      icon: Icons.timer_outlined,
                      value: '${avgTime}s',
                      label: '평균',
                      color: const Color(0xFF638ECB),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Show review
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF638ECB),
                          ),
                        ),
                        child: const Text('결과 분석'),
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

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF737373),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _currentQuestionIndex < _questions.length
        ? _questions[_currentQuestionIndex]
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
              
              // Progress & Timer
              _buildProgressSection(),
              
              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildQuestionCard(currentQuestion),
                      const SizedBox(height: 24),
                      _buildAnswerOptions(currentQuestion),
                      if (_isAnswered) ...[
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
                    title: const Text('퀴즈 종료'),
                    content: const Text('정말 퀴즈를 종료하시겠습니까? 진행 상황이 저장되지 않습니다.'),
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
              '퀴즈',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFFFC107),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currentQuestionIndex < _questions.length ? _questions[_currentQuestionIndex].points : 0}점',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107),
                  ),
                ),
              ],
            ),
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
                '문제 ${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF525252),
                ),
              ),
              // Timer
              AnimatedBuilder(
                animation: _timerAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _timeRemaining <= 10
                          ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                          : const Color(0xFF638ECB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: _timeRemaining <= 10
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF638ECB),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_timeRemaining}s',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _timeRemaining <= 10
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF638ECB),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF638ECB),
                ),
                minHeight: 6,
              );
            },
          ),
          const SizedBox(height: 8),
          // Timer Progress Bar
          AnimatedBuilder(
            animation: _timerAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _timerAnimation.value,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timeRemaining <= 10
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
                minHeight: 3,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(question.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(question.category),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getDifficultyLabel(question.difficulty),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getDifficultyColor(question.difficulty),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(QuizQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final isSelected = _selectedAnswer == index.toString();
        final isCorrect = index == question.correctAnswer;
        
        Color? backgroundColor;
        Color? borderColor;
        IconData? trailingIcon;
        
        if (_isAnswered) {
          if (isCorrect) {
            backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1);
            borderColor = const Color(0xFF10B981);
            trailingIcon = Icons.check_circle_rounded;
          } else if (isSelected && !isCorrect) {
            backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
            borderColor = const Color(0xFFEF4444);
            trailingIcon = Icons.cancel_rounded;
          }
        } else if (isSelected) {
          backgroundColor = const Color(0xFF638ECB).withValues(alpha: 0.1);
          borderColor = const Color(0xFF638ECB);
        }
        
        return GestureDetector(
          onTap: _isAnswered
              ? null
              : () {
                  setState(() {
                    _selectedAnswer = index.toString();
                  });
                },
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
                    color: isSelected && !_isAnswered
                        ? const Color(0xFF638ECB)
                        : Colors.transparent,
                    border: Border.all(
                      color: borderColor ?? const Color(0xFFD4D4D4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected && !_isAnswered
                            ? Colors.white
                            : borderColor ?? const Color(0xFF737373),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: const Color(0xFF262626),
                    ),
                  ),
                ),
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: borderColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExplanation(QuizQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF638ECB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF638ECB),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '해설',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF638ECB),
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
          onPressed: _selectedAnswer != null && !_isAnswered
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
            _isAnswered ? '다음 문제로...' : '답안 제출',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '수학':
        return const Color(0xFF8AAEE0);
      case '언어':
        return const Color(0xFF638ECB);
      case '과학':
        return const Color(0xFF395886);
      case '역사':
        return const Color(0xFFFFC107);
      case '코딩':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF737373);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFFFC107);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF737373);
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return '일반';
    }
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String category;
  final String difficulty;
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.points,
  });
}