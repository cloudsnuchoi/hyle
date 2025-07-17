import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// Friends Provider
final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier();
});

class FriendsState {
  final List<FriendData> friends;
  final List<FriendData> pendingRequests;
  final List<FriendData> sentRequests;
  final bool isLoading;
  final String? error;

  FriendsState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.sentRequests = const [],
    this.isLoading = false,
    this.error,
  });

  FriendsState copyWith({
    List<FriendData>? friends,
    List<FriendData>? pendingRequests,
    List<FriendData>? sentRequests,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  FriendsNotifier() : super(FriendsState()) {
    // Load mock data
    _loadFriends();
  }

  void _loadFriends() {
    // Mock data
    state = state.copyWith(
      friends: [
        FriendData(
          id: '1',
          name: 'Sarah Kim',
          status: 'Studying Math 📐',
          isOnline: true,
          currentActivity: StudyActivity(
            subject: 'Math',
            duration: const Duration(minutes: 45),
            type: 'Pomodoro',
          ),
          level: 23,
          streak: 15,
          profileImage: '👩‍🎓',
        ),
        FriendData(
          id: '2',
          name: 'John Park',
          status: 'Taking a break ☕',
          isOnline: true,
          currentActivity: null,
          level: 18,
          streak: 7,
          profileImage: '👨‍💻',
        ),
        FriendData(
          id: '3',
          name: 'Emily Chen',
          status: 'Offline',
          isOnline: false,
          currentActivity: null,
          level: 31,
          streak: 23,
          profileImage: '👩‍🔬',
          lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      pendingRequests: [
        FriendData(
          id: '4',
          name: 'David Lee',
          status: 'New student',
          isOnline: true,
          level: 5,
          streak: 2,
          profileImage: '🧑‍🎓',
        ),
      ],
    );
  }

  void acceptFriendRequest(String friendId) {
    final friend = state.pendingRequests.firstWhere((f) => f.id == friendId);
    state = state.copyWith(
      friends: [...state.friends, friend],
      pendingRequests: state.pendingRequests.where((f) => f.id != friendId).toList(),
    );
  }

  void declineFriendRequest(String friendId) {
    state = state.copyWith(
      pendingRequests: state.pendingRequests.where((f) => f.id != friendId).toList(),
    );
  }
}

// Data models
class FriendData {
  final String id;
  final String name;
  final String status;
  final bool isOnline;
  final StudyActivity? currentActivity;
  final int level;
  final int streak;
  final String profileImage;
  final DateTime? lastSeen;

  FriendData({
    required this.id,
    required this.name,
    required this.status,
    required this.isOnline,
    this.currentActivity,
    required this.level,
    required this.streak,
    required this.profileImage,
    this.lastSeen,
  });
}

class StudyActivity {
  final String subject;
  final Duration duration;
  final String type;

  StudyActivity({
    required this.subject,
    required this.duration,
    required this.type,
  });
}

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendsProvider);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                // TODO: Show add friend dialog
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Friends'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Friends Tab
            _FriendsTab(friends: state.friends),
            
            // Requests Tab
            _RequestsTab(
              pendingRequests: state.pendingRequests,
              sentRequests: state.sentRequests,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  final List<FriendData> friends;

  const _FriendsTab({required this.friends});

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return _EmptyState(
        icon: Icons.people,
        title: 'No Friends Yet',
        subtitle: 'Add friends to see their study progress!',
      );
    }

    // Sort friends: online first, then by activity
    final sortedFriends = [...friends]..sort((a, b) {
      if (a.isOnline != b.isOnline) {
        return a.isOnline ? -1 : 1;
      }
      if (a.currentActivity != null && b.currentActivity == null) {
        return -1;
      }
      if (a.currentActivity == null && b.currentActivity != null) {
        return 1;
      }
      return 0;
    });

    return ListView.builder(
      padding: AppSpacing.paddingMD,
      itemCount: sortedFriends.length,
      itemBuilder: (context, index) {
        final friend = sortedFriends[index];
        return _FriendCard(friend: friend);
      },
    );
  }
}

class _FriendCard extends StatelessWidget {
  final FriendData friend;

  const _FriendCard({required this.friend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to friend profile
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Profile image with online indicator
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        friend.profileImage,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  if (friend.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              AppSpacing.horizontalGapMD,
              
              // Friend info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          friend.name,
                          style: AppTypography.titleMedium,
                        ),
                        AppSpacing.horizontalGapSM,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv.${friend.level}',
                            style: AppTypography.caption.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    AppSpacing.verticalGapXS,
                    
                    // Status or activity
                    if (friend.currentActivity != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${friend.currentActivity!.subject} • ${_formatDuration(friend.currentActivity!.duration)}',
                            style: AppTypography.caption.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        friend.status,
                        style: AppTypography.caption.copyWith(
                          color: friend.isOnline
                              ? theme.colorScheme.onSurface.withOpacity(0.7)
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                    
                    // Last seen if offline
                    if (!friend.isOnline && friend.lastSeen != null) ...[
                      AppSpacing.verticalGapXS,
                      Text(
                        'Last seen ${_formatLastSeen(friend.lastSeen!)}',
                        style: AppTypography.caption.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Streak indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${friend.streak}',
                      style: AppTypography.caption.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * friend.id.hashCode % 5))
      .slideX(begin: 0.1, end: 0);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _RequestsTab extends ConsumerWidget {
  final List<FriendData> pendingRequests;
  final List<FriendData> sentRequests;

  const _RequestsTab({
    required this.pendingRequests,
    required this.sentRequests,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pendingRequests.isEmpty && sentRequests.isEmpty) {
      return _EmptyState(
        icon: Icons.person_add,
        title: 'No Friend Requests',
        subtitle: 'When someone sends you a friend request, it will appear here',
      );
    }

    return ListView(
      padding: AppSpacing.paddingMD,
      children: [
        // Pending requests
        if (pendingRequests.isNotEmpty) ...[
          Text(
            'Pending Requests',
            style: AppTypography.titleMedium,
          ),
          AppSpacing.verticalGapMD,
          ...pendingRequests.map((request) => _RequestCard(
            friend: request,
            onAccept: () {
              ref.read(friendsProvider.notifier).acceptFriendRequest(request.id);
            },
            onDecline: () {
              ref.read(friendsProvider.notifier).declineFriendRequest(request.id);
            },
          )),
          AppSpacing.verticalGapXL,
        ],
        
        // Sent requests
        if (sentRequests.isNotEmpty) ...[
          Text(
            'Sent Requests',
            style: AppTypography.titleMedium,
          ),
          AppSpacing.verticalGapMD,
          ...sentRequests.map((request) => _SentRequestCard(friend: request)),
        ],
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final FriendData friend;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.friend,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          children: [
            Row(
              children: [
                // Profile image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      friend.profileImage,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                AppSpacing.horizontalGapMD,
                
                // Friend info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        'Level ${friend.level} • ${friend.streak} day streak',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            AppSpacing.verticalGapMD,
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),
                AppSpacing.horizontalGapMD,
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0);
  }
}

class _SentRequestCard extends StatelessWidget {
  final FriendData friend;

  const _SentRequestCard({required this.friend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              friend.profileImage,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(friend.name),
        subtitle: Text('Level ${friend.level}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Pending',
            style: AppTypography.caption,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          AppSpacing.verticalGapMD,
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          AppSpacing.verticalGapSM,
          Text(
            subtitle,
            style: AppTypography.body.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}