#!/bin/bash
cd "/mnt/c/dev/git/hyle"
flutter analyze > analyze_results.txt 2>&1
echo "Analysis complete. Check analyze_results.txt for results."