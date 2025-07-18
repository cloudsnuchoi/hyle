import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';

class WeekView extends ConsumerWidget {
  final Function(StudyEvent)? onEventTap;
  
  const WeekView({super.key, this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    
    return SingleChildScrollView(
      child: SizedBox(
        height: 24 * 60.0, // 24시간 * 60픽셀
        child: Row(
          children: [
            // 시간 축
            _buildTimeAxis(),
            
            // 요일별 컬럼
            Expanded(
              child: Row(
                children: List.generate(7, (index) {
                  final day = weekStart.add(Duration(days: index));
                  return Expanded(
                    child: _DayColumn(date: day, onEventTap: onEventTap),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeAxis() {
    return Container(
      width: 60,
      child: Column(
        children: List.generate(24, (hour) {
          return Container(
            height: 60,
            alignment: Alignment.topCenter,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTypography.caption,
            ),
          );
        }),
      ),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  final DateTime date;
  final Function(StudyEvent)? onEventTap;
  
  const _DayColumn({required this.date, this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEvents = ref.watch(scheduleProvider);
    final events = ref.read(scheduleProvider.notifier).getEventsForDay(date);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: date.weekday == 7 ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // 날짜 헤더
          Container(
            height: 60,
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: isToday ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getWeekdayName(date.weekday),
                  style: AppTypography.caption.copyWith(
                    color: isToday ? Theme.of(context).primaryColor : null,
                  ),
                ),
                Text(
                  date.day.toString(),
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? Theme.of(context).primaryColor : null,
                  ),
                ),
              ],
            ),
          ),
          
          // 이벤트 영역
          Expanded(
            child: Stack(
              children: [
                // 시간 그리드
                ...List.generate(24, (hour) {
                  return Positioned(
                    top: hour * 60.0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                
                // 이벤트들
                ...events.map((event) {
                  final startHour = event.startTime.hour + event.startTime.minute / 60;
                  final duration = event.duration.inMinutes / 60;
                  
                  return Positioned(
                    top: startHour * 60,
                    left: 2,
                    right: 2,
                    height: duration * 60 - 4,
                    child: _EventCard(event: event, onTap: onEventTap),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getWeekdayName(int weekday) {
    const names = ['월', '화', '수', '목', '금', '토', '일'];
    return names[weekday - 1];
  }
}

class _EventCard extends ConsumerWidget {
  final StudyEvent event;
  final Function(StudyEvent)? onTap;
  
  const _EventCard({required this.event, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(event);
        } else {
          _showEventDetail(context, event, ref);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: event.color.withOpacity(event.isCompleted ? 0.5 : 0.9),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: event.color,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (event.duration.inMinutes > 30)
              Text(
                '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                style: AppTypography.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showEventDetail(BuildContext context, StudyEvent event, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.horizontalGapMD,
                Expanded(
                  child: Text(
                    event.title,
                    style: AppTypography.titleMedium,
                  ),
                ),
                if (event.isCompleted)
                  Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            AppSpacing.verticalGapMD,
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                AppSpacing.horizontalGapSM,
                Text(
                  '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                  style: AppTypography.body,
                ),
                AppSpacing.horizontalGapMD,
                Chip(
                  label: Text(event.subject),
                  backgroundColor: event.color.withOpacity(0.2),
                  labelStyle: TextStyle(color: event.color),
                ),
              ],
            ),
            if (event.description != null) ...[
              AppSpacing.verticalGapMD,
              Text(event.description!, style: AppTypography.body),
            ],
            AppSpacing.verticalGapLG,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(scheduleProvider.notifier).toggleComplete(event.id);
                      Navigator.pop(context);
                    },
                    icon: Icon(event.isCompleted ? Icons.undo : Icons.check),
                    label: Text(event.isCompleted ? '미완료로 변경' : '완료'),
                  ),
                ),
                AppSpacing.horizontalGapMD,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 타이머 연동
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('타이머가 시작되었습니다')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('학습 시작'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}