import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../models/flashcard_models.dart';

class StudyScreen extends ConsumerStatefulWidget {
  final String deckId;
  
  const StudyScreen({super.key, required this.deckId});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  
  bool _isFlipped = false;
  bool _showAnswer = false;
  int _currentIndex = 0;
  List<Flashcard> _studyCards = [];
  Map<String, bool> _answers = {};
  DateTime? _sessionStartTime;
  
  @override
  void initState() {
    super.initState();
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
    
    _initializeStudySession();
  }
  
  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }
  
  void _initializeStudySession() {
    final cards = ref.read(deckCardsProvider(widget.deckId));
    setState(() {
      _studyCards = List.from(cards)..shuffle();
      _currentIndex = 0;
      _sessionStartTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_studyCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('학습'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.credit_card,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '학습할 카드가 없습니다',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_currentIndex >= _studyCards.length) {
      return _buildCompletionScreen();
    }
    
    final currentCard = _studyCards[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_studyCards.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _studyCards.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          
          // Card Area
          Expanded(
            child: Padding(
              padding: AppSpacing.paddingLG,
              child: Center(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final isShowingFront = _flipAnimation.value < 0.5;
                      
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_flipAnimation.value * 3.14159),
                        child: Card(
                          elevation: 8,
                          child: Container(
                            width: double.infinity,
                            height: 400,
                            padding: AppSpacing.paddingLG,
                            child: isShowingFront
                                ? _buildCardFront(currentCard)
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(3.14159),
                                    child: _buildCardBack(currentCard),
                                  ),
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
          Container(
            padding: AppSpacing.paddingLG,
            child: _showAnswer
                ? _buildAnswerButtons(currentCard)
                : _buildFlipButton(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCardFront(Flashcard card) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '질문',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: card.difficultyColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        
        AppSpacing.verticalGapLG,
        
        Expanded(
          child: Center(
            child: Text(
              card.front,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        AppSpacing.verticalGapMD,
        
        const Text(
          '탭하여 답 확인',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCardBack(Flashcard card) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '답',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: card.difficultyColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        
        AppSpacing.verticalGapLG,
        
        Expanded(
          child: Center(
            child: Text(
              card.back,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        if (card.tags.isNotEmpty) ...[
          AppSpacing.verticalGapMD,
          Wrap(
            spacing: 8,
            children: card.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#$tag',
                style: AppTypography.caption,
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildFlipButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _flipCard,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flip),
            SizedBox(width: 8),
            Text('답 확인하기', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnswerButtons(Flashcard card) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _answerCard(card, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close),
                  SizedBox(width: 8),
                  Text('틀렸어요', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
        
        AppSpacing.horizontalGapMD,
        
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _answerCard(card, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('맞았어요', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompletionScreen() {
    final correctAnswers = _answers.values.where((answer) => answer).length;
    final totalCards = _answers.length;
    final accuracy = totalCards > 0 ? (correctAnswers / totalCards) : 0.0;
    final xpEarned = _calculateXPEarned(correctAnswers, totalCards);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 완료'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: accuracy >= 0.8 ? Colors.green : accuracy >= 0.6 ? Colors.orange : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                accuracy >= 0.8 ? Icons.star : accuracy >= 0.6 ? Icons.thumb_up : Icons.refresh,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            Text(
              accuracy >= 0.8 ? '훌륭해요!' : accuracy >= 0.6 ? '좋아요!' : '다시 도전해보세요!',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            
            AppSpacing.verticalGapLG,
            
            Card(
              child: Padding(
                padding: AppSpacing.paddingLG,
                child: Column(
                  children: [
                    _buildResultItem('정답률', '${(accuracy * 100).toInt()}%'),
                    _buildResultItem('정답 수', '$correctAnswers / $totalCards'),
                    _buildResultItem('획득 XP', '+$xpEarned XP'),
                    if (_sessionStartTime != null)
                      _buildResultItem('학습 시간', _getStudyTimeText()),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _restartStudy(),
                    child: const Text('다시 학습'),
                  ),
                ),
                AppSpacing.horizontalGapMD,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _finishStudy(),
                    child: const Text('완료'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
      setState(() {
        _showAnswer = false;
      });
    } else {
      _flipController.forward();
      setState(() {
        _showAnswer = true;
      });
    }
    _isFlipped = !_isFlipped;
  }
  
  void _answerCard(Flashcard card, bool isCorrect) {
    // Record answer
    _answers[card.id] = isCorrect;
    
    // Update card statistics
    ref.read(flashcardProvider.notifier).recordAnswer(card.id, isCorrect);
    
    // Move to next card
    setState(() {
      _currentIndex++;
      _isFlipped = false;
      _showAnswer = false;
    });
    
    _flipController.reset();
    
    // Award XP if correct
    if (isCorrect) {
      ref.read(userStatsProvider.notifier).addXP(5); // 5 XP per correct answer
    }
  }
  
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 중단'),
        content: const Text('학습을 중단하시겠습니까? 진행 상황이 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 학습'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('중단'),
          ),
        ],
      ),
    );
  }
  
  void _restartStudy() {
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _showAnswer = false;
      _answers.clear();
      _sessionStartTime = DateTime.now();
      _studyCards.shuffle();
    });
    _flipController.reset();
  }
  
  void _finishStudy() {
    // Save study session
    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deckId: widget.deckId,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      cardIds: _studyCards.map((card) => card.id).toList(),
      answers: _answers,
      totalCards: _studyCards.length,
      correctAnswers: _answers.values.where((answer) => answer).length,
    );
    
    ref.read(studySessionProvider.notifier).addSession(session);
    
    Navigator.pop(context);
  }
  
  int _calculateXPEarned(int correctAnswers, int totalCards) {
    final baseXP = correctAnswers * 5;
    final bonusXP = totalCards == correctAnswers ? 20 : 0; // Perfect score bonus
    return baseXP + bonusXP;
  }
  
  String _getStudyTimeText() {
    if (_sessionStartTime == null) return '0분';
    
    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }
}