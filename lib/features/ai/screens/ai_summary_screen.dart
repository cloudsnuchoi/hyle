import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AISummaryScreen extends ConsumerStatefulWidget {
  const AISummaryScreen({super.key});

  @override
  ConsumerState<AISummaryScreen> createState() => _AISummaryScreenState();
}

class _AISummaryScreenState extends ConsumerState<AISummaryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  String _selectedSubject = 'all';
  bool _isGenerating = false;
  
  final List<StudySummary> _summaries = [
    StudySummary(
      id: '1',
      title: '이차방정식 완전정복',
      subject: '수학',
      date: DateTime.now().subtract(const Duration(days: 1)),
      keyPoints: [
        '근의 공식: x = (-b ± √(b²-4ac)) / 2a',
        '판별식 D = b²-4ac로 근의 개수 판단',
        '인수분해를 통한 해법',
        '완전제곱식 활용법',
      ],
      difficulty: 'intermediate',
      completionRate: 85,
      estimatedTime: '15분',
      tags: ['대수', '방정식', '2차'],
    ),
    StudySummary(
      id: '2',
      title: '영어 동사 시제 총정리',
      subject: '영어',
      date: DateTime.now().subtract(const Duration(days: 2)),
      keyPoints: [
        '현재완료: have/has + p.p',
        '과거완료: had + p.p',
        '미래완료: will have + p.p',
        '진행형의 활용',
      ],
      difficulty: 'basic',
      completionRate: 92,
      estimatedTime: '20분',
      tags: ['문법', '시제', '동사'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _generateSummary() {
    setState(() {
      _isGenerating = true;
    });
    _progressAnimationController.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _progressAnimationController.reset();
        _showGeneratedSummary();
      }
    });
  }

  void _showGeneratedSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    '생성된 요약',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E27),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF638ECB).withValues(alpha: 0.1),
                            const Color(0xFF8AAEE0).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 학습 요약',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1E27),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'AI가 분석한 오늘의 학습 내용입니다. 핵심 개념들을 중심으로 정리했습니다.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSummarySection('핵심 개념', Icons.lightbulb_outline),
                    _buildSummarySection('학습 포인트', Icons.check_circle_outline),
                    _buildSummarySection('추가 학습 필요', Icons.info_outline),
                  ],
                ),
              ),
            ),
          ],
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
                      'AI 요약',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Color(0xFF638ECB)),
                      onPressed: () => _showFilterOptions(),
                    ),
                  ],
                ),
              ),

              // Generate Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateSummary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF638ECB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isGenerating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                value: _progressAnimation.value,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'AI가 요약 중...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              '새 요약 생성',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
                    Tab(text: '최근 요약'),
                    Tab(text: '저장된 요약'),
                    Tab(text: '마인드맵'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecentSummaries(),
                    _buildSavedSummaries(),
                    _buildMindMap(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSummaries() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _summaries.length,
      itemBuilder: (context, index) {
        final summary = _summaries[index];
        return _buildSummaryCard(summary);
      },
    );
  }

  Widget _buildSavedSummaries() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildSavedCard(index);
      },
    );
  }

  Widget _buildMindMap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center Node
                Container(
                  width: 80,
                  height: 80,
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
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '수학',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Branch Nodes
                ..._buildBranchNodes(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '마인드맵으로 학습 내용을 시각화합니다',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.fullscreen),
            label: const Text('전체 화면으로 보기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF638ECB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBranchNodes() {
    final nodes = ['대수', '기하', '해석', '확률'];
    return List.generate(4, (index) {
      final angle = (index * 90 - 45) * 3.14159 / 180;
      final x = 60 * math.cos(angle);
      final y = 60 * math.sin(angle);
      
      return Positioned(
        left: 100 + x - 25,
        top: 100 + y - 25,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8AAEE0),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              nodes[index],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF638ECB),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCard(StudySummary summary) {
    Color difficultyColor;
    String difficultyText;
    
    switch (summary.difficulty) {
      case 'basic':
        difficultyColor = Colors.green;
        difficultyText = '기초';
        break;
      case 'intermediate':
        difficultyColor = Colors.orange;
        difficultyText = '중급';
        break;
      case 'advanced':
        difficultyColor = Colors.red;
        difficultyText = '고급';
        break;
      default:
        difficultyColor = Colors.grey;
        difficultyText = '일반';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showSummaryDetail(summary),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        summary.subject,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF638ECB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        difficultyText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: difficultyColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(summary.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  summary.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 12),
                ...summary.keyPoints.take(2).map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF8AAEE0),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                if (summary.keyPoints.length > 2)
                  Text(
                    '+${summary.keyPoints.length - 2} 더보기',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF638ECB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      summary.estimatedTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.trending_up, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${summary.completionRate}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCard(int index) {
    final colors = [
      const Color(0xFF8AAEE0),
      const Color(0xFF638ECB),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
    ];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[index % colors.length].withValues(alpha: 0.1),
            colors[index % colors.length].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors[index % colors.length].withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description,
                  size: 40,
                  color: colors[index % colors.length],
                ),
                const SizedBox(height: 12),
                Text(
                  '요약 ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3개 주제',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF638ECB), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 이차방정식의 근의 공식 이해\n• 판별식을 통한 근의 개수 판단\n• 인수분해와 완전제곱식 활용',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '필터 옵션',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1E27),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '과목',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['전체', '수학', '영어', '과학', '역사'].map((subject) {
                return FilterChip(
                  label: Text(subject),
                  selected: _selectedSubject == subject,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSubject = subject;
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: const Color(0xFF638ECB).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF638ECB),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSummaryDetail(StudySummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF395886)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          summary.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1E27),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Content here
                          Text(
                            '상세 요약 내용',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }
}

// Study Summary Model
class StudySummary {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final List<String> keyPoints;
  final String difficulty;
  final int completionRate;
  final String estimatedTime;
  final List<String> tags;

  StudySummary({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.keyPoints,
    required this.difficulty,
    required this.completionRate,
    required this.estimatedTime,
    required this.tags,
  });
}