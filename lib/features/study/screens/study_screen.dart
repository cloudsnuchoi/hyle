import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  
  final List<Subject> _subjects = [
    Subject(
      name: '수학',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF8AAEE0),
      progress: 0.65,
      totalLessons: 24,
      completedLessons: 16,
    ),
    Subject(
      name: '영어',
      icon: Icons.abc_rounded,
      color: const Color(0xFF638ECB),
      progress: 0.45,
      totalLessons: 30,
      completedLessons: 14,
    ),
    Subject(
      name: '과학',
      icon: Icons.science_rounded,
      color: const Color(0xFF395886),
      progress: 0.80,
      totalLessons: 20,
      completedLessons: 16,
    ),
    Subject(
      name: '역사',
      icon: Icons.history_edu_rounded,
      color: const Color(0xFF8AAEE0),
      progress: 0.30,
      totalLessons: 18,
      completedLessons: 5,
    ),
    Subject(
      name: '코딩',
      icon: Icons.code_rounded,
      color: const Color(0xFF638ECB),
      progress: 0.90,
      totalLessons: 15,
      completedLessons: 14,
    ),
    Subject(
      name: '국어',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF395886),
      progress: 0.55,
      totalLessons: 22,
      completedLessons: 12,
    ),
  ];

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
              
              // Tabs
              _buildTabs(),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 과목 탭
                    _buildSubjectsTab(),
                    // 진행중 탭
                    _buildInProgressTab(),
                    // 완료 탭
                    _buildCompletedTab(),
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
            '학습',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        indicatorColor: const Color(0xFF395886), // primary500
        indicatorWeight: 3,
        labelColor: const Color(0xFF395886),
        unselectedLabelColor: const Color(0xFF737373), // gray500
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: '과목'),
          Tab(text: '진행중'),
          Tab(text: '완료'),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Stats
          _buildStudyStats(),
          
          const SizedBox(height: 24),
          
          // Subjects Grid
          const Text(
            '모든 과목',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                return _buildSubjectCard(_subjects[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStats() {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('오늘 학습', '2시간 30분', Icons.timer_rounded),
              _buildStatItem('완료 레슨', '5개', Icons.check_circle_rounded),
              _buildStatItem('획득 XP', '150', Icons.star_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '주간 목표',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '15/20 레슨',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return InkWell(
      onTap: () {
        _showStudyOptionsBottomSheet(subject);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: subject.color.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    subject.icon,
                    size: 24,
                    color: subject.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(subject.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subject.color,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              subject.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626), // gray800
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${subject.completedLessons}/${subject.totalLessons} 레슨',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF737373), // gray500
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: subject.progress,
              backgroundColor: const Color(0xFFE5E5E5),
              valueColor: AlwaysStoppedAnimation<Color>(subject.color),
              minHeight: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgressTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildLessonCard(
          title: '미적분 기초 ${index + 1}',
          subject: '수학',
          progress: 0.3 + (index * 0.1),
          timeLeft: '${30 - (index * 5)}분 남음',
          color: const Color(0xFF8AAEE0),
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildLessonCard(
          title: '완료된 레슨 ${index + 1}',
          subject: '영어',
          progress: 1.0,
          timeLeft: '완료됨',
          color: const Color(0xFF4CAF50),
          isCompleted: true,
        );
      },
    );
  }

  Widget _buildLessonCard({
    required String title,
    required String subject,
    required double progress,
    required String timeLeft,
    required Color color,
    bool isCompleted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted 
          ? color.withValues(alpha: 0.1)
          : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
          ? Border.all(color: color, width: 1)
          : null,
        boxShadow: isCompleted ? null : [
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
          onTap: () {
            // Navigate to lesson
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.play_arrow_rounded,
                    size: 24,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF262626), // gray800
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF638ECB),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeLeft,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCompleted
                                ? color
                                : const Color(0xFF737373), // gray500
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFE5E5E5),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: const Color(0xFF737373), // gray500
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('필터'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('전체'),
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text('최근 학습'),
                value: 'recent',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text('즐겨찾기'),
                value: 'favorite',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStudyOptionsBottomSheet(Subject subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5DEEF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Subject Info
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: subject.color.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    subject.icon,
                    size: 28,
                    color: subject.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF262626),
                        ),
                      ),
                      Text(
                        '${subject.completedLessons}/${subject.totalLessons} 레슨 완료',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Study Options
            const Text(
              '학습 옵션 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626),
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildStudyOptionCard(
                  icon: Icons.style,
                  label: '플래시카드',
                  color: const Color(0xFF638ECB),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/study/flashcard');
                  },
                ),
                _buildStudyOptionCard(
                  icon: Icons.quiz,
                  label: '퀴즈',
                  color: const Color(0xFF8AAEE0),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/study/quiz');
                  },
                ),
                _buildStudyOptionCard(
                  icon: Icons.school,
                  label: '수업',
                  color: const Color(0xFF395886),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/study/lesson');
                  },
                ),
                _buildStudyOptionCard(
                  icon: Icons.edit,
                  label: '연습',
                  color: const Color(0xFF638ECB),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/study/practice');
                  },
                ),
                _buildStudyOptionCard(
                  icon: Icons.play_circle,
                  label: '비디오',
                  color: const Color(0xFF8AAEE0),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/study/video');
                  },
                ),
                _buildStudyOptionCard(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF 자료',
                  color: const Color(0xFF395886),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/study/pdf');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyOptionCard({
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
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
}

class Subject {
  final String name;
  final IconData icon;
  final Color color;
  final double progress;
  final int totalLessons;
  final int completedLessons;

  Subject({
    required this.name,
    required this.icon,
    required this.color,
    required this.progress,
    required this.totalLessons,
    required this.completedLessons,
  });
}