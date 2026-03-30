# Project Instructions for Claude

## CSS Build Process

**IMPORTANT**: After modifying any CSS files in `public/css/` (especially `workflow.css` or `main.css`), you MUST rebuild the Tailwind CSS:

```bash
bunx @tailwindcss/cli -i public/css/main.css -o public/css/styles.css
```

The CSS architecture:
- `public/css/main.css` - Main entry point, imports Tailwind and all other CSS files
- `public/css/workflow.css` - Commands section, glass terminal, case studies styles
- `public/css/styles.css` - **Compiled output** (do not edit directly)

## Development Server

```bash
bun run dev        # Bun dev server at http://localhost:3000
bun run preview    # Build + Cloudflare Pages local preview
```

## Deployment

Hosted on Cloudflare Pages. Static assets served from `build/`, API routes handled via `_redirects` rewrites (JSON) and Pages Functions (downloads).

```bash
bun run deploy     # Build + deploy to Cloudflare Pages
```

## Build System

The build system compiles skills and commands from `source/` to provider-specific formats in `dist/`:

```bash
bun run build      # Build all providers
bun run rebuild    # Clean and rebuild
```

Source files use placeholders that get replaced per-provider:
- `{{model}}` - Model name (Claude, Gemini, GPT, etc.)
- `{{config_file}}` - Config file name (CLAUDE.md, .cursorrules, etc.)
- `{{ask_instruction}}` - How to ask user questions

## Testing

```bash
bun run test       # Run all tests
```

Unit tests (build, detector logic) run via `bun test`. Fixture tests (jsdom-based HTML detection) run via `node --test` because bun is too slow with jsdom. The `test` script handles this split automatically.

## CLI

Impeccable includes a CLI for running anti-pattern detection outside of AI harnesses:

```bash
bun bin/impeccable detect [file-or-dir-or-url...]   # detect anti-patterns
bun bin/impeccable detect --fast --json src/         # regex-only, JSON output
bun bin/impeccable --help                            # show help
```

The detection script is at `source/skills/critique/scripts/detect-antipatterns.mjs`. It auto-detects browser vs Node and works as both:
- **CLI/Node**: jsdom for HTML, regex for CSS/JSX/TSX, Puppeteer for URLs
- **Browser**: visual overlays injected via `<script src="/js/detect-antipatterns-browser.js">`

Build the browser script: `node scripts/build-browser-detector.js`

## Versioning

When bumping the version, update **all** of these locations to keep them in sync:

- `package.json` → `version`
- `.claude-plugin/plugin.json` → `version`
- `.claude-plugin/marketplace.json` → `plugins[0].version`
- `public/index.html` → hero version link text + new changelog entry (user-facing changes only, not internal build/tooling details)

## Adding New Skills

When adding a new user-invocable skill, update the command count in **all** of these locations:

- `public/index.html` → meta descriptions, hero box, section lead
- `public/cheatsheet.html` → meta description, subtitle, `commandCategories`, `commandRelationships`
- `public/js/data.js` → `commandProcessSteps`, `commandCategories`, `commandRelationships`
- `public/js/components/framework-viz.js` → `commandSymbols`, `commandNumbers`
- `public/js/demos/commands/` → new demo file + import in `index.js`
- `README.md` → intro, command count, commands table
- `NOTICE.md` → steering commands count
- `AGENTS.md` → intro command count
- `.claude-plugin/plugin.json` → description
- `.claude-plugin/marketplace.json` → metadata description + plugin description
