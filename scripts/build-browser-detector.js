#!/usr/bin/env node

/**
 * Generates .claude/skills/critique/scripts/detect-antipatterns-browser.js
 * by stripping Node-specific sections from the universal source and wrapping in an IIFE.
 *
 * Run: node scripts/build-browser-detector.js
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');

const SOURCE = path.join(ROOT, 'source/skills/critique/scripts/detect-antipatterns.mjs');
const OUTPUT = path.join(ROOT, '.claude/skills/critique/scripts/detect-antipatterns-browser.js');
// Also output next to source so the CLI's URL scanner can find it
const OUTPUT_CLI = path.join(ROOT, 'source/skills/critique/scripts/detect-antipatterns-browser.js');

let code = fs.readFileSync(SOURCE, 'utf-8');

// Strip shebang
code = code.replace(/^#!.*\n/, '');
// Strip sections between @browser-strip-start / @browser-strip-end markers
code = code.replace(/^\/\/ @browser-strip-start\n[\s\S]*?^\/\/ @browser-strip-end\n?/gm, '');
// Set IS_BROWSER = true (dead-code eliminates Node paths)
code = code.replace(/^const IS_BROWSER = .*$/m, 'const IS_BROWSER = true;');

const output = `/**
 * Anti-Pattern Browser Detector for Impeccable
 * GENERATED — do not edit. Source: detect-antipatterns.mjs
 * Rebuild: node scripts/build-browser-detector.js
 *
 * Usage: <script src="detect-antipatterns-browser.js"></script>
 * Re-scan: window.impeccableScan()
 */
(function () {
if (typeof window === 'undefined') return;
${code}
})();
`;

fs.mkdirSync(path.dirname(OUTPUT), { recursive: true });
fs.writeFileSync(OUTPUT, output);
fs.writeFileSync(OUTPUT_CLI, output);
console.log(`\u2713 Generated ${path.relative(ROOT, OUTPUT)} (${(output.length / 1024).toFixed(1)} KB)`);
