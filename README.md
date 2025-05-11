# Curtis' Blog - Hugo Implementation

This repository contains a Hugo-based implementation of Curtis Goolsby's personal blog, with GitHub Pages hosting and CI/CD workflows.

## Overview

This blog is built with Hugo and can be hosted on GitHub Pages or your own custom domain. This approach offers several advantages:

- **Zero cost hosting** through GitHub Pages
- **Automated deployments** via GitHub Actions
- **Improved performance** through static site delivery
- **Simple content management** with Markdown files

## Local Development

### Prerequisites

1. [Hugo Extended](https://gohugo.io/installation/) (version 0.147.2 or later)
2. Git

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/cgoolsby/my-blog.git
   cd my-blog
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

## Project Structure

### Content
- `content/posts/` - Blog posts (currently contains "validating-admission-policies.md")
- `content/about.md` - About page

### Configuration and Templates
- `config.yaml` - Main site configuration
- `layouts/` - HTML templates and customizations
- `static/` - Static assets (images, CSS, etc.)
- `archetypes/` - Content templates
- `assets/` - Files for processing by Hugo pipes

## Theme

This blog uses the [Hugo Paper](https://github.com/nanxiaobei/hugo-paper) theme, imported as a Hugo module in the `config.yaml` file.

## Deployment Workflows

### GitHub Pages Deployment

The site is automatically deployed when changes are pushed to the `main` branch. The workflow:

1. Runs tests (HTML validation, link checking)
2. Builds the site with Hugo
3. Deploys to GitHub Pages

## Custom Domain Setup

To use a custom domain with this site:

1. Update the `baseURL` in `config.yaml` to your domain
2. Add a `CNAME` file in the `static/` directory with your domain name
3. Configure your domain's DNS settings to point to GitHub Pages
4. Enable HTTPS in the GitHub repository settings

## Customization

### Site Configuration

Edit `config.yaml` to modify:
- Site title and description
- Author information
- Menu structure
- Social media links

### Visual Styling

Custom CSS can be added in the `static/css/` directory and referenced in the `config.yaml` file.

## License

Copyright 2025 Curtis Goolsby. All rights reserved.
