# Flutter foundations

Referência transversal. Toda outra `reference/*.md` assume que você leu isto.

## O que muda quando o produto é um app Flutter

A web tem CSS, jsdom, viewports e um navegador que quebra tudo de formas conhecidas. Flutter tem `ThemeData`, `MediaQuery`, widget tree e Skia/Impeller que renderiza pixel-exato em iOS, Android e desktop. As leis de design são as mesmas. O vocabulário muda inteiro.

A regra mestra: **se você precisa de um valor visual em qualquer lugar do app, ele veio do `Theme`**. Cor literal num `Container`, `TextStyle(fontSize: 14)` num `Text`, `EdgeInsets.all(12)` num `Padding`: três cheiros de design abandonado. Theme é o único lugar onde valores moram.

A regra mestra dois: **plataforma é parte do design**. Material num iPhone que não respeita gestos do iOS é tão estranho quanto Cupertino num Pixel. Decida cedo. Se for "ambos", decida o que faz override por plataforma e o que é unificado.

## Mapeamento web → Flutter

Quando uma referência de `reference/*.md` cita um conceito web, traduza assim:

| Web | Flutter |
|---|---|
| `body { color: ... }` global | `MaterialApp(theme: ThemeData(...))` |
| `:root { --color-... }` tokens | `ColorScheme` + `ThemeExtension<T>` |
| `getComputedStyle(el)` | `Theme.of(context)` + `DefaultTextStyle.of(context)` |
| `display: flex; gap: 8` | `Row`/`Column` com `SizedBox(width/height: 8)` ou `spacing:` (3.27+) |
| `padding: 16` | `Padding(padding: EdgeInsets.all(16))` |
| `border-radius: 12` | `BorderRadius.circular(12)` |
| `box-shadow` | `BoxShadow` em `BoxDecoration` (raro em M3, prefira `Material(elevation:)`) |
| `font-family: Inter` | `GoogleFonts.inter()` ou system stack via `TextTheme` |
| `line-height: 1.4` | `TextStyle(height: 1.4)` |
| `letter-spacing: 0.5px` | `TextStyle(letterSpacing: 0.5)` |
| `clamp(min, pref, max)` | nada equivalente; use breakpoints `LayoutBuilder`/`MediaQuery` |
| `@media (min-width: 600px)` | breakpoints Material: `compact <600 / medium 600-840 / expanded 840+` |
| `prefers-color-scheme: dark` | `MediaQuery.platformBrightnessOf(context)` + `themeMode: ThemeMode.system` |
| `prefers-reduced-motion` | `MediaQuery.disableAnimationsOf(context)` |
| `aria-label`, role | `Semantics(label:, button: true, ...)` |
| `:focus-visible` outline | `FocusableActionDetector` + `WidgetState.focused` |
| `:hover` state | `WidgetState.hovered` (desktop/web Flutter; mobile não tem hover) |
| WCAG contrast | mesma matemática, mas valida com cores RESOLVIDAS de `ColorScheme`, não com literal |
| Lighthouse, Web Vitals | DevTools Performance, `Timeline`, `flutter run --profile` |
| `IntersectionObserver` | `VisibilityDetector` package, ou `NotificationListener` |
| Hot Module Replacement | hot reload (`r` no `flutter run`) |

## Glossário curto

- **`ThemeData`**: o único lugar onde tokens moram. Define `colorScheme`, `textTheme`, `useMaterial3: true`, `extensions: [...]`. Acessado via `Theme.of(context)`.
- **`ColorScheme`**: 30 papéis semânticos (`primary`, `onPrimary`, `surface`, `surfaceContainerHigh`, `error`, `outline`, etc.). Construído idealmente via `ColorScheme.fromSeed(seedColor: ...)`. Material 3 deriva todos os papéis a partir de uma cor-semente.
- **`TextTheme`**: 15 papéis tipográficos M3 (`displayLarge` → `labelSmall`). Cada papel é um `TextStyle` com fontSize, fontWeight, letterSpacing, height. Acessado via `Theme.of(context).textTheme.bodyLarge` etc.
- **`ThemeExtension<T>`**: subclasse para tokens fora do M3 (gradients, custom shadows, motion durations próprias). Ler via `Theme.of(context).extension<T>()`.
- **`MediaQuery`**: dados de runtime do device (`size`, `padding` para safe area, `viewInsets` para teclado, `textScaler` para Dynamic Type, `platformBrightness`, `disableAnimations`).
- **`MediaQuery.textScaler`**: substitui `textScaleFactor`. Aplica escala não-linear acessível. NUNCA hard-code em 1.0; isso quebra A11y.
- **`Semantics`**: a árvore paralela que `TalkBack`, `VoiceOver`, `Switch Control` enxergam. Sem isso, gestos viram nada para usuários A11y.
- **`WidgetState`** (antigo `MaterialState`): estados de interação (`hovered`, `focused`, `pressed`, `dragged`, `selected`, `scrolledUnder`, `disabled`, `error`). Use `WidgetStateProperty.resolveWith(...)`.
- **`Cupertino*`**: widgets iOS-fluentes (`CupertinoButton`, `CupertinoNavigationBar`, `CupertinoSwitch`). Coexistem com Material; alterne por `Theme.of(context).platform` ou pacote `flutter_platform_widgets`.
- **`SafeArea`**: garante que conteúdo não vai para baixo do notch, status bar, gesture bar ou display cutout. `Scaffold` aplica em `body` por padrão; widgets fora de `Scaffold` precisam declarar.
- **DevTools**: `flutter run` + `--profile` + DevTools Performance. Frames, raster, build, rebuilds. Onde você descobre por que aquela tela faz jank.

## Fontes canônicas

Nas refs, sempre que citar uma regra de plataforma, linke uma destas. Não inventar URL.

- [Material Design 3](https://m3.material.io)
- [Apple Human Interface Guidelines (iOS)](https://developer.apple.com/design/human-interface-guidelines/ios)
- [Flutter App Architecture (oficial)](https://docs.flutter.dev/app-architecture)
- [Flutter Adaptive & Responsive UI](https://docs.flutter.dev/ui/adaptive-responsive)
- [Flutter Accessibility](https://docs.flutter.dev/ui/accessibility)
- [Flutter Animations](https://docs.flutter.dev/ui/animations)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [`ThemeData` API](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [`ColorScheme` API](https://api.flutter.dev/flutter/material/ColorScheme-class.html)
- [`TextTheme` API](https://api.flutter.dev/flutter/material/TextTheme-class.html)
- [`Semantics` API](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [`MediaQuery` API](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
- [Material 3 Components for Flutter](https://docs.flutter.dev/ui/widgets/material)
- [`very_good_analysis` lints](https://pub.dev/packages/very_good_analysis)

Cinco coisas que parecem detalhe e não são, e que toda ref vai cobrar de você:

1. **`useMaterial3: true`**. Sem isso, `ThemeData` cai no Material 2 default e a paleta inteira fica errada. Em Flutter 3.16+ é o default; ainda assim, declare explícito num app sério.
2. **Nenhum literal `Colors.black` / `Colors.white`**. Sempre `Theme.of(context).colorScheme.onSurface` (ou o papel correto). Literais quebram dark mode silenciosamente.
3. **`MediaQuery.textScalerOf(context).scale(fontSize)`** quando você precisa medir altura de texto em código. Hard-codar tamanho ignora Dynamic Type.
4. **`SafeArea` em qualquer overlay full-screen** (modais, bottom sheets, splashes). Notch + gesture bar comem o conteúdo se você esquecer.
5. **`Semantics` em todo `GestureDetector` / `InkWell` que faz algo**. Se não há `Semantics` ou `tooltip`, TalkBack/VoiceOver lê "botão sem rótulo", o que é pior do que invisível.
