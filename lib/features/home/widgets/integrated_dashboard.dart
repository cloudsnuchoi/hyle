import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/todo_category_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/dday_provider.dart';
import '../../../providers/daily_goal_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/web_notification_service.dart';
import '../../todo/screens/todo_screen_enhanced.dart';
import '../../timer/screens/timer_screen_enhanced.dart';
import '../../notes/screens/notes_screen_enhanced.dart';
import '../../social/widgets/social_button.dart';
import 'dday_widget.dart';
import 'level_badge.dart';
import 'quest_widget.dart';

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
        actions: const [
          LevelBadge(),
          SizedBox(width: 8),
          SocialButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오늘의 요약
          _buildTodaySummary(context, ref, todayIncompleteTodos.length, todayTodos),
          
          AppSpacing.verticalGapLG,
          
          // D-Day 위젯
          const DDayWidget(),
          
          AppSpacing.verticalGapLG,
          
          // 퀘스트 위젯
          const QuestWidget(),
          
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
          
          AppSpacing.verticalGapLG,
          
          // 알림 테스트 버튼 (개발용)
          ElevatedButton.icon(
            onPressed: () => _testNotifications(),
            icon: const Icon(Icons.notifications),
            label: const Text('알림 테스트'),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, WidgetRef ref, int todayTodos, int completedTodos) {
    final theme = Theme.of(context);
    final totalTodos = todayTodos + completedTodos;
    final progress = totalTodos > 0 ? completedTodos / totalTodos : 0.0;
    final userStats = ref.watch(userStatsProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);
    final studyProgress = userStats.todayStudyMinutes / dailyGoal.studyMinutes;
    
    return Card(
      child: InkWell(
        onTap: () => _showGoalSettingDialog(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                AppSpacing.horizontalGapMD,
                Text(
                  '오늘의 목표',
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
            AppSpacing.verticalGapLG,
            
            // 할 일 진행도
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.task_alt, size: 20, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('할 일', style: AppTypography.body),
                  ],
                ),
                Text(
                  '$completedTodos / $totalTodos',
                  style: AppTypography.titleMedium.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapSM,
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.green,
              ),
            ),
            
            AppSpacing.verticalGapMD,
            
            // 학습 시간 진행도
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('학습 시간', style: AppTypography.body),
                  ],
                ),
                Text(
                  '${userStats.todayStudyMinutes}분 / ${dailyGoal.studyMinutes}분',
                  style: AppTypography.titleMedium.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapSM,
            LinearProgressIndicator(
              value: studyProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
            ),
            
            AppSpacing.verticalGapMD,
            
            // 종합 진행률
            Center(
              child: Text(
                '오늘 목표 ${((progress + studyProgress) / 2 * 100).toInt()}% 달성',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
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
        physics: const BouncingScrollPhysics(),
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
        physics: const BouncingScrollPhysics(),
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
      child: InkWell(
        onTap: () => _showStatsDetailDialog(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('이번 주 학습 통계', style: AppTypography.titleMedium),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              AppSpacing.verticalGapMD,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _buildStatItem(
                      icon: Icons.timer,
                      label: '총 학습 시간',
                      value: '${userStats.weeklyStudyMinutes}분',
                      color: Colors.blue,
                    ),
                  ),
                  Flexible(
                    child: _buildStatItem(
                      icon: Icons.task_alt,
                      label: '완료한 할 일',
                      value: '${ref.watch(completedTodosCountProvider)}개',
                      color: Colors.green,
                    ),
                  ),
                  Flexible(
                    child: _buildStatItem(
                      icon: Icons.note,
                      label: '작성한 노트',
                      value: '${ref.watch(notesProvider).length}개',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
  
  void _showGoalSettingDialog(BuildContext context, WidgetRef ref) {
    final dailyGoal = ref.read(dailyGoalProvider);
    int selectedTodoCount = dailyGoal.todoCount;
    int selectedStudyHours = dailyGoal.studyMinutes ~/ 60;
    int selectedStudyMinutes = dailyGoal.studyMinutes % 60;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.flag,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('오늘의 목표 설정'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 할 일 목표
              Text('할 일 목표', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: selectedTodoCount.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: '$selectedTodoCount개',
                      onChanged: (value) {
                        setState(() {
                          selectedTodoCount = value.round();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        '$selectedTodoCount개',
                        style: AppTypography.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 학습 시간 목표
              Text('학습 시간 목표', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  // 시간 선택
                  Column(
                    children: [
                      Text('시간', style: AppTypography.caption),
                      const SizedBox(height: 4),
                      DropdownButton<int>(
                        value: selectedStudyHours,
                        items: List.generate(13, (i) => i).map((hour) {
                          return DropdownMenuItem(
                            value: hour,
                            child: Text('$hour시간'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStudyHours = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 분 선택
                  Column(
                    children: [
                      Text('분', style: AppTypography.caption),
                      const SizedBox(height: 4),
                      DropdownButton<int>(
                        value: selectedStudyMinutes,
                        items: [0, 15, 30, 45].map((minute) {
                          return DropdownMenuItem(
                            value: minute,
                            child: Text('$minute분'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStudyMinutes = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 권장 사항
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '하루 3-4시간, 5-7개의 할 일이 적당해요',
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
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
                final totalMinutes = selectedStudyHours * 60 + selectedStudyMinutes;
                ref.read(dailyGoalProvider.notifier).updateTodoGoal(selectedTodoCount);
                ref.read(dailyGoalProvider.notifier).updateStudyGoal(totalMinutes);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('오늘의 목표가 설정되었습니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('설정'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showStatsDetailDialog(BuildContext context, WidgetRef ref) {
    final userStats = ref.read(userStatsProvider);
    final todos = ref.read(todoItemsProvider);
    final completedTodos = todos.where((t) => t.isCompleted).toList();
    final notes = ref.read(notesProvider);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('이번 주 학습 통계 상세', style: AppTypography.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // 내용
              Flexible(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingLG,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 학습 시간 상세
                      _buildDetailSection(
                        context: context,
                        icon: Icons.timer,
                        title: '학습 시간 분석',
                        color: Colors.blue,
                        children: [
                          _buildDetailRow('오늘', '${userStats.todayStudyMinutes}분'),
                          _buildDetailRow('이번 주', '${userStats.weeklyStudyMinutes}분'),
                          _buildDetailRow('일일 평균', '${userStats.weeklyStudyMinutes ~/ 7}분'),
                          const Divider(),
                          _buildDetailRow('총 누적 시간', userStats.getFormattedStudyTime()),
                          if (userStats.subjectStats.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('과목별 시간', style: AppTypography.titleSmall),
                            const SizedBox(height: 8),
                            ...userStats.subjectStats.entries.map((entry) {
                              return _buildDetailRow(entry.key, '${entry.value}분');
                            }),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 할 일 상세
                      _buildDetailSection(
                        context: context,
                        icon: Icons.task_alt,
                        title: '할 일 완료 현황',
                        color: Colors.green,
                        children: [
                          _buildDetailRow('오늘 완료', '${ref.read(todayCompletedTodosProvider)}개'),
                          _buildDetailRow('이번 주 완료', '${completedTodos.length}개'),
                          _buildDetailRow('전체 할 일', '${todos.length}개'),
                          _buildDetailRow('완료율', '${(completedTodos.length / todos.length * 100).toInt()}%'),
                          const Divider(),
                          const Text('최근 완료한 할 일', style: AppTypography.titleSmall),
                          const SizedBox(height: 8),
                          ...completedTodos.take(5).map((todo) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      todo.title,
                                      style: AppTypography.body,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 노트 상세
                      _buildDetailSection(
                        context: context,
                        icon: Icons.note,
                        title: '노트 작성 현황',
                        color: Colors.orange,
                        children: [
                          _buildDetailRow('전체 노트', '${notes.length}개'),
                          _buildDetailRow('이번 주 작성', '${notes.where((n) => n.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}개'),
                          const Divider(),
                          const Text('최근 작성한 노트', style: AppTypography.titleSmall),
                          const SizedBox(height: 8),
                          ...notes.take(5).map((note) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.description, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: AppTypography.body,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  // 알림 테스트 메서드
  void _testNotifications() async {
    final webNotificationService = WebNotificationService();
    
    // 즉시 알림 테스트
    webNotificationService.showGoalProgress(
      percentage: 75,
      goalType: '오늘의 학습',
      encouragement: '조금만 더 하면 목표 달성이에요!',
    );
    
    // 2초 후 휴식 알림
    await Future.delayed(const Duration(seconds: 2));
    webNotificationService.showBreakReminder(
      studyMinutes: 25,
      breakMinutes: 5,
    );
    
    // 4초 후 연속 학습 알림
    await Future.delayed(const Duration(seconds: 2));
    webNotificationService.showStreakNotification(
      currentStreak: 3,
      nextMilestone: 7,
    );
    
    // 6초 후 스마트 제안
    await Future.delayed(const Duration(seconds: 2));
    webNotificationService.showSmartSuggestion(
      suggestion: '지금이 집중력이 가장 높은 시간이에요!',
      reason: '평소 이 시간대에 학습 효율이 20% 높았어요',
    );
  }
}