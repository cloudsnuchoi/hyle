import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../timer/screens/timer_screen_enhanced.dart';
import '../../todo/screens/todo_screen_with_categories.dart';
import 'quest_popup.dart';

class QuickActionDial extends StatefulWidget {
  final AnimationController animationController;
  
  const QuickActionDial({
    super.key,
    required this.animationController,
  });

  @override
  State<QuickActionDial> createState() => _QuickActionDialState();
}

class _QuickActionDialState extends State<QuickActionDial> {
  bool _isOpen = false;
  
  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpen = !_isOpen;
    });
    
    if (_isOpen) {
      widget.animationController.forward();
    } else {
      widget.animationController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 200,
      height: 300,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // 서브 액션 버튼들
          ..._buildActionButtons(),
          
          // 메인 FAB
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: _toggle,
              backgroundColor: theme.primaryColor,
              child: AnimatedBuilder(
                animation: widget.animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: widget.animationController.value * math.pi / 4,
                    child: Icon(
                      _isOpen ? Icons.close : Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildActionButtons() {
    if (!_isOpen) return [];
    
    final actions = [
      _ActionItem(
        icon: Icons.timer,
        label: '타이머',
        color: Colors.blue,
        onTap: () {
          _toggle();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TimerScreenEnhanced(),
            ),
          );
        },
      ),
      _ActionItem(
        icon: Icons.task_alt,
        label: '할 일',
        color: Colors.green,
        onTap: () {
          _toggle();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TodoScreenWithCategories(),
            ),
          );
        },
      ),
      _ActionItem(
        icon: Icons.auto_awesome,
        label: '퀘스트',
        color: Colors.orange,
        onTap: () {
          _toggle();
          showDialog(
            context: context,
            builder: (context) => const QuestPopup(),
          );
        },
      ),
    ];
    
    return actions.asMap().entries.map((entry) {
      final index = entry.key;
      final action = entry.value;
      
      return AnimatedBuilder(
        animation: widget.animationController,
        builder: (context, child) {
          final offset = Tween<Offset>(
            begin: Offset.zero,
            end: Offset(0, -(index + 1) * 70.0),
          ).animate(CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(
              index * 0.1,
              0.7 + index * 0.1,
              curve: Curves.easeOut,
            ),
          )).value;
          
          return Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: widget.animationController.value,
              child: _buildActionButton(action),
            ),
          );
        },
      );
    }).toList();
  }
  
  Widget _buildActionButton(_ActionItem action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 라벨
          AnimatedOpacity(
            opacity: _isOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 버튼
          SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                action.onTap();
              },
              backgroundColor: action.color,
              mini: true,
              child: Icon(
                action.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}