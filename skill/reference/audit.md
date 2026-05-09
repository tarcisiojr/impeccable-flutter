# Audit (Flutter)

Roda checagens técnicas sistemáticas e gera relatório. Não corrige; documenta para outros comandos resolverem.

Code-level audit, não design critique. Cobre o mensurável e verificável na implementação Flutter.

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Diagnostic Scan

5 dimensões. Score 0-4 cada uma com critério abaixo.

### 1. Acessibilidade (A11y)

**Check for**:
- **Contraste**: textos com ratio <4.5:1 (ou <3:1 para large text e ícones de UI). Validar com cor RESOLVIDA via `Theme.of(context).colorScheme`, não com literal `Color(0xFF...)`. Em ambos brightness.
- **`Semantics` ausente**: `GestureDetector`/`InkWell` que faz algo sem `Semantics(label:, button: true)` ou widget pai com label útil.
- **Focus**: `FocusableActionDetector` em widgets interativos custom. `TextField` sem `focusNode` rastreável.
- **Touch target <48dp**: `IconButton.iconSize` pequeno sem `MaterialTapTargetSize.padded`. `InkWell` cru com child de 24×24.
- **`tooltip:`**: ausente em `IconButton`. Sem isso, screen reader lê "botão" sem contexto.
- **`semanticLabel:`**: ausente em `Image`/`Icon` informativo. Decorativos devem usar `excludeFromSemantics: true`.
- **`MediaQuery.textScaler` ignorado**: hard-code `TextScaler.noScaling`, ou layout que quebra em 130%/200%.
- **Order de leitura**: estrutura Semantics em ordem ilógica. Use `Semantics(sortKey:)`.
- **Cor sozinha conveying**: vermelho = erro, verde = sucesso, sem ícone ou texto adicional.

**Tools**: `flutter analyze`, `accessibility_tools` package (overlay dev), `Semantics.debugMode`, `flutter test --semantics`.

**Score 0-4**: 0=Inacessível (`MaterialApp` sem `theme`, `Colors.black` em texto sobre `Colors.white`, sem `Semantics`); 1=Major gaps (poucos labels, sem tooltip em `IconButton`); 2=Parcial (algum esforço, lacunas significativas); 3=Bom (WCAG AA mostly atendido, lacunas menores); 4=Excelente (WCAG AA atendido, `Semantics` em todo interativo, contraste validado em ambos brightness).

### 2. Performance

**Check for**:
- **Sem `const`**: widgets literais que poderiam ser `const` rebuildando a cada `setState`. `BoxDecoration`, `TextStyle`, `EdgeInsets` literais sem `const`.
- **`RepaintBoundary` ausente**: lista longa, área animada cercada de conteúdo estático, `CustomPainter` que repinta frequente.
- **`AnimatedContainer` mudando width/height/padding**: causa relayout. Anime via `AnimatedAlign`, `AnimatedSlide`, `Transform`.
- **`BackdropFilter` em fullscreen**: mata performance em devices baixo custo.
- **`Image.network` cru em `ListView`**: sem `cacheWidth`, sem cache em disco. Use `cached_network_image` + `cacheWidth: (width * dpr).toInt()`.
- **`StatefulWidget` que reconstrói árvore inteira por causa de uma cor animada**: separar em sub-widget. Ou usar `ValueListenableBuilder`/`AnimatedBuilder` com `child:` parâmetro.
- **`build()` >50 linhas**: tipicamente sinal de árvore profunda que rebuilda demais. Quebrar.
- **`setState` em frequência alta** (gestures, scroll): use `ValueNotifier` + `ListenableBuilder` em vez.
- **Frame budget**: 16ms a 60fps; 8ms a 120fps. Conferir em `flutter run --profile` + DevTools Performance.
- **App size**: `flutter build apk --analyze-size` ou `flutter build ios --analyze-size`. Apps >40MB são pesados em mercado emergente.

**Tools**: DevTools Performance (rebuild count, raster timeline, build timeline), `flutter run --profile`, `flutter build --analyze-size`, Observatory.

**Score 0-4**: 0=Severe (nenhum `const`, jank visível em rolagem); 1=Major (sem cache de imagem, animações pesadas); 2=Parcial; 3=Bom (60fps em devices médios, alguns gaps); 4=Excelente (60fps em low-end, app size enxuto, `RepaintBoundary` estratégico, métricas medidas).

### 3. Theming

**Check for**:
- **`Colors.black` / `Colors.white`** literal em qualquer lugar de UI.
- **`Color(0xFF...)`** literal num widget (deveria vir de `colorScheme`).
- **`TextStyle` cru** em `Text` (deveria vir de `textTheme`).
- **`MaterialApp` sem `theme:`** ou com `seedColor: Colors.deepPurple` (default `flutter create`).
- **`useMaterial3: false`** sem justificativa.
- **`darkTheme:` ausente** ou com paleta inconsistente.
- **`themeMode: ThemeMode.system`** ausente (app não respeita Settings do device).
- **`ThemeExtension`** ausente para tokens fora do M3 (success/warning, spacing, motion durations, brand-secondary).
- **Sombras custom** via `BoxShadow` em vez de `Material(elevation:)`.

**Score 0-4**: 0=Sem theming; 1=Mínimo; 2=Parcial; 3=Bom; 4=Excelente (`ThemeData` completo, `ColorScheme.fromSeed`, `ThemeExtension`, dark mode validado, zero literals).

### 4. Adaptive Design

**Check for**:
- **Hard-code de width/height** que quebra em telas pequenas (<320 lógicos) ou grandes (tablet, foldable, desktop Flutter).
- **`SafeArea` ausente** em modais/overlays full-screen.
- **`MediaQuery.viewInsetsOf(context)`** ignorado quando teclado abre (formulário sumiu).
- **Touch targets <48dp** (já em a11y, mas relevante aqui também).
- **`MediaQuery.textScaler` ignorado** ou layout que quebra em escala alta.
- **Sem `LayoutBuilder` para componentes que reagem ao container**.
- **Sem switch entre `BottomNavigationBar`/`NavigationRail`/`NavigationDrawer`** baseado em window class.
- **`Image.network`** sem `loadingBuilder`/`errorBuilder` em conexão lenta.
- **`OrientationBuilder` ausente** quando relevante (galeria, mapa).
- **`displayFeatures`** ignorado em foldables (rara mas relevante).

**Score 0-4**: 0=Single-screen apenas; 1=Major (quebra em tablet); 2=Parcial; 3=Bom; 4=Excelente (responde a window class, foldable, teclado, text scale, orientation).

### 5. Anti-padrões (CRÍTICO)

Check contra TODOS os bans absolutos do skill parent (já carregado neste context). Plus os Flutter-specific:

- **`Curves.bounce*` ou `Curves.elastic*`** em product (raros em jogos OK, em product nunca).
- **`LinearGradient` em `AppBar`** purple-blue.
- **Splash screen com fade-in genérico** (logo + scale + 1.5s).
- **Lottie animation genérica** de stock library (sem ser desenhada para a marca).
- **Hero card com border-radius 24, shadow azul, eyebrow chip + headline + button** (template de Material 3 tutorial).
- **`Card` aninhado em `Card`**.
- **`ColorScheme.fromSeed(seedColor: Colors.deepPurple)`**.
- **Padding monotônico**: `EdgeInsets.all(N)` repetido em ≥4 widgets adjacentes com mesmo N.
- **Gradient em `Text` via `ShaderMask`**.
- **Glass effect via `BackdropFilter` em todo card** (deveria ser raro e proposital).

**Score 0-4**: 0=Galeria de slop (5+ tells); 1=Aesthetic AI pesada (3-4 tells); 2=Algum (1-2 notáveis); 3=Mostly clean; 4=Sem tells (distintivo, intencional).

## Generate Report

### Audit Health Score

| # | Dimension | Score | Key Finding |
|---|---|---|---|
| 1 | Accessibility | ? | [issue mais crítica ou "--"] |
| 2 | Performance | ? | |
| 3 | Theming | ? | |
| 4 | Adaptive Design | ? | |
| 5 | Anti-Patterns | ? | |
| **Total** | | **??/20** | **[Rating band]** |

**Rating bands**: 18-20 Excelente; 14-17 Bom; 10-13 Aceitável; 6-9 Pobre; 0-5 Crítico.

### Anti-Patterns Verdict

**Comece aqui.** Pass/fail: parece app Flutter de IA? Liste tells específicas. Brutalmente honesto.

### Executive Summary
- Audit Health Score: **??/20** ([rating band])
- Total issues por severidade (P0/P1/P2/P3)
- Top 3-5 issues críticas
- Próximos passos recomendados

### Detailed Findings by Severity

Cada issue:
- **[P?] Issue name**
- **Location**: arquivo, linha (`lib/widgets/foo.dart:42`)
- **Category**: A11y / Performance / Theming / Adaptive / Anti-Pattern
- **Impact**: como afeta usuário
- **Standard**: WCAG, Material 3, HIG, qual viola
- **Recommendation**: como corrigir (concreto)
- **Suggested command**: qual comando do skill resolve (`{{available_commands}}`)

P0/P1/P2/P3 conforme [heuristics-scoring.md](heuristics-scoring.md).

### Patterns & Systemic Issues

Recorrências que indicam gap sistêmico:
- "Hard-coded `Color(0xFF...)` aparece em 15+ widgets, deveria via `colorScheme`."
- "Touch targets <48dp consistentemente em ícones de header."
- "Nenhum widget usa `const`; rebuild em cascata em cada `setState`."

### Positive Findings

Note o que está bom: práticas a manter e replicar.

## Recommended Actions

Comandos em ordem de prioridade (P0 primeiro):

1. **[P?] `{{command_prefix}}command-name`**: descrição breve (contexto específico do audit)
2. **[P?] `{{command_prefix}}command-name`**: descrição (contexto)

**Rules**: só comandos de `{{available_commands}}`. Termine com `{{command_prefix}}impeccable polish` se houve fixes.

Após o resumo:

> Você pode pedir para rodar uma por vez, todas, ou na ordem que preferir.
>
> Re-rode `{{command_prefix}}impeccable audit` após fixes para ver o score subir.

**IMPORTANTE**: thorough mas acionável. Muitos P3 vira ruído. Foco no que importa.

**NUNCA**:
- Reportar sem explicar impacto (por que importa?)
- Recomendações genéricas (seja específico).
- Pular positive findings (celebre o que funciona).
- Esquecer prioritizar (nem tudo é P0).
- Reportar falsos positivos sem verificação (rode `dart analyze`/`custom_lint` antes).

## Comandos auxiliares

Quando disponíveis, prefira invocar:

```bash
dart analyze                                    # análise estática base
dart run custom_lint                            # se impeccable_flutter_lints instalado
flutter test                                    # widget tests, golden tests
flutter test --update-goldens                   # se golden tests existirem
flutter run --profile -d <device>               # benchmark real
flutter build apk --analyze-size                # app size
flutter build ios --analyze-size
```

DevTools Performance + Inspector + Network são a fonte de verdade em runtime.
