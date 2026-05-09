# impeccable_flutter_lints

Detector estático de anti-padrões de design para apps Flutter. Plugin [`custom_lint`](https://pub.dev/packages/custom_lint) que cobre AI slop e qualidade.

**Status**: pré-MVP. 5 regras proof-of-concept. ~30 regras planejadas (ver `FLUTTER-PORT.md` na raiz do repo).

## Instalação

```yaml
# pubspec.yaml
dev_dependencies:
  custom_lint: ^0.7.0
  impeccable_flutter_lints: ^0.0.1
```

```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint
```

```bash
dart run custom_lint
```

## Regras implementadas (5)

| ID | Categoria | Detecta |
|---|---|---|
| `impeccable_deep_purple_seed` | slop | `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` (default `flutter create`) |
| `impeccable_bounce_elastic_curve` | slop | `Curves.bounce*` ou `Curves.elastic*` (banidos em product) |
| `impeccable_black_white_literal` | quality | `Colors.black` / `Colors.white` literal (quebra dark mode) |
| `impeccable_missing_tooltip` | quality | `IconButton` sem `tooltip:` (screen reader cego) |
| `impeccable_textstyle_outside_theme` | quality | `TextStyle(...)` literal em vez de `textTheme.X` |

## Regras planejadas (~30)

Veja a tabela completa em `FLUTTER-PORT.md` na raiz do repo. Resumo dos slots:

- 15 regras slop herdadas do impeccable web (gradient text, ai-color-palette, nested cards, monotonous spacing, everything centered, dark glow, icon tile stack, italic serif display, hero eyebrow chip, etc.).
- 12 regras quality herdadas (gray on color, low contrast, layout transition, line length, cramped padding, tight leading, skipped heading, justified text, tiny text, all caps body, wide tracking).
- 7 regras novas Flutter-only: `missing-const`, `theme-bypass`, `missing-semantics`, `touch-target-too-small`, `missing-safe-area`, `material-baseline`, `useMaterial3-false`.

## Limitações honestas

- Análise estática não vê contraste real renderizado (cor resolvida via Material You depende do device). Para essas, considere golden tests em v2.
- Composições que dependem de runtime (touch target só vira <48 quando `Wrap` empilha) precisam runtime. Assumimos worst-case.
- Algumas regras proof acima usam heurística simples (string match em `toSource()`); versões finais devem usar análise tipada via `analyzer` para reduzir falso-positivo.

## Desenvolvimento

```bash
cd lints
dart pub get
dart analyze
dart test
```

Para testar contra um projeto Flutter real localmente:

```yaml
# Em pubspec.yaml do projeto-cobaia:
dev_dependencies:
  impeccable_flutter_lints:
    path: ../path/to/this/repo/lints
```

## Licença

Apache 2.0. Baseado no impeccable (web). Veja `NOTICE.md` na raiz do repo.
