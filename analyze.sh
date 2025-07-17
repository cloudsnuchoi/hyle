#!/bin/bash
cd "/Users/junhoochoi/dev/github desktop/hyle"
flutter analyze > analyze_results.txt 2>&1
echo "Analysis complete. Check analyze_results.txt for results."