# Notice

impeccable-flutter
Copyright 2026 Tarcísio Júnior

Port of [`impeccable`](https://github.com/pbakaus/impeccable) for the Flutter ecosystem.

## Original impeccable (web)

This project is a Flutter port of Paul Bakaus's `impeccable`, a design toolbox for web frontends.

**Original work:** https://github.com/pbakaus/impeccable
**Original license:** Apache License 2.0
**Copyright:** 2025-2026 Paul Bakaus

The Flutter port shares the design philosophy, the command surface (23 commands), and the brand-vs-product register. The skill references and the detector are rewritten from the ground up for Material 3 / Cupertino / Dart AST.

## Anthropic frontend-design Skill

The original `impeccable` (web) was itself based on Anthropic's frontend-design skill. The lineage carries through to this Flutter port.

**Original work:** https://github.com/anthropics/skills/tree/main/skills/frontend-design
**Original license:** Apache License 2.0
**Copyright:** 2025 Anthropic, PBC

## Typecraft Guide Skill

The `typography.md` reference incorporates tactical additions originally merged into upstream `impeccable` from ehmo's `typecraft-guide-skill` (with the author's consent): dark-mode weight/tracking compensation, `font-display: optional` vs `swap` (in upstream), preload-critical-weight-only guidance, variable fonts for 3+ weights, responsive measure/container coupling, ALL-CAPS tracking quantification, paragraph-rhythm rule.

The Flutter port adapts these to TextTheme + GoogleFonts vocabulary where applicable.

**Original work:** https://github.com/ehmo/typecraft-guide-skill
**Original license:** see upstream repo
**Author:** ehmo
