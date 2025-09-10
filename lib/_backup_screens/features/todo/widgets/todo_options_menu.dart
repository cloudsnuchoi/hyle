import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/todo_item.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../timer/screens/timer_screen_enhanced.dart';
import '../../notes/screens/notes_screen_enhanced.dart';
import 'todo_item_dialog.dart';

class TodoOptionsMenu extends ConsumerWidget {
  final TodoItem todo;

  const TodoOptionsMenu({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(todoCategoryProvider.notifier).getCategoryById(todo.categoryId);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (category != null) ...[
                  Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (todo.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description!,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 옵션 목록
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('이름 수정'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => TodoItemDialog(
                  categoryId: todo.categoryId,
                  todoToEdit: todo,
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.note_add_outlined),
            title: const Text('노트 작성'),
            subtitle: todo.noteId != null 
                ? const Text('연결된 노트 있음')
                : null,
            onTap: () {
              Navigator.pop(context);
              // 노트 화면으로 이동하면서 todo 전달
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesScreenEnhanced(linkedTodo: todo),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('타이머 시작'),
            subtitle: Text('예상 ${todo.estimatedMinutes}분'),
            onTap: () {
              Navigator.pop(context);
              // Timer 화면으로 이동하면서 todo 전달
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimerScreenEnhanced(initialTodo: todo),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('세션 설정'),
            subtitle: todo.sessionSettings != null
                ? const Text('커스텀 설정 있음')
                : const Text('기본 설정 사용'),
            onTap: () {
              Navigator.pop(context);
              _showSessionSettingsDialog(context, ref);
            },
          ),
          
          const Divider(height: 1),
          
          // 위험 액션
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            title: Text(
              '삭제',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, ref);
            },
          ),
          
          // 닫기 버튼
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  void _showSessionSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _SessionSettingsDialog(todo: todo),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: Text('\'${todo.title}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(todoItemsProvider.notifier).deleteTodo(todo.id);
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
}

// 세션 설정 다이얼로그
class _SessionSettingsDialog extends ConsumerStatefulWidget {
  final TodoItem todo;

  const _SessionSettingsDialog({required this.todo});

  @override
  ConsumerState<_SessionSettingsDialog> createState() => _SessionSettingsDialogState();
}

class _SessionSettingsDialogState extends ConsumerState<_SessionSettingsDialog> {
  late int _focusMinutes;
  late int _breakMinutes;
  late int _sessions;
  late bool _autoStartBreak;
  late bool _autoStartFocus;

  @override
  void initState() {
    super.initState();
    final settings = widget.todo.sessionSettings ?? {};
    _focusMinutes = settings['focusMinutes'] ?? 25;
    _breakMinutes = settings['breakMinutes'] ?? 5;
    _sessions = settings['sessions'] ?? 4;
    _autoStartBreak = settings['autoStartBreak'] ?? true;
    _autoStartFocus = settings['autoStartFocus'] ?? false;
  }

  void _saveSettings() {
    final settings = {
      'focusMinutes': _focusMinutes,
      'breakMinutes': _breakMinutes,
      'sessions': _sessions,
      'autoStartBreak': _autoStartBreak,
      'autoStartFocus': _autoStartFocus,
    };

    ref.read(todoItemsProvider.notifier).updateSessionSettings(
      widget.todo.id,
      settings,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('타이머 세션 설정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 집중 시간
            ListTile(
              title: const Text('집중 시간'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _focusMinutes > 5
                        ? () => setState(() => _focusMinutes -= 5)
                        : null,
                  ),
                  Text('$_focusMinutes분'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _focusMinutes < 60
                        ? () => setState(() => _focusMinutes += 5)
                        : null,
                  ),
                ],
              ),
            ),
            
            // 휴식 시간
            ListTile(
              title: const Text('휴식 시간'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _breakMinutes > 1
                        ? () => setState(() => _breakMinutes -= 1)
                        : null,
                  ),
                  Text('$_breakMinutes분'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _breakMinutes < 30
                        ? () => setState(() => _breakMinutes += 1)
                        : null,
                  ),
                ],
              ),
            ),
            
            // 세션 수
            ListTile(
              title: const Text('세션 수'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _sessions > 1
                        ? () => setState(() => _sessions -= 1)
                        : null,
                  ),
                  Text('$_sessions'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _sessions < 10
                        ? () => setState(() => _sessions += 1)
                        : null,
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // 자동 시작 옵션
            SwitchListTile(
              title: const Text('휴식 자동 시작'),
              value: _autoStartBreak,
              onChanged: (value) => setState(() => _autoStartBreak = value),
            ),
            
            SwitchListTile(
              title: const Text('다음 세션 자동 시작'),
              value: _autoStartFocus,
              onChanged: (value) => setState(() => _autoStartFocus = value),
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
          onPressed: _saveSettings,
          child: const Text('저장'),
        ),
      ],
    );
  }
}