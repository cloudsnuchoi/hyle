import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubjectListScreen extends ConsumerStatefulWidget {
  const SubjectListScreen({super.key});

  @override
  ConsumerState<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends ConsumerState<SubjectListScreen> {
  String _selectedCategory = 'all';
  String _sortBy = 'name';
  
  final List<SubjectDetail> _subjects = [
    SubjectDetail(
      id: '1',
      name: '수학',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF8AAEE0),
      category: 'science',
      description: '기초부터 고급까지 단계별 수학 학습',
      totalLessons: 120,
      completedLessons: 78,
      progress: 0.65,
      difficulty: 'intermediate',
      estimatedTime: '30시간',
      topics: ['대수', '기하', '미적분', '통계'],
    ),
    SubjectDetail(
      id: '2',
      name: '영어',
      icon: Icons.abc_rounded,
      color: const Color(0xFF638ECB),
      category: 'language',
      description: '실전 영어 회화와 문법 마스터',
      totalLessons: 150,
      completedLessons: 68,
      progress: 0.45,
      difficulty: 'beginner',
      estimatedTime: '40시간',
      topics: ['문법', '회화', '작문', '독해'],
    ),
    SubjectDetail(
      id: '3',
      name: '과학',
      icon: Icons.science_rounded,
      color: const Color(0xFF395886),
      category: 'science',
      description: '재미있는 실험과 함께하는 과학 탐구',
      totalLessons: 100,
      completedLessons: 80,
      progress: 0.80,
      difficulty: 'advanced',
      estimatedTime: '25시간',
      topics: ['물리', '화학', '생물', '지구과학'],
    ),
    SubjectDetail(
      id: '4',
      name: '역사',
      icon: Icons.history_edu_rounded,
      color: const Color(0xFF8AAEE0),
      category: 'humanities',
      description: '한국사와 세계사를 한눈에',
      totalLessons: 80,
      completedLessons: 24,
      progress: 0.30,
      difficulty: 'intermediate',
      estimatedTime: '20시간',
      topics: ['한국사', '세계사', '문화사', '근현대사'],
    ),
    SubjectDetail(
      id: '5',
      name: '코딩',
      icon: Icons.code_rounded,
      color: const Color(0xFF10B981),
      category: 'technology',
      description: '프로그래밍 기초부터 실전까지',
      totalLessons: 90,
      completedLessons: 81,
      progress: 0.90,
      difficulty: 'intermediate',
      estimatedTime: '35시간',
      topics: ['Python', 'JavaScript', 'HTML/CSS', '알고리즘'],
    ),
    SubjectDetail(
      id: '6',
      name: '국어',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF395886),
      category: 'language',
      description: '문학과 언어의 아름다움',
      totalLessons: 110,
      completedLessons: 61,
      progress: 0.55,
      difficulty: 'beginner',
      estimatedTime: '30시간',
      topics: ['문학', '문법', '작문', '화법'],
    ),
  ];

  List<SubjectDetail> get _filteredSubjects {
    var filtered = _subjects;
    
    if (_selectedCategory != 'all') {
      filtered = filtered.where((s) => s.category == _selectedCategory).toList();
    }
    
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'progress':
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'difficulty':
        final difficultyOrder = {'beginner': 0, 'intermediate': 1, 'advanced': 2};
        filtered.sort((a, b) => 
          difficultyOrder[a.difficulty]!.compareTo(difficultyOrder[b.difficulty]!));
        break;
    }
    
    return filtered;
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
              
              // Filter and Sort
              _buildFilterSort(),
              
              // Subject Grid
              Expanded(
                child: _buildSubjectGrid(),
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
            '과목 선택',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_subjects.length}개 과목',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF638ECB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSort() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category Filter
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('전체', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('과학', 'science'),
                  const SizedBox(width: 8),
                  _buildFilterChip('언어', 'language'),
                  const SizedBox(width: 8),
                  _buildFilterChip('인문', 'humanities'),
                  const SizedBox(width: 8),
                  _buildFilterChip('기술', 'technology'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              items: const [
                DropdownMenuItem(value: 'name', child: Text('이름순')),
                DropdownMenuItem(value: 'progress', child: Text('진도순')),
                DropdownMenuItem(value: 'difficulty', child: Text('난이도순')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
              underline: const SizedBox(),
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Color(0xFF395886),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF262626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF395886)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF395886)
                : const Color(0xFFE5E5E5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected 
                ? Colors.white
                : const Color(0xFF525252),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectGrid() {
    final subjects = _filteredSubjects;
    
    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Color(0xFFD4D4D4),
            ),
            SizedBox(height: 16),
            Text(
              '해당하는 과목이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF525252),
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(subjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(SubjectDetail subject) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to subject detail
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: subject.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        subject.icon,
                        size: 24,
                        color: subject.color,
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: subject.progress,
                            backgroundColor: const Color(0xFFE5E5E5),
                            valueColor: AlwaysStoppedAnimation<Color>(subject.color),
                            strokeWidth: 4,
                          ),
                        ),
                        Text(
                          '${(subject.progress * 100).toInt()}%',
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
                
                const SizedBox(height: 12),
                
                // Subject Name
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Description
                Text(
                  subject.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF737373),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Stats
                Row(
                  children: [
                    Icon(
                      Icons.play_lesson_rounded,
                      size: 14,
                      color: const Color(0xFF737373),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.completedLessons}/${subject.totalLessons}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF737373),
                      ),
                    ),
                    const Spacer(),
                    _buildDifficultyBadge(subject.difficulty),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Topics
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: subject.topics.take(2).map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF638ECB),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    
    switch (difficulty) {
      case 'beginner':
        color = const Color(0xFF10B981);
        label = '초급';
        break;
      case 'intermediate':
        color = const Color(0xFFFFC107);
        label = '중급';
        break;
      case 'advanced':
        color = const Color(0xFFEF4444);
        label = '고급';
        break;
      default:
        color = const Color(0xFF737373);
        label = '일반';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class SubjectDetail {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String category;
  final String description;
  final int totalLessons;
  final int completedLessons;
  final double progress;
  final String difficulty;
  final String estimatedTime;
  final List<String> topics;

  SubjectDetail({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    required this.description,
    required this.totalLessons,
    required this.completedLessons,
    required this.progress,
    required this.difficulty,
    required this.estimatedTime,
    required this.topics,
  });
}