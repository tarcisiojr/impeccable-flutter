# Document (Flutter)

Auto-extrai o sistema visual de um app Flutter existente e gera DESIGN.md no formato [Google Stitch](https://stitch.withgoogle.com/docs/design-md/format/), adaptado para vocabulário Flutter (Material 3 / Cupertino / ThemeData).

Roda em duas modalidades:
- **Scan mode** (default): app já tem código, escaneia `lib/`, lê tokens reais.
- **Seed mode** (`--seed`): app vazio, faz 5 perguntas e cria starter DESIGN.md.

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Pré-requisitos

- Loader já rodou (`load-context.mjs`); PRODUCT.md existe.
- `pubspec.yaml` na raiz (sinal de projeto Flutter).
- Decisão clara entre scan vs seed.

Se PRODUCT.md falta, blocker: rode `/impeccable teach` antes.

## Decisão scan vs seed

Auto-detecte:
- Se `lib/` tem ≥3 arquivos `.dart` E ao menos um deles importa `package:flutter/material.dart`/`package:flutter/cupertino.dart`: **scan**.
- Se `lib/main.dart` é só template (`MyApp` default do `flutter create`): **seed**.
- Se `--seed` foi passado: força seed mesmo com código existente.

## Scan mode

### Step 1: Detectar a estrutura de tema

Procure em ordem:
1. `lib/theme/`, `lib/core/theme/`, `lib/styles/`, `lib/design/`: convenções comuns.
2. `lib/main.dart` ou `lib/app.dart`: onde `MaterialApp(theme: ...)` é construído.
3. Qualquer arquivo que exporte `ThemeData`, `ColorScheme`, `TextTheme`, ou `extends ThemeExtension`.

Capture:
- Caminho de `ThemeData` light e dark.
- `seedColor` se via `ColorScheme.fromSeed`.
- Presença de `useMaterial3: true`.
- Custom `TextTheme`?
- `pageTransitionsTheme`, `visualDensity`, `splashFactory`?
- Lista de `ThemeExtension` registrados.

### Step 2: Extrair ColorScheme

Liste os 30 papéis M3 com cor RESOLVIDA em ambos brightness:

```
| Role | Light | Dark |
|---|---|---|
| primary | #1F4ED8 | #B0C5FF |
| onPrimary | #FFFFFF | #002F8E |
| primaryContainer | #DCE2FF | #003BB6 |
| ... (30 papéis) |
```

Detectar custom colors fora do M3 (success, warning, info, brand-secondary): listar de `ThemeExtension<*>` registrados.

### Step 3: Extrair TextTheme

Liste os 15 papéis M3 com `fontSize`, `fontWeight`, `letterSpacing`, `height`:

```
| Role | Size | Weight | Line height | Letter |
|---|---|---|---|---|
| displayLarge | 57 | w400 | 1.12 | -0.25 |
| ... |
| labelSmall | 11 | w500 | 1.45 | 0.5 |
```

Identificar família(s) de fonte. Se via `google_fonts`, qual? Se bundlada, qual nome em `pubspec.yaml > fonts`?

### Step 4: Extrair tokens de espaço e elevation

Procure:
- `EdgeInsets` recorrentes em widgets (`EdgeInsets.all(8)`, `EdgeInsets.all(16)`, `EdgeInsets.all(24)`).
- `SizedBox(height: N)` recorrentes.
- Constantes em `theme/spacing.dart` ou `ThemeExtension<SpacingTokens>`.
- `BorderRadius.circular(N)` recorrentes.
- `Material(elevation: N)` ou níveis de `surfaceContainer*` usados.

Documente o sistema descoberto. Se inconsistente (`EdgeInsets.all(7)` em um lugar, `9` em outro), sinalize.

### Step 5: Extrair componentes recorrentes

Varra `lib/widgets/`, `lib/components/`, `lib/shared/`. Liste:
- Botões customizados (`AppFilledButton`, `PrimaryButton`).
- Cards customizados.
- ListTile customizados.
- Inputs customizados.
- Empty states / error states.
- Layout containers / sections.

Para cada, anote: nome do widget, parâmetros principais, onde está, quantos lugares usam.

### Step 6: Detectar plataforma strategy

Conte imports:
- `package:flutter/material.dart` X vezes.
- `package:flutter/cupertino.dart` Y vezes.

- Se Y >> X: provavelmente `cupertino_only`.
- Se X >> Y: provavelmente `material_only`.
- Se ambos significativos + uso de `Theme.of(context).platform`: provavelmente `adaptive`.
- Se `flutter_platform_widgets` package: definitivamente adaptive.

Cross-check com PRODUCT.md `## Platform Strategy`. Se diverge, sinaliza.

### Step 7: Detectar motion

Procure:
- `AnimationController`, `Tween`, `CurvedAnimation`.
- `Curves.bounce*` ou `Curves.elastic*` (anti-pattern; flag).
- Durations recorrentes (`Duration(milliseconds: 300)`).
- Custom `MotionScheme` ou `ThemeExtension<MotionTokens>`.
- Hero usage.
- `pageTransitionsTheme`.

### Step 8: Escrever DESIGN.md

Use o formato Google Stitch adaptado para Flutter. Estrutura:

```markdown
# Design System

## Theme strategy
- Material 3 enabled: yes / no
- Brightness: light + dark / light only / dark only
- ThemeMode: system / light / dark
- Platform: material_only | cupertino_only | adaptive

## Color
### Seed color
`#1F4ED8` (Indigo Material You)

### Light scheme (Material 3 derived)
[tabela 30 papéis M3 com hex]

### Dark scheme
[tabela 30 papéis M3 com hex dark]

### Custom colors (ThemeExtension<SemanticColors>)
- `success`: #1F8E3A (light), #6FE48E (dark)
- `warning`: #B8590F (light), #FFB060 (dark)
- `info`: #2D6CB0 (light), #88BDFF (dark)

## Typography
### Family
- Body: Inter (via google_fonts)
- Display: Fraunces (bundled em assets/fonts/)

### Scale (Material 3 textTheme)
[tabela 15 papéis com size/weight/height/letter]

### Custom text styles (ThemeExtension<TextTokens>)
- `code`: monospace JetBrains Mono 14, height 1.4
- `captionAllCaps`: Inter 11 medium, letterSpacing 0.08em

## Space
### Tokens (ThemeExtension<SpacingTokens>)
- xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48

### Border radius
- sm: 4, md: 8, lg: 16, xl: 24
- Circle: BorderRadius.circular(999)

## Elevation (Material 3)
| Level | surfaceContainer | Elevation |
|---|---|---|
| 0 | surface | 0 |
| 1 | surfaceContainerLow | 1 |
| 2 | surfaceContainer | 3 |
| 3 | surfaceContainerHigh | 6 |
| 4 | surfaceContainerHighest | 8 |
| 5 | (n/a) | 12 |

## Motion
### Duration tokens
- short: 150ms
- medium: 300ms
- long: 500ms

### Curves
- standard: Curves.easeOutCubic
- emphasized: Curves.easeOutQuart
- exit: Curves.easeInCubic

### Page transition
- Material: PredictiveBackPageTransitionsBuilder (Android), CupertinoPageTransitionsBuilder (iOS)

## Components
### Buttons
- `AppFilledButton` (lib/widgets/buttons/app_filled_button.dart): primary CTA
- `AppTextButton`: secondary action
- `AppDestructiveButton`: error-colored

### Cards
- `AppCard` (lib/widgets/layout/app_card.dart): wrapper com padding md, elevation 1

### Empty states
- `AppEmptyState(icon:, title:, message:, actionLabel:, onAction:)`

[etc]

## Iconography
- Set: Material Icons (default) + custom em assets/icons/ (SVGs via flutter_svg)
- Sizes: 16, 20, 24 (default), 32

## Anti-patterns observed
- [Lista issues encontradas durante scan: hard-coded colors em N lugares, EdgeInsets monotônicos em listings, etc.]
```

Termine com:
- Onde o scan achou inconsistências (para o user resolver via `extract` ou `polish`).
- Recomendação de comando para próximos passos.

## Seed mode

Quando `lib/` é vazio ou template puro. Faça 5 perguntas:

1. **Cor**: "Qual cor de marca? Se não tem, cole hex aqui ou diga uma palavra (azul-cobalto, vermelho-vinho)." Vira `seedColor`.
2. **Fonte**: "Sans simples (Inter), display + body (Fraunces + Inter), system stack, ou outro? Se outro, qual?" Vira `textTheme` direction.
3. **Plataforma**: "Material puro, Cupertino puro, ou adaptive?" Vira `platform_strategy`.
4. **Energia de motion**: "Quieto (animações sutis 150-200ms), padrão (300ms), ou expressivo (com Hero, shared axis, 500ms)?" Vira motion tokens.
5. **Referências visuais**: "App que captura o feel certo? (Linear, Things, Notion, Liquid Death, etc.)" Influencia color strategy e component vocabulary.

Sintetize em DESIGN.md "starter" com defaults sensatos baseados nas respostas, e marque cada section com `<!-- TODO: validate after first screens are built -->`. Lembre o user de re-rodar `/impeccable document` depois que tiver código.

## Output

Escreva no `PROJECT_ROOT/DESIGN.md`. Se já existe, não overwrite. Pergunte:
- Append novo conteúdo numa seção `## Refresh YYYY-MM-DD`?
- Substituir totalmente?
- Cancelar?

Após escrever, **rode o loader de novo** (`node .claude/skills/impeccable/scripts/load-context.mjs`) para a sessão pegar o DESIGN.md fresco. Comandos subsequentes vão usar.

## Verificar

- DESIGN.md cobre todos os 30 papéis ColorScheme se a app usa M3.
- Lista de fontes bate com `pubspec.yaml > fonts`.
- Componentes listados existem mesmo em `lib/widgets/`.
- Seções marcadas `TODO` são reais (não invente).

Hand off para `/impeccable extract` se a documentação revelou padrões repetidos prontos para virar componentes.
