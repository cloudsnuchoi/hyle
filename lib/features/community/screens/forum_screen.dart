import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedSort = 'recent';
  String _selectedCategory = 'all';
  
  final List<ForumPost> _posts = [
    ForumPost(
      id: '1',
      title: '이차방정식 문제 질문드립니다',
      content: '근의 공식을 적용할 때 판별식이 음수가 나오는데...',
      author: '학습자123',
      category: '수학',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      views: 234,
      answers: 5,
      likes: 12,
      isSolved: true,
      tags: ['이차방정식', '근의공식', '판별식'],
    ),
    ForumPost(
      id: '2',
      title: '영어 문법 to부정사 vs 동명사 차이점',
      content: 'stop to do와 stop doing의 차이가 헷갈려요',
      author: '영어초보',
      category: '영어',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      views: 456,
      answers: 8,
      likes: 23,
      isSolved: false,
      tags: ['문법', 'to부정사', '동명사'],
    ),
    ForumPost(
      id: '3',
      title: '물리학 운동량 보존 법칙 문제',
      content: '충돌 후 속도를 구하는 문제입니다',
      author: '과학탐구',
      category: '과학',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      views: 189,
      answers: 3,
      likes: 7,
      isSolved: true,
      tags: ['물리', '운동량', '충돌'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
                      '질문 & 답변',
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
                  ],
                ),
              ),

              // Stats Row
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('오늘 질문', '45', Icons.help_outline),
                      _buildStatItem('답변 대기', '12', Icons.hourglass_empty),
                      _buildStatItem('해결됨', '89%', Icons.check_circle),
                      _buildStatItem('활동 멤버', '234', Icons.people),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Filter Row
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('전체', 'all'),
                    _buildFilterChip('미해결', 'unsolved'),
                    _buildFilterChip('해결됨', 'solved'),
                    _buildFilterChip('인기', 'popular'),
                    const SizedBox(width: 16),
                    Container(width: 1, color: Colors.grey[300]),
                    const SizedBox(width: 16),
                    _buildSortChip('최신순', 'recent'),
                    _buildSortChip('답변많은순', 'answers'),
                    _buildSortChip('조회순', 'views'),
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
                    Tab(text: '전체'),
                    Tab(text: '수학'),
                    Tab(text: '영어'),
                    Tab(text: '과학'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Posts List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsList(_posts),
                    _buildPostsList(_posts.where((p) => p.category == '수학').toList()),
                    _buildPostsList(_posts.where((p) => p.category == '영어').toList()),
                    _buildPostsList(_posts.where((p) => p.category == '과학').toList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(),
        backgroundColor: const Color(0xFF638ECB),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          '질문하기',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF638ECB), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1E27),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
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
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSort = value;
          });
        },
        selectedColor: const Color(0xFF8AAEE0).withValues(alpha: 0.2),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPostsList(List<ForumPost> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '아직 게시글이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: post.isSolved
            ? Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: post.isSolved
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF638ECB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (post.isSolved)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '해결됨',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E27),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8AAEE0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8AAEE0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      post.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.visibility_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${post.views}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${post.answers}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite_outline, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likes}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  void _showCreatePostDialog() {
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    '새 질문 작성',
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
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: '제목',
                        hintText: '질문 제목을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: '내용',
                        hintText: '질문 내용을 자세히 작성해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF638ECB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '질문 등록',
                          style: TextStyle(
                            fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}

// Forum Post Model
class ForumPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final String category;
  final DateTime createdAt;
  final int views;
  final int answers;
  final int likes;
  final bool isSolved;
  final List<String> tags;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.createdAt,
    required this.views,
    required this.answers,
    required this.likes,
    required this.isSolved,
    required this.tags,
  });
}