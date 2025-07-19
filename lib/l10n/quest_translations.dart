// Quest titles and descriptions translations
class QuestTranslations {
  static const Map<String, Map<String, String>> questTexts = {
    'en': {
      // Daily Quests
      'daily_study_1_title': 'First Step',
      'daily_study_1_desc': 'Study for 30 minutes or more today',
      'daily_todo_1_title': 'Task Master',
      'daily_todo_1_desc': 'Complete 3 or more tasks today',
      'daily_pomodoro_1_title': 'Focus Master',
      'daily_pomodoro_1_desc': 'Complete 2 Pomodoro cycles',
      
      // Weekly Quests
      'weekly_study_1_title': 'Consistent Learner',
      'weekly_study_1_desc': 'Study for 10 hours or more this week',
      'weekly_streak_1_title': 'Streak Challenge',
      'weekly_streak_1_desc': 'Study for 5 consecutive days',
      
      // Special Quests
      'special_note_1_title': 'Knowledge Keeper',
      'special_note_1_desc': 'Create 10 notes this week',
      'special_perfect_1_title': 'Perfect Day',
      'special_perfect_1_desc': 'Achieve 100% of daily goals',
      
      // Quest Types
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
    },
    'ko': {
      // Daily Quests
      'daily_study_1_title': '첫 발걸음',
      'daily_study_1_desc': '오늘 30분 이상 공부하기',
      'daily_todo_1_title': '할 일 마스터',
      'daily_todo_1_desc': '오늘 3개 이상의 할 일 완료하기',
      'daily_pomodoro_1_title': '집중의 달인',
      'daily_pomodoro_1_desc': '뽀모도로 2사이클 완료하기',
      
      // Weekly Quests
      'weekly_study_1_title': '꾸준한 학습자',
      'weekly_study_1_desc': '이번 주 10시간 이상 공부하기',
      'weekly_streak_1_title': '연속 학습 챌린지',
      'weekly_streak_1_desc': '5일 연속 학습하기',
      
      // Special Quests
      'special_note_1_title': '지식 기록자',
      'special_note_1_desc': '이번 주 노트 10개 작성하기',
      'special_perfect_1_title': '완벽한 하루',
      'special_perfect_1_desc': '하루 목표 100% 달성하기',
      
      // Quest Types
      'easy': '쉬움',
      'medium': '보통',
      'hard': '어려움',
    },
  };
  
  static String getQuestTitle(String questId, String languageCode) {
    return questTexts[languageCode]?['${questId}_title'] ?? questId;
  }
  
  static String getQuestDescription(String questId, String languageCode) {
    return questTexts[languageCode]?['${questId}_desc'] ?? questId;
  }
  
  static String getDifficulty(String difficulty, String languageCode) {
    return questTexts[languageCode]?[difficulty] ?? difficulty;
  }
}