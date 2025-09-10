import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/note_provider.dart';
import '../../../models/note_models.dart';

class NoteEditScreen extends ConsumerStatefulWidget {
  final Note note;
  final bool isNew;
  
  const NoteEditScreen({
    super.key,
    required this.note,
    this.isNew = false,
  });

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  late Note _currentNote;
  
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);
    _tagController = TextEditingController();
    
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? '새 노트' : '노트 편집'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _currentNote.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _currentNote.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _currentNote = _currentNote.copyWith(isFavorite: !_currentNote.isFavorite);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Container(
        color: _currentNote.color,
        child: Column(
          children: [
            // Subject and Tags Section
            Container(
              padding: AppSpacing.paddingMD,
              child: Column(
                children: [
                  // Subject Selector
                  DropdownButtonFormField<String>(
                    value: _currentNote.subject,
                    decoration: const InputDecoration(
                      labelText: '과목',
                      border: OutlineInputBorder(),
                    ),
                    items: _getSubjectItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _currentNote = _currentNote.copyWith(subject: value);
                        });
                      }
                    },
                  ),
                  
                  AppSpacing.verticalGapMD,
                  
                  // Tags Section
                  _buildTagsSection(),
                ],
              ),
            ),
            
            // Title and Content Section
            Expanded(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  children: [
                    // Title Input
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '제목을 입력하세요',
                        border: InputBorder.none,
                      ),
                      style: AppTypography.titleLarge,
                      maxLines: 1,
                    ),
                    
                    const Divider(),
                    
                    // Content Input
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          hintText: '내용을 입력하세요',
                          border: InputBorder.none,
                        ),
                        style: AppTypography.body,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Info Bar
            Container(
              padding: AppSpacing.paddingMD,
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '생성: ${_formatDate(_currentNote.createdAt)}',
                    style: AppTypography.caption,
                  ),
                  if (!widget.isNew)
                    Text(
                      '수정: ${_formatDate(_currentNote.updatedAt)}',
                      style: AppTypography.caption,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: '태그 추가',
                  border: OutlineInputBorder(),
                  hintText: '태그를 입력하고 Enter를 누르세요',
                ),
                onSubmitted: _addTag,
              ),
            ),
            AppSpacing.horizontalGapMD,
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_tagController.text),
            ),
          ],
        ),
        
        AppSpacing.verticalGapMD,
        
        // Tags Display
        if (_currentNote.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _currentNote.tags.map((tag) => Chip(
              label: Text('#$tag'),
              onDeleted: () => _removeTag(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
            )).toList(),
          ),
      ],
    );
  }
  
  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_currentNote.tags.contains(tag.trim())) {
      setState(() {
        _currentNote = _currentNote.copyWith(
          tags: [..._currentNote.tags, tag.trim()],
        );
        _tagController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _currentNote = _currentNote.copyWith(
        tags: _currentNote.tags.where((t) => t != tag).toList(),
      );
    });
  }
  
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('노트 색상 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 100,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: NoteColors.colors.length,
            itemBuilder: (context, index) {
              final color = NoteColors.colors[index];
              final isSelected = color == _currentNote.color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentNote = _currentNote.copyWith(color: color);
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _saveNote() {
    final updatedNote = _currentNote.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );
    
    if (widget.isNew) {
      ref.read(noteProvider.notifier).addNote(updatedNote);
    } else {
      ref.read(noteProvider.notifier).updateNote(updatedNote);
    }
    
    setState(() {
      _hasChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('노트가 저장되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
  
  List<DropdownMenuItem<String>> _getSubjectItems() {
    final subjects = [
      'General',
      'Math',
      'English',
      'Science',
      'History',
      'Literature',
      'Art',
      'Music',
      'Sports',
      'Technology',
      'Language',
      'Other',
    ];
    
    return subjects.map((subject) => DropdownMenuItem(
      value: subject,
      child: Text(subject),
    )).toList();
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}