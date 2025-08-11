import 'package:equatable/equatable.dart';

class ReadingSettings extends Equatable {
  final bool showEstimatedReadingTime;
  final bool showReadingTimer;
  final double fontSize;
  final double lineHeight;
  final int wordsPerMinute;

  const ReadingSettings({
    this.showEstimatedReadingTime = true,
    this.showReadingTimer = true,
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.wordsPerMinute = 200,
  });

  ReadingSettings copyWith({
    bool? showEstimatedReadingTime,
    bool? showReadingTimer,
    double? fontSize,
    double? lineHeight,
    int? wordsPerMinute,
  }) {
    return ReadingSettings(
      showEstimatedReadingTime: showEstimatedReadingTime ?? this.showEstimatedReadingTime,
      showReadingTimer: showReadingTimer ?? this.showReadingTimer,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      wordsPerMinute: wordsPerMinute ?? this.wordsPerMinute,
    );
  }

  @override
  List<Object> get props => [
        showEstimatedReadingTime,
        showReadingTimer,
        fontSize,
        lineHeight,
        wordsPerMinute,
      ];

  Map<String, dynamic> toJson() {
    return {
      'showEstimatedReadingTime': showEstimatedReadingTime,
      'showReadingTimer': showReadingTimer,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'wordsPerMinute': wordsPerMinute,
    };
  }

  factory ReadingSettings.fromJson(Map<String, dynamic> json) {
    return ReadingSettings(
      showEstimatedReadingTime: json['showEstimatedReadingTime'] ?? true,
      showReadingTimer: json['showReadingTimer'] ?? true,
      fontSize: json['fontSize'] ?? 16.0,
      lineHeight: json['lineHeight'] ?? 1.5,
      wordsPerMinute: json['wordsPerMinute'] ?? 200,
    );
  }
}
