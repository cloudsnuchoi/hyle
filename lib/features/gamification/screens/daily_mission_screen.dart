import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class DailyMissionScreen extends ConsumerStatefulWidget {
  const DailyMissionScreen({super.key});

  @override
  ConsumerState<DailyMissionScreen> createState() => _DailyMissionScreenState();
}

class _DailyMissionScreenState extends ConsumerState<DailyMissionScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _rewardAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _rewardAnimation;
  
  final List<DailyMission> _missions = [
    DailyMission(
      id: '1',
      title: '30분 학습하기',
      description: '어떤 과목이든 30분 이상 학습하세요',
      icon: Icons.timer,
      xpReward: 50,
      coinReward: 10,
      progress: 25,
      maxProgress: 30,
      isCompleted: false,
      category: MissionCategory.study,
    ),
    DailyMission(
      id: '2',
      title: '퀴즈 3개 완료',
      description: '퀴즈를 3개 이상 풀어보세요',
      icon: Icons.quiz,
      xpReward: 30,
      coinReward: 5,
      progress: 2,
      maxProgress: 3,
      isCompleted: false,
      category: MissionCategory.practice,
    ),
    DailyMission(
      id: '3',
      title: '친구와 함께 학습',
      description: '스터디 그룹에서 활동하세요',
      icon: Icons.groups,
      xpReward: 40,
      coinReward: 8,
      progress: 1,
      maxProgress: 1,
      isCompleted: true,
      category: MissionCategory.social,
    ),
    DailyMission(
      id: '4',
      title: '연속 학습 3일',
      description: '3일 연속으로 학습을 이어가세요',
      icon: Icons.local_fire_department,
      xpReward: 100,
      coinReward: 20,
      progress: 2,
      maxProgress: 3,
      isCompleted: false,
      category: MissionCategory.streak,
    ),
  ];
  
  double get totalProgress {
    final completed = _missions.where((m) => m.isCompleted).length;
    return completed / _missions.length;
  }

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rewardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutBack,
    ));
    _rewardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rewardAnimationController,
      curve: Curves.elasticOut,
    ));
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _rewardAnimationController.dispose();
    super.dispose();
  }

  void _claimReward(DailyMission mission) {
    _rewardAnimationController.forward(from: 0);
    setState(() {
      // Claim reward logic
    });
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
                expandedHeight: 200,
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
                    child: Stack(
                      children: [
                        // Background Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: MissionPatternPainter(),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '일일 미션',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '오늘의 도전과제를 완료하세요!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildProgressBar(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              // Time Remaining Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.withValues(alpha: 0.1),
                        Colors.red.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '남은 시간',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '14시간 32분',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1E27),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF638ECB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              '완료',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '1/4',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Missions List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final mission = _missions[index];
                      return AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          final delay = index * 0.1;
                          final animationValue = (_progressAnimation.value - delay).clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - animationValue)),
                            child: Opacity(
                              opacity: animationValue,
                              child: _buildMissionCard(mission),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _missions.length,
                  ),
                ),
              ),

              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '전체 진행도',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(totalProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: totalProgress * _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF0F3FA)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissionCard(DailyMission mission) {
    final progressPercent = mission.progress / mission.maxProgress;
    Color categoryColor;
    
    switch (mission.category) {
      case MissionCategory.study:
        categoryColor = const Color(0xFF638ECB);
        break;
      case MissionCategory.practice:
        categoryColor = const Color(0xFF8AAEE0);
        break;
      case MissionCategory.social:
        categoryColor = const Color(0xFF8B5CF6);
        break;
      case MissionCategory.streak:
        categoryColor = Colors.orange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: mission.isCompleted
            ? Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: mission.isCompleted
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: mission.isCompleted ? () => _claimReward(mission) : null,
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
                        color: categoryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        mission.icon,
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: mission.isCompleted
                                  ? Colors.green
                                  : const Color(0xFF1A1E27),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (mission.isCompleted)
                      ScaleTransition(
                        scale: _rewardAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
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
                          '${mission.progress}/${mission.maxProgress}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: categoryColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        mission.isCompleted ? Colors.green : categoryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Rewards
                Row(
                  children: [
                    _buildRewardChip(
                      Icons.star,
                      '+${mission.xpReward} XP',
                      Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _buildRewardChip(
                      Icons.monetization_on,
                      '+${mission.coinReward}',
                      Colors.orange,
                    ),
                    const Spacer(),
                    if (mission.isCompleted)
                      ElevatedButton(
                        onPressed: () => _claimReward(mission),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '보상 받기',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  Widget _buildRewardChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Background Pattern
class MissionPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 10;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Daily Mission Model
class DailyMission {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final int coinReward;
  final int progress;
  final int maxProgress;
  final bool isCompleted;
  final MissionCategory category;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.coinReward,
    required this.progress,
    required this.maxProgress,
    required this.isCompleted,
    required this.category,
  });
}

enum MissionCategory {
  study,
  practice,
  social,
  streak,
}