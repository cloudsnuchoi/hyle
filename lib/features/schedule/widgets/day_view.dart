import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';
import '../widgets/event_detail_sheet.dart';

class DayView extends ConsumerWidget {
  final Function(StudyEvent)? onEventTap;
  
  const DayView({super.key, this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allEvents = ref.watch(scheduleProvider);
    final events = ref.read(scheduleProvider.notifier).getEventsForDay(selectedDate);
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    
    return SingleChildScrollView(
      child: SizedBox(
        height: 24 * 60.0 + 80, // 24시간 * 60픽셀 + 헤더
        child: Row(
          children: [
            // 시간 축
            _buildTimeAxis(),
            
            // 일정 컬럼
            Expanded(
              child: Column(
                children: [
                  // 날짜 헤더
                  Container(
                    height: 80,
                    padding: AppSpacing.paddingMD,
                    decoration: BoxDecoration(
                      color: isToday ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: isToday ? Theme.of(context).primaryColor : null,
                        ),
                        AppSpacing.horizontalGapMD,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('yyyy년 M월 d일').format(selectedDate),
                              style: AppTypography.titleMedium.copyWith(
                                color: isToday ? Theme.of(context).primaryColor : null,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE', 'ko').format(selectedDate),
                              style: AppTypography.caption.copyWith(
                                color: isToday ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 타임테이블 영역
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
                        
                        // 현재 시간 표시 (오늘인 경우)
                        if (isToday)
                          Positioned(
                            top: (DateTime.now().hour + DateTime.now().minute / 60) * 60,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        
                        // 이벤트들
                        ...events.map((event) {
                          final startHour = event.startTime.hour + event.startTime.minute / 60;
                          final duration = event.duration.inMinutes / 60;
                          
                          return Positioned(
                            top: startHour * 60,
                            left: 8,
                            right: 8,
                            height: duration * 60 - 4,
                            child: _buildTimeTableEvent(context, ref, event, onEventTap),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
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
          Container(height: 80), // 헤더 공간
          ...List.generate(24, (hour) {
            return Container(
              height: 60,
              alignment: Alignment.topCenter,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: AppTypography.caption,
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildTimeTableEvent(BuildContext context, WidgetRef ref, StudyEvent event, Function(StudyEvent)? onEventTap) {
    return GestureDetector(
      onTap: () {
        if (onEventTap != null) {
          onEventTap(event);
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => EventDetailSheet(event: event),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: event.color.withOpacity(event.isCompleted ? 0.5 : 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: event.color,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (event.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.white, size: 14),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            if (event.duration.inMinutes >= 60) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  event.subject,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}