import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late TabController _tabController;

  String _selectedPeriod = 'Week';

  final List<Map<String, dynamic>> _rankings = [
    {
      'rank': 1,
      'name': 'Emma Wilson',
      'avatar': '👩‍🎓',
      'score': 2850,
      'change': 'up',
      'changeAmount': 2,
      'level': 15,
      'badges': 12,
    },
    {
      'rank': 2,
      'name': 'James Park',
      'avatar': '👨‍💻',
      'score': 2720,
      'change': 'up',
      'changeAmount': 1,
      'level': 14,
      'badges': 10,
    },
    {
      'rank': 3,
      'name': 'Sophie Chen',
      'avatar': '👩‍🔬',
      'score': 2650,
      'change': 'down',
      'changeAmount': 1,
      'level': 14,
      'badges': 11,
    },
    {
      'rank': 4,
      'name': 'You',
      'avatar': '🎯',
      'score': 2480,
      'change': 'up',
      'changeAmount': 3,
      'level': 13,
      'badges': 8,
      'isCurrentUser': true,
    },
    {
      'rank': 5,
      'name': 'Alex Kim',
      'avatar': '👨‍🏫',
      'score': 2350,
      'change': 'same',
      'changeAmount': 0,
      'level': 12,
      'badges': 7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _tabController = TabController(length: 3, vsync: this);

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideIn = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
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
              Color(0xFF395886),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, _slideIn.value),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildPeriodSelector(),
                      _buildTopThree(),
                      _buildTabs(),
                      Expanded(child: _buildRankingList()),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF395886)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF395886)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Day', 'Week', 'Month', 'All Time'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedPeriod == periods[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(periods[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedPeriod = periods[index]);
              },
              selectedColor: const Color(0xFF638ECB),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF395886),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopThree() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumPlace(_rankings[1], 2, 160),
          const SizedBox(width: 8),
          _buildPodiumPlace(_rankings[0], 1, 180),
          const SizedBox(width: 8),
          _buildPodiumPlace(_rankings[2], 3, 140),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(Map<String, dynamic> user, int place, double height) {
    final colors = [
      const Color(0xFFFFD700),  // Gold
      const Color(0xFFC0C0C0),  // Silver
      const Color(0xFFCD7F32),  // Bronze
    ];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          user['avatar'],
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          user['name'],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${user['score']}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF638ECB),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors[place - 1],
                colors[place - 1].withValues(alpha: 0.7),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: colors[place - 1].withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors[place - 1].withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  place.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors[place - 1],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF638ECB),
        labelColor: const Color(0xFF638ECB),
        unselectedLabelColor: const Color(0xFF8AAEE0),
        tabs: const [
          Tab(text: 'Global'),
          Tab(text: 'Friends'),
          Tab(text: 'School'),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(_rankings),
        _buildList(_rankings.sublist(0, 3)),
        _buildList(_rankings.sublist(1, 4)),
      ],
    );
  }

  Widget _buildList(List<Map<String, dynamic>> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildRankingItem(users[index]);
      },
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> user) {
    final isCurrentUser = user['isCurrentUser'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF638ECB).withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser 
            ? Border.all(color: const Color(0xFF638ECB), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(user['rank']).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user['rank'].toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(user['rank']),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            user['avatar'],
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF395886),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF638ECB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.military_tech, size: 14, color: const Color(0xFF8AAEE0)),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${user['level']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8AAEE0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.emoji_events, size: 14, color: const Color(0xFF8AAEE0)),
                    const SizedBox(width: 4),
                    Text(
                      '${user['badges']} badges',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8AAEE0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user['score']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF638ECB),
                ),
              ),
              const SizedBox(height: 4),
              _buildChangeIndicator(user['change'], user['changeAmount']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(String change, int amount) {
    IconData icon;
    Color color;
    
    switch (change) {
      case 'up':
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case 'down':
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      default:
        icon = Icons.remove;
        color = const Color(0xFF8AAEE0);
    }
    
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        if (amount > 0) ...[
          const SizedBox(width: 2),
          Text(
            amount.toString(),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF638ECB);
    }
  }
}