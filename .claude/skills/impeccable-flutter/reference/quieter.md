Quiet design is harder than bold design. Subtlety needs precision. Reduce visual intensity in designs that are too loud, aggressive, or overstimulating without losing personality or making the result generic.

---

## Register

Brand: "quieter" means more restrained palette, more whitespace, more typographic air. Drama is reduced, not eliminated; the POV stays intact.

Product: "quieter" means reducing visual noise. Fewer background accents, flatter cards, less color, less motion. The tool should disappear more completely into the task.

---

## Assess Current State

Analyze what makes the design feel too intense:

1. **Identify intensity sources**:
   - **Color saturation**: Overly bright or saturated colors
   - **Contrast extremes**: Too much high-contrast juxtaposition
   - **Visual weight**: Too many bold, heavy elements competing
   - **Animation excess**: Too much motion or overly dramatic effects
   - **Complexity**: Too many visual elements, patterns, or decorations
   - **Scale**: Everything is large and loud with no hierarchy

2. **Understand the context**:
   - What's the purpose? (Marketing vs tool vs reading experience)
   - Who's the audience? (Some contexts need energy)
   - What's working? (Don't throw away good ideas)
   - What's the core message? (Preserve what matters)

If any of these are unclear from the codebase, STOP and call the AskUserQuestion tool to clarify.

**CRITICAL**: "Quieter" doesn't mean boring or generic. It means refined and easier on the eyes. Think luxury, not laziness.

## Plan Refinement

Create a strategy to reduce intensity while maintaining impact:

- **Color approach**: Desaturate or shift to more restrained tones?
- **Hierarchy approach**: Which elements should stay bold (very few), which should recede?
- **Simplification approach**: What can be removed entirely?
- **Sophistication approach**: How can we signal quality through restraint?

**IMPORTANT**: Subtlety requires precision. Quiet without intent collapses to generic.

## Refine the Design

Systematically reduce intensity across these dimensions:

### Color Refinement (Flutter)
- **Reduzir saturação**: shift de chroma alta para 70-85%. Em `ColorScheme.fromSeed`, escolha hue mais quieto (azul-grafite em vez de azul-cobalto).
- **Suavizar paleta**: substituir `tertiary` brilhante por tom mais muted; ou tirar `tertiary` e ficar só com primary + neutros.
- **Menos variedade**: M3 já entrega 30 papéis, mas nem todos precisam aparecer na tela. Default para Restrained: `surface` + `onSurface` + `primary` (10%).
- **Dominância neutra**: deixe `surface` / `surfaceContainer*` ocuparem 70%+ da tela. Cor só em ação primária e indicador de estado.
- **Contrastes gentis**: alto contraste só onde importa (CTA, error). Para metadata, `onSurfaceVariant` em vez de `onSurface` total.
- **Tinted neutrals**: M3 já entrega via `surfaceTint`. Não desligue.
- **Nunca cinza sobre cor**: gray sobre `colorScheme.primary` fica washed-out. Use `onPrimary` (M3 garante contraste correto) ou `primary.withValues(alpha: 0.6)`.

### Visual Weight Reduction (Flutter)
- **Tipografia**: reduzir `fontWeight` (w900 → w600, w700 → w500). Para variable fonts, `FontVariation('wght', 480)` em vez de bold cheio. Reduzir tamanho de `displayLarge` para `headlineLarge` se for hero.
- **Hierarquia por sutileza**: peso + tamanho + espaço, não por cor e bold.
- **White space**: subir tokens de spacing (md → lg, lg → xl). `Padding` mais generoso entre seções.
- **Borders & lines**: reduzir `Border.all(width: 0.5)` (hairline), ou remover. `Divider(thickness: 0.5, color: scheme.outlineVariant)` em vez de `Divider(thickness: 2)`.

### Simplification
- **Remove decorative elements**: Gradients, shadows, patterns, textures that don't serve purpose
- **Simplify shapes**: Reduce border radius extremes, simplify custom shapes
- **Reduce layering**: Flatten visual hierarchy where possible
- **Clean up effects**: Reduce or remove blur effects, glows, multiple shadows

### Motion Reduction (Flutter)
- **Reduzir intensidade**: distâncias menores (`Tween(begin: Offset(0, 0.05), end: Offset.zero)` em vez de 0.2), easing gentle (`Curves.easeOutCubic` em vez de `Curves.easeOutExpo`).
- **Remover decorativas**: manter motion funcional (state change, entrance, transition entre rotas), remover flourishes (parallax exagerado, stagger longo, scale-pop em buttons).
- **Micro-interactions sutis**: ripple default do Material, `AnimatedScale(scale: pressed ? 0.98 : 1)` em vez de scale-bounce.
- **Easing refinado**: `Curves.easeOutCubic` ou `Curves.easeOutQuart`. **Nunca** bounce ou elastic.
- **Remover totalmente**: se a animação não serve propósito, `Duration.zero` ou widget sem animation.

### Composition Refinement
- **Reduce scale jumps**: Smaller contrast between sizes creates calmer feeling
- **Align to grid**: Bring rogue elements back into systematic alignment
- **Even out spacing**: Replace extreme spacing variations with consistent rhythm

**NEVER**:
- Make everything the same size/weight (hierarchy still matters)
- Remove all color (quiet ≠ grayscale)
- Eliminate all personality (maintain character through refinement)
- Sacrifice usability for aesthetics (functional elements still need clear affordances)
- Make everything small and light (some anchors needed)

## Verify Quality

Ensure refinement maintains quality:

- **Still functional**: Can users still accomplish tasks easily?
- **Still distinctive**: Does it have character, or is it generic now?
- **Better reading**: Is text easier to read for extended periods?
- **Restrained, not absent**: Does the POV survive the cuts?

When the result feels right, hand off to `/impeccable-flutter polish` for the final pass.
