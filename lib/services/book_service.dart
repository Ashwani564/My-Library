import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:epub_view/epub_view.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';

class BookService {
  static const String _booksKey = 'books';

  Future<List<Book>> getBooks() async {
    // In a real app, you'd get this from storage
    // For now, return empty list
    return [];
  }

  Future<Book> loadEpubFromFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    
    final epubBook = await EpubReader.readBook(bytes);
    
    // Extract book metadata
    final title = epubBook.Title ?? 'Unknown Title';
    final author = epubBook.Author ?? 'Unknown Author';
    
    // Calculate total pages (estimate based on content length)
    int totalPages = 0;
    final chapters = <ChapterInfo>[];
    
    if (epubBook.Chapters != null) {
      for (int i = 0; i < epubBook.Chapters!.length; i++) {
        final chapter = epubBook.Chapters![i];
        final content = chapter.HtmlContent ?? '';
        final wordCount = _countWords(content);
        final pageCount = (wordCount / 250).ceil(); // Estimate 250 words per page
        
        chapters.add(ChapterInfo(
          index: i,
          title: chapter.Title ?? 'Chapter ${i + 1}',
          startPage: totalPages,
          endPage: totalPages + pageCount,
          wordCount: wordCount,
        ));
        
        totalPages += pageCount;
      }
    }
    
    // Copy file to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = file.path.split('/').last;
    final newPath = '${appDir.path}/books/$fileName';
    final newFile = File(newPath);
    await newFile.create(recursive: true);
    await newFile.writeAsBytes(bytes);
    
    return Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: author,
      filePath: newPath,
      totalPages: totalPages,
      chapters: chapters,
    );
  }

  Future<Book> loadEpubFromBytes(Uint8List bytes, String fileName) async {
    try {
      // Try to parse the actual EPUB file
      final epubBook = await EpubReader.readBook(bytes);
      
      // Extract book metadata
      final title = epubBook.Title ?? fileName.replaceAll('.epub', '');
      final author = epubBook.Author ?? 'Unknown Author';
      
      // Calculate total pages (estimate based on content length)
      int totalPages = 0;
      final chapters = <ChapterInfo>[];
      
      if (epubBook.Chapters != null && epubBook.Chapters!.isNotEmpty) {
        for (int i = 0; i < epubBook.Chapters!.length; i++) {
          final chapter = epubBook.Chapters![i];
          final content = chapter.HtmlContent ?? '';
          final wordCount = _countWords(content);
          final pageCount = (wordCount / 250).ceil(); // Estimate 250 words per page
          
          chapters.add(ChapterInfo(
            index: i,
            title: chapter.Title ?? 'Chapter ${i + 1}',
            startPage: totalPages,
            endPage: totalPages + pageCount,
            wordCount: wordCount,
          ));
          
          totalPages += pageCount;
        }
      } else {
        // Fallback if no chapters found
        chapters.add(ChapterInfo(
          index: 0,
          title: 'Chapter 1',
          startPage: 0,
          endPage: 10,
          wordCount: 2500,
        ));
        totalPages = 10;
      }
      
      // Save the bytes to a temporary file for reading screen access
      String filePath = 'bytes_$fileName';
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
        final newPath = '${appDir.path}/books/$cleanFileName';
        final newFile = File(newPath);
        await newFile.create(recursive: true);
        await newFile.writeAsBytes(bytes);
        filePath = newPath;
      } catch (e) {
        print('Could not save file to documents directory: $e');
        // Use a temporary path identifier
        filePath = 'temp_${DateTime.now().millisecondsSinceEpoch}_$fileName';
      }
      
      return Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        author: author,
        filePath: filePath,
        totalPages: totalPages,
        chapters: chapters,
      );
    } catch (e) {
      print('Error parsing EPUB from bytes: $e');
      // Create a fallback book if EPUB parsing fails
      final chapters = <ChapterInfo>[
        ChapterInfo(
          index: 0,
          title: 'Chapter 1',
          startPage: 0,
          endPage: 10,
          wordCount: 2500,
        ),
      ];
      
      return Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: fileName.replaceAll('.epub', ''),
        author: 'Unknown Author',
        filePath: 'fallback_$fileName',
        totalPages: 10,
        chapters: chapters,
      );
    }
  }

  int _countWords(String text) {
    // Remove HTML tags and count words
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final words = cleanText.split(RegExp(r'\s+'));
    return words.where((word) => word.isNotEmpty).length;
  }

  Future<void> saveBook(Book book) async {
    // In a real app, save to persistent storage
    // For now, just return
  }

  Future<void> updateBookProgress(String bookId, int currentPage, double progress) async {
    // Update book progress in storage
  }

  String formatReadingTime(int seconds) {
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

  String estimateReadingTime(int wordCount, int wordsPerMinute) {
    final minutes = (wordCount / wordsPerMinute).ceil();
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
  }
}
