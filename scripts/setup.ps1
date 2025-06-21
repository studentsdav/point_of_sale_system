# Requires PowerShell 5.0 or later
$ErrorActionPreference = 'Stop'

# Fetch Flutter dependencies
Write-Output "Running flutter pub get..."
flutter pub get

# Install Node.js dependencies
Write-Output "Running npm install..."
npm install

# Copy environment file if needed
if ((Test-Path '.env.example') -and (-not (Test-Path '.env'))) {
    Write-Output "Creating .env from .env.example"
    Copy-Item '.env.example' '.env'
}

Write-Output "Setup complete."
