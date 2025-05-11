#!/bin/bash
# Local development environment setup for Hugo blog

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
HUGO_DIR="/Users/curtisgoolsby/Documents/Git/cgoolsby/blog/hugo-site"
PORT=1313

echo -e "${BLUE}=== Hugo Blog Development Environment ===${NC}"

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo -e "${RED}Hugo is not installed. Please install Hugo first:${NC}"
    echo "  brew install hugo"
    exit 1
fi

# Navigate to Hugo directory
cd "$HUGO_DIR"

# Check for npm and install dependencies if needed
echo -e "${YELLOW}Setting up testing tools...${NC}"
if command -v npm &> /dev/null; then
    # Create package.json if it doesn't exist
    if [ ! -f "package.json" ]; then
        cat > package.json << EOF
{
  "name": "curtis-blog",
  "version": "1.0.0",
  "description": "Curtis Goolsby's Blog",
  "scripts": {
    "start": "hugo server -D",
    "build": "hugo --minify",
    "test": "npm run test:links && npm run test:html",
    "test:links": "hugo && lychee ./public/**/*.html",
    "test:html": "hugo && html-validate ./public/**/*.html"
  },
  "devDependencies": {
    "html-validate": "^7.1.2",
    "lychee": "^0.11.1"
  }
}
EOF
        echo "  Created package.json"
    fi
    
    # Install dependencies
    echo "  Installing npm dependencies..."
    npm install --silent
    echo -e "${GREEN}✓ Testing tools installed${NC}"
else
    echo -e "${YELLOW}npm not found. Skipping test tools installation.${NC}"
    echo "  Install Node.js and npm for testing capabilities."
fi

# Create a convenient dev script
cat > dev.sh << EOF
#!/bin/bash
# Start Hugo development server with live reload

# Kill any existing Hugo processes
pkill -f "hugo server" || true

# Start Hugo server
echo "Starting Hugo development server..."
hugo server -D --disableFastRender
EOF

chmod +x dev.sh

echo
echo -e "${GREEN}✓ Development environment setup complete!${NC}"
echo
echo -e "${YELLOW}Available commands:${NC}"
echo "  ./dev.sh                - Start development server with live reload"
echo "  npm test                - Run all tests"
echo "  npm run test:links      - Check for broken links"
echo "  npm run test:html       - Validate HTML"
echo "  hugo new posts/my-post.md - Create a new blog post"
echo
echo -e "${BLUE}Starting development server...${NC}"
echo -e "${BLUE}Visit http://localhost:${PORT} in your browser${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo

# Start the development server
./dev.sh
