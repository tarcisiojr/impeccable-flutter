Space is the most underused design tool. Find the layout's actual problem (monotone spacing, weak hierarchy, identical card grids, the centered-stack default) and fix the structure, not the surface.

---

## Register

Brand: asymmetric compositions, fluid spacing with `clamp()`, intentional grid-breaking for emphasis. Rhythm through contrast: tight groupings paired with generous separations.

Product: predictable grids, consistent densities, familiar navigation patterns. Responsive behavior is structural (collapse sidebar, responsive table), not fluid typography. Consistency IS an affordance.

---

## Assess Current Layout

Analyze what's weak about the current spatial design:

1. **Spacing**:
   - Is spacing consistent or arbitrary? (Random padding/margin values)
   - Is all spacing the same? (Equal padding everywhere = no rhythm)
   - Are related elements grouped tightly, with generous space between groups?

2. **Visual hierarchy**:
   - Apply the squint test: blur your (metaphorical) eyes. Can you still identify the most important element, second most important, and clear groupings?
   - Is hierarchy achieved effectively? (Space and weight alone can be enough; is the current approach working?)
   - Does whitespace guide the eye to what matters?

3. **Grid & structure**:
   - Is there a clear underlying structure, or does the layout feel random?
   - Are identical card grids used everywhere? (Icon + heading + text, repeated endlessly)
   - Is everything centered? (Left-aligned with asymmetric layouts feels more designed, but not a hard and fast rule)

4. **Rhythm & variety**:
   - Does the layout have visual rhythm? (Alternating tight/generous spacing)
   - Is every section structured the same way? (Monotonous repetition)
   - Are there intentional moments of surprise or emphasis?

5. **Density**:
   - Is the layout too cramped? (Not enough breathing room)
   - Is the layout too sparse? (Excessive whitespace without purpose)
   - Does density match the content type? (Data-dense UIs need tighter spacing; marketing pages need more air)

**CRITICAL**: Layout problems are often the root cause of interfaces feeling "off" even when colors and fonts are fine. Space is a design material; use it with intention.

## Plan Layout Improvements

Consult the [spatial design reference](spatial-design.md) for detailed guidance on grids, rhythm, and container queries.

Create a systematic plan:

- **Spacing system**: Use a consistent scale (a framework's built-in scale like Tailwind's, rem-based tokens, or a custom system). The specific values matter less than consistency.
- **Hierarchy strategy**: How will space communicate importance?
- **Layout approach**: What structure fits the content? Flex for 1D, Grid for 2D, named areas for complex page layouts.
- **Rhythm**: Where should spacing be tight vs generous?

## Improve Layout Systematically

### Estabelecer um Sistema de Espaçamento (Flutter)

- Use uma escala consistente. Em Flutter: `ThemeExtension<SpacingTokens>` ou classe estática `AppSpacing`. Valores tipicamente 4, 8, 12, 16, 24, 32, 48, 64, 96 lógicos.
- Nomes semânticos: `spacing.md`, `spacing.lg`, não `spacing16`.
- Use `Padding` + `SizedBox` ou parâmetro `spacing:` (Flutter 3.27+ em `Row`/`Column`/`Wrap`) entre irmãos. Não use `Container(margin:)` para irmãos (confuso e dificulta alinhamento).
- Não há `clamp()` em Flutter. Para variar spacing por window class, switch via `LayoutBuilder` ou `MediaQuery.sizeOf`.

### Criar Ritmo Visual

- **Tight grouping** para items relacionados (8-12 lógicos entre siblings via `SizedBox`).
- **Generous separation** entre seções distintas (32-64 lógicos em mobile, 48-96 em tablet/desktop).
- **Varied spacing** dentro das seções; não toda linha precisa do mesmo gap.
- **Composições assimétricas**: `Stack` + `Positioned`, `Align` em pontos não-óbvios, `SliverAppBar` colapsável.

### Escolher a ferramenta certa de layout

- **`Row` / `Column` para 1D**: rows de items, nav bars, grupos de botão, conteúdo de card, internals de componente. É a ferramenta default e correta para a maioria.
- **`GridView` / `Wrap` para 2D**: estrutura page-level, dashboards, telas data-dense, qualquer coisa onde rows E columns precisam controle coordenado.
- **`Wrap` em vez de `Row` quando items podem quebrar**: tags, chips, lista horizontal que pode wrap.
- **`GridView.builder(SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 280))`** para grids responsivos sem breakpoint.
- **`CustomMultiChildLayout`** para layouts realmente intricados (raro). `Stack` com `Positioned`/`AnimatedPositioned` resolve a maioria.
- **`Flexible` / `Expanded`** para overflow safety. Sem isso, `Row` com `Text` longo crasha visualmente.

### Break Card Grid Monotony

- Don't default to card grids for everything; spacing and alignment create visual grouping naturally
- Use cards only when content is truly distinct and actionable. Never nest cards inside cards
- Vary card sizes, span columns, or mix cards with non-card content to break repetition

### Strengthen Visual Hierarchy

- Use the fewest dimensions needed for clear hierarchy. Space alone can be enough; generous whitespace around an element draws the eye. Some of the most polished designs achieve rhythm with just space and weight. Add color or size contrast only when simpler means aren't sufficient.
- Be aware of reading flow: in LTR languages, the eye naturally scans top-left to bottom-right, but primary action placement depends on context (e.g., bottom-right in dialogs, top in navigation).
- Create clear content groupings through proximity and separation.

### Gerenciar Depth & Elevation (Flutter)

- Em Flutter, ordem visual é decidida pela árvore (o que vem depois fica em cima). Para "camada acima de tudo", use `Overlay`/`OverlayEntry` (que `Tooltip`, `showMenu`, `showModalBottomSheet`, `Dialog` usam por baixo).
- Material 3 entrega 6 níveis de elevation (0, 1, 3, 6, 8, 12) que mapeiam a `surfaceContainer*`. Use `Material(elevation:)` ou widgets que herdam (`Card`, `MenuAnchor`, `Drawer`).
- Sombras devem ser sutis. Em dark mode, sombras quase desaparecem; profundidade vem da `surfaceContainer*` mais clara.
- Use elevation para reforçar hierarquia, não decoração.

### Optical Adjustments

- Se um ícone parece off-center apesar de geometricamente centrado, nudge via `Transform.translate(offset: Offset(2, 0))`. Só quando você tem certeza visual; não ajuste especulativamente.
- `IconButton`, `ListTile.leading`, `AppBar.title` em Flutter já tem ajustes ópticos para muitos glyphs.

**NEVER (Flutter)**:
- Valores de spacing arbitrários fora da sua escala (`EdgeInsets.all(7)`, `EdgeInsets.all(13)`).
- Todo spacing igual (variedade cria hierarquia; `EdgeInsets.all(16)` repetido em N widgets adjacentes é o anti-pattern `monotonous-spacing`).
- Embrulhar tudo em `Card` (não tudo precisa container).
- `Card` aninhado em `Card`.
- Grids idênticos de Card icon + heading + text repetidos (anti-pattern `icon-tile-stack`).
- Centralizar tudo (`Center`/`MainAxisAlignment.center` em ≥80% dos containers é o anti-pattern `everything-centered`).
- Hero card com gradient + big number + label + sparkline como template (a menos que seja dado real e justificado).
- `GridView` quando `Row` ou `Wrap` resolveriam mais simples.
- `Stack` + `Positioned` quando `Align` resolve.

## Verify Layout Improvements

- **Squint test**: Can you identify primary, secondary, and groupings with blurred vision?
- **Rhythm**: Does the page have a satisfying beat of tight and generous spacing?
- **Hierarchy**: Is the most important content obvious within 2 seconds?
- **Breathing room**: Does the layout feel comfortable, not cramped or wasteful?
- **Consistency**: Is the spacing system applied uniformly?
- **Responsiveness**: Does the layout adapt gracefully across screen sizes?

When the rhythm and hierarchy land, hand off to `$impeccable-flutter polish` for the final pass.

## Live-mode (Flutter MVP)

No MVP de live mode, variantes são source-level. Variantes de layout devem nomear estrutura E densidade:

```dart
// _DashboardStackedAiry: Column, EdgeInsets.all(spacing.lg), gap spacing.lg
// _DashboardGridDense: GridView.count(crossAxisCount: 2), EdgeInsets.all(spacing.sm)
// _DashboardBentoAsymmetric: Stack + Positioned, varied spacing
```

Roadmap v0.2: cada variante exporá `density` (range) + `structure` (steps stacked/grid/bento). Veja [live.md](live.md).
