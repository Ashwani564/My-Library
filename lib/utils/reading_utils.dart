class ReadingUtils {
  /// Estimates reading time based on word count and reading speed
  static String estimateReadingTime(int wordCount, int wordsPerMinute) {
    final minutes = (wordCount / wordsPerMinute).ceil();
    
    if (minutes < 1) {
      return 'Less than 1 minute';
    } else if (minutes < 60) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return '$hours hour${hours == 1 ? '' : 's'}';
      } else {
        return '$hours hour${hours == 1 ? '' : 's'} $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'}';
      }
    }
  }

  /// Formats duration in seconds to human readable format
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    } else if (totalSeconds < 3600) {
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  /// Calculates reading progress percentage
  static double calculateProgress(int currentPage, int totalPages) {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  /// Estimates pages read per minute based on reading speed
  static double estimatePagesPerMinute(int wordsPerMinute, int averageWordsPerPage) {
    if (averageWordsPerPage <= 0) return 0.0;
    return wordsPerMinute / averageWordsPerPage;
  }

  /// Calculates the average words per page for a book
  static int calculateAverageWordsPerPage(List<int> chapterWordCounts, List<int> chapterPageCounts) {
    if (chapterWordCounts.isEmpty || chapterPageCounts.isEmpty) return 250; // Default estimate
    
    final totalWords = chapterWordCounts.fold<int>(0, (sum, count) => sum + count);
    final totalPages = chapterPageCounts.fold<int>(0, (sum, count) => sum + count);
    
    if (totalPages <= 0) return 250;
    return totalWords ~/ totalPages;
  }

  /// Estimates remaining reading time for current chapter
  static String estimateChapterRemainingTime(
    int currentChapterWordCount,
    double chapterProgress,
    int wordsPerMinute,
  ) {
    final remainingWords = (currentChapterWordCount * (1 - chapterProgress)).round();
    return estimateReadingTime(remainingWords, wordsPerMinute);
  }

  /// Estimates remaining reading time for entire book
  static String estimateBookRemainingTime(
    int totalBookWordCount,
    double bookProgress,
    int wordsPerMinute,
  ) {
    final remainingWords = (totalBookWordCount * (1 - bookProgress)).round();
    return estimateReadingTime(remainingWords, wordsPerMinute);
  }

  /// Converts reading speed from different units
  static int convertReadingSpeed(double speed, String fromUnit, String toUnit) {
    // Convert to words per minute as base unit
    double wpm = speed;
    
    switch (fromUnit.toLowerCase()) {
      case 'wps': // words per second
        wpm = speed * 60;
        break;
      case 'wph': // words per hour
        wpm = speed / 60;
        break;
      case 'ppm': // pages per minute (assuming 250 words per page)
        wpm = speed * 250;
        break;
    }
    
    // Convert from words per minute to target unit
    switch (toUnit.toLowerCase()) {
      case 'wps':
        return (wpm / 60).round();
      case 'wph':
        return (wpm * 60).round();
      case 'ppm':
        return (wpm / 250).round();
      default:
        return wpm.round();
    }
  }

  /// Validates reading speed and returns a reasonable value
  static int validateReadingSpeed(int wordsPerMinute) {
    // Typical reading speeds range from 100-400 WPM
    return wordsPerMinute.clamp(100, 400);
  }
}
