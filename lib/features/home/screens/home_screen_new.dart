import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends ConsumerState<HomeScreenNew>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isMenuExpanded = false;
  int _dDay = 100;
  double _todayProgress = 0.7; // 70%
  int _totalStudyHours = 8;
  int _totalStudyMinutes = 26;
  
  final Map<String, int> _subjectTimes = {
    '수학': 6,
    '영어': 28,
    '국어': 4,
  };
  
  final List<Map<String, dynamic>> _todos = [
    {'title': 'to-do 리스트 1', 'completed': true},
    {'title': '숙제 2', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: _todayProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _progressController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FA),
      endDrawer: _buildSideDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildProgressCircle(),
                          const SizedBox(height: 20),
                          _buildTotalStudyTime(),
                          const SizedBox(height: 30),
                          _buildSubjectTimes(),
                          const SizedBox(height: 30),
                          _buildTodoList(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomMenu(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // D-Day
          InkWell(
            onTap: () {
              // D-Day 설정 다이얼로그
              _showDDayDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF638ECB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'D-$_dDay',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF638ECB),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '대학수학능력시험',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8AAEE0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 햄버거 메뉴
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF395886)),
            onPressed: () {
              _showSideMenu();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const Text(
            '오늘 목표',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8AAEE0),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CircularProgressPainter(
                    progress: _progressAnimation.value,
                    backgroundColor: const Color(0xFFD5DEEF),
                    progressColor: const Color(0xFF638ECB),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(_progressAnimation.value * 100).toInt()}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF395886),
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF8AAEE0),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStudyTime() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time,
            size: 20,
            color: Color(0xFF8AAEE0),
          ),
          const SizedBox(width: 8),
          Text(
            '${_totalStudyHours}H ${_totalStudyMinutes}M',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '총 공부시간',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8AAEE0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTimes() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '과목별 공부시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, 
                    color: Color(0xFF638ECB),
                    size: 28,
                  ),
                  onPressed: () {
                    // 타이머 화면으로 이동 또는 팝업
                    _showTimerOptions();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._subjectTimes.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF395886),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5DEEF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: entry.value / 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF638ECB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.value}분',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF638ECB),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '퀵 메뉴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildQuickAccessItem(
                icon: Icons.emoji_events,
                label: '퀘스트',
                color: const Color(0xFFFFB74D),
                onTap: () => context.push('/gamification/quest'),
              ),
              _buildQuickAccessItem(
                icon: Icons.task_alt,
                label: '미션',
                color: const Color(0xFF4FC3F7),
                onTap: () => context.push('/gamification/mission'),
              ),
              _buildQuickAccessItem(
                icon: Icons.card_giftcard,
                label: '보상',
                color: const Color(0xFF81C784),
                onTap: () => context.push('/gamification/reward'),
              ),
              _buildQuickAccessItem(
                icon: Icons.store,
                label: '상점',
                color: const Color(0xFFBA68C8),
                onTap: () => context.push('/gamification/shop'),
              ),
              _buildQuickAccessItem(
                icon: Icons.note_add,
                label: '노트',
                color: const Color(0xFF8AAEE0),
                onTap: () => context.push('/tools/note'),
              ),
              _buildQuickAccessItem(
                icon: Icons.bookmark,
                label: '북마크',
                color: const Color(0xFFFF7043),
                onTap: () => context.push('/tools/bookmark'),
              ),
              _buildQuickAccessItem(
                icon: Icons.history,
                label: '기록',
                color: const Color(0xFF638ECB),
                onTap: () => context.push('/tools/history'),
              ),
              _buildQuickAccessItem(
                icon: Icons.search,
                label: '검색',
                color: const Color(0xFF395886),
                onTap: () => context.push('/search'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '할 일 목록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, 
                    color: Color(0xFF638ECB),
                    size: 28,
                  ),
                  onPressed: () {
                    _showAddTodoDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._todos.map((todo) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: todo['completed'],
                      onChanged: (value) {
                        setState(() {
                          todo['completed'] = value!;
                        });
                      },
                      activeColor: const Color(0xFF638ECB),
                    ),
                    Expanded(
                      child: Text(
                        todo['title'],
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF395886),
                          decoration: todo['completed'] 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, 
                        color: const Color(0xFF8AAEE0),
                        size: 20,
                      ),
                      onPressed: () {
                        // Todo 옵션 메뉴
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomMenu() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isMenuExpanded ? 400 : 60,
        height: _isMenuExpanded ? 80 : 60,
        decoration: BoxDecoration(
          color: const Color(0xFF638ECB),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF638ECB).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _isMenuExpanded
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Main Navigation Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFloatingMenuItem(Icons.home, '홈', () {
                          context.go('/home');
                          setState(() => _isMenuExpanded = false);
                        }),
                        _buildFloatingMenuItem(Icons.check_circle, '투두', () {
                          context.push('/todo');
                          setState(() => _isMenuExpanded = false);
                        }),
                        _buildFloatingMenuItem(Icons.calendar_today, '캘린더', () {
                          context.push('/calendar');
                          setState(() => _isMenuExpanded = false);
                        }),
                        _buildFloatingMenuItem(Icons.people, '소셜', () {
                          context.push('/social/ranking');
                          setState(() => _isMenuExpanded = false);
                        }),
                        _buildFloatingMenuItem(Icons.smart_toy, 'AI', () {
                          context.push('/ai');
                          setState(() => _isMenuExpanded = false);
                        }),
                      ],
                    ),
                  ],
                ),
              )
            : IconButton(
                icon: const Icon(Icons.apps, color: Colors.white, size: 30),
                onPressed: () {
                  setState(() {
                    _isMenuExpanded = true;
                  });
                },
              ),
      ),
    );
  }

  void _showDDayDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('D-Day 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '시험 이름',
                hintText: '대학수학능력시험',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('날짜 선택'),
              subtitle: Text('D-$_dDay'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(Duration(days: _dDay)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dDay = date.difference(DateTime.now()).inDays;
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showSideMenu() {
    Scaffold.of(context).openEndDrawer();
  }
  
  Widget _buildSideDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF638ECB),
                    Color(0xFF8AAEE0),
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '메뉴',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.school, color: Color(0xFF638ECB)),
                    title: const Text('학습'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/study');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: Color(0xFF638ECB)),
                    title: const Text('커뮤니티'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/community');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF638ECB)),
                    title: const Text('프로필'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Color(0xFF8AAEE0)),
                    title: const Text('설정'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart, color: Color(0xFF8AAEE0)),
                    title: const Text('통계'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/statistics');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups, color: Color(0xFF8AAEE0)),
                    title: const Text('스터디 그룹'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/social/study-groups');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.emoji_events, color: Color(0xFF638ECB)),
                    title: const Text('성취도'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/progress/achievements');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.leaderboard, color: Color(0xFF638ECB)),
                    title: const Text('리더보드'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/progress/leaderboard');
                    },
                  ),
                  const Divider(),
                  // 게임화 기능들
                  ListTile(
                    leading: const Icon(Icons.emoji_events, color: Color(0xFF638ECB)),
                    title: const Text('퀘스트'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/gamification/quest');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.task_alt, color: Color(0xFF638ECB)),
                    title: const Text('미션'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/gamification/mission');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.card_giftcard, color: Color(0xFF638ECB)),
                    title: const Text('보상'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/gamification/reward');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.store, color: Color(0xFF638ECB)),
                    title: const Text('상점'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/gamification/shop');
                    },
                  ),
                  const Divider(),
                  // 도구들
                  ListTile(
                    leading: const Icon(Icons.note_add, color: Color(0xFF8AAEE0)),
                    title: const Text('노트'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/tools/note');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark, color: Color(0xFF8AAEE0)),
                    title: const Text('북마크'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/tools/bookmark');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history, color: Color(0xFF8AAEE0)),
                    title: const Text('기록'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/tools/history');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.search, color: Color(0xFF8AAEE0)),
                    title: const Text('검색'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/search');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help, color: Color(0xFF8AAEE0)),
                    title: const Text('도움말'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings/help');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '공부 시간 측정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.timer, color: Color(0xFF638ECB)),
              title: const Text('타이머'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/timer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF638ECB)),
              title: const Text('스톱워치'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/timer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.timelapse, color: Color(0xFF638ECB)),
              title: const Text('뽀모도로'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/timer');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoDialog() {
    // Navigate to todo screen instead of showing dialog
    context.push('/home/todo');
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius - 7.5, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 7.5),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}