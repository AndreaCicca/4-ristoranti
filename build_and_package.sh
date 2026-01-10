#!/bin/bash

# Stop script on error
set -e

# Configuration
PROJECT_NAME="ristoranti"
SCHEME_NAME="ristoranti"
BUILD_DIR="build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
APP_NAME="ristoranti.app"
DMG_NAME="4Ristoranti.dmg"

# 1. Prepare build directory
echo "Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 2. Build the project using xcodebuild
echo "Building $PROJECT_NAME..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration Release \
           -derivedDataPath "$DERIVED_DATA_DIR" \
           -destination 'platform=macOS' \
           CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
           build 

# 3. Locate the built app
APP_PATH="$DERIVED_DATA_DIR/Build/Products/Release/$APP_NAME"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    exit 1
fi

echo "Build successful!"

# 4. Create DMG
echo "Creating DMG package..."
DMG_SOURCE_DIR="$BUILD_DIR/dmg_source"
mkdir -p "$DMG_SOURCE_DIR"

# Copy App to source dir
cp -R "$APP_PATH" "$DMG_SOURCE_DIR/"

# Create symlink to /Applications for easy installation
ln -s /Applications "$DMG_SOURCE_DIR/Applications"

# Generate DMG using hdiutil
hdiutil create -volname "4 Ristoranti" \
               -srcfolder "$DMG_SOURCE_DIR" \
               -ov -format UDZO \
               "$BUILD_DIR/$DMG_NAME"

# Clean up temp source
rm -rf "$DMG_SOURCE_DIR"

echo "Done! DMG is available at: $BUILD_DIR/$DMG_NAME"
