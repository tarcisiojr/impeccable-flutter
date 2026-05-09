# Impeccable Flutter

Design fluency for Flutter apps. **1 skill, 23 commands, 36 anti-pattern detection checks** for Material 3 / Cupertino. The vocabulary you didn't know you needed, now in Flutter.

> **Heritage:** Port of [impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus, originally a design toolbox for web frontends. This repo is the Flutter sibling: same conceptual core, fully rewritten for Material 3 / Cupertino / Dart AST. See **Credits** at the bottom.

## Why Impeccable Flutter?

Every Flutter app trained on the same Material baseline: `Colors.deepPurple` seed, `Inter` font, `BoxShadow` blur 30 with brand-tinted glow, `Curves.elasticOut`, gradient `AppBar`, `Container` chip above every hero `Text`. Skip the design intentionality and you ship the same look-and-feel on every project.

This skill adds:

- **13 domain reference files** ([`skill/reference/`](skill/reference/)). Typography (TextTheme), color (ColorScheme.fromSeed), motion (Material Motion), spatial (EdgeInsets), interaction (WidgetState), responsive (NavigationBar↔Rail↔Drawer), UX writing, plus a brand-vs-product register that adjusts the defaults.
- **23 commands.** A shared design vocabulary with your AI: `/impeccable-flutter polish`, `/impeccable-flutter audit`, `/impeccable-flutter critique`, `/impeccable-flutter colorize`, `/impeccable-flutter typeset`, etc.
- **36 anti-pattern detection checks** via `custom_lint` (34 inline) plus `--fast` regex scanner (2 aggregation passes). Inline IDE warnings for slop (deepPurple seed, AI color palette, gradient text, bounce easing) and quality (missing Semantics, touch target <48dp, missing tooltip, theme bypass, low contrast WCAG, gray on saturated, skipped heading).

## Three Pieces

This project ships three independent components. Pick the ones you need.

| Component | Where | What it does |
|---|---|---|
| `impeccable_flutter_lints` | [pub.dev](https://pub.dev/packages/impeccable_flutter_lints) | `custom_lint` plugin. 31 inline AST rules for IDE squiggles. |
| `impeccable_flutter` (CLI) | [pub.dev](https://pub.dev/packages/impeccable_flutter) | Dart CLI: `detect`, `live`, `version`. Adds 2 aggregation rules in `--fast` mode. |
| `impeccable-flutter` (skill) | this repo as Claude Code plugin | 23 commands the AI agent can invoke. Coexists with the original `/impeccable` (web): see Coexistence. |

## Install

### 1. Lints (inline IDE warnings)

In your Flutter app:

```bash
dart pub add --dev custom_lint impeccable_flutter_lints
```

Edit `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
```

Run:

```bash
dart run custom_lint
```

Warnings appear inline in VS Code and Android Studio (Dart extension required).

### 2. CLI (one-shot scan or live mode)

```bash
dart pub global activate impeccable_flutter

impeccable_flutter detect lib/                  # full scan
impeccable_flutter detect --fast lib/           # regex-only (faster, smaller scope)
impeccable_flutter detect --json lib/           # JSON output for CI
impeccable_flutter live                         # live iteration workflow (v0.1: edit + hot reload)
impeccable_flutter --version
```

### 3. Skill in Claude Code (the 23 commands)

This repo is published as a Claude Code plugin via marketplace. To install:

```
/plugin marketplace add tarcisiojr/impeccable-flutter
/plugin install impeccable-flutter
```

Once installed, the 23 commands become available:

```
/impeccable-flutter teach            # one-time setup: gather PRODUCT.md + DESIGN.md context
/impeccable-flutter shape            # plan UX/UI before writing widgets
/impeccable-flutter craft            # full shape-then-build flow
/impeccable-flutter polish           # final design pass + system alignment
/impeccable-flutter audit            # deterministic detector + LLM heuristics review
/impeccable-flutter critique         # UX review: hierarchy, clarity, emotional resonance
/impeccable-flutter clarify          # improve unclear UX copy
/impeccable-flutter document         # extract DESIGN.md from existing lib/ code
/impeccable-flutter extract          # consolidate tokens into ThemeData
/impeccable-flutter bolder           # amplify boring designs
/impeccable-flutter quieter          # tone down overly bold designs
/impeccable-flutter distill          # strip to essence
/impeccable-flutter harden           # text overflow, RTL, intl, low-memory edges
/impeccable-flutter onboard          # first-run, empty states, activation paths
/impeccable-flutter animate          # purposeful motion (implicit/explicit, Hero, SharedAxis)
/impeccable-flutter colorize         # ColorScheme.fromSeed exploration
/impeccable-flutter typeset          # TextTheme + GoogleFonts choice
/impeccable-flutter layout           # EdgeInsets, SizedBox, Flex hygiene
/impeccable-flutter delight          # micro-interactions
/impeccable-flutter overdrive        # CustomPainter, flutter_shaders, Rive
/impeccable-flutter adapt            # NavigationBar↔Rail↔Drawer, foldables, SafeArea
/impeccable-flutter optimize         # rebuild count, raster budget, app size
/impeccable-flutter live             # iterate via hot reload (v0.1: manual workflow)
```

Use `/impeccable-flutter pin <command>` to create standalone shortcuts (e.g., `pin audit` creates `/audit`).

## Coexistence with the original `/impeccable` (web)

Paul Bakaus's [`impeccable`](https://github.com/pbakaus/impeccable) targets web frontends (HTML/CSS, Astro, React, Tailwind). This Flutter sibling keeps the same design philosophy but speaks Material 3 / Cupertino. Both can be installed in the same Claude Code:

```
You type /
  ↓
  /impeccable polish              ← web (Paul's plugin, npm impeccable)
  /impeccable audit
  ...
  /impeccable-flutter polish      ← Flutter (this plugin, marketplace)
  /impeccable-flutter audit
  ...
```

No `enable`/`disable` per project. The agent picks the right one based on what you're working on (or you call it explicitly).

## Workflow Example

```bash
# 1. Setup
cd ~/myapp
dart pub add --dev custom_lint impeccable_flutter_lints
dart pub global activate impeccable_flutter
# In Claude Code: /plugin install impeccable-flutter

# 2. One-time discovery
/impeccable-flutter teach
# → agent interviews you, writes PRODUCT.md + DESIGN.md

# 3. Baseline detect
impeccable_flutter detect lib/
# → list of slop + quality findings

# 4. Polish a screen
/impeccable-flutter polish lib/screens/home.dart

# 5. Iterate live
flutter run -d <device>     # in one terminal
/impeccable-flutter live    # in Claude Code
# Agent edits source → hot reload → you accept/discard variants

# 6. Final audit
/impeccable-flutter audit
```

## Anti-patterns Detected

The detectors are organized in two categories.

### Slop · 16 detectors: AI tells

Bounce/elastic easing, deep-purple seed, AI color palette (10 reflex hexes), gradient text via ShaderMask, dark glow shadows, icon-tile stacks, italic-serif display, hero-eyebrow chips, monotonous spacing, everything centered, nested cards, overused fonts (GoogleFonts.Inter/DMSans/Fraunces…), single-font TextTheme, side-tab borders, rounded accent borders.

### Quality · 20 detectors: real UX/perf bugs

Pure black/white literals, AnimatedContainer relayout, line-length without maxLines, cramped padding, tight leading, justified text on mobile, tiny text, all-caps body, wide tracking, missing const on hot-path decorations, TextStyle outside theme, missing Semantics on InkWell, missing tooltip on IconButton, touch target <48dp, missing SafeArea on extendBodyBehindAppBar, MaterialApp without theme, useMaterial3: false, **gray-on-color** (cinza sobre fundo saturado), **low-contrast** (WCAG AA <4.5:1 com cores literais), **skipped-heading** (Semantics(header: true) fora de ordem decrescente no mesmo build).

### About low-contrast resolution

`low-contrast` resolve cores LITERAIS: `Color(0xFF...)`, `Color.fromARGB(...)`, e `Colors.<name>` / `Colors.<name>.shade<N>` da paleta Material. Cores resolvidas em runtime (`Theme.of(context).colorScheme.X`, `Color.lerp`, `withOpacity`) são puladas silenciosamente. Falsos positivos só ocorrem quando ambas as cores foram extraídas com confiança e a conta de luminância dá <4.5:1.

## Distinct from `flutter_lints`?

`flutter_lints` (Flutter team) covers code style and correctness (`prefer_const_constructors`, `use_super_parameters`, etc.). `impeccable_flutter_lints` covers design choices (color palette, typography hierarchy, motion vocabulary, accessibility hooks). Both run together via `custom_lint`.

## Status

- **v0.1.1**: 36 of 36 planned checks complete. 23 commands. Skill bundles for 13 harness directories.
- **Live mode v0.1**: manual workflow via hot reload. v0.2 (overlay + VM Service + WidgetInspector) planned.
- **3 complex checks** pending: low-contrast, gray-on-color, skipped-heading.
- See [`FLUTTER-PORT.md`](FLUTTER-PORT.md) for the full status tracker.

## Credits

This project is a port of [`impeccable`](https://github.com/pbakaus/impeccable) by **Paul Bakaus** ([@pbakaus](https://github.com/pbakaus)). The original targets web frontends; this Flutter sibling shares the design philosophy, the command surface, and the brand-vs-product register, while rewriting the references and the detector from the ground up for the Flutter ecosystem.

The original impeccable was itself based on Anthropic's [frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) skill. See [`NOTICE.md`](NOTICE.md) for the full attribution chain.

## License

Apache 2.0. See [`LICENSE`](LICENSE).
