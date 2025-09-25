#!/bin/bash

# Setup alias for run-prompt command
# This makes the AI prompt loader easily accessible from anywhere in the project

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/run-prompt.sh"

echo "🔧 Setting up AI prompt alias..."
echo
echo "To make 'run-prompt' available from the project root, run:"
echo
echo "echo 'alias run-prompt=\"$SCRIPT_PATH\"' >> ~/.zshrc"
echo "source ~/.zshrc"
echo
echo "Or for bash users:"
echo "echo 'alias run-prompt=\"$SCRIPT_PATH\"' >> ~/.bashrc"
echo "source ~/.bashrc"
echo
echo "After setup, you can run 'run-prompt' from anywhere in your project!"
echo
echo "📁 Files are now organized in: $(dirname "$SCRIPT_PATH")"