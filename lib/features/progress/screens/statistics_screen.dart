import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';
  
  // Mock statistics data
  final Map<String, dynamic> _stats = {
    'totalStudyTime': 125,
    'averageDaily': 3.5,
    'completedLessons': 342,
    'currentStreak': 7,
    'longestStreak': 15,
    'totalXP': 1250,
    'accuracy': 78.5,
    'weeklyProgress': [
      {'day': '월', 'hours': 3.5, 'lessons': 12},
      {'day': '화', 'hours': 2.5, 'lessons': 8},
      {'day': '수', 'hours': 4.5, 'lessons': 15},
      {'day': '목', 'hours': 3.0, 'lessons': 10},
      {'day': '금', 'hours': 4.0, 'lessons': 14},
      {'day': '토', 'hours': 2.0, 'lessons': 7},
      {'day': '일', 'hours': 5.0, 'lessons': 18},
    ],
    'subjectDistribution': [
      {'name': '수학', 'value': 35, 'color': const Color(0xFF8AAEE0)},
      {'name': '영어', 'value': 25, 'color': const Color(0xFF638ECB)},
      {'name': '과학', 'value': 20, 'color': const Color(0xFF395886)},
      {'name': '역사', 'value': 10, 'color': const Color(0xFFFFC107)},
      {'name': '코딩', 'value': 10, 'color': const Color(0xFF10B981)},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Period Selector
              _buildPeriodSelector(),
              
              // Tabs
              _buildTabs(),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildDetailsTab(),
                    _buildInsightsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            '학습 통계',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              // Export statistics
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
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
          Expanded(
            child: _buildPeriodButton('일', 'day'),
          ),
          Expanded(
            child: _buildPeriodButton('주', 'week'),
          ),
          Expanded(
            child: _buildPeriodButton('월', 'month'),
          ),
          Expanded(
            child: _buildPeriodButton('년', 'year'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF395886) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF737373),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF395886),
        indicatorWeight: 3,
        labelColor: const Color(0xFF395886),
        unselectedLabelColor: const Color(0xFF737373),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: '개요'),
          Tab(text: '상세'),
          Tab(text: '인사이트'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(),
          
          const SizedBox(height: 24),
          
          // Weekly Chart
          _buildWeeklyChart(),
          
          const SizedBox(height: 24),
          
          // Subject Distribution
          _buildSubjectDistribution(),
          
          const SizedBox(height: 24),
          
          // Performance Metrics
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          icon: Icons.timer_rounded,
          title: '총 학습 시간',
          value: '${_stats['totalStudyTime']}',
          unit: '시간',
          color: const Color(0xFF638ECB),
        ),
        _buildStatCard(
          icon: Icons.local_fire_department_rounded,
          title: '연속 학습',
          value: '${_stats['currentStreak']}',
          unit: '일',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          title: '완료 레슨',
          value: '${_stats['completedLessons']}',
          unit: '개',
          color: const Color(0xFF10B981),
        ),
        _buildStatCard(
          icon: Icons.star_rounded,
          title: '획득 XP',
          value: '${_stats['totalXP']}',
          unit: 'XP',
          color: const Color(0xFFFFC107),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF262626),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF737373),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF737373),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final weeklyData = _stats['weeklyProgress'] as List;
    final maxHours = weeklyData
        .map((d) => (d['hours'] as double))
        .reduce((a, b) => math.max(a, b));
    
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주간 학습 현황',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyData.map((data) {
                final height = (data['hours'] / maxHours) * 160;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${data['hours']}h',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF737373),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 36,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF638ECB),
                            const Color(0xFF8AAEE0),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['day'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF525252),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF638ECB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '학습 시간',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF737373),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '평균 ${_stats['averageDaily']}시간/일',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF262626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDistribution() {
    final subjects = _stats['subjectDistribution'] as List;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '과목별 학습 분포',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626),
            ),
          ),
          const SizedBox(height: 20),
          // Pie Chart Placeholder
          SizedBox(
            height: 200,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(180, 180),
                    painter: PieChartPainter(subjects),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF262626),
                        ),
                      ),
                      Text(
                        '총 학습',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: subjects.map((subject) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: subject['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${subject['name']} ${subject['value']}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF525252),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF638ECB),
            Color(0xFF395886),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '성과 지표',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow('정답률', _stats['accuracy'], '%', Colors.white),
          const SizedBox(height: 12),
          _buildMetricRow('최장 연속', _stats['longestStreak'], '일', Colors.white70),
          const SizedBox(height: 12),
          _buildMetricRow('일일 평균', _stats['averageDaily'], '시간', Colors.white70),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          '$value$unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailCard('학습 세션', '84회', Icons.play_circle_outline),
          const SizedBox(height: 12),
          _buildDetailCard('평균 세션 시간', '45분', Icons.timer_outlined),
          const SizedBox(height: 12),
          _buildDetailCard('가장 활발한 시간', '오후 7-9시', Icons.schedule),
          const SizedBox(height: 12),
          _buildDetailCard('선호 과목', '수학', Icons.favorite_outline),
          const SizedBox(height: 12),
          _buildDetailCard('취약 과목', '역사', Icons.warning_amber_outlined),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF638ECB),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF737373),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInsightCard(
            title: '학습 패턴 분석',
            content: '주말에 평일보다 2배 더 많은 학습을 하고 있어요. 균형잡힌 학습 스케줄을 추천합니다.',
            icon: Icons.insights,
            color: const Color(0xFF638ECB),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            title: '성장 추세',
            content: '지난 주 대비 학습 시간이 25% 증가했어요! 이 속도를 유지하세요.',
            icon: Icons.trending_up,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            title: '추천 사항',
            content: '역사 과목의 학습 시간을 늘려보세요. 다른 과목에 비해 진도가 느립니다.',
            icon: Icons.lightbulb_outline,
            color: const Color(0xFFFFC107),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            title: '목표 달성',
            content: '이번 주 목표의 85%를 달성했어요. 조금만 더 노력하면 100% 달성!',
            icon: Icons.flag,
            color: const Color(0xFF395886),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF525252),
                    height: 1.4,
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

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<dynamic> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    double startAngle = -math.pi / 2;
    
    for (var item in data) {
      final sweepAngle = (item['value'] / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = item['color']
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Draw inner circle for donut effect
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}