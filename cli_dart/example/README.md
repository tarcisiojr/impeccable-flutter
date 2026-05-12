# Exemplo — `impeccable_flutter`

Demonstra o uso programático do scanner `--fast` (regex-only, sem analyzer)
sobre um snippet inline de Flutter cheio de anti-padrões.

## Rodar

```bash
dart run example/main.dart
```

## Output esperado

JSON no mesmo schema do `impeccable` web original (paridade com `--fast --format=json`):

```json
[
  {
    "antipattern": "deep-purple-seed",
    "name": "Deep Purple Seed",
    "description": "Colors.deepPurple seed = look \"flutter create\".",
    "file": "/tmp/impeccable_example_XXX/sample.dart",
    "line": 11,
    "snippet": "        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),",
    "severity": "WARNING",
    "column": 1
  },
  ...
]

→ 3 finding(s) detected.
```

## Uso real (no seu app Flutter)

```bash
dart pub global activate impeccable_flutter
cd /seu/app/flutter
impeccable_flutter detect --fast --format=json lib/
```

Para regras AST inline com squiggles na IDE, instale também o pacote irmão
[`impeccable_flutter_lints`](https://pub.dev/packages/impeccable_flutter_lints)
via `custom_lint`.

Veja o [README principal](../README.md) para todos os subcomandos.
