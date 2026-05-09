# impeccable_flutter_lints

Plugin [`custom_lint`](https://pub.dev/packages/custom_lint) com **34 regras inline de detecção de anti-padrões de design** para apps Flutter. Cobre AI slop (Material baseline default-look, deepPurple seed, AI color palette, gradient text, bounce easing, gradient AppBar, dark glow, icon-tile stack, hero-eyebrow chip, italic-serif display, monoculture fonts, single-font TextTheme, side-tab borders, rounded accent borders) e quality (preto/branco literal, AnimatedContainer relayout, line length sem maxLines, cramped padding, tight leading, justified text mobile, tiny text, ALL-CAPS body, wide tracking, missing const, theme bypass, missing Semantics, missing tooltip, touch target <48dp, missing SafeArea, MaterialApp sem theme, useMaterial3: false, gray on color, low contrast WCAG, skipped heading).

Pacote irmão de [`impeccable_flutter`](https://pub.dev/packages/impeccable_flutter) (CLI Dart com 2 checks adicionais cross-file via `--fast` e gerenciamento de skill).

Port Flutter do [`impeccable`](https://github.com/pbakaus/impeccable) (web) por Paul Bakaus.

## Instalação

```yaml
# pubspec.yaml do seu app Flutter
dev_dependencies:
  custom_lint: ^0.7.0
  impeccable_flutter_lints: ^0.1.0
```

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
```

```bash
dart run custom_lint
```

Warnings aparecem inline no VS Code e Android Studio (extensão Dart instalada).

Output JSON estruturado:

```bash
dart run custom_lint --format=json
```

Schema `{version, diagnostics: [{code, severity, type, location: {file, range: {start: {offset, line, column}, end: {...}}}, problemMessage, correctionMessage}]}` (padrão do `custom_lint`).

## As 34 regras

### Slop · 14 detectores: tells de UI gerada por IA

| ID | Detecta |
|---|---|
| `impeccable_ai_color_palette` | `Color(0xFF...)` da família roxo/índigo IA (10 hexes específicos). |
| `impeccable_border_accent_on_rounded` | `Border.all(width: >2)` + `borderRadius` arredondado (lê como AI tutorial card). |
| `impeccable_colors_deep_purple_seed` | `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` (default `flutter create`). |
| `impeccable_curves_bounce_elastic` | `Curves.bounce*` ou `Curves.elastic*` (banido em product). |
| `impeccable_dark_glow` | `BoxShadow(blurRadius: >30, color: <saturada>)` em fundo escuro (AI dashboard glow). |
| `impeccable_gradient_text` | `ShaderMask` + `LinearGradient` em `Text` (decorativo, fere hierarquia tipográfica). |
| `impeccable_hero_eyebrow_chip` | `Container` chip arredondado seguido de `Text` display em `Column` (template Stripe-clone). |
| `impeccable_icon_tile_stack` | `Row`/`Wrap`/`GridView` com 3+ Container "Icon + Text" (template SaaS landing). |
| `impeccable_italic_serif_display` | TextStyle italic + serif (Fraunces/Lora/etc.) + fontSize >32 (lane editorial saturada). |
| `impeccable_nested_cards` | `Card` dentro de `Card` (>1 nível). |
| `impeccable_overused_font` | `GoogleFonts.<font>` da reflex-reject list (Inter, DM Sans, Fraunces, Geist, etc.). |
| `impeccable_side_tab` | `Border(left: BorderSide(width: >1, color: <colored>))` desigual (banido absoluto). |
| `impeccable_single_font` | `TextTheme` com mesma `fontFamily` em ≥4 papéis. |
| `impeccable_flat_type_hierarchy` | `TextTheme` com fontSize ratio <1.2 entre papéis adjacentes. |

### Quality · 20 detectores: bugs reais de UX/perf/a11y

| ID | Detecta |
|---|---|
| `impeccable_all_caps_body` | `Text('STRING')` >12 chars todo em uppercase. |
| `impeccable_black_white_literal` | `Colors.black` / `Colors.white` literal (quebra dark mode). |
| `impeccable_cramped_padding` | `EdgeInsets.all(<8)` literal em conteúdo. |
| `impeccable_gray_on_color` | `Container`/`Material`/`Card` com fundo saturado e `Text` cinza descendente (contraste <2.5:1). |
| `impeccable_justified_text` | `Text(textAlign: TextAlign.justify)` em mobile (cria rivers em linhas estreitas). |
| `impeccable_layout_transition` | `AnimatedContainer` mudando width/height/padding/constraints (causa relayout cada frame). |
| `impeccable_line_length` | `Text` com string >100 chars sem `maxLines:`/`softWrap:`. |
| `impeccable_low_contrast` | `Container`/`Material`/`Card` com fundo literal e `Text` literal cuja contraste WCAG é <4.5:1. |
| `impeccable_material_baseline` | `MaterialApp`/`CupertinoApp` sem `theme:`/`darkTheme:` (cai no look default). |
| `impeccable_missing_const_decoration` | `BoxDecoration`/`TextStyle`/`EdgeInsets`/`BorderRadius` literal sem `const` em hot path. |
| `impeccable_missing_safe_area` | `Scaffold(extendBodyBehindAppBar: true)` sem `SafeArea`. |
| `impeccable_missing_semantics` | `GestureDetector`/`InkWell` interativo sem `Semantics`/tooltip/`semanticLabel`. |
| `impeccable_missing_tooltip` | `IconButton` sem `tooltip:` (screen reader lê apenas "botão"). |
| `impeccable_skipped_heading` | Múltiplos `Semantics(header: true, child: Text(_, style: TextStyle(fontSize: <N>)))` num mesmo `build()` com fontSizes fora de ordem decrescente. |
| `impeccable_textstyle_outside_theme` | `TextStyle(...)` literal hard-coded em vez de `Theme.of(context).textTheme.*`. |
| `impeccable_tight_leading` | `TextStyle.height <1.15` em body. |
| `impeccable_tiny_text` | `TextStyle.fontSize <12` sem ser caption. |
| `impeccable_touch_target_too_small` | `IconButton(padding: EdgeInsets.zero)` ou `visualDensity` compact + `iconSize` pequeno (<48dp). |
| `impeccable_use_material3_false` | `useMaterial3: false` literal em ThemeData. |
| `impeccable_wide_tracking` | `TextStyle.letterSpacing >2` em body. |

### Limitações honestas

- `impeccable_low_contrast` resolve só cores literais (`Color(0xFF...)`, `Color.fromARGB`, `Colors.<name>` / `Colors.<name>.shade<N>` via tabela Material). Cores resolvidas em runtime (`Theme.of(context).colorScheme.X`, `Color.lerp`, `withOpacity`) são puladas silenciosamente. Sem falso positivo nesse caso.
- `impeccable_skipped_heading` requer `fontSize` literal nos Text dentro dos Semantics. fontSizes vindos de `textTheme` são pulados.
- `impeccable_gray_on_color` é heurística textual sobre `toSource()`. Cobre os padrões mais comuns; cores resolvidas via scheme não disparam.

### 2 detectores adicionais via `impeccable_flutter` CLI `--fast`

Duas regras de agregação cross-file não rodam dentro do `custom_lint` 0.7.5 (limitação de visitor scope) e ficam no CLI irmão:

- `impeccable_monotonous_spacing` — `EdgeInsets.all(N)` mesmo `N` repetido ≥4× no arquivo.
- `impeccable_everything_centered` — ≥6 `Center` ou `MainAxisAlignment.center` no arquivo.

```bash
dart pub global activate impeccable_flutter
impeccable_flutter detect --fast lib/
```

## Distinto de `flutter_lints`?

`flutter_lints` (Flutter team) cobre code style e correctness (`prefer_const_constructors`, `use_super_parameters`, etc.). Este pacote cobre design choices (color palette, typography hierarchy, motion vocabulary, accessibility hooks, contraste WCAG). Os dois rodam juntos via `custom_lint` sem conflito.

## Roadmap

- v0.2: bump `analyzer` 7→13, `custom_lint` 0.7→0.8
- v0.2: type-flow real para `low_contrast` (cobrir cores via scheme)

## Desenvolvimento

```bash
cd lints
dart pub get
dart analyze
dart test  # 35 integration tests via custom_lint contra example/
```

Para testar contra um app Flutter real localmente:

```yaml
# Em pubspec.yaml do app-cobaia:
dev_dependencies:
  impeccable_flutter_lints:
    path: ../path/to/this/repo/lints
```

## Licença

Apache 2.0. Port Flutter do [impeccable](https://github.com/pbakaus/impeccable) (web) por Paul Bakaus. Veja `NOTICE.md` no repo.
