# Changelog

Todos os releases do `impeccable_flutter` (CLI). Segue [Keep a Changelog](https://keepachangelog.com/) e [SemVer](https://semver.org/).

## 0.0.1 (initial release)

### Adicionados — subcomandos

- `detect [path]` — wrapper sobre `dart run custom_lint`. Roda as regras do `impeccable_flutter_lints` sobre o projeto. Suporta `--format=human|json` e `--fast`.
- `detect --fast [path]` — scanner regex puro, sem analyzer. Cobre 9 regras (deep_purple_seed, bounce_elastic_curve, black_white_literal, justified_text, use_material3_false, ai_color_palette, overused_font, monotonous_spacing, everything_centered). Útil para CI rápido pré-commit ou codebases >500 arquivos.
- `live` — stub MVP. Documenta o workflow manual via hot reload (descrito em `skill/reference/live.md`). v0.2 ganha overlay de seleção via VM Service.
- `version` — imprime versão do CLI.

### Testes

- 13 unit tests do `--fast` scanner via `dart test`. Cobrem todas as 9 regras + casos negativos (clean code, comments, generated files).

### Conhecido — pendente

- Empacotamento pub.dev (homepage/repository links no pubspec, polish do README, badges).
- `live` overlay v0.2 (HTTP server + VM Service + WidgetInspector).
