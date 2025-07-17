#!/bin/bash

echo "=== Running Flutter Pub Get ==="
cd "/Users/junhoochoi/dev/github desktop/hyle"

# Run flutter pub get
flutter pub get

echo -e "\n=== Checking for any issues ==="
flutter doctor -v

echo -e "\n=== Running Flutter Analyze ==="
flutter analyze --no-fatal-infos

echo -e "\n=== Complete! ==="