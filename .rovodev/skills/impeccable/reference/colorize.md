> **Additional context needed**: existing brand colors.

Replace timid grayscale or single-accent designs with a strategic palette: pick a color strategy, choose a hue family that fits the brand, then apply color with intent. More color ≠ better. Strategic color beats rainbow vomit.

---

## Register

Brand: palette IS voice. Pick a color strategy first per SKILL.md (Restrained / Committed / Full palette / Drenched) and follow its dosage. Committed, Full palette, and Drenched deliberately exceed the ≤10% rule; that rule is Restrained only. Unexpected combinations are allowed; a dominant color can own the page when the chosen strategy calls for it.

Product: semantic-first and almost always Restrained. Accent color is reserved for primary action, current selection, and state indicators. Not decoration. Every color has a consistent meaning across every screen.

---

## Assess Color Opportunity

Analyze the current state and identify opportunities:

1. **Understand current state**:
   - **Color absence**: Pure grayscale? Limited neutrals? One timid accent?
   - **Missed opportunities**: Where could color add meaning, hierarchy, or delight?
   - **Context**: What's appropriate for this domain and audience?
   - **Brand**: Are there existing brand colors we should use?

2. **Identify where color adds value**:
   - **Semantic meaning**: Success (green), error (red), warning (yellow/orange), info (blue)
   - **Hierarchy**: Drawing attention to important elements
   - **Categorization**: Different sections, types, or states
   - **Emotional tone**: Warmth, energy, trust, creativity
   - **Wayfinding**: Helping users navigate and understand structure
   - **Delight**: Moments of visual interest and personality

If any of these are unclear from the codebase, ask the user directly to clarify what you cannot infer.

**CRITICAL**: More color ≠ better. Strategic color beats rainbow vomit every time. Every color should have a purpose.

## Plan Color Strategy

Create a purposeful color introduction plan:

- **Color palette**: What colors match the brand/context? (Choose 2-4 colors max beyond neutrals)
- **Dominant color**: Which color owns 60% of colored elements?
- **Accent colors**: Which colors provide contrast and highlights? (30% and 10%)
- **Application strategy**: Where does each color appear and why?

**IMPORTANT**: Color should enhance hierarchy and meaning, not create chaos. Less is more when it matters more.

## Introduce Color Strategically

Add color systematically across these dimensions:

### Semantic Color
- **State indicators**:
  - Success: Green tones (emerald, forest, mint)
  - Error: Red/pink tones (rose, crimson, coral)
  - Warning: Orange/amber tones
  - Info: Blue tones (sky, ocean, indigo)
  - Neutral: Gray/slate for inactive states

- **Status badges**: Colored backgrounds or borders for states (active, pending, completed, etc.)
- **Progress indicators**: Colored bars, rings, or charts showing completion or health

### Accent Color Application
- **Primary actions**: Color the most important buttons/CTAs
- **Links**: Add color to clickable text (maintain accessibility)
- **Icons**: Colorize key icons for recognition and personality
- **Headers/titles**: Add color to section headers or key labels
- **Hover states**: Introduce color on interaction

### Background & Surfaces (Flutter)
- **Tinted neutrals**: M3 entrega via `surfaceTint` automático. Não desligue. Para customizar, override `colorScheme.surface` mantendo chroma 0.005-0.01 puxando para a `primary`.
- **Seções coloridas**: `Container(color: scheme.surfaceContainerLow)` para uma faixa, `surfaceContainerHigh` para a próxima. M3 já entrega 5 níveis prontos.
- **Gradients**: `LinearGradient(colors: [scheme.primary, scheme.tertiary], stops: [0, 1])` intencional. NÃO purple-to-blue genérico.
- **Cards**: `Card.filled` (M3) ou `Material(color: scheme.surfaceContainer, elevation: 0)`.

**OKLCH como modelo mental**: escolha cores em oklch.com (perceptualmente uniforme), depois cole hex no `Color(0xFF...)` ou `seedColor`. Flutter 3.27+ tem `Color.from(... colorSpace: ColorSpace.displayP3)` para apps que precisam de wide gamut em iPhones recentes.

### Data Visualization
- **Charts & graphs**: Use color to encode categories or values
- **Heatmaps**: Color intensity shows density or importance
- **Comparison**: Color coding for different datasets or timeframes

### Borders & Accents
- **Hairline borders**: 1px colored borders on full perimeter (not side-stripes; see the absolute ban on `border-left/right > 1px`)
- **Underlines**: Color underlines for emphasis or active states
- **Dividers**: Subtle colored dividers instead of gray lines
- **Focus rings**: Colored focus indicators matching brand
- **Surface tints**: A 4-8% background wash of the accent color instead of a stripe

**NEVER**: `border-left` or `border-right` greater than 1px as a colored accent stripe. This is one of the three absolute bans in the parent skill. If you want to mark a card as "active" or "warning", use a full hairline border, a background tint, a leading glyph, or a numbered prefix. Not a side stripe.

### Typography Color
- **Colored headings**: Use brand colors for section headings (maintain contrast)
- **Highlight text**: Color for emphasis or categories
- **Labels & tags**: Small colored labels for metadata or categories

### Decorative Elements
- **Illustrations**: Add colored illustrations or icons
- **Shapes**: Geometric shapes in brand colors as background elements
- **Gradients**: Colorful gradient overlays or mesh backgrounds
- **Blobs/organic shapes**: Soft colored shapes for visual interest

## Balance & Refinement

Ensure color addition improves rather than overwhelms:

### Maintain Hierarchy
- **Dominant color** (60%): Primary brand color or most used accent
- **Secondary color** (30%): Supporting color for variety
- **Accent color** (10%): High contrast for key moments
- **Neutrals** (remaining): Gray/black/white for structure

### Accessibility
- **Contrast ratios**: Ensure WCAG compliance (4.5:1 for text, 3:1 for UI components)
- **Don't rely on color alone**: Use icons, labels, or patterns alongside color
- **Test for color blindness**: Verify red/green combinations work for all users

### Cohesion
- **Consistent palette**: Use colors from defined palette, not arbitrary choices
- **Systematic application**: Same color meanings throughout (green always = success)
- **Temperature consistency**: Warm palette stays warm, cool stays cool

**NEVER (Flutter)**:
- Usar arco-íris (escolha 2-4 cores além dos neutros).
- Aplicar cor aleatória sem significado semântico.
- Texto cinza sobre fundo colorido (use `onPrimary`/`onSecondary` que M3 já calibra).
- Cinza puro em neutros (M3 já tinta via `surfaceTint`; não desligue).
- `Colors.black` ou `Colors.white` literal em qualquer lugar de UI.
- Violar contraste WCAG (validar com cor RESOLVIDA de `colorScheme`, não com literal).
- Cor sozinha como único indicador (issue de A11y).
- `seedColor: Colors.deepPurple` (default `flutter create`).
- `LinearGradient(colors: [purple, blue])` em qualquer AppBar ou hero (AI slop).

## Verify Color Addition

Test that colorization improves the experience:

- **Better hierarchy**: Does color guide attention appropriately?
- **Clearer meaning**: Does color help users understand states/categories?
- **More engaging**: Does the interface feel warmer and more inviting?
- **Still accessible**: Do all color combinations meet WCAG standards?
- **Not overwhelming**: Is color balanced and purposeful?

When the palette earns its place, hand off to `/impeccable polish` for the final pass.

## Live-mode signature params

Live mode no MVP Flutter (v0.1) é manual: agente edita variantes inline e usuário escolhe via hot reload. Variantes de cor devem declarar uma direção clara em comentário:

```dart
// _ProductCardRestrained: accent ≤10%, scheme.primary só no badge
// _ProductCardCommitted: scheme.primary domina o card inteiro
// _ProductCardDrenched: scheme.primary é a tela; texto em onPrimary
```

Quando v0.2 chegar com VM Service, cada variante vai declarar params equivalentes (color-amount como `range`, palette selection como `steps`). Veja [live.md](live.md) e o roadmap.
