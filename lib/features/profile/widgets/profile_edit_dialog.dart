import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/profile_screen_improved.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ProfileEditDialog extends ConsumerStatefulWidget {
  const ProfileEditDialog({super.key});

  @override
  ConsumerState<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<ProfileEditDialog> {
  late TextEditingController _nameController;
  late String _selectedGrade;
  late List<String> _selectedSubjects;
  final TextEditingController _subjectController = TextEditingController();

  final List<String> _grades = [
    '중1', '중2', '중3',
    '고1', '고2', '고3',
    '재수생', 'N수생',
    '대학생', '공시생', '자격증',
  ];

  final List<String> _commonSubjects = [
    '국어', '영어', '수학',
    '과학', '사회', '역사',
    '물리', '화학', '생물',
    '지구과학', '프로그래밍', 'TOEIC',
    'TEPS', '공무원', '자격증',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _selectedGrade = profile.grade;
    _selectedSubjects = List.from(profile.subjects);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요')),
      );
      return;
    }

    final newProfile = ref.read(userProfileProvider).copyWith(
      name: _nameController.text.trim(),
      grade: _selectedGrade,
      subjects: _selectedSubjects,
    );

    ref.read(userProfileProvider.notifier).updateProfile(newProfile);
    Navigator.pop(context);
  }

  void _addSubject(String subject) {
    if (!_selectedSubjects.contains(subject)) {
      setState(() {
        _selectedSubjects.add(subject);
      });
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      _selectedSubjects.remove(subject);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Text('프로필 편집', style: AppTypography.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 이름
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '이름을 입력하세요',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 학년/신분
            Text('학년/신분', style: AppTypography.labelLarge),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _grades.map((grade) {
                final isSelected = _selectedGrade == grade;
                return ChoiceChip(
                  label: Text(grade),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedGrade = grade;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // 과목 태그
            Text('공부하는 과목', style: AppTypography.labelLarge),
            const SizedBox(height: 12),
            
            // 선택된 과목
            if (_selectedSubjects.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedSubjects.map((subject) {
                  return Chip(
                    label: Text(subject),
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: theme.primaryColor),
                    onDeleted: () => _removeSubject(subject),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // 과목 추가
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      hintText: '과목 추가',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _addSubject(value);
                        _subjectController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_subjectController.text.isNotEmpty) {
                      _addSubject(_subjectController.text);
                      _subjectController.clear();
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 추천 과목
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _commonSubjects
                  .where((subject) => !_selectedSubjects.contains(subject))
                  .map((subject) {
                return ActionChip(
                  label: Text(subject),
                  onPressed: () => _addSubject(subject),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('저장'),
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