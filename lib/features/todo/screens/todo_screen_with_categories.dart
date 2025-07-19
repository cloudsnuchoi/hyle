import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../models/todo_category.dart';
import '../../../models/todo_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/todo_category_dialog.dart';
import '../widgets/todo_item_dialog.dart';
import '../widgets/todo_options_menu.dart';
import '../widgets/category_edit_dialog.dart';

class TodoScreenWithCategories extends ConsumerStatefulWidget {
  const TodoScreenWithCategories({super.key});

  @override
  ConsumerState<TodoScreenWithCategories> createState() => _TodoScreenWithCategoriesState();
}

class _TodoScreenWithCategoriesState extends ConsumerState<TodoScreenWithCategories> {
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    // 모든 카테고리를 기본적으로 펼침
    final categories = ref.read(todoCategoryProvider);
    for (final category in categories) {
      _expandedCategories[category.id] = true;
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const TodoCategoryDialog(),
    );
  }

  void _showEditCategoryDialog(TodoCategory category) {
    showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(category: category),
    );
  }

  void _showAddTodoDialog(String categoryId) {
    showDialog(
      context: context,
      builder: (context) => TodoItemDialog(categoryId: categoryId),
    );
  }

  void _showTodoOptions(TodoItem todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TodoOptionsMenu(todo: todo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(todoCategoryProvider);
    final todos = ref.watch(todoItemsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _showAddCategoryDialog,
            tooltip: '카테고리 추가',
          ),
        ],
      ),
      body: categories.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryTodos = todos
                    .where((todo) => todo.categoryId == category.id)
                    .toList()
                  ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
                
                final incompleteTodos = categoryTodos.where((t) => !t.isCompleted).toList();
                final completedTodos = categoryTodos.where((t) => t.isCompleted).toList();
                final isExpanded = _expandedCategories[category.id] ?? false;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // 카테고리 헤더
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedCategories[category.id] = !isExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                category.icon,
                                color: category.color,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: category.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (categoryTodos.isNotEmpty)
                                      Text(
                                        '${incompleteTodos.length}개 진행중, ${completedTodos.length}개 완료',
                                        style: AppTypography.caption,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onPressed: () => _showCategoryMenu(category),
                              ),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: category.color,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // 카테고리 내용
                      if (isExpanded) ...[
                        if (categoryTodos.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '할 일이 없습니다',
                                  style: AppTypography.body.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => _showAddTodoDialog(category.id),
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text('할 일 추가'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: category.color,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // 진행 중인 할 일
                          if (incompleteTodos.isNotEmpty) ...[
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: incompleteTodos.length,
                              onReorder: (oldIndex, newIndex) {
                                ref.read(todoItemsProvider.notifier)
                                    .reorderTodosInCategory(
                                  category.id,
                                  oldIndex,
                                  newIndex,
                                );
                              },
                              itemBuilder: (context, index) {
                                final todo = incompleteTodos[index];
                                return _buildTodoItem(
                                  key: ValueKey(todo.id),
                                  todo: todo,
                                  category: category,
                                );
                              },
                            ),
                          ],
                          
                          // 완료된 할 일
                          if (completedTodos.isNotEmpty) ...[
                            const Divider(),
                            ExpansionTile(
                              title: Text(
                                '완료됨 (${completedTodos.length})',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              children: completedTodos.map((todo) {
                                return _buildTodoItem(
                                  key: ValueKey(todo.id),
                                  todo: todo,
                                  category: category,
                                );
                              }).toList(),
                            ),
                          ],
                          
                          // 할 일 추가 버튼
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showAddTodoDialog(category.id),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('할 일 추가'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: category.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showCategoryMenu(TodoCategory category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('카테고리 수정'),
              onTap: () {
                Navigator.pop(context);
                _showEditCategoryDialog(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('카테고리 삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteCategory(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(TodoCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('\'${category.name}\' 카테고리를 삭제하시겠습니까?\n카테고리의 모든 할 일은 \'기타\'로 이동됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Todo들을 기타로 이동
              ref.read(todoItemsProvider.notifier).moveTodosToOtherCategory(category.id);
              // 카테고리 삭제
              ref.read(todoCategoryProvider.notifier).deleteCategory(category.id);
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '카테고리를 추가해주세요',
              style: AppTypography.titleLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '상단의 + 버튼을 눌러 첫 카테고리를 만들어보세요',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add),
              label: const Text('카테고리 추가'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoItem({
    required Key key,
    required TodoItem todo,
    required TodoCategory category,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () => _showTodoOptions(todo),
        borderRadius: BorderRadius.circular(8),
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: todo.isCompleted
                  ? Colors.grey[100]
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // 체크박스
                InkWell(
                  onTap: () {
                    ref.read(todoItemsProvider.notifier)
                        .toggleTodoComplete(todo.id);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: todo.isCompleted
                            ? Colors.grey[400]!
                            : category.color,
                        width: 2,
                      ),
                      color: todo.isCompleted ? category.color : null,
                    ),
                    child: todo.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: AppTypography.titleSmall.copyWith(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? Colors.grey[500]
                              : null,
                        ),
                      ),
                      if (todo.description != null &&
                          todo.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          todo.description!,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey[600],
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // 예상 시간
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${todo.estimatedMinutes}분',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                          
                          // 실제 시간 (있는 경우)
                          if (todo.actualMinutes > 0) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${todo.actualMinutes}분',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                          
                          // 연결된 노트 (있는 경우)
                          if (todo.noteId != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.note_outlined,
                              size: 14,
                              color: Colors.orange[600],
                            ),
                          ],
                          
                          // 타이머 설정 (있는 경우)
                          if (todo.sessionSettings != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.play_circle_outline,
                              size: 14,
                              color: Colors.purple[600],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 드래그 핸들
                if (!todo.isCompleted)
                  Icon(
                    Icons.drag_handle,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
    );
  }
}