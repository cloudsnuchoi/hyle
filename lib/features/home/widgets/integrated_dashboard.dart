import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../todo/screens/todo_screen_enhanced.dart';
import '../../timer/screens/timer_screen_enhanced.dart';
import '../../notes/screens/notes_screen_enhanced.dart';

class IntegratedDashboard extends ConsumerWidget {
  const IntegratedDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoItemsProvider);
    final todayTodos = ref.watch(todayCompletedTodosProvider);
    final notes = ref.watch(recentNotesProvider);
    final categories = ref.watch(todoCategoryProvider);
    final userStats = ref.watch(userStatsProvider);
    
    // 오늘 할 일
    final todayIncompleteTodos = todos.where((todo) {
      return !todo.isCompleted && 
             todo.createdAt.day == DateTime.now().day;
    }).toList();
    
    // 진행 중인 Todo (예상 시간이 설정된 것)
    final activeTodos = todos.where((todo) {
      return !todo.isCompleted && todo.estimatedMinutes > 0;
    }).toList()
      ..sort((a, b) => a.estimatedMinutes.compareTo(b.estimatedMinutes));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오늘의 요약
          _buildTodaySummary(context, ref, todayIncompleteTodos.length, todayTodos),
          
          AppSpacing.verticalGapLG,
          
          // 빠른 시작 섹션
          Text('빠른 시작', style: AppTypography.titleLarge),
          AppSpacing.verticalGapMD,
          _buildQuickStartSection(context, ref, activeTodos),
          
          AppSpacing.verticalGapLG,
          
          // 카테고리별 진행도
          Text('카테고리별 진행도', style: AppTypography.titleLarge),
          AppSpacing.verticalGapMD,
          _buildCategoryProgress(context, ref, categories, todos),
          
          AppSpacing.verticalGapLG,
          
          // 최근 노트
          if (notes.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('최근 노트', style: AppTypography.titleLarge),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotesScreenEnhanced(),
                      ),
                    );
                  },
                  child: const Text('모두 보기'),
                ),
              ],
            ),
            AppSpacing.verticalGapMD,
            _buildRecentNotes(context, ref, notes),
          ],
          
          AppSpacing.verticalGapLG,
          
          // 학습 통계
          Text('이번 주 학습 통계', style: AppTypography.titleLarge),
          AppSpacing.verticalGapMD,
          _buildWeeklyStats(context, ref, userStats),
        ],
      ),
    ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, WidgetRef ref, int todayTodos, int completedTodos) {
    final theme = Theme.of(context);
    final progress = todayTodos > 0 ? completedTodos / (todayTodos + completedTodos) : 0.0;
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                AppSpacing.horizontalGapMD,
                Text(
                  '오늘의 할 일',
                  style: AppTypography.titleMedium,
                ),
                const Spacer(),
                Text(
                  '$completedTodos / ${todayTodos + completedTodos}',
                  style: AppTypography.titleLarge.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapMD,
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            AppSpacing.verticalGapSM,
            Text(
              '${(progress * 100).toInt()}% 완료',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartSection(BuildContext context, WidgetRef ref, List<dynamic> activeTodos) {
    if (activeTodos.isEmpty) {
      return Card(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  size: 48,
                  color: Colors.grey[400],
                ),
                AppSpacing.verticalGapMD,
                Text(
                  '모든 할 일을 완료했습니다!',
                  style: AppTypography.body.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activeTodos.length.clamp(0, 5),
        itemBuilder: (context, index) {
          final todo = activeTodos[index];
          final category = ref.watch(todoCategoryProvider).firstWhere(
            (c) => c.id == todo.categoryId,
            orElse: () => ref.watch(todoCategoryProvider).last,
          );
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimerScreenEnhanced(initialTodo: todo),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 200,
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: category.color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          category.icon,
                          size: 20,
                          color: category.color,
                        ),
                        AppSpacing.horizontalGapSM,
                        Expanded(
                          child: Text(
                            category.name,
                            style: AppTypography.caption.copyWith(
                              color: category.color,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.play_circle,
                          color: category.color,
                        ),
                      ],
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      todo.title,
                      style: AppTypography.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${todo.estimatedMinutes}분',
                          style: AppTypography.caption,
                        ),
                        if (todo.actualMinutes > 0) ...[
                          const Spacer(),
                          Text(
                            '진행: ${todo.actualMinutes}분',
                            style: AppTypography.caption.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryProgress(BuildContext context, WidgetRef ref, List<dynamic> categories, List<dynamic> todos) {
    return Column(
      children: categories.map((category) {
        final categoryTodos = todos.where((t) => t.categoryId == category.id).toList();
        final completedCount = categoryTodos.where((t) => t.isCompleted).length;
        final totalCount = categoryTodos.length;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Todo 화면으로 이동하면서 해당 카테고리 선택
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TodoScreenEnhanced(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                      AppSpacing.horizontalGapMD,
                      Text(
                        category.name,
                        style: AppTypography.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        '$completedCount / $totalCount',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                  AppSpacing.verticalGapSM,
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentNotes(BuildContext context, WidgetRef ref, List<dynamic> notes) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final category = note.categoryId != null
              ? ref.watch(todoCategoryProvider).firstWhere(
                  (c) => c.id == note.categoryId,
                  orElse: () => null as dynamic,
                )
              : null;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotesScreenEnhanced(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 250,
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: note.color ?? Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: note.color != null
                        ? note.color!.withOpacity(0.3)
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (category != null) ...[
                          Icon(
                            category.icon,
                            size: 16,
                            color: category.color,
                          ),
                          AppSpacing.horizontalGapSM,
                        ],
                        Expanded(
                          child: Text(
                            note.title,
                            style: AppTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalGapSM,
                    Expanded(
                      child: Text(
                        note.content,
                        style: AppTypography.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      _formatDate(note.updatedAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyStats(BuildContext context, WidgetRef ref, dynamic userStats) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.timer,
                  label: '총 학습 시간',
                  value: '${userStats.weeklyStudyMinutes}분',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.task_alt,
                  label: '완료한 할 일',
                  value: '${ref.watch(completedTodosCountProvider)}개',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.note,
                  label: '작성한 노트',
                  value: '${ref.watch(notesProvider).length}개',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.titleLarge),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}