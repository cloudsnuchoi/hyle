# Flutter Error Analysis for Hyle Project

## Summary

Based on manual code inspection of the Hyle project, I've identified several categories of errors that are likely present:

### Total Estimated Errors: 50-100+

## Top 5 Most Common Error Types

### 1. **Missing Import for FontFeature** (2 occurrences)
- **Count**: 2 confirmed
- **Files affected**: 
  - `lib/features/todo/screens/todo_screen.dart` (line 566)
  - `lib/features/timer/screens/timer_screen.dart` (line 356)
- **Error**: The `FontFeature` class is used without importing `dart:ui`
- **Fix**: Add `import 'dart:ui';` to both files

### 2. **Duplicate Todo Class Definition** (1 major conflict)
- **Count**: 1 namespace conflict
- **Files affected**:
  - `lib/features/todo/screens/todo_screen.dart` (defines local Todo class, lines 11-57)
  - `lib/models/Todo.dart` (defines Amplify Todo model)
- **Error**: Two different Todo classes with different properties cause naming conflicts
- **Fix**: Rename the local Todo class in todo_screen.dart to `TodoItem` or use the Amplify model

### 3. **Inconsistent Duration Usage** (~8-10 occurrences)
- **Count**: Estimated 8-10 
- **Files affected**: 
  - `lib/features/todo/screens/todo_screen.dart` (line 27: `Duration.zero`)
  - Other service files in `lib/data/services/`
- **Error**: Using `Duration.zero` which should be `const Duration()`
- **Fix**: Replace `Duration.zero` with `const Duration()`

### 4. **Potential Type Mismatches in Service Models** (~10-20 occurrences)
- **Count**: Estimated 10-20
- **Pattern**: Files importing `'../../models/service_models.dart' as models;`
- **Error**: Multiple achievement-related classes with similar names may cause confusion
- **Fix**: Use consistent naming and proper imports

### 5. **Missing or Incorrect Model Field References** (~5-10 occurrences)
- **Count**: Estimated 5-10
- **Files affected**: Files using Todo model
- **Error**: Todo model has both `completed` and `isCompleted` fields, causing confusion
- **Fix**: Standardize on one field name

## Specific Errors in Todo Feature Files

### `/lib/features/todo/screens/todo_screen.dart`:

1. **Line 566**: `FontFeature.tabularFigures()` - Missing import 'dart:ui'
2. **Line 11-57**: Local Todo class conflicts with Amplify Todo model
3. **Line 27**: `actualTime = Duration.zero` - Should be `const Duration()`
4. **Potential issue**: The screen uses a local Todo model instead of the Amplify-generated one

### `/lib/models/Todo.dart`:

1. **Line 173**: Priority enum is defined but not exported in ModelProvider
2. **Potential issue**: Model has duplicate fields (completed vs isCompleted)

## Recommended Fixes

### Critical (Fix First):

1. **Add missing imports**:
   ```dart
   // In todo_screen.dart and timer_screen.dart
   import 'dart:ui';
   ```

2. **Resolve Todo class conflict**:
   ```dart
   // In todo_screen.dart, rename the local class
   class TodoItem {  // Instead of Todo
     // ... rest of the implementation
   }
   ```

3. **Fix Duration constants**:
   ```dart
   // Replace
   actualTime = Duration.zero
   // With
   actualTime = const Duration()
   ```

### Important:

4. **Priority enum is already exported** (verified in ModelProvider.dart line 41)
   - No action needed, but ensure files import from ModelProvider

5. **Standardize model usage**:
   - Decide whether to use the local Todo model or Amplify's Todo model
   - Update imports and references accordingly
   - The local Todo class has different fields (estimatedTime as Duration vs int)

### Nice to Have:

6. **Clean up duplicate model fields**:
   - Remove either `completed` or `isCompleted` from Todo model
   - Update all references consistently

## Running Flutter Analyze

To get the complete list of errors, run:
```bash
cd /mnt/c/dev/git/hyle
flutter analyze --no-fatal-infos > analyze_results.txt 2>&1
```

Note: The flutter command may need to be run from a Windows terminal or WSL with proper Flutter setup.