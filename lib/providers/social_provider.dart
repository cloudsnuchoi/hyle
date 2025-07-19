import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';

class SocialNotifier extends StateNotifier<List<Friend>> {
  SocialNotifier() : super(_getDefaultFriends());
  
  static List<Friend> _getDefaultFriends() {
    final now = DateTime.now();
    return [
      Friend(
        id: '1',
        name: '김민수',
        status: OnlineStatus.studying,
        currentActivity: '수학 - 미적분',
        todayStudyMinutes: 120,
        streak: 15,
        lastSeen: now,
        level: 12,
        grade: '고3',
        studyGoal: '수능',
        title: '🔥 열정왕',
      ),
      Friend(
        id: '2',
        name: '이서연',
        status: OnlineStatus.studying,
        currentActivity: '영어 단어 암기',
        todayStudyMinutes: 85,
        streak: 7,
        lastSeen: now,
        level: 8,
        grade: '고2',
        studyGoal: '내신',
        title: '📚 꾸준함의 정석',
      ),
      Friend(
        id: '3',
        name: '박준호',
        status: OnlineStatus.rest,
        todayStudyMinutes: 95,
        streak: 3,
        lastSeen: now.subtract(const Duration(minutes: 5)),
        level: 5,
        grade: '중3',
        studyGoal: '고입',
        title: '🌱 새싹',
      ),
      Friend(
        id: '4',
        name: '최지은',
        status: OnlineStatus.online,
        todayStudyMinutes: 60,
        streak: 12,
        lastSeen: now.subtract(const Duration(minutes: 10)),
        level: 10,
        grade: '고1',
        studyGoal: '내신',
        title: '⭐ 우등생',
      ),
      Friend(
        id: '5',
        name: '정하윤',
        status: OnlineStatus.offline,
        todayStudyMinutes: 150,
        streak: 30,
        lastSeen: now.subtract(const Duration(hours: 2)),
        level: 20,
        grade: '고3',
        studyGoal: '수능',
        title: '👑 공부의 신',
      ),
    ];
  }
  
  void updateFriendStatus(String friendId, OnlineStatus status, [String? activity]) {
    state = state.map((friend) {
      if (friend.id == friendId) {
        return friend.copyWith(
          status: status,
          currentActivity: activity,
          lastSeen: DateTime.now(),
        );
      }
      return friend;
    }).toList();
  }
  
  void addFriend(Friend friend) {
    state = [...state, friend];
  }
  
  void removeFriend(String friendId) {
    state = state.where((f) => f.id != friendId).toList();
  }
  
  List<Friend> getOnlineFriends() {
    return state.where((f) => f.status != OnlineStatus.offline).toList();
  }
  
  List<Friend> getStudyingFriends() {
    return state.where((f) => f.status == OnlineStatus.studying).toList();
  }
}

// Providers
final socialProvider = StateNotifierProvider<SocialNotifier, List<Friend>>(
  (ref) => SocialNotifier(),
);

final onlineFriendsProvider = Provider<List<Friend>>((ref) {
  final friends = ref.watch(socialProvider);
  return friends.where((f) => f.status != OnlineStatus.offline).toList();
});

final studyingFriendsProvider = Provider<List<Friend>>((ref) {
  final friends = ref.watch(socialProvider);
  return friends.where((f) => f.status == OnlineStatus.studying).toList();
});

// 내 상태 관리
final myStatusProvider = StateProvider<OnlineStatus>((ref) => OnlineStatus.online);
final myActivityProvider = StateProvider<String?>((ref) => null);