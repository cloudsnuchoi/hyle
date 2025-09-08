import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicScreen extends ConsumerStatefulWidget {
  const TopicScreen({super.key});

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleIn;

  String _selectedSubject = 'Mathematics';
  String _selectedDifficulty = 'All';
  final Set<String> _completedTopics = {'topic1', 'topic3'};
  final Set<String> _bookmarkedTopics = {'topic2', 'topic4'};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideIn = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ));

    _scaleIn = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _controller.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
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
              Color(0xFF395886),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  _buildHeader(),
                  _buildSubjectSelector(),
                  _buildFilterSection(),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(0, _slideIn.value),
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: _buildTopicList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF395886)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Study Topics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF395886)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelector() {
    final subjects = ['Mathematics', 'Science', 'History', 'Literature', 'Programming'];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = _selectedSubject == subject;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedSubject = subject),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF638ECB) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF395886),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    final difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Difficulty:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(width: 12),
          ...difficulties.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(difficulty),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedDifficulty = difficulty);
                },
                selectedColor: const Color(0xFF638ECB),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF395886),
                  fontSize: 12,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopicList() {
    final topics = [
      {
        'id': 'topic1',
        'title': 'Algebra Basics',
        'lessons': 12,
        'duration': '2h 30m',
        'difficulty': 'Beginner',
        'progress': 100,
      },
      {
        'id': 'topic2',
        'title': 'Calculus I',
        'lessons': 15,
        'duration': '3h 45m',
        'difficulty': 'Intermediate',
        'progress': 65,
      },
      {
        'id': 'topic3',
        'title': 'Geometry',
        'lessons': 10,
        'duration': '2h 15m',
        'difficulty': 'Beginner',
        'progress': 100,
      },
      {
        'id': 'topic4',
        'title': 'Statistics',
        'lessons': 8,
        'duration': '1h 50m',
        'difficulty': 'Intermediate',
        'progress': 40,
      },
      {
        'id': 'topic5',
        'title': 'Linear Algebra',
        'lessons': 20,
        'duration': '4h 30m',
        'difficulty': 'Advanced',
        'progress': 0,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Transform.scale(
          scale: _scaleIn.value,
          child: _buildTopicCard(topic),
        );
      },
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    final isCompleted = _completedTopics.contains(topic['id']);
    final isBookmarked = _bookmarkedTopics.contains(topic['id']);
    final progress = (topic['progress'] as int) / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to topic detail
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF638ECB).withValues(alpha: 0.1)
                            : const Color(0xFF8AAEE0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.menu_book,
                        color: isCompleted
                            ? const Color(0xFF638ECB)
                            : const Color(0xFF8AAEE0),
                        size: 28,
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
                                  topic['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF395886),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: const Color(0xFF638ECB),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isBookmarked) {
                                      _bookmarkedTopics.remove(topic['id']);
                                    } else {
                                      _bookmarkedTopics.add(topic['id']);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.library_books,
                                '${topic['lessons']} lessons',
                              ),
                              const SizedBox(width: 12),
                              _buildInfoChip(
                                Icons.access_time,
                                topic['duration'],
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(topic['difficulty'])
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  topic['difficulty'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getDifficultyColor(topic['difficulty']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF8AAEE0),
                          ),
                        ),
                        Text(
                          '${topic['progress']}%',
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
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: progress * _progressController.value,
                          backgroundColor: const Color(0xFFD5DEEF),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? const Color(0xFF638ECB)
                                : const Color(0xFF8AAEE0),
                          ),
                          minHeight: 6,
                        );
                      },
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8AAEE0)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8AAEE0),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return const Color(0xFF8AAEE0);
    }
  }
}