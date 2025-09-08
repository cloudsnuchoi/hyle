import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestScreen extends ConsumerStatefulWidget {
  const QuestScreen({super.key});

  @override
  ConsumerState<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends ConsumerState<QuestScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  final List<Quest> _activeQuests = [
    Quest(
      id: '1',
      title: '지식의 탐험가',
      description: '5개의 다른 과목을 학습하세요',
      icon: Icons.explore,
      category: QuestCategory.exploration,
      currentProgress: 3,
      totalProgress: 5,
      xpReward: 200,
      coinReward: 50,
      deadline: DateTime.now().add(const Duration(days: 7)),
      difficulty: QuestDifficulty.medium,
    ),
    Quest(
      id: '2',
      title: '퀴즈 마스터',
      description: '퀴즈에서 90% 이상 점수 10회 달성',
      icon: Icons.emoji_events,
      category: QuestCategory.mastery,
      currentProgress: 7,
      totalProgress: 10,
      xpReward: 300,
      coinReward: 80,
      deadline: DateTime.now().add(const Duration(days: 14)),
      difficulty: QuestDifficulty.hard,
    ),
    Quest(
      id: '3',
      title: '꾸준한 학습자',
      description: '7일 연속 학습하기',
      icon: Icons.local_fire_department,
      category: QuestCategory.consistency,
      currentProgress: 4,
      totalProgress: 7,
      xpReward: 150,
      coinReward: 30,
      deadline: DateTime.now().add(const Duration(days: 3)),
      difficulty: QuestDifficulty.easy,
    ),
  ];
  
  final List<Quest> _completedQuests = [
    Quest(
      id: '4',
      title: '첫 걸음',
      description: '첫 학습 세션 완료',
      icon: Icons.flag,
      category: QuestCategory.beginner,
      currentProgress: 1,
      totalProgress: 1,
      xpReward: 50,
      coinReward: 10,
      completedAt: DateTime.now().subtract(const Duration(days: 5)),
      difficulty: QuestDifficulty.easy,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                      '퀘스트',
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF638ECB), Color(0xFF8AAEE0)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '1,250 XP',
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
              ),

              // Progress Overview
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOverviewStat('진행중', '${_activeQuests.length}', Icons.play_arrow),
                          _buildOverviewStat('완료', '${_completedQuests.length}', Icons.check_circle),
                          _buildOverviewStat('레벨', '12', Icons.military_tech),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '다음 레벨까지 350 XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
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
                    Tab(text: '진행중'),
                    Tab(text: '완료'),
                    Tab(text: '특별'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveQuests(),
                    _buildCompletedQuests(),
                    _buildSpecialQuests(),
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
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveQuests() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _activeQuests.length,
      itemBuilder: (context, index) {
        final quest = _activeQuests[index];
        return _buildQuestCard(quest, isActive: true);
      },
    );
  }

  Widget _buildCompletedQuests() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _completedQuests.length,
      itemBuilder: (context, index) {
        final quest = _completedQuests[index];
        return _buildQuestCard(quest, isCompleted: true);
      },
    );
  }

  Widget _buildSpecialQuests() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.2),
                  Colors.pink.withValues(alpha: 0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              size: 50,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '특별 퀘스트가 곧 시작됩니다!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E27),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '매주 새로운 도전이 기다립니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(Quest quest, {bool isActive = false, bool isCompleted = false}) {
    final progress = quest.currentProgress / quest.totalProgress;
    Color difficultyColor;
    String difficultyText;
    
    switch (quest.difficulty) {
      case QuestDifficulty.easy:
        difficultyColor = Colors.green;
        difficultyText = '쉬움';
        break;
      case QuestDifficulty.medium:
        difficultyColor = Colors.orange;
        difficultyText = '보통';
        break;
      case QuestDifficulty.hard:
        difficultyColor = Colors.red;
        difficultyText = '어려움';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withValues(alpha: 0.05),
                  Colors.green.withValues(alpha: 0.02),
                ],
              )
            : null,
        color: isCompleted ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted
            ? Border.all(color: Colors.green.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isCompleted
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
          onTap: () {},
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
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF638ECB).withValues(alpha: 0.2),
                            const Color(0xFF8AAEE0).withValues(alpha: 0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        quest.icon,
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
                                  quest.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1E27),
                                  ),
                                ),
                              ),
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
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            quest.description,
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
                
                // Progress
                if (isActive) ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFE8EDF5),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${quest.currentProgress}/${quest.totalProgress}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF638ECB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Rewards and Deadline
                Row(
                  children: [
                    _buildRewardChip(Icons.star, '+${quest.xpReward} XP', Colors.amber),
                    const SizedBox(width: 8),
                    _buildRewardChip(Icons.monetization_on, '+${quest.coinReward}', Colors.orange),
                    const Spacer(),
                    if (isActive && quest.deadline != null)
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDeadline(quest.deadline!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 남음';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 남음';
    } else {
      return '곧 마감';
    }
  }
}

// Quest Model
class Quest {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final QuestCategory category;
  final int currentProgress;
  final int totalProgress;
  final int xpReward;
  final int coinReward;
  final DateTime? deadline;
  final DateTime? completedAt;
  final QuestDifficulty difficulty;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.currentProgress,
    required this.totalProgress,
    required this.xpReward,
    required this.coinReward,
    this.deadline,
    this.completedAt,
    required this.difficulty,
  });
}

enum QuestCategory {
  beginner,
  exploration,
  mastery,
  consistency,
  social,
  special,
}

enum QuestDifficulty {
  easy,
  medium,
  hard,
}