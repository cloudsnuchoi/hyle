import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';

class DayView extends ConsumerWidget {
  final Function(StudyEvent)? onEventTap;
  
  const DayView({super.key, this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allEvents = ref.watch(scheduleProvider);
    final events = ref.read(scheduleProvider.notifier).getEventsForDay(selectedDate);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                AppSpacing.horizontalGapMD,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy년 M월 d일').format(selectedDate),
                      style: AppTypography.titleMedium,
                    ),
                    Text(
                      DateFormat('EEEE', 'ko').format(selectedDate),
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          AppSpacing.verticalGapLG,
          
          // 시간대별 일정
          if (events.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  AppSpacing.verticalGapMD,
                  Text(
                    '오늘은 일정이 없습니다',
                    style: AppTypography.body.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ...events.map((event) => _buildEventCard(context, ref, event, onEventTap)),
        ],
      ),
    );
  }
  
  Widget _buildEventCard(BuildContext context, WidgetRef ref, StudyEvent event, Function(StudyEvent)? onEventTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onEventTap?.call(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: event.color,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // 시간
              Container(
                width: 80,
                child: Column(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(event.startTime),
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      '-',
                      style: AppTypography.caption,
                    ),
                    Text(
                      DateFormat('HH:mm').format(event.endTime),
                      style: AppTypography.titleSmall,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.horizontalGapMD,
              
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: AppTypography.titleMedium,
                          ),
                        ),
                        if (event.isCompleted)
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    AppSpacing.verticalGapSM,
                    Row(
                      children: [
                        Chip(
                          label: Text(event.subject),
                          backgroundColor: event.color.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: event.color,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        AppSpacing.horizontalGapSM,
                        Text(
                          '${event.duration.inMinutes}분',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    if (event.description != null) ...[
                      AppSpacing.verticalGapSM,
                      Text(
                        event.description!,
                        style: AppTypography.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // 액션 버튼
              IconButton(
                icon: Icon(
                  event.isCompleted ? Icons.undo : Icons.play_arrow,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (event.isCompleted) {
                    ref.read(scheduleProvider.notifier).toggleComplete(event.id);
                  } else {
                    // 타이머 시작
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('타이머가 시작되었습니다')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}