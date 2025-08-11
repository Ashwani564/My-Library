# My Library 📚

A beautiful, feature-rich Flutter EPUB reader app with Kindle-like functionality and OLED optimization.

## ✨ Features

### 📖 Reading Experience
- **OLED-optimized pure black background** for comfortable night reading
- **Bookerly font** for optimal reading experience
- **Smooth page navigation** with tap-to-turn pages
- **Clean, distraction-free interface**

### 📊 Progress Tracking
- **Reading progress tracking** with visual progress bar
- **Estimated reading time** (per chapter and whole book)
- **Reading session timer** with pause/resume functionality
- **Total reading time statistics**

### 📱 User Interface
- **Three-dot menu** for accessing reading statistics and controls
- **Toggle estimated reading time** visibility option
- **Responsive design** optimized for mobile devices
- **Intuitive tap zones** for page navigation

### 📂 File Management
- **Custom EPUB upload** support
- **File picker integration** for easy EPUB selection
- **Automatic file caching** for offline reading
- **Cross-platform compatibility**

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio / VS Code
- Android device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ashwani564/My-Library.git
   cd My-Library
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ **Android** (Primary platform with full functionality)
- ⚠️ **Web** (Limited file system access)
- 🔄 **iOS** (Not tested, but should work with minor adjustments)

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC (Business Logic Component)
- **EPUB Parsing**: epub_view package
- **File Handling**: file_picker
- **Local Storage**: shared_preferences
- **Fonts**: Bookerly (Amazon Kindle's reading font)

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  epub_view: ^3.2.0
  file_picker: ^8.3.7
  shared_preferences: ^2.5.3
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7
  path_provider: ^2.1.5
  permission_handler: ^11.4.0
  google_fonts: ^6.3.0
```

## 🏗️ Architecture

The app follows a clean architecture pattern with:

- **Models**: Data structures for books, settings, etc.
- **Services**: Business logic for file handling, reading time tracking
- **BLoC**: State management for reading and settings
- **Screens**: UI components for home, reading, and settings
- **Utils**: Helper functions and utilities

## 📖 Usage

1. **Upload EPUB**: Tap the "+" button to select an EPUB file
2. **Start Reading**: Tap on a book to open the reader
3. **Navigate**: Tap left/right sides of screen or swipe to turn pages
4. **Access Menu**: Tap center of screen to show/hide controls
5. **Reading Stats**: Tap three dots (⋮) to view reading statistics
6. **Settings**: Access font size, reading speed, and other preferences

## 🎨 Design Philosophy

Die Bibliothek prioritizes:
- **Readability**: Optimized typography and spacing
- **Performance**: Smooth animations and efficient rendering
- **Battery Life**: OLED-friendly pure black backgrounds
- **Simplicity**: Clean interface without distractions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Amazon Kindle** for the Bookerly font inspiration
- **Flutter Community** for the excellent epub_view package
- **Open Source Contributors** for various dependencies used

## 🐛 Known Issues

- Table of Contents may show initially instead of first chapter content
- Progress jumping via slider is limited in current epub_view version
- Web platform has limited file system access

## 🔮 Future Features

- [ ] Bookmarks and highlights
- [ ] Note-taking functionality
- [ ] Multiple themes (sepia, white, etc.)
- [ ] Font family selection
- [ ] Text-to-speech integration
- [ ] Cloud sync for reading progress

---

**My Library** - *Your personal digital library* 📚✨
