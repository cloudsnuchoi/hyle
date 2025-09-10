import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FlashcardListScreen extends ConsumerStatefulWidget {
  const FlashcardListScreen({super.key});

  @override
  ConsumerState<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends ConsumerState<FlashcardListScreen> {
  String _selectedCategory = '전체';
  
  // Mock flashcard sets data
  final List<FlashcardSet> _flashcardSets = [
    FlashcardSet(
      id: '1',
      title: '수학 공식 모음',
      description: '미적분, 대수, 기하 기본 공식',
      category: '수학',
      cardCount: 45,
      difficulty: 'medium',
      lastStudied: DateTime.now().subtract(const Duration(hours: 3)),
      progress: 0.75,
      color: const Color(0xFF638ECB),
      icon: Icons.calculate,
    ),
    FlashcardSet(
      id: '2',
      title: '프랑스어 기초 단어',
      description: '일상 회화 필수 단어 100선',
      category: '언어',
      cardCount: 100,
      difficulty: 'easy',
      lastStudied: DateTime.now().subtract(const Duration(days: 1)),
      progress: 0.45,
      color: const Color(0xFF8B5CF6),
      icon: Icons.language,
    ),
    FlashcardSet(
      id: '3',
      title: '생물학 - 광합성',
      description: '광합성 과정과 화학 반응',
      category: '과학',
      cardCount: 25,
      difficulty: 'hard',
      lastStudied: DateTime.now().subtract(const Duration(days: 2)),
      progress: 0.20,
      color: const Color(0xFF10B981),
      icon: Icons.science,
    ),
    FlashcardSet(
      id: '4',
      title: '한국사 연대표',
      description: '조선시대 주요 사건과 인물',
      category: '역사',
      cardCount: 60,
      difficulty: 'medium',
      lastStudied: DateTime.now().subtract(const Duration(hours: 12)),
      progress: 0.85,
      color: const Color(0xFFF59E0B),
      icon: Icons.history_edu,
    ),
    FlashcardSet(
      id: '5',
      title: 'Python 기초 문법',
      description: '파이썬 프로그래밍 핵심 개념',
      category: '코딩',
      cardCount: 35,
      difficulty: 'easy',
      lastStudied: DateTime.now(),
      progress: 0.60,
      color: const Color(0xFF3B82F6),
      icon: Icons.code,
    ),
    FlashcardSet(
      id: '6',
      title: '영어 숙어 표현',
      description: '토익/토플 빈출 숙어',
      category: '언어',
      cardCount: 80,
      difficulty: 'medium',
      lastStudied: DateTime.now().subtract(const Duration(days: 3)),
      progress: 0.30,
      color: const Color(0xFFEF4444),
      icon: Icons.menu_book,
    ),
    FlashcardSet(
      id: '7',
      title: '화학 원소 주기율표',
      description: '원소 기호와 특성',
      category: '과학',
      cardCount: 118,
      difficulty: 'hard',
      lastStudied: null,
      progress: 0.0,
      color: const Color(0xFF06B6D4),
      icon: Icons.bubble_chart,
    ),
    FlashcardSet(
      id: '8',
      title: '경제학 기본 용어',
      description: '미시/거시 경제학 핵심 개념',
      category: '사회',
      cardCount: 40,
      difficulty: 'medium',
      lastStudied: DateTime.now().subtract(const Duration(days: 5)),
      progress: 0.15,
      color: const Color(0xFF84CC16),
      icon: Icons.trending_up,
    ),
  ];

  List<String> get _categories {
    final categories = ['전체'];
    categories.addAll(_flashcardSets.map((set) => set.category).toSet().toList());
    return categories;
  }

  List<FlashcardSet> get _filteredSets {
    if (_selectedCategory == '전체') {
      return _flashcardSets;
    }
    return _flashcardSets.where((set) => set.category == _selectedCategory).toList();
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
              Color(0xFFE8EDF5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCategoryFilter(),
              _buildStats(),
              Expanded(
                child: _buildFlashcardGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new flashcard set
        },
        backgroundColor: const Color(0xFF638ECB),
        child: const Icon(Icons.add, color: Colors.white),
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
              '플래시카드 목록',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF395886)),
            onPressed: () {
              // Search flashcard sets
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF638ECB) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF638ECB) 
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF525252),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    final totalSets = _filteredSets.length;
    final totalCards = _filteredSets.fold<int>(0, (sum, set) => sum + set.cardCount);
    final avgProgress = _filteredSets.isEmpty ? 0.0 
        : _filteredSets.fold<double>(0, (sum, set) => sum + set.progress) / _filteredSets.length;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFF638ECB).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF638ECB).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.style,
            '$totalSets',
            '세트',
            const Color(0xFF638ECB),
          ),
          _buildStatItem(
            Icons.layers,
            '$totalCards',
            '카드',
            const Color(0xFF8AAEE0),
          ),
          _buildStatItem(
            Icons.trending_up,
            '${(avgProgress * 100).toInt()}%',
            '평균 진도',
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredSets.length,
      itemBuilder: (context, index) {
        final set = _filteredSets[index];
        return _buildFlashcardSetCard(set);
      },
    );
  }

  Widget _buildFlashcardSetCard(FlashcardSet set) {
    return GestureDetector(
      onTap: () {
        // Navigate to flashcard study session
        context.push('/study/flashcard/session', extra: set);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              set.color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: set.color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: set.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      set.icon,
                      color: set.color,
                      size: 24,
                    ),
                  ),
                  _buildDifficultyBadge(set.difficulty),
                ],
              ),
              const Spacer(),
              Text(
                set.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                set.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.layers, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${set.cardCount}장',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: set.category == '수학' ? const Color(0xFF638ECB) 
                          : set.category == '언어' ? const Color(0xFF8B5CF6)
                          : set.category == '과학' ? const Color(0xFF10B981)
                          : set.category == '역사' ? const Color(0xFFF59E0B)
                          : set.category == '코딩' ? const Color(0xFF3B82F6)
                          : const Color(0xFF84CC16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      set.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: set.progress,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(set.color),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '진도: ${(set.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              if (set.lastStudied != null) ...[
                const SizedBox(height: 4),
                Text(
                  '최근 학습: ${_getTimeAgo(set.lastStudied!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String text;
    
    switch (difficulty) {
      case 'easy':
        color = const Color(0xFF10B981);
        text = '쉬움';
        break;
      case 'medium':
        color = const Color(0xFFF59E0B);
        text = '보통';
        break;
      case 'hard':
        color = const Color(0xFFEF4444);
        text = '어려움';
        break;
      default:
        color = Colors.grey;
        text = difficulty;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

// Model class for Flashcard Set
class FlashcardSet {
  final String id;
  final String title;
  final String description;
  final String category;
  final int cardCount;
  final String difficulty;
  final DateTime? lastStudied;
  final double progress;
  final Color color;
  final IconData icon;

  FlashcardSet({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cardCount,
    required this.difficulty,
    this.lastStudied,
    required this.progress,
    required this.color,
    required this.icon,
  });
}