#!/bin/bash

echo "=== Fixing Flutter Errors ==="
cd "/Users/junhoochoi/dev/github desktop/hyle"

echo -e "\n1. Running flutter pub get..."
flutter pub get

echo -e "\n2. Running flutter analyze..."
flutter analyze --no-fatal-infos | head -50

echo -e "\n=== Script Complete ==="