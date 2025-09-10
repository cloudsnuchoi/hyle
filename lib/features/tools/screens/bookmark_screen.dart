import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkScreen extends ConsumerStatefulWidget {
  const BookmarkScreen({super.key});

  @override
  ConsumerState<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends ConsumerState<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  
  String _selectedFilter = '전체';

  final List<Map<String, dynamic>> _bookmarks = [
    {
      'id': '1',
      'title': '고급 미적분학 5장',
      'type': 'lesson',
      'subject': '수학',
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '2',
      'title': '물리학 퀴즈 - 열역학',
      'type': 'quiz',
      'subject': '물리학',
      'date': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': '3',
      'title': '영문학 에세이 가이드',
      'type': 'resource',
      'subject': '영어',
      'date': DateTime.now().subtract(const Duration(days: 7)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              Color(0xFF395886),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                _buildHeader(),
                _buildFilterChips(),
                Expanded(child: _buildBookmarkList()),
              ],
            ),
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
              '북마크',
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['전체', '수업', '퀴즈', '자료'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filters[index]);
              },
              selectedColor: const Color(0xFF638ECB),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF395886),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        return _buildBookmarkCard(_bookmarks[index]);
      },
    );
  }

  Widget _buildBookmarkCard(Map<String, dynamic> bookmark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTypeColor(bookmark['type']).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(bookmark['type']),
              color: _getTypeColor(bookmark['type']),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookmark['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      bookmark['subject'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8AAEE0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(bookmark['date']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD5DEEF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_remove, color: Color(0xFF638ECB)),
            onPressed: () {
              setState(() {
                _bookmarks.removeWhere((b) => b['id'] == bookmark['id']);
              });
            },
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'lesson':
        return Icons.menu_book;
      case 'quiz':
        return Icons.quiz;
      case 'resource':
        return Icons.folder;
      default:
        return Icons.bookmark;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'lesson':
        return const Color(0xFF8AAEE0);
      case 'quiz':
        return const Color(0xFF638ECB);
      case 'resource':
        return const Color(0xFF395886);
      default:
        return const Color(0xFF8AAEE0);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return '오늘';
    if (difference.inDays == 1) return '어제';
    return '${difference.inDays}일 전';
  }
}