$fonts = @(
    "Regular",
    "Medium",
    "SemiBold",
    "Bold"
)

foreach ($weight in $fonts) {
    $url = "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-$weight.ttf"
    $output = "assets/fonts/Poppins-$weight.ttf"
    
    Write-Host "Downloading Poppins-$weight.ttf..."
    Invoke-WebRequest -Uri $url -OutFile $output
}

Write-Host "All fonts downloaded successfully!" 