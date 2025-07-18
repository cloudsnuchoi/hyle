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

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarView = ref.watch(calendarViewProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 일정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
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
      padding: AppSpacing.paddingMD,
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
          Text(
            _getDateRangeText(selectedDate, calendarView),
            style: AppTypography.titleMedium,
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
        return const WeekView();
      case CalendarView.threeDay:
        return const ThreeDayView();
      case CalendarView.day:
        return const DayView();
      case CalendarView.month:
        return _buildMonthView(ref);
    }
  }
  
  Widget _buildMonthView(WidgetRef ref) {
    // 간단한 월간 뷰 구현
    return Center(
      child: Text(
        '월간 뷰는 준비중입니다',
        style: AppTypography.body,
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
    final formatter = DateFormat('M월 d일');
    
    switch (view) {
      case CalendarView.day:
        return formatter.format(date);
      case CalendarView.threeDay:
        final endDate = date.add(const Duration(days: 2));
        return '${formatter.format(date)} - ${formatter.format(endDate)}';
      case CalendarView.week:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
      case CalendarView.month:
        return DateFormat('yyyy년 M월').format(date);
    }
  }
}