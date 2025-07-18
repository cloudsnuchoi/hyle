import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../models/flashcard_models.dart';
import 'flashcard_edit_screen.dart';
import 'deck_screen.dart';
import 'study_screen.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcardStats = ref.watch(flashcardStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('플래시카드'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: '데크 (${flashcardStats.totalDecks})',
              icon: const Icon(Icons.view_module),
            ),
            Tab(
              text: '카드 (${flashcardStats.activeCards})',
              icon: const Icon(Icons.credit_card),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DecksTab(),
          _CardsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(),
    );
  }
  
  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateDialog(),
    );
  }
}

class _DecksTab extends ConsumerWidget {
  const _DecksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(activeDecksProvider);
    
    if (decks.isEmpty) {
      return const _EmptyState(
        icon: Icons.view_module,
        title: '데크가 없습니다',
        subtitle: '첫 번째 플래시카드 데크를 만들어보세요!',
      );
    }
    
    return _DecksGrid(decks: decks);
  }
}

class _CardsTab extends ConsumerWidget {
  const _CardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(filteredFlashcardsProvider);
    
    if (cards.isEmpty) {
      return const _EmptyState(
        icon: Icons.credit_card,
        title: '플래시카드가 없습니다',
        subtitle: '첫 번째 플래시카드를 만들어보세요!',
      );
    }
    
    return _CardsGrid(cards: cards);
  }
}

class _DecksGrid extends StatelessWidget {
  final List<FlashcardDeck> decks;
  
  const _DecksGrid({required this.decks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingMD,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: decks.length,
        itemBuilder: (context, index) {
          final deck = decks[index];
          return _DeckCard(deck: deck)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 100))
            .slideY(begin: 0.3, duration: 300.ms);
        },
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  final List<Flashcard> cards;
  
  const _CardsGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingMD,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return _FlashcardCard(card: card)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 100))
            .slideY(begin: 0.3, duration: 300.ms);
        },
      ),
    );
  }
}

class _DeckCard extends ConsumerWidget {
  final FlashcardDeck deck;
  
  const _DeckCard({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckCards = ref.watch(deckCardsProvider(deck.id));
    
    return Card(
      color: deck.color.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeckScreen(deck: deck),
            ),
          );
        },
        onLongPress: () {
          _showDeckOptions(context, ref, deck);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.view_module,
                    color: deck.color,
                    size: 24,
                  ),
                  const Spacer(),
                  if (deck.isFavorite)
                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                ],
              ),
              
              AppSpacing.verticalGapMD,
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: AppTypography.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      deck.description,
                      style: AppTypography.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.verticalGapMD,
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${deckCards.length} 카드',
                    style: AppTypography.caption.copyWith(
                      color: deck.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    deck.subject,
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDeckOptions(BuildContext context, WidgetRef ref, FlashcardDeck deck) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DeckOptionsSheet(deck: deck),
    );
  }
}

class _FlashcardCard extends ConsumerWidget {
  final Flashcard card;
  
  const _FlashcardCard({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardEditScreen(card: card),
            ),
          );
        },
        onLongPress: () {
          _showCardOptions(context, ref, card);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: card.difficultyColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  if (card.isFavorite)
                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                ],
              ),
              
              AppSpacing.verticalGapMD,
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.front,
                      style: AppTypography.titleSmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      card.back,
                      style: AppTypography.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.verticalGapMD,
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.subject,
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (card.timesReviewed > 0)
                    Text(
                      '${(card.accuracyRate * 100).toInt()}%',
                      style: AppTypography.caption.copyWith(
                        color: card.accuracyRate > 0.7 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              
              if (card.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 4,
                    children: card.tags.take(2).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTypography.caption.copyWith(fontSize: 9),
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showCardOptions(BuildContext context, WidgetRef ref, Flashcard card) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CardOptionsSheet(card: card),
    );
  }
}

class _DeckOptionsSheet extends ConsumerWidget {
  final FlashcardDeck deck;
  
  const _DeckOptionsSheet({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.paddingMD,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('학습 시작'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudyScreen(deckId: deck.id),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('데크 편집'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to deck edit screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('삭제', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, deck);
            },
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, FlashcardDeck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데크 삭제'),
        content: const Text('이 데크를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(deckProvider.notifier).deleteDeck(deck.id);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CardOptionsSheet extends ConsumerWidget {
  final Flashcard card;
  
  const _CardOptionsSheet({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.paddingMD,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(card.isFavorite ? Icons.favorite : Icons.favorite_border),
            title: Text(card.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가'),
            onTap: () {
              ref.read(flashcardProvider.notifier).toggleFavorite(card.id);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('보관하기'),
            onTap: () {
              ref.read(flashcardProvider.notifier).archiveCard(card.id);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('삭제', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, card);
            },
          ),
        ],
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          AppSpacing.verticalGapMD,
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          AppSpacing.verticalGapSM,
          Text(
            subtitle,
            style: AppTypography.body.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<_SearchDialog> {
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('플래시카드 검색'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '앞면, 뒷면, 태그로 검색',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          ref.read(flashcardSearchProvider.notifier).state = value;
        },
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(flashcardSearchProvider.notifier).state = '';
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('검색'),
        ),
      ],
    );
  }
}

class _CreateDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('새로 만들기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('플래시카드'),
            subtitle: const Text('새로운 플래시카드를 만듭니다'),
            onTap: () {
              Navigator.pop(context);
              _createBlankCard(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('데크'),
            subtitle: const Text('새로운 데크를 만듭니다'),
            onTap: () {
              Navigator.pop(context);
              _createBlankDeck(context, ref);
            },
          ),
        ],
      ),
    );
  }
  
  void _createBlankCard(BuildContext context, WidgetRef ref) {
    final card = Flashcard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      front: '',
      back: '',
      subject: 'General',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditScreen(card: card, isNew: true),
      ),
    );
  }
  
  void _createBlankDeck(BuildContext context, WidgetRef ref) {
    // Navigate to deck creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데크 생성 기능은 곧 추가될 예정입니다')),
    );
  }
}