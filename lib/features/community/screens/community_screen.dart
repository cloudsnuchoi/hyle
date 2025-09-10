import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<CommunitySection> _sections = [
    CommunitySection(
      title: '스터디 그룹',
      subtitle: '함께 공부하는 동료들',
      icon: Icons.groups,
      color: const Color(0xFF638ECB),
      memberCount: 1234,
      activeNow: 89,
      trending: true,
    ),
    CommunitySection(
      title: '질문 & 답변',
      subtitle: '궁금한 것을 물어보세요',
      icon: Icons.forum,
      color: const Color(0xFF8AAEE0),
      questionCount: 5678,
      answeredRate: 92,
      trending: false,
    ),
    CommunitySection(
      title: '멘토링',
      subtitle: '전문가의 도움받기',
      icon: Icons.school,
      color: const Color(0xFF8B5CF6),
      mentorCount: 45,
      sessionsToday: 12,
      trending: true,
    ),
    CommunitySection(
      title: '이벤트 & 챌린지',
      subtitle: '도전하고 성장하기',
      icon: Icons.emoji_events,
      color: const Color(0xFFF59E0B),
      eventCount: 8,
      participants: 3456,
      trending: true,
    ),
  ];
  
  final List<TrendingTopic> _trendingTopics = [
    TrendingTopic(rank: 1, title: '수능 D-30 대비', posts: 234, change: 5),
    TrendingTopic(rank: 2, title: '토익 900 달성', posts: 189, change: -2),
    TrendingTopic(rank: 3, title: '코딩테스트 준비', posts: 156, change: 3),
    TrendingTopic(rank: 4, title: '영어회화 스터디', posts: 134, change: 0),
    TrendingTopic(rank: 5, title: '수학 공식 정리', posts: 98, change: -1),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF638ECB),
                          Color(0xFF8AAEE0),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '커뮤니티',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '함께 배우고 성장하는 공간',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              // Welcome Card
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFF638ECB).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF638ECB).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '오늘의 커뮤니티',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1E27),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '활발한 토론 참여로\n지식을 넓혀보세요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildStatChip(Icons.people, '1,234명 온라인'),
                                  const SizedBox(width: 12),
                                  _buildStatChip(Icons.chat_bubble, '89개 새 글'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.diversity_3,
                            size: 40,
                            color: Color(0xFF638ECB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Trending Topics
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFF638ECB),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '실시간 인기 토픽',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1E27),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Column(
                          children: _trendingTopics.map((topic) {
                            return _buildTrendingItem(topic);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              // Leaderboard Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.leaderboard,
                            color: Color(0xFFFFC107),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '리더보드',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1E27),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              '전체 보기',
                              style: TextStyle(
                                color: Color(0xFF638ECB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              const Color(0xFFFFC107).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildLeaderboardItem(
                              rank: 1,
                              name: '박지훈',
                              points: 2450,
                              level: 15,
                              avatar: '👑',
                              isCurrentUser: false,
                            ),
                            _buildLeaderboardItem(
                              rank: 2,
                              name: '김서연',
                              points: 2320,
                              level: 14,
                              avatar: '🥈',
                              isCurrentUser: false,
                            ),
                            _buildLeaderboardItem(
                              rank: 3,
                              name: '이준호',
                              points: 2180,
                              level: 13,
                              avatar: '🥉',
                              isCurrentUser: true,
                            ),
                            _buildLeaderboardItem(
                              rank: 4,
                              name: '최민지',
                              points: 2050,
                              level: 12,
                              avatar: '⭐',
                              isCurrentUser: false,
                            ),
                            _buildLeaderboardItem(
                              rank: 5,
                              name: '정우진',
                              points: 1980,
                              level: 11,
                              avatar: '✨',
                              isCurrentUser: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              // Community Sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    '커뮤니티 섹션',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E27),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // Section Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = _sections[index];
                      return _buildSectionCard(section);
                    },
                    childCount: _sections.length,
                  ),
                ),
              ),

              // Recent Activities
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '최근 활동',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1E27),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActivityCard(
                        '김민준님이 "수학 공식 정리" 그룹에 참여했습니다',
                        '5분 전',
                        Icons.group_add,
                        const Color(0xFF638ECB),
                      ),
                      _buildActivityCard(
                        '이서연님이 질문에 답변했습니다',
                        '12분 전',
                        Icons.question_answer,
                        const Color(0xFF8AAEE0),
                      ),
                      _buildActivityCard(
                        '새로운 챌린지 "7일 연속 학습"이 시작되었습니다',
                        '1시간 전',
                        Icons.emoji_events,
                        const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF638ECB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF638ECB)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF638ECB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(TrendingTopic topic) {
    Color changeColor;
    IconData changeIcon;
    
    if (topic.change > 0) {
      changeColor = Colors.green;
      changeIcon = Icons.arrow_upward;
    } else if (topic.change < 0) {
      changeColor = Colors.red;
      changeIcon = Icons.arrow_downward;
    } else {
      changeColor = Colors.grey;
      changeIcon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: topic.rank <= 3
                  ? const Color(0xFF638ECB).withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${topic.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: topic.rank <= 3
                      ? const Color(0xFF638ECB)
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                Text(
                  '${topic.posts}개 게시글',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              changeIcon,
              size: 14,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(CommunitySection section) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            section.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: section.trending
            ? Border.all(
                color: section.color.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: section.color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: section.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        section.icon,
                        color: section.color,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (section.trending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  section.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSectionStats(section),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionStats(CommunitySection section) {
    if (section.memberCount != null) {
      return Row(
        children: [
          Icon(Icons.people, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${section.memberCount}명',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.circle, size: 8, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            '${section.activeNow}명 활동중',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      );
    } else if (section.questionCount != null) {
      return Row(
        children: [
          Icon(Icons.help_outline, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${section.questionCount}개',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.check_circle, size: 14, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            '${section.answeredRate}% 해결',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      );
    } else if (section.mentorCount != null) {
      return Row(
        children: [
          Icon(Icons.school, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${section.mentorCount}명',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.today, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '오늘 ${section.sessionsToday}개',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.event, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${section.eventCount}개 진행중',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.people, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${section.participants}명',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int points,
    required int level,
    required String avatar,
    required bool isCurrentUser,
  }) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = const Color(0xFF638ECB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF638ECB).withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                width: 2,
              )
            : Border.all(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
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
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FA),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser 
                            ? const Color(0xFF638ECB)
                            : const Color(0xFF1A1E27),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF638ECB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Lv.$level',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              Text(
                'XP',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
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
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
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

// Models
class CommunitySection {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int? memberCount;
  final int? activeNow;
  final int? questionCount;
  final int? answeredRate;
  final int? mentorCount;
  final int? sessionsToday;
  final int? eventCount;
  final int? participants;
  final bool trending;

  CommunitySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.memberCount,
    this.activeNow,
    this.questionCount,
    this.answeredRate,
    this.mentorCount,
    this.sessionsToday,
    this.eventCount,
    this.participants,
    required this.trending,
  });
}

class TrendingTopic {
  final int rank;
  final String title;
  final int posts;
  final int change;

  TrendingTopic({
    required this.rank,
    required this.title,
    required this.posts,
    required this.change,
  });
}