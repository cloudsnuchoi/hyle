import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../timer/screens/timer_screen_enhanced.dart';
import '../../todo/screens/todo_screen_with_categories.dart';
import '../../profile/screens/profile_screen_improved.dart';
import '../widgets/minimal_dashboard.dart';
import '../widgets/quest_popup.dart';
import '../widgets/quick_action_dial.dart';
import '../../schedule/screens/schedule_screen.dart';
import '../../notes/screens/notes_screen_enhanced.dart';
import '../../flashcards/screens/flashcards_screen.dart';
import '../../ai/screens/ai_assistant_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreenMinimal extends ConsumerStatefulWidget {
  const HomeScreenMinimal({super.key});

  @override
  ConsumerState<HomeScreenMinimal> createState() => _HomeScreenMinimalState();
}

class _HomeScreenMinimalState extends ConsumerState<HomeScreenMinimal> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _pageTransitionController;
  
  // 페이지들을 미리 생성하지 않고 필요할 때만 생성
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const MinimalDashboard();
      case 1:
        return const TimerScreenEnhanced();
      case 2:
        return const TodoScreenWithCategories();
      case 3:
        return _buildMorePage();
      default:
        return const MinimalDashboard();
    }
  }

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pageTransitionController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
    _pageTransitionController.reset();
    _pageTransitionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      // 극도로 심플한 배경
      backgroundColor: isDark ? Colors.black : Colors.white,
      
      // PageView로 스와이프 가능하게
      body: Stack(
        children: [
          // 메인 콘텐츠
          PageView(
            onPageChanged: _onPageChanged,
            children: [
              FadeTransition(
                opacity: _pageTransitionController,
                child: _getPage(0),
              ),
              FadeTransition(
                opacity: _pageTransitionController,
                child: _getPage(1),
              ),
              FadeTransition(
                opacity: _pageTransitionController,
                child: _getPage(2),
              ),
              FadeTransition(
                opacity: _pageTransitionController,
                child: _getPage(3),
              ),
            ],
          ),
          
          // 하단 미니멀 네비게이션 (작은 점들)
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: _buildMinimalNavigation(),
          ),
        ],
      ),
      
      // 플로팅 액션 버튼 (주요 기능 접근)
      floatingActionButton: QuickActionDial(
        animationController: _fabAnimationController,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  Widget _buildMinimalNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isSelected = index == _selectedIndex;
        return GestureDetector(
          onTap: () => _onPageChanged(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isSelected ? 24 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isSelected 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
        );
      }),
    );
  }
  
  // 더보기 페이지
  Widget _buildMorePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('더보기'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildMenuGrid(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuGrid() {
    final menuItems = [
      _MenuItem(
        icon: Icons.calendar_today,
        label: '스케줄',
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.note,
        label: '노트',
        color: Colors.orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotesScreenEnhanced()),
        ),
      ),
      _MenuItem(
        icon: Icons.quiz,
        label: '플래시카드',
        color: Colors.purple,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FlashcardsScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.psychology,
        label: 'AI 어시스턴트',
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.person,
        label: '프로필',
        color: Colors.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreenImproved()),
        ),
      ),
      _MenuItem(
        icon: Icons.settings,
        label: '설정',
        color: Colors.grey,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        ),
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuCard(item);
      },
    );
  }
  
  Widget _buildMenuCard(_MenuItem item) {
    return Material(
      color: item.color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          item.onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 40,
                color: item.color,
              ),
              const SizedBox(height: 12),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 극도로 심플한 메인 액션 버튼
class MainActionButton extends ConsumerWidget {
  const MainActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withBlue(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.mediumImpact();
            // 빠른 작업 시작 다이얼로그
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => const QuickStartSheet(),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

// 빠른 시작 시트 (아래에서 올라옴)
class QuickStartSheet extends StatelessWidget {
  const QuickStartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // 큰 아이콘들로 주요 기능 접근
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAction(
                icon: Icons.timer,
                label: '타이머',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimerScreenEnhanced(),
                    ),
                  );
                },
              ),
              _QuickAction(
                icon: Icons.task_alt,
                label: '할 일',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodoScreenWithCategories(),
                    ),
                  );
                },
              ),
              _QuickAction(
                icon: Icons.auto_awesome,
                label: '퀘스트',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => const QuestPopup(),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}