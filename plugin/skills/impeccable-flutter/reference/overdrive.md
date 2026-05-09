Start your response with:

```
──────────── ⚡ OVERDRIVE ─────────────
》》》 Entering overdrive mode...
```

Push an interface past conventional limits. This isn't just about visual effects. It's about using the full power of the browser to make any part of an interface feel extraordinary: a table that handles a million rows, a dialog that morphs from its trigger, a form that validates in real-time with streaming feedback, a page transition that feels cinematic.

**EXTRA IMPORTANT FOR THIS COMMAND**: Context determines what "extraordinary" means. A particle system on a creative portfolio is impressive. The same particle system on a settings page is embarrassing. But a settings page with instant optimistic saves and animated state transitions? That's extraordinary too. Understand the project's personality and goals before deciding what's appropriate.

### Propose Before Building

This command has the highest potential to misfire. Do NOT jump straight into implementation. You MUST:

1. **Think through 2-3 different directions**: consider different techniques, levels of ambition, and aesthetic approaches. For each direction, briefly describe what the result would look and feel like.
2. **STOP and call the AskUserQuestion tool to clarify.** to present these directions and get the user's pick before writing any code. Explain trade-offs (browser support, performance cost, complexity).
3. Only proceed with the direction the user confirms.

Skipping this step risks building something embarrassing that needs to be thrown away.

### Iterate with Hot Reload + DevTools

Efeitos tecnicamente ambiciosos quase nunca funcionam de primeira. Você DEVE usar `flutter run --profile -d <real device>` + DevTools Performance para preview e iterar. Não assuma que o efeito está certo, confira:

- Hot reload (`r`) para ajustar valores rápidos.
- Hot restart (`R`) quando state muda fundamental.
- DevTools Performance → Frame chart para garantir 60fps (vermelho = jank).
- Em device físico, NUNCA emulador. Shaders e `BackdropFilter` rodam diferente.

Espere múltiplas rodadas de refinamento. O gap entre "tecnicamente funciona" e "parece extraordinário" fecha por iteração visual, não código sozinho.

---

## Assess What "Extraordinary" Means Here

The right kind of technical ambition depends entirely on what you're working with. Before choosing a technique, ask: **what would make a user of THIS specific interface say "wow, that's nice"?**

### For visual/marketing surfaces
Pages, hero sections, landing pages, portfolios: the "wow" is often sensory: a scroll-driven reveal, a shader background, a cinematic page transition, generative art that responds to the cursor.

### For functional UI
Tables, forms, dialogs, navigation: the "wow" is in how it FEELS: a dialog that morphs from the button that triggered it via View Transitions, a data table that renders 100k rows at 60fps via virtual scrolling, a form with streaming validation that feels instant, drag-and-drop with spring physics.

### For performance-critical UI
The "wow" is invisible but felt: a search that filters 50k items without a flicker, a complex form that never blocks the main thread, an image editor that processes in near-real-time. The interface just never hesitates.

### For data-heavy interfaces
Charts and dashboards: the "wow" is in fluidity: GPU-accelerated rendering via Canvas/WebGL for massive datasets, animated transitions between data states, force-directed graph layouts that settle naturally.

**The common thread**: something about the implementation goes beyond what users expect from a web interface. The technique serves the experience, not the other way around.

## The Toolkit

Organized by what you're trying to achieve, not by technology name.

### Make transitions feel cinematic (Flutter)
- **`Hero` widget**: shared element morphing entre rotas. `Hero(tag: 'product-$id', child: Image(...))` em ambas as telas. Flutter anima automaticamente. Para customizar a curva, `flightShuttleBuilder`.
- **`PageRouteBuilder` + `SlideTransition`/`FadeTransition`**: transições custom entre rotas.
- **`SharedAxisTransition`** (animations package): Material 3 emphasized motion para transições de tab/fluxo.
- **Spring physics**: `SpringSimulation` + `AnimationController.animateWith()`. Mass, stiffness, damping. Built-in, sem package.

### Tie animation to scroll position
- **`SliverAppBar(pinned, floating, snap)`**: AppBar que colapsa via scroll, built-in.
- **`CustomScrollView` + `Sliver*`**: composição parallax.
- **`NotificationListener<ScrollUpdateNotification>`**: dispara animation baseada em offset.
- **`flutter_parallax_pro` ou implementação manual via `Transform.translate(offset: Offset(0, scroll * 0.5))`**.

### Render além do framework

- **`CustomPainter`**: pixel-level via Canvas API. Particle systems, generative art, custom charts. Built-in, no package.
- **`flutter_shaders` package + `.frag` files**: shaders GLSL custom (Skia ou Impeller). Dispatch como `FragmentShaderBuilder`. Para post-processing, gradient noise, ondas, lens distortion.
- **`Impeller`** (Flutter render engine): muito mais rápido que Skia em iOS, gradativo em Android. Default em Flutter 3.13+. Para animation pesada, escolha runtime que rode bem em Impeller.
- **`flutter_svg`**: SVG complexos com gradient, paths, filters. Animar via `AnimatedBuilder` reconstruindo SVG.

### Make data feel alive
- **Virtual scrolling built-in**: `ListView.builder`, `GridView.builder`, `Sliver*` builders. Constroem só o visível. Para listas de 50k+ items, use `itemExtent:` para max performance.
- **GPU-accelerated charts**: `fl_chart` package usa `CustomPainter` (rápido); `flutter_charts`, `syncfusion_flutter_charts` para datasets grandes.
- **Animated data transitions**: `TweenAnimationBuilder<Map<String, double>>` para morph entre states de gráfico, ou `AnimatedBuilder` envolvendo o painter.

### Animate complex properties
- **`Tween<T>`** customizada: implemente `Tween<MyClass>` para interpolar gradients, paletas inteiras, geometrias. Supera o que CSS/styled-components fazem.
- **`AnimationController` + `AnimatedBuilder`**: a fundação de toda choreography complexa. Combinable, cancellable, reversível.

### Push performance boundaries
- **Isolates** (`compute()` ou `Isolate.spawn()`): processamento pesado fora da UI thread. Image processing, search indexing, JSON parsing grande.
- **`flutter_isolate` package**: mais conveniente para use cases comuns.
- **Native code via Method Channels** (`MethodChannel`): chamar Swift/Kotlin/C++ para SDKs ou processamento extremo.
- **FFI (`dart:ffi`)**: linkar C/C++/Rust direto, near-native performance para image processing, codecs, ML inference.

### Interact com o device
- **`HapticFeedback`** (built-in `dart:services`): vibração tátil. `lightImpact()`, `mediumImpact()`, `heavyImpact()`, `selectionClick()`. Use em delight moments e confirmações.
- **`audioplayers` / `just_audio`**: spatial audio, audio-reactive visualizations, sonic feedback.
- **`sensors_plus` package**: orientation, accelerometer, gyroscope. Use parsimônia e com permissão.
- **`camera` / `geolocator`**: APIs do device com permissão clara.

**NOTE**: This command is about enhancing how an interface FEELS, not changing what a product DOES. Adding real-time collaboration, offline support, or new backend capabilities are product decisions, not UI enhancements. Focus on making existing features feel extraordinary.

## Implement with Discipline

### Progressive enhancement (Flutter)

Cada técnica deve degradar graciosamente. A experiência sem o enhancement deve continuar boa.

```dart
// Detect platform/capability
final canShader = !kIsWeb || /* shader support em web é limitado */ true;

if (canShader) {
  return FragmentShaderBuilder(/* effect */);
}
return _StaticFallback();   // que ainda tem que ser bonito
```

`MediaQuery.disableAnimationsOf(context)` desliga toda animation pesada. Sempre honra:

```dart
final reduceMotion = MediaQuery.disableAnimationsOf(context);
if (reduceMotion) return _StaticHero();
return _AnimatedHero();
```

### Performance rules

- Target 60fps em devices mid-range (Moto G4 era, Pixel 4a). Se cai abaixo de 50, simplifique.
- Respect `MediaQuery.disableAnimationsOf`, sempre. Forneça alternativa estática bonita.
- Lazy-init recursos pesados (`flutter_shaders` `.frag`, Lottie compositions, audio buffers) só quando perto do viewport.
- Pause off-screen rendering. `VisibilityDetector` + dispose de `AnimationController` quando some da tela.
- Teste em devices mid-range físicos, não só máquina de dev.
- `flutter run --profile` + DevTools Performance é a única medida confiável. Debug é mais lento; release não tem instrumentation.
- `RepaintBoundary` envolvendo qualquer área animada cara para evitar repaint do parent.

### Polish is the difference

The gap between "cool" and "extraordinary" is in the last 20% of refinement: the easing curve on a spring animation, the timing offset in a staggered reveal, the subtle secondary motion that makes a transition feel physical. Don't ship the first version that works; ship the version that feels inevitable.

**NEVER (Flutter)**:
- Ignorar `MediaQuery.disableAnimationsOf`. É requisito de acessibilidade, não sugestão.
- Shippar efeitos que causam jank em devices mid-range (`flutter run --profile` mostra).
- Usar APIs bleeding-edge sem fallback (Impeller bugs raros em alguns shaders Android, sempre teste em ambos).
- Adicionar som sem opt-in explícito do usuário.
- Usar ambição técnica para mascarar fundamentos fracos de design; resolva esses com outros comandos primeiro.
- Layer múltiplos extraordinary moments competindo. Foco cria impacto, excesso cria ruído.
- Esquecer `dispose()` em `AnimationController`, `VideoPlayerController`, `AudioPlayer`. Vazamento garantido.
- `BackdropFilter` em fullscreen num device baixo custo.

## Verify the Result

- **The wow test**: Show it to someone who hasn't seen it. Do they react?
- **The removal test**: Take it away. Does the experience feel diminished, or does nobody notice?
- **The device test**: Run it on a phone, a tablet, a Chromebook. Still smooth?
- **The accessibility test**: Enable reduced motion. Still beautiful?
- **The context test**: Does this make sense for THIS brand and audience?

"Technically extraordinary" isn't about using the newest API. It's about making an interface do something users didn't think a website could do.
