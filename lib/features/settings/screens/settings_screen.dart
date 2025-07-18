import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_typography.dart';
import '../../profile/widgets/theme_settings_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // 일반 설정
          _buildSectionHeader('일반'),
          _buildSettingTile(
            icon: Icons.palette,
            title: '테마 설정',
            subtitle: '앱의 색상과 스타일을 변경합니다',
            onTap: () => _showThemeSettings(context),
          ),
          _buildSettingTile(
            icon: Icons.language,
            title: '언어 설정',
            subtitle: '한국어',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('언어 설정 준비 중')),
              );
            },
          ),
          
          const Divider(height: 32),
          
          // 알림 설정
          _buildSectionHeader('알림'),
          _buildSettingTile(
            icon: Icons.notifications,
            title: '알림 설정',
            subtitle: '학습 리마인더와 알림을 관리합니다',
            onTap: () => _showNotificationSettings(context),
          ),
          _buildSettingTile(
            icon: Icons.do_not_disturb,
            title: '방해 금지 모드',
            subtitle: '집중 시간 동안 알림을 차단합니다',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('방해 금지 모드 준비 중')),
                );
              },
            ),
            onTap: () {}, // Switch가 있으므로 빈 함수
          ),
          
          const Divider(height: 32),
          
          // 학습 설정
          _buildSectionHeader('학습'),
          _buildSettingTile(
            icon: Icons.timer,
            title: '기본 학습 시간',
            subtitle: '25분',
            onTap: () {
              _showTimerSettings(context);
            },
          ),
          _buildSettingTile(
            icon: Icons.calendar_today,
            title: '주간 학습 목표',
            subtitle: '주 5일, 하루 3시간',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('학습 목표 설정 준비 중')),
              );
            },
          ),
          
          const Divider(height: 32),
          
          // 데이터 및 저장소
          _buildSectionHeader('데이터 및 저장소'),
          _buildSettingTile(
            icon: Icons.backup,
            title: '데이터 백업',
            subtitle: '클라우드에 학습 데이터를 백업합니다',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('백업 기능 준비 중')),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.delete_sweep,
            title: '캐시 삭제',
            subtitle: '임시 파일을 삭제하여 저장 공간을 확보합니다',
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
          
          const Divider(height: 32),
          
          // 정보
          _buildSectionHeader('정보'),
          _buildSettingTile(
            icon: Icons.info,
            title: '앱 정보',
            subtitle: 'Hyle v1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Hyle',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Hyle Team\n\nAI 기반 개인 맞춤형 학습 동반자',
                children: [
                  const SizedBox(height: 16),
                  const Text('Hyle은 학생들의 효과적인 학습을 돕는 AI 학습 동반자입니다.'),
                ],
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: '개인정보 처리방침',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('개인정보 처리방침 페이지 준비 중')),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.description,
            title: '이용약관',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이용약관 페이지 준비 중')),
              );
            },
          ),
          
          const Divider(height: 32),
          
          // 계정
          _buildSectionHeader('계정'),
          _buildSettingTile(
            icon: Icons.logout,
            title: '로그아웃',
            titleColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: Colors.grey[600],
        ),
      ),
    );
  }
  
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: titleColor != null ? TextStyle(color: titleColor) : null,
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  void _showThemeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSettingsDialog(),
    );
  }
  
  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('알림 설정', style: AppTypography.titleLarge),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('학습 시작 알림'),
              subtitle: const Text('예정된 학습 시간에 알림을 받습니다'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('휴식 시간 알림'),
              subtitle: const Text('휴식 시간이 되면 알림을 받습니다'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('목표 달성 알림'),
              subtitle: const Text('일일 목표를 달성하면 알림을 받습니다'),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTimerSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('타이머 설정', style: AppTypography.titleLarge),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('집중 시간'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('25분', style: AppTypography.titleMedium),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            ListTile(
              title: const Text('짧은 휴식'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('5분', style: AppTypography.titleMedium),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            ListTile(
              title: const Text('긴 휴식'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('15분', style: AppTypography.titleMedium),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('임시 파일을 삭제하시겠습니까?\n앱이 더 빠르게 작동할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('캐시가 삭제되었습니다')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 실제 로그아웃 처리
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃되었습니다')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}