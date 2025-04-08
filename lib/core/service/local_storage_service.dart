import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String READING_PROGRESS_KEY = 'reading_progress';

  // Lưu tiến độ đọc vào local storage
  Future<void> saveReadingProgress(
      String documentId,
      double progress,
      int? lastPage,
      String? lastPosition,
      DateTime lastReadTime,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readingData = {
        'progress': progress,
        'lastPage': lastPage,
        'lastPosition': lastPosition,
        'lastReadTime': lastReadTime.toIso8601String(),
      };

      // Lấy dữ liệu hiện có
      final String? storedData = prefs.getString(READING_PROGRESS_KEY);
      Map<String, dynamic> allReadingProgress = {};

      if (storedData != null) {
        allReadingProgress = json.decode(storedData);
      }

      // Cập nhật dữ liệu mới
      allReadingProgress[documentId] = readingData;

      // Lưu lại
      await prefs.setString(READING_PROGRESS_KEY, json.encode(allReadingProgress));
    } catch (e) {
      print('Error saving reading progress to local storage: $e');
    }
  }

  // Lấy tiến độ đọc từ local storage
  Future<Map<String, dynamic>?> getReadingProgress(String documentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(READING_PROGRESS_KEY);

      if (storedData != null) {
        final Map<String, dynamic> allReadingProgress = json.decode(storedData);
        return allReadingProgress[documentId];
      }

      return null;
    } catch (e) {
      print('Error getting reading progress from local storage: $e');
      return null;
    }
  }
}