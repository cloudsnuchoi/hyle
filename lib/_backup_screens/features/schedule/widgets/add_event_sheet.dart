import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/schedule_models.dart';
import '../providers/schedule_provider.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  const AddEventSheet({super.key});

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedSubject = 'Math';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  Color _selectedColor = Colors.blue;
  
  final List<String> _subjects = ['Math', 'English', 'Science', 'History', 'Computer', 'Other'];
  final List<Color> _colors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.indigo,
    Colors.teal,
    Colors.pink,
  ];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들바
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.verticalGapLG,
            
            Text('새 학습 일정', style: AppTypography.titleLarge),
            AppSpacing.verticalGapLG,
            
            // 제목
            CustomTextField(
              controller: _titleController,
              label: '제목',
              hint: '예: 미적분학 복습',
            ),
            
            AppSpacing.verticalGapMD,
            
            // 과목 선택
            Text('과목', style: AppTypography.titleSmall),
            AppSpacing.verticalGapSM,
            Wrap(
              spacing: 8,
              children: _subjects.map((subject) {
                return ChoiceChip(
                  label: Text(subject),
                  selected: _selectedSubject == subject,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSubject = subject;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            AppSpacing.verticalGapMD,
            
            // 날짜 선택
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('날짜: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            
            // 시간 선택
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text('시작: ${_startTime.format(context)}'),
                    onTap: () async {
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
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text('종료: ${_endTime.format(context)}'),
                    onTap: () async {
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
                  ),
                ),
              ],
            ),
            
            AppSpacing.verticalGapMD,
            
            // 색상 선택
            Text('색상', style: AppTypography.titleSmall),
            AppSpacing.verticalGapSM,
            Wrap(
              spacing: 8,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            AppSpacing.verticalGapMD,
            
            // 설명
            CustomTextField(
              controller: _descriptionController,
              label: '설명 (선택)',
              hint: '학습 내용이나 목표를 입력하세요',
              maxLines: 3,
            ),
            
            AppSpacing.verticalGapXL,
            
            // 버튼
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: '취소',
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                  ),
                ),
                AppSpacing.horizontalGapMD,
                Expanded(
                  child: CustomButton(
                    text: '추가',
                    onPressed: _addEvent,
                  ),
                ),
              ],
            ),
            
            AppSpacing.verticalGapLG,
          ],
        ),
      ),
    );
  }
  
  void _addEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }
    
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    
    final event = StudyEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      subject: _selectedSubject,
      startTime: startDateTime,
      endTime: endDateTime,
      color: _selectedColor,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );
    
    ref.read(scheduleProvider.notifier).addEvent(event);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정이 추가되었습니다')),
    );
  }
}