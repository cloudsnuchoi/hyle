import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Settings states
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _language = 'ko';
  String _difficulty = 'normal';
  bool _autoSave = true;
  bool _offlineMode = false;
  
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
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Settings List
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Account Section
                      _buildSectionHeader('계정'),
                      _buildAccountSection(),
                      
                      const SizedBox(height: 24),
                      
                      // App Settings Section
                      _buildSectionHeader('앱 설정'),
                      _buildAppSettingsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Learning Settings Section
                      _buildSectionHeader('학습 설정'),
                      _buildLearningSettingsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Notification Settings Section
                      _buildSectionHeader('알림 설정'),
                      _buildNotificationSettingsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Data & Privacy Section
                      _buildSectionHeader('데이터 & 개인정보'),
                      _buildDataPrivacySection(),
                      
                      const SizedBox(height: 24),
                      
                      // About Section
                      _buildSectionHeader('정보'),
                      _buildAboutSection(),
                      
                      const SizedBox(height: 32),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF737373), // gray500
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
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
          _buildListTile(
            icon: Icons.person_outline_rounded,
            title: '프로필 관리',
            subtitle: '이름, 사진, 정보 수정',
            onTap: () {
              // Navigate to profile edit
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.email_outlined,
            title: '이메일 변경',
            subtitle: 'student@example.com',
            onTap: () {
              // Change email
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.lock_outline_rounded,
            title: '비밀번호 변경',
            onTap: () {
              // Change password
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.link_rounded,
            title: '연결된 계정',
            subtitle: 'Google, Apple, Kakao',
            onTap: () {
              // Manage linked accounts
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
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
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: '다크 모드',
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
          _buildDivider(),
          _buildDropdownTile(
            icon: Icons.language_rounded,
            title: '언어',
            value: _language,
            items: const {
              'ko': '한국어',
              'en': 'English',
              'ja': '日本語',
              'zh': '中文',
            },
            onChanged: (value) {
              setState(() {
                _language = value!;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.volume_up_outlined,
            title: '효과음',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.vibration_rounded,
            title: '진동',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLearningSettingsSection() {
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
          _buildDropdownTile(
            icon: Icons.speed_rounded,
            title: '난이도',
            value: _difficulty,
            items: const {
              'easy': '쉬움',
              'normal': '보통',
              'hard': '어려움',
              'expert': '전문가',
            },
            onChanged: (value) {
              setState(() {
                _difficulty = value!;
              });
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.timer_outlined,
            title: '학습 목표',
            subtitle: '일일 30분',
            onTap: () {
              // Set learning goals
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.save_outlined,
            title: '자동 저장',
            subtitle: '학습 진도 자동 저장',
            value: _autoSave,
            onChanged: (value) {
              setState(() {
                _autoSave = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.wifi_off_rounded,
            title: '오프라인 모드',
            subtitle: '콘텐츠 다운로드',
            value: _offlineMode,
            onChanged: (value) {
              setState(() {
                _offlineMode = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsSection() {
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
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: '푸시 알림',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          if (_notificationsEnabled) ...[
            _buildDivider(),
            _buildListTile(
              icon: Icons.access_time_rounded,
              title: '학습 리마인더',
              subtitle: '매일 오후 7시',
              onTap: () {
                // Set reminder time
              },
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.celebration_outlined,
              title: '업적 알림',
              subtitle: '새로운 배지 획득 시',
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF638ECB),
              ),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.group_outlined,
              title: '친구 활동',
              subtitle: '친구의 새로운 활동',
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: const Color(0xFF638ECB),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataPrivacySection() {
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
          _buildListTile(
            icon: Icons.download_outlined,
            title: '데이터 내보내기',
            subtitle: '학습 기록 다운로드',
            onTap: () {
              // Export data
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.delete_outline_rounded,
            title: '캐시 삭제',
            subtitle: '임시 파일 정리',
            onTap: () {
              // Clear cache
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보 처리방침',
            onTap: () {
              // Show privacy policy
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.description_outlined,
            title: '이용약관',
            onTap: () {
              // Show terms
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
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
          _buildListTile(
            icon: Icons.info_outline_rounded,
            title: '버전 정보',
            subtitle: 'v1.0.0',
            onTap: () {
              // Show version info
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.help_outline_rounded,
            title: '도움말 센터',
            onTap: () {
              // Show help center
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.feedback_outlined,
            title: '피드백 보내기',
            onTap: () {
              // Send feedback
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.star_outline_rounded,
            title: '앱 평가하기',
            onTap: () {
              // Rate app
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                          fontSize: 14,
                          color: Color(0xFF737373), // gray500
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ?? 
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                      fontSize: 14,
                      color: Color(0xFF737373), // gray500
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF638ECB),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF262626), // gray800
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: value,
              items: items.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF395886),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              underline: const SizedBox(),
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Color(0xFF395886),
              ),
            ),
          ),
        ],
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
}