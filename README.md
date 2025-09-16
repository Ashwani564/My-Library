# My Library using Flutter 📚

A beautiful, feature-rich Flutter EPUB reader app with Kindle-like functionality and OLED optimization.

<img width="1886" height="1043" alt="image" src="https://github.com/user-attachments/assets/a0ad7e2b-2bcf-4192-85df-7804272fecc2" />


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

##  Platform Support

- ✅ **Android** (Primary platform with full functionality)
- ⚠️ **Web** (Limited file system access)
- 🔄 **iOS** (Not tested, but should work with minor adjustments)

## Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC (Business Logic Component)
- **EPUB Parsing**: epub_view package
- **File Handling**: file_picker
- **Local Storage**: shared_preferences
- **Fonts**: Bookerly (Amazon Kindle's reading font)

##  Dependencies

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


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Amazon Kindle** for the Bookerly font inspiration
- **Flutter Community** for the excellent epub_view package
- **Open Source Contributors** for various dependencies used


