# Curtis' Blog - Hugo Implementation

This repository contains a Hugo-based implementation of Curtis Goolsby's personal blog, with GitHub Pages hosting and comprehensive CI/CD workflows.

## Overview

This blog has been transitioned from a custom Go web application to a static site generated with Hugo and hosted on GitHub Pages. This approach offers several advantages:

- **Zero cost hosting** through GitHub Pages
- **Automated deployments** via GitHub Actions
- **Separate staging environment** for content previews
- **Comprehensive testing** for quality assurance
- **Improved performance** through static site delivery

## Local Development

### Prerequisites

1. [Hugo Extended](https://gohugo.io/installation/) (latest version)
2. Git

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/cgoolsby/blog.git
   cd blog/hugo-site
   ```

2. Start the Hugo development server:
   ```bash
   hugo server -D
   ```

3. Visit http://localhost:1313 in your browser

### Creating New Content

Create a new blog post:

```bash
hugo new content posts/my-new-post.md
```

This will create a new post with the appropriate frontmatter template.

## Content Structure

- `content/posts/` - Blog posts
- `content/about.md` - About page
- `static/` - Static assets (images, CSS, etc.)
- `layouts/` - HTML templates
- `config.yaml` - Main site configuration

## Deployment Workflows

### Production Deployment

The production site is automatically deployed when changes are pushed to the `main` branch. The workflow:

1. Runs tests (HTML validation, link checking)
2. Builds the site with Hugo
3. Deploys to GitHub Pages

### Staging Environment

A staging environment is available for previewing content before publishing:

- Automatically deployed from the `staging` branch
- Available at: https://cgoolsby.github.io/blog/staging/
- Includes draft posts and future-dated content
- Features a prominent "STAGING" banner

For pull requests, a preview link is automatically added as a comment.

## Testing Framework

The site includes comprehensive testing:

- **HTML Validation** - Ensures valid HTML5
- **Link Checking** - Identifies broken links
- **Accessibility Testing** - Verifies WCAG compliance
- **Performance Testing** - Checks page load performance

Run tests locally:

```bash
# Install dependencies
npm install -g lighthouse html-validator

# Run tests
hugo
html-validator --root public/
lighthouse http://localhost:1313 --view
```

## Workflow for Publishing Content

1. Create a new branch for your content:
   ```bash
   git checkout -b post/my-new-article
   ```

2. Create and edit your content:
   ```bash
   hugo new content posts/my-new-article.md
   # Edit the file in your preferred editor
   ```

3. Preview locally:
   ```bash
   hugo server -D
   ```

4. Submit a pull request to the `staging` branch
5. Review the staging preview
6. When ready, merge to `main` to publish

## Directory Structure

```
hugo-site/
├── archetypes/     # Content templates
├── assets/         # For processing by Hugo pipes
├── config/         # Environment-specific configurations
│   └── staging/    # Staging environment config
├── content/        # Markdown content files
│   └── posts/      # Blog posts
├── layouts/        # HTML templates
│   ├── _default/   # Default templates
│   ├── partials/   # Reusable template parts
│   └── shortcodes/ # Custom shortcodes
├── static/         # Static assets
│   ├── css/        # Stylesheets
│   ├── images/     # Images
│   └── js/         # JavaScript files
└── themes/         # Hugo themes (if used)
```

## Customization

### Site Configuration

Edit `config.yaml` to modify:
- Site title and description
- Author information
- Menu structure
- Social media links

### Visual Styling

- Main styling: `static/css/custom.css`
- Syntax highlighting: `static/css/syntax.css`
- Staging banner: `static/css/staging.css`

## License

Copyright © 2025 Curtis Goolsby. All rights reserved.
