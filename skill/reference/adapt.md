# Adapt (Flutter)

> **Additional context needed**: target platforms/devices and usage contexts.

Adaptar um design existente para outro contexto: outra classe de window, outro device, outra plataforma, outro use case. A trap é tratar adaptação como escala. O job é repensar a experiência para o novo contexto.

Em Flutter, "adaptive" é o termo nativo (e o título do guia oficial). Cobre: telas (compact/medium/expanded/large/extra-large), foldables, orientação, input method, plataforma (Material vs Cupertino).

Leia [flutter-foundations.md](flutter-foundations.md) e [responsive-design.md](responsive-design.md) primeiro.

## Avaliar o desafio

1. **Source context**:
   - Para que foi desenhado originalmente? Phone portrait? Tablet? Desktop?
   - Quais assumptions? Touch único? Mouse? Conexão rápida?
   - O que funciona bem hoje?

2. **Target context**:
   - **Window class**: Compact (<600), Medium, Expanded, Large, Extra-large.
   - **Input**: Touch, mouse + keyboard, gamepad, voz, Switch Control.
   - **Orientation**: Portrait apenas, ou ambos.
   - **Plataforma**: iOS, Android, Web Flutter, Desktop Flutter (macOS/Windows/Linux), foldable.
   - **Conexão**: Wi-Fi rápido, 4G, 3G, offline-first.
   - **Contexto de uso**: caminhando vs sentado, glance rápido vs leitura focada.
   - **Expectativa**: o que usuário espera nesta plataforma?

3. **Adaptation challenges**:
   - O que não cabe? (Conteúdo, navegação, features.)
   - O que não funciona? (Hover em touch, touch targets pequenos, swipe-back colidindo com gesture custom.)
   - O que é inapropriado? (Padrões desktop em mobile, padrões mobile em desktop, Material em iPhone que ignora gesto iOS.)

**CRÍTICO**: adaptação é repensar a experiência. Não estica pixel.

## Estratégias por target

### Compact → Medium / Expanded (Phone → Tablet)

**Layout**:
- `BottomNavigationBar` / `NavigationBar` (M3) → `NavigationRail` (compact ou expandida).
- Single column → 2 colunas (master-detail é o padrão tablet ouro).
- `Card` full-width → grid `GridView.builder(SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 280))`.
- `Drawer` modal → `Drawer` permanente em `Row`.

**Pattern**:
```dart
final width = MediaQuery.sizeOf(context).width;
return Scaffold(
  body: Row(children: [
    if (width >= 600) NavigationRail(extended: width >= 840, /* ... */),
    Expanded(child: width >= 600
        ? Row(children: [
            SizedBox(width: 320, child: _MasterList()),
            const VerticalDivider(width: 1),
            Expanded(child: _DetailPane()),
          ])
        : _SingleColumnList()),
  ]),
  bottomNavigationBar: width < 600 ? const NavigationBar(/* ... */) : null,
);
```

### Compact → Expanded / Large (Phone → Desktop Flutter)

**Layout**:
- `NavigationDrawer` permanente em `Row`.
- Multi-column dense.
- `Padding` horizontal generoso (max-width no conteúdo, tipo 1024).
- `MouseRegion` para hover affordance (cursor pointer, tint sutil).

**Interaction**:
- Atalhos de teclado via `Shortcuts` + `Actions`.
- Right-click via `GestureDetector(onSecondaryTapDown:)`.
- Drag-and-drop via `Draggable` + `DragTarget`.
- Multi-select com Shift/Cmd.

**Content**:
- Mais info upfront (menos disclosure progressiva).
- `DataTable2` para tabelas densas.
- Visualizações ricas (charts, mais columns).

### Material → Cupertino (Android → iOS plataforma-correctness)

```dart
final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

isIOS
  ? CupertinoButton.filled(child: Text('Salvar'), onPressed: ...)
  : FilledButton(child: Text('Salvar'), onPressed: ...)
```

Pacote `flutter_platform_widgets` ajuda quando você quer um único API com fallback. Use quando o código de tela ficaria muito ramificado, e quando paridade visual entre platforms importa menos que velocidade de desenvolvimento.

**Sempre alterne**:
- `AlertDialog` ↔ `CupertinoAlertDialog`.
- `Switch` ↔ `CupertinoSwitch`.
- `DatePicker` ↔ `CupertinoDatePicker`.
- `BottomNavigationBar` ↔ `CupertinoTabBar` + `CupertinoTabScaffold`.
- `Slider` ↔ `CupertinoSlider`.
- Page transition: `MaterialPageRoute` ↔ `CupertinoPageRoute` (este último entrega swipe-back automaticamente).

### Foldables (Surface Duo, Z Fold, Pixel Fold)

```dart
final features = MediaQuery.of(context).displayFeatures;
final hinge = features.firstWhereOrNull((f) =>
    f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold);

if (hinge != null) {
  // Layout em duas regiões evitando o hinge
  return TwoPaneLayout(hingeBounds: hinge.bounds, /* ... */);
}
```

Pacote `dual_screen` (oficial da Microsoft para Surface Duo) facilita.

### Print / Export PDF

Não é o caso típico mobile, mas Flutter app pode gerar PDF via package `pdf` (não confundir com renderizar PDF, que é `pdfx`). Estrutura separada de UI:

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final doc = pw.Document();
doc.addPage(pw.Page(build: (context) => pw.Center(/* ... */)));
final bytes = await doc.save();
```

Princípios: page breaks lógicos, sem nav/footer, P&B ou cor limitada, margens para encadernação, page numbers.

## Implementar

### Window classes (Material 3 oficial)

Use os 5 windows: compact / medium / expanded / large / extra-large. Detalhes em [responsive-design.md](responsive-design.md).

```dart
WindowSizeClass _classFor(double w) {
  if (w < 600) return WindowSizeClass.compact;
  if (w < 840) return WindowSizeClass.medium;
  if (w < 1200) return WindowSizeClass.expanded;
  if (w < 1600) return WindowSizeClass.large;
  return WindowSizeClass.extraLarge;
}
```

### LayoutBuilder vs MediaQuery

- **`LayoutBuilder`**: componente reage ao container que recebe (equivalente container queries CSS). Use sempre que possível.
- **`MediaQuery.sizeOf(context)`**: componente reage à viewport real. Use para decisões de página/scaffold.

### SafeArea

```dart
SafeArea(
  top: true, bottom: true, left: true, right: true,    // default todos true
  minimum: const EdgeInsets.all(0),
  child: ...,
)
```

`Scaffold` aplica em `body` por padrão. Modais full-screen, splash, telas de câmera precisam declarar.

### Touch adaptation

- Tap targets ≥48dp (já no theme via `MaterialTapTargetSize.padded`).
- Espaçamento entre interativos.
- Sem dependência de hover.
- `InkWell` ripple (Material) ou `CupertinoButton` highlight (iOS).
- Considere thumb zones: bottom é mais alcançável que top em phones grandes.

### Image responsivo

Não há `srcset` em Flutter. Use:
- `Image.asset` com `assets/2.0x/`, `3.0x/` (resolution-aware automático).
- `Image.network(url, cacheWidth: (300 * dpr).toInt())` para reduzir memória.
- `cached_network_image` para cache em disco.
- CDN com transformação (Cloudinary, imgix): construa URL com `width: (sizeOf(context).width * dpr).toInt()`.

### Navigation transformation

3 estágios canônicos:

| Window class | Pattern |
|---|---|
| Compact | `BottomNavigationBar` ou `NavigationBar` (M3) |
| Medium / Expanded | `NavigationRail` (compacta na medium, expandida em expanded) |
| Large / Extra-large | `NavigationDrawer` permanente em `Row` |

Não inventar custom. Apple e Google têm padrões tested.

**IMPORTANTE**: teste em devices reais. Emulador é útil para layout, falha em performance, gestos, fontes do sistema.

**NUNCA**:
- Esconder funcionalidade core no mobile (se importa, faz funcionar).
- Assumir desktop = poderoso (considerar a11y, máquinas antigas).
- IA diferente entre contexts (confuso).
- Quebrar expectativa da plataforma (iOS espera padrões iOS, Android espera padrões Android).
- Esquecer landscape em phone/tablet.
- Usar breakpoints arbitrários em vez dos M3 windows.
- Ignorar foldables se PRODUCT.md menciona Android premium audience.

## Verificar

- **Real devices**: phones reais, tablets reais. iOS + Android, mínimo um phone de baixo custo.
- **Orientations**: portrait + landscape em pelo menos 1 device.
- **Plataformas**: se Flutter web/desktop está no escopo, teste lá também.
- **Input**: touch, mouse (em web/desktop), keyboard.
- **Edge cases**: phones pequenos (320 lógicos width), tablets grandes, ultrawide se desktop.
- **Conexões lentas**: Network Link Conditioner (iOS) ou throttle do Android dev tools.

Quando a adaptação parece nativa de cada contexto, hand off para `{{command_prefix}}impeccable-flutter polish`.
