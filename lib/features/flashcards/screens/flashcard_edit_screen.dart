import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../models/flashcard_models.dart';

class FlashcardEditScreen extends ConsumerStatefulWidget {
  final Flashcard card;
  final bool isNew;
  
  const FlashcardEditScreen({
    super.key,
    required this.card,
    this.isNew = false,
  });

  @override
  ConsumerState<FlashcardEditScreen> createState() => _FlashcardEditScreenState();
}

class _FlashcardEditScreenState extends ConsumerState<FlashcardEditScreen> {
  late TextEditingController _frontController;
  late TextEditingController _backController;
  late TextEditingController _tagController;
  late Flashcard _currentCard;
  
  bool _hasChanges = false;
  bool _isFlipped = false;
  
  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _frontController = TextEditingController(text: _currentCard.front);
    _backController = TextEditingController(text: _currentCard.back);
    _tagController = TextEditingController();
    
    _frontController.addListener(_onTextChanged);
    _backController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? '새 플래시카드' : '플래시카드 편집'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _currentCard.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _currentCard.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _currentCard = _currentCard.copyWith(isFavorite: !_currentCard.isFavorite);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip),
            onPressed: () {
              setState(() {
                _isFlipped = !_isFlipped;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCard,
          ),
        ],
      ),
      body: Column(
        children: [
          // Card Settings
          Container(
            padding: AppSpacing.paddingMD,
            child: Column(
              children: [
                // Subject and Difficulty Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currentCard.subject,
                        decoration: const InputDecoration(
                          labelText: '과목',
                          border: OutlineInputBorder(),
                        ),
                        items: _getSubjectItems(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _currentCard = _currentCard.copyWith(subject: value);
                            });
                          }
                        },
                      ),
                    ),
                    AppSpacing.horizontalGapMD,
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currentCard.difficulty,
                        decoration: const InputDecoration(
                          labelText: '난이도',
                          border: OutlineInputBorder(),
                        ),
                        items: _getDifficultyItems(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _currentCard = _currentCard.copyWith(difficulty: value);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                
                AppSpacing.verticalGapMD,
                
                // Tags Section
                _buildTagsSection(),
              ],
            ),
          ),
          
          // Card Preview/Edit
          Expanded(
            child: Container(
              margin: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isFlipped ? _buildBackCard() : _buildFrontCard(),
              ),
            ),
          ),
          
          // Bottom Stats
          if (!widget.isNew)
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('복습 횟수', '${_currentCard.timesReviewed}'),
                  _buildStatItem('정답률', '${(_currentCard.accuracyRate * 100).toInt()}%'),
                  _buildStatItem('마지막 복습', _getLastReviewedText()),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildFrontCard() {
    return Container(
      key: const ValueKey('front'),
      padding: AppSpacing.paddingLG,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '앞면',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _currentCard.difficultyColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          
          AppSpacing.verticalGapLG,
          
          Expanded(
            child: TextField(
              controller: _frontController,
              decoration: const InputDecoration(
                hintText: '질문을 입력하세요',
                border: InputBorder.none,
              ),
              style: AppTypography.titleMedium,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackCard() {
    return Container(
      key: const ValueKey('back'),
      padding: AppSpacing.paddingLG,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '뒷면',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _currentCard.difficultyColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          
          AppSpacing.verticalGapLG,
          
          Expanded(
            child: TextField(
              controller: _backController,
              decoration: const InputDecoration(
                hintText: '답을 입력하세요',
                border: InputBorder.none,
              ),
              style: AppTypography.titleMedium,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: '태그 추가',
                  border: OutlineInputBorder(),
                  hintText: '태그를 입력하고 Enter를 누르세요',
                ),
                onSubmitted: _addTag,
              ),
            ),
            AppSpacing.horizontalGapMD,
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_tagController.text),
            ),
          ],
        ),
        
        if (_currentCard.tags.isNotEmpty) ...[
          AppSpacing.verticalGapSM,
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _currentCard.tags.map((tag) => Chip(
              label: Text('#$tag'),
              onDeleted: () => _removeTag(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
            )).toList(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }
  
  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_currentCard.tags.contains(tag.trim())) {
      setState(() {
        _currentCard = _currentCard.copyWith(
          tags: [..._currentCard.tags, tag.trim()],
        );
        _tagController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _currentCard = _currentCard.copyWith(
        tags: _currentCard.tags.where((t) => t != tag).toList(),
      );
    });
  }
  
  void _saveCard() {
    final updatedCard = _currentCard.copyWith(
      front: _frontController.text.trim(),
      back: _backController.text.trim(),
      updatedAt: DateTime.now(),
    );
    
    if (widget.isNew) {
      ref.read(flashcardProvider.notifier).addCard(updatedCard);
    } else {
      ref.read(flashcardProvider.notifier).updateCard(updatedCard);
    }
    
    setState(() {
      _hasChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('플래시카드가 저장되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
  
  List<DropdownMenuItem<String>> _getSubjectItems() {
    final subjects = [
      'General',
      'Math',
      'English',
      'Science',
      'History',
      'Literature',
      'Geography',
      'Art',
      'Music',
      'Technology',
      'Language',
      'Other',
    ];
    
    return subjects.map((subject) => DropdownMenuItem(
      value: subject,
      child: Text(subject),
    )).toList();
  }
  
  List<DropdownMenuItem<String>> _getDifficultyItems() {
    final difficulties = [
      {'value': 'easy', 'label': '쉬움', 'color': Colors.green},
      {'value': 'medium', 'label': '보통', 'color': Colors.orange},
      {'value': 'hard', 'label': '어려움', 'color': Colors.red},
    ];
    
    return difficulties.map((difficulty) => DropdownMenuItem(
      value: difficulty['value'] as String,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: difficulty['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.horizontalGapSM,
          Text(difficulty['label'] as String),
        ],
      ),
    )).toList();
  }
  
  String _getLastReviewedText() {
    if (_currentCard.lastReviewed == null) return '없음';
    
    final now = DateTime.now();
    final diff = now.difference(_currentCard.lastReviewed!);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}