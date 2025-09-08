import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _chestAnimationController;
  late AnimationController _coinAnimationController;
  late Animation<double> _chestAnimation;
  late Animation<double> _coinAnimation;
  
  final List<Reward> _availableRewards = [
    Reward(
      id: '1',
      title: '일일 보상',
      description: '매일 로그인하면 받는 보상',
      icon: Icons.today,
      type: RewardType.daily,
      coins: 10,
      xp: 20,
      isAvailable: true,
      lastClaimed: DateTime.now().subtract(const Duration(days: 1)),
      cooldownHours: 24,
    ),
    Reward(
      id: '2',
      title: '주간 보너스',
      description: '일주일 연속 학습 보상',
      icon: Icons.calendar_view_week,
      type: RewardType.weekly,
      coins: 50,
      xp: 100,
      gems: 5,
      isAvailable: true,
      lastClaimed: DateTime.now().subtract(const Duration(days: 7)),
      cooldownHours: 168,
    ),
    Reward(
      id: '3',
      title: '레벨 업 보상',
      description: '레벨 10 달성!',
      icon: Icons.trending_up,
      type: RewardType.levelUp,
      coins: 100,
      xp: 0,
      gems: 10,
      isAvailable: true,
    ),
  ];
  
  final List<Reward> _claimedRewards = [
    Reward(
      id: '4',
      title: '첫 학습 보상',
      description: '첫 학습 세션 완료',
      icon: Icons.flag,
      type: RewardType.achievement,
      coins: 30,
      xp: 50,
      isAvailable: false,
      claimedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _chestAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chestAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _chestAnimationController,
      curve: Curves.elasticInOut,
    ));
    _coinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.bounceOut,
    ));
    _chestAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _chestAnimationController.dispose();
    _coinAnimationController.dispose();
    super.dispose();
  }

  void _claimReward(Reward reward) {
    _coinAnimationController.forward(from: 0);
    setState(() {
      // Claim logic
    });
    _showRewardDialog(reward);
  }

  void _showRewardDialog(Reward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF0F3FA)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _coinAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '보상 획득!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E27),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                reward.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (reward.coins > 0)
                    _buildRewardItem(Icons.monetization_on, '+${reward.coins}', Colors.orange),
                  if (reward.coins > 0 && reward.xp > 0)
                    const SizedBox(width: 20),
                  if (reward.xp > 0)
                    _buildRewardItem(Icons.star, '+${reward.xp} XP', Colors.amber),
                  if (reward.gems != null && reward.gems! > 0) ...[
                    const SizedBox(width: 20),
                    _buildRewardItem(Icons.diamond, '+${reward.gems}', Colors.purple),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF638ECB),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F3FA),
              Color(0xFFE8EDF5),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA500),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _chestAnimation,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.redeem,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '보상',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '노력의 결실을 받아가세요!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Available Rewards Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '받을 수 있는 보상',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1E27),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._availableRewards.map((reward) => _buildRewardCard(reward, true)),
                    ],
                  ),
                ),
              ),

              // Claimed Rewards Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '받은 보상',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1E27),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._claimedRewards.map((reward) => _buildRewardCard(reward, false)),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(Reward reward, bool isAvailable) {
    Color typeColor;
    switch (reward.type) {
      case RewardType.daily:
        typeColor = const Color(0xFF638ECB);
        break;
      case RewardType.weekly:
        typeColor = const Color(0xFF8B5CF6);
        break;
      case RewardType.levelUp:
        typeColor = Colors.orange;
        break;
      case RewardType.achievement:
        typeColor = Colors.green;
        break;
      case RewardType.special:
        typeColor = Colors.pink;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isAvailable
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  typeColor.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: isAvailable ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: isAvailable
            ? Border.all(color: typeColor.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isAvailable
                ? typeColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isAvailable ? () => _claimReward(reward) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: isAvailable ? 0.1 : 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    reward.icon,
                    color: isAvailable ? typeColor : Colors.grey,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? const Color(0xFF1A1E27) : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isAvailable ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (reward.coins > 0)
                            _buildRewardChip(
                              Icons.monetization_on,
                              '${reward.coins}',
                              Colors.orange,
                              isAvailable,
                            ),
                          if (reward.xp > 0) ...[
                            const SizedBox(width: 8),
                            _buildRewardChip(
                              Icons.star,
                              '${reward.xp} XP',
                              Colors.amber,
                              isAvailable,
                            ),
                          ],
                          if (reward.gems != null && reward.gems! > 0) ...[
                            const SizedBox(width: 8),
                            _buildRewardChip(
                              Icons.diamond,
                              '${reward.gems}',
                              Colors.purple,
                              isAvailable,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '받기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (reward.claimedAt != null)
                  Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(reward.claimedAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardChip(IconData icon, String text, Color color, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isEnabled ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isEnabled ? color : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isEnabled ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

// Reward Model
class Reward {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final RewardType type;
  final int coins;
  final int xp;
  final int? gems;
  final bool isAvailable;
  final DateTime? lastClaimed;
  final DateTime? claimedAt;
  final int? cooldownHours;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.coins,
    required this.xp,
    this.gems,
    required this.isAvailable,
    this.lastClaimed,
    this.claimedAt,
    this.cooldownHours,
  });
}

enum RewardType {
  daily,
  weekly,
  levelUp,
  achievement,
  special,
}