# impeccable_flutter (CLI)

CLI Dart para detectar anti-padrões de design em apps Flutter, gerenciar a versão do skill `impeccable-flutter` no projeto, e iterar via hot reload.

Pacote irmão de [`impeccable_flutter_lints`](https://pub.dev/packages/impeccable_flutter_lints) (plugin `custom_lint` com 34 regras AST inline). Este CLI complementa esse pacote com um modo `--fast` (regex puro, 2 checks de agregação cross-file que não cabem em `custom_lint`), gerenciamento do skill no projeto e modo live.

Port Flutter do [`impeccable`](https://github.com/pbakaus/impeccable) (web) por Paul Bakaus.

## Instalação

```bash
dart pub global activate impeccable_flutter
```

### Adicionar ao PATH (macOS/Linux com zsh ou bash)

Por default, `~/.pub-cache/bin/` não está no PATH. Sem isso, `impeccable_flutter` retorna `command not found`.

```bash
# zsh (default no macOS recente)
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc

# Confirme
which impeccable_flutter
# /Users/<você>/.pub-cache/bin/impeccable_flutter
```

Sem alterar o PATH, ainda dá pra rodar via:

```bash
dart pub global run impeccable_flutter:impeccable_flutter <args>
```

## Subcomandos

### `detect [path]` — scan estático

Roda detecção sobre o projeto Flutter atual. Dois modos:

```bash
# Full mode (default): delega para `dart run custom_lint` no diretório.
# Cobre as 34 regras AST inline. Requer impeccable_flutter_lints como
# dev_dependency no projeto alvo.
impeccable_flutter detect lib/
impeccable_flutter detect --format=json lib/

# Fast mode: scan regex puro. Cobre as 2 regras cross-file que custom_lint
# não roda (monotonous_spacing, everything_centered) + algumas regras line-level
# como atalho de CI/pre-commit.
impeccable_flutter detect --fast lib/
impeccable_flutter detect --fast --format=json lib/
```

**Schema do output `--format=json`** (unificado nos dois modos, paridade com o `impeccable` web original):

```json
[
  {
    "antipattern": "deep-purple-seed",
    "name": "Deep Purple Seed",
    "description": "Colors.deepPurple é a seedColor default de flutter create.",
    "file": "/path/to/file.dart",
    "line": 20,
    "snippet": "seedColor: Colors.deepPurple",
    "severity": "WARNING",
    "column": 43
  }
]
```

Output é array direto, sem wrapper. `antipattern` é o ID curto em kebab-case (sem o prefix `impeccable_`). Modo full também extrai snippet do source via offsets reportados pelo `custom_lint`.

### `skills install/update/check` — gerenciar o skill no projeto

Instala e mantém o skill `impeccable-flutter` (23 comandos para Claude Code, Cursor, Codex e 9 outros harnesses) no projeto atual.

```bash
# Detecta harness dirs já presentes (.claude/, .cursor/, etc.) e instala
# em cada um. Se nenhum detectado, default .claude/.
impeccable_flutter skills install

# Em todos os 11 harnesses suportados:
impeccable_flutter skills install --all

# Apenas um harness:
impeccable_flutter skills install --target=.cursor

# Sobrescreve harness dir existente (puxa versão mais nova):
impeccable_flutter skills update

# Compara versão local (lida do SKILL.md frontmatter) com versão remota
# (lida do plugin.json no GitHub raw):
impeccable_flutter skills check
```

**Pré-requisito**: `git` disponível no PATH (usado para clone shallow do repo).

**Para Claude Code**: `skills install` é o **caminho recomendado**. O flow alternativo via `/plugin marketplace add tarcisiojr/impeccable-flutter` + `/plugin install impeccable-flutter@impeccable-flutter` esbarra no bug [anthropics/claude-code#18949](https://github.com/anthropics/claude-code/issues/18949) (skills via marketplace plugin não aparecem no autocomplete). `skills install` instala como skill local de projeto e funciona normalmente. **Reinicie o Claude Code** depois de instalar para o autocomplete reconhecer.

### `live` — iteração via hot reload

```bash
impeccable_flutter live
```

v0.1: imprime o workflow manual (você abre `flutter run`, agente edita widget, hot reload aplica). v0.2 (planejado): HTTP server + overlay de seleção via `dart:vm_service` + WidgetInspector. Veja `skill/reference/live.md` no repo.

### `version`

```bash
impeccable_flutter version
```

## Workflow E2E num app Flutter

```bash
cd /meu/app
dart pub add --dev custom_lint impeccable_flutter_lints   # lints package
dart pub global activate impeccable_flutter                # este CLI
impeccable_flutter skills install                          # skill nos harness dirs
impeccable_flutter detect lib/                             # baseline
# Iterar via Claude Code com /impeccable-flutter polish, audit, etc.
impeccable_flutter detect --json lib/ > findings.json      # CI
```

## Roadmap

- v0.2: live mode com HTTP server + overlay
- v0.2: bump de dependências Dart (analyzer 7→13, custom_lint 0.7→0.8)

## Licença

Apache 2.0. Port do [impeccable](https://github.com/pbakaus/impeccable) (web) por Paul Bakaus. Veja `NOTICE.md` no repo.
