When asked for "bolder," AI defaults to the same tired tricks: cyan/purple gradients, glassmorphism, neon accents on dark backgrounds, gradient text on metrics. These are the opposite of bold. Reject them first, then increase visual impact and personality through stronger hierarchy, committed scale, and decisive type.

---

## Register

Brand: "bolder" means distinctive. Extreme scale, unexpected color, typographic risk, committed POV.

Product: "bolder" rarely means theatrics; those undermine trust. It means stronger hierarchy, clearer weight contrast, one sharper accent, more committed density. The amplification is in clarity, not drama.

---

## Assess Current State

Analyze what makes the design feel too safe or boring:

1. **Identify weakness sources**:
   - **Generic choices**: System fonts, basic colors, standard layouts
   - **Timid scale**: Everything is medium-sized with no drama
   - **Low contrast**: Everything has similar visual weight
   - **Static**: No motion, no energy, no life
   - **Predictable**: Standard patterns with no surprises
   - **Flat hierarchy**: Nothing stands out or commands attention

2. **Understand the context**:
   - What's the brand personality? (How far can we push?)
   - What's the purpose? (Marketing can be bolder than financial dashboards)
   - Who's the audience? (What will resonate?)
   - What are the constraints? (Brand guidelines, accessibility, performance)

If any of these are unclear from the codebase, ask the user directly to clarify what you cannot infer.

**CRITICAL**: "Bolder" doesn't mean chaotic or garish. It means distinctive, memorable, and confident. Think intentional drama, not random chaos.

**WARNING - AI SLOP TRAP**: Review ALL the DON'T guidelines from the parent impeccable skill (already loaded in this context) before proceeding. Bold means distinctive, not "more effects."

## Plan Amplification

Create a strategy to increase impact while maintaining coherence:

- **Focal point**: What should be the hero moment? (Pick ONE, make it amazing)
- **Personality direction**: Maximalist chaos? Elegant drama? Playful energy? Dark moody? Choose a lane.
- **Risk budget**: How experimental can we be? Push boundaries within constraints.
- **Hierarchy amplification**: Make big things BIGGER, small things smaller (increase contrast)

**IMPORTANT**: Bold design must still be usable. Impact without function is just decoration.

## Amplify the Design

Systematically increase impact across these dimensions:

### Typography Amplification (Flutter)
- **Trocar fontes genéricas**: substitua system stack ou Inter por display distintivo. Em Flutter: `GoogleFonts.X()` ou bundle em `pubspec.yaml > fonts`. Veja [typography.md](typography.md) e [brand.md](brand.md) para reflex-rejects.
- **Escala extrema**: salto dramático entre `displayLarge` (57+) e `bodyMedium` (14). Em vez de 1.5x, vá 3-5x.
- **Contraste de peso**: pareie `FontWeight.w900` com `FontWeight.w200`, não w600 com w400. Variable fonts via `FontVariation('wght', 880)` para peso fracionário.
- **Escolhas inesperadas**: variable fonts (`FontVariation`), display fonts para headlines, larguras condensed/extended, mono como accent intencional (NÃO como default preguiçoso de "dev tool").

### Color Intensification (Flutter)
- **Aumentar saturação**: shift `seedColor` para hue mais vibrante. NÃO neon. NÃO `Colors.deepPurple` (default `flutter create`).
- **Paleta bold**: combinações inesperadas. Evite gradient purple-blue AI slop. Em `LinearGradient`, prefira cor sólida saturada da marca.
- **Cor dominante**: deixe uma cor (`primary` ou `tertiary`) ocupar 60% da tela. Brand surface drenched.
- **Accents nítidos**: cores accent de alto contraste. Material 3 já entrega `primaryContainer` / `tertiaryContainer` que são candidatos naturais.
- **Tinted neutrals**: M3 já entrega via `surfaceTint`. Não desligue.
- **Gradients ricos**: multi-stop intencionais via `LinearGradient(colors: [...stops], stops: [0, 0.4, 1])`. NÃO purple-to-blue genérico.

### Spatial Drama
- **Extreme scale jumps**: Make important elements 3-5x larger than surroundings
- **Break the grid**: Let hero elements escape containers and cross boundaries
- **Asymmetric layouts**: Replace centered, balanced layouts with tension-filled asymmetry
- **Generous space**: Use white space dramatically (100-200px gaps, not 20-40px)
- **Overlap**: Layer elements intentionally for depth

### Visual Effects (Flutter)
- **Sombras dramáticas**: M3 entrega via `Material(elevation: 8)`. Para hero brand surface, `BoxShadow(blurRadius: 40, color: brand.withValues(alpha: 0.3))` deliberada.
- **Tratamentos de fundo**: `CustomPainter` para mesh, noise via `flutter_shaders`, geometric patterns via `SvgPicture` em background. NÃO purple-to-blue gradient AppBar.
- **Texture & depth**: grain via shader, duotone via `ColorFiltered(colorFilter: ColorFilter.mode(...))`, layered `Stack`. NÃO glassmorphism em todo card (overused).
- **Borders & frames**: `Border.all(width: 4)` decisivo, frames custom via `ClipPath` com `CustomClipper`. NÃO `BoxDecoration(border: Border(left: BorderSide(width: 4, color: accent)))` sozinho: esse é o **side-stripe** banido.
- **Elementos custom**: ilustrações próprias (`SvgPicture.asset`), ícones desenhados, Rive animations.

### Motion & Animation (Flutter)
- **Coreografia de entrada**: staggered via `AnimationController` + `Interval` ou `flutter_staggered_animations` package. Delays 50-100ms entre items.
- **Scroll effects**: `SliverAppBar` colapsável + `CustomScrollView`, parallax via `Transform.translate(offset: Offset(0, scroll * 0.5))`, reveal via `VisibilityDetector` package.
- **Micro-interactions**: ripple custom em botões hero, `AnimatedSwitcher` em counters, `Hero` entre rotas para continuidade brand.
- **Transitions**: `Curves.easeOutCubic` / `easeOutQuart` / custom `Cubic(0.16, 1, 0.3, 1)`. **Nunca** `Curves.bounceOut` ou `Curves.elasticIn`: barateiam o efeito.

### Composition Boldness
- **Hero moments**: Create clear focal points with dramatic treatment
- **Diagonal flows**: Escape horizontal/vertical rigidity with diagonal arrangements
- **Full-bleed elements**: Use full viewport width/height for impact
- **Unexpected proportions**: Golden ratio? Throw it out. Try 70/30, 80/20 splits

**NEVER**:
- Add effects randomly without purpose (chaos ≠ bold)
- Sacrifice readability for aesthetics (body text must be readable)
- Make everything bold (then nothing is bold; you need contrast)
- Ignore accessibility (bold design must still meet WCAG standards)
- Overwhelm with motion (animation fatigue is real)
- Copy trendy aesthetics blindly (bold means distinctive, not derivative)

## Verify Quality

Ensure amplification maintains usability and coherence:

- **NOT AI slop**: Does this look like every other AI-generated "bold" design? If yes, start over.
- **Still functional**: Can users accomplish tasks without distraction?
- **Coherent**: Does everything feel intentional and unified?
- **Memorable**: Will users remember this experience?
- **Performant**: Do all these effects run smoothly?
- **Accessible**: Does it still meet accessibility standards?

**The test**: If you showed this to someone and said "AI made this bolder," would they believe you immediately? If yes, you've failed. Bold means distinctive, not "more AI effects."

When the result feels right, hand off to `/impeccable-flutter polish` for the final pass.
