# Interaction Design (Flutter)

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Os oito estados interativos

Todo elemento interativo precisa destes estados desenhados:

| Estado | Quando | Tratamento |
|---|---|---|
| **Default** | Em repouso | Estilo base |
| **Hovered** | Ponteiro sobre (desktop/web Flutter; mobile não tem) | Lift sutil, shift de cor |
| **Focused** | Foco de teclado / programático | Focus ring visível |
| **Pressed** | Sendo pressionado | Mais escuro, ripple no Material |
| **Disabled** | Não interativo | Opacidade reduzida, sem ripple |
| **Selected** | Item selecionado em group | Cor de container ou borda |
| **Error** | Estado inválido | Borda `colorScheme.error`, ícone, mensagem |
| **Loading** | Processando | Skeleton, spinner inline, ou disabled state |

A confusão mais comum: desenhar hover sem focus, ou vice-versa. Em mobile puro, `hovered` raramente importa (a não ser que rode em iPad com Magic Keyboard ou em desktop). `focused` importa sempre: usuário com Switch Control, teclado bluetooth, ou screen reader navega assim.

## WidgetState e WidgetStateProperty

Em Flutter, os 8 estados são unificados em `WidgetState` (antigo `MaterialState`). Para customizar comportamento por estado, use `WidgetStateProperty.resolveWith`:

```dart
ElevatedButton(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return scheme.surfaceContainerLow;
      if (states.contains(WidgetState.pressed)) return scheme.primaryContainer;
      if (states.contains(WidgetState.hovered)) return scheme.primary.withValues(alpha: 0.92);
      return scheme.primary;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return scheme.onSurface.withValues(alpha: 0.38);
      return scheme.onPrimary;
    }),
  ),
  onPressed: () {},
  child: const Text('Salvar'),
)
```

Não monte `if (isPressed) ...` em `build` manualmente: você vai esquecer um estado.

## Focus ring: faça direito

**`FocusableActionDetector`** é a ferramenta canônica para widgets custom interativos. Ela combina `Focus`, `FocusableActionDetector`, `MouseRegion` e atalhos de teclado. Para widgets que herdam de `InkWell`/`Material`, o ring vem de graça.

Nunca remova o focus indicator sem substituto:

```dart
FocusableActionDetector(
  actions: { ActivateIntent: CallbackAction(onInvoke: (_) => onTap()) },
  shortcuts: { LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent() },
  child: Builder(builder: (context) {
    final hasFocus = Focus.of(context).hasFocus;
    return Container(
      decoration: BoxDecoration(
        border: hasFocus
            ? Border.all(color: scheme.primary, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      // ...
    );
  }),
)
```

Critérios do focus ring:
- Alto contraste (3:1 mínimo contra cores adjacentes).
- 2-3 lógicos de espessura.
- Offset em vez de inset (use `Border.all` com cor de fundo do container, ou `Stack` com `Positioned` para anel externo).
- Consistente entre todos os widgets interativos.

## Form design: o não-óbvio

**Hint não é label.** `InputDecoration(hintText: 'email')` desaparece no input. Sempre use `labelText:` (que floats) ou `Text` separada acima do `TextFormField`. Se você precisa do hint, ele é exemplo de formato (`'jane@example.com'`), não nome do campo.

**Validar no blur**, não em cada keystroke. Em Flutter, isso significa `Form.onChanged: null` + `validator:` que dispara em `Form.validate()` (chamado no submit ou no `onFocusChange: (has) => !has ? ...`).

Exceção: força de senha, autocomplete contextual, busca incremental: esses validam em real-time porque é a função.

**Errors abaixo do field**, não em diálogo. Em Flutter, `InputDecoration(errorText: ...)` faz isso direto e expõe `Semantics` correto para screen reader. Para erros que cobrem múltiplos campos, `SnackBar` ou banner no topo.

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'jane@example.com',
    helperText: 'Usado para login',         // ajuda persistente
    errorText: _emailError,                 // erro condicional
  ),
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (v) => v?.contains('@') == true ? null : 'Endereço inválido',
)
```

`autovalidateMode: AutovalidateMode.onUserInteraction` é o sweet spot: valida só depois que o usuário tocou no campo, não ao primeiro render.

## Loading states

**Updates otimistas**: mostre sucesso imediato, rollback em falha. Use para low-stakes (likes, follows, marcar como lido). Em Flutter:

```dart
Future<void> _toggleLike() async {
  setState(() => _liked = !_liked);    // UI imediata
  try {
    await api.setLike(_liked);
  } catch (e) {
    setState(() => _liked = !_liked);  // rollback
    showSnackBar('Não foi possível salvar');
  }
}
```

**Skeleton > spinner**: skeleton dá preview do shape do conteúdo e parece mais rápido que `CircularProgressIndicator` no meio da tela. Pacotes: `shimmer`, `skeletonizer`. Para casos simples, `Container` cinza com `BorderRadius` no shape do widget final + `AnimatedOpacity` quando dados chegam.

**`CircularProgressIndicator`** continua válido para:
- Botões enquanto submetem (`ElevatedButton` com `child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))`).
- Estados terminais onde skeleton não faz sentido (refresh em pull-to-refresh já usa via `RefreshIndicator`).

## Modais: bottom sheets, dialogs, full-screen

Em mobile, **bottom sheet costuma vencer dialog**. Está mais perto do polegar, ocupa espaço previsível, suporta drag-to-dismiss.

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,                  // permite altura customizada
  showDragHandle: true,                      // M3 dragger no topo
  builder: (context) => _MyBottomSheetContent(),
)
```

Para conteúdo que precisa decisão sim/não simples, `AlertDialog` (Material) ou `CupertinoAlertDialog` (iOS-fluente). Para tela inteira de fluxo, `Navigator.push` com `fullscreenDialog: true` (transição vem de baixo, botão de close em vez de back).

### Focus trap automático

`Dialog`, `showModalBottomSheet`, `showMenu`, `showDatePicker`: todos lidam com focus trap, dismiss no escape, retorno de foco para o trigger. Você não precisa montar nada manual. Diferente de web: zero `inert`, zero JS de focus trap.

### Cuidado com `BackdropFilter` em modal

Se a sheet ou dialog tem blur de fundo via `BackdropFilter`, contraste do conteúdo abaixo fica imprevisível. Sempre componha com um `Container(color: scheme.scrim)` por baixo do blur. M3 já entrega `colorScheme.scrim` calibrado.

## Tooltips e menus

Para tooltips:

```dart
Tooltip(
  message: 'Excluir item',
  child: IconButton(icon: Icon(Icons.delete), onPressed: ...),
)
```

`Tooltip` aparece no long-press em mobile (default), no hover em desktop. Long-press para tooltip não é descobrible: sempre dê alternativa visual quando possível (label visível, ícone + texto).

Para menus de opção:

```dart
MenuAnchor(
  builder: (context, controller, child) => IconButton(
    icon: const Icon(Icons.more_vert),
    onPressed: controller.open,
  ),
  menuChildren: [
    MenuItemButton(child: const Text('Editar'), onPressed: () {}),
    MenuItemButton(child: const Text('Excluir'), onPressed: () {}),
  ],
)
```

`MenuAnchor` (M3) é a ferramenta moderna. `PopupMenuButton` ainda funciona mas é M2. Para menus contextuais em ícone, prefira `MenuAnchor`.

## Posicionamento de overlay

Em web isso é o problema crônico (`position: absolute` clipado por `overflow: hidden`). **Em Flutter o equivalente direto não existe**: `Overlay` (top layer) é onde tudo flutua. `Tooltip`, `showMenu`, `MenuAnchor`, `Dialog` usam por baixo. Para sua própria UI flutuante:

```dart
final overlay = Overlay.of(context);
final entry = OverlayEntry(builder: (_) => Positioned(
  left: 100, top: 200,
  child: Material(elevation: 8, child: ...),
));
overlay.insert(entry);
// ... mais tarde:
entry.remove();
```

Para "menu ancorado a este botão" sem montar manual, `MenuAnchor` resolve com posicionamento automático que considera bordas da viewport.

### Anti-padrões equivalentes

- `Overlay` esquecido removido. Vazamento. Sempre `entry.remove()` quando fechar.
- `Stack` profundo com `Positioned` para emular dropdown. Use `Overlay` ou `MenuAnchor` em vez.
- `showDialog` sem `useRootNavigator: true` quando há nested `Navigator`. Diálogo aparece no Navigator errado (atrás de bottom sheet, por exemplo).
- Z-index mental "tooltip > modal > snackbar". Em Flutter, ordem é definida pelo `Overlay` em que cada um insere. `ScaffoldMessenger` > `Navigator overlay` > etc. Documentação Flutter cobre.

## Ações destrutivas: undo > confirm

**Undo bate diálogo de confirmação.** Usuários clicam through confirmação no piloto automático. Remover da UI imediato, mostrar `SnackBar` com action "Desfazer", deletar de fato após o snack expirar:

```dart
void _delete(Item item) {
  setState(() => items.remove(item));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('"${item.title}" excluído'),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () => setState(() => items.add(item)),
      ),
      duration: const Duration(seconds: 5),
      onVisible: () {},
    ),
  );
  // schedule actual delete after snackbar duration
  Future.delayed(const Duration(seconds: 5, milliseconds: 300), () {
    if (mounted && !items.contains(item)) _api.delete(item.id);
  });
}
```

Use diálogo de confirmação só para:
- Ações realmente irreversíveis (deletar conta, deletar workspace inteiro).
- Ações de alto custo (compra, transferência).
- Operações em batch (deletar 50 items).

## Navegação por teclado

### Roving tabindex equivalente

Em Flutter, `FocusTraversalGroup` com `policy: WidgetOrderTraversalPolicy()` ou `OrderedTraversalPolicy()` controla a ordem do tab. Para grupos onde uma seta (não tab) move entre items (tabs, menu, radio):

```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Row(children: [
    for (final tab in tabs) FocusTraversalOrder(
      order: NumericFocusOrder(tab.index.toDouble()),
      child: TabButton(tab),
    ),
  ]),
)
```

Para arrow-key navigation entre items de uma lista/menu, `Shortcuts` + `Actions`:

```dart
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
    LogicalKeySet(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
  },
  child: Actions(
    actions: {
      NextFocusIntent: CallbackAction(onInvoke: (_) => FocusScope.of(context).nextFocus()),
      // ...
    },
    child: ...,
  ),
)
```

`MenuAnchor` e `TabBar` já fazem isso por dentro.

### Skip links

Em mobile costuma ser desnecessário; o screen reader tem rotor (iOS) ou navigation gestures (Android) para pular grupos. Para apps com side nav grande no tablet, `Semantics(sortKey:)` controla a ordem que TalkBack/VoiceOver lê.

## Descobribilidade de gestos

Swipe-to-delete e similares são invisíveis. Insinue:

- **Reveal parcial**: `Dismissible` com `background:` colorido visível durante drag: mostra a ação que vai disparar.
- **Onboarding**: tooltips coach mark na primeira vez (`showcaseview` package).
- **Alternativa visível**: sempre dê opção menu "..." com "Excluir" para usuários que não descobrem o swipe.

Não confie em gesto como única forma de fazer ação.

```dart
Dismissible(
  key: ValueKey(item.id),
  direction: DismissDirection.endToStart,
  background: Container(
    color: scheme.errorContainer,
    alignment: AlignmentDirectional.centerEnd,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Icon(Icons.delete, color: scheme.onErrorContainer),
  ),
  confirmDismiss: (_) async => /* show confirm if irreversible */,
  onDismissed: (_) => _deleteWithUndo(item),
  child: ListTile(title: Text(item.title)),
)
```

---

**Evitar**: remover focus indicators sem alternativa. Hint text como label. Touch target <48dp. Mensagens de erro genéricas. Widgets interativos custom sem `Semantics`/keyboard handling. Diálogo de confirmação para ações reversíveis. `setState` ignorando rollback em UI otimista.
