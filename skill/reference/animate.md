> **Additional context needed**: performance constraints.

Add motion that conveys state, gives feedback, and clarifies hierarchy. Cut motion that exists only for decoration. Animation fatigue is a real cost; spend the budget on the moments that need it.

---

## Register

Brand: orchestrated page-load sequences, staggered reveals, scroll-driven animation. Motion is part of the voice; one well-rehearsed entrance beats scattered micro-interactions.

Product: 150–250 ms on most transitions. Motion conveys state: feedback, reveal, loading, transitions between views. No page-load choreography; users are in a task and won't wait for it.

---

## Assess Animation Opportunities

Analyze where motion would improve the experience:

1. **Identify static areas**:
   - **Missing feedback**: Actions without visual acknowledgment (button clicks, form submission, etc.)
   - **Jarring transitions**: Instant state changes that feel abrupt (show/hide, page loads, route changes)
   - **Unclear relationships**: Spatial or hierarchical relationships that aren't obvious
   - **Lack of delight**: Functional but joyless interactions
   - **Missed guidance**: Opportunities to direct attention or explain behavior

2. **Understand the context**:
   - What's the personality? (Playful vs serious, energetic vs calm)
   - What's the performance budget? (Mobile-first? Complex page?)
   - Who's the audience? (Motion-sensitive users? Power users who want speed?)
   - What matters most? (One hero animation vs many micro-interactions?)

If any of these are unclear from the codebase, {{ask_instruction}}

**CRITICAL**: Respect `prefers-reduced-motion`. Always provide non-animated alternatives for users who need them.

## Plan Animation Strategy

Create a purposeful animation plan:

- **Hero moment**: What's the ONE signature animation? (Page load? Hero section? Key interaction?)
- **Feedback layer**: Which interactions need acknowledgment?
- **Transition layer**: Which state changes need smoothing?
- **Delight layer**: Where can we surprise and delight?

**IMPORTANT**: One well-orchestrated experience beats scattered animations everywhere. Focus on high-impact moments.

## Implement Animations

Add motion systematically across these categories:

### Entrance Animations
- **Page load choreography**: Stagger element reveals (100-150ms delays), fade + slide combinations
- **Hero section**: Dramatic entrance for primary content (scale, parallax, or creative effects)
- **Content reveals**: Scroll-triggered animations using intersection observer
- **Modal/drawer entry**: Smooth slide + fade, backdrop fade, focus management

### Micro-interactions
- **Button feedback**:
  - Hover: Subtle scale (1.02-1.05), color shift, shadow increase
  - Click: Quick scale down then up (0.95 → 1), ripple effect
  - Loading: Spinner or pulse state
- **Form interactions**:
  - Input focus: Border color transition, slight scale or glow
  - Validation: Shake on error, check mark on success, smooth color transitions
- **Toggle switches**: Smooth slide + color transition (200-300ms)
- **Checkboxes/radio**: Check mark animation, ripple effect
- **Like/favorite**: Scale + rotation, particle effects, color transition

### State Transitions
- **Show/hide**: Fade + slide (not instant), appropriate timing (200-300ms)
- **Expand/collapse**: Height transition with overflow handling, icon rotation
- **Loading states**: Skeleton screen fades, spinner animations, progress bars
- **Success/error**: Color transitions, icon animations, gentle scale pulse
- **Enable/disable**: Opacity transitions, cursor changes

### Navigation & Flow
- **Page transitions**: Crossfade between routes, shared element transitions
- **Tab switching**: Slide indicator, content fade/slide
- **Carousel/slider**: Smooth transforms, snap points, momentum
- **Scroll effects**: Parallax layers, sticky headers with state changes, scroll progress indicators

### Feedback & Guidance
- **Hover hints**: Tooltip fade-ins, cursor changes, element highlights
- **Drag & drop**: Lift effect (shadow + scale), drop zone highlights, smooth repositioning
- **Copy/paste**: Brief highlight flash on paste, "copied" confirmation
- **Focus flow**: Highlight path through form or workflow

### Delight Moments
- **Empty states**: Subtle floating animations on illustrations
- **Completed actions**: Confetti, check mark flourish, success celebrations
- **Easter eggs**: Hidden interactions for discovery
- **Contextual animation**: Weather effects, time-of-day themes, seasonal touches

## Technical Implementation

Use appropriate techniques for each animation:

### Timing & Easing

**Durations by purpose:**
- **100-150ms**: Instant feedback (button press, toggle)
- **200-300ms**: State changes (hover, menu open)
- **300-500ms**: Layout changes (accordion, modal)
- **500-800ms**: Entrance animations (page load)

**Easing curves (use these, not CSS defaults):**
```css
/* Recommended: natural deceleration */
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);    /* Smooth */
--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);   /* Slightly snappier */
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);     /* Confident, decisive */

/* AVOID: feel dated and tacky */
/* bounce: cubic-bezier(0.34, 1.56, 0.64, 1); */
/* elastic: cubic-bezier(0.68, -0.6, 0.32, 1.6); */
```

**Exit animations are faster than entrances.** Use ~75% of enter duration.

### Animações implícitas (preferir)
```dart
// Simples, declarativas, automaticamente animam quando state muda
AnimatedContainer(duration: 300.ms, curve: Curves.easeOutCubic, color: ...)
AnimatedOpacity(duration: 200.ms, opacity: visible ? 1.0 : 0.0, child: ...)
AnimatedSwitcher(duration: 250.ms, child: KeyedSubtree(key: ValueKey(state), child: ...))
AnimatedAlign(duration: 300.ms, alignment: ...)
AnimatedSlide(duration: 200.ms, offset: ...)
AnimatedScale(duration: 150.ms, scale: pressed ? 0.96 : 1.0)
```

Catálogo completo em [motion-design.md](motion-design.md).

### Animações explícitas (quando precisa de controle)
```dart
// Para sequência, repeat, custom physics, gesto-driven
class _S extends State<...> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: 600.ms);
  late final _tween = Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override Widget build(context) =>
      SlideTransition(position: _tween, child: const Hero(/*...*/));

  @override void dispose() { _controller.dispose(); super.dispose(); }
}
```

### Hero (continuidade entre rotas)
```dart
// Tela A
Hero(tag: 'product-${id}', child: Image.network(url))
// Tela B
Hero(tag: 'product-${id}', child: Image.network(url, fit: BoxFit.cover))
// Flutter anima a transição automática entre rotas
```

### Performance
- **Materiais de motion**: `Transform`/`Opacity`/`Color` confiáveis; `BackdropFilter`/`ColorFiltered`/`ShaderMask` quando agregam polish e são bounded.
- **Safety de layout**: evite animar `width`/`height`/`padding` casualmente (causa relayout). Use `Transform.scale`, `AnimatedAlign`, ou estruturas que não disparam relayout.
- **`RepaintBoundary`**: envolva o widget animado, especialmente cercado de conteúdo estático.
- **`AnimatedBuilder` com `child:`**: o child não rebuilda em cada tick.
- **Monitorar FPS**: `flutter run --profile` + DevTools Performance → Frame chart. 60fps em targets, 120fps em premium.

### Acessibilidade
```dart
// Em todo widget que anima
final reduceMotion = MediaQuery.disableAnimationsOf(context);
AnimatedContainer(
  duration: reduceMotion ? Duration.zero : 300.ms,
  curve: reduceMotion ? Curves.linear : Curves.easeOutCubic,
)
```

**NEVER (Flutter)**:
- `Curves.bounce*` ou `Curves.elastic*` em product. Em jogos OK, em product nunca.
- Animar `width`/`height`/`padding` casualmente (`AnimatedContainer` mudando size = relayout em cada frame). Prefira `Transform.scale`, `AnimatedAlign`, ou `AnimatedSize`.
- Durações >500ms para feedback (sente lag).
- Animar sem propósito (toda animação precisa razão; veja shared design law em SKILL.md).
- Ignorar `MediaQuery.disableAnimationsOf` (violação A11y).
- Animar tudo (motion fatigue real).
- Bloquear interação durante animação a menos que intencional.
- Esquecer `dispose()` em `AnimationController` (vazamento garantido).

## Verify Quality

Test animations thoroughly:

- **Smooth at 60fps**: No jank on target devices
- **Feels natural**: Easing curves feel organic, not robotic
- **Appropriate timing**: Not too fast (jarring) or too slow (laggy)
- **Reduced motion works**: Animations disabled or simplified appropriately
- **Doesn't block**: Users can interact during/after animations
- **Adds value**: Makes interface clearer or more delightful

When the motion clarifies state instead of decorating it, hand off to `{{command_prefix}}impeccable-flutter polish` for the final pass.
