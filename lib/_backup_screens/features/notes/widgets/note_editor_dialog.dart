import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class NoteEditorDialog extends ConsumerStatefulWidget {
  final Note? note;
  final String? categoryId;
  final bool isNewFromTodo;

  const NoteEditorDialog({
    super.key,
    this.note,
    this.categoryId,
    this.isNewFromTodo = false,
  });

  @override
  ConsumerState<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends ConsumerState<NoteEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  late List<String> _tags;
  Color? _selectedColor;
  String? _selectedCategoryId;
  bool _hasChanges = false;

  final List<Color?> _availableColors = [
    null, // 기본
    Colors.red[100]!,
    Colors.orange[100]!,
    Colors.yellow[100]!,
    Colors.green[100]!,
    Colors.blue[100]!,
    Colors.purple[100]!,
    Colors.pink[100]!,
    Colors.grey[100]!,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _tagController = TextEditingController();
    _tags = List.from(widget.note?.tags ?? []);
    _selectedColor = widget.note?.color;
    _selectedCategoryId = widget.note?.categoryId ?? widget.categoryId;

    // 변경 감지
    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
    
    // Todo에서 생성된 경우 제목 자동 설정
    if (widget.isNewFromTodo && widget.note?.todoId != null) {
      final todo = ref.read(todoItemsProvider).firstWhere(
        (t) => t.id == widget.note!.todoId,
      );
      _titleController.text = '${todo.title} - 노트';
    }
  }

  void _onChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }

    if (widget.note != null) {
      // 수정
      ref.read(notesProvider.notifier).updateNote(
        widget.note!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          categoryId: _selectedCategoryId,
          tags: _tags,
          color: _selectedColor,
        ),
      );
    } else {
      // 생성
      ref.read(notesProvider.notifier).addNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        categoryId: _selectedCategoryId,
        tags: _tags,
        color: _selectedColor,
      );
    }

    Navigator.pop(context);
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
        _hasChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경사항이 있습니다'),
        content: const Text('저장하지 않고 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(todoCategoryProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: size.width * 0.8,
          height: size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 헤더
              Row(
                children: [
                  Text(
                    widget.note != null ? '노트 수정' : '새 노트',
                    style: AppTypography.titleLarge,
                  ),
                  const Spacer(),
                  // 색상 선택
                  PopupMenuButton<Color?>(
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _selectedColor ?? Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor != null
                              ? _selectedColor!
                              : theme.dividerColor,
                        ),
                      ),
                      child: Icon(
                        Icons.palette,
                        size: 18,
                        color: _selectedColor != null
                            ? Colors.white
                            : theme.iconTheme.color,
                      ),
                    ),
                    onSelected: (color) {
                      setState(() {
                        _selectedColor = color;
                        _hasChanges = true;
                      });
                    },
                    itemBuilder: (context) => _availableColors.map((color) {
                      return PopupMenuItem(
                        value: color,
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color ?? Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: color != null
                                  ? color
                                  : theme.dividerColor,
                            ),
                          ),
                          child: color == null
                              ? const Center(
                                  child: Text('기본'),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      if (await _onWillPop()) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 카테고리 선택
              if (categories.isNotEmpty)
                DropdownButtonFormField<String?>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('없음'),
                    ),
                    ...categories.map((category) {
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
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      _hasChanges = true;
                    });
                  },
                ),
              const SizedBox(height: 16),

              // 제목
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '노트 제목을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // 내용
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    hintText: '노트 내용을 입력하세요',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 16),

              // 태그
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: '태그',
                        hintText: '태그를 입력하고 Enter',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      onDeleted: () {
                        setState(() {
                          _tags.remove(tag);
                          _hasChanges = true;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (await _onWillPop()) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveNote,
                    child: Text(widget.note != null ? '수정' : '저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}