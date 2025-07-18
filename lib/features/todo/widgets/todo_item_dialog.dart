import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../models/todo_item.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class TodoItemDialog extends ConsumerStatefulWidget {
  final String categoryId;
  final TodoItem? todoToEdit;

  const TodoItemDialog({
    super.key,
    required this.categoryId,
    this.todoToEdit,
  });

  @override
  ConsumerState<TodoItemDialog> createState() => _TodoItemDialogState();
}

class _TodoItemDialogState extends ConsumerState<TodoItemDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedMinutesController;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.todoToEdit?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.todoToEdit?.description ?? '',
    );
    _estimatedMinutesController = TextEditingController(
      text: widget.todoToEdit?.estimatedMinutes.toString() ?? '30',
    );
    _selectedCategoryId = widget.todoToEdit?.categoryId ?? widget.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  void _saveTodo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('할 일 제목을 입력해주세요')),
      );
      return;
    }

    final estimatedMinutes = int.tryParse(_estimatedMinutesController.text) ?? 30;

    if (widget.todoToEdit != null) {
      // 수정
      ref.read(todoItemsProvider.notifier).updateTodo(
        widget.todoToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          estimatedMinutes: estimatedMinutes,
        ),
      );
    } else {
      // 추가
      ref.read(todoItemsProvider.notifier).addTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: _selectedCategoryId,
        estimatedMinutes: estimatedMinutes,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(todoCategoryProvider);
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.todoToEdit != null ? '할 일 수정' : '새 할 일',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 24),

            // 제목
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '할 일',
                hintText: '무엇을 해야 하나요?',
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 설명
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 (선택)',
                hintText: '자세한 내용을 입력하세요',
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 카테고리 선택
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: '카테고리',
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 20,
                        color: category.color,
                      ),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // 예상 시간
            TextField(
              controller: _estimatedMinutesController,
              decoration: const InputDecoration(
                labelText: '예상 시간 (분)',
                hintText: '30',
                suffixText: '분',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveTodo(),
            ),
            const SizedBox(height: 8),

            // 시간 프리셋
            Wrap(
              spacing: 8,
              children: [15, 30, 45, 60, 90, 120].map((minutes) {
                return ActionChip(
                  label: Text('${minutes}분'),
                  onPressed: () {
                    _estimatedMinutesController.text = minutes.toString();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveTodo,
                  child: Text(widget.todoToEdit != null ? '수정' : '추가'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}