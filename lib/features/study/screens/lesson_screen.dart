import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late PageController _pageController;
  
  int _currentPage = 0;
  final int _totalPages = 5;
  bool _isCompleted = false;
  
  // Mock lesson content
  final List<LessonContent> _lessonPages = [
    LessonContent(
      type: 'intro',
      title: '미적분 기초',
      content: '미적분은 변화를 다루는 수학의 한 분야입니다.',
      imageUrl: null,
      hasInteraction: false,
    ),
    LessonContent(
      type: 'concept',
      title: '극한의 개념',
      content: 'x가 어떤 값에 가까워질 때, 함수 f(x)가 어떤 값에 접근하는지를 나타냅니다.',
      imageUrl: null,
      hasInteraction: true,
    ),
    LessonContent(
      type: 'example',
      title: '예제 문제',
      content: 'lim(x→2) (x² - 4)/(x - 2) = ?',
      imageUrl: null,
      hasInteraction: true,
    ),
    LessonContent(
      type: 'practice',
      title: '연습 문제',
      content: '다음 극한값을 구하세요.',
      imageUrl: null,
      hasInteraction: true,
    ),
    LessonContent(
      type: 'summary',
      title: '요약',
      content: '오늘 배운 내용을 정리해봅시다.',
      imageUrl: null,
      hasInteraction: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0 / _totalPages,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressAnimation = Tween<double>(
        begin: _currentPage / _totalPages,
        end: (_currentPage + 1) / _totalPages,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController.forward(from: 0);
    } else {
      setState(() {
        _isCompleted = true;
      });
      _showCompletionDialog();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressAnimation = Tween<double>(
        begin: (_currentPage + 2) / _totalPages,
        end: (_currentPage + 1) / _totalPages,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController.forward(from: 0);
    }
  }

  void _showCompletionDialog() {
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
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF638ECB),
                        Color(0xFF395886),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '레슨 완료!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '+50 XP 획득',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF638ECB),
                          ),
                        ),
                        child: const Text('나가기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to next lesson
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF395886),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('다음 레슨'),
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
              
              // Progress Bar
              _buildProgressBar(),
              
              // Lesson Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    return _buildLessonPage(_lessonPages[index]);
                  },
                ),
              ),
              
              // Navigation Buttons
              _buildNavigationButtons(),
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
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              '미적분 기초 - 레슨 1',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626), // gray800
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              // Show help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentPage + 1} / $_totalPages',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF525252), // gray600
                ),
              ),
              Text(
                '${((_currentPage + 1) / _totalPages * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF638ECB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF638ECB),
                ),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPage(LessonContent content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTypeColor(content.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getTypeColor(content.type),
                width: 1,
              ),
            ),
            child: Text(
              _getTypeLabel(content.type),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTypeColor(content.type),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Content
          Container(
            padding: const EdgeInsets.all(20),
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
                Text(
                  content.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF525252), // gray600
                    height: 1.6,
                  ),
                ),
                
                if (content.type == 'example') ...[
                  const SizedBox(height: 20),
                  _buildExampleContent(),
                ],
                
                if (content.type == 'practice') ...[
                  const SizedBox(height: 20),
                  _buildPracticeContent(),
                ],
                
                if (content.hasInteraction) ...[
                  const SizedBox(height: 24),
                  _buildInteractionArea(content.type),
                ],
              ],
            ),
          ),
          
          // Additional Resources
          if (content.type == 'summary') ...[
            const SizedBox(height: 24),
            _buildSummaryContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF638ECB).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '풀이:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. 분자를 인수분해: x² - 4 = (x+2)(x-2)',
            style: TextStyle(fontSize: 14, color: Color(0xFF525252)),
          ),
          const SizedBox(height: 4),
          const Text(
            '2. 약분: (x+2)(x-2)/(x-2) = x+2',
            style: TextStyle(fontSize: 14, color: Color(0xFF525252)),
          ),
          const SizedBox(height: 4),
          const Text(
            '3. x=2 대입: 2+2 = 4',
            style: TextStyle(fontSize: 14, color: Color(0xFF525252)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '답: 4',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeContent() {
    return Column(
      children: [
        _buildPracticeQuestion('1. lim(x→3) (x² - 9)/(x - 3)'),
        const SizedBox(height: 12),
        _buildPracticeQuestion('2. lim(x→1) (x³ - 1)/(x - 1)'),
        const SizedBox(height: 12),
        _buildPracticeQuestion('3. lim(x→4) (√x - 2)/(x - 4)'),
      ],
    );
  }

  Widget _buildPracticeQuestion(String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF262626),
              ),
            ),
          ),
          const Icon(
            Icons.edit_rounded,
            size: 20,
            color: Color(0xFF638ECB),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionArea(String type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF638ECB).withValues(alpha: 0.1),
            const Color(0xFF8AAEE0).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.touch_app_rounded,
            size: 32,
            color: Color(0xFF638ECB),
          ),
          const SizedBox(height: 8),
          Text(
            type == 'concept' 
                ? '그래프를 터치하여 극한 개념을 확인하세요'
                : '문제를 풀어보세요',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF395886),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF638ECB),
            Color(0xFF395886),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘 배운 내용',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryItem('✓ 극한의 기본 개념'),
          _buildSummaryItem('✓ 극한값 계산 방법'),
          _buildSummaryItem('✓ 인수분해를 이용한 극한'),
          _buildSummaryItem('✓ 연습 문제 풀이'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: Color(0xFF638ECB),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '이전',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF395886),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _totalPages - 1 ? '완료' : '다음',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'intro':
        return const Color(0xFF638ECB);
      case 'concept':
        return const Color(0xFF8AAEE0);
      case 'example':
        return const Color(0xFF10B981);
      case 'practice':
        return const Color(0xFFFFC107);
      case 'summary':
        return const Color(0xFF395886);
      default:
        return const Color(0xFF737373);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'intro':
        return '소개';
      case 'concept':
        return '개념';
      case 'example':
        return '예제';
      case 'practice':
        return '연습';
      case 'summary':
        return '요약';
      default:
        return '';
    }
  }
}

class LessonContent {
  final String type;
  final String title;
  final String content;
  final String? imageUrl;
  final bool hasInteraction;

  LessonContent({
    required this.type,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.hasInteraction,
  });
}