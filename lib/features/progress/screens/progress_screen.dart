import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Card
                      _buildOverviewCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Period Selector
                      _buildPeriodSelector(),
                      
                      const SizedBox(height: 24),
                      
                      // Study Time Chart
                      _buildStudyTimeChart(),
                      
                      const SizedBox(height: 24),
                      
                      // Subject Progress
                      _buildSubjectProgress(),
                      
                      const SizedBox(height: 24),
                      
                      // Achievements
                      _buildAchievements(),
                      
                      const SizedBox(height: 24),
                      
                      // Goals
                      _buildGoals(),
                    ],
                  ),
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
            '학습 진도',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // Share progress
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '레벨 12',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '1,250 / 2,000 XP',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 0.625,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 8,
                    ),
                  ),
                  const Text(
                    '62.5%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewStat('총 학습 시간', '125시간'),
              _buildOverviewStat('완료 레슨', '342개'),
              _buildOverviewStat('연속 학습', '7일'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton('일', 'day'),
          ),
          Expanded(
            child: _buildPeriodButton('주', 'week'),
          ),
          Expanded(
            child: _buildPeriodButton('월', 'month'),
          ),
          Expanded(
            child: _buildPeriodButton('년', 'year'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF395886) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF737373),
          ),
        ),
      ),
    );
  }

  Widget _buildStudyTimeChart() {
    return Container(
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
          const Text(
            '학습 시간',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final days = ['월', '화', '수', '목', '금', '토', '일'];
                final values = [0.7, 0.5, 0.9, 0.6, 0.8, 0.4, 0.95];
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(values[index] * 5).toStringAsFixed(1)}h',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF737373),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: values[index] * 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF638ECB),
                            const Color(0xFF8AAEE0),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF525252),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '과목별 진도',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        const SizedBox(height: 12),
        _buildSubjectItem('수학', 0.75, const Color(0xFF8AAEE0)),
        const SizedBox(height: 8),
        _buildSubjectItem('영어', 0.60, const Color(0xFF638ECB)),
        const SizedBox(height: 8),
        _buildSubjectItem('과학', 0.85, const Color(0xFF395886)),
        const SizedBox(height: 8),
        _buildSubjectItem('역사', 0.45, const Color(0xFF8AAEE0)),
      ],
    );
  }

  Widget _buildSubjectItem(String name, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE5E5E5),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 업적',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626), // gray800
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all achievements
              },
              child: const Text(
                '모두 보기',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF638ECB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildAchievementBadge(
              icon: Icons.local_fire_department_rounded,
              label: '7일 연속',
              color: Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildAchievementBadge(
              icon: Icons.school_rounded,
              label: '우등생',
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildAchievementBadge(
              icon: Icons.speed_rounded,
              label: '스피드런',
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            _buildAchievementBadge(
              icon: Icons.star_rounded,
              label: '퍼펙트',
              color: Colors.purple,
              isLocked: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required String label,
    required Color color,
    bool isLocked = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLocked 
            ? const Color(0xFFE5E5E5) 
            : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked ? const Color(0xFFD4D4D4) : color,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isLocked ? Icons.lock_rounded : icon,
              size: 32,
              color: isLocked ? const Color(0xFF737373) : color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isLocked ? const Color(0xFF737373) : color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '목표',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        const SizedBox(height: 12),
        _buildGoalItem(
          title: '주간 학습 시간',
          current: 15,
          target: 20,
          unit: '시간',
          color: const Color(0xFF638ECB),
        ),
        const SizedBox(height: 8),
        _buildGoalItem(
          title: '일일 문제 풀이',
          current: 25,
          target: 30,
          unit: '문제',
          color: const Color(0xFF8AAEE0),
        ),
      ],
    );
  }

  Widget _buildGoalItem({
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color color,
  }) {
    final progress = current / target;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              ),
              Text(
                '$current / $target $unit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE5E5E5),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% 달성',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF737373),
            ),
          ),
        ],
      ),
    );
  }
}