import 'dart:io';

void main() async {
  print('Running flutter analyze...');
  
  final result = await Process.run(
    'flutter',
    ['analyze', '--no-preamble'],
    workingDirectory: 'C:\\dev\\git\\hyle',
  );
  
  final output = result.stdout.toString() + result.stderr.toString();
  final lines = output.split('\n');
  
  // Track undefined class errors
  final undefinedClasses = <String, List<String>>{};
  final importErrors = <String>[];
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    // Check for undefined class errors
    if (line.contains('Undefined class')) {
      final match = RegExp(r"Undefined class '(\w+)'").firstMatch(line);
      if (match != null) {
        final className = match.group(1)!;
        final location = line.split(' - ')[1] ?? '';
        
        if (!undefinedClasses.containsKey(className)) {
          undefinedClasses[className] = [];
        }
        undefinedClasses[className]!.add(location);
      }
    }
    
    // Check for import errors
    if (line.contains("can't be resolved") || line.contains("Unused import")) {
      importErrors.add(line);
    }
  }
  
  print('\n=== UNDEFINED CLASSES ===');
  print('Found ${undefinedClasses.length} undefined classes:\n');
  
  // Sort by frequency (most common first)
  final sortedClasses = undefinedClasses.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  
  for (final entry in sortedClasses) {
    print('${entry.key}: ${entry.value.length} occurrences');
    if (entry.value.length <= 5) {
      for (final location in entry.value) {
        print('  - $location');
      }
    } else {
      print('  - First 5 locations:');
      for (int i = 0; i < 5; i++) {
        print('  - ${entry.value[i]}');
      }
      print('  - ... and ${entry.value.length - 5} more');
    }
    print('');
  }
  
  print('\n=== IMPORT ERRORS ===');
  print('Found ${importErrors.length} import errors');
  if (importErrors.isNotEmpty) {
    for (final error in importErrors.take(10)) {
      print('- $error');
    }
    if (importErrors.length > 10) {
      print('... and ${importErrors.length - 10} more');
    }
  }
}