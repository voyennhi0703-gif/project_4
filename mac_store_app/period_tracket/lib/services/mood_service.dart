import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_data.dart';

class MoodService {
  static const String _moodDataKey = 'mood_data_history';

  // Lưu dữ liệu mood
  static Future<void> saveMoodData(MoodData moodData) async {
    final prefs = await SharedPreferences.getInstance();
    List<MoodData> moodHistory = await getMoodHistory();

    // Xóa dữ liệu cũ của ngày hiện tại nếu có
    moodHistory.removeWhere(
      (mood) =>
          mood.date.day == moodData.date.day &&
          mood.date.month == moodData.date.month &&
          mood.date.year == moodData.date.year,
    );

    // Thêm dữ liệu mới
    moodHistory.add(moodData);

    // Lưu vào SharedPreferences
    final jsonList = moodHistory.map((mood) => mood.toJson()).toList();
    await prefs.setString(_moodDataKey, jsonEncode(jsonList));
  }

  // Lấy lịch sử mood
  static Future<List<MoodData>> getMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_moodDataKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => MoodData.fromJson(json)).toList();
  }

  // Lấy mood của ngày cụ thể
  static Future<MoodData?> getMoodForDate(DateTime date) async {
    final moodHistory = await getMoodHistory();
    return moodHistory
        .where(
          (mood) =>
              mood.date.day == date.day &&
              mood.date.month == date.month &&
              mood.date.year == date.year,
        )
        .firstOrNull;
  }

  // Lấy thống kê mood
  static Future<Map<String, int>> getMoodStatistics() async {
    final moodHistory = await getMoodHistory();
    Map<String, int> stats = {};

    for (var moodData in moodHistory) {
      for (var mood in moodData.selectedMoods) {
        stats[mood] = (stats[mood] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Lấy xu hướng mood theo tuần
  static Future<List<Map<String, dynamic>>> getWeeklyMoodTrend() async {
    final moodHistory = await getMoodHistory();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    List<Map<String, dynamic>> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayMood = moodHistory
          .where(
            (mood) =>
                mood.date.day == date.day &&
                mood.date.month == date.month &&
                mood.date.year == date.year,
          )
          .firstOrNull;

      weeklyData.add({
        'date': date,
        'moodCount': dayMood?.selectedMoods.length ?? 0,
        'hasData': dayMood != null,
      });
    }

    return weeklyData;
  }

  // Lấy thống kê triệu chứng
  static Future<Map<String, int>> getSymptomStatistics() async {
    final moodHistory = await getMoodHistory();
    Map<String, int> stats = {};

    for (var moodData in moodHistory) {
      for (var symptom in moodData.selectedSymptoms) {
        stats[symptom] = (stats[symptom] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Lấy xu hướng tháng
  static Future<List<Map<String, dynamic>>> getMonthlyMoodTrend() async {
    final moodHistory = await getMoodHistory();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    List<Map<String, dynamic>> monthlyData = [];

    for (int week = 1; week <= 4; week++) {
      final weekStart = monthStart.add(Duration(days: (week - 1) * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final hasActivity = moodHistory.any(
        (mood) =>
            mood.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            mood.date.isBefore(weekEnd.add(const Duration(days: 1))),
      );

      monthlyData.add({'week': week, 'hasActivity': hasActivity});
    }

    return monthlyData;
  }

  // Lấy mood gần đây
  static Future<List<MoodData>> getRecentMoods(int days) async {
    final moodHistory = await getMoodHistory();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return moodHistory.where((mood) => mood.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
