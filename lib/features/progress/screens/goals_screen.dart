import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  final List<Goal> _shortTermGoals = [
    Goal(
      id: '1',
      title: '영어 단어 100개 암기',
      description: '이번 주까지 토익 필수 단어 마스터',
      category: '영어',
      targetDate: DateTime.now().add(const Duration(days: 3)),
      progress: 65,
      milestones: [
        Milestone(title: '기초 단어 30개', isCompleted: true),
        Milestone(title: '중급 단어 35개', isCompleted: true),
        Milestone(title: '고급 단어 35개', isCompleted: false),
      ],
      priority: Priority.high,
      icon: Icons.translate,
    ),
    Goal(
      id: '2',
      title: '수학 문제집 완성',
      description: '미적분 단원 문제 전체 풀이',
      category: '수학',
      targetDate: DateTime.now().add(const Duration(days: 7)),
      progress: 40,
      milestones: [
        Milestone(title: '기본 문제', isCompleted: true),
        Milestone(title: '응용 문제', isCompleted: false),
        Milestone(title: '심화 문제', isCompleted: false),
      ],
      priority: Priority.medium,
      icon: Icons.calculate,
    ),
  ];
  
  final List<Goal> _longTermGoals = [
    Goal(
      id: '3',
      title: '토익 900점 달성',
      description: '6개월 내 목표 점수 달성',
      category: '영어',
      targetDate: DateTime.now().add(const Duration(days: 180)),
      progress: 30,
      milestones: [
        Milestone(title: 'LC 450점', isCompleted: false),
        Milestone(title: 'RC 450점', isCompleted: false),
      ],
      priority: Priority.high,
      icon: Icons.school,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _progressAnimationController.dispose();
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
                      '목표 관리',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF638ECB), size: 28),
                      onPressed: () => _showAddGoalDialog(),
                    ),
                  ],
                ),
              ),

              // Overview Card
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '이번 달 목표 달성률',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '68%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.trending_up, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '+12%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOverviewStat('진행중', '5', Icons.play_arrow),
                        _buildOverviewStat('완료', '12', Icons.check_circle),
                        _buildOverviewStat('이번주', '3', Icons.calendar_today),
                      ],
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
                    Tab(text: '단기 목표'),
                    Tab(text: '장기 목표'),
                    Tab(text: '완료됨'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGoalsList(_shortTermGoals),
                    _buildGoalsList(_longTermGoals),
                    _buildCompletedGoals(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(List<Goal> goals) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _progressAnimation.value)),
              child: Opacity(
                opacity: _progressAnimation.value,
                child: _buildGoalCard(goal),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal) {
    Color priorityColor;
    switch (goal.priority) {
      case Priority.high:
        priorityColor = Colors.red;
        break;
      case Priority.medium:
        priorityColor = Colors.orange;
        break;
      case Priority.low:
        priorityColor = Colors.green;
        break;
    }

    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;

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
          onTap: () => _showGoalDetailDialog(goal),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        goal.icon,
                        color: const Color(0xFF638ECB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1E27),
                                  ),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: priorityColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '진행도',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${goal.progress}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF638ECB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: (goal.progress / 100) * _progressAnimation.value,
                          backgroundColor: const Color(0xFFE8EDF5),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
                          minHeight: 6,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Milestones
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: goal.milestones.map((milestone) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: milestone.isCompleted
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: milestone.isCompleted
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            milestone.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            size: 14,
                            color: milestone.isCompleted ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            milestone.title,
                            style: TextStyle(
                              fontSize: 11,
                              color: milestone.isCompleted ? Colors.green : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                
                // Footer
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      goal.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      daysRemaining > 0 ? '$daysRemaining일 남음' : '오늘 마감',
                      style: TextStyle(
                        fontSize: 12,
                        color: daysRemaining <= 3 ? Colors.orange : Colors.grey[600],
                        fontWeight: daysRemaining <= 3 ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildCompletedGoals() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 50,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '축하합니다!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E27),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이번 달 12개의 목표를 달성했어요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '새 목표 추가',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
            ),
            // Add goal form would go here
          ],
        ),
      ),
    );
  }

  void _showGoalDetailDialog(Goal goal) {
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
              Row(
                children: [
                  Icon(goal.icon, color: const Color(0xFF638ECB), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                goal.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
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
}

// Goal Model
class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime targetDate;
  final int progress;
  final List<Milestone> milestones;
  final Priority priority;
  final IconData icon;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    required this.progress,
    required this.milestones,
    required this.priority,
    required this.icon,
  });
}

class Milestone {
  final String title;
  final bool isCompleted;

  Milestone({
    required this.title,
    required this.isCompleted,
  });
}

enum Priority {
  high,
  medium,
  low,
}