# Responsive & Adaptive Design (Flutter)

Flutter usa o termo **adaptive** para o que web chama de responsive: o app reorganiza estrutura, não só estica. Esse arquivo cobre os dois sentidos. Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Mobile-first faz sentido em Flutter?

Em web, mobile-first é estratégia de CSS (escreva base para mobile, layer para desktop com `min-width`). Em Flutter, **a postura padrão é mobile-first por construção**: você escreve para um celular e cresce. A pergunta real é: seu app vive em mais de uma classe de device?

- **Só mobile**: maioria dos apps. Uma única `LayoutBuilder` ou `MediaQuery.sizeOf` na home. Pronto.
- **Mobile + tablet**: NavigationBar vira NavigationRail; cards de uma coluna viram dois.
- **Mobile + tablet + desktop (Flutter web/macOS)**: NavigationDrawer permanente; `Hover` aparece; mouse cursor + atalhos de teclado importam.
- **Foldables**: `MediaQuery.displayFeatures` informa hinge e cutouts; o app pode partir UI em duas regiões.

## Breakpoints: usar os do Material 3

Não invente. Material 3 define três classes de window:

| Window class | Width | Decisão de layout |
|---|---|---|
| **Compact** | <600 | Phone portrait. NavigationBar. Single column. |
| **Medium** | 600 ≤ w < 840 | Tablet portrait, foldable parcialmente aberto. NavigationRail. 2 colunas. |
| **Expanded** | 840 ≤ w < 1200 | Tablet landscape, laptop pequeno. NavigationRail expandida. 3 colunas. |
| **Large** | 1200 ≤ w < 1600 | Desktop, large tablet. NavigationDrawer permanente. 4 colunas. |
| **Extra-large** | ≥1600 | Monitor grande, ultra-wide. Multi-pane com max-width no conteúdo. |

```dart
WindowSizeClass _classFor(double width) {
  if (width < 600) return WindowSizeClass.compact;
  if (width < 840) return WindowSizeClass.medium;
  if (width < 1200) return WindowSizeClass.expanded;
  if (width < 1600) return WindowSizeClass.large;
  return WindowSizeClass.extraLarge;
}

@override
Widget build(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return switch (_classFor(width)) {
    WindowSizeClass.compact => _MobileLayout(),
    WindowSizeClass.medium => _MediumLayout(),
    WindowSizeClass.expanded || WindowSizeClass.large => _ExpandedLayout(),
    WindowSizeClass.extraLarge => _ExtraLargeLayout(),
  };
}
```

Para componentes que devem reagir ao seu container (não à viewport), use `LayoutBuilder` em vez de `MediaQuery`. Isso é o equivalente a container queries em CSS, e resolve o caso "card no sidebar fica compacto, mesmo card no main expande".

## Detectar input method, não só tamanho

Tamanho de tela não te diz como o usuário interage. Um laptop com touchscreen, um tablet com keyboard. Em Flutter:

```dart
final platform = Theme.of(context).platform;       // iOS, android, macOS, windows, linux, fuchsia
final isMobile = platform == TargetPlatform.iOS || platform == TargetPlatform.android;
final isDesktop = !isMobile;

// Pointer real:
// MouseRegion + GestureDetector(behavior:) cobrem hover/touch separados.
// Para "tem mouse?", conferir se hover events disparam.

// Detectar physical keyboard:
final hardwareKeyboard = HardwareKeyboard.instance;
final hasPhysicalKeyboard = hardwareKeyboard.physicalKeysPressed.isNotEmpty;
```

`Theme.of(context).platform` é controlado pelo framework e respeita o device real. Em web, vira `TargetPlatform.android`/`iOS`/`macOS`/`windows`/`linux` baseado no User-Agent.

**Crítico**: não dependa de `hover` para funcionalidade. Touch users não têm hover. `MouseRegion` é OK para feedback visual (cursor pointer, leve tint), mas a ação tem que ser disponível por tap.

## SafeArea: lidando com notch e gesture bar

Phones modernos têm notch, cantos arredondados, indicador de home, dynamic island. Em Flutter:

```dart
SafeArea(
  child: Scaffold(  // ou seu conteúdo
    body: ...,
  ),
)
```

`Scaffold` aplica `SafeArea` no `body` por padrão (`primary: true`). Conteúdo fora de `Scaffold` (overlays, splash full-screen, telas de câmera) precisa declarar `SafeArea` manualmente.

Para casos onde você quer ir até a borda mas respeitar o gesture bar embaixo:

```dart
SafeArea(
  top: false, left: false, right: false,    // só protege embaixo
  child: BottomBar(),
)
```

Para conteúdo que deve cobrir tudo (vídeo full-screen, mapa), `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)` esconde status bar; e nesse modo, você ainda precisa respeitar `MediaQuery.padding` para não cobrir o gesture indicator.

`MediaQuery.viewInsetsOf(context)` reflete o teclado; `MediaQuery.paddingOf(context)` reflete safe areas estáticas.

### Display features (foldables, dynamic island)

```dart
final features = MediaQuery.of(context).displayFeatures;
// features contém DisplayFeature com bounds e type:
// DisplayFeatureType.fold (Surface Duo, Z Fold)
// DisplayFeatureType.cutout (notch)
// DisplayFeatureType.hinge
```

Para split UI ao redor do hinge, `TwoPane` widget ou layout manual baseado nos bounds das features.

## Imagens responsivas

Flutter resolve imagens diferente da web. Não há `srcset`. Em vez disso:

### `Image.asset` com resolução-aware

```yaml
flutter:
  assets:
    - assets/images/hero.png
    - assets/images/2.0x/hero.png
    - assets/images/3.0x/hero.png
```

Flutter pega automaticamente a resolução certa baseada em `MediaQuery.devicePixelRatio`. iPhone Pro = 3.0x, iPhone padrão = 2.0x, antigo iPad mini = 2.0x.

### `Image.network` com `cacheWidth`/`cacheHeight`

```dart
Image.network(
  'https://...',
  cacheWidth: (300 * MediaQuery.devicePixelRatio).toInt(),
  loadingBuilder: (_, child, progress) => progress == null ? child : ...,
)
```

Faz download e cacheia já no tamanho exato necessário. Reduz uso de memória dramaticamente em listas longas.

Para CDNs com transformação (Cloudinary, imgix, Cloudflare Images), construa URL com width baseado em `MediaQuery.sizeOf(context).width * devicePixelRatio` e peça a imagem certa do servidor.

### `cached_network_image` package

Em produção, sempre use `cached_network_image` em vez de `Image.network`. Ele cache em disco, lida com placeholder, error widget, e re-tentativa.

## Padrões de adaptação de layout

### Navegação em três (ou cinco) estágios

| Width | Padrão |
|---|---|
| Compact (<600) | `BottomNavigationBar` ou `NavigationBar` (M3) |
| Medium (600-840) | `NavigationRail` (compacto, só ícones) |
| Expanded (840-1200) | `NavigationRail` expandida (ícone + label) |
| Large (≥1200) | `NavigationDrawer` permanente |

```dart
Widget build(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return Scaffold(
    body: Row(children: [
      if (width >= 1200) const NavigationDrawer(/* ... */),
      if (width >= 600 && width < 1200) NavigationRail(extended: width >= 840, /* ... */),
      Expanded(child: _content),
    ]),
    bottomNavigationBar: width < 600 ? const NavigationBar(/* ... */) : null,
  );
}
```

### Tabelas: vire cards no mobile

`DataTable` é desktop-first. Em mobile, transforme em `ListView` de `Card`s onde cada card é uma linha. Isso é decisão de produto, não conversão automática.

### Disclosure progressiva

Em web, `<details>/<summary>`. Em Flutter:

```dart
ExpansionTile(
  title: Text('Detalhes'),
  children: [/* só renderiza quando aberto */],
)
```

`ExpansionTile` vem do Material e respeita `ThemeData.expansionTileTheme`.

## Orientação

```dart
OrientationBuilder(
  builder: (context, orientation) => orientation == Orientation.landscape
      ? _LandscapeLayout()
      : _PortraitLayout(),
)
```

Para apps que devem travar orientation (jogos, alguns onboardings), `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`. Use parsimônia: usuário tem expectativa de rotacionar.

## Testando: não confie em emulador

Emulador é útil para layout, mas falha em:

- Toques reais e gestures (especialmente edge swipes que disputam com gesture bar do iOS).
- CPU/memória reais (emulador é mais rápido que device de baixo custo).
- Latência de rede.
- Renderização de fontes (sistema do device é diferente do bundled).
- Comportamento de teclado e suas animações.

**Teste em pelo menos**: um iPhone real, um Android real (preferencialmente baixo custo, tipo Moto G), e um tablet se relevante. Phones Android baratos revelam jank que você nunca vê em iPhone Pro Max.

`flutter run --profile -d <device>` é o único benchmark confiável. Debug é mais lento que produção.

---

**Evitar**: hard-code de breakpoints fora dos M3 windows. Single codebase mobile/desktop sem `LayoutBuilder` (estica em vez de adaptar). Ignorar tablet e landscape. `Image.network` cru em listas longas (memória explode). Confiar em hover para funcionalidade. Esquecer `SafeArea` em modais full-screen.
