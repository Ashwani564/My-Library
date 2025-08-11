#!/bin/bash

# Build script for EPUB Reader App

echo "Building EPUB Reader App..."

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Check for font files
if [ ! -f "assets/fonts/Bookerly-Regular.ttf" ]; then
    echo "Warning: Bookerly font files not found in assets/fonts/"
    echo "Please add the font files before building. See assets/fonts/README.md for instructions."
fi

# Build for Android (Debug)
echo "Building Android debug APK..."
flutter build apk --debug

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS app..."
    flutter build ios --debug --no-codesign
fi

echo "Build complete!"
echo "Android APK location: build/app/outputs/flutter-apk/app-debug.apk"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "iOS app location: build/ios/iphoneos/Runner.app"
fi
