# Script to replace deprecated withOpacity() with withValues(alpha:)
# Run this script in the lib directory

$files = Get-ChildItem -Path "lib" -Recurse -Include *.dart

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Replace .withOpacity(x) with .withValues(alpha: x)
    $content = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
    
    # Save the file
    Set-Content $file.FullName $content -NoNewline
    Write-Host "Processed: $($file.Name)"
}

Write-Host "Replacement complete!"
