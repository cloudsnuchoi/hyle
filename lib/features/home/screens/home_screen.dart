import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _cardController;
  late Animation<double> _greetingAnimation;
  late Animation<double> _cardAnimation;
  
  int _selectedBottomNavIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _greetingAnimation = CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOutCubic,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    
    _greetingController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _cardController.dispose();
    _scrollController.dispose();
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
              Color(0xFFF0F3FA), // primary50
              Color(0xFFD5DEEF), // primary100
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              _buildSliverAppBar(),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Greeting Section
                    FadeTransition(
                      opacity: _greetingAnimation,
                      child: _buildGreetingSection(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Study Streak Card
                    ScaleTransition(
                      scale: _cardAnimation,
                      child: _buildStudyStreakCard(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Daily Missions
                    _buildDailyMissions(),
                    
                    const SizedBox(height: 24),
                    
                    // AI Recommendations
                    _buildAIRecommendations(),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    _buildRecentActivity(),
                    
                    const SizedBox(height: 80), // Bottom nav padding
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingAIButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8AAEE0), // primary300
                  Color(0xFF395886), // primary500
                ],
              ),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'HYLE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF525252), // gray600
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF525252), // gray600
          ),
          onPressed: () {
            // Navigate to search
          },
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '좋은 아침이에요';
    } else if (hour < 18) {
      greeting = '좋은 오후에요';
    } else {
      greeting = '좋은 저녁이에요';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '오늘의 학습 목표를 달성해보세요! 🎯',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF525252), // gray600
          ),
        ),
      ],
    );
  }

  Widget _buildStudyStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF638ECB), // primary400
            Color(0xFF395886), // primary500
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.3),
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
                  '연속 학습',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '7일째',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(7, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < 7
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                      child: index < 7
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF395886),
                            )
                          : null,
                    );
                  }),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '빠른 시작',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.menu_book_rounded,
                label: '학습하기',
                color: const Color(0xFF8AAEE0), // primary300
                onTap: () {
                  // Navigate to study
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.quiz_rounded,
                label: '퀴즈',
                color: const Color(0xFF638ECB), // primary400
                onTap: () {
                  // Navigate to quiz
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.smart_toy_rounded,
                label: 'AI 튜터',
                color: const Color(0xFF395886), // primary500
                onTap: () {
                  // Navigate to AI tutor
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF525252), // gray600
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '일일 미션',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626), // gray800
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all missions
              },
              child: const Text(
                '모두 보기',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF638ECB), // primary400
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMissionItem(
          title: '수학 문제 10개 풀기',
          progress: 0.7,
          reward: '50 XP',
          icon: Icons.calculate_rounded,
        ),
        const SizedBox(height: 8),
        _buildMissionItem(
          title: '영어 단어 20개 암기',
          progress: 0.3,
          reward: '30 XP',
          icon: Icons.abc_rounded,
        ),
        const SizedBox(height: 8),
        _buildMissionItem(
          title: 'AI 튜터와 대화하기',
          progress: 1.0,
          reward: '20 XP',
          icon: Icons.chat_rounded,
          isCompleted: true,
        ),
      ],
    );
  }

  Widget _buildMissionItem({
    required String title,
    required double progress,
    required String reward,
    required IconData icon,
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
          : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
          ? Border.all(color: const Color(0xFF4CAF50), width: 1)
          : null,
        boxShadow: isCompleted ? null : [
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFF638ECB).withValues(alpha: 0.1),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              size: 20,
              color: isCompleted
                ? Colors.white
                : const Color(0xFF638ECB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF262626), // gray800
                    decoration: isCompleted 
                      ? TextDecoration.lineThrough 
                      : null,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFE5E5E5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted 
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF638ECB),
                  ),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              reward,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF57C00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI 추천 콘텐츠',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildRecommendationCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(int index) {
    final subjects = ['수학', '영어', '과학', '역사', '코딩'];
    final topics = [
      '미적분 기초',
      '토익 문법',
      '물리학 개념',
      '한국사 정리',
      'Flutter 입문'
    ];
    final colors = [
      const Color(0xFF8AAEE0),
      const Color(0xFF638ECB),
      const Color(0xFF395886),
      const Color(0xFF8AAEE0),
      const Color(0xFF638ECB),
    ];
    
    return Container(
      width: 140,
      margin: EdgeInsets.only(
        right: 12,
        left: index == 0 ? 0 : 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[index],
            colors[index].withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors[index].withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to content
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  subjects[index],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topics[index],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 활동',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.edit_note_rounded,
          title: '수학 노트 작성',
          time: '30분 전',
          color: const Color(0xFF8AAEE0),
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          icon: Icons.quiz_rounded,
          title: '영어 퀴즈 완료',
          time: '2시간 전',
          color: const Color(0xFF638ECB),
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          icon: Icons.group_rounded,
          title: '스터디 그룹 참여',
          time: '어제',
          color: const Color(0xFF395886),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF262626), // gray800
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF737373), // gray500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF395886), // primary500
        unselectedItemColor: const Color(0xFF737373), // gray500
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: '학습',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded),
            label: '진도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '프로필',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAIButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF638ECB), // primary400
            Color(0xFF395886), // primary500
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // Navigate to AI assistant
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
        ),
      ),
    );
  }
}