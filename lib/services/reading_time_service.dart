import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingTimeService {
  final SharedPreferences _prefs;
  Timer? _timer;
  DateTime? _sessionStartTime;
  String? _currentBookId;
  int _sessionTime = 0;

  ReadingTimeService(this._prefs);

  void startReadingSession(String bookId) {
    if (_currentBookId == bookId && _timer?.isActive == true) {
      return; // Already tracking this book
    }

    stopReadingSession();
    
    _currentBookId = bookId;
    _sessionStartTime = DateTime.now();
    _sessionTime = 0;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionTime++;
    });
  }

  void stopReadingSession() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
      
      if (_currentBookId != null && _sessionStartTime != null) {
        _saveReadingTime(_currentBookId!, _sessionTime);
      }
    }
    
    _currentBookId = null;
    _sessionStartTime = null;
    _sessionTime = 0;
  }

  void pauseReadingSession() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
      
      if (_currentBookId != null) {
        _saveReadingTime(_currentBookId!, _sessionTime);
      }
    }
  }

  void resumeReadingSession() {
    if (_currentBookId != null && _timer?.isActive != true) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _sessionTime++;
      });
    }
  }

  int get currentSessionTime => _sessionTime;

  int getTotalReadingTime(String bookId) {
    final timeStr = _prefs.getString('reading_time_$bookId');
    if (timeStr == null) return 0;
    
    try {
      final data = jsonDecode(timeStr) as Map<String, dynamic>;
      return data['totalTime'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Map<int, int> getChapterReadingTimes(String bookId) {
    final timeStr = _prefs.getString('reading_time_$bookId');
    if (timeStr == null) return {};
    
    try {
      final data = jsonDecode(timeStr) as Map<String, dynamic>;
      final chapterTimes = data['chapterTimes'] as Map<String, dynamic>?;
      if (chapterTimes == null) return {};
      
      return chapterTimes.map((key, value) => MapEntry(int.parse(key), value as int));
    } catch (e) {
      return {};
    }
  }

  void _saveReadingTime(String bookId, int additionalTime) {
    final existingTimeStr = _prefs.getString('reading_time_$bookId');
    Map<String, dynamic> data = {};
    
    if (existingTimeStr != null) {
      try {
        data = jsonDecode(existingTimeStr) as Map<String, dynamic>;
      } catch (e) {
        data = {};
      }
    }
    
    final currentTotal = data['totalTime'] ?? 0;
    data['totalTime'] = currentTotal + additionalTime;
    data['lastUpdated'] = DateTime.now().toIso8601String();
    
    _prefs.setString('reading_time_$bookId', jsonEncode(data));
  }

  void addChapterReadingTime(String bookId, int chapterIndex, int time) {
    final existingTimeStr = _prefs.getString('reading_time_$bookId');
    Map<String, dynamic> data = {};
    
    if (existingTimeStr != null) {
      try {
        data = jsonDecode(existingTimeStr) as Map<String, dynamic>;
      } catch (e) {
        data = {};
      }
    }
    
    final chapterTimes = data['chapterTimes'] as Map<String, dynamic>? ?? {};
    final currentChapterTime = chapterTimes[chapterIndex.toString()] ?? 0;
    chapterTimes[chapterIndex.toString()] = currentChapterTime + time;
    
    data['chapterTimes'] = chapterTimes;
    _prefs.setString('reading_time_$bookId', jsonEncode(data));
  }

  String formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0 ? '${minutes}m ${remainingSeconds}s' : '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}
