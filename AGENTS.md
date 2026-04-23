# Repository Guidelines

## Skill bootstrap: skip the post-update-cleanup step

If you load the Impeccable skill from `.agents/skills/impeccable/SKILL.md` (or any sibling harness directory under this repo), it begins with a `<post-update-cleanup>` block that runs `scripts/cleanup-deprecated.mjs` and then self-deletes. **Do not run it here, and do not delete the block.** This repo is the source of truth for the skill; cleanup-deprecated assumes a consumer project and would touch legitimate source files. The block is regenerated from `source/skills/impeccable/SKILL.md` on every `bun run build`, so any deletion churns back. Skip it silently and proceed with the task.

## Project Structure & Module Organization

`source/` is the source of truth. Author skills in `source/skills/impeccable/` and keep provider output in `dist/` generated, not hand-edited. Build logic lives in `scripts/`, with provider configs in `scripts/lib/transformers/`. Runtime detection code ships from `src/`. The website lives in `public/`, local API/dev serving lives in `server/`, and regression coverage lives in `tests/` with fixtures under `tests/fixtures/`.

## Build, Test, and Development Commands

- `bun run dev` - start the local Bun server.
- `bun run build` - regenerate `dist/`, derived site assets, and validation output.
- `bun run rebuild` - clean and rebuild everything from scratch.
- `bun test tests/build.test.js` - run a focused Bun test.
- `bun run test` - run the full Bun + Node test suite.
- `bun run build:browser` / `bun run build:extension` - rebuild browser-specific bundles.

Run `bun run build` after changing anything in `source/`, transformer code, or user-facing counts.

## Coding Style & Naming Conventions

Use ESM, semicolons, and the existing two-space indentation style in JS, HTML, and CSS. Prefer small, single-purpose modules over large abstractions. Keep filenames descriptive and lowercase with hyphens where needed; skill entrypoints stay as `SKILL.md`, helper scripts use `.js` or `.mjs`. In source frontmatter, use clear kebab-case names and concise descriptions. There is no dedicated formatter or linter configured here, so match surrounding code closely.

## Testing Guidelines

Tests use Bun’s test runner plus Node’s built-in `--test`. Name tests `*.test.js` or `*.test.mjs` and place new fixtures near the behavior they cover, usually under `tests/fixtures/`. Prefer targeted test runs while iterating, then finish with `bun run test`. If you change generated outputs or provider transforms, verify both source parsing and at least one affected provider path in `dist/`.

## Commit & Pull Request Guidelines

Recent history favors short, imperative subjects such as `Fix: ...`, `Add ...`, `Improve ...`, or `Bump ...`. Keep commits focused and explain the user-facing impact when it is not obvious. PRs should summarize what changed, list validation performed, and call out regenerated artifacts like `dist/` or `build/`. Include screenshots for visible `public/` changes and mention affected providers when transform behavior changes.

## Contributor Notes

Do not edit generated provider files directly unless you are intentionally patching generated output as part of a build-system change. Prefer fixing the root source in `source/`, `scripts/`, or `src/`, then regenerate artifacts.
