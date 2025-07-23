import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';

class ThreeDayView extends ConsumerWidget {
  final Function(StudyEvent)? onEventTap;
  
  const ThreeDayView({super.key, this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    
    return SingleChildScrollView(
      child: SizedBox(
        height: 24 * 60.0 + 60, // 24시간 * 60픽셀 + 헤더
        child: Row(
          children: [
            // 시간 축
            _buildTimeAxis(),
            
            // 3일 컬럼
            Expanded(
              child: Row(
                children: List.generate(3, (index) {
                  final day = selectedDate.add(Duration(days: index));
                  return Expanded(
                    child: _buildDayColumn(context, ref, day, onEventTap),
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
        children: [
          Container(height: 60), // 헤더 공간
          ...List.generate(24, (hour) {
            return Container(
              height: 60,
              alignment: Alignment.topCenter,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildDayColumn(BuildContext context, WidgetRef ref, DateTime date, Function(StudyEvent)? onEventTap) {
    final allEvents = ref.watch(scheduleProvider);
    final events = ref.read(scheduleProvider.notifier).getEventsForDay(date);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
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
                  DateFormat('E', 'ko').format(date),
                  style: AppTypography.caption.copyWith(
                    color: isToday ? Theme.of(context).primaryColor : null,
                  ),
                ),
                Text(
                  '${date.month}/${date.day}',
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
                    left: 4,
                    right: 4,
                    height: duration * 60 - 8,
                    child: GestureDetector(
                      onTap: () => onEventTap?.call(event),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            if (duration >= 1) // 1시간 이상인 경우 시간 표시
                              Text(
                                '${DateFormat('HH:mm').format(event.startTime)}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}