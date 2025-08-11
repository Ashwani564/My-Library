import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:typed_data';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/reading_time_service.dart';

// Events
abstract class ReadingEvent extends Equatable {
  const ReadingEvent();

  @override
  List<Object> get props => [];
}

class LoadBooks extends ReadingEvent {}

class LoadBookFromFile extends ReadingEvent {
  final String filePath;

  const LoadBookFromFile(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class LoadBookFromBytes extends ReadingEvent {
  final Uint8List bytes;
  final String fileName;

  const LoadBookFromBytes(this.bytes, this.fileName);

  @override
  List<Object> get props => [bytes, fileName];
}

class OpenBook extends ReadingEvent {
  final Book book;

  const OpenBook(this.book);

  @override
  List<Object> get props => [book];
}

class UpdateReadingProgress extends ReadingEvent {
  final String bookId;
  final int currentPage;
  final double progress;

  const UpdateReadingProgress(this.bookId, this.currentPage, this.progress);

  @override
  List<Object> get props => [bookId, currentPage, progress];
}

class StartReadingSession extends ReadingEvent {
  final String bookId;

  const StartReadingSession(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class StopReadingSession extends ReadingEvent {}

class PauseReadingSession extends ReadingEvent {}

class ResumeReadingSession extends ReadingEvent {}

// States
abstract class ReadingState extends Equatable {
  const ReadingState();

  @override
  List<Object?> get props => [];
}

class ReadingInitial extends ReadingState {}

class ReadingLoading extends ReadingState {}

class BooksLoaded extends ReadingState {
  final List<Book> books;

  const BooksLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class BookOpened extends ReadingState {
  final Book book;
  final bool isReading;
  final int currentSessionTime;

  const BookOpened(this.book, {this.isReading = false, this.currentSessionTime = 0});

  @override
  List<Object> get props => [book, isReading, currentSessionTime];
}

class ReadingError extends ReadingState {
  final String message;

  const ReadingError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final BookService bookService;
  final ReadingTimeService readingTimeService;

  ReadingBloc({
    required this.bookService,
    required this.readingTimeService,
  }) : super(ReadingInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadBookFromFile>(_onLoadBookFromFile);
    on<LoadBookFromBytes>(_onLoadBookFromBytes);
    on<OpenBook>(_onOpenBook);
    on<UpdateReadingProgress>(_onUpdateReadingProgress);
    on<StartReadingSession>(_onStartReadingSession);
    on<StopReadingSession>(_onStopReadingSession);
    on<PauseReadingSession>(_onPauseReadingSession);
    on<ResumeReadingSession>(_onResumeReadingSession);
  }

  void _onLoadBooks(LoadBooks event, Emitter<ReadingState> emit) async {
    emit(ReadingLoading());
    try {
      final books = await bookService.getBooks();
      emit(BooksLoaded(books));
    } catch (e) {
      emit(ReadingError('Failed to load books: $e'));
    }
  }

  void _onLoadBookFromFile(LoadBookFromFile event, Emitter<ReadingState> emit) async {
    emit(ReadingLoading());
    try {
      final book = await bookService.loadEpubFromFile(event.filePath);
      await bookService.saveBook(book);
      final books = await bookService.getBooks();
      emit(BooksLoaded([...books, book]));
    } catch (e) {
      emit(ReadingError('Failed to load book: $e'));
    }
  }

  void _onLoadBookFromBytes(LoadBookFromBytes event, Emitter<ReadingState> emit) async {
    emit(ReadingLoading());
    try {
      final book = await bookService.loadEpubFromBytes(event.bytes, event.fileName);
      await bookService.saveBook(book);
      final books = await bookService.getBooks();
      emit(BooksLoaded([...books, book]));
    } catch (e) {
      emit(ReadingError('Failed to load book: $e'));
    }
  }

  void _onOpenBook(OpenBook event, Emitter<ReadingState> emit) async {
    emit(BookOpened(event.book));
  }

  void _onUpdateReadingProgress(UpdateReadingProgress event, Emitter<ReadingState> emit) async {
    try {
      await bookService.updateBookProgress(event.bookId, event.currentPage, event.progress);
      // Emit updated state if needed
    } catch (e) {
      emit(ReadingError('Failed to update progress: $e'));
    }
  }

  void _onStartReadingSession(StartReadingSession event, Emitter<ReadingState> emit) async {
    readingTimeService.startReadingSession(event.bookId);
    
    if (state is BookOpened) {
      final currentState = state as BookOpened;
      emit(BookOpened(
        currentState.book,
        isReading: true,
        currentSessionTime: readingTimeService.currentSessionTime,
      ));
    }
  }

  void _onStopReadingSession(StopReadingSession event, Emitter<ReadingState> emit) async {
    readingTimeService.stopReadingSession();
    
    if (state is BookOpened) {
      final currentState = state as BookOpened;
      emit(BookOpened(
        currentState.book,
        isReading: false,
        currentSessionTime: 0,
      ));
    }
  }

  void _onPauseReadingSession(PauseReadingSession event, Emitter<ReadingState> emit) async {
    readingTimeService.pauseReadingSession();
    
    if (state is BookOpened) {
      final currentState = state as BookOpened;
      emit(BookOpened(
        currentState.book,
        isReading: false,
        currentSessionTime: currentState.currentSessionTime,
      ));
    }
  }

  void _onResumeReadingSession(ResumeReadingSession event, Emitter<ReadingState> emit) async {
    readingTimeService.resumeReadingSession();
    
    if (state is BookOpened) {
      final currentState = state as BookOpened;
      emit(BookOpened(
        currentState.book,
        isReading: true,
        currentSessionTime: currentState.currentSessionTime,
      ));
    }
  }
}
