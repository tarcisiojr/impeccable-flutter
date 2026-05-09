Typography carries most of the information on the page. Replace generic defaults (Inter, Roboto, system fallback at flat scale) with type that reflects the brand and scales with intentional contrast.

---

## Register

Brand: run the font selection procedure in [brand.md](brand.md). Pairing follows the brand's lane (display serif + sans body for editorial/luxury, one committed sans for tech, etc.). Fluid `clamp()` scale, ≥1.25 ratio between steps.

Product: system fonts and familiar sans stacks are legitimate here. One well-tuned family typically carries the whole UI. Fixed `rem` scale, 1.125–1.2 ratio between more closely-spaced steps.

---

## Assess Current Typography

Analyze what's weak or generic about the current type:

1. **Font choices**:
   - Are we using invisible defaults? (Inter, Roboto, Arial, Open Sans, system defaults)
   - Does the font match the brand personality? (A playful brand shouldn't use a corporate typeface)
   - Are there too many font families? (More than 2-3 is almost always a mess)

2. **Hierarchy**:
   - Can you tell headings from body from captions at a glance?
   - Are font sizes too close together? (14px, 15px, 16px = muddy hierarchy)
   - Are weight contrasts strong enough? (Medium vs Regular is barely visible)

3. **Sizing & scale**:
   - Is there a consistent type scale, or are sizes arbitrary?
   - Does body text meet minimum readability? (16px+)
   - Is the sizing strategy appropriate for the context? (Fixed `rem` scales for app UIs; fluid `clamp()` for marketing/content page headings)

4. **Readability**:
   - Are line lengths comfortable? (45-75 characters ideal)
   - Is line-height appropriate for the font and context?
   - Is there enough contrast between text and background?

5. **Consistency**:
   - Are the same elements styled the same way throughout?
   - Are font weights used consistently? (Not bold in one section, semibold in another for the same role)
   - Is letter-spacing intentional or default everywhere?

**CRITICAL**: The goal isn't to make text "fancier." It's to make it clearer, more readable, and more intentional. Good typography is invisible; bad typography is distracting.

## Plan Typography Improvements

Consult the [typography reference](typography.md) for detailed guidance on scales, pairing, and loading strategies.

Create a systematic plan:

- **Font selection**: Do fonts need replacing? What fits the brand/context?
- **Type scale**: Establish a modular scale (e.g., 1.25 ratio) with clear hierarchy
- **Weight strategy**: Which weights serve which roles? (Regular for body, Semibold for labels, Bold for headings, or whatever fits)
- **Spacing**: Line-heights, letter-spacing, and margins between typographic elements

## Improve Typography Systematically (Flutter)

### Font Selection

Se as fontes precisam ser trocadas:
- Escolha fontes que refletem a personalidade da marca (procedimento em [brand.md](brand.md)).
- Pareie com contraste genuíno (serif + sans, geometric + humanist), ou use uma família só em múltiplos pesos.
- Em Flutter, carregue via `google_fonts` package (runtime fetch desabilitado em produção, com TTFs bundlados em `assets/`) ou bundle direto via `pubspec.yaml > flutter > fonts`. Veja [typography.md](typography.md).
- Para variable fonts: declare em `pubspec.yaml` e use `FontVariation('wght', 480)` para pesos fracionários.

### Hierarquia via TextTheme

**Use os 15 papéis Material 3** em vez de inventar paralelo:

```dart
// Acessar
Text('Título', style: Theme.of(context).textTheme.headlineMedium);

// Customizar TextTheme inteiro
ThemeData(
  textTheme: GoogleFonts.interTextTheme(),  // base inteira
  // ou override por papel:
  textTheme: TextTheme(
    displayLarge: GoogleFonts.fraunces(fontWeight: FontWeight.w900),
    // resto vem do default M3
  ),
)
```

- **15 papéis cobrem tudo**: display(L/M/S), headline(L/M/S), title(L/M/S), body(L/M/S), label(L/M/S).
- **Razão consistente**: M3 entrega 1.125-1.27 entre vizinhos. Se customiza, mantenha 1.2-1.333.
- **Combine dimensões**: tamanho + peso + cor + espaço para hierarquia forte. Não dependa só de tamanho.
- **App UIs**: escala fixa via `TextTheme`. Não tente fluid type em mobile (jank em scroll).
- **Brand surfaces (marketing screen, splash)**: ajuste `displayLarge` para tamanho dramático.

### Readability

- Não há `ch` em Flutter. Aproxime: para `bodyLarge` (16), 50-75 chars cabem em 280-420 lógicos. Em tablet/desktop, `ConstrainedBox(maxWidth: 600)` para não passar de 75 em prosa.
- `TextStyle.height` para line-height. M3 default em body: 1.5. Headings: 1.1-1.2. Coluna larga: 1.5-1.6.
- Body claro em fundo escuro: aumentar `height` em 0.05-0.1, adicionar `letterSpacing` 0.01-0.02, considerar reduzir peso em um nível.
- Body text mínimo 16 (`bodyLarge` M3 default).
- **Honra `MediaQuery.textScaler`** sempre. Nunca `noScaling`.

### Refinar detalhes

```dart
TextStyle(
  fontFeatures: const [
    FontFeature.tabularFigures(),    // dígitos alinhados em listas/tabelas
    FontFeature.enable('frac'),       // frações reais
    FontFeature.disable('liga'),      // tira ligaduras (em código)
  ],
  letterSpacing: 0.5,                 // ALL-CAPS labels precisam +5-12% (= 0.05-0.12 em em-multiplier)
  height: 1.4,                        // line-height
)
```

`textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false)` corrige leading desnecessária em headers grandes.

### Weight consistency

- Defina papéis claros para cada peso e mantenha.
- Não use mais que 3-4 pesos (Regular, Medium, Semibold, Bold). Para variable fonts, `FontVariation` permite fracionário, mas ainda discipline.
- Bundle só os pesos que usa (cada peso adiciona kilobytes).

**NEVER (Flutter)**:
- Mais que 2-3 famílias.
- Tamanhos arbitrários; commit a `TextTheme` M3 ou customização derivada.
- Body abaixo de 14 (`bodyMedium` M3); idealmente 16 (`bodyLarge`).
- Display fonts em body text.
- Hard-code `MediaQuery.textScaler: TextScaler.noScaling` (quebra A11y).
- `TextStyle(fontSize: ...)` cru; sempre via `Theme.of(context).textTheme`.
- Default para Inter/Roboto/Plus Jakarta Sans quando personalidade importa.
- Pareie fontes parecidas mas diferentes (dois geométricos sans).

## Verify Typography Improvements

- **Hierarchy**: Can you identify heading vs body vs caption instantly?
- **Readability**: Is body text comfortable to read in long passages?
- **Consistency**: Are same-role elements styled identically throughout?
- **Personality**: Does the typography reflect the brand?
- **Performance**: Are web fonts loading efficiently without layout shift?
- **Accessibility**: Does text meet WCAG contrast ratios? Is it zoomable to 200%?

When the type carries the hierarchy on its own, hand off to `{{command_prefix}}impeccable polish` for the final pass.

## Live-mode (Flutter MVP)

No MVP de live mode (v0.1), variantes são source-level e o usuário escolhe via hot reload. Variantes de typography devem nomear:

```dart
// _OnboardingHeroSubdued: TextTheme conservadora, displayMedium em vez de displayLarge
// _OnboardingHeroCommanding: displayLarge w900, letterSpacing -0.02
// _OnboardingHeroEditorial: pareamento serif Fraunces + sans body, italic acent
```

Roadmap (v0.2 com VM Service): cada variante exporá params equivalentes (scale como `range`, pairing como `steps`). Veja [live.md](live.md).
