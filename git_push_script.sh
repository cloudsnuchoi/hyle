#!/bin/bash

# Navigate to project directory
cd "/Users/junhoochoi/dev/github desktop/hyle"

# Check git status
echo "=== Git Status ==="
git status

# Add all files
echo -e "\n=== Adding all files ==="
git add .

# Create commit
echo -e "\n=== Creating commit ==="
git commit -m "Complete AI learning services development for Hyle platform

- Implemented 26 comprehensive AI learning service files
- Added AWS infrastructure with Neptune graph database and Pinecone vector store
- Created Lambda functions for AI processing, curriculum management, and real-time analytics
- Integrated 3 orchestration components for seamless service coordination
- Services include:
  * Predictive analytics for student performance
  * Learning pattern recognition and analysis
  * Real-time session feedback system
  * Problem difficulty and mistake pattern analysis
  * Smart notification and intervention system
  * Cognitive load monitoring and behavioral nudges
  * Personalized learning pathways

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to origin main
echo -e "\n=== Pushing to GitHub ==="
git push origin main

echo -e "\n=== Complete! ==="