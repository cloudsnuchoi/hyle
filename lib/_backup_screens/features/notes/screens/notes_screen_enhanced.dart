import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../models/todo_item.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/note_editor_dialog.dart';
import '../widgets/note_card.dart';

class NotesScreenEnhanced extends ConsumerStatefulWidget {
  final TodoItem? linkedTodo;
  
  const NotesScreenEnhanced({super.key, this.linkedTodo});

  @override
  ConsumerState<NotesScreenEnhanced> createState() => _NotesScreenEnhancedState();
}

class _NotesScreenEnhancedState extends ConsumerState<NotesScreenEnhanced> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 연결된 Todo가 있으면 해당 노트 생성/편집
    if (widget.linkedTodo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNoteForTodo(widget.linkedTodo!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNoteForTodo(TodoItem todo) async {
    final existingNote = ref.read(notesProvider.notifier).getNoteByTodoId(todo.id);
    
    if (existingNote != null) {
      // 기존 노트 편집
      _showNoteEditor(note: existingNote);
    } else {
      // 새 노트 생성
      final noteId = await ref.read(notesProvider.notifier).createNoteForTodo(
        todo.id,
        todo.categoryId,
      );
      
      // Todo에 노트 ID 연결
      ref.read(todoItemsProvider.notifier).linkNoteToTodo(todo.id, noteId);
      
      // 생성된 노트 편집
      final newNote = ref.read(notesProvider).firstWhere((n) => n.id == noteId);
      _showNoteEditor(note: newNote, isNewFromTodo: true);
    }
  }

  void _showNoteEditor({Note? note, bool isNewFromTodo = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoteEditorDialog(
        note: note,
        categoryId: _selectedCategoryId,
        isNewFromTodo: isNewFromTodo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final categories = ref.watch(todoCategoryProvider);
    final theme = Theme.of(context);

    // 필터링
    List<Note> filteredNotes = notes;
    
    // 카테고리 필터
    if (_selectedCategoryId != null) {
      filteredNotes = filteredNotes
          .where((note) => note.categoryId == _selectedCategoryId)
          .toList();
    }
    
    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      filteredNotes = ref.read(notesProvider.notifier).searchNotes(_searchQuery);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('노트'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '노트 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          // 사이드바 - 카테고리
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
            ),
            child: Column(
              children: [
                // 전체 노트
                ListTile(
                  leading: const Icon(Icons.notes),
                  title: const Text('전체 노트'),
                  selected: _selectedCategoryId == null,
                  selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                  trailing: Text(
                    '${notes.length}',
                    style: AppTypography.caption,
                  ),
                ),
                
                const Divider(height: 1),
                
                // 카테고리별 노트
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final noteCount = ref.watch(
                        notesCountByCategoryProvider(category.id),
                      );
                      
                      return ListTile(
                        leading: Icon(
                          category.icon,
                          color: category.color,
                          size: 20,
                        ),
                        title: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        selectedTileColor: category.color.withOpacity(0.1),
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        },
                        trailing: noteCount > 0
                            ? Text(
                                '$noteCount',
                                style: AppTypography.caption,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                
                // 태그
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('태그'),
                  onTap: () {
                    // TODO: 태그 관리 화면
                  },
                ),
              ],
            ),
          ),
          
          // 메인 컨텐츠 - 노트 목록
          Expanded(
            child: filteredNotes.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => _showNoteEditor(note: note),
                        onDelete: () => _confirmDelete(note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? '검색 결과가 없습니다'
                : '노트가 없습니다',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? '다른 검색어를 시도해보세요'
                : '+ 버튼을 눌러 첫 노트를 작성해보세요',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('노트 삭제'),
        content: Text('\'${note.title}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notesProvider.notifier).deleteNote(note.id);
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