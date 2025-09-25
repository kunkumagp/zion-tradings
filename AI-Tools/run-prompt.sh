#!/bin/bash

# AI Prompt Runner Script
# This script reads the AI-prompt file and user-prompt.txt for complete AI context

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_PROMPT_FILE="$SCRIPT_DIR/AI-prompt"
USER_PROMPT_FILE="$SCRIPT_DIR/user-prompt.txt"
APPLICATION_UPDATES_FILE="$SCRIPT_DIR/application-updates"
DATABASE_UPDATES_FILE="$SCRIPT_DIR/database-updates"

echo "=========================================="
echo "🤖 AI Context & Complete Project Status"
echo "=========================================="
echo

# Check if AI-prompt file exists
if [ ! -f "$AI_PROMPT_FILE" ]; then
    echo "❌ Error: AI-prompt file not found at: $AI_PROMPT_FILE"
    echo "Please create an AI-prompt file in the AI-Tools folder."
    exit 1
fi

echo "📖 Reading AI context from: $AI_PROMPT_FILE"
echo "=========================================="
echo

# Display the content of AI-prompt file
cat "$AI_PROMPT_FILE"

echo
echo "=========================================="
echo "🔧 Application Updates & Changes"
echo "=========================================="

# Check if application-updates file exists and read it
if [ -f "$APPLICATION_UPDATES_FILE" ]; then
    cat "$APPLICATION_UPDATES_FILE"
else
    echo "⚠️  No application-updates file found."
    echo "💡 Location: $APPLICATION_UPDATES_FILE"
fi

echo
echo "=========================================="
echo "🗄️  Database Updates & Changes"
echo "=========================================="

# Check if database-updates file exists and read it
if [ -f "$DATABASE_UPDATES_FILE" ]; then
    cat "$DATABASE_UPDATES_FILE"
else
    echo "⚠️  No database-updates file found."
    echo "💡 Location: $DATABASE_UPDATES_FILE"
fi

echo
echo "=========================================="
echo "📝 Current User Request:"
echo "=========================================="

# Check if user-prompt.txt exists and read it
if [ -f "$USER_PROMPT_FILE" ]; then
    cat "$USER_PROMPT_FILE"
else
    echo "⚠️  No user-prompt.txt found. Create one to specify your request."
    echo "💡 Location: $USER_PROMPT_FILE"
fi

echo
echo "=========================================="
echo "✅ Complete project context loaded!"
echo "📋 Includes: AI context + App changes + DB changes + User request"
echo "🚀 Ready for AI assistance."
echo "=========================================="