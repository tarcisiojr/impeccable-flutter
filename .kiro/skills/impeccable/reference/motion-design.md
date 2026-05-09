# Motion Design (Flutter)

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Duração: a regra 100/250/500

Timing pesa mais que easing. Estes valores funcionam para a maioria de UI mobile:

| Duração | Uso | Exemplo Flutter |
|---|---|---|
| **100-150ms** | Feedback instantâneo | press de botão (`InkWell` ripple), troca de cor, toggle |
| **200-300ms** | Mudança de estado | menu open, tooltip, hover (desktop), `AnimatedContainer` em selected |
| **300-500ms** | Mudança de layout | accordion (`AnimatedSize`), modal entrance (`showDialog`), drawer |
| **500-800ms** | Entrance | splash → home, hero reveal, primeira screen do app |

**Animations de saída são mais rápidas que entrada.** Use ~75% da duração de entrada. Em Flutter isso significa `reverseDuration` mais curto:

```dart
AnimationController(
  duration: const Duration(milliseconds: 400),
  reverseDuration: const Duration(milliseconds: 280),
  vsync: this,
)
```

Material 3 expressa isso em tokens. `MaterialApp.theme.pageTransitionsTheme` controla rotas. O catálogo M3 oficial:

- `MotionScheme.expressive()` (M3 expressive) ou `MotionScheme.standard()`: define spring physics + durations.
- Tokens M3 oficiais: short1=50, short2=100, short3=150, short4=200, medium1=250, medium2=300, medium3=350, medium4=400, long1=450, long2=500, long3=550, long4=600, extraLong1=700, ..., extraLong4=1000.

Em Flutter 3.27+, `Theme.of(context).motionScheme` expõe os defaults M3. Para custom, `ThemeExtension<MotionTokens>`.

## Easing: escolha a curva certa

**Não use `Curves.ease`.** É um compromisso raramente ótimo. Prefira:

| Curva | Uso | Flutter |
|---|---|---|
| **ease-out** | Entrada de elemento | `Curves.easeOutCubic`, `Curves.easeOutQuart`, `Curves.easeOutExpo` |
| **ease-in** | Saída de elemento | `Curves.easeInCubic`, `Curves.easeInQuart` |
| **ease-in-out** | Toggle (vai e volta) | `Curves.easeInOutCubic` |

**Para micro-interactions, use curvas exponenciais.** Sentem natural porque imitam física (atrito, desaceleração). Em Flutter:

```dart
// Quart out: refinado, recomendado default
const Cubic easeOutQuart = Cubic(0.25, 1.0, 0.5, 1.0);

// Quint out: pouco mais dramático
const Cubic easeOutQuint = Cubic(0.22, 1.0, 0.36, 1.0);

// Expo out: snappy, confiante
const Cubic easeOutExpo = Cubic(0.16, 1.0, 0.3, 1.0);

// Material 3 emphasized (já no framework)
Curves.easeOutCubic           // standard easing
// Material 3 emphasized vem do MotionScheme
```

**Banir `Curves.bounceIn`, `Curves.bounceOut`, `Curves.elasticIn`, `Curves.elasticOut`.** Foram trend em 2015 e hoje leem amador. Objetos reais não pulam quando param; desaceleram suavemente. Overshoot puxa atenção para a animação em vez do conteúdo.

Em Flutter, estes existem no framework e o autocomplete vai te oferecer. Não pegue. Em apps de jogo ou com mascote ilustrado, talvez. Em product/brand séria, nunca.

## Materiais de motion premium

`Transform`, `Opacity` e `AnimatedContainer` são defaults confiáveis, não a paleta inteira. Interfaces premium frequentemente precisam de propriedades atmosféricas em mobile:

- **Transform / Opacity**: movimento, press feedback, reveals simples, choreography de lista.
- **`BackdropFilter` (blur, saturation, brightness)**: depth, glass effect, focus pull. Usar parsimônia, é caro.
- **`ClipPath` / `ClipRRect` animados**: wipes, reveals, transições editoriais.
- **`Material(shadowColor:, surfaceTintColor:)`** para depth dinâmica em M3.
- **Variable fonts via `FontVariation`**: animar `wght` para um peso pulsando em estado selected é polida e barata.
- **Shaders via `flutter_shaders` + `.frag`**: GLSL para efeitos exóticos (gradient noise, parallax). Caro mas reservado para hero/brand. Veja [overdrive.md](overdrive.md).

A regra dura não é "só transform e opacity". A regra dura é: **evite animar propriedades que disparam relayout casualmente** (width, height, padding, constraints), mantenha efeitos caros confinados em áreas pequenas/isoladas (`RepaintBoundary`!), e verifique no device alvo (`flutter run --profile`) que está smooth a 60fps (90/120 em devices recentes).

Se `BackdropFilter` faz a interação parecer significativamente mais premium e mantém-se smooth, use.

## Animações implícitas vs explícitas

Em Flutter você quase sempre quer **implícitas** primeiro:

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeOutCubic,
  color: selected ? scheme.primary : scheme.surface,
  padding: EdgeInsets.all(selected ? 16 : 12),
)
```

Quando precisa de:
- coordenar múltiplos widgets ao mesmo tempo,
- triggerar animação com gesto, não com state change,
- repetir, sequenciar, controlar com física custom,

troque para **explícito** com `AnimationController` + `Tween` + `AnimatedBuilder`.

Catálogo de implícitos do framework (use antes de ir explícito):

`AnimatedContainer`, `AnimatedOpacity`, `AnimatedAlign`, `AnimatedPadding`, `AnimatedPositioned`, `AnimatedSize`, `AnimatedDefaultTextStyle`, `AnimatedSwitcher`, `AnimatedCrossFade`, `AnimatedRotation`, `AnimatedScale`, `AnimatedSlide`, `AnimatedTheme`, `AnimatedPhysicalModel`.

Para casos específicos:
- **Trocar conteúdo com fade**: `AnimatedSwitcher`.
- **Continuidade entre rotas**: `Hero`.
- **Lista que aparece um por um (stagger)**: `AnimationController` + `Interval` por item, ou `flutter_staggered_animations` package.

## Stagger (escalonado)

Em CSS você usa `animation-delay: calc(--i * 50ms)`. Em Flutter:

```dart
final controller = AnimationController(vsync: this, duration: 600.ms);
final items = List.generate(8, (i) {
  final start = (i / 8) * 0.5;        // primeira metade da timeline
  final end = start + 0.5;
  return CurvedAnimation(
    parent: controller,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );
});
```

**Cap o tempo total de stagger**: 10 itens × 50ms = 500ms total já é o limite confortável. Para muitos itens, reduza delay-por-item ou cap em quantos itens stagger (resto aparece junto).

## Reduce motion

Não opcional. Distúrbios vestibulares afetam ~35% dos adultos acima de 40. Em Flutter:

```dart
final reduceMotion = MediaQuery.disableAnimationsOf(context);

AnimatedContainer(
  duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
  curve: Curves.easeOutCubic,
  // ...
)
```

`MediaQuery.disableAnimationsOf(context)` reflete:

- iOS: Settings → Accessibility → Motion → Reduce Motion.
- Android: Settings → Accessibility → Remove Animations.

Quando habilitado, o framework já desabilita certos transitions (page route padrão), mas suas animations explícitas ficam: você precisa honrar manualmente. **O que preservar**: animações funcionais (progress bar, loading spinner em velocidade reduzida, focus indicator). Trocar movimento espacial por crossfade (200ms `AnimatedSwitcher` simples).

Padrão sugerido: helper no app

```dart
extension MotionAware on BuildContext {
  Duration motionDuration(Duration normal) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : normal;
  Curve motionCurve(Curve normal) =>
      MediaQuery.disableAnimationsOf(this) ? Curves.linear : normal;
}
```

Use em todo widget que anima: `duration: context.motionDuration(300.ms)`.

## Performance percebida

**Ninguém liga para quão rápido seu app é, só para quão rápido ele *parece*.** Percepção pode ser tão eficaz quanto performance real.

**Threshold de 80ms**: o cérebro buffera input sensorial por ~80ms para sincronizar. Abaixo disso parece instantâneo. Esse é seu alvo para micro-interactions (press feedback, toggle response).

**Tempo ativo vs passivo**: passivo (olhando para spinner) parece mais longo que ativo (vendo conteúdo aparecer). Estratégias:

- **Início preemptivo**: comece a transição enquanto carrega. iOS app zoom + skeleton UI. Em Flutter: `Hero` + `FutureBuilder` que exibe estrutura imediato e dados quando vêm.
- **Conclusão precoce**: mostre conteúdo progressivamente. Image placeholders via `cached_network_image` + `placeholder:`. Stream de dados via `StreamBuilder` com primeiro frame imediato.
- **UI otimista**: atualize a interface imediato, lide com falha graciosamente. Like no Instagram funciona offline; UI atualiza, sync depois. Usar para low-stakes (likes, follows, marcar como lido). Evitar em pagamentos, deletes destrutivos, transferências.

**Easing afeta duração percebida**: ease-in (acelerando até completar) faz tarefa parecer mais curta porque o efeito peak-end pesa os momentos finais. Ease-out é satisfatório para entradas; ease-in para fechamentos comprime tempo percebido.

**Cuidado**: respostas rápidas demais podem reduzir valor percebido. Usuários desconfiam de busca instantânea ou de "AI generation" que retorna em <500ms. Às vezes um delay artificial sinaliza "trabalho real". Em Flutter, `Future.delayed(300.ms)` antes de exibir resultado de uma análise complexa tem seu lugar.

## Performance: o real

`will-change` web não tem equivalente direto, mas Flutter te dá ferramentas mais fortes:

- **`RepaintBoundary`**: isola subtree que repinta, evita repaint do parent. Use envolto em qualquer widget que anima frequentemente (lista que scrolla, card animado), especialmente se cercado de conteúdo estático.
- **`const` em todo widget que pode**: o framework reconhece `const` e pula reconstruction.
- **`AnimatedBuilder` com `child:`**: o `child` não rebuilda em cada tick, só o `builder:` roda. Ganho enorme em animations longas.
- **`flutter run --profile`** em device físico: o único benchmark confiável. Debug é mais lento que produção; nada de medir em emulador.
- **DevTools → Performance → "Track Widget builds"**: mostra qual widget rebuilda quando.

Para scroll-triggered: use `NotificationListener<ScrollNotification>` ou `ScrollController.position.atEdge`. Não dispare animação a cada `onPointerMove`: vai dropar frames.

Tokens de motion: registre durations e curves num `ThemeExtension<MotionTokens>` e nunca hard-code `Duration(milliseconds: 300)` em código de tela. Centralizar permite mudar o feel do app inteiro mexendo um lugar só.

---

**Evitar**: animar tudo (motion fatigue é real). Usar >500ms para feedback de UI. Ignorar `MediaQuery.disableAnimationsOf`. Usar animação para esconder loading lento. `Curves.bounce*` ou `Curves.elastic*` em product. `Container(...)` mudando width/height direto sem `AnimatedContainer` (causa rebuild + relayout, jank). Hard-code de Duration/Curve fora dos tokens de tema.
