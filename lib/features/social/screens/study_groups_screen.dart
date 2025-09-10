import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudyGroupsScreen extends ConsumerStatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  ConsumerState<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends ConsumerState<StudyGroupsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  
  String _selectedCategory = 'all';
  
  final List<StudyGroup> _myGroups = [
    StudyGroup(
      id: '1',
      name: '수능 수학 마스터',
      description: '수능 수학 1등급을 목표로 함께 공부해요',
      category: '수학',
      memberCount: 12,
      maxMembers: 15,
      level: 'advanced',
      imageUrl: '🎯',
      isActive: true,
      nextSession: DateTime.now().add(const Duration(hours: 2)),
      progress: 75,
      tags: ['수능', '미적분', '확률과통계'],
    ),
    StudyGroup(
      id: '2',
      name: '토익 900+ 클럽',
      description: '토익 고득점을 위한 집중 스터디',
      category: '영어',
      memberCount: 8,
      maxMembers: 10,
      level: 'intermediate',
      imageUrl: '🌟',
      isActive: true,
      nextSession: DateTime.now().add(const Duration(days: 1)),
      progress: 60,
      tags: ['토익', 'RC', 'LC'],
    ),
  ];
  
  final List<StudyGroup> _recommendedGroups = [
    StudyGroup(
      id: '3',
      name: '코딩테스트 준비반',
      description: '알고리즘과 자료구조를 함께 공부합니다',
      category: '프로그래밍',
      memberCount: 18,
      maxMembers: 20,
      level: 'all',
      imageUrl: '💻',
      isActive: false,
      progress: 0,
      tags: ['알고리즘', '파이썬', '자료구조'],
    ),
    StudyGroup(
      id: '4',
      name: '물리학 기초',
      description: '물리학의 기본 개념을 탄탄히 다져요',
      category: '과학',
      memberCount: 5,
      maxMembers: 12,
      level: 'beginner',
      imageUrl: '⚛️',
      isActive: false,
      progress: 0,
      tags: ['역학', '전자기학', '파동'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    ));
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
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
                      '스터디 그룹',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1E27),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF638ECB)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Color(0xFF638ECB)),
                      onPressed: () => _showFilterOptions(),
                    ),
                  ],
                ),
              ),

              // Category Filter
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('전체', 'all'),
                    _buildCategoryChip('수학', 'math'),
                    _buildCategoryChip('영어', 'english'),
                    _buildCategoryChip('과학', 'science'),
                    _buildCategoryChip('프로그래밍', 'programming'),
                    _buildCategoryChip('예술', 'art'),
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
                    Tab(text: '내 그룹'),
                    Tab(text: '추천'),
                    Tab(text: '탐색'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyGroups(),
                    _buildRecommendedGroups(),
                    _buildExploreGroups(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateGroupDialog(),
          backgroundColor: const Color(0xFF638ECB),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            '그룹 만들기',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = value;
          });
        },
        selectedColor: const Color(0xFF638ECB).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF638ECB),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF638ECB) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildMyGroups() {
    if (_myGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 50,
                color: Color(0xFF638ECB),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '참여중인 그룹이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1E27),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 그룹을 만들거나 탐색해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _myGroups.length,
      itemBuilder: (context, index) {
        final group = _myGroups[index];
        return _buildGroupCard(group, isMyGroup: true);
      },
    );
  }

  Widget _buildRecommendedGroups() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _recommendedGroups.length,
      itemBuilder: (context, index) {
        final group = _recommendedGroups[index];
        return _buildGroupCard(group, isRecommended: true);
      },
    );
  }

  Widget _buildExploreGroups() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildExploreCard(index);
      },
    );
  }

  Widget _buildGroupCard(StudyGroup group, {bool isMyGroup = false, bool isRecommended = false}) {
    Color levelColor;
    String levelText;
    
    switch (group.level) {
      case 'beginner':
        levelColor = Colors.green;
        levelText = '초급';
        break;
      case 'intermediate':
        levelColor = Colors.orange;
        levelText = '중급';
        break;
      case 'advanced':
        levelColor = Colors.red;
        levelText = '고급';
        break;
      default:
        levelColor = Colors.blue;
        levelText = '모든 레벨';
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
          onTap: () => _showGroupDetail(group),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF638ECB).withValues(alpha: 0.2),
                            const Color(0xFF8AAEE0).withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          group.imageUrl,
                          style: const TextStyle(fontSize: 30),
                        ),
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
                                  group.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1E27),
                                  ),
                                ),
                              ),
                              if (group.isActive)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            group.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: group.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8AAEE0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF638ECB),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  children: [
                    _buildStatItem(Icons.people, '${group.memberCount}/${group.maxMembers}'),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.bar_chart, levelText, color: levelColor),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.category, group.category),
                    const Spacer(),
                    if (isMyGroup && group.nextSession != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Color(0xFF638ECB),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatNextSession(group.nextSession!),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF638ECB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isRecommended)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF638ECB),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '참여하기',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                
                if (isMyGroup && group.progress > 0) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '학습 진도',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${group.progress}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF638ECB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: group.progress / 100,
                        backgroundColor: const Color(0xFFE8EDF5),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreCard(int index) {
    final categories = ['수학', '영어', '과학', '프로그래밍', '예술', '역사', '경제', '심리'];
    final emojis = ['📐', '🌍', '🔬', '💻', '🎨', '📚', '💰', '🧠'];
    
    return Container(
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
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emojis[index % emojis.length],
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  categories[index % categories.length],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${15 + index * 3}개 그룹',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '탐색하기',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF638ECB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatNextSession(DateTime nextSession) {
    final now = DateTime.now();
    final difference = nextSession.difference(now);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 후';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 후';
    } else {
      return '${difference.inDays}일 후';
    }
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
              '레벨',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['모든 레벨', '초급', '중급', '고급'].map((level) {
                return FilterChip(
                  label: Text(level),
                  selected: false,
                  onSelected: (selected) {
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              '그룹 크기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['5명 이하', '6-10명', '11-20명', '20명 이상'].map((size) {
                return FilterChip(
                  label: Text(size),
                  selected: false,
                  onSelected: (selected) {
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupDetail(StudyGroup group) {
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
                        Expanded(
                          child: Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1E27),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Group detail content would go here
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
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
              const Text(
                '새 스터디 그룹 만들기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: '그룹 이름',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '그룹 설명',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF638ECB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '만들기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Study Group Model
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final int maxMembers;
  final String level;
  final String imageUrl;
  final bool isActive;
  final DateTime? nextSession;
  final int progress;
  final List<String> tags;

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.maxMembers,
    required this.level,
    required this.imageUrl,
    required this.isActive,
    this.nextSession,
    required this.progress,
    required this.tags,
  });
}