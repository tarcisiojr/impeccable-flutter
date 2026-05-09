# Changelog

Todos os releases do `impeccable_flutter_lints`. Segue [Keep a Changelog](https://keepachangelog.com/) e [SemVer](https://semver.org/).

## 0.1.0

### Adicionadas — 3 regras de a11y/contraste (cobertura agora 34 inline + 2 cross-file = 36)

- `impeccable_gray_on_color` (quality) — `Container`/`Material`/`Card` com fundo de cor saturada (`Colors.blue`, `Colors.purple`, etc.) envolvendo `Text` com `TextStyle.color: Colors.grey*`. Padrão clássico de dashboards e marketing screens em apps "modernos"; cinza fica próximo do fundo saturado e contraste cai para 1.5–2.5:1 (WCAG AA exige 4.5:1).
- `impeccable_low_contrast` (quality) — `Container`/`Material`/`Card` com fundo literal e `Text` descendente com `TextStyle.color` literal cujo contraste WCAG é < 4.5:1. Resolve cores via tabela do Material palette + `Color(0xFF...)` literal + `Color.fromARGB`. Cores resolvidas em runtime (`Theme.of`, `Color.lerp`, `withOpacity`) são puladas silenciosamente. Sem falsos positivos quando ambas as cores podem ser resolvidas com confiança.
- `impeccable_skipped_heading` (quality) — Múltiplos `Semantics(header: true, child: Text(_, style: TextStyle(fontSize: <N>)))` dentro de um mesmo método `build()` cujos fontSizes não estão em ordem decrescente (h1 → h2 → h3). Isolamento por método evita falsos positivos quando widgets distintos no mesmo arquivo têm headings independentes.

### Mudou

- README e contagens atualizadas: 33 → 36 detectores (34 via custom_lint inline + 2 cross-file via `impeccable_flutter` `--fast`).

## 0.0.1 (initial release)

### Adicionadas — 25 regras de detecção

**Slop (10):**
- `impeccable_ai_color_palette` — `Color(0xFF<hex>)` da família roxo/índigo IA (10 hexes).
- `impeccable_border_accent_on_rounded` — `Border.all(width: >2)` + `borderRadius` arredondado.
- `impeccable_deep_purple_seed` — `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`.
- `impeccable_bounce_elastic_curve` — `Curves.bounce*` ou `Curves.elastic*`.
- `impeccable_dark_glow` — `BoxShadow` com `blurRadius >30`.
- `impeccable_gradient_text` — `ShaderMask` + `LinearGradient` envolvendo `Text`.
- `impeccable_italic_serif_display` — `TextStyle` italic + serif (Fraunces, Lora, etc.) + `fontSize >32`.
- `impeccable_nested_cards` — `Card` aninhado em `Card`.
- `impeccable_side_tab` — `Border(left: BorderSide(width: >1))` desigual.
- `impeccable_single_font` — `TextTheme` com mesma `fontFamily` em ≥4 papéis.

**Quality (15):**
- `impeccable_all_caps_body` — `Text('STRING')` >12 chars todo em uppercase.
- `impeccable_black_white_literal` — `Colors.black` / `Colors.white` literal.
- `impeccable_cramped_padding` — `EdgeInsets.all(<8)`.
- `impeccable_justified_text` — `TextAlign.justify` em mobile.
- `impeccable_layout_transition` — `AnimatedContainer` mudando width/height/padding/margin/constraints.
- `impeccable_material_baseline` — `MaterialApp`/`CupertinoApp` sem `theme:`/`darkTheme:`.
- `impeccable_missing_safe_area` — `Scaffold(extendBodyBehindAppBar: true)` sem `SafeArea`.
- `impeccable_missing_semantics` — `GestureDetector`/`InkWell` interativo sem `Semantics`/`Text`/`tooltip`.
- `impeccable_missing_tooltip` — `IconButton` sem `tooltip:`.
- `impeccable_textstyle_outside_theme` — `TextStyle(...)` literal em vez de `textTheme.X`.
- `impeccable_tight_leading` — `TextStyle.height <1.15`.
- `impeccable_tiny_text` — `TextStyle.fontSize <12`.
- `impeccable_touch_target_too_small` — `IconButton(padding: EdgeInsets.zero)` ou compact density + iconSize <24.
- `impeccable_use_material3_false` — `useMaterial3: false`.
- `impeccable_wide_tracking` — `TextStyle.letterSpacing >2`.

### Conhecido — limitações

- `monotonous_spacing` e `everything_centered` precisam de agregação cross-node, não suportada bem por `custom_lint_core` 0.7.5. Implementadas via `--fast` regex no CLI `impeccable_flutter`.
- `overused_font` (GoogleFonts da reflex-reject list) não dispara via `addMethodInvocation`/`addSimpleIdentifier` em `custom_lint_core` 0.7.5. Implementada via `--fast` regex.

### Testes

- 26 integration tests via `dart test`. Cada regra é validada contra fixtures em `example/lib/should_flag.dart` (deve flagar) e `example/lib/should_pass.dart` (não deve flagar). Tempo de suite: ~13s.
