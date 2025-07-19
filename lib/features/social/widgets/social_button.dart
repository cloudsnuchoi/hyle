import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/social_provider.dart';
import '../../../models/friend.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SocialButton extends ConsumerWidget {
  const SocialButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineFriends = ref.watch(onlineFriendsProvider);
    final myStatus = ref.watch(myStatusProvider);
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.people, size: 28),
              if (onlineFriends.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${onlineFriends.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showFriendsDialog(context, ref),
        ),
        // 내 상태 표시
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getStatusColor(myStatus),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return Colors.green;
      case OnlineStatus.studying:
        return Colors.blue;
      case OnlineStatus.rest:
        return Colors.orange;
      case OnlineStatus.offline:
        return Colors.grey;
    }
  }
  
  void _showFriendsDialog(BuildContext context, WidgetRef ref) {
    final friends = ref.read(socialProvider);
    final myStatus = ref.read(myStatusProvider);
    final myActivity = ref.read(myActivityProvider);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
          width: 420,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('친구 목록', style: AppTypography.titleLarge),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () => _showAddFriendDialog(context, ref),
                              tooltip: '친구 추가',
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.verticalGapMD,
                    // 내 상태 설정
                    _buildMyStatusSection(context, ref, myStatus, myActivity),
                  ],
                ),
              ),
              
              // 친구 목록
              Flexible(
                child: friends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            AppSpacing.verticalGapMD,
                            Text(
                              '아직 친구가 없습니다',
                              style: AppTypography.body.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            AppSpacing.verticalGapSM,
                            ElevatedButton.icon(
                              onPressed: () => _showAddFriendDialog(context, ref),
                              icon: const Icon(Icons.person_add),
                              label: const Text('친구 추가하기'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          return _buildFriendTile(context, ref, friend);
                        },
                      ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMyStatusSection(BuildContext context, WidgetRef ref, OnlineStatus myStatus, String? myActivity) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('내 상태', style: AppTypography.titleSmall),
          AppSpacing.verticalGapSM,
          Row(
            children: [
              // 상태 선택
              DropdownButton<OnlineStatus>(
                value: myStatus,
                isDense: true,
                onChanged: (status) {
                  if (status != null) {
                    ref.read(myStatusProvider.notifier).state = status;
                    if (status != OnlineStatus.studying) {
                      ref.read(myActivityProvider.notifier).state = null;
                    }
                  }
                },
                items: OnlineStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 8),
                        Text(_getStatusText(status)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              
              // 공부 중일 때 활동 입력
              if (myStatus == OnlineStatus.studying) ...[
                AppSpacing.horizontalMd,
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '무엇을 공부하고 있나요?',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      ref.read(myActivityProvider.notifier).state = value.isEmpty ? null : value;
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFriendTile(BuildContext context, WidgetRef ref, Friend friend) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              friend.name[0],
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: friend.statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(friend.name),
              const SizedBox(width: 4),
              Text(
                'Lv.${friend.level}',
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (friend.streak > 7) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.orange,
                ),
                Text(
                  '${friend.streak}',
                  style: AppTypography.caption.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          if (friend.title != null) ...[
            const SizedBox(height: 2),
            Text(
              friend.title!,
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (friend.grade != null || friend.studyGoal != null) ...[
            Text(
              '${friend.grade ?? ''} ${friend.studyGoal != null ? '• ${friend.studyGoal}' : ''}'.trim(),
              style: AppTypography.caption.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          Row(
            children: [
              Icon(
                friend.statusIcon,
                size: 12,
                color: friend.statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                friend.statusText,
                style: AppTypography.caption.copyWith(
                  color: friend.statusColor,
                ),
              ),
              if (friend.status == OnlineStatus.offline) ...[
                Text(
                  ' • ${friend.lastSeenText}',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
          if (friend.status == OnlineStatus.studying || friend.status == OnlineStatus.rest)
            Text(
              '오늘 ${friend.todayStudyMinutes}분 공부',
              style: AppTypography.caption,
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'remove') {
            ref.read(socialProvider.notifier).removeFriend(friend.id);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text('프로필 보기'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'message',
            child: Row(
              children: [
                Icon(Icons.message),
                SizedBox(width: 8),
                Text('메시지 보내기'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.person_remove, color: Colors.red),
                SizedBox(width: 8),
                Text('친구 삭제', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '친구 코드 또는 이메일',
                hintText: '친구의 고유 코드나 이메일을 입력하세요',
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            AppSpacing.verticalGapMD,
            Text(
              '내 친구 코드: HYLE2024${DateTime.now().millisecondsSinceEpoch % 1000}',
              style: AppTypography.caption,
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
              if (controller.text.isNotEmpty) {
                // 임시로 새 친구 추가
                ref.read(socialProvider.notifier).addFriend(
                  Friend(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: '새로운 친구',
                    status: OnlineStatus.online,
                    lastSeen: DateTime.now(),
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('친구 요청을 보냈습니다')),
                );
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return Icons.circle;
      case OnlineStatus.studying:
        return Icons.menu_book;
      case OnlineStatus.rest:
        return Icons.coffee;
      case OnlineStatus.offline:
        return Icons.circle_outlined;
    }
  }
  
  String _getStatusText(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return '온라인';
      case OnlineStatus.studying:
        return '공부 중';
      case OnlineStatus.rest:
        return '휴식 중';
      case OnlineStatus.offline:
        return '오프라인';
    }
  }
}