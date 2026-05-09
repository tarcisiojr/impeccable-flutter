# Product register

Quando o design SERVE o produto: app principal, telas autenticadas, painéis admin, telas de configuração, listas longas, formulários, qualquer superfície onde o usuário está numa tarefa. A maioria de um app Flutter cai aqui.

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## O teste de slop em product (mobile)

Não é "alguém diria que IA fez isso". Familiaridade é uma feature aqui. O teste é: um usuário fluente em apps de referência da categoria (Instagram, Notion, Linear, Things, Stripe Dashboard, Apple Wallet, Google Photos) abre seu app e confia, ou hesita em cada componente sutilmente errado?

Em mobile há um modo de falha extra que web não tem: **o look do "Flutter app default"**. `MaterialApp` sem `theme:`, ou com `seedColor: Colors.deepPurple` (o do `flutter create`), produz um app que qualquer dev Flutter reconhece em meio segundo. Se seu produto tem mais de uma semana, esse look é dívida.

A barra é familiaridade ganha. A ferramenta deve sumir dentro da tarefa.

## ThemeData é o produto

Em product mobile, todo trabalho de design começa e termina em `ThemeData`. Antes de qualquer screen, defina:

```dart
final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1F4ED8),  // sua cor de marca, NÃO deepPurple
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.interTextTheme(),  // ou system stack
  visualDensity: VisualDensity.adaptivePlatformDensity,
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
  }),
);
```

Tudo o que aparece num `Container`, `Text`, `Padding`, `Card`, `Button` lê desse objeto via `Theme.of(context)`. Se algum widget tem cor literal, esse widget é a causa raiz do próximo bug de dark mode. Trate como tal.

## Material vs Cupertino

Decida antes de escolher widgets:

- **Só Android-fluentes**: Material puro. `MaterialApp`, `AppBar`, `BottomNavigationBar` ou `NavigationBar` (M3), `FloatingActionButton`. iOS roda mas não é "iOS-nativo".
- **Só iOS-fluentes**: Cupertino puro. `CupertinoApp`, `CupertinoNavigationBar`, `CupertinoTabScaffold`, `CupertinoButton`. Android roda mas parece um port.
- **Ambos plataforma-correctness**: alterne por `Theme.of(context).platform`. Pacotes como `flutter_platform_widgets` ajudam, mas o controle fino de cada tela vence o convergente. Apple rejeita apps na App Store quando o look é claramente Android com tinta.

Não há resposta "neutra". Aplicar Material num iPhone que não respeita o swipe-back é tão estranho quanto Cupertino num Pixel sem o gesto de voltar previsível.

## Tipografia

Detalhes em [typography.md](typography.md). Para product:

- **Uma família costuma bastar.** Product não precisa de display + body separados. Um sans bem ajustado carrega `headlineSmall` até `labelSmall`.
- **Stack do sistema é legítimo.** SF Pro no iOS, Roboto no Android, Inter no desktop. `TextTheme` sem `fontFamily` declarada usa o stack do sistema. Carrega instantâneo, não precisa licenciar, parece nativo.
- **Escala fixa via `TextTheme`.** Use os 15 papéis M3 (`displayLarge` … `labelSmall`) sem reinventar. Razão típica entre níveis: 1.125 a 1.2. Mais que isso vira ruído num app denso.
- **Nunca hard-code `fontSize` num `Text`**. Sempre `Theme.of(context).textTheme.bodyMedium`. Hard-code mata Dynamic Type e dark mode tipográfico de uma vez.
- **`MediaQuery.textScaler` é não-negociável.** Não passe `textScaler: TextScaler.noScaling` em lugar nenhum, mesmo que "quebre o layout". Se 130% de escala quebra a tela, a tela está errada.

## Cor

Product padrão é Restrained. Uma única superfície pode justificar Committed (uma tela de welcome com hero saturado, um relatório com uma cor de categoria dominante), mas Restrained é o piso.

- **`ColorScheme.fromSeed` é a única forma sensata.** Material 3 deriva 30 papéis a partir da semente. Tentar montar à mão `primary`, `onPrimary`, `surfaceContainerHigh` etc. quase sempre quebra contraste em algum estado.
- **Vocabulário semântico de estado.** Use `WidgetStateProperty` para `hovered`, `focused`, `pressed`, `disabled`, `selected`, `error`. Padronize. Não invente cor para "estado pressionado" tela a tela.
- **Cor de acento é para ação primária, seleção atual e indicador de estado.** Nunca decoração. Um `FloatingActionButton` colorido + 6 chips com a mesma cor + ícones tonais = perda de hierarquia.
- **Camada neutra dupla.** `surface` para conteúdo, `surfaceContainerHigh` ou `surfaceContainer` para sidebars/sheets/cards elevados. Material 3 já entrega isso pronto.
- **Validação de contraste vai sobre cor RESOLVIDA, não sobre literal.** Um `Color(0xFF666)` num fundo dinâmico do Material You pode passar num device e falhar em outro.

Detalhes em [color-and-contrast.md](color-and-contrast.md).

## Layout

- **Grids previsíveis.** Consistência É uma affordance. Em mobile, o usuário só tem um polegar e três segundos. Surpresas estruturais custam caro.
- **Padrões padrão são features.** `BottomNavigationBar` (ou `NavigationBar` M3) para 3 a 5 destinos top-level, `NavigationRail` para tablets, `NavigationDrawer` para mais. Se o seu app inventa "tab inferior horizontal customizada", a App Store sabe.
- **Adaptive não é responsive.** Web responde com layout fluido, mobile responde com **mudança de componente**. `BottomNavigationBar` no celular vira `NavigationRail` no tablet. Não estique. Detalhes em [responsive-design.md](responsive-design.md).
- **`SafeArea` em qualquer overlay full-screen.** Bottom sheets, modais, splashes, telas de câmera. O notch e a gesture bar comem o que você esquecer.
- **`Padding` semântico, não mágico.** Use tokens (`EdgeInsets.symmetric(horizontal: spacing.md)` em vez de `EdgeInsets.all(16)`). Se cada tela tem um número diferente, você tem um problema de design system, não de layout.

## Componentes

Todo componente interativo tem: default, hovered (desktop), focused, pressed, disabled, loading, error, selected. Não shipear com metade.

- **Skeleton em loading, não spinner.** `Shimmer` ou `SkeletonLoader` em vez de `CircularProgressIndicator` no meio do conteúdo. Spinner só para ações pontuais (botão de submit).
- **Empty states ensinam a interface.** Não "nada aqui". Diga o que o usuário pode fazer (botão "Criar primeiro projeto" + ilustração contextual).
- **Affordance consistente entre telas.** Mesmo formato de botão primário. Mesmo `ListTile` para listas. Mesmo `IconButton` size. Se o "salvar" parece diferente em duas telas, um dos dois está errado.
- **Touch target 48dp mínimo.** `IconButton` default já é 48; `InkWell` cru não é. `MaterialTapTargetSize.padded` em `ThemeData` é o padrão correto.

## Motion

Detalhes em [motion-design.md](motion-design.md). Para product:

- **150 a 250ms na maioria das transições.** Usuário está em fluxo. Não faça ele esperar coreografia.
- **Movimento conveys estado, não decoração.** Mudança de estado, feedback, reveal, transição entre rotas. Nada além disso.
- **Sem orquestração de page-load.** Product carrega para uma tarefa. Ninguém quer ver seu app entrar em cena com stagger.
- **Curvas do Material 3 emphasized/standard, ou Cupertino easings.** Nunca `Curves.bounceOut` ou `Curves.elasticIn` em product. Em qualquer tela. Nunca.
- **`AnimatedSwitcher` para conteúdo trocável, `Hero` para continuidade entre rotas.** Os dois resolvem 80% das transições que valem a pena.

## Acessibilidade

Detalhes em [audit.md](audit.md). Para product, o checklist mínimo:

- `Semantics` em todo `GestureDetector`/`InkWell` que faz algo.
- `tooltip:` em todo `IconButton`.
- `semanticLabel:` em todo `Image`/`Icon` informativo.
- Foco navegável. `FocusTraversalGroup` quando há múltiplas regiões.
- Contraste 4.5:1 em texto body, 3:1 em large text e ícones de UI.
- Touch target 48dp.
- `MediaQuery.textScaler` honrado em todas as telas.
- `MediaQuery.disableAnimationsOf(context)` honrado em motion não-essencial.

## Banimentos do product mobile (sobre os bans compartilhados)

- `MaterialApp` sem `theme:` definido. Look default = dívida.
- `Colors.deepPurple` como `seedColor`. É o look "flutter create".
- `Colors.black` ou `Colors.white` literal em qualquer lugar do código de UI.
- `TextStyle` cru em `Text` (fora de testes ou one-shots).
- Hard-code de `MediaQuery.textScaler: TextScaler.noScaling`.
- `Curves.bounce*` ou `Curves.elastic*` em transições de produção.
- Custom scrollbar visível no mobile. Scrollbar nativa do sistema vence sempre.
- `BottomNavigationBar` com 6+ destinos. Reorganize a IA, não esprema mais um.
- `FloatingActionButton` em telas que já tem ação primária na AppBar. Uma ação primária por tela.
- Inconsistência entre Material e Cupertino dentro do mesmo app sem regra clara. Mistura aleatória reads como port mal feito.

## Permissões do product mobile

Coisas que product pode e brand não precisa.

- System stack de fonte (SF Pro / Roboto / system-ui via `TextTheme` sem família).
- Padrões de navegação canônicos: bottom nav, back button no topo, swipe-to-back no iOS, predictive back no Android 14+.
- Densidade. Listas longas, formulários densos, tabelas em tablet com `DataTable2`.
- Consistência sobre surpresa. Mesmo vocabulário visual tela a tela é virtude. Delight é momento, não página.
- Cupertino e Material misturados quando a regra é clara (e.g. "diálogos modais em iOS usam `CupertinoAlertDialog`, no Android usam `AlertDialog`"). Inconsistência regrada é OK.
