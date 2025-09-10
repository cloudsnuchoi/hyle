import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_models.dart';

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<StudyEvent>>((ref) {
  return ScheduleNotifier();
});

final calendarViewProvider = StateProvider<CalendarView>((ref) => CalendarView.week);

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class ScheduleNotifier extends StateNotifier<List<StudyEvent>> {
  ScheduleNotifier() : super([]) {
    _loadSampleEvents();
  }
  
  void _loadSampleEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    state = [
      // 오늘 일정
      StudyEvent(
        id: '1',
        title: '미적분학 복습',
        subject: 'Math',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 11)),
        color: Colors.blue,
        description: 'Chapter 3: 적분법',
      ),
      StudyEvent(
        id: '2',
        title: '영어 단어 암기',
        subject: 'English',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 15)),
        color: Colors.purple,
        description: 'TOEIC 빈출 단어 100개',
      ),
      StudyEvent(
        id: '3',
        title: '물리학 문제풀이',
        subject: 'Science',
        startTime: today.add(const Duration(hours: 16)),
        endTime: today.add(const Duration(hours: 18)),
        color: Colors.green,
        isCompleted: true,
      ),
      
      // 내일 일정
      StudyEvent(
        id: '4',
        title: '한국사 정리',
        subject: 'History',
        startTime: today.add(const Duration(days: 1, hours: 10)),
        endTime: today.add(const Duration(days: 1, hours: 12)),
        color: Colors.orange,
      ),
      StudyEvent(
        id: '5',
        title: '프로그래밍 실습',
        subject: 'Computer',
        startTime: today.add(const Duration(days: 1, hours: 15)),
        endTime: today.add(const Duration(days: 1, hours: 17)),
        color: Colors.indigo,
      ),
      
      // 모레 일정
      StudyEvent(
        id: '6',
        title: '모의고사',
        subject: 'Test',
        startTime: today.add(const Duration(days: 2, hours: 9)),
        endTime: today.add(const Duration(days: 2, hours: 12)),
        color: Colors.red,
      ),
    ];
  }
  
  void addEvent(StudyEvent event) {
    // 새로운 리스트를 생성하여 state 변경을 보장
    final newState = List<StudyEvent>.from(state);
    newState.add(event);
    state = newState;
  }
  
  void updateEvent(String id, StudyEvent updated) {
    // 새로운 리스트를 생성하여 state 변경을 보장
    final newState = state.map((event) {
      return event.id == id ? updated : event;
    }).toList();
    state = newState;
  }
  
  void deleteEvent(String id) {
    // 새로운 리스트를 생성하여 state 변경을 보장
    final newState = state.where((event) => event.id != id).toList();
    state = newState;
  }
  
  void toggleComplete(String id) {
    state = state.map((event) {
      if (event.id == id) {
        return event.copyWith(isCompleted: !event.isCompleted);
      }
      return event;
    }).toList();
  }
  
  List<StudyEvent> getEventsForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    
    return state.where((event) {
      return event.startTime.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
             event.startTime.isBefore(dayEnd);
    }).toList();
  }
  
  List<StudyEvent> getEventsForRange(DateTime start, DateTime end) {
    return state.where((event) {
      return event.startTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
             event.startTime.isBefore(end);
    }).toList();
  }
}