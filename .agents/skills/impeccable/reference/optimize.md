# Optimize (Flutter)

Performance é uma feature. Identifique o gargalo real DESTE app, corrija, então meça. Não otimize o que não está lento.

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Avaliar issues de performance

1. **Meça o estado atual**:
   - **Frame budget**: 60fps = 16ms; 120fps = 8ms. DevTools Performance → Frames.
   - **Build time**: tempo médio do `build()`. Targets: <8ms.
   - **Raster time**: tempo de raster (GPU). Targets: <8ms.
   - **Rebuild count**: quantas vezes cada widget reconstrói. DevTools → Inspector → "Track Widget builds".
   - **App size**: `flutter build apk --analyze-size` ou `flutter build ios --analyze-size`.
   - **Startup time**: `flutter run --trace-startup`.
   - **Memória**: DevTools Memory tab.

2. **Identifique gargalo**:
   - O que está lento? Initial load? Interações? Animações? Rolagem de lista?
   - O que causa? Imagens grandes? `setState` em cascata? `BackdropFilter` em fullscreen? Listagem sem `builder`?
   - Quão ruim? Perceptível? Annoying? Bloqueante?
   - Quem afeta? Todos? Só low-end Android? Só conexão lenta?

**CRÍTICO**: meça antes e depois. Otimização prematura desperdiça tempo. Ataque o gargalo principal primeiro.

## Estratégia

### Imagens

- **Resolution-aware assets**: `assets/2.0x/`, `3.0x/`. Flutter pega automaticamente.
- **`cacheWidth`/`cacheHeight`**: reduz memória dramaticamente em listas. `Image.network(url, cacheWidth: (300 * dpr).toInt())`.
- **`cached_network_image`**: cache em disco, placeholder, error widget, retry. Use sempre em produção.
- **Lazy load**: `ListView.builder` só constrói o que está visível. Para grids: `GridView.builder`.
- **`FadeInImage`**: troca placeholder por imagem real com fade, sem layout shift.
- **Formatos**: JPG/PNG aceitam tudo, mas WebP é menor; use no servidor se possível. Para asset local, original importa.
- **CDN com transformação**: Cloudinary, imgix, Cloudflare Images. Peça ao servidor o size exato necessário.

```dart
CachedNetworkImage(
  imageUrl: '$cdn/profile/$id?w=${(96 * dpr).toInt()}',
  placeholder: (_, __) => Container(color: scheme.surfaceContainer),
  errorWidget: (_, __, ___) => Icon(Icons.person, color: scheme.onSurfaceVariant),
  memCacheWidth: (96 * dpr).toInt(),
  fit: BoxFit.cover,
)
```

### Reduzir bundle / app size

- **Tree-shake**: Flutter já faz por padrão em release. `flutter build` agressivo é o produto final, não `flutter run`.
- **Deferred components** (Android, AOT): `import 'foo.dart' deferred as foo;` baixa em runtime. Útil para features raras.
- **Imagens em assets**: bundlar só o que precisa. Audite assets/ regularmente.
- **Fonts**: bundlar só os pesos usados. Variable font costuma ser menor que 3 estáticos.
- **Remover packages não usados**: `dart pub deps`. Cada package adiciona kilobytes.
- **`R8` / `ProGuard`** no Android: já habilitado em release.

### Rendering & rebuilds

#### `const` em todo lugar possível

```dart
// RUIM: rebuilda a cada parent build
Container(
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
  child: Text('Olá'),
)

// BOM: const completo
const Padding(
  padding: EdgeInsets.all(16),
  child: Text('Olá'),
)
```

`const` widgets não passam pelo build. Em telas com listas grandes, ganho mensurável.

#### `RepaintBoundary`

Isola repaint. Use envolvendo widgets que animam frequente, especialmente cercados de conteúdo estático.

```dart
RepaintBoundary(
  child: AnimatedRotation(
    turns: _angle,
    duration: 300.ms,
    child: const Icon(Icons.refresh),
  ),
)
```

#### `AnimatedBuilder` com `child:`

```dart
AnimatedBuilder(
  animation: _controller,
  child: const ExpensiveStaticWidget(),    // não rebuilda
  builder: (context, child) => Transform.scale(
    scale: 1 + _controller.value * 0.1,
    child: child,
  ),
)
```

`child:` parameter não rebuilda em cada tick.

#### Evitar layout-driving animations

```dart
// RUIM: anima width = relayout em cada frame
AnimatedContainer(width: expanded ? 300 : 100, /* ... */)

// BOM: anima escala = só repaint
Transform.scale(scale: expanded ? 1.0 : 0.5, /* ... */)
```

#### Quebrar `build()` grandes

`build()` >50 linhas geralmente esconde árvore profunda que rebuilda demais. Quebra em `StatelessWidget` filhos. Cada um pode ser `const` e isolar rebuild.

#### `ValueListenableBuilder` / `ListenableBuilder` em vez de `setState`

Para state que muda frequente (gestures, scroll, animações):

```dart
// RUIM: setState rebuilda toda a árvore
class _MyState extends State<...> {
  double _scroll = 0;
  @override
  Widget build(context) {
    return Listener(
      onPointerMove: (e) => setState(() => _scroll += e.delta.dy),
      child: Column(/* árvore inteira */),
    );
  }
}

// BOM: ValueNotifier rebuilda só o consumer
final _scroll = ValueNotifier<double>(0);
// ...
ValueListenableBuilder(
  valueListenable: _scroll,
  builder: (context, value, _) => Transform.translate(offset: Offset(0, -value)),
)
```

### `flutter_shaders` / efeitos pesados

- `BackdropFilter` em área pequena (botão, card específico): OK.
- `BackdropFilter` em fullscreen: mata performance em Android baixo custo. Rare.
- `Shader.fromAsset` para custom GLSL: bonito mas caro. Confine em hero, brand surface, ou uso pontual.
- Drop shadow custom via `BoxShadow` em quantidade: usa GPU. Em dark mode, M3 já reduz; siga.

### Listas longas

- **`ListView.builder` / `GridView.builder`**: lazy. `ListView(children: [...])` cru constrói tudo, fatal em listas longas.
- **`SliverList` + `SliverChildBuilderDelegate`**: para scroll customizado com `CustomScrollView`.
- **`AutomaticKeepAliveClientMixin`** em items que custam construir e são revisitados.
- **`itemExtent:`** ou `prototypeItem:` em `ListView.builder` quando todos têm mesmo tamanho: ganha velocidade.
- **`addAutomaticKeepAlives: false`** quando `keepAlive` não vale a pena (cada item leve).
- **`addRepaintBoundaries: false`** quando padrão isola demais (raro de precisar).

### Texto

- **`TextHeightBehavior(applyHeightToFirstAscent: false)`** corrige leading desnecessária em headers.
- **`TextScaler` honrado**: nunca `noScaling`, mas faz layout funcionar com `Flexible`/`Wrap`.
- Strings muito longas (>1000 chars) num único `Text`: considere quebrar ou usar `SelectableText.rich` que é mais otimizado para spans.

### Networking

- **Pagination**: nunca carregar lista inteira. `infinite_scroll_pagination` package ou implementação manual com offset/cursor.
- **Compression**: gzip/brotli no servidor.
- **Keep-alive**: HTTP/2 ou HTTP/3 reusam conexão.
- **Optimistic UI**: atualiza imediato, sync depois. Patterns em [interaction-design.md](interaction-design.md).
- **Queue offline**: `connectivity_plus` package + `Hive`/`Drift` queue para retry quando volta.

## Métricas-alvo

### Startup

- Cold start: <2s (target Apple), <3s (target Android baixo custo).
- Time-to-first-frame: <500ms.
- `flutter run --trace-startup` mede.

### Frames

- 60fps em devices alvo: 16ms budget por frame. Build + raster <16ms cada.
- 120fps em devices premium: 8ms.
- DevTools Performance → Frame chart mostra cada frame em verde (smooth) ou vermelho (jank).

### App size

- iOS: <50MB ideal, <100MB OK.
- Android (APK split por ABI): <40MB.
- Targets para mercado emergente: <30MB se possível.

### Memory

- Tipicamente <150MB em uso normal. Acima de 300MB começa a swap em devices baixos, vira lag.
- DevTools Memory → snapshot e diff revelam vazamentos.

## Tools

- **DevTools Performance**: a fonte de verdade.
- **`flutter run --profile -d <device>`**: única configuração que reflete produção. Debug é mais lento; release não tem instrumentation.
- **`flutter build apk --analyze-size`** / **`--analyze-size`**.
- **`flutter run --trace-startup`**.
- **Observatory** (legacy, agora dentro de DevTools): isolates, timeline.
- **Xcode Instruments** (iOS): para deep dive nativo.
- **Android Studio Profiler**: para deep dive Android.

**IMPORTANTE**: meça em device físico de baixo custo, não em simulador/emulador, e não em iPhone Pro Max.

**NUNCA**:
- Otimizar sem medir (otimização prematura).
- Sacrificar a11y por performance (`MediaQuery.textScaler: noScaling` para "evitar quebra" é troca pobre).
- Quebrar funcionalidade otimizando.
- Lazy load above-the-fold.
- Otimizar microsegundo enquanto ignora gargalo principal.
- Esquecer mobile baixo custo (frequentemente devices mais lentos, conexões piores).
- Confiar em métricas de simulador.

## Verificar

- **Métricas before/after**: capture screenshots de DevTools Performance antes e depois.
- **Real-user monitoring**: Firebase Performance, Sentry, ou tooling próprio.
- **Devices diferentes**: low-end Android, mid-tier Android, iPhone padrão. Não só flagship.
- **Conexões lentas**: Network Link Conditioner.
- **Sem regressões**: `flutter test` continua passando.
- **Percepção**: parece mais rápido?

Quando os números sobem (e a percepção também), hand off para `$impeccable polish`.
