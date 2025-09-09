import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Widget _buildBottomMenu() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isMenuExpanded ? 280 : 60,
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
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.people, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_task, color: Colors.white),
                    onPressed: () {
                      _showAddTodoDialog();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isMenuExpanded = false;
                      });
                    },
                  ),
                ],
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('프로필'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('통계'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('도움말'),
              onTap: () {},
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF638ECB)),
              title: const Text('스톱워치'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.timelapse, color: Color(0xFF638ECB)),
              title: const Text('뽀모도로'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 추가'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: '할 일',
            hintText: '할 일을 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _todos.add({'title': '새로운 할 일', 'completed': false});
              });
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
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