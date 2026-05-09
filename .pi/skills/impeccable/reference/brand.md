# Brand register

Quando o design IS o produto. Em mobile isso é um nicho real, embora menor que em web: app de marca (Liquid Death, Patagonia), app de campanha, app de uma exposição ou turnê, app de portfólio (artista, fotógrafo, estúdio), app companion de uma marca física (loja, restaurante, hotel), splash + onboarding branded de qualquer app que se leva a sério como identidade visual.

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

O register cobre vários gêneros. Tech (Linear app, Vercel app), luxo (hotel, fashion), consumo (restaurante, travel, CPG), criativos (estúdio, agência, banda). Compartilham a postura (*comunicar, não transacionar*) e divergem totalmente no estético. Não colapsar tudo num único look.

## O teste de slop em brand (mobile)

Se alguém olha sem hesitar e diz "isso é um app Flutter de IA", falhou. A barra é distinção. O visitante deve perguntar "como fizeram isso?", não "qual modelo gerou isso?".

Brand não é um register neutro. Apps de campanha gerados por LLM já existem e são intercambiáveis. Restraint sem intenção lê como mediano, não refinado. Brand surfaces precisam de POV, audiência específica, vontade de arriscar estranheza. Vai grande ou vai pra casa.

**O segundo teste, lane estética**: antes de comprometer com movimentos, nomeie a referência. "Tipo o app da Liquid Death, ácido maximalista". "Tipo o app do Hermès, editorial preto e branco". "Tipo a abertura do Apple Maps, mapas tipográficos". Não derive para editorial-magazine num brief que não pede magazine. Um app de campanha de hiking com Cormorant italic em drop caps tem o register errado dentro do register.

## O slop específico de brand em Flutter

Três fingerprints de "Flutter brand app gerado por IA" para banir antes de começar:

1. **Splash screen com gradiente roxo-azul + logo centralizada com `FadeInScale`.** O splash mais comum gerado é exatamente isso. Se você quer brand, splash ou é matemática (logo bold em fundo flat brand-color, sem animação) ou é arte (loop Lottie/Rive de 600ms desenhado para a marca).
2. **AppBar com `LinearGradient` purple → blue + `Text` branco bold.** Se a barra de cima é gradiente, você está copiando 2018 Material Design tutorials. Brand mobile em 2026 ou é cor flat saturada da marca, ou é transparente com `SliverAppBar` colapsável.
3. **Hero card com border-radius 24, sombra suave azul-clara, padding 24, "eyebrow" pequeno em maiúsculas, headline bold, botão arredondado abaixo.** Esse layout é o equivalente Flutter do `<section class="hero">` web genérico. Brand pede composição assimétrica, hierarquia tipográfica forte, ou imagem que carrega a tela.

## Tipografia

### Procedimento de seleção de fonte

Todo projeto. Nunca pular.

1. Ler o brief. Escrever três palavras concretas de voz da marca. Não "moderno" ou "elegante", mas "quente e mecânico e opinionado" ou "calmo e clínico e cuidadoso". Palavras de objeto físico.
2. Listar as três fontes que viriam por reflexo. Se aparecerem na lista de reflex-reject abaixo, rejeitar. São defaults de training data e criam monocultura.
3. Procurar num catálogo real (Google Fonts, Pangram Pangram, Future Fonts, Adobe Fonts, ABC Dinamo, Klim, Velvetyne) com as três palavras em mente. Achar a fonte para a marca como objeto físico: legenda de museu, manual de terminal dos anos 70, etiqueta de tecido, livro infantil em jornal barato, poster de show, recibo de diner mid-century. Rejeitar a primeira coisa que "parece de design".
4. Cross-check. "Elegante" não é necessariamente serif. "Técnico" não é necessariamente sans. "Quente" não é Fraunces. Se a escolha final bate com o reflexo original, recomeçar.

### Em Flutter, como carregar

Duas vias razoáveis, decidir cedo:

- **`google_fonts` package**: pega de runtime ou cacheia local. Bom para protótipos e marcas que aceitam dependência de Google. Usar `GoogleFonts.config.allowRuntimeFetching = false` em produção; embedar TTFs no `assets/fonts/` para garantia.
- **Bundle direto via `pubspec.yaml > flutter > fonts`**: licença na sua mão, controle total, suporta `axes` de variable font. Para marcas sérias, é o caminho.

Variable fonts são suportadas. `FontVariation('wght', 480)` para peso fracionário. Um variable file costuma ser menor que três pesos estáticos.

### Lista reflex-reject

Defaults de training data. Lista de proibidos. Procurar mais fundo.

Fraunces · Newsreader · Lora · Crimson · Crimson Pro · Crimson Text · Playfair Display · Cormorant · Cormorant Garamond · Syne · IBM Plex Mono · IBM Plex Sans · IBM Plex Serif · Space Mono · Space Grotesk · Inter · DM Sans · DM Serif Display · DM Serif Text · Outfit · Plus Jakarta Sans · Instrument Sans · Instrument Serif

### Lanes estéticas reflex-reject (em mobile)

Paralelo à lista de fontes. Famílias estéticas saturadas em apps mobile. Se o brief cai numa destas sem razão de register que *exija*, é reflexo de segunda ordem. Procurar mais fundo.

- **Editorial-tipográfico mobile.** Display serif italic + mono labels pequenos + linhas horizontais ruled + restraint monocromático. A versão Stripe/Linear app reduzida. Fingerprint: três blocos separados por divider line, headline italic Fraunces/Recoleta/Newsreader, metadata em uppercase track-spaced, sem imagem.
- **Material baseline polished.** Card com elevation, FAB redondo brand-color, BottomNavigationBar 4 tabs com ícones outlined. Parece "bem feito" porque é o tutorial Material 3. Se sua marca tem voz, isso esconde a voz.
- **Splash + onboarding "página 1 de 3" com Lottie genérico.** Padrão de 100% dos templates. Se brand, ou tem ilustração própria ou começa direto na tela 1 sem onboarding.

(Mais entradas aterrissam aqui no mesmo cadência da lista de fonte. Brutalist-utility e acid-maximalism podem entrar quando saturarem. Remover quando saírem da saturação também é OK.)

As listas reflex-reject valem para **decisões novas**. Quando a marca já comprometeu com uma fonte ou lane como parte da identidade, identidade-vence. Variantes em superfície existente não questionam o que já está shippado. Reflex-reject é para greenfield.

### Pairing e voz

Distinto + refinado é o objetivo. Forma específica depende da marca:

- **Editorial / long-form / luxo**: display serif + sans body. Em Flutter: dois `TextStyle` diferentes, um para `displayLarge` (serif), outro para `bodyLarge` (sans).
- **Tech / dev tools / fintech**: um sans comprometido. Tracking apertado, contraste forte de peso dentro da família.
- **Consumer / food / travel**: pares quentes, humanist sans + script display.
- **Estúdios criativos / agências**: quebra de regra bem-vinda. Mono-only, display-only, type custom desenhado.

Mínimo duas famílias só *quando a voz pede*. Uma família bem escolhida com contraste comprometido de peso/tamanho é mais forte que um par display+body tímido.

Variar entre projetos. Se o último brief foi serif-display-landing, esse não é.

### Escala

Modular scale. Em Flutter mobile: razão ≥1.25 entre níveis do `TextTheme` quando você customiza. Escalas planas (1.1x apart) leem como sem comprometimento.

Não há `clamp()` em Flutter. Para variar tamanho por viewport, use `LayoutBuilder` ou breakpoints Material (compact/medium/expanded) para trocar de `TextTheme` ou aplicar fator. Não tente fluid type por código (fica jank em scroll).

Texto claro em fundo escuro: adicionar 0.05 a 0.1 em `height`. Texto leve lê como mais leve e precisa de mais respiro.

## Cor

Brand surfaces têm permissão para Committed, Full palette e Drenched. Usar. Uma única cor saturada espalhada pelo hero não é excesso, é voz. Um app brand bege-com-azul-claro ignora o register.

- Nomear referência real antes de pegar estratégia. "Liquid Death app, verde ácido drenched". "Patagonia app, terra-vermelha committed". "Hermès app, laranja saturado em fundo creme". "MUBI app, preto puro com posters dominando". Ambição sem nome vira bege.
- Em Flutter, isso significa **não começar pelo `ColorScheme.fromSeed` se brand**. `fromSeed` é a ferramenta certa para product. Brand pode pedir `ColorScheme.fromSeed` com semente brand E **override manual** de `primary`, `surface`, `surfaceContainer` para a paleta-marca exata. Ou montar `ColorScheme.fromSwatch` à mão.
- Paleta É voz. Marca calma e marca inquieta não compartilham mecânica de paleta.
- Quando a estratégia é Committed ou Drenched, cor carrega a marca. Não hedge com neutros nas bordas. Comprometer.
- Não convergir entre projetos. Se a última marca foi restrained-on-cream, essa não é.

## Layout

- Composição assimétrica é uma opção real. `Stack` + `Positioned` + `Align` resolvem 80% das composições "quebradas" que importam em mobile.
- `SliverAppBar` colapsável + `CustomScrollView` é a ferramenta brand de scroll-driven em mobile. Vale para hero que vira AppBar fixa.
- Espaçamento generoso em mobile é mais raro que em web (tela é menor) mas em brand é diferencial. Padding 32-48 horizontal num hero comunica "esse app vale o pixel".
- Alternativa: grid estrito visível como voz (brutalist / Swiss / tech-spec). Em Flutter: `GridView` com gap fixo, separadores `Divider` com `thickness: 0.5`, números monoespaçados.
- Não centralizar tudo. Left-aligned com asymmetric ou strict-grid passa "designed". Centered-stack com card-icon-title-subtitle passa template.
- Quando cards SÃO a affordance, `GridView.builder` com `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 280)` dá responsivo sem breakpoint.

## Imagem

Brand surfaces se apoiam em imagem. Um app de restaurante, hotel, magazine ou produto sem nenhuma imagem lê como incompleto, não restrained. Um `Container` colorido onde uma hero image deveria estar é pior que uma foto stock representativa.

**Quando o brief implica imagem (restaurante, hotel, magazine, fotografia, comunidade hobbyista, food, travel, fashion, produto), você precisa shippar imagem.** Zero imagens é bug, não escolha de design.

- **Para greenfield sem assets locais, use `cached_network_image` + Unsplash.** URL: `https://images.unsplash.com/photo-{id}?auto=format&fit=crop&w=1600&q=80`. Pegue IDs reais que você sabe que existem (`photo-1559339352-11d035aa65de`, etc.). Se em dúvida, menos fotos, mas não substitua por `Container` colorido.
- **Buscar pelo objeto físico da marca**, não pela categoria genérica. "fettuccine costeira cortada à mão na varanda" bate "comida italiana".
- **Uma foto decisiva bate cinco medianas.** Hero comprometido com mood vence padding com mais stock.
- **`semanticLabel:` em `Image` é parte da voz.** "Fettuccine costeira, cortada à mão, servida na varanda" bate "prato de massa".

Apps tech / dev tools são exceção onde zero imagem pode ser certo. Saiba qual marca você tem.

## Motion

- Splash + onboarding orquestrados. Brand pode pagar 1.5s de coreografia se a marca pede. `Hero` para continuidade de identidade entre rotas.
- Para colapsar/expandir seções, `AnimatedSize` ou `SliverAnimatedList` são mais corretos que rebuild com `setState`.
- Tech-minimal brands podem pular entrance motion. O restraint é a voz. Apple App Store opening: zero animation, isso ESSA decisão.
- Em brand, motion pode ser custom: `CustomPainter` desenhando, Rive embedado, `AnimationController` orquestrado em fases. Em product nada disso.

Detalhes em [motion-design.md](motion-design.md).

## Banimentos do brand mobile (sobre os bans compartilhados)

- Mono como atalho preguiçoso para "técnico / developer". Se a marca não é técnica, mono lê como fantasia.
- Ícone redondo grande arredondado acima de cada heading. Grita template.
- Apps single-family que escolheram a família por reflexo, não voz. (Single family deliberada é fina.)
- All-caps em body. Reservar caps para labels curtos e headings.
- Paletas tímidas e layouts médios. Safe = invisível.
- Zero imagem em brief que pede imagem (restaurante, hotel, food, travel, fashion, fotografia, hobbyista). Blocos coloridos onde foto-hero pertence.
- Default para editorial-magazine (display serif + italic + drop caps + grid broadsheet) em briefs que não são magazine. Editorial é UMA lane, não default.
- Splash genérico (logo + fade-in + duração 2s). Ou tem desenho próprio, ou nem tem splash.
- `LinearGradient` purple-blue em qualquer lugar (AppBar, FAB, Card). Talvez a maior bandeira de "Flutter app de tutorial".

## Permissões do brand mobile

Coisas que brand pode e product não precisa.

- Splash + onboarding com motion ambicioso. Reveals, scroll-triggered, coreografia tipográfica.
- Telas single-purpose. Uma ideia dominante por scroll, scroll longo, pacing deliberado.
- Risco tipográfico. Display enorme, italic inesperado, mistura de cases, headlines desenhadas à mão, palavra única gigante como hero.
- Estratégias de cor inesperadas. Paleta É voz; marca calma e inquieta não compartilham mecânica.
- Direção de arte por seção. Seções diferentes podem ter mundos visuais diferentes se a narrativa pede. Consistência de voz vence consistência de tratamento.
- Plataforma-overrides ousados. Pode shippar `CupertinoApp` puro mesmo no Android se a marca pede iOS-aesthetic, ou Material puro mesmo no iPhone se a marca é Android-first declarado.
