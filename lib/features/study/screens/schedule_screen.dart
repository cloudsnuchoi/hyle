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
  String _viewMode = 'week'; // week, month, day
  
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': '1',
      'title': 'Mathematics Study',
      'subject': 'Mathematics',
      'time': '09:00 - 10:30',
      'color': const Color(0xFF8AAEE0),
      'date': DateTime.now(),
      'type': 'study',
    },
    {
      'id': '2',
      'title': 'Physics Quiz',
      'subject': 'Science',
      'time': '14:00 - 15:00',
      'color': const Color(0xFF638ECB),
      'date': DateTime.now(),
      'type': 'quiz',
    },
    {
      'id': '3',
      'title': 'English Essay',
      'subject': 'Literature',
      'time': '16:00 - 17:30',
      'color': const Color(0xFF395886),
      'date': DateTime.now(),
      'type': 'assignment',
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
                  _buildCalendarView(),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(0, _slideIn.value),
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: _buildScheduleList(),
                      ),
                    ),
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
              'Study Schedule',
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
            _buildCalendarHeader(),
            const SizedBox(height: 16),
            if (_viewMode == 'week') _buildWeekView(),
            if (_viewMode == 'month') _buildMonthView(),
            if (_viewMode == 'day') _buildDayView(),
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
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _isSameDay(date, _selectedDate);
        final hasSchedule = _schedules.any((s) => _isSameDay(s['date'], date));

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF638ECB)
                  : isToday
                      ? const Color(0xFF8AAEE0).withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  weekDays[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF8AAEE0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF395886),
                  ),
                ),
                if (hasSchedule) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF638ECB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthView() {
    // Simplified month view
    return const Center(
      child: Text(
        'Month view calendar',
        style: TextStyle(color: Color(0xFF8AAEE0)),
      ),
    );
  }

  Widget _buildDayView() {
    return Column(
      children: [
        Text(
          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
          style: const TextStyle(
            fontSize: 20,
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
              'No schedules for this day',
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
          onTap: () {},
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
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
        title: const Text('Add New Schedule'),
        content: const Text('Schedule creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add schedule logic
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}