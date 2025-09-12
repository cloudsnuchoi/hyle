import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F3FA), // primary50
              Color(0xFFD5DEEF), // primary100
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(),
                
                // Profile Header
                _buildProfileHeader(),
                
                const SizedBox(height: 24),
                
                // Stats Overview
                _buildStatsOverview(),
                
                const SizedBox(height: 24),
                
                // Recent Badges
                _buildRecentBadges(),
                
                const SizedBox(height: 24),
                
                // Menu Items
                _buildMenuSection(),
                
                const SizedBox(height: 24),
                
                // Logout Button
                _buildLogoutButton(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const Text(
            '프로필',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              context.go('/profile/settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8AAEE0), // primary300
                      Color(0xFF395886), // primary500
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF395886).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF638ECB),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Name and Level
          const Text(
            '홍길동',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF638ECB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Level 12 • 학습 전사',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF638ECB),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'student@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF737373), // gray500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.local_fire_department_rounded,
            value: '7',
            label: '연속 학습',
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.timer_rounded,
            value: '125',
            label: '학습 시간',
            color: const Color(0xFF638ECB),
          ),
          _buildStatItem(
            icon: Icons.star_rounded,
            value: '1.2K',
            label: 'XP',
            color: const Color(0xFFFFC107),
          ),
          _buildStatItem(
            icon: Icons.emoji_events_rounded,
            value: '15',
            label: '배지',
            color: const Color(0xFF395886),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF737373), // gray500
          ),
        ),
      ],
    );
  }

  Widget _buildRecentBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 획득 배지',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                final badges = [
                  BadgeData('우등생', Icons.school_rounded, Colors.blue),
                  BadgeData('7일 연속', Icons.local_fire_department_rounded, Colors.orange),
                  BadgeData('퀴즈왕', Icons.quiz_rounded, Colors.green),
                  BadgeData('AI 친구', Icons.smart_toy_rounded, Colors.purple),
                  BadgeData('팀플레이', Icons.groups_rounded, Colors.red),
                ];
                
                return Container(
                  width: 80,
                  margin: EdgeInsets.only(
                    right: 12,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badges[index].color.withValues(alpha: 0.1),
                          border: Border.all(
                            color: badges[index].color,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          badges[index].icon,
                          size: 28,
                          color: badges[index].color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badges[index].name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF525252), // gray600
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            title: '프로필 편집',
            onTap: () {
              // 프로필 편집 화면은 아직 없음
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필 편집 화면 준비 중')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.group_outlined,
            title: '친구 관리',
            onTap: () {
              // 친구 관리 화면은 아직 없음
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('친구 관리 화면 준비 중')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.credit_card_outlined,
            title: '구독 관리',
            subtitle: '프리미엄',
            onTap: () {
              context.go('/settings/subscription');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF638ECB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF262626), // gray800
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF737373), // gray500
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF737373), // gray500
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFE5E5E5), // gray200
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          // Handle logout
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class BadgeData {
  final String name;
  final IconData icon;
  final Color color;

  BadgeData(this.name, this.icon, this.color);
}