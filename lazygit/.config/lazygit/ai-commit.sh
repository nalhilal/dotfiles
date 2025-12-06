#!/bin/bash
# AI-powered commit message generator for lazygit

# Read the diff from stdin and pipe to gemini
cat | gemini "Create a conventional commit message for this diff. Output ONLY the commit message - no questions, no AI attribution, no emoji. Format: subject line (max 50 chars), blank line, bullet points." > /tmp/commit_msg

# Commit with the generated message
git commit -F /tmp/commit_msg

# Clean up
rm -f /tmp/commit_msg
