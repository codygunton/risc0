# RISC Zero Developer Website

## Overview

This is the main documentation website for RISC Zero, built using Docusaurus 3.7.0. It serves as the primary hub for developer documentation, educational resources, and technical guides for the RISC Zero zero-knowledge computing platform.

## Architecture

### Technology Stack
- **Framework**: Docusaurus (React-based static site generator)
- **Package Manager**: Bun
- **Styling**: CSS modules, custom CSS
- **Documentation**: Markdown/MDX files with versioning support
- **Math Rendering**: KaTeX via rehype-katex
- **Diagrams**: Mermaid.js integration
- **Code Highlighting**: Prism with custom Rust syntax support

### Key Components

#### Content Structure
- **`/api/`** - Current API documentation
- **`/api_versioned_docs/`** - Historical API documentation (versions 0.18-2.3)
- **`/docs/`** - General documentation (proof system, reference docs, study club)
- **`/src/`** - React components and custom code
- **`/static/`** - Static assets (images, PDFs, diagrams)

#### Core Features
- **Multi-version Documentation**: Supports multiple API versions with separate documentation trees
- **Interactive Elements**: Mermaid diagrams for sequence flows and architectural diagrams  
- **Mathematical Notation**: LaTeX math rendering for cryptographic concepts
- **Code Examples**: Syntax-highlighted Rust code with custom processing
- **OG Image Generation**: Automated social media preview images

#### Main Documentation Sections
1. **ZKVM Documentation**: Core zero-knowledge virtual machine guides
2. **Blockchain Integration**: Ethereum and other blockchain platform guides  
3. **Proof Generation**: Local and remote proving workflows
4. **Developer Guides**: Getting started, optimization, profiling
5. **Educational Content**: Proof system theory, STARK explanations

### Build System

#### Development Workflow
```bash
bun install          # Install dependencies
bun run start        # Local development server
bun run build        # Production build
bun run lint         # Code quality checks
```

#### Quality Assurance
- **Prettier**: Code formatting
- **Remark**: Markdown linting and processing
- **Link Validation**: Custom Python script for version link checking
- **Broken Link Detection**: Docusaurus built-in link validation

### Key Files

#### Configuration
- **`docusaurus.config.js`** - Main Docusaurus configuration
- **`sidebars.js`** - Documentation navigation structure  
- **`package.json`** - Dependencies and build scripts

#### Custom Components
- **`src/components/HomepageFeatures/`** - Landing page feature showcase
- **`src/components/Mermaid/`** - Custom Mermaid diagram components
- **`src/remark/rust.js`** - Custom Rust code processing

#### Content Management
- **`api_versions.json`** - Version configuration for API docs
- **`remark-append-md.js`** - Custom Remark plugin for content processing

## Development Guidelines

### Content Creation
- Use MDX for interactive documentation pages
- Follow existing patterns for code examples and mathematical notation
- Maintain consistent terminology as defined in `docs/terminology.md`
- Add appropriate version tags for API documentation

### Code Style
- Follow Prettier configuration for consistent formatting
- Use semantic HTML and accessible markup patterns
- Leverage Docusaurus components for consistent UI

### Documentation Standards
- Mathematical concepts should use KaTeX rendering
- Code examples should include proper syntax highlighting
- Diagrams should be created using Mermaid when possible
- Images should be optimized and include alt text

## Integration Points

### External Dependencies
- **RISC Zero Core**: Documentation reflects the main risc0 repository structure
- **API Versioning**: Synchronized with risc0 release versions
- **Example Code**: Links to and embeds code from risc0 examples

### Deployment
- Static site generation for hosting flexibility
- GitHub Pages deployment support
- Custom domain configuration (dev.risczero.com)

## Maintenance Notes

### Version Management
- API documentation versions track risc0 releases
- Legacy versions maintained for backward compatibility
- Version-specific sidebars in `api_versioned_sidebars/`

### Content Updates
- Educational content in `/docs/` is version-agnostic
- API documentation should be updated with each risc0 release
- External links require validation via link-version-check.py

### Performance Considerations
- Static site generation enables fast loading
- Image optimization for bandwidth efficiency
- Lazy loading of interactive components