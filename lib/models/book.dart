import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final int totalPages;
  final int currentPage;
  final double readingProgress;
  final int totalReadingTime; // in seconds
  final DateTime? lastReadAt;
  final Map<int, int> chapterReadingTimes; // chapter index -> reading time in seconds
  final List<ChapterInfo> chapters;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.totalPages,
    this.currentPage = 0,
    this.readingProgress = 0.0,
    this.totalReadingTime = 0,
    this.lastReadAt,
    this.chapterReadingTimes = const {},
    this.chapters = const [],
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    int? totalPages,
    int? currentPage,
    double? readingProgress,
    int? totalReadingTime,
    DateTime? lastReadAt,
    Map<int, int>? chapterReadingTimes,
    List<ChapterInfo>? chapters,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      readingProgress: readingProgress ?? this.readingProgress,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      chapterReadingTimes: chapterReadingTimes ?? this.chapterReadingTimes,
      chapters: chapters ?? this.chapters,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        filePath,
        totalPages,
        currentPage,
        readingProgress,
        totalReadingTime,
        lastReadAt,
        chapterReadingTimes,
        chapters,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'filePath': filePath,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'readingProgress': readingProgress,
      'totalReadingTime': totalReadingTime,
      'lastReadAt': lastReadAt?.toIso8601String(),
      'chapterReadingTimes': chapterReadingTimes,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      filePath: json['filePath'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'] ?? 0,
      readingProgress: json['readingProgress'] ?? 0.0,
      totalReadingTime: json['totalReadingTime'] ?? 0,
      lastReadAt: json['lastReadAt'] != null 
          ? DateTime.parse(json['lastReadAt']) 
          : null,
      chapterReadingTimes: Map<int, int>.from(json['chapterReadingTimes'] ?? {}),
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((c) => ChapterInfo.fromJson(c))
          .toList() ?? [],
    );
  }
}

class ChapterInfo extends Equatable {
  final int index;
  final String title;
  final int startPage;
  final int endPage;
  final int wordCount;

  const ChapterInfo({
    required this.index,
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.wordCount,
  });

  @override
  List<Object> get props => [index, title, startPage, endPage, wordCount];

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'title': title,
      'startPage': startPage,
      'endPage': endPage,
      'wordCount': wordCount,
    };
  }

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      index: json['index'],
      title: json['title'],
      startPage: json['startPage'],
      endPage: json['endPage'],
      wordCount: json['wordCount'],
    );
  }
}
