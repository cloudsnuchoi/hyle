import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class AIAnalysisScreen extends ConsumerStatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;
  
  String _selectedPeriod = 'week';
  bool _isAnalyzing = false;
  
  final Map<String, double> _strengthData = {
    '논리적 사고': 85,
    '문제 해결': 78,
    '창의성': 92,
    '집중력': 70,
    '기억력': 88,
    '이해력': 82,
  };
  
  final Map<String, double> _subjectPerformance = {
    '수학': 88,
    '영어': 75,
    '과학': 82,
    '역사': 70,
    '국어': 85,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutBack,
    ));
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        _showAnalysisResult();
      }
    });
  }

  void _showAnalysisResult() {
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF638ECB),
                      Color(0xFF8AAEE0),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AI 분석 완료',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '학습 패턴 분석이 완료되었습니다.\n개인 맞춤 학습 전략을 확인하세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
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
                      'AI 학습 분석',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        isDense: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF638ECB)),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF638ECB),
                          fontWeight: FontWeight.bold,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'week', child: Text('주간')),
                          DropdownMenuItem(value: 'month', child: Text('월간')),
                          DropdownMenuItem(value: 'year', child: Text('연간')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // AI Insight Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI 인사이트',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '당신의 학습 스타일은 "시각적 학습자"입니다.\n다이어그램과 차트를 활용한 학습이 효과적입니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isAnalyzing ? null : _startAnalysis,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF638ECB),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
                              ),
                            )
                          : const Text(
                              '심화 분석 시작',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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
                    Tab(text: '강점 분석'),
                    Tab(text: '취약점'),
                    Tab(text: '학습 패턴'),
                    Tab(text: '추천'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStrengthAnalysis(),
                    _buildWeaknessAnalysis(),
                    _buildLearningPattern(),
                    _buildRecommendations(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthAnalysis() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 능력 분석',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E27),
            ),
          ),
          const SizedBox(height: 20),
          // Radar Chart
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomPaint(
              painter: RadarChartPainter(
                data: _strengthData,
                animation: _chartAnimation,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Strength Cards
          ..._strengthData.entries.map((entry) {
            return _buildStrengthCard(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildWeaknessAnalysis() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildWeaknessCard(
          '집중력 부족',
          '평균 학습 시간이 30분으로 짧은 편입니다.',
          '포모도로 기법을 활용해 집중력을 향상시키세요.',
          70,
          Colors.orange,
        ),
        _buildWeaknessCard(
          '복습 부족',
          '학습 후 복습 빈도가 낮습니다.',
          '에빙하우스 망각 곡선을 고려한 복습 계획을 세우세요.',
          65,
          Colors.red,
        ),
        _buildWeaknessCard(
          '과목 편중',
          '특정 과목에만 학습이 집중되어 있습니다.',
          '균형잡힌 학습 계획을 수립하세요.',
          75,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildLearningPattern() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Distribution
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                  '시간대별 학습 패턴',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTimeChart(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Subject Performance
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                  '과목별 성취도',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 20),
                ..._subjectPerformance.entries.map((entry) {
                  return _buildPerformanceBar(entry.key, entry.value);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildRecommendationCard(
          Icons.schedule,
          '최적 학습 시간',
          '오후 2시-4시',
          '이 시간대에 가장 높은 집중력을 보입니다.',
          const Color(0xFF638ECB),
        ),
        _buildRecommendationCard(
          Icons.book,
          '추천 학습법',
          '시각적 학습',
          '다이어그램과 마인드맵을 활용하세요.',
          const Color(0xFF8AAEE0),
        ),
        _buildRecommendationCard(
          Icons.trending_up,
          '개선 포인트',
          '반복 학습',
          '주기적인 복습으로 장기 기억을 강화하세요.',
          const Color(0xFF8B5CF6),
        ),
        _buildRecommendationCard(
          Icons.groups,
          '스터디 그룹',
          '협동 학습',
          '동료와의 토론이 이해도를 높입니다.',
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildStrengthCard(String title, double value) {
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF638ECB),
                ),
              ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: const Color(0xFFE8EDF5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    value >= 80
                        ? Colors.green
                        : value >= 60
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeaknessCard(String title, String description, String suggestion, double score, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${score.toInt()}점',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFF638ECB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF638ECB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChart() {
    final hours = ['6시', '9시', '12시', '15시', '18시', '21시'];
    final values = [20, 40, 30, 80, 60, 90];
    
    return Container(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(hours.length, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return Container(
                    width: 40,
                    height: values[index] * _chartAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF638ECB),
                          const Color(0xFF8AAEE0),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                hours[index],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPerformanceBar(String subject, double value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              const Spacer(),
              Text(
                '${value.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: value >= 80
                      ? Colors.green
                      : value >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: (value / 100) * _chartAnimation.value,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8EDF5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  value >= 80
                      ? Colors.green
                      : value >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(IconData icon, String title, String value, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1E27),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
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
}

// Custom Painter for Radar Chart
class RadarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Animation<double> animation;

  RadarChartPainter({
    required this.data,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    final angle = 2 * math.pi / data.length;
    
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    for (var i = 1; i <= 5; i++) {
      final gridRadius = radius * i / 5;
      final path = Path();
      
      for (var j = 0; j < data.length; j++) {
        final x = center.dx + gridRadius * math.cos(angle * j - math.pi / 2);
        final y = center.dy + gridRadius * math.sin(angle * j - math.pi / 2);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      path.close();
      canvas.drawPath(path, gridPaint);
    }
    
    // Draw axes
    for (var i = 0; i < data.length; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      canvas.drawLine(center, Offset(x, y), gridPaint);
      
      // Draw labels
      final label = data.keys.elementAt(i);
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF395886),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final labelX = center.dx + (radius + 20) * math.cos(angle * i - math.pi / 2) - textPainter.width / 2;
      final labelY = center.dy + (radius + 20) * math.sin(angle * i - math.pi / 2) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
    
    // Draw data
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = const Color(0xFF638ECB).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = const Color(0xFF638ECB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (var i = 0; i < data.length; i++) {
      final value = data.values.elementAt(i) * animation.value;
      final dataRadius = radius * value / 100;
      final x = center.dx + dataRadius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + dataRadius * math.sin(angle * i - math.pi / 2);
      
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF638ECB)
      ..style = PaintingStyle.fill;
    
    for (var i = 0; i < data.length; i++) {
      final value = data.values.elementAt(i) * animation.value;
      final dataRadius = radius * value / 100;
      final x = center.dx + dataRadius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + dataRadius * math.sin(angle * i - math.pi / 2);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}