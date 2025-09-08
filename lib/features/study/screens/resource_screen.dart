import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResourceScreen extends ConsumerStatefulWidget {
  const ResourceScreen({super.key});

  @override
  ConsumerState<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends ConsumerState<ResourceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  String _selectedType = 'All';
  String _selectedSubject = 'All';

  final List<Map<String, dynamic>> _resources = [
    {
      'id': '1',
      'title': 'Advanced Calculus Textbook',
      'type': 'PDF',
      'subject': 'Mathematics',
      'size': '15.2 MB',
      'pages': 450,
      'downloads': 1234,
      'rating': 4.8,
      'thumbnail': Icons.picture_as_pdf,
      'color': Colors.red,
    },
    {
      'id': '2',
      'title': 'Physics Lab Experiments',
      'type': 'Video',
      'subject': 'Physics',
      'duration': '2h 15min',
      'quality': '1080p',
      'downloads': 890,
      'rating': 4.9,
      'thumbnail': Icons.play_circle_fill,
      'color': Colors.blue,
    },
    {
      'id': '3',
      'title': 'Chemistry Formula Sheet',
      'type': 'Document',
      'subject': 'Chemistry',
      'size': '2.1 MB',
      'pages': 25,
      'downloads': 2456,
      'rating': 4.7,
      'thumbnail': Icons.description,
      'color': Colors.green,
    },
    {
      'id': '4',
      'title': 'Interactive Biology Quiz',
      'type': 'Interactive',
      'subject': 'Biology',
      'questions': 50,
      'difficulty': 'Medium',
      'downloads': 567,
      'rating': 4.6,
      'thumbnail': Icons.quiz,
      'color': Colors.purple,
    },
    {
      'id': '5',
      'title': 'English Grammar Guide',
      'type': 'Audio',
      'subject': 'English',
      'duration': '45min',
      'size': '35 MB',
      'downloads': 789,
      'rating': 4.5,
      'thumbnail': Icons.headphones,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildFilters(),
                _buildStats(),
                Expanded(child: _buildResourceGrid()),
              ],
            ),
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
              'Learning Resources',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Color(0xFF395886)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF8AAEE0)),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search resources...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Color(0xFF638ECB)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        // Type filter
        Container(
          height: 40,
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'PDF', 'Video', 'Audio', 'Document', 'Interactive'].map((type) {
              final isSelected = _selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedType = type);
                  },
                  selectedColor: const Color(0xFF638ECB),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF395886),
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Subject filter
        Container(
          height: 40,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Mathematics', 'Physics', 'Chemistry', 'Biology', 'English'].map((subject) {
              final isSelected = _selectedSubject == subject;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(subject),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedSubject = subject);
                  },
                  selectedColor: const Color(0xFF8AAEE0),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF395886),
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final totalResources = _resources.length;
    final totalDownloads = _resources.fold<int>(
      0, (sum, r) => sum + (r['downloads'] as int));
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.folder, '$totalResources Resources'),
          _buildStatItem(Icons.download, '${(totalDownloads / 1000).toStringAsFixed(1)}K Downloads'),
          _buildStatItem(Icons.star, '4.7 Avg Rating'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF638ECB)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF395886),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _resources.length,
      itemBuilder: (context, index) {
        return _buildResourceCard(_resources[index]);
      },
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: (resource['color'] as Color).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  resource['thumbnail'],
                  size: 48,
                  color: resource['color'],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF395886),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        resource['type'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF638ECB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${resource['rating']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF395886),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.download, size: 12, color: const Color(0xFF8AAEE0)),
                        const SizedBox(width: 2),
                        Text(
                          '${resource['downloads']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8AAEE0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (resource['size'] != null)
                      Text(
                        resource['size'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD5DEEF),
                        ),
                      ),
                    if (resource['duration'] != null)
                      Text(
                        resource['duration'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD5DEEF),
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