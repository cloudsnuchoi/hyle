import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final List<Map<String, dynamic>> _history = [
    {
      'date': DateTime.now(),
      'activities': [
        {'type': 'study', 'title': '수학 수업 완료', 'time': '09:00', 'duration': '45분'},
        {'type': 'quiz', 'title': '물리학 퀴즈 - 85%', 'time': '10:30', 'duration': '20분'},
        {'type': 'achievement', 'title': '"학습 연속" 배지 획득', 'time': '11:00', 'duration': ''},
      ],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'activities': [
        {'type': 'study', 'title': '화학 5장', 'time': '14:00', 'duration': '60분'},
        {'type': 'practice', 'title': '영어 문법 연습', 'time': '16:00', 'duration': '30분'},
      ],
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
                _buildStats(),
                Expanded(child: _buildHistoryList()),
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
              '학습 기록',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF395886)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('7', '연속 일수', Icons.local_fire_department),
          _buildStatItem('156', '총 세션', Icons.timer),
          _buildStatItem('4.5h', '오늘', Icons.today),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF638ECB), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8AAEE0),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        return _buildDaySection(_history[index]);
      },
    );
  }

  Widget _buildDaySection(Map<String, dynamic> day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _formatDate(day['date']),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
        ),
        ...List.generate(
          day['activities'].length,
          (index) => _buildActivityItem(day['activities'][index]),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, String> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityColor(activity['type']!).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getActivityIcon(activity['type']!),
              color: _getActivityColor(activity['type']!),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF395886),
                  ),
                ),
                if (activity['duration']!.isNotEmpty)
                  Text(
                    activity['duration']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8AAEE0),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            activity['time']!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFD5DEEF),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'study':
        return Icons.menu_book;
      case 'quiz':
        return Icons.quiz;
      case 'practice':
        return Icons.edit;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.check_circle;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'study':
        return const Color(0xFF8AAEE0);
      case 'quiz':
        return const Color(0xFF638ECB);
      case 'practice':
        return const Color(0xFF395886);
      case 'achievement':
        return Colors.amber;
      default:
        return const Color(0xFF8AAEE0);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '오늘';
    }
    if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return '어제';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}