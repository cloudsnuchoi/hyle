import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock notifications
  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      type: 'achievement',
      title: '새로운 배지 획득!',
      message: '7일 연속 학습 배지를 획득했습니다 🔥',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    NotificationItem(
      type: 'reminder',
      title: '학습 시간입니다',
      message: '오늘의 수학 레슨을 시작해보세요',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationItem(
      type: 'social',
      title: '친구 요청',
      message: '김철수님이 친구 요청을 보냈습니다',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      type: 'system',
      title: '업데이트 알림',
      message: '새로운 기능이 추가되었습니다',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      type: 'achievement',
      title: '레벨 업!',
      message: '레벨 12를 달성했습니다',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  List<NotificationItem> get _unreadNotifications =>
      _allNotifications.where((n) => !n.isRead).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
              
              // Tabs
              _buildTabs(),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationList(_allNotifications),
                    _buildNotificationList(_unreadNotifications),
                  ],
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
            '알림',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262626), // gray800
            ),
          ),
          const Spacer(),
          if (_unreadNotifications.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444), // red500
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_unreadNotifications.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to notification settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF395886), // primary500
        indicatorWeight: 3,
        labelColor: const Color(0xFF395886),
        unselectedLabelColor: const Color(0xFF737373), // gray500
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: [
          Tab(
            text: '전체',
            icon: _allNotifications.isEmpty
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _unreadNotifications.isNotEmpty
                          ? const Color(0xFFEF4444)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
            iconMargin: const EdgeInsets.only(bottom: 4),
          ),
          Tab(
            text: '읽지 않음',
            icon: _unreadNotifications.isEmpty
                ? null
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_unreadNotifications.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
            iconMargin: const EdgeInsets.only(bottom: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: const Color(0xFFD4D4D4), // gray300
            ),
            const SizedBox(height: 16),
            Text(
              '알림이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF525252), // gray600
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 알림이 오면 여기에 표시됩니다',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF737373), // gray500
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        
        // Add date separator
        bool showDateSeparator = false;
        if (index == 0) {
          showDateSeparator = true;
        } else {
          final prevDate = notifications[index - 1].timestamp;
          final currDate = notification.timestamp;
          showDateSeparator = !_isSameDay(prevDate, currDate);
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateSeparator)
              Padding(
                padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 12),
                child: Text(
                  _getDateLabel(notification.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF737373), // gray500
                  ),
                ),
              ),
            _buildNotificationItem(notification),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    IconData icon;
    Color iconColor;
    Color bgColor;
    
    switch (notification.type) {
      case 'achievement':
        icon = Icons.emoji_events_rounded;
        iconColor = const Color(0xFFFFC107); // amber
        bgColor = const Color(0xFFFFF9C4); // amber50
        break;
      case 'reminder':
        icon = Icons.alarm_rounded;
        iconColor = const Color(0xFF638ECB); // primary400
        bgColor = const Color(0xFFF0F3FA); // primary50
        break;
      case 'social':
        icon = Icons.people_rounded;
        iconColor = const Color(0xFF10B981); // green500
        bgColor = const Color(0xFFD1FAE5); // green100
        break;
      case 'system':
        icon = Icons.info_rounded;
        iconColor = const Color(0xFF737373); // gray500
        bgColor = const Color(0xFFF5F5F5); // gray100
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = const Color(0xFF638ECB);
        bgColor = const Color(0xFFF0F3FA);
    }

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead 
            ? Colors.white.withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead 
            ? null 
            : Border.all(
                color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              notification.isRead = true;
            });
            // Handle notification tap
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead 
                                    ? FontWeight.w600 
                                    : FontWeight.bold,
                                color: const Color(0xFF262626), // gray800
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444), // red500
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: notification.isRead
                              ? const Color(0xFF737373) // gray500
                              : const Color(0xFF525252), // gray600
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTimeAgo(notification.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF737373), // gray500
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Color(0xFF737373),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      setState(() {
                        _allNotifications.remove(notification);
                      });
                    } else if (value == 'mark_read') {
                      setState(() {
                        notification.isRead = true;
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    if (!notification.isRead)
                      const PopupMenuItem(
                        value: 'mark_read',
                        child: Text('읽음으로 표시'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('삭제'),
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return '오늘';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return '어제';
    } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
      return '이번 주';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.month}월 ${timestamp.day}일';
    }
  }
}

class NotificationItem {
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}