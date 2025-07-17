#!/usr/bin/env python3
import subprocess
import sys
import os

def run_flutter_analyze():
    """Run flutter analyze and capture output"""
    try:
        # Try to find flutter in common locations
        flutter_paths = [
            '/mnt/c/src/flutter/bin/flutter.bat',
            'flutter.bat',
            'flutter'
        ]
        
        flutter_cmd = None
        for path in flutter_paths:
            try:
                # Test if the command works
                test = subprocess.run([path, '--version'], capture_output=True, text=True, shell=True)
                if test.returncode == 0:
                    flutter_cmd = path
                    break
            except:
                continue
        
        if not flutter_cmd:
            print("Flutter command not found!")
            return
        
        print(f"Using flutter command: {flutter_cmd}")
        print("Running flutter analyze...")
        
        # Run flutter analyze
        result = subprocess.run([flutter_cmd, 'analyze', '--no-fatal-infos'], 
                              capture_output=True, text=True, shell=True, cwd='/mnt/c/dev/git/hyle')
        
        output = result.stdout + result.stderr
        
        # Save full output
        with open('analyze_full_output.txt', 'w') as f:
            f.write(output)
        
        # Parse and analyze errors
        lines = output.split('\n')
        errors = []
        
        for line in lines:
            if ' • ' in line and ' at ' in line:
                errors.append(line.strip())
        
        print(f"\nTotal errors found: {len(errors)}")
        
        # Count error types
        error_types = {}
        todo_errors = []
        model_errors = []
        
        for error in errors:
            # Extract error type
            if ' • ' in error:
                parts = error.split(' • ')
                if len(parts) >= 2:
                    error_type = parts[1].split(' at ')[0].strip()
                    error_types[error_type] = error_types.get(error_type, 0) + 1
                    
                    # Check if it's in todo or models directories
                    if 'lib/features/todo' in error:
                        todo_errors.append(error)
                    elif 'lib/models' in error:
                        model_errors.append(error)
        
        # Print analysis
        print("\n=== Top Error Types ===")
        sorted_errors = sorted(error_types.items(), key=lambda x: x[1], reverse=True)
        for i, (error_type, count) in enumerate(sorted_errors[:10]):
            print(f"{i+1}. {error_type}: {count} occurrences")
        
        print(f"\n=== Todo Feature Errors ({len(todo_errors)}) ===")
        for error in todo_errors[:5]:
            print(error)
        
        print(f"\n=== Model Errors ({len(model_errors)}) ===")
        for error in model_errors[:5]:
            print(error)
        
        # Save summary
        with open('analyze_summary.txt', 'w') as f:
            f.write(f"Total errors: {len(errors)}\n\n")
            f.write("Top Error Types:\n")
            for error_type, count in sorted_errors[:10]:
                f.write(f"- {error_type}: {count}\n")
            f.write(f"\nTodo errors: {len(todo_errors)}\n")
            f.write(f"Model errors: {len(model_errors)}\n")
        
        print("\nFull output saved to analyze_full_output.txt")
        print("Summary saved to analyze_summary.txt")
        
    except Exception as e:
        print(f"Error running analysis: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    run_flutter_analyze()