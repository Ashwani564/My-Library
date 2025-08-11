import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_settings.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateEstimatedReadingTimeVisibility extends SettingsEvent {
  final bool show;

  const UpdateEstimatedReadingTimeVisibility(this.show);

  @override
  List<Object> get props => [show];
}

class UpdateReadingTimerVisibility extends SettingsEvent {
  final bool show;

  const UpdateReadingTimerVisibility(this.show);

  @override
  List<Object> get props => [show];
}

class UpdateFontSize extends SettingsEvent {
  final double fontSize;

  const UpdateFontSize(this.fontSize);

  @override
  List<Object> get props => [fontSize];
}

class UpdateLineHeight extends SettingsEvent {
  final double lineHeight;

  const UpdateLineHeight(this.lineHeight);

  @override
  List<Object> get props => [lineHeight];
}

class UpdateWordsPerMinute extends SettingsEvent {
  final int wordsPerMinute;

  const UpdateWordsPerMinute(this.wordsPerMinute);

  @override
  List<Object> get props => [wordsPerMinute];
}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ReadingSettings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object> get props => [settings];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;
  static const String _settingsKey = 'reading_settings';

  SettingsBloc(this._prefs) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateEstimatedReadingTimeVisibility>(_onUpdateEstimatedReadingTimeVisibility);
    on<UpdateReadingTimerVisibility>(_onUpdateReadingTimerVisibility);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateLineHeight>(_onUpdateLineHeight);
    on<UpdateWordsPerMinute>(_onUpdateWordsPerMinute);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    final settingsJson = _prefs.getString(_settingsKey);
    ReadingSettings settings;
    
    if (settingsJson != null) {
      try {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        settings = ReadingSettings.fromJson(settingsMap);
      } catch (e) {
        settings = const ReadingSettings();
      }
    } else {
      settings = const ReadingSettings();
    }
    
    emit(SettingsLoaded(settings));
  }

  void _onUpdateEstimatedReadingTimeVisibility(
    UpdateEstimatedReadingTimeVisibility event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(
        showEstimatedReadingTime: event.show,
      );
      _saveSettings(newSettings);
      emit(SettingsLoaded(newSettings));
    }
  }

  void _onUpdateReadingTimerVisibility(
    UpdateReadingTimerVisibility event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(
        showReadingTimer: event.show,
      );
      _saveSettings(newSettings);
      emit(SettingsLoaded(newSettings));
    }
  }

  void _onUpdateFontSize(UpdateFontSize event, Emitter<SettingsState> emit) {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(fontSize: event.fontSize);
      _saveSettings(newSettings);
      emit(SettingsLoaded(newSettings));
    }
  }

  void _onUpdateLineHeight(UpdateLineHeight event, Emitter<SettingsState> emit) {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(lineHeight: event.lineHeight);
      _saveSettings(newSettings);
      emit(SettingsLoaded(newSettings));
    }
  }

  void _onUpdateWordsPerMinute(UpdateWordsPerMinute event, Emitter<SettingsState> emit) {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(wordsPerMinute: event.wordsPerMinute);
      _saveSettings(newSettings);
      emit(SettingsLoaded(newSettings));
    }
  }

  void _saveSettings(ReadingSettings settings) {
    _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
