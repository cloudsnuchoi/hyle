import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';
import '../widgets/week_view.dart';
import '../widgets/three_day_view.dart';
import '../widgets/day_view.dart';
import '../widgets/add_event_sheet.dart';
import '../widgets/event_detail_sheet.dart';

class ScheduleScreenImproved extends ConsumerWidget {
  const ScheduleScreenImproved({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarView = ref.watch(calendarViewProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 일정'),
        centerTitle: false,
        actions: [
          // 뷰 선택
          PopupMenuButton<CalendarView>(
            icon: const Icon(Icons.view_module),
            initialValue: calendarView,
            onSelected: (view) {
              ref.read(calendarViewProvider.notifier).state = view;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.day,
                child: Text('일간'),
              ),
              const PopupMenuItem(
                value: CalendarView.threeDay,
                child: Text('3일'),
              ),
              const PopupMenuItem(
                value: CalendarView.week,
                child: Text('주간'),
              ),
              const PopupMenuItem(
                value: CalendarView.month,
                child: Text('월간'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
            tooltip: '오늘',
          ),
        ],
      ),
      body: Column(
        children: [
          // 날짜 네비게이션
          _buildDateNavigation(context, ref),
          
          // 캘린더 뷰
          Expanded(
            child: _buildCalendarView(calendarView, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddEventSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDateNavigation(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final calendarView = ref.watch(calendarViewProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = _getPreviousDate(selectedDate, calendarView);
              ref.read(selectedDateProvider.notifier).state = newDate;
            },
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getDateRangeText(selectedDate, calendarView),
                style: AppTypography.titleMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = _getNextDate(selectedDate, calendarView);
              ref.read(selectedDateProvider.notifier).state = newDate;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendarView(CalendarView view, WidgetRef ref) {
    switch (view) {
      case CalendarView.week:
        return WeekViewImproved(
          onEventTap: (event) => _showEventDetail(ref.context, event),
        );
      case CalendarView.threeDay:
        return ThreeDayViewImproved(
          onEventTap: (event) => _showEventDetail(ref.context, event),
        );
      case CalendarView.day:
        return DayViewImproved(
          onEventTap: (event) => _showEventDetail(ref.context, event),
        );
      case CalendarView.month:
        return _buildMonthView(ref);
    }
  }
  
  void _showEventDetail(BuildContext context, StudyEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventDetailSheet(event: event),
    );
  }
  
  Widget _buildMonthView(WidgetRef ref) {
    final events = ref.watch(scheduleProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '월간 뷰는 준비중입니다',
            style: AppTypography.titleMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '주간, 3일, 일간 뷰를 사용해주세요',
            style: AppTypography.body.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  DateTime _getPreviousDate(DateTime current, CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return current.subtract(const Duration(days: 1));
      case CalendarView.threeDay:
        return current.subtract(const Duration(days: 3));
      case CalendarView.week:
        return current.subtract(const Duration(days: 7));
      case CalendarView.month:
        return DateTime(current.year, current.month - 1);
    }
  }
  
  DateTime _getNextDate(DateTime current, CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return current.add(const Duration(days: 1));
      case CalendarView.threeDay:
        return current.add(const Duration(days: 3));
      case CalendarView.week:
        return current.add(const Duration(days: 7));
      case CalendarView.month:
        return DateTime(current.year, current.month + 1);
    }
  }
  
  String _getDateRangeText(DateTime date, CalendarView view) {
    final format = DateFormat('M월 d일');
    
    switch (view) {
      case CalendarView.day:
        return format.format(date);
      case CalendarView.threeDay:
        final endDate = date.add(const Duration(days: 2));
        return '${format.format(date)} - ${format.format(endDate)}';
      case CalendarView.week:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${format.format(weekStart)} - ${format.format(weekEnd)}';
      case CalendarView.month:
        return DateFormat('yyyy년 M월').format(date);
    }
  }
}

// 개선된 주간 뷰
class WeekViewImproved extends ConsumerWidget {
  final Function(StudyEvent) onEventTap;
  
  const WeekViewImproved({
    super.key,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WeekView(onEventTap: onEventTap);
  }
}

// 개선된 3일 뷰
class ThreeDayViewImproved extends ConsumerWidget {
  final Function(StudyEvent) onEventTap;
  
  const ThreeDayViewImproved({
    super.key,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThreeDayView(onEventTap: onEventTap);
  }
}

// 개선된 일간 뷰
class DayViewImproved extends ConsumerWidget {
  final Function(StudyEvent) onEventTap;
  
  const DayViewImproved({
    super.key,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DayView(onEventTap: onEventTap);
  }
}