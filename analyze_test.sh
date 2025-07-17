#!/bin/bash
cd "/Users/junhoochoi/dev/github desktop/hyle"
flutter analyze 2>&1 | grep -E "error|Error" | head -30