import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../models/todo_category.dart';
import '../../../models/todo_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/todo_category_dialog.dart';
import '../widgets/todo_item_dialog.dart';
import '../widgets/todo_options_menu.dart';

class TodoScreenEnhanced extends ConsumerStatefulWidget {
  const TodoScreenEnhanced({super.key});

  @override
  ConsumerState<TodoScreenEnhanced> createState() => _TodoScreenEnhancedState();
}

class _TodoScreenEnhancedState extends ConsumerState<TodoScreenEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final categories = ref.read(todoCategoryProvider);
    _tabController = TabController(
      length: categories.length,
      vsync: this,
    );
    _selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const TodoCategoryDialog(),
    );
  }

  void _showAddTodoDialog() {
    if (_selectedCategoryId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => TodoItemDialog(
        categoryId: _selectedCategoryId!,
      ),
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

    // TabController 업데이트
    if (_tabController.length != categories.length) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: categories.length,
        vsync: this,
        initialIndex: oldIndex < categories.length ? oldIndex : 0,
      );
      if (categories.isNotEmpty) {
        _selectedCategoryId = categories[
          oldIndex < categories.length ? oldIndex : 0
        ].id;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _showAddCategoryDialog,
            tooltip: '카테고리 추가',
          ),
        ],
        bottom: categories.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                onTap: (index) {
                  setState(() {
                    _selectedCategoryId = categories[index].id;
                  });
                },
                tabs: categories.map((category) {
                  final todoCount = ref.watch(
                    todosCountByCategoryProvider(category.id),
                  );
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(category.name),
                        if (todoCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$todoCount',
                              style: TextStyle(
                                fontSize: 12,
                                color: category.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
      body: categories.isEmpty
          ? _buildEmptyState()
          : TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final categoryTodos = todos
                    .where((todo) => todo.categoryId == category.id)
                    .toList()
                  ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
                
                return _buildCategoryView(category, categoryTodos);
              }).toList(),
            ),
      floatingActionButton: categories.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _showAddTodoDialog,
              child: const Icon(Icons.add),
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

  Widget _buildCategoryView(TodoCategory category, List<TodoItem> todos) {
    if (todos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 64,
                color: category.color.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                '${category.name} 카테고리가 비어있습니다',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+ 버튼을 눌러 할 일을 추가해보세요',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 완료되지 않은 항목과 완료된 항목 분리
    final incompleteTodos = todos.where((t) => !t.isCompleted).toList();
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        // 진행 중인 할 일
        if (incompleteTodos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '진행 중 (${incompleteTodos.length})',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: incompleteTodos.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(todoItemsProvider.notifier).reorderTodosInCategory(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '완료됨 (${completedTodos.length})',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // 완료된 항목 모두 삭제
                    for (final todo in completedTodos) {
                      ref.read(todoItemsProvider.notifier).deleteTodo(todo.id);
                    }
                  },
                  child: const Text('모두 삭제'),
                ),
              ],
            ),
          ),
          ...completedTodos.map((todo) => _buildTodoItem(
            key: ValueKey(todo.id),
            todo: todo,
            category: category,
          )),
        ],
      ],
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
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _showTodoOptions(todo),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: '편집',
            ),
            SlidableAction(
              onPressed: (_) {
                ref.read(todoItemsProvider.notifier).deleteTodo(todo.id);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '삭제',
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showTodoOptions(todo),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: todo.isCompleted
                    ? Colors.grey[300]!
                    : category.color.withOpacity(0.3),
              ),
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
                        style: AppTypography.titleMedium.copyWith(
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
                        const SizedBox(height: 4),
                        Text(
                          todo.description!,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey[600],
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // 예상 시간
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
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
                            const SizedBox(width: 16),
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
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
                            const SizedBox(width: 16),
                            Icon(
                              Icons.note_outlined,
                              size: 16,
                              color: Colors.orange[600],
                            ),
                          ],
                          
                          // 타이머 설정 (있는 경우)
                          if (todo.sessionSettings != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.play_circle_outline,
                              size: 16,
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
      ),
    );
  }
}