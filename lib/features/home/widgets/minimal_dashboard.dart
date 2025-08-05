import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/daily_goal_provider.dart';
import '../../../providers/todo_category_provider.dart';
import '../../timer/screens/timer_screen_enhanced.dart';
import '../../todo/screens/todo_screen_with_categories.dart';

class MinimalDashboard extends ConsumerStatefulWidget {
  const MinimalDashboard({super.key});

  @override
  ConsumerState<MinimalDashboard> createState() => _MinimalDashboardState();
}

class _MinimalDashboardState extends ConsumerState<MinimalDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStats = ref.watch(userStatsProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);
    final todos = ref.watch(todoItemsProvider);
    
    // 오늘 완료한 할 일
    final todayCompleted = todos.where((todo) {
      return todo.isCompleted && 
             todo.completedAt != null &&
             todo.completedAt!.day == DateTime.now().day;
    }).length;
    
    // 오늘 남은 할 일
    final todayRemaining = todos.where((todo) {
      return !todo.isCompleted && 
             todo.createdAt.day == DateTime.now().day;
    }).length;
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 상단 인사말
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _animationController,
                      child: Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _animationController,
                      child: Text(
                        _getMotivationalMessage(todayCompleted, todayRemaining),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 메인 카드들
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 오늘의 진행도 카드
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                    )),
                    child: _buildProgressCard(
                      context,
                      userStats,
                      dailyGoal,
                      todayCompleted,
                      todayRemaining,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 빠른 시작 버튼들
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                    )),
                    child: _buildQuickActions(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 동기부여 카드
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                    )),
                    child: _buildMotivationCard(context, userStats),
                  ),
                  
                  const SizedBox(height: 80), // FAB 공간
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressCard(
    BuildContext context,
    UserStats userStats,
    DailyGoal dailyGoal,
    int todayCompleted,
    int todayRemaining,
  ) {
    final theme = Theme.of(context);
    final totalTodos = todayCompleted + todayRemaining;
    final todoProgress = totalTodos > 0 ? todayCompleted / totalTodos : 0.0;
    final studyProgress = userStats.todayStudyMinutes / dailyGoal.studyMinutes;
    final overallProgress = (todoProgress + studyProgress) / 2;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 원형 진행도
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 원
                CustomPaint(
                  size: const Size(180, 180),
                  painter: CircularProgressPainter(
                    progress: 1.0,
                    color: theme.primaryColor.withOpacity(0.1),
                    strokeWidth: 12,
                  ),
                ),
                // 진행도 원
                CustomPaint(
                  size: const Size(180, 180),
                  painter: CircularProgressPainter(
                    progress: overallProgress.clamp(0.0, 1.0),
                    color: theme.primaryColor,
                    strokeWidth: 12,
                  ),
                ),
                // 중앙 텍스트
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(overallProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      '오늘 목표',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 상세 진행도
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  context,
                  icon: Icons.task_alt,
                  label: '할 일',
                  current: todayCompleted,
                  total: totalTodos,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  context,
                  icon: Icons.timer,
                  label: '학습',
                  current: userStats.todayStudyMinutes,
                  total: dailyGoal.studyMinutes,
                  color: Colors.blue,
                  unit: '분',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int current,
    required int total,
    required Color color,
    String unit = '개',
  }) {
    final progress = total > 0 ? current / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$current / $total$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.play_arrow,
            label: '집중 시작',
            color: Colors.blue,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimerScreenEnhanced(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.add_task,
            label: '할 일 추가',
            color: Colors.green,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TodoScreenWithCategories(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMotivationCard(BuildContext context, UserStats userStats) {
    final theme = Theme.of(context);
    final messages = [
      if (userStats.currentStreak > 0)
        '🔥 ${userStats.currentStreak}일 연속 학습 중!',
      if (userStats.level > 1)
        '⭐ 레벨 ${userStats.level} 달성!',
      if (userStats.todayStudyMinutes > 60)
        '💪 오늘 ${userStats.todayStudyMinutes}분 학습!',
      '🎯 조금씩 꾸준히가 성공의 비결',
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.orange.shade700,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  messages.first,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (messages.length > 1) ...[                  const SizedBox(height: 4),
                  Text(
                    messages[1],
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '편안한 새벽';
    if (hour < 12) return '좋은 아침';
    if (hour < 17) return '활기찬 오후';
    if (hour < 21) return '편안한 저녁';
    return '고요한 밤';
  }
  
  String _getMotivationalMessage(int completed, int remaining) {
    if (remaining == 0 && completed > 0) {
      return '오늘 할 일을 모두 완료했어요! 🎉';
    } else if (remaining > 0 && completed == 0) {
      return '오늘도 함께 시작해볼까요?';
    } else if (completed > remaining) {
      return '거의 다 왔어요! 조금만 더 힘내요 💪';
    } else {
      return '차근차근 해나가고 있어요 ✨';
    }
  }
}

// 원형 진행도 페인터
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  
  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}