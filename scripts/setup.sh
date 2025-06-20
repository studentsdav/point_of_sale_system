#!/bin/bash
set -e

# Fetch Flutter dependencies
echo "Running flutter pub get..."
flutter pub get

# Install Node.js dependencies
echo "Running npm install..."
npm install

# Copy environment file if needed
if [ -f .env.example ] && [ ! -f .env ]; then
  echo "Creating .env from .env.example"
  cp .env.example .env
fi

echo "Setup complete."
