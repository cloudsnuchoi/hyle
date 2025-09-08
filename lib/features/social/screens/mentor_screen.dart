import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key});

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;

  String _selectedSubject = 'All';

  final List<Map<String, dynamic>> _mentors = [
    {
      'id': '1',
      'name': 'Dr. Sarah Johnson',
      'avatar': '👩‍🏫',
      'subject': 'Mathematics',
      'specialization': 'Advanced Calculus',
      'rating': 4.9,
      'reviews': 342,
      'students': 1250,
      'experience': '15 years',
      'languages': ['English', 'Spanish'],
      'availability': 'Available',
      'price': 45,
    },
    {
      'id': '2',
      'name': 'Prof. Michael Chen',
      'avatar': '👨‍🎓',
      'subject': 'Physics',
      'specialization': 'Quantum Mechanics',
      'rating': 4.8,
      'reviews': 278,
      'students': 890,
      'experience': '12 years',
      'languages': ['English', 'Chinese'],
      'availability': 'Busy',
      'price': 50,
    },
    {
      'id': '3',
      'name': 'Ms. Emily Roberts',
      'avatar': '👩‍💻',
      'subject': 'Computer Science',
      'specialization': 'AI & Machine Learning',
      'rating': 4.9,
      'reviews': 456,
      'students': 2100,
      'experience': '8 years',
      'languages': ['English', 'French'],
      'availability': 'Available',
      'price': 55,
    },
    {
      'id': '4',
      'name': 'Dr. James Wilson',
      'avatar': '👨‍🔬',
      'subject': 'Chemistry',
      'specialization': 'Organic Chemistry',
      'rating': 4.7,
      'reviews': 198,
      'students': 650,
      'experience': '10 years',
      'languages': ['English'],
      'availability': 'Offline',
      'price': 40,
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

    _slideIn = Tween<double>(
      begin: 30.0,
      end: 0.0,
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, _slideIn.value),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildSubjectFilter(),
                      Expanded(child: _buildMentorList()),
                    ],
                  ),
                ),
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
              'Find a Mentor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF395886)),
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
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search by name or specialization...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF8AAEE0)),
        ),
      ),
    );
  }

  Widget _buildSubjectFilter() {
    final subjects = ['All', 'Mathematics', 'Physics', 'Chemistry', 'Computer Science'];
    return Container(
      height: 40,
      margin: const EdgeInsets.all(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedSubject == subjects[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(subjects[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedSubject = subjects[index]);
              },
              selectedColor: const Color(0xFF638ECB),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF395886),
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMentorList() {
    final filteredMentors = _selectedSubject == 'All'
        ? _mentors
        : _mentors.where((m) => m['subject'] == _selectedSubject).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredMentors.length,
      itemBuilder: (context, index) {
        return _buildMentorCard(filteredMentors[index]);
      },
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      mentor['avatar'],
                      style: const TextStyle(fontSize: 32),
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
                              mentor['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF395886),
                              ),
                            ),
                          ),
                          _buildAvailabilityBadge(mentor['availability']),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor['specialization'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF638ECB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${mentor['rating']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF395886),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${mentor['reviews']} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8AAEE0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FA),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(Icons.school, mentor['subject']),
                    _buildInfoItem(Icons.people, '${mentor['students']} students'),
                    _buildInfoItem(Icons.access_time, mentor['experience']),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.language, size: 14, color: const Color(0xFF8AAEE0)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: (mentor['languages'] as List).map((lang) {
                          return Chip(
                            label: Text(
                              lang,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${mentor['price']}/hr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('View Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF638ECB),
                          side: const BorderSide(color: Color(0xFF638ECB)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: mentor['availability'] == 'Available' ? () {} : null,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text('Book Session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF638ECB),
                          disabledBackgroundColor: const Color(0xFFD5DEEF),
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
    );
  }

  Widget _buildAvailabilityBadge(String availability) {
    Color color;
    switch (availability) {
      case 'Available':
        color = Colors.green;
        break;
      case 'Busy':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            availability,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8AAEE0)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF395886),
          ),
        ),
      ],
    );
  }
}