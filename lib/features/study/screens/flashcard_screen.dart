import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flashcard_list_screen.dart'; // FlashcardSet import

class FlashcardScreen extends ConsumerStatefulWidget {
  final FlashcardSet? flashcardSet;
  const FlashcardScreen({super.key, this.flashcardSet});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  bool _showAnswer = false;
  int _knownCount = 0;
  int _unknownCount = 0;
  
  // 세트별 플래시카드 데이터를 동적으로 생성
  late final List<FlashCard> _flashcards;
  
  List<FlashCard> _generateFlashcards() {
    if (widget.flashcardSet == null) {
      // 기본 플래시카드 데이터
      return [
        FlashCard(
          id: '1',
          question: 'x²의 미분은?',
          answer: '2x',
          category: '수학',
          difficulty: 'easy',
          lastReviewed: DateTime.now().subtract(const Duration(days: 1)),
          reviewCount: 3,
        ),
        FlashCard(
          id: '2',
          question: 'Bonjour는 무슨 뜻일까요?',
          answer: '안녕하세요 (프랑스어)',
          category: '언어',
          difficulty: 'easy',
          lastReviewed: DateTime.now().subtract(const Duration(days: 2)),
          reviewCount: 1,
        ),
        FlashCard(
          id: '3',
          question: '광합성의 화학식은?',
          answer: '6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂',
          category: '과학',
          difficulty: 'medium',
          lastReviewed: DateTime.now().subtract(const Duration(days: 3)),
          reviewCount: 2,
        ),
        FlashCard(
          id: '4',
          question: '조선의 첫 번째 왕은?',
          answer: '태조 이성계',
          category: '역사',
          difficulty: 'easy',
          lastReviewed: DateTime.now().subtract(const Duration(hours: 12)),
          reviewCount: 5,
        ),
        FlashCard(
          id: '5',
          question: 'Python에서 리스트를 정의하는 방법은?',
          answer: 'list_name = [] 또는 list_name = list()',
          category: '코딩',
          difficulty: 'easy',
          lastReviewed: DateTime.now(),
          reviewCount: 4,
        ),
      ];
    }
    
    // 세트별 다른 플래시카드 생성
    switch (widget.flashcardSet!.id) {
      case '1': // 수학 공식 모음
        return [
          FlashCard(id: '1', question: '원의 넓이 공식은?', answer: 'πr²', category: '수학', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 2),
          FlashCard(id: '2', question: '피타고라스 정리는?', answer: 'a² + b² = c²', category: '수학', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 3),
          FlashCard(id: '3', question: '이차방정식의 근의 공식은?', answer: 'x = (-b ± √(b²-4ac))/2a', category: '수학', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 1),
          FlashCard(id: '4', question: 'sin²θ + cos²θ = ?', answer: '1', category: '수학', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 4),
          FlashCard(id: '5', question: '극한 lim(x→0) sin(x)/x = ?', answer: '1', category: '수학', difficulty: 'hard', lastReviewed: DateTime.now(), reviewCount: 2),
        ];
      case '2': // 프랑스어 기초 단어
        return [
          FlashCard(id: '1', question: 'Merci는 무슨 뜻?', answer: '감사합니다', category: '언어', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 5),
          FlashCard(id: '2', question: 'Au revoir는 무슨 뜻?', answer: '안녕히 가세요', category: '언어', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 3),
          FlashCard(id: '3', question: 'S\'il vous plaît는 무슨 뜻?', answer: '부탁드립니다', category: '언어', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 2),
          FlashCard(id: '4', question: 'Comment allez-vous?', answer: '어떻게 지내세요?', category: '언어', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 1),
          FlashCard(id: '5', question: 'Je ne comprends pas', answer: '이해하지 못합니다', category: '언어', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 2),
        ];
      case '3': // 생물학 - 광합성
        return [
          FlashCard(id: '1', question: '광합성이 일어나는 장소는?', answer: '엽록체', category: '과학', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 4),
          FlashCard(id: '2', question: '광합성의 명반응이 일어나는 곳은?', answer: '틸라코이드', category: '과학', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 2),
          FlashCard(id: '3', question: '광합성의 암반응이 일어나는 곳은?', answer: '스트로마', category: '과학', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 1),
          FlashCard(id: '4', question: 'ATP의 정식 명칭은?', answer: '아데노신 삼인산', category: '과학', difficulty: 'hard', lastReviewed: DateTime.now(), reviewCount: 3),
          FlashCard(id: '5', question: '캘빈 회로의 최종 산물은?', answer: '포도당', category: '과학', difficulty: 'hard', lastReviewed: DateTime.now(), reviewCount: 1),
        ];
      case '4': // 한국사 연대표
        return [
          FlashCard(id: '1', question: '조선 건국 연도는?', answer: '1392년', category: '역사', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 6),
          FlashCard(id: '2', question: '임진왜란이 일어난 연도는?', answer: '1592년', category: '역사', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 5),
          FlashCard(id: '3', question: '세종대왕 재위 기간은?', answer: '1418년 ~ 1450년', category: '역사', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 3),
          FlashCard(id: '4', question: '훈민정음 창제 연도는?', answer: '1443년', category: '역사', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 4),
          FlashCard(id: '5', question: '경술국치 연도는?', answer: '1910년', category: '역사', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 7),
        ];
      case '5': // Python 기초 문법
        return [
          FlashCard(id: '1', question: 'Python에서 주석 처리는?', answer: '# 또는 """..."""', category: '코딩', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 3),
          FlashCard(id: '2', question: 'Python의 조건문 키워드는?', answer: 'if, elif, else', category: '코딩', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 4),
          FlashCard(id: '3', question: 'Python의 반복문 종류는?', answer: 'for, while', category: '코딩', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 2),
          FlashCard(id: '4', question: '리스트 컴프리헨션 예시는?', answer: '[x**2 for x in range(10)]', category: '코딩', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 1),
          FlashCard(id: '5', question: 'lambda 함수란?', answer: '익명 함수', category: '코딩', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 2),
        ];
      case '6': // 영어 숙어 표현
        return [
          FlashCard(id: '1', question: 'piece of cake의 뜻은?', answer: '매우 쉬운 일', category: '언어', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 2),
          FlashCard(id: '2', question: 'break a leg의 뜻은?', answer: '행운을 빌어', category: '언어', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 1),
          FlashCard(id: '3', question: 'hit the nail on the head', answer: '정확히 맞추다', category: '언어', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 3),
          FlashCard(id: '4', question: 'burn the midnight oil', answer: '늦게까지 일하다', category: '언어', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 2),
          FlashCard(id: '5', question: 'when pigs fly의 뜻은?', answer: '절대 일어나지 않을 일', category: '언어', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 4),
        ];
      case '7': // 화학 원소 주기율표
        return [
          FlashCard(id: '1', question: '수소의 원자번호는?', answer: '1', category: '과학', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 0),
          FlashCard(id: '2', question: '금의 원소기호는?', answer: 'Au', category: '과학', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 0),
          FlashCard(id: '3', question: '철의 원소기호는?', answer: 'Fe', category: '과학', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 0),
          FlashCard(id: '4', question: '나트륨의 원소기호는?', answer: 'Na', category: '과학', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 0),
          FlashCard(id: '5', question: '희유가스 5개는?', answer: 'He, Ne, Ar, Kr, Xe', category: '과학', difficulty: 'hard', lastReviewed: DateTime.now(), reviewCount: 0),
        ];
      case '8': // 경제학 기본 용어
        return [
          FlashCard(id: '1', question: 'GDP의 정식 명칭은?', answer: '국내총생산', category: '사회', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 1),
          FlashCard(id: '2', question: '인플레이션이란?', answer: '화폐 가치 하락으로 인한 물가 상승', category: '사회', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 2),
          FlashCard(id: '3', question: '기회비용이란?', answer: '선택으로 포기한 차선의 가치', category: '사회', difficulty: 'medium', lastReviewed: DateTime.now(), reviewCount: 1),
          FlashCard(id: '4', question: '수요의 법칙이란?', answer: '가격이 오르면 수요량이 감소', category: '사회', difficulty: 'easy', lastReviewed: DateTime.now(), reviewCount: 3),
          FlashCard(id: '5', question: '한계효용 체감의 법칙', answer: '소비량이 늘수록 추가 만족도 감소', category: '사회', difficulty: 'hard', lastReviewed: DateTime.now(), reviewCount: 1),
        ];
      default:
        return _generateDefaultFlashcards();
    }
  }
  
  List<FlashCard> _generateDefaultFlashcards() {
    return [
      FlashCard(
        id: '1',
        question: 'x²의 미분은?',
        answer: '2x',
        category: '수학',
        difficulty: 'easy',
        lastReviewed: DateTime.now().subtract(const Duration(days: 1)),
        reviewCount: 3,
      ),
      FlashCard(
        id: '2',
        question: 'Bonjour는 무슨 뜻일까요?',
        answer: '안녕하세요 (프랑스어)',
        category: '언어',
        difficulty: 'easy',
        lastReviewed: DateTime.now().subtract(const Duration(days: 2)),
        reviewCount: 1,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _flashcards = _generateFlashcards();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
      _showAnswer = !_showAnswer;
    });
  }

  void _markAsKnown() {
    setState(() {
      _knownCount++;
    });
    _nextCard();
  }

  void _markAsUnknown() {
    setState(() {
      _unknownCount++;
    });
    _nextCard();
  }

  void _nextCard() {
    _swipeController.forward().then((_) {
      setState(() {
        if (_currentCardIndex < _flashcards.length - 1) {
          _currentCardIndex++;
          _isFlipped = false;
          _showAnswer = false;
        } else {
          _showCompletionDialog();
        }
      });
      _flipController.reset();
      _swipeController.reset();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final totalCards = _flashcards.length;
        final masteryRate = (_knownCount / totalCards * 100).round();
        
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: masteryRate >= 70
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFFFFC107), const Color(0xFFF59E0B)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    masteryRate >= 70 ? Icons.star_rounded : Icons.replay_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  masteryRate >= 70 ? '훌륭해요!' : '계속 연습해요!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '학습 완료율: $masteryRate%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF525252),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_knownCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const Text(
                          '알고 있음',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF737373),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_unknownCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const Text(
                          '모르겠음',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF737373),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentCardIndex = 0;
                            _knownCount = 0;
                            _unknownCount = 0;
                            _isFlipped = false;
                            _showAnswer = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF638ECB),
                          ),
                        ),
                        child: const Text('다시 학습'),
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
    final size = MediaQuery.of(context).size;
    final currentCard = _currentCardIndex < _flashcards.length
        ? _flashcards[_currentCardIndex]
        : _flashcards.last;
    
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
              
              // Progress
              _buildProgress(),
              
              // Flashcard
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _flipCard,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        _markAsUnknown();
                      } else if (details.primaryVelocity! < 0) {
                        _markAsKnown();
                      }
                    },
                    child: SlideTransition(
                      position: _swipeAnimation,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final isShowingFront = _flipAnimation.value < 0.5;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_flipAnimation.value * math.pi),
                            child: Container(
                              width: size.width * 0.85,
                              height: size.height * 0.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: isShowingFront
                                  ? _buildCardFront(currentCard)
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(math.pi),
                                      child: _buildCardBack(currentCard),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // Action Buttons
              _buildActionButtons(),
              
              const SizedBox(height: 20),
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
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.flashcardSet?.title ?? '플래시카드',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626), // gray800
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () {
              setState(() {
                _flashcards.shuffle();
                _currentCardIndex = 0;
                _knownCount = 0;
                _unknownCount = 0;
                _isFlipped = false;
                _showAnswer = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentCardIndex + 1} / ${_flashcards.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF525252),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_knownCount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_unknownCount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentCardIndex + 1) / _flashcards.length,
            backgroundColor: const Color(0xFFE5E5E5),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF638ECB),
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(FlashCard card) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(card.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getCategoryColor(card.category),
                width: 1,
              ),
            ),
            child: Text(
              card.category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getCategoryColor(card.category),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Question
          Text(
            card.question,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 20,
                color: const Color(0xFF737373).withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                '탭하여 답 확인',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF737373).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(FlashCard card) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF638ECB).withValues(alpha: 0.1),
            const Color(0xFF8AAEE0).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Answer Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '정답',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Answer
          Text(
            card.answer,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Review Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 16,
                color: const Color(0xFF737373).withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '${card.reviewCount}번 복습함',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF737373).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Don't Know Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _markAsUnknown,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 32,
              ),
            ),
          ),
          
          // Flip Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _flipCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF638ECB),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
              ),
              child: Icon(
                _isFlipped ? Icons.flip_to_front : Icons.flip_to_back,
                size: 36,
              ),
            ),
          ),
          
          // Know Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _markAsKnown,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 32,
              ),
            ),
          ),
        ],
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
}

class FlashCard {
  final String id;
  final String question;
  final String answer;
  final String category;
  final String difficulty;
  final DateTime lastReviewed;
  final int reviewCount;

  FlashCard({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.difficulty,
    required this.lastReviewed,
    required this.reviewCount,
  });
}