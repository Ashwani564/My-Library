import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:epub_view/epub_view.dart';
import '../blocs/reading_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../models/book.dart';
import '../models/reading_settings.dart';
import '../services/reading_time_service.dart';

class ReadingScreen extends StatefulWidget {
  final Book book;

  const ReadingScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  EpubController? _epubController;
  bool _isMenuVisible = false;
  Timer? _sessionTimer;
  int _currentSessionTime = 0;
  bool _isReading = false;
  bool _isControllerInitialized = false;
  String? _errorMessage;
  double _currentProgress = 0.0;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.book.readingProgress;
    _totalPages = widget.book.totalPages;
    _initializeEpubController();
    context.read<SettingsBloc>().add(LoadSettings());
    _startReadingSession();
  }

  void _initializeEpubController() async {
    try {
      // For Android platform, try to load the actual EPUB file
      if (!widget.book.filePath.startsWith('web_') && 
          !widget.book.filePath.startsWith('fallback_') &&
          !widget.book.filePath.startsWith('temp_')) {
        try {
          final file = File(widget.book.filePath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            
            _epubController = EpubController(
              document: EpubDocument.openData(bytes),
            );
            
            setState(() {
              _isControllerInitialized = true;
            });
            return;
          }
        } catch (e) {
          print('Error loading EPUB file: $e');
          // Fall through to demo content
        }
      }
      
      // For demo/fallback cases, show demo content
      setState(() {
        _isControllerInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load EPUB: ${e.toString()}';
        _isControllerInitialized = true;
      });
    }
  }

  void _startReadingSession() {
    context.read<ReadingBloc>().add(StartReadingSession(widget.book.id));
    _isReading = true;
    _sessionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isReading) {
        setState(() {
          _currentSessionTime += 5;
        });
      }
    });
  }

  void _pauseReadingSession() {
    context.read<ReadingBloc>().add(PauseReadingSession());
    setState(() {
      _isReading = false;
    });
  }

  void _resumeReadingSession() {
    context.read<ReadingBloc>().add(ResumeReadingSession());
    setState(() {
      _isReading = true;
    });
  }

  void _previousPage() {
    // Note: Direct page navigation through controller is not available
    // Users can tap on the left side of the screen or use gesture navigation
  }

  void _nextPage() {
    // Note: Direct page navigation through controller is not available  
    // Users can tap on the right side of the screen or use gesture navigation
  }

  void _showReadingMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Reading session controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuButton(
                    icon: _isReading ? Icons.pause : Icons.play_arrow,
                    label: _isReading ? 'Pause' : 'Resume',
                    onPressed: () {
                      if (_isReading) {
                        _pauseReadingSession();
                      } else {
                        _resumeReadingSession();
                      }
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              
              // Reading statistics
              Text(
                'Reading Statistics',
                style: TextStyle(
                  fontFamily: 'Bookerly',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),                Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Session Time', _formatTime(_currentSessionTime)),
                  _buildStatColumn('Total Time', _getTotalReadingTime()),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, settingsState) {
                      final wordsPerMinute = settingsState is SettingsLoaded 
                          ? settingsState.settings.wordsPerMinute 
                          : 250; // default value
                      return _buildStatColumn('Chapter Left', _getEstimatedChapterTime(wordsPerMinute));
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Bookerly',
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Bookerly',
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Bookerly',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Use default settings if not loaded yet
          final settings = settingsState is SettingsLoaded 
              ? settingsState.settings 
              : ReadingSettings(
                  fontSize: 16.0,
                  lineHeight: 1.5,
                  showEstimatedReadingTime: true,
                  showReadingTimer: true,
                  wordsPerMinute: 200,
                );
          
          if (!_isControllerInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuVisible = !_isMenuVisible;
                  });
                },
                onTapDown: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final tapPosition = details.localPosition.dx;
                  
                  // Handle menu visibility toggle on center tap
                  if (tapPosition >= screenWidth * 0.3 && tapPosition <= screenWidth * 0.7) {
                    setState(() {
                      _isMenuVisible = !_isMenuVisible;
                    });
                  }
                  // EpubView handles left/right page navigation automatically
                },
                child: _errorMessage != null
                    ? _buildErrorView()
                    : _epubController != null
                        ? EpubView(
                            controller: _epubController!,
                            onExternalLinkPressed: (href) {},
                            onChapterChanged: (chapter) {
                              // Optimize: reduce frequency of updates
                              if (chapter != null && chapter.progress != null) {
                                final newProgress = chapter.progress!;
                                if ((newProgress - _currentProgress).abs() > 0.01) {
                                  setState(() {
                                    _currentProgress = newProgress;
                                    _currentPage = (newProgress * _totalPages).round();
                                  });
                                }
                              }
                            },
                            builders: EpubViewBuilders<DefaultBuilderOptions>(
                              options: DefaultBuilderOptions(
                                textStyle: TextStyle(
                                  fontFamily: 'Bookerly',
                                  fontSize: settings.fontSize,
                                  height: settings.lineHeight,
                                  color: Colors.white,
                                ),
                                paragraphPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              chapterDividerBuilder: (_) => const Divider(
                                color: Colors.grey,
                                height: 1,
                                thickness: 0.5,
                              ),
                            ),
                          )
                        : _buildDemoView(settings),
              ),
              if (_isMenuVisible) _buildTopBar(settings),
              if (_isMenuVisible) _buildBottomBar(settings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(ReadingSettings settings) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).padding.top + 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontFamily: 'Bookerly',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    _showReadingMenu(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ReadingSettings settings) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 100,
          maxHeight: 160 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clean progress bar
                Slider(
                  value: _currentProgress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    setState(() {
                      _currentProgress = value;
                      _currentPage = (value * _totalPages).round();
                    });
                    
                    // Update reading progress
                    context.read<ReadingBloc>().add(
                      UpdateReadingProgress(widget.book.id, _currentPage, value),
                    );
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[700],
                ),
                // Simple progress info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_currentProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Bookerly',
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    if (settings.showEstimatedReadingTime)
                      Text(
                        '${_getEstimatedBookTime(settings.wordsPerMinute)} left',
                        style: const TextStyle(
                          fontFamily: 'Bookerly',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEstimatedChapterTime(int wordsPerMinute) {
    // Calculate based on current chapter
    if (widget.book.chapters.isNotEmpty) {
      final currentChapter = widget.book.chapters[0]; // Simplified
      final remainingWords = (currentChapter.wordCount * (1 - _currentProgress)).round();
      final minutes = (remainingWords / wordsPerMinute).ceil();
      return '${minutes}m';
    }
    return '--';
  }

  String _getEstimatedBookTime(int wordsPerMinute) {
    // Calculate based on total book
    final totalWords = widget.book.chapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.wordCount,
    );
    final remainingWords = (totalWords * (1 - _currentProgress)).round();
    final minutes = (remainingWords / wordsPerMinute).ceil();
    
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
  }

  String _getTotalReadingTime() {
    final totalTime = context.read<ReadingTimeService>().getTotalReadingTime(widget.book.id);
    return _formatTime(totalTime + _currentSessionTime);
  }

  String _formatTime(int seconds) {
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

  Widget _buildErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Error Loading Book',
                style: TextStyle(
                  fontFamily: 'Bookerly',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: TextStyle(
                  fontFamily: 'Bookerly',
                  fontSize: 16,
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoView(ReadingSettings settings) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: TextStyle(
                fontFamily: 'Bookerly',
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'by ${widget.book.author}',
              style: TextStyle(
                fontFamily: 'Bookerly',
                fontSize: 18,
                color: Colors.grey[300],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Demo Content',
              style: TextStyle(
                fontFamily: 'Bookerly',
                fontSize: settings.fontSize,
                color: Colors.white,
                height: settings.lineHeight,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This is a demo of the EPUB reader app. The actual EPUB parsing functionality is limited on the web platform due to security restrictions.',
              style: TextStyle(
                fontFamily: 'Bookerly',
                fontSize: settings.fontSize,
                color: Colors.white,
                height: settings.lineHeight,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'To fully test the EPUB reader with real EPUB files, please run this app on an Android device where full file system access is available.',
              style: TextStyle(
                fontFamily: 'Bookerly',
                fontSize: settings.fontSize,
                color: Colors.white,
                height: settings.lineHeight,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Features Available:',
              style: TextStyle(
                fontFamily: 'Bookerly',
                fontSize: settings.fontSize + 2,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: settings.lineHeight,
              ),
            ),
            SizedBox(height: 12),
            ...[
              '• OLED-optimized pure black background',
              '• Bookerly font for optimal reading experience',
              '• Reading progress tracking',
              '• Reading time estimation',
              '• Customizable font size and line height',
              '• Reading session timer',
              '• Chapter navigation',
            ].map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                feature,
                style: TextStyle(
                  fontFamily: 'Bookerly',
                  fontSize: settings.fontSize,
                  color: Colors.white,
                  height: settings.lineHeight,
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
