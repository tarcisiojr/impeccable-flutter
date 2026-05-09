# Spatial Design (Flutter)

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Sistema de espaçamento

### Use base 4, não 8

Sistema de 8 é grosso demais; você frequentemente vai precisar de 12 (entre 8 e 16). Use 4 como granularidade: 4, 8, 12, 16, 24, 32, 48, 64, 96 lógicos.

Em Flutter, lógicos = pontos lógicos (1 lógico ≈ 1pt iOS ≈ 1dp Android). Você não escreve px. `EdgeInsets.all(16)` significa 16 lógicos em todo lado. O framework converte para pixels físicos via `MediaQuery.devicePixelRatio`.

### Tokens semânticos via ThemeExtension

Nomeie por relação (`spacing.md`), não por valor (`spacing16`). Use `Padding`, `SizedBox` ou o parâmetro `spacing:` (Flutter 3.27+ em `Row`/`Column`/`Wrap`) entre irmãos. Não use `Container(margin:)` para irmãos: isso confunde alinhamento.

```dart
@immutable
class SpacingTokens extends ThemeExtension<SpacingTokens> {
  const SpacingTokens({
    this.xs = 4, this.sm = 8, this.md = 16, this.lg = 24, this.xl = 32, this.xxl = 48,
  });
  final double xs, sm, md, lg, xl, xxl;
  @override SpacingTokens copyWith({...}) => SpacingTokens(...);
  @override SpacingTokens lerp(other, t) => this;  // valores constantes não interpolam
}

// Uso:
Padding(
  padding: EdgeInsets.all(Theme.of(context).extension<SpacingTokens>()!.md),
  child: ...,
)
```

Para apps menores e protótipos, declare uma classe estática `AppSpacing` em vez de `ThemeExtension`. Para apps que precisam variar tokens por contexto (densidade compact vs comfortable), `ThemeExtension` paga o preço.

## Sistemas de grid

### Grid auto-ajustável

Em Flutter, o equivalente de `repeat(auto-fit, minmax(280px, 1fr))` é `SliverGridDelegateWithMaxCrossAxisExtent`:

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 280,         // colunas com no máximo 280 lógicos
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 4 / 3,
  ),
  itemBuilder: (context, i) => ...,
)
```

Quantas couberem por linha, leftover estica. Sem breakpoints.

Para layouts complexos com regiões nomeadas (header, sidebar, content), `Stack` com `Positioned` resolve. Para algo realmente intricado (tipo CSS grid-template-areas), `CustomMultiChildLayout` é a ferramenta exata, mas raro precisar.

## Hierarquia visual

### O squint test

Tire screenshot, aplique blur (Photoshop, Preview > Markup, ou `Image.filter`). Você ainda consegue identificar:

- O elemento mais importante?
- O segundo mais importante?
- Agrupamentos claros?

Se tudo parece o mesmo peso depois do blur, hierarquia falhou.

### Hierarquia em múltiplas dimensões

Não dependa só de tamanho. Combine:

| Ferramenta | Hierarquia forte | Hierarquia fraca |
|---|---|---|
| **Tamanho** | razão 3:1 ou mais | <2:1 |
| **Peso** | Bold vs Regular | Medium vs Regular |
| **Cor** | Alto contraste (`primary` vs `onSurfaceVariant`) | Tons similares |
| **Posição** | Topo/esquerda (primária) | Embaixo/direita |
| **Espaço** | Cercado de espaço | Apertado |

Em Flutter, tudo isso vira `TextStyle` + `Padding` + `Theme.of(context).colorScheme`. A melhor hierarquia usa 2-3 dimensões ao mesmo tempo: heading que é maior, mais bold, E tem mais espaço acima.

### Cards não são obrigatórios

`Card` é overused. Espaçamento e alinhamento criam grupos visualmente sem precisar do contorno. Use `Card` só quando:

- Conteúdo é genuinamente distinto e acionável (item de feed, tarefa).
- Items precisam de comparação visual em grid.
- Conteúdo precisa de boundary clara de interação.

**Nunca aninhe `Card` dentro de `Card`.** Em Flutter isso é fácil de fazer por engano (`ListView` com `Card` em cada item, dentro de um `Card` de seção). Use `Padding`, `Divider`, ou `surfaceTint` mais alto para hierarquia interna.

### Em mobile, a tendência inversa

Em mobile, "card overload" é a falha mais comum. App de notícias, e-commerce, social: toda lista vira deck de cards arredondados com sombra. O squint test detecta: se todo item da tela é um retângulo igual com sombra leve, hierarquia desaparece. Use `ListTile`, `Divider` sutil, e contraste tipográfico antes de cair em mais um `Card`.

## Container queries em Flutter

Web tem container queries (`@container`). Flutter tem `LayoutBuilder`, que é o equivalente direto e disponível há mais tempo:

```dart
LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth < 400) {
    return _CompactLayout();
  }
  return _ExpandedLayout();
})
```

Componente reage ao espaço que **ele mesmo recebe**, não à viewport. Mesma ideia que container queries. Use sempre que um widget precisa adaptar baseado no slot que ocupa, não na tela inteira.

Para responder à viewport real, `MediaQuery.sizeOf(context).width`. Mas adaptive geralmente quer `LayoutBuilder` (componente reativo ao container) em vez de `MediaQuery` (componente reativo à tela). Ver [responsive-design.md](responsive-design.md).

## Ajustes ópticos

Texto com `padding-left: 0` parece indentado por causa do whitespace da letra; em Flutter, isso aparece em `ListTile.title` e `AppBar.title`. Use `Padding` negativo ou `Transform.translate` para corrigir, com cuidado:

```dart
ListTile(
  title: Transform.translate(
    offset: const Offset(-2, 0),
    child: const Text('Título'),
  ),
)
```

Ícones centralizados geometricamente parecem off-center: `Icons.play_arrow` precisa shiftar à direita; setas, em direção da seta. `Icon` em Flutter já vem com pequenos ajustes ópticos para muitos glyphs. Para ícones custom (`SvgPicture` ou bitmap), confira no design e aplique `Transform.translate` quando necessário.

### Touch target vs tamanho visual

Botões podem parecer pequenos mas precisam de touch target grande (48dp mínimo no Material, 44pt no iOS HIG). Em Flutter:

- `IconButton` default já tem 48dp de tap region (visual costuma ser o ícone de 24).
- `MaterialTapTargetSize.padded` em `ThemeData` é o default certo. `shrinkWrap` reduz para o tamanho visual e quebra a11y.
- `InkWell` cru é só o tamanho do `child`. Se o child for 24×24, touch target é 24×24 e falha.

Como expandir touch target sem mudar o visual:

```dart
SizedBox(
  width: 48, height: 48,                        // touch target
  child: Center(
    child: SizedBox(
      width: 24, height: 24,                    // visual
      child: Icon(Icons.close, size: 24),
    ),
  ),
)
```

Ou, mais idiomático em M3:

```dart
IconButton(
  iconSize: 24,
  visualDensity: VisualDensity.compact,         // apenas se você sabe o que faz
  onPressed: ...,
  icon: const Icon(Icons.close),
)
```

`IconButton` resolve o caso comum. Vá manual quando o widget não é botão (gestos custom em ícone informativo).

## Profundidade & elevação

Em web, z-index numérico. Em Flutter, **a árvore decide**: o que é desenhado depois fica em cima. Para casos onde você precisa de "camada acima de tudo", use `Overlay`/`OverlayEntry` (que é o que `Tooltip`, `showMenu`, `showModalBottomSheet`, `Dialog` usam por baixo).

Crie escala semântica de elevation, não números arbitrários:

```dart
// Material 3 entrega 6 níveis de elevation: 0, 1, 3, 6, 8, 12
// Cada nível mapeia a um surfaceContainer diferente:
// 0 → surface
// 1 → surfaceContainerLow
// 2 → surfaceContainer
// 3 → surfaceContainerHigh
// 4-5 → surfaceContainerHighest
```

Em M3, **elevation não é só sombra: é cor**. Surfaces em níveis maiores ficam mais claras (light) ou levemente mais saturadas via `surfaceTint`. Use `Material(elevation: ...)` ou os widgets que herdam (`Card`, `MenuAnchor`, `Drawer`). Não invente sombras paralelas via `BoxShadow`.

**Insight chave**: sombras devem ser sutis. Se você claramente vê a sombra, ela está forte demais. Em dark mode, sombras quase desaparecem; profundidade vem de `surfaceContainer*` mais claro. Use a escala M3, não custom.

---

**Evitar**: valores arbitrários de espaçamento fora da escala. Espaçamentos todos iguais (variedade cria hierarquia). Hierarquia só por tamanho (combine size, weight, color, space). `Card` aninhado em `Card`. `BoxShadow` custom em vez da escala M3 elevation. `Container(margin: ...)` para irmãos (use `Padding`, `SizedBox`, ou o `spacing:` de `Row`/`Column`).
