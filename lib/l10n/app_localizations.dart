import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'dashboard': 'Dashboard',
      'todo': 'Todo',
      'timer': 'Timer',
      'notes': 'Notes',
      'profile': 'Profile',
      
      // Home Screen
      'quests': 'Quests',
      'viewAll': 'View All',
      'acceptQuest': 'Accept Quest',
      'available': 'Available',
      'completed': 'Completed',
      'claimReward': 'Claim Reward',
      'questAccepted': 'Quest accepted!',
      'rewardClaimed': 'Reward claimed!',
      'dailyQuestLimit': 'Daily quest limit',
      'weeklyQuestLimit': 'Weekly quest limit',
      'cannotAcceptQuest': 'Cannot accept quest',
      'noAvailableQuests': 'No available quests!',
      'allQuests': 'All Quests',
      'dailyQuests': 'Daily Quests',
      'weeklyQuests': 'Weekly Quests',
      'specialQuests': 'Special Quests',
      
      // D-Day
      'dday': 'D-Day',
      'addDDay': 'Add D-Day',
      'editDDay': 'Edit D-Day',
      'deleteDDay': 'Delete D-Day',
      'title': 'Title',
      'date': 'Date',
      'color': 'Color',
      'icon': 'Icon',
      'importantDDay': 'Important D-Day',
      'showOnHomeScreen': 'Show on home screen',
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'close': 'Close',
      
      // Todo
      'addTodo': 'Add Todo',
      'editTodo': 'Edit Todo',
      'todoTitle': 'Todo Title',
      'selectCategory': 'Select Category',
      'estimatedTime': 'Estimated Time',
      'minutes': 'minutes',
      'priority': 'Priority',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
      'categories': 'Categories',
      'manageCategories': 'Manage Categories',
      
      // Timer
      'startTimer': 'Start',
      'pauseTimer': 'Pause',
      'stopTimer': 'Stop',
      'focusTime': 'Focus Time',
      'breakTime': 'Break Time',
      'pomodoro': 'Pomodoro',
      'settings': 'Settings',
      
      // Profile
      'myProfile': 'My Profile',
      'level': 'Level',
      'totalXP': 'Total XP',
      'coins': 'Coins',
      'studyStreak': 'Study Streak',
      'days': 'days',
      'achievements': 'Achievements',
      'statistics': 'Statistics',
      'logout': 'Logout',
      
      // Settings
      'settings': 'Settings',
      'language': 'Language',
      'korean': 'Korean',
      'english': 'English',
      'theme': 'Theme',
      'notifications': 'Notifications',
      'about': 'About',
      
      // Common
      'save': 'Save',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Info',
      'loading': 'Loading...',
      'noData': 'No data',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'tomorrow': 'Tomorrow',
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
    },
    'ko': {
      // Navigation
      'dashboard': '대시보드',
      'todo': '할 일',
      'timer': '타이머',
      'notes': '노트',
      'profile': '프로필',
      
      // Home Screen
      'quests': '퀘스트',
      'viewAll': '모두 보기',
      'acceptQuest': '퀘스트 수락',
      'available': '수락 가능',
      'completed': '완료!',
      'claimReward': '보상 받기',
      'questAccepted': '퀘스트를 수락했습니다!',
      'rewardClaimed': '보상을 받았습니다!',
      'dailyQuestLimit': '일일 퀘스트 제한',
      'weeklyQuestLimit': '주간 퀘스트 제한',
      'cannotAcceptQuest': '퀘스트를 수락할 수 없습니다',
      'noAvailableQuests': '사용 가능한 퀘스트가 없습니다!',
      'allQuests': '전체 퀘스트',
      'dailyQuests': '일일 퀘스트',
      'weeklyQuests': '주간 퀘스트',
      'specialQuests': '특별 퀘스트',
      
      // D-Day
      'dday': 'D-Day',
      'addDDay': 'D-Day 추가',
      'editDDay': 'D-Day 수정',
      'deleteDDay': 'D-Day 삭제',
      'title': '제목',
      'date': '날짜',
      'color': '색상',
      'icon': '아이콘',
      'importantDDay': '중요한 D-Day',
      'showOnHomeScreen': '홈 화면에 표시됩니다',
      'add': '추가',
      'edit': '수정',
      'delete': '삭제',
      'cancel': '취소',
      'close': '닫기',
      
      // Todo
      'addTodo': '할 일 추가',
      'editTodo': '할 일 수정',
      'todoTitle': '할 일 제목',
      'selectCategory': '카테고리 선택',
      'estimatedTime': '예상 시간',
      'minutes': '분',
      'priority': '우선순위',
      'high': '높음',
      'medium': '보통',
      'low': '낮음',
      'categories': '카테고리',
      'manageCategories': '카테고리 관리',
      
      // Timer
      'startTimer': '시작',
      'pauseTimer': '일시정지',
      'stopTimer': '정지',
      'focusTime': '집중 시간',
      'breakTime': '휴식 시간',
      'pomodoro': '뽀모도로',
      'settings': '설정',
      
      // Profile
      'myProfile': '내 프로필',
      'level': '레벨',
      'totalXP': '총 XP',
      'coins': '코인',
      'studyStreak': '연속 학습',
      'days': '일',
      'achievements': '업적',
      'statistics': '통계',
      'logout': '로그아웃',
      
      // Settings
      'settings': '설정',
      'language': '언어',
      'korean': '한국어',
      'english': '영어',
      'theme': '테마',
      'notifications': '알림',
      'about': '정보',
      
      // Common
      'save': '저장',
      'confirm': '확인',
      'yes': '예',
      'no': '아니오',
      'ok': '확인',
      'error': '오류',
      'success': '성공',
      'warning': '경고',
      'info': '정보',
      'loading': '로딩 중...',
      'noData': '데이터 없음',
      'today': '오늘',
      'yesterday': '어제',
      'tomorrow': '내일',
      'week': '주',
      'month': '월',
      'year': '년',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Navigation
  String get dashboard => get('dashboard');
  String get todo => get('todo');
  String get timer => get('timer');
  String get notes => get('notes');
  String get profile => get('profile');
  
  // Home Screen
  String get quests => get('quests');
  String get viewAll => get('viewAll');
  String get acceptQuest => get('acceptQuest');
  String get available => get('available');
  String get completed => get('completed');
  String get claimReward => get('claimReward');
  String get questAccepted => get('questAccepted');
  String get rewardClaimed => get('rewardClaimed');
  String get dailyQuestLimit => get('dailyQuestLimit');
  String get weeklyQuestLimit => get('weeklyQuestLimit');
  String get cannotAcceptQuest => get('cannotAcceptQuest');
  String get noAvailableQuests => get('noAvailableQuests');
  String get allQuests => get('allQuests');
  String get dailyQuests => get('dailyQuests');
  String get weeklyQuests => get('weeklyQuests');
  String get specialQuests => get('specialQuests');
  
  // D-Day
  String get dday => get('dday');
  String get addDDay => get('addDDay');
  String get editDDay => get('editDDay');
  String get deleteDDay => get('deleteDDay');
  String get title => get('title');
  String get date => get('date');
  String get color => get('color');
  String get icon => get('icon');
  String get importantDDay => get('importantDDay');
  String get showOnHomeScreen => get('showOnHomeScreen');
  String get add => get('add');
  String get edit => get('edit');
  String get delete => get('delete');
  String get cancel => get('cancel');
  String get close => get('close');
  
  // Settings
  String get settings => get('settings');
  String get language => get('language');
  String get korean => get('korean');
  String get english => get('english');
  String get theme => get('theme');
  String get notifications => get('notifications');
  String get about => get('about');
  
  // Common
  String get save => get('save');
  String get loading => get('loading');
  String get today => get('today');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}