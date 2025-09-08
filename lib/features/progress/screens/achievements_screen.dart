import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _badgeAnimationController;
  late Animation<double> _badgeAnimation;
  
  final List<Achievement> _allAchievements = [
    Achievement(
      id: '1',
      title: '첫 걸음',
      description: '첫 학습 세션 완료',
      icon: Icons.flag,
      category: AchievementCategory.learning,
      points: 10,
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 30)),
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: '2',
      title: '꾸준한 학습자',
      description: '7일 연속 학습',
      icon: Icons.local_fire_department,
      category: AchievementCategory.streak,
      points: 50,
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 7)),
      rarity: AchievementRarity.rare,
    ),
    Achievement(
      id: '3',
      title: '퀴즈 마스터',
      description: '퀴즈 100점 달성',
      icon: Icons.emoji_events,
      category: AchievementCategory.quiz,
      points: 30,
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 2)),
      rarity: AchievementRarity.epic,
    ),
    Achievement(
      id: '4',
      title: '소셜 학습자',
      description: '스터디 그룹 가입',
      icon: Icons.groups,
      category: AchievementCategory.social,
      points: 20,
      isUnlocked: false,
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: '5',
      title: '멘토',
      description: '다른 학습자 10명 도움',
      icon: Icons.volunteer_activism,
      category: AchievementCategory.social,
      points: 100,
      isUnlocked: false,
      rarity: AchievementRarity.legendary,
    ),
    Achievement(
      id: '6',
      title: '완벽주의자',
      description: '한 과목 완주',
      icon: Icons.school,
      category: AchievementCategory.completion,
      points: 200,
      isUnlocked: false,
      rarity: AchievementRarity.legendary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _badgeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _badgeAnimationController,
      curve: Curves.elasticOut,
    ));
    _badgeAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _badgeAnimationController.dispose();
    super.dispose();
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF8AAEE0);
      case AchievementRarity.rare:
        return const Color(0xFF638ECB);
      case AchievementRarity.epic:
        return const Color(0xFF8B5CF6);
      case AchievementRarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }

  String _getRarityText(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.rare:
        return '희귀';
      case AchievementRarity.epic:
        return '영웅';
      case AchievementRarity.legendary:
        return '전설';
    }
  }

  List<Achievement> _getAchievementsByCategory(AchievementCategory? category) {
    if (category == null) return _allAchievements;
    return _allAchievements.where((a) => a.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _allAchievements.where((a) => a.isUnlocked).length;
    final totalPoints = _allAchievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, a) => sum + a.points);

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
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF395886)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '업적',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        '획득한 업적',
                        '$unlockedCount/${_allAchievements.length}',
                        Icons.emoji_events,
                        const Color(0xFF8AAEE0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatsCard(
                        '총 포인트',
                        totalPoints.toString(),
                        Icons.star,
                        const Color(0xFF638ECB),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF638ECB),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF395886),
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: '전체'),
                    Tab(text: '학습'),
                    Tab(text: '소셜'),
                    Tab(text: '특별'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Achievement Grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAchievementGrid(null),
                    _buildAchievementGrid(AchievementCategory.learning),
                    _buildAchievementGrid(AchievementCategory.social),
                    _buildAchievementGrid(AchievementCategory.special),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid(AchievementCategory? category) {
    final achievements = _getAchievementsByCategory(category);
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return ScaleTransition(
          scale: _badgeAnimation,
          child: _buildAchievementCard(achievement),
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final rarityColor = _getRarityColor(achievement.rarity);
    
    return Container(
      decoration: BoxDecoration(
        gradient: achievement.isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  rarityColor.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: achievement.isUnlocked ? null : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: achievement.isUnlocked
            ? Border.all(color: rarityColor.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: achievement.isUnlocked
                ? rarityColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: achievement.isUnlocked
              ? () => _showAchievementDetail(achievement)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? rarityColor.withValues(alpha: 0.1)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icon,
                    size: 30,
                    color: achievement.isUnlocked
                        ? rarityColor
                        : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Title
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? const Color(0xFF1A1E27)
                        : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Description
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: achievement.isUnlocked
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Points & Rarity
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? rarityColor.withValues(alpha: 0.1)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: achievement.isUnlocked
                            ? rarityColor
                            : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${achievement.points}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: achievement.isUnlocked
                              ? rarityColor
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (achievement.isUnlocked && achievement.unlockedDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(achievement.unlockedDate!),
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
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getRarityColor(achievement.rarity).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  size: 40,
                  color: _getRarityColor(achievement.rarity),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              const SizedBox(height: 8),
              
              // Rarity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRarityColor(achievement.rarity).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRarityText(achievement.rarity),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getRarityColor(achievement.rarity),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Points
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 20,
                    color: _getRarityColor(achievement.rarity),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${achievement.points} 포인트',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E27),
                    ),
                  ),
                ],
              ),
              
              if (achievement.unlockedDate != null) ...[
                const SizedBox(height: 16),
                Text(
                  '획득일: ${_formatDate(achievement.unlockedDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF638ECB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final AchievementRarity rarity;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.points,
    required this.isUnlocked,
    this.unlockedDate,
    required this.rarity,
  });
}

enum AchievementCategory {
  learning,
  streak,
  quiz,
  social,
  completion,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}