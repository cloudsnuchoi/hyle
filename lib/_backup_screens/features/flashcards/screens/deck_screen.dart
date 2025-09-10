import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../models/flashcard_models.dart';
import 'flashcard_edit_screen.dart';
import 'study_screen.dart';

class DeckScreen extends ConsumerWidget {
  final FlashcardDeck deck;
  
  const DeckScreen({super.key, required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckCards = ref.watch(deckCardsProvider(deck.id));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to deck edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('데크 편집 기능은 곧 추가될 예정입니다')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Deck Info Header
          Container(
            margin: AppSpacing.paddingMD,
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              color: deck.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: deck.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.view_module,
                      color: deck.color,
                      size: 32,
                    ),
                    AppSpacing.horizontalGapMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deck.name,
                            style: AppTypography.titleLarge,
                          ),
                          Text(
                            deck.subject,
                            style: AppTypography.caption.copyWith(
                              color: deck.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (deck.isFavorite)
                      const Icon(Icons.favorite, color: Colors.red),
                  ],
                ),
                
                if (deck.description.isNotEmpty) ...[
                  AppSpacing.verticalGapMD,
                  Text(
                    deck.description,
                    style: AppTypography.body,
                  ),
                ],
                
                AppSpacing.verticalGapLG,
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      '총 카드',
                      '${deckCards.length}',
                      Icons.credit_card,
                    ),
                    _buildStatItem(
                      context,
                      '평균 정답률',
                      '${_getAverageAccuracy(deckCards)}%',
                      Icons.trending_up,
                    ),
                    _buildStatItem(
                      context,
                      '생성일',
                      _formatDate(deck.createdAt),
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: deckCards.isNotEmpty ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudyScreen(deckId: deck.id),
                        ),
                      );
                    } : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('학습 시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deck.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                AppSpacing.horizontalGapMD,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showAddCardDialog(context, ref);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('카드 추가'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: deck.color),
                      foregroundColor: deck.color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Cards List
          Expanded(
            child: deckCards.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: AppSpacing.paddingMD,
                    itemCount: deckCards.length,
                    separatorBuilder: (context, index) => AppSpacing.verticalGapSM,
                    itemBuilder: (context, index) {
                      final card = deckCards[index];
                      return _DeckCardItem(
                        card: card,
                        deckColor: deck.color,
                        onRemove: () {
                          ref.read(deckProvider.notifier).removeCardFromDeck(deck.id, card.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: deck.color,
          size: 24,
        ),
        AppSpacing.verticalGapSM,
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: deck.color,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 80,
            color: Colors.grey.shade300,
          ),
          AppSpacing.verticalGapMD,
          Text(
            '카드가 없습니다',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          AppSpacing.verticalGapSM,
          Text(
            '첫 번째 플래시카드를 추가해보세요!',
            style: AppTypography.body.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 추가'),
        content: const Text('새로운 카드를 만들거나 기존 카드를 추가할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createNewCard(context, ref);
            },
            child: const Text('새 카드 만들기'),
          ),
        ],
      ),
    );
  }
  
  void _createNewCard(BuildContext context, WidgetRef ref) {
    final card = Flashcard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      front: '',
      back: '',
      subject: deck.subject,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditScreen(card: card, isNew: true),
      ),
    ).then((_) {
      // Add card to deck after creation
      ref.read(deckProvider.notifier).addCardToDeck(deck.id, card.id);
    });
  }
  
  int _getAverageAccuracy(List<Flashcard> cards) {
    if (cards.isEmpty) return 0;
    
    final reviewedCards = cards.where((card) => card.timesReviewed > 0);
    if (reviewedCards.isEmpty) return 0;
    
    final totalAccuracy = reviewedCards.fold<double>(
      0.0,
      (sum, card) => sum + card.accuracyRate,
    );
    
    return (totalAccuracy / reviewedCards.length * 100).round();
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class _DeckCardItem extends ConsumerWidget {
  final Flashcard card;
  final Color deckColor;
  final VoidCallback onRemove;
  
  const _DeckCardItem({
    required this.card,
    required this.deckColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: card.difficultyColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          card.front.isNotEmpty ? card.front : '제목 없음',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          card.back.isNotEmpty ? card.back : '내용 없음',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (card.timesReviewed > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: card.accuracyRate > 0.7 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(card.accuracyRate * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showCardOptions(context, ref, card);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardEditScreen(card: card),
            ),
          );
        },
      ),
    );
  }
  
  void _showCardOptions(BuildContext context, WidgetRef ref, Flashcard card) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.paddingMD,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('카드 편집'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardEditScreen(card: card),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('데크에서 제거'),
              onTap: () {
                Navigator.pop(context);
                onRemove();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('카드 삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, card);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Flashcard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 삭제'),
        content: const Text('이 플래시카드를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(flashcardProvider.notifier).deleteCard(card.id);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}