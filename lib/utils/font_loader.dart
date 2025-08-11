import 'package:flutter/services.dart';

class BookerlyFontLoader {
  static const String _fontFamily = 'Bookerly';
  
  static Future<void> loadFonts() async {
    try {
      // Load Bookerly font variants
      await _loadFont('assets/fonts/Bookerly-Regular.ttf');
      await _loadFont('assets/fonts/Bookerly-Bold.ttf');
      await _loadFont('assets/fonts/Bookerly-Italic.ttf');
      await _loadFont('assets/fonts/Bookerly-BoldItalic.ttf');
    } catch (e) {
      print('Error loading Bookerly fonts: $e');
    }
  }

  static Future<void> _loadFont(String assetPath) async {
    try {
      final fontData = await rootBundle.load(assetPath);
      final fontLoader = FontLoader(_fontFamily);
      fontLoader.addFont(Future.value(fontData));
      await fontLoader.load();
    } catch (e) {
      print('Error loading font from $assetPath: $e');
    }
  }

  static TextStyle getBookerlyStyle({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
    );
  }
}
