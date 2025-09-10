import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/note_provider.dart';
import '../../../models/note_models.dart';
import 'note_edit_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteStats = ref.watch(noteStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('노트'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: '전체 (${noteStats.activeNotes})',
              icon: const Icon(Icons.note),
            ),
            Tab(
              text: '즐겨찾기 (${noteStats.favoriteNotes})',
              icon: const Icon(Icons.favorite),
            ),
            Tab(
              text: '보관함 (${noteStats.archivedNotes})',
              icon: const Icon(Icons.archive),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NotesListTab(),
          _FavoriteNotesTab(),
          _ArchivedNotesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateNoteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(),
    );
  }
  
  void _showCreateNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateNoteDialog(),
    );
  }
}

class _NotesListTab extends ConsumerWidget {
  const _NotesListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesBySubjectProvider);
    
    if (notes.isEmpty) {
      return const _EmptyState(
        icon: Icons.note,
        title: '노트가 없습니다',
        subtitle: '첫 번째 노트를 작성해보세요!',
      );
    }
    
    return _NotesGrid(notes: notes);
  }
}

class _FavoriteNotesTab extends ConsumerWidget {
  const _FavoriteNotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(favoriteNotesProvider);
    
    if (notes.isEmpty) {
      return const _EmptyState(
        icon: Icons.favorite,
        title: '즐겨찾기가 비어있습니다',
        subtitle: '중요한 노트를 즐겨찾기에 추가해보세요!',
      );
    }
    
    return _NotesGrid(notes: notes);
  }
}

class _ArchivedNotesTab extends ConsumerWidget {
  const _ArchivedNotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(archivedNotesProvider);
    
    if (notes.isEmpty) {
      return const _EmptyState(
        icon: Icons.archive,
        title: '보관함이 비어있습니다',
        subtitle: '보관된 노트가 없습니다.',
      );
    }
    
    return _NotesGrid(notes: notes, isArchived: true);
  }
}

class _NotesGrid extends StatelessWidget {
  final List<Note> notes;
  final bool isArchived;
  
  const _NotesGrid({
    required this.notes,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingMD,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return _NoteCard(
            note: note,
            isArchived: isArchived,
          ).animate()
            .fadeIn(delay: Duration(milliseconds: index * 100))
            .slideY(begin: 0.3, duration: 300.ms);
        },
      ),
    );
  }
}

class _NoteCard extends ConsumerWidget {
  final Note note;
  final bool isArchived;
  
  const _NoteCard({
    required this.note,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: note.color,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(note: note),
            ),
          );
        },
        onLongPress: () {
          _showNoteOptions(context, ref, note);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title.isNotEmpty ? note.title : '제목 없음',
                      style: AppTypography.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isFavorite)
                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                ],
              ),
              
              AppSpacing.verticalGapSM,
              
              // Content Preview
              Expanded(
                child: Text(
                  note.content.isNotEmpty ? note.content : '내용 없음',
                  style: AppTypography.body,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              AppSpacing.verticalGapSM,
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.subject,
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    _formatDate(note.updatedAt),
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              // Tags
              if (note.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 4,
                    children: note.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTypography.caption.copyWith(fontSize: 10),
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showNoteOptions(BuildContext context, WidgetRef ref, Note note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _NoteOptionsSheet(note: note, isArchived: isArchived),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 7) {
      return '${date.month}/${date.day}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

class _NoteOptionsSheet extends ConsumerWidget {
  final Note note;
  final bool isArchived;
  
  const _NoteOptionsSheet({
    required this.note,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.paddingMD,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(note.isFavorite ? Icons.favorite : Icons.favorite_border),
            title: Text(note.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가'),
            onTap: () {
              ref.read(noteProvider.notifier).toggleFavorite(note.id);
              Navigator.pop(context);
            },
          ),
          if (!isArchived)
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('보관하기'),
              onTap: () {
                ref.read(noteProvider.notifier).archiveNote(note.id);
                Navigator.pop(context);
              },
            ),
          if (isArchived)
            ListTile(
              leading: const Icon(Icons.unarchive),
              title: const Text('보관 해제'),
              onTap: () {
                ref.read(noteProvider.notifier).unarchiveNote(note.id);
                Navigator.pop(context);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('삭제', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, note);
            },
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('노트 삭제'),
        content: const Text('이 노트를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(noteProvider.notifier).deleteNote(note.id);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          AppSpacing.verticalGapMD,
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          AppSpacing.verticalGapSM,
          Text(
            subtitle,
            style: AppTypography.body.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<_SearchDialog> {
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('노트 검색'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '제목, 내용, 태그로 검색',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          ref.read(noteSearchProvider.notifier).state = value;
        },
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(noteSearchProvider.notifier).state = '';
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('검색'),
        ),
      ],
    );
  }
}

class _CreateNoteDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('새 노트 만들기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('템플릿을 선택하거나 빈 노트를 만드세요.'),
          AppSpacing.verticalGapMD,
          SizedBox(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              itemCount: NoteTemplates.templates.length,
              itemBuilder: (context, index) {
                final template = NoteTemplates.templates[index];
                return ListTile(
                  leading: Icon(template.icon),
                  title: Text(template.name),
                  subtitle: Text(template.description),
                  onTap: () {
                    Navigator.pop(context);
                    _createNoteFromTemplate(context, ref, template);
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _createBlankNote(context, ref);
          },
          child: const Text('빈 노트'),
        ),
      ],
    );
  }
  
  void _createNoteFromTemplate(BuildContext context, WidgetRef ref, NoteTemplate template) {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: template.template,
      subject: template.subject,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: NoteColors.getColor(0),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(note: note, isNew: true),
      ),
    );
  }
  
  void _createBlankNote(BuildContext context, WidgetRef ref) {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      subject: 'General',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: NoteColors.getColor(0),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(note: note, isNew: true),
      ),
    );
  }
}