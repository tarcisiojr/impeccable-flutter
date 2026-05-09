# Changelog

Todos os releases do `impeccable_flutter` (CLI). Segue [Keep a Changelog](https://keepachangelog.com/) e [SemVer](https://semver.org/).

## 0.1.0

### Adicionado — subcomando `skills`

Reduz o gap entre o CLI Dart e o `impeccable` (Node, web upstream):

- `skills install` — clona o repo `tarcisiojr/impeccable-flutter` (shallow via `git`) e copia o skill bundlado para os harness dirs do projeto atual (`.claude/skills/impeccable-flutter/`, `.cursor/skills/...`, etc.). Detecta automaticamente harness dirs já presentes; default `.claude/` quando nada é detectado. Flags: `--target=<harness>` para um único, `--all` para todos os 11 suportados.
- `skills update` — igual a install mas sobrescreve harness dirs existentes (force overwrite).
- `skills check` — compara versão local (lida do `SKILL.md` frontmatter num harness dir) com versão remota (lida do `plugin.json` no GitHub raw). Retorna `Atualizado` ou `Atualização disponível`.

Sem dependências novas: usa `git` shell + `dart:io HttpClient`.

### Mudou

- Description do `pubspec.yaml` reflete a realidade: CLI tem `--fast` próprio + delega ao `custom_lint` para modo full + agora gerencia o skill via `skills install/update/check`.

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
