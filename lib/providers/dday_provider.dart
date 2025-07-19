import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dday.dart';

class DDayNotifier extends StateNotifier<List<DDay>> {
  DDayNotifier() : super([]) {
    _loadDDays();
  }
  
  static const String _storageKey = 'ddays';
  
  Future<void> _loadDDays() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ddaysJson = prefs.getString(_storageKey);
    
    if (ddaysJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(ddaysJson);
        state = decoded.map((json) => DDay.fromJson(json)).toList();
      } catch (e) {
        state = _getDefaultDDays();
      }
    } else {
      state = _getDefaultDDays();
    }
  }
  
  List<DDay> _getDefaultDDays() {
    return [
      DDay(
        id: '1',
        title: '수능',
        targetDate: DateTime(2024, 11, 14),
        color: Colors.red,
        icon: Icons.school,
        isImportant: true,
      ),
    ];
  }
  
  Future<void> _saveDDays() async {
    final prefs = await SharedPreferences.getInstance();
    final String ddaysJson = jsonEncode(
      state.map((dday) => dday.toJson()).toList(),
    );
    await prefs.setString(_storageKey, ddaysJson);
  }
  
  Future<void> addDDay({
    required String title,
    required DateTime targetDate,
    Color color = Colors.blue,
    IconData icon = Icons.event,
    bool isImportant = false,
  }) async {
    final newDDay = DDay(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetDate: targetDate,
      color: color,
      icon: icon,
      isImportant: isImportant,
    );
    
    state = [...state, newDDay];
    await _saveDDays();
  }
  
  Future<void> updateDDay(DDay dday) async {
    state = state.map((d) => d.id == dday.id ? dday : d).toList();
    await _saveDDays();
  }
  
  Future<void> deleteDDay(String id) async {
    state = state.where((d) => d.id != id).toList();
    await _saveDDays();
  }
  
  // 중요한 D-Day만 가져오기
  List<DDay> getImportantDDays() {
    return state.where((d) => d.isImportant).toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  }
  
  // 가장 가까운 D-Day 가져오기
  DDay? getClosestDDay() {
    if (state.isEmpty) return null;
    
    final sorted = [...state]
      ..sort((a, b) => a.daysLeft.abs().compareTo(b.daysLeft.abs()));
    
    return sorted.first;
  }
}

// Provider
final ddayProvider = StateNotifierProvider<DDayNotifier, List<DDay>>(
  (ref) => DDayNotifier(),
);

// 중요한 D-Day Provider
final importantDDaysProvider = Provider<List<DDay>>((ref) {
  final ddays = ref.watch(ddayProvider);
  return ddays.where((d) => d.isImportant).toList()
    ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
});

// 가장 가까운 D-Day Provider
final closestDDayProvider = Provider<DDay?>((ref) {
  final ddays = ref.watch(ddayProvider);
  if (ddays.isEmpty) return null;
  
  final sorted = [...ddays]
    ..sort((a, b) => a.daysLeft.abs().compareTo(b.daysLeft.abs()));
  
  return sorted.first;
});