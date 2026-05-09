# Status do port: `impeccable` (web) → `impeccable-flutter` ✅ v0.1.0 publicada

Port concluído e publicado. Branch `flutter-port` mergeada na `main`. Pacotes no pub.dev:

- [`impeccable_flutter_lints 0.0.1`](https://pub.dev/packages/impeccable_flutter_lints) (31 regras `custom_lint`)
- [`impeccable_flutter 0.0.1`](https://pub.dev/packages/impeccable_flutter) (CLI: `detect`, `live`, `version` + 2 regras de agregação via `--fast`)
- Plugin Claude Code: `impeccable-flutter` no marketplace deste repo (instala via `/plugin marketplace add tarcisiojr/impeccable-flutter`)

Plano original em `~/.claude/plans/analise-o-repo-iterative-snowglobe.md`. Este tracker reflete o pós-publish.

## Princípios do port

- O esqueleto (router de comandos, build multi-provider, registros brand/product, validateProse) é **agnóstico de plataforma** — fica.
- As **referências** (`skill/reference/*.md`) são reescritas em vocabulário Flutter (Material 3, Cupertino, ThemeData, MediaQuery, Semantics).
- O **detector** (hoje JS + jsdom) é reescrito em Dart como pacote `custom_lint` em `lints/`.
- O **CLI** é reescrito em Dart em `cli_dart/`, distribuído via pub.dev.
- A versão web atual (`cli/`, `extension/`, `tests/framework-fixtures/`) sobrevive durante a transição — **não apagar**.

## Convenções de status

- ⬜ não iniciado
- 🟡 em progresso
- ✅ feito
- ⏭️ pulado / decidido fora de escopo

---

## Fases

| # | Fase | Status | Notas |
|---|---|---|---|
| 0 | Baseline & guardrails | ✅ | branch `flutter-port`, pubspec raiz, este tracker, CLAUDE.md atualizado |
| 1 | Reescrever 12 referências de domínio | ✅ | 13/13: foundations (NOVO), product, brand, typography, color-and-contrast, spatial-design, motion-design, interaction-design, responsive-design, cognitive-load, personas, ux-writing, heuristics-scoring. + edit do SKILL.md (Platform law, pubspec signal). |
| 2 | Adaptar os 23 comandos | ✅ | 4 preservados (teach, extract, critique, clarify), 14 adaptados (shape, craft, polish, bolder, quieter, distill, harden, onboard, animate, colorize, typeset, layout, delight, overdrive), 5 reescritos (audit, document, adapt, optimize, live). Build clean (24 commands, 36 reference files). |
| 3 | Detector Dart `custom_lint` | ✅ | **34 regras via custom_lint** (14 slop + 20 quality, incluindo gray_on_color, low_contrast, skipped_heading na v0.1.0) + **2 exclusivas via `--fast`** (monotonous_spacing, everything_centered — agregação cross-node) = **36 distintas**. 35 integration tests + 13 unit tests verdes. |
| 4 | CLI Dart `impeccable_flutter` | ✅ | `detect` (full + `--fast` cobrindo 9 regras), `live`, `version` funcionais. 13 unit tests verdes. `dart analyze` zero issues. LICENSE + CHANGELOG. `dart pub publish --dry-run` 0 warnings. Pronto para publish após autorização. |
| 5 | Skill bundling (build multi-provider) | ✅ | command-metadata.json reescrito para Flutter (24 commands, 13 harness dirs). STYLE.md atualizado com nota sobre code samples em Dart. Build clean. |
| 6 | Live mode em Flutter | 🟡 | v0.1 documentado em `skill/reference/live.md` (workflow manual via hot reload). CLI `live` subcommand funcional. v0.2 (overlay + VM Service) é trabalho dedicado futuro. |
| 7 | Site (vertical `/flutter`) | ✅ | `site/pages/flutter.astro`: hero + tabela web↔Flutter + 36 regras + instalação. Nav link em Header.astro. Astro build OK (`/flutter/index.html`). |
| 8 | Versionamento + publish (pub.dev + plugin rename) | ✅ | Ambos packages publicados (`impeccable_flutter_lints 0.0.1`, `impeccable_flutter 0.0.1`). Skill renomeado `impeccable` → `impeccable-flutter` para coexistir com upstream do Paul. Plugin marketplace.json pronto. |

---

## Comandos (23) — status e estratégia

| Comando | Categoria | Estratégia | Status |
|---|---|---|---|
| `teach` | Build | Preservar (só trocar exemplos) | ✅ |
| `shape` | Build | Adaptar | ✅ |
| `craft` | Build | Adaptar | ✅ |
| `document` | Build | Reescrever (varre `lib/`, extrai ThemeData/TextStyle/Color) | ✅ |
| `extract` | Build | Preservar (consolida em `tokens.dart`) | ✅ |
| `critique` | Evaluate | Preservar (heurísticas Nielsen + AI slop) | ✅ |
| `audit` | Evaluate | Reescrever (chama detector Dart) | ✅ |
| `polish` | Refine | Adaptar (descobre design system via `lib/theme/`) | ✅ |
| `bolder` | Refine | Adaptar | ✅ |
| `quieter` | Refine | Adaptar | ✅ |
| `distill` | Refine | Adaptar | ✅ |
| `harden` | Refine | Adaptar (overflow, RTL, intl, low-mem) | ✅ |
| `onboard` | Refine | Adaptar | ✅ |
| `animate` | Enhance | Adaptar (implicit/explicit animations, Hero) | ✅ |
| `colorize` | Enhance | Adaptar (ColorScheme M3) | ✅ |
| `typeset` | Enhance | Adaptar (TextTheme + GoogleFonts) | ✅ |
| `layout` | Enhance | Adaptar (EdgeInsets, SizedBox, Flex) | ✅ |
| `delight` | Enhance | Adaptar (micro-interactions Flutter) | ✅ |
| `overdrive` | Enhance | Adaptar (custom_painter, flutter_shaders, Rive) | ✅ |
| `clarify` | Fix | Preservar (UX copy universal) | ✅ |
| `adapt` | Fix | Reescrever (NavigationBar↔Rail↔Drawer, SafeArea, foldables) | ✅ |
| `optimize` | Fix | Reescrever (DevTools, rebuild count, app size) | ✅ |
| `live` | Iterate | Reescrever — MVP v0.1 workflow manual done; v0.2 (VM Service overlay) pending | 🟡 |

---

## Regras do detector (27 herdadas + ~7 novas Flutter-only)

### Slop (herdadas)

| ID | Equivalente Flutter | Status |
|---|---|---|
| `side-tab` (impl) | `Border(left: BorderSide(width: >1))` desigual | ✅ |
| `border-accent-on-rounded` (impl) | `Border.all(width: >2)` + `borderRadius` arredondado | ✅ |
| `overused-font` (impl `--fast`) | `GoogleFonts.inter/dmSans/fraunces/etc.` da reflex-reject | ✅ (via fast scanner) |
| `single-font` (impl) | `TextTheme` com mesma `fontFamily` em ≥4 papéis | ✅ |
| `flat-type-hierarchy` (impl) | TextTheme com fontSize ratio <1.2 entre papéis adjacentes | ✅ |
| `gradient-text` (impl) | `ShaderMask` + `LinearGradient` em `Text` | ✅ |
| `ai-color-palette` (impl) | `Color(0xFF<hex>)` da família roxo/índigo IA (10 hexes) | ✅ |
| `deep-purple-seed` (impl) | `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` | ✅ |
| `nested-cards` (impl) | `Card` dentro de `Card` >1 nível | ✅ |
| `monotonous-spacing` (impl `--fast`) | `EdgeInsets.all(N)` repetido ≥4× no arquivo | ✅ (via fast scanner) |
| `everything-centered` (impl `--fast`) | ≥6 `Center`/`MainAxisAlignment.center` no arquivo | ✅ (via fast scanner) |
| `bounce-easing` (impl) | `Curves.bounce*` ou `Curves.elastic*` | ✅ |
| `dark-glow` (impl) | `BoxShadow` blurRadius >30 (heurística simples) | ✅ |
| `icon-tile-stack` (impl) | `Row`/`Wrap`/`GridView` com 3+ Container "Icon + Text" | ✅ |
| `italic-serif-display` (impl) | TextStyle italic + serif (Fraunces/Lora/etc.) + fontSize >32 | ✅ |
| `hero-eyebrow-chip` (impl) | Container chip arredondado seguido de Text display em Column | ✅ |

### Quality (herdadas)

| ID | Equivalente Flutter | Status |
|---|---|---|
| `pure-black-white` (impl `colors-black-white-literal`) | `Colors.black` / `Colors.white` literal (não scheme) | ✅ |
| `gray-on-color` | TextStyle gray sobre Container com fundo saturado | ⬜ |
| `low-contrast` | TextStyle.color vs background, WCAG calculado | ⬜ |
| `layout-transition` (impl) | `AnimatedContainer` mudando width/height/padding/margin/constraints | ✅ |
| `line-length` (impl) | `Text` com string >100 chars sem `maxLines:`/`softWrap:` | ✅ |
| `cramped-padding` (impl) | `EdgeInsets.all(<8)` literal | ✅ |
| `tight-leading` (impl) | TextStyle.height <1.15 em body | ✅ |
| `skipped-heading` | Header semântico fora de ordem em Semantics tree | ⬜ |
| `justified-text` (impl) | `Text(textAlign: TextAlign.justify)` em mobile | ✅ |
| `tiny-text` (impl) | TextStyle.fontSize <12 sem ser caption | ✅ |
| `all-caps-body` (impl) | `Text('STRING')` >12 chars todo em uppercase | ✅ |
| `wide-tracking` (impl) | `TextStyle.letterSpacing >2` literal | ✅ |

### Novas (Flutter-only)

| ID | O que detecta | Status |
|---|---|---|
| `missing-const-decoration` (impl) | `BoxDecoration`/`TextStyle`/`EdgeInsets`/`BorderRadius` literal sem `const` em hot path | ✅ (complementa `prefer_const_constructors` padrão) |
| `theme-bypass` (impl `textstyle-outside-theme`) | TextStyle/Color hard-coded em vez de `Theme.of(context)` | ✅ (parcial: TextStyle) |
| `missing-semantics` (impl) | `GestureDetector`/`InkWell` interativo sem `Semantics`/`Text`/`tooltip`/`semanticLabel` | ✅ |
| `missing-tooltip-iconbutton` (impl) | `IconButton` sem `tooltip:` | ✅ |
| `touch-target-too-small` (impl) | `IconButton(padding: EdgeInsets.zero)` ou compact density + iconSize <24 | ✅ |
| `missing-safe-area` (impl) | `Scaffold(extendBodyBehindAppBar: true)` sem `SafeArea` | ✅ |
| `material-baseline` (impl) | `MaterialApp`/`CupertinoApp` sem `theme:`/`darkTheme:` | ✅ |
| `useMaterial3-false` (impl) | `useMaterial3: false` literal em ThemeData | ✅ |

---

## Fontes canônicas (Flutter) usadas pelas referências

- https://m3.material.io
- https://docs.flutter.dev/ui/accessibility
- https://docs.flutter.dev/perf
- https://docs.flutter.dev/ui/adaptive-responsive
- https://docs.flutter.dev/ui/animations
- https://docs.flutter.dev/app-architecture
- https://api.flutter.dev/flutter/material/ThemeData-class.html
- https://api.flutter.dev/flutter/widgets/Semantics-class.html
- https://developer.apple.com/design/human-interface-guidelines/ios

## Coexistência com a versão web

Pacotes web sobrevivem como referência arquitetônica e para servir o site original. Não apagar:

- `cli/` (Node CLI web)
- `extension/` (Chrome extension web)
- `tests/framework-fixtures/` (fixtures de frameworks web)
- `_redirects` e deploy Cloudflare Pages

No Claude Code, ambos plugins coexistem sem colisão:

- `/impeccable polish` → upstream do Paul ([npm impeccable](https://www.npmjs.com/package/impeccable))
- `/impeccable-flutter polish` → este repo

## Próximos passos (v0.2 — não bloqueiam v0.1.x)

- ~~3 regras complexas pendentes: `low-contrast`, `gray-on-color`, `skipped-heading`~~ ✅ **implementadas em v0.1.1** com heurísticas pragmáticas (cores literais resolvidas via Material palette + Color(0xFF...) + Color.fromARGB; type-flow real do `analyzer` direto fica para v0.2 se aparecer demanda)
- Live mode v0.2: overlay + VM Service + WidgetInspector
- Bump das 15 dependências Dart desatualizadas (analyzer 7→13, custom_lint 0.7→0.8, etc.)
- Eventual submissão ao marketplace oficial da Anthropic se quiser exposição maior
