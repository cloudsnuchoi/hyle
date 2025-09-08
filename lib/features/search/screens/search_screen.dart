import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _selectedFilter = 'all';
  bool _isSearching = false;
  
  // Mock search results
  final List<SearchResult> _recentSearches = [
    SearchResult(type: 'lesson', title: '미적분 기초', category: '수학'),
    SearchResult(type: 'topic', title: '영어 문법', category: '영어'),
    SearchResult(type: 'practice', title: '물리 문제집', category: '과학'),
  ];

  List<SearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _searchResults = _generateMockResults(query);
        _isSearching = false;
      });
    });
  }

  List<SearchResult> _generateMockResults(String query) {
    return [
      SearchResult(
        type: 'lesson',
        title: '$query 기초 강의',
        category: '수학',
        description: '초보자를 위한 쉬운 설명',
      ),
      SearchResult(
        type: 'practice',
        title: '$query 연습 문제',
        category: '수학',
        description: '100개의 문제로 실력 향상',
      ),
      SearchResult(
        type: 'topic',
        title: '$query 심화 학습',
        category: '과학',
        description: '고급 개념과 응용',
      ),
      SearchResult(
        type: 'user',
        title: '$query 스터디 그룹',
        category: '커뮤니티',
        description: '함께 공부할 친구들',
      ),
    ];
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
              // Search Bar
              _buildSearchBar(),
              
              // Filter Tabs
              _buildFilterTabs(),
              
              // Content
              Expanded(
                child: _searchController.text.isEmpty
                    ? _buildDefaultContent()
                    : _isSearching
                        ? _buildSearchingIndicator()
                        : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '레슨, 주제, 사용자 검색...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF737373), // gray500
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF737373),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Color(0xFF737373),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _performSearch,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
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
          Tab(text: '전체'),
          Tab(text: '레슨'),
          Tab(text: '주제'),
          Tab(text: '사용자'),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('최근 검색', Icons.history_rounded),
            const SizedBox(height: 12),
            ..._recentSearches.map((result) => _buildSearchItem(result)),
            const SizedBox(height: 24),
          ],
          
          // Popular Topics
          _buildSectionHeader('인기 주제', Icons.trending_up_rounded),
          const SizedBox(height: 12),
          _buildPopularTopics(),
          
          const SizedBox(height: 24),
          
          // Recommended Lessons
          _buildSectionHeader('추천 레슨', Icons.recommend_rounded),
          const SizedBox(height: 12),
          _buildRecommendedLessons(),
        ],
      ),
    );
  }

  Widget _buildSearchingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
          ),
          const SizedBox(height: 16),
          Text(
            '검색 중...',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF737373), // gray500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: const Color(0xFFD4D4D4), // gray300
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF525252), // gray600
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 키워드로 검색해보세요',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF737373), // gray500
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchItem(_searchResults[index]);
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF638ECB),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
      ],
    );
  }

  Widget _buildSearchItem(SearchResult result) {
    IconData icon;
    Color color;
    
    switch (result.type) {
      case 'lesson':
        icon = Icons.play_circle_outline_rounded;
        color = const Color(0xFF638ECB);
        break;
      case 'topic':
        icon = Icons.topic_outlined;
        color = const Color(0xFF8AAEE0);
        break;
      case 'practice':
        icon = Icons.edit_note_rounded;
        color = const Color(0xFF395886);
        break;
      case 'user':
        icon = Icons.person_outline_rounded;
        color = const Color(0xFF10B981);
        break;
      default:
        icon = Icons.circle_outlined;
        color = const Color(0xFF737373);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to result
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
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF262626), // gray800
                        ),
                      ),
                      const SizedBox(height: 2),
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
                              result.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF638ECB),
                              ),
                            ),
                          ),
                          if (result.description != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF737373), // gray500
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF737373), // gray500
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTopics() {
    final topics = [
      {'name': '수학', 'icon': Icons.calculate_rounded, 'color': const Color(0xFF8AAEE0)},
      {'name': '영어', 'icon': Icons.abc_rounded, 'color': const Color(0xFF638ECB)},
      {'name': '과학', 'icon': Icons.science_rounded, 'color': const Color(0xFF395886)},
      {'name': '코딩', 'icon': Icons.code_rounded, 'color': const Color(0xFF10B981)},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: topics.map((topic) {
        return ActionChip(
          onPressed: () {
            _searchController.text = topic['name'] as String;
            _performSearch(topic['name'] as String);
          },
          avatar: Icon(
            topic['icon'] as IconData,
            size: 18,
            color: topic['color'] as Color,
          ),
          label: Text(topic['name'] as String),
          backgroundColor: (topic['color'] as Color).withValues(alpha: 0.1),
          labelStyle: TextStyle(
            fontSize: 14,
            color: topic['color'] as Color,
          ),
          side: BorderSide(
            color: topic['color'] as Color,
            width: 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedLessons() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          final lessons = [
            {'title': '미적분 입문', 'subject': '수학', 'level': '초급'},
            {'title': '영어 회화', 'subject': '영어', 'level': '중급'},
            {'title': '물리 실험', 'subject': '과학', 'level': '고급'},
            {'title': 'Python 기초', 'subject': '코딩', 'level': '초급'},
            {'title': '한국사 정리', 'subject': '역사', 'level': '중급'},
          ];
          
          final lesson = lessons[index];
          
          return Container(
            width: 150,
            margin: EdgeInsets.only(
              right: 12,
              left: index == 0 ? 0 : 0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF638ECB).withValues(alpha: 0.8),
                  const Color(0xFF395886),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF395886).withValues(alpha: 0.3),
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
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.play_circle_filled_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                      const Spacer(),
                      Text(
                        lesson['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lesson['subject']!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lesson['level']!,
                              style: const TextStyle(
                                fontSize: 10,
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
        },
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '필터 옵션',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Filter options would go here
              const Text('필터 옵션이 여기에 표시됩니다'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class SearchResult {
  final String type;
  final String title;
  final String category;
  final String? description;

  SearchResult({
    required this.type,
    required this.title,
    required this.category,
    this.description,
  });
}