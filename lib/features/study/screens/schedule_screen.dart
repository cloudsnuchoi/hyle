import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _calendarController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleIn;

  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'month'; // week, month, day
  
  // 샘플 일정 데이터 (나중에 Supabase와 연동)
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': '1',
      'title': '수학 중간고사',
      'subject': '수학',
      'date': DateTime.now(),
      'startTime': '09:00',
      'endTime': '10:30',
      'color': const Color(0xFFFF6B6B),
      'type': 'exam',
    },
    {
      'id': '2',
      'title': '영어 단어 시험',
      'subject': '영어',
      'date': DateTime.now().add(const Duration(days: 1)),
      'startTime': '14:00',
      'endTime': '15:00',
      'color': const Color(0xFF4ECDC4),
      'type': 'quiz',
    },
    {
      'id': '3',
      'title': '물리 실험',
      'subject': '과학',
      'date': DateTime.now().add(const Duration(days: 2)),
      'startTime': '13:00',
      'endTime': '15:00',
      'color': const Color(0xFF8338EC),
      'type': 'lab',
    },
    {
      'id': '4',
      'title': '국어 발표',
      'subject': '국어',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'startTime': '10:00',
      'endTime': '11:00',
      'color': const Color(0xFFFFBE0B),
      'type': 'presentation',
    },
    {
      'id': '5',
      'title': '한국사 보고서 마감',
      'subject': '한국사',
      'date': DateTime.now().add(const Duration(days: 3)),
      'startTime': '23:59',
      'endTime': '23:59',
      'color': const Color(0xFFFB5607),
      'type': 'assignment',
    },
    {
      'id': '6',
      'title': '사회 토론',
      'subject': '사회',
      'date': DateTime.now().add(const Duration(days: 4)),
      'startTime': '15:00',
      'endTime': '16:30',
      'color': const Color(0xFF3A86FF),
      'type': 'discussion',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _calendarController.dispose();
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
                  _buildViewModeSelector(),
                  Expanded(
                    child: _buildCalendarView(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddScheduleDialog();
        },
        backgroundColor: const Color(0xFF638ECB),
        child: const Icon(Icons.add, color: Colors.white),
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
              '학습 일정',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.today, color: Color(0xFF395886)),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    final modes = [
      {'id': 'day', 'label': 'Day', 'icon': Icons.view_day},
      {'id': 'week', 'label': 'Week', 'icon': Icons.view_week},
      {'id': 'month', 'label': 'Month', 'icon': Icons.calendar_month},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: modes.map((mode) {
          final isSelected = _viewMode == mode['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _viewMode = mode['id'] as String;
                });
                _calendarController.reset();
                _calendarController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF638ECB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      mode['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF395886),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mode['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : const Color(0xFF395886),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Transform.scale(
      scale: _scaleIn.value,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            // Day 뷰에서는 헤더 생략 (이미 Day 뷰 안에 포함됨)
            if (_viewMode != 'day') _buildCalendarHeader(),
            if (_viewMode != 'day') const SizedBox(height: 16),
            if (_viewMode == 'week') Expanded(child: _buildWeekView()),
            if (_viewMode == 'month') Expanded(child: _buildMonthView()),
            if (_viewMode == 'day') Expanded(child: _buildDayView()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF638ECB)),
          onPressed: () {
            setState(() {
              if (_viewMode == 'day') {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              } else if (_viewMode == 'week') {
                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
              } else {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                  _selectedDate.day,
                );
              }
            });
          },
        ),
        Text(
          _getDateRangeText(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Color(0xFF638ECB)),
          onPressed: () {
            setState(() {
              if (_viewMode == 'day') {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              } else if (_viewMode == 'week') {
                _selectedDate = _selectedDate.add(const Duration(days: 7));
              } else {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                  _selectedDate.day,
                );
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 주간 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _isSameDay(date, _selectedDate);
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedDate = date;
                    _viewMode = 'day';  // 날짜 클릭 시 Day 뷰로 전환
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF638ECB)
                          : isToday
                              ? const Color(0xFF8AAEE0).withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          weekDays[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? const Color(0xFF638ECB)
                                    : const Color(0xFF8AAEE0),
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? const Color(0xFF638ECB)
                                    : const Color(0xFF395886),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // 주간 일정 표시
          Expanded(
            child: Row(
              children: List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final daySchedules = _schedules.where((s) => 
                  _isSameDay(s['date'], date)
                ).toList();
                
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        Expanded(
                          child: daySchedules.isEmpty
                              ? Center(
                                  child: Text(
                                    '-',
                                    style: TextStyle(
                                      color: Colors.grey.shade300,
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: daySchedules.length,
                                  itemBuilder: (context, idx) {
                                    final schedule = daySchedules[idx];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: (schedule['color'] as Color).withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            schedule['startTime'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            schedule['title'],
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    final now = DateTime.now();
    final currentMonth = _selectedDate.month;
    final currentYear = _selectedDate.year;
    
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);
    
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    
    // 필요한 행 수 계산 (더 효율적으로)
    final rows = ((daysInMonth + startWeekday) / 7).ceil();
    final totalCells = rows * 7;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // 가용 높이를 기반으로 셀 높이 계산
        final availableHeight = constraints.maxHeight - 50; // 헤더 높이 제외
        final cellHeight = availableHeight / rows;
        final cellWidth = constraints.maxWidth / 7;
        final aspectRatio = cellWidth / cellHeight;
        
        return Column(
          children: [
            // Week days header
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: day == '일' 
                              ? Colors.red.shade400 
                              : day == '토' 
                                  ? Colors.blue.shade400 
                                  : const Color(0xFF8AAEE0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            
            // Calendar grid - 남은 공간 전체 활용
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: aspectRatio,  // 동적으로 계산된 비율 사용
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox();
              }
              
              final day = index - startWeekday + 1;
              if (day > daysInMonth) {
                return const SizedBox();
              }
              
              final date = DateTime(currentYear, currentMonth, day);
              final isToday = date.year == now.year && 
                             date.month == now.month && 
                             date.day == now.day;
              final isSelected = _selectedDate.year == date.year &&
                                _selectedDate.month == date.month &&
                                _selectedDate.day == date.day;
              
              // Check if there are schedules on this date
              final schedulesOnDate = _schedules.where((schedule) {
                final scheduleDate = schedule['date'] as DateTime;
                return scheduleDate.year == date.year &&
                       scheduleDate.month == date.month &&
                       scheduleDate.day == date.day;
              }).toList();
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    // 날짜 클릭 시 일 뷰로 전환
                    _viewMode = 'day';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF638ECB).withOpacity(0.1)
                        : isToday
                            ? const Color(0xFF8AAEE0).withOpacity(0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF638ECB)
                          : isToday
                              ? const Color(0xFF8AAEE0)
                              : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 표시
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected || isToday
                                ? const Color(0xFF638ECB)
                                : const Color(0xFF395886),
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      // 일정 표시 (최대 3개)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...schedulesOnDate.take(3).map((schedule) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                decoration: BoxDecoration(
                                  color: schedule['color'],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  schedule['title'],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            // 더 많은 일정이 있을 때
                            if (schedulesOnDate.length > 3)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '+${schedulesOnDate.length - 3} more',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildDayView() {
    final daySchedules = _schedules.where((s) => 
      _isSameDay(s['date'], _selectedDate)
    ).toList();
    
    // 시간순으로 정렬
    daySchedules.sort((a, b) => 
      (a['startTime'] as String).compareTo(b['startTime'] as String));

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더 with 네비게이션 통합
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF638ECB),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF395886),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDayName(_selectedDate.weekday),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8AAEE0),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF638ECB),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          
          // 일정 목록
          Expanded(
            child: daySchedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 80,
                          color: const Color(0xFF8AAEE0).withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '오늘은 일정이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8AAEE0),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = daySchedules[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 시간
                            SizedBox(
                              width: 80,
                              child: Text(
                                schedule['startTime'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8AAEE0),
                                ),
                              ),
                            ),
                            // 일정 카드
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (schedule['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: schedule['color'],
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schedule['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF395886),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.subject,
                                          size: 14,
                                          color: schedule['color'],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          schedule['subject'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: schedule['color'],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${schedule['startTime']} - ${schedule['endTime']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final todaySchedules = _schedules.where((s) => 
      _isSameDay(s['date'], _selectedDate)
    ).toList();

    if (todaySchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: const Color(0xFF8AAEE0).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              '이 날에는 일정이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8AAEE0),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: todaySchedules.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(todaySchedules[index]);
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showScheduleDetailsDialog(schedule),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: schedule['color'],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF395886),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: const Color(0xFF8AAEE0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule['time'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8AAEE0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: schedule['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              schedule['subject'],
                              style: TextStyle(
                                fontSize: 12,
                                color: schedule['color'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getScheduleIcon(schedule['type']),
                  color: schedule['color'],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getScheduleIcon(String type) {
    switch (type) {
      case 'study':
        return Icons.menu_book;
      case 'quiz':
        return Icons.quiz;
      case 'assignment':
        return Icons.assignment;
      default:
        return Icons.event;
    }
  }

  String _getDateRangeText() {
    if (_viewMode == 'day') {
      return '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
    } else if (_viewMode == 'week') {
      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1),
      );
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${startOfWeek.day}-${endOfWeek.day} ${_getMonthName(_selectedDate.month)}';
    } else {
      return '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      '월요일', '화요일', '수요일', '목요일',
      '금요일', '토요일', '일요일'
    ];
    return days[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 일정 추가'),
        content: const Text('일정 생성 폼이 여기에 표시됩니다'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add schedule logic
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDetailsDialog(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: schedule['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getScheduleIcon(schedule['type']),
                      color: schedule['color'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF395886),
                          ),
                        ),
                        Text(
                          schedule['subject'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8AAEE0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8AAEE0)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.access_time, '시간', schedule['time']),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_today, '날짜', 
                '${schedule['date'].year}년 ${schedule['date'].month}월 ${schedule['date'].day}일'),
              if (schedule['description'] != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.description, '설명', schedule['description']),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteSchedule(schedule['id']);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editSchedule(schedule);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('수정'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF638ECB),
                      foregroundColor: Colors.white,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8AAEE0)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8AAEE0),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF395886),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editSchedule(Map<String, dynamic> schedule) {
    // 수정 로직을 여기에 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${schedule['title']}" 수정 기능 구현 예정')),
    );
  }

  void _deleteSchedule(String id) {
    setState(() {
      _schedules.removeWhere((s) => s['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정이 삭제되었습니다')),
    );
  }
}