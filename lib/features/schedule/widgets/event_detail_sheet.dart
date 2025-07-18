import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';

class EventDetailSheet extends ConsumerStatefulWidget {
  final StudyEvent event;

  const EventDetailSheet({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends ConsumerState<EventDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Color _selectedColor;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _startDate = widget.event.startTime;
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.event.endTime);
    _selectedColor = widget.event.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }

    final updatedEvent = widget.event.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      ),
      endTime: DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _endTime.hour,
        _endTime.minute,
      ),
      color: _selectedColor,
    );

    ref.read(scheduleProvider.notifier).updateEvent(widget.event.id, updatedEvent);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정이 수정되었습니다')),
    );
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ref.read(scheduleProvider.notifier).deleteEvent(widget.event.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('일정이 삭제되었습니다')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy년 M월 d일');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? '일정 수정' : '일정 상세',
                        style: AppTypography.titleLarge,
                      ),
                    ),
                    if (!_isEditing) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _toggleEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _deleteEvent,
                        color: theme.colorScheme.error,
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 색상 표시/선택
                if (_isEditing) ...[
                  Text('색상', style: AppTypography.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Colors.blue,
                      Colors.red,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.pink,
                    ].map((color) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ] else
                  Container(
                    width: double.infinity,
                    height: 4,
                    color: widget.event.color,
                    margin: const EdgeInsets.only(bottom: 20),
                  ),

                // 제목
                if (_isEditing)
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
                    ),
                  )
                else
                  Text(
                    widget.event.title,
                    style: AppTypography.titleLarge,
                  ),
                const SizedBox(height: 16),

                // 시간 정보
                Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    if (_isEditing) ...[
                      Expanded(
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _startTime,
                                );
                                if (time != null) {
                                  setState(() {
                                    _startTime = time;
                                  });
                                }
                              },
                              child: Text(
                                _startTime.format(context),
                                style: AppTypography.body,
                              ),
                            ),
                            const Text(' ~ '),
                            TextButton(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _endTime,
                                );
                                if (time != null) {
                                  setState(() {
                                    _endTime = time;
                                  });
                                }
                              },
                              child: Text(
                                _endTime.format(context),
                                style: AppTypography.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      Text(
                        '${timeFormat.format(widget.event.startTime)} - ${timeFormat.format(widget.event.endTime)}',
                        style: AppTypography.body,
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // 날짜 정보
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    if (_isEditing)
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                        child: Text(
                          dateFormat.format(_startDate),
                          style: AppTypography.body,
                        ),
                      )
                    else
                      Text(
                        dateFormat.format(widget.event.startTime),
                        style: AppTypography.body,
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // 설명
                if (_isEditing) ...[
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ] else if (widget.event.description != null &&
                    widget.event.description!.isNotEmpty) ...[
                  Text('설명', style: AppTypography.labelLarge),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description!,
                    style: AppTypography.body,
                  ),
                ],

                const SizedBox(height: 24),

                // 버튼
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              // 원래 값으로 복원
                              _titleController.text = widget.event.title;
                              _descriptionController.text = widget.event.description ?? '';
                              _startDate = widget.event.startTime;
                              _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
                              _endTime = TimeOfDay.fromDateTime(widget.event.endTime);
                              _selectedColor = widget.event.color;
                            });
                          },
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveEvent,
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}