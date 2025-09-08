import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _rankAnimationController;
  late Animation<double> _rankAnimation;
  
  String _selectedPeriod = 'weekly';
  String _selectedSubject = 'all';
  
  final List<LeaderboardEntry> _globalLeaderboard = [
    LeaderboardEntry(
      rank: 1,
      name: '김민준',
      avatar: '👨‍🎓',
      points: 15420,
      level: 42,
      streak: 180,
      isCurrentUser: false,
      change: 0,
      achievements: 89,
    ),
    LeaderboardEntry(
      rank: 2,
      name: '이서연',
      avatar: '👩‍🎓',
      points: 14850,
      level: 41,
      streak: 165,
      isCurrentUser: false,
      change: 1,
      achievements: 85,
    ),
    LeaderboardEntry(
      rank: 3,
      name: '박지호',
      avatar: '🧑‍🎓',
      points: 14200,
      level: 40,
      streak: 150,
      isCurrentUser: false,
      change: -1,
      achievements: 82,
    ),
    LeaderboardEntry(
      rank: 4,
      name: '최예은',
      avatar: '👩‍💼',
      points: 13500,
      level: 38,
      streak: 140,
      isCurrentUser: false,
      change: 2,
      achievements: 78,
    ),
    LeaderboardEntry(
      rank: 5,
      name: '나 (현재 사용자)',
      avatar: '🎯',
      points: 12800,
      level: 36,
      streak: 120,
      isCurrentUser: true,
      change: 3,
      achievements: 75,
    ),
  ];
  
  final List<LeaderboardEntry> _friendsLeaderboard = [
    LeaderboardEntry(
      rank: 1,
      name: '나 (현재 사용자)',
      avatar: '🎯',
      points: 12800,
      level: 36,
      streak: 120,
      isCurrentUser: true,
      change: 1,
      achievements: 75,
    ),
    LeaderboardEntry(
      rank: 2,
      name: '김철수',
      avatar: '👨‍💻',
      points: 11500,
      level: 33,
      streak: 90,
      isCurrentUser: false,
      change: -1,
      achievements: 65,
    ),
    LeaderboardEntry(
      rank: 3,
      name: '이영희',
      avatar: '👩‍🏫',
      points: 10200,
      level: 30,
      streak: 75,
      isCurrentUser: false,
      change: 0,
      achievements: 58,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _rankAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rankAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rankAnimationController,
      curve: Curves.easeOutBack,
    ));
    _rankAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rankAnimationController.dispose();
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
                      '리더보드',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Color(0xFF638ECB)),
                      onPressed: () => _showRankingInfo(),
                    ),
                  ],
                ),
              ),

              // Filter Row
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('주간', 'weekly'),
                    const SizedBox(width: 8),
                    _buildFilterChip('월간', 'monthly'),
                    const SizedBox(width: 8),
                    _buildFilterChip('전체', 'all'),
                    const SizedBox(width: 16),
                    Container(
                      width: 1,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    const SizedBox(width: 16),
                    _buildSubjectChip('전체', 'all'),
                    const SizedBox(width: 8),
                    _buildSubjectChip('수학', 'math'),
                    const SizedBox(width: 8),
                    _buildSubjectChip('영어', 'english'),
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
                    Tab(text: '전체 순위'),
                    Tab(text: '친구 순위'),
                    Tab(text: '그룹 순위'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Leaderboard Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeaderboardList(_globalLeaderboard),
                    _buildLeaderboardList(_friendsLeaderboard),
                    _buildGroupLeaderboard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF638ECB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectChip(String label, String value) {
    final isSelected = _selectedSubject == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubject = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8AAEE0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final delay = index * 100;
        
        return AnimatedBuilder(
          animation: _rankAnimation,
          builder: (context, child) {
            final animationValue = _rankAnimation.value;
            final itemAnimation = Curves.easeOutQuart.transform(
              (animationValue - (delay / 1000)).clamp(0.0, 1.0),
            );
            
            return Transform.translate(
              offset: Offset(0, 20 * (1 - itemAnimation)),
              child: Opacity(
                opacity: itemAnimation,
                child: _buildLeaderboardItem(entry),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    Color rankColor;
    if (entry.rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (entry.rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else if (entry.rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: entry.isCurrentUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF638ECB).withValues(alpha: 0.1),
                  const Color(0xFF8AAEE0).withValues(alpha: 0.05),
                ],
              )
            : const LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
        borderRadius: BorderRadius.circular(16),
        border: entry.isCurrentUser
            ? Border.all(color: const Color(0xFF638ECB), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: entry.isCurrentUser
                ? const Color(0xFF638ECB).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showUserDetail(entry),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: entry.rank <= 3
                        ? Icon(
                            Icons.emoji_events,
                            color: rankColor,
                            size: 24,
                          )
                        : Text(
                            '${entry.rank}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: rankColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8AAEE0).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8AAEE0).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.avatar,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: entry.isCurrentUser
                                  ? const Color(0xFF638ECB)
                                  : const Color(0xFF1A1E27),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lv.${entry.level}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF638ECB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.points.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )} XP',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.streak}일',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Change Indicator
                if (entry.change != 0)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: entry.change > 0
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      entry.change > 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                      color: entry.change > 0 ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupLeaderboard() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildGroupCard(
          '알고리즘 스터디',
          '15명',
          45680,
          1,
          const Color(0xFFFFD700),
        ),
        _buildGroupCard(
          '영어 회화 모임',
          '12명',
          38920,
          2,
          const Color(0xFFC0C0C0),
        ),
        _buildGroupCard(
          '수학 올림피아드',
          '8명',
          35200,
          3,
          const Color(0xFFCD7F32),
        ),
        _buildGroupCard(
          '코딩 부트캠프',
          '20명',
          32100,
          4,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildGroupCard(String name, String members, int totalPoints, int rank, Color rankColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: rank <= 3
                        ? Icon(
                            Icons.emoji_events,
                            color: rankColor,
                            size: 24,
                          )
                        : Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: rankColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Group Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF638ECB).withValues(alpha: 0.2),
                        const Color(0xFF8AAEE0).withValues(alpha: 0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups,
                    color: Color(0xFF638ECB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1E27),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            members,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${totalPoints.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )} XP',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDetail(LeaderboardEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar and Name
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8AAEE0).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF638ECB),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        entry.avatar,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E27),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Level ${entry.level}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF638ECB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(Icons.star, '${entry.points}', 'XP', Colors.amber),
                      _buildStatItem(Icons.local_fire_department, '${entry.streak}', '연속', Colors.orange),
                      _buildStatItem(Icons.emoji_events, '${entry.achievements}', '업적', const Color(0xFF638ECB)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add, size: 20),
                          label: const Text('친구 추가'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF638ECB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                          label: const Text('메시지'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF638ECB),
                            side: const BorderSide(color: Color(0xFF638ECB)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1E27),
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

  void _showRankingInfo() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '순위 산정 기준',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem('경험치 (XP)', '학습 활동으로 획득한 총 포인트'),
              _buildInfoItem('레벨', '누적 경험치에 따른 사용자 레벨'),
              _buildInfoItem('연속 학습', '매일 학습한 연속 일수'),
              _buildInfoItem('업적', '완료한 도전 과제 수'),
              const SizedBox(height: 24),
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

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF638ECB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Leaderboard Entry Model
class LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int points;
  final int level;
  final int streak;
  final bool isCurrentUser;
  final int change;
  final int achievements;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.points,
    required this.level,
    required this.streak,
    required this.isCurrentUser,
    required this.change,
    required this.achievements,
  });
}