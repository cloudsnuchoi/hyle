import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dday_provider.dart';
import '../../../models/dday.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class DDayWidget extends ConsumerWidget {
  const DDayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final importantDDays = ref.watch(importantDDaysProvider);
    
    if (importantDDays.isEmpty) {
      return Card(
        child: InkWell(
          onTap: () => _showDDayDialog(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: AppSpacing.paddingLG,
            child: Column(
              children: [
                Icon(
                  Icons.event_note,
                  size: 48,
                  color: Colors.grey[400],
                ),
                AppSpacing.verticalGapMD,
                Text(
                  'D-Day를 설정해보세요',
                  style: AppTypography.body.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                AppSpacing.verticalGapSM,
                TextButton.icon(
                  onPressed: () => _showDDayDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('D-Day 추가'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('D-Day', style: AppTypography.titleLarge),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showDDayDialog(context, ref),
            ),
          ],
        ),
        AppSpacing.verticalGapMD,
        ...importantDDays.map((dday) => _buildDDayCard(context, ref, dday)),
      ],
    );
  }
  
  Widget _buildDDayCard(BuildContext context, WidgetRef ref, DDay dday) {
    final theme = Theme.of(context);
    final daysLeft = dday.daysLeft;
    final isToday = daysLeft == 0;
    final isPast = daysLeft < 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isToday ? 4 : 1,
        child: InkWell(
          onTap: () => _showDDayDetailDialog(context, ref, dday),
          onLongPress: () => _showDDayOptions(context, ref, dday),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isToday ? LinearGradient(
                colors: [
                  dday.color.withOpacity(0.1),
                  dday.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
            ),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: dday.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dday.color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    dday.icon,
                    color: dday.color,
                    size: 28,
                  ),
                ),
                AppSpacing.horizontalGapLG,
                
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dday.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      AppSpacing.verticalGapSM,
                      Text(
                        '${dday.targetDate.year}년 ${dday.targetDate.month}월 ${dday.targetDate.day}일',
                        style: AppTypography.caption.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // D-Day 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isToday 
                        ? dday.color 
                        : isPast 
                            ? Colors.grey[400]
                            : dday.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: !isToday && !isPast ? Border.all(
                      color: dday.color.withOpacity(0.3),
                    ) : null,
                  ),
                  child: Text(
                    dday.daysLeftText,
                    style: AppTypography.titleMedium.copyWith(
                      color: isToday || isPast ? Colors.white : dday.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showDDayDialog(BuildContext context, WidgetRef ref, [DDay? dday]) {
    final titleController = TextEditingController(text: dday?.title);
    DateTime selectedDate = dday?.targetDate ?? DateTime.now().add(const Duration(days: 30));
    Color selectedColor = dday?.color ?? Colors.blue;
    IconData selectedIcon = dday?.icon ?? Icons.event;
    bool isImportant = dday?.isImportant ?? true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(dday == null ? 'D-Day 추가' : 'D-Day 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    hintText: '예: 수능, 생일, 시험',
                  ),
                ),
                AppSpacing.verticalGapLG,
                
                // 날짜 선택
                ListTile(
                  title: const Text('날짜'),
                  subtitle: Text(
                    '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                
                // 색상 선택
                AppSpacing.verticalGapMD,
                const Text('색상'),
                AppSpacing.verticalGapSM,
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.red,
                    Colors.pink,
                    Colors.purple,
                    Colors.deepPurple,
                    Colors.indigo,
                    Colors.blue,
                    Colors.teal,
                    Colors.green,
                    Colors.orange,
                    Colors.brown,
                  ].map((color) {
                    return InkWell(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color ? Border.all(
                            color: Colors.black,
                            width: 2,
                          ) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                // 아이콘 선택
                AppSpacing.verticalGapMD,
                const Text('아이콘'),
                AppSpacing.verticalGapSM,
                Wrap(
                  spacing: 8,
                  children: [
                    Icons.event,
                    Icons.school,
                    Icons.cake,
                    Icons.favorite,
                    Icons.star,
                    Icons.flight_takeoff,
                    Icons.sports_soccer,
                    Icons.work,
                    Icons.celebration,
                    Icons.emoji_events,
                  ].map((icon) {
                    return InkWell(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedIcon == icon 
                              ? selectedColor.withOpacity(0.2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: selectedIcon == icon ? Border.all(
                            color: selectedColor,
                          ) : null,
                        ),
                        child: Icon(icon, color: selectedColor),
                      ),
                    );
                  }).toList(),
                ),
                
                // 중요 표시
                AppSpacing.verticalGapMD,
                SwitchListTile(
                  title: const Text('중요한 D-Day'),
                  subtitle: const Text('홈 화면에 표시됩니다'),
                  value: isImportant,
                  onChanged: (value) => setState(() => isImportant = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  if (dday == null) {
                    ref.read(ddayProvider.notifier).addDDay(
                      title: titleController.text,
                      targetDate: selectedDate,
                      color: selectedColor,
                      icon: selectedIcon,
                      isImportant: isImportant,
                    );
                  } else {
                    ref.read(ddayProvider.notifier).updateDDay(
                      dday.copyWith(
                        title: titleController.text,
                        targetDate: selectedDate,
                        color: selectedColor,
                        icon: selectedIcon,
                        isImportant: isImportant,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(dday == null ? '추가' : '수정'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDDayDetailDialog(BuildContext context, WidgetRef ref, DDay dday) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(dday.icon, color: dday.color),
            const SizedBox(width: 8),
            Text(dday.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dday.daysLeftText,
              style: AppTypography.headlineMedium.copyWith(
                color: dday.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalGapMD,
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${dday.targetDate.year}년 ${dday.targetDate.month}월 ${dday.targetDate.day}일',
                  style: AppTypography.body,
                ),
              ],
            ),
            if (dday.daysLeft > 0) ...[
              AppSpacing.verticalGapSM,
              Text(
                '${dday.daysLeft}일 남았습니다',
                style: AppTypography.caption,
              ),
            ] else if (dday.daysLeft < 0) ...[
              AppSpacing.verticalGapSM,
              Text(
                '${dday.daysLeft.abs()}일 지났습니다',
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDDayDialog(context, ref, dday);
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }
  
  void _showDDayOptions(BuildContext context, WidgetRef ref, DDay dday) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.pop(context);
                _showDDayDialog(context, ref, dday);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(ddayProvider.notifier).deleteDDay(dday.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}