import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/todo_category.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class CategoryEditDialog extends ConsumerStatefulWidget {
  final TodoCategory category;
  
  const CategoryEditDialog({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends ConsumerState<CategoryEditDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.brown,
  ];

  final List<IconData> _availableIcons = [
    Icons.folder,
    Icons.school,
    Icons.work,
    Icons.home,
    Icons.star,
    Icons.favorite,
    Icons.sports_esports,
    Icons.music_note,
    Icons.book,
    Icons.code,
    Icons.brush,
    Icons.science,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.shopping_bag,
    Icons.language,
    Icons.calculate,
    Icons.history_edu,
    Icons.psychology,
    Icons.engineering,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColor = widget.category.color;
    _selectedIcon = widget.category.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateCategory() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리 이름을 입력해주세요')),
      );
      return;
    }

    ref.read(todoCategoryProvider.notifier).updateCategory(
      widget.category.copyWith(
        name: _nameController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
              '카테고리 수정',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 24),

            // 카테고리 이름
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '카테고리 이름',
                hintText: '예: 수학, 영어, 프로젝트',
              ),
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _updateCategory(),
            ),
            const SizedBox(height: 24),

            // 색상 선택
            Text(
              '색상',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 아이콘 선택
            Text(
              '아이콘',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 미리보기
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedIcon,
                    color: _selectedColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _nameController.text.isEmpty
                        ? '카테고리 이름'
                        : _nameController.text,
                    style: AppTypography.titleMedium.copyWith(
                      color: _selectedColor,
                    ),
                  ),
                ],
              ),
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
                  onPressed: _updateCategory,
                  child: const Text('수정'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}