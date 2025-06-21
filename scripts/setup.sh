#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Run Flutter dependency fetch
echo "Running flutter pub get..."
flutter pub get

# Run Node.js dependency install
echo "Running npm install..."
npm install

# Create .env file if it doesn't exist
if [[ -f .env.example && ! -f .env ]]; then
  echo "Creating .env from .env.example"
  cp .env.example .env
fi

echo "✅ Setup complete."
