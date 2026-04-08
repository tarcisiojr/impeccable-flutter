/**
 * Page template wrapper for generated sub-pages.
 *
 * Reads the shared site header partial once and wraps content bodies with
 * a minimal HTML scaffold that imports tokens.css + sub-pages.css.
 *
 * Used by scripts/build-sub-pages.js (wired up in commit 3).
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = path.resolve(__dirname, '..', '..');
const HEADER_PARTIAL = path.join(ROOT_DIR, 'content', 'site', 'partials', 'header.html');

let cachedHeader = null;

/**
 * Read the shared site header partial.
 * Cached after first read.
 */
export function readHeaderPartial() {
  if (cachedHeader === null) {
    cachedHeader = fs.readFileSync(HEADER_PARTIAL, 'utf8').trim();
  }
  return cachedHeader;
}

/**
 * Mark a nav item as current by adding aria-current="page" and removing
 * the default nav href state. Matches on `data-nav="{activeNav}"`.
 *
 * @param {string} headerHtml
 * @param {string} activeNav - one of: home, skills, anti-patterns, tutorials, gallery, github
 * @returns {string}
 */
export function applyActiveNav(headerHtml, activeNav) {
  if (!activeNav) return headerHtml;
  return headerHtml.replace(
    new RegExp(`data-nav="${activeNav}"`, 'g'),
    `data-nav="${activeNav}" aria-current="page"`,
  );
}

/**
 * Wrap body HTML in a full page shell.
 *
 * @param {object} opts
 * @param {string}   opts.title         - <title> text
 * @param {string}   opts.description   - meta description
 * @param {string}   opts.bodyHtml      - main content HTML (will be placed inside <main>)
 * @param {string}   [opts.activeNav]   - which nav item to mark current
 * @param {string}   [opts.canonicalPath] - relative URL path for <link rel="canonical">
 * @param {string}   [opts.extraHead]   - raw HTML to inject into <head>
 * @param {string}   [opts.bodyClass]   - optional class on <body>
 * @returns {string} full HTML document
 */
export function renderPage({
  title,
  description,
  bodyHtml,
  activeNav,
  canonicalPath,
  extraHead = '',
  bodyClass = 'sub-page',
}) {
  const header = applyActiveNav(readHeaderPartial(), activeNav);
  const safeTitle = escapeHtml(title);
  const safeDesc = escapeAttr(description || '');
  const canonical = canonicalPath
    ? `<link rel="canonical" href="https://impeccable.style${canonicalPath}">`
    : '';

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${safeTitle}</title>
  <meta name="description" content="${safeDesc}">
  <meta name="theme-color" content="#fafafa">
  ${canonical}
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=Instrument+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/css/sub-pages.css">
  ${extraHead}
</head>
<body class="${bodyClass}">
  <a href="#main" class="skip-link">Skip to content</a>
  ${header}
  <main id="main">
${bodyHtml}
  </main>
</body>
</html>
`;
}

function escapeHtml(str) {
  return String(str || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function escapeAttr(str) {
  return String(str || '').replace(/"/g, '&quot;');
}
