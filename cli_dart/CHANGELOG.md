# Changelog

Todos os releases do `impeccable_flutter` (CLI). Segue [Keep a Changelog](https://keepachangelog.com/) e [SemVer](https://semver.org/).

## 0.1.2

### Documentação

- README ganha seção explícita "Adicionar ao PATH" para macOS/Linux com zsh ou bash. Por default, `~/.pub-cache/bin/` não está no PATH e `dart pub global activate impeccable_flutter` deixa o binário "instalado mas inacessível". Snippet copy-paste com `~/.zshrc` / `~/.bashrc` resolve.
- Workaround sem alterar PATH documentado: `dart pub global run impeccable_flutter:impeccable_flutter <args>`.
- Seção `skills install` corrigida: agora é o **caminho recomendado para Claude Code também** (não mais "para harnesses sem marketplace"). Inclui referência ao bug [anthropics/claude-code#18949](https://github.com/anthropics/claude-code/issues/18949) que torna o flow `/plugin install` inviável para skills hoje.

## 0.1.1

### Adicionado

- **Schema JSON unificado** entre `detect --fast --format=json` e `detect --format=json` (full mode). Os dois agora emitem o mesmo array `[{antipattern, name, description, file, line, snippet, severity, column}]`, com paridade ao schema do `impeccable` (web) original. Antes: o full mode emitia o schema bruto do `custom_lint` (`{version, diagnostics: [{code, location: {range: ...}, ...}]}`) e o fast mode emitia um schema próprio (`{mode, count, findings: [...]}`). Agora um único parser cobre ambos os modos para CI e ferramentas downstream.

### Documentação

- README reescrito refletindo o estado real do CLI: removido o "pré-MVP, empacotamento pub.dev TODO" e a roadmap que listava `--fast`, JSON e empacotamento como TODO. Substituído pelo subcomandos atuais (detect com full e --fast e --json, skills install/update/check, live, version), workflow E2E e schema do output JSON.

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
