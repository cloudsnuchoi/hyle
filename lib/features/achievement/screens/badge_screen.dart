import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BadgeScreen extends ConsumerStatefulWidget {
  const BadgeScreen({super.key});

  @override
  ConsumerState<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends ConsumerState<BadgeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _badges = [
    {
      'id': '1',
      'title': 'First Step',
      'description': 'Complete your first lesson',
      'icon': Icons.flag,
      'category': 'Beginner',
      'earned': true,
      'earnedDate': DateTime.now().subtract(const Duration(days: 30)),
      'color': const Color(0xFF8AAEE0),
      'progress': 1.0,
    },
    {
      'id': '2',
      'title': 'Study Streak',
      'description': 'Study for 7 days in a row',
      'icon': Icons.local_fire_department,
      'category': 'Consistency',
      'earned': true,
      'earnedDate': DateTime.now().subtract(const Duration(days: 7)),
      'color': Colors.orange,
      'progress': 1.0,
    },
    {
      'id': '3',
      'title': 'Quiz Master',
      'description': 'Score 90% or higher on 10 quizzes',
      'icon': Icons.emoji_events,
      'category': 'Excellence',
      'earned': false,
      'earnedDate': null,
      'color': const Color(0xFF638ECB),
      'progress': 0.7,
    },
    {
      'id': '4',
      'title': 'Knowledge Seeker',
      'description': 'Complete 50 lessons',
      'icon': Icons.school,
      'category': 'Learning',
      'earned': false,
      'earnedDate': null,
      'color': const Color(0xFF395886),
      'progress': 0.4,
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

    _scaleIn = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
    final earnedCount = _badges.where((b) => b['earned'] == true).length;
    final totalCount = _badges.length;

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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scaleIn.value,
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildProgress(earnedCount, totalCount),
                      _buildCategoryFilter(),
                      Expanded(child: _buildBadgeGrid()),
                    ],
                  ),
                ),
              );
            },
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
              'My Badges',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF395886)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(int earned, int total) {
    final progress = earned / total;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$earned/$total Badges Earned',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF395886),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF638ECB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFD5DEEF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Beginner', 'Consistency', 'Excellence', 'Learning'];
    return Container(
      height: 40,
      margin: const EdgeInsets.all(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = categories[index]);
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

  Widget _buildBadgeGrid() {
    final filteredBadges = _selectedCategory == 'All'
        ? _badges
        : _badges.where((b) => b['category'] == _selectedCategory).toList();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: filteredBadges.length,
      itemBuilder: (context, index) {
        return _buildBadgeCard(filteredBadges[index]);
      },
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final isEarned = badge['earned'] as bool;
    final progress = badge['progress'] as double;

    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isEarned 
                      ? badge['color'].withValues(alpha: 0.1)
                      : const Color(0xFFD5DEEF).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isEarned)
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: const Color(0xFFD5DEEF),
                    valueColor: AlwaysStoppedAnimation<Color>(badge['color']),
                  ),
                ),
              Icon(
                badge['icon'],
                size: 40,
                color: isEarned ? badge['color'] : const Color(0xFFD5DEEF),
              ),
              if (isEarned)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            badge['title'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isEarned ? const Color(0xFF395886) : const Color(0xFF8AAEE0),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge['description'],
            style: TextStyle(
              fontSize: 12,
              color: isEarned ? const Color(0xFF8AAEE0) : const Color(0xFFD5DEEF),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isEarned) ...[
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF638ECB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (isEarned && badge['earnedDate'] != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatDate(badge['earnedDate']),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFD5DEEF),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks ago';
    return '${difference.inDays ~/ 30} months ago';
  }
}