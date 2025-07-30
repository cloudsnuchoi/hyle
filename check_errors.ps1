# Run flutter analyze and capture output
$output = flutter analyze --no-preamble 2>&1 | Out-String

# Split into lines
$lines = $output -split "`n"

# Find undefined class errors
$undefinedClasses = @{}
$errorCount = 0

foreach ($line in $lines) {
    if ($line -match "error.*Undefined class '(\w+)'") {
        $className = $matches[1]
        $errorCount++
        
        # Extract file location
        if ($line -match "([^-]+\.dart:\d+:\d+)") {
            $location = $matches[1].Trim()
            
            if (-not $undefinedClasses.ContainsKey($className)) {
                $undefinedClasses[$className] = @()
            }
            $undefinedClasses[$className] += $location
        }
    }
}

Write-Host "=== UNDEFINED CLASS ERRORS ===" -ForegroundColor Yellow
Write-Host "Total undefined class errors: $errorCount" -ForegroundColor Cyan
Write-Host ""

# Sort by frequency
$sorted = $undefinedClasses.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending

foreach ($entry in $sorted) {
    $className = $entry.Key
    $locations = $entry.Value
    
    Write-Host "$className : $($locations.Count) occurrences" -ForegroundColor Green
    
    # Show first 5 locations
    $count = 0
    foreach ($loc in $locations) {
        if ($count -lt 5) {
            Write-Host "  - $loc" -ForegroundColor Gray
            $count++
        }
    }
    
    if ($locations.Count -gt 5) {
        Write-Host "  ... and $($locations.Count - 5) more" -ForegroundColor DarkGray
    }
    Write-Host ""
}