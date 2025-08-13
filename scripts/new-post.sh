#!/bin/bash
# Script to create a new blog post with the correct frontmatter

set -e

# Check if a title was provided
if [ -z "$1" ]; then
  echo "Error: Please provide a post title"
  echo "Usage: $0 \"My New Post Title\""
  exit 1
fi

# Configuration
TITLE="$1"
CURRENT_DATE=$(date +%Y-%m-%d)
AUTHOR_NAME="Curtis Goolsby"
AUTHOR_EMAIL="curtis.goolsby@gmail.com"

# Generate slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:] -' | tr ' ' '-' | tr -s '-')

# Create file path
FILE_PATH="content/posts/$SLUG.md"

# Check if file already exists
if [ -f "$FILE_PATH" ]; then
  echo "Error: A post with this slug already exists: $FILE_PATH"
  exit 1
fi

# Create the post with frontmatter
cat > "$FILE_PATH" << EOF
+++
title = "$TITLE"
description = ""
date = $CURRENT_DATE
author = {name = "$AUTHOR_NAME", email = "$AUTHOR_EMAIL"}
tags = []
draft = true
+++

# $TITLE

*Write your post content here...*

EOF

echo "✅ Created new post: $FILE_PATH"
echo "Edit this file to add your content and metadata."
echo "Remember to set draft = false when ready to publish."
