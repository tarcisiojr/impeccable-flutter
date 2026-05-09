# Color & Contrast (Flutter)

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Color spaces: o vocabulário Flutter

OKLCH continua sendo o melhor modelo mental para escolher cores ("igual passo de lightness *parece* igual"). Em código Flutter você ainda vai escrever `Color(0xFF...)` porque é o que o framework aceita. Faça as escolhas em OKLCH (ferramenta: oklch.com), depois converta para hex e cole.

Flutter 3.27+ tem `Color.from(alpha:, red:, green:, blue:, colorSpace:)` com `ColorSpace.displayP3` e `ColorSpace.extendedSRGB`. Para a maioria de apps fica em sRGB. P3 vale para apps de imagem/foto/branding sério em iPhones recentes.

A regra de não default: o hue que você escolhe é decisão de marca. Não cair em azul (hue 250) ou laranja quente (hue 60) por reflexo. **Em Flutter, o anti-default específico é `Colors.deepPurple`** (hue ~280), porque é o que `flutter create` injeta. Veja num app desconhecido essa cor de marca, e você sabe que ninguém customizou.

## Construindo a paleta funcional

### Material 3 ColorScheme: a única forma sensata

`ColorScheme.fromSeed(seedColor: ...)` deriva 30 papéis semânticos. Use. Não monte os 30 à mão.

```dart
final scheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1F4ED8),     // sua cor de marca
  brightness: Brightness.light,
  // contrastLevel: 0.5,   // M3+: força mais contraste (acessibilidade)
);
```

Os 30 papéis cobrem `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondary` & seus pares, `tertiary`, `error`, `surface`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`, `surfaceVariant`, `outline`, `outlineVariant`, `shadow`, `scrim`, `inverseSurface`, `inverseOnSurface`, `inversePrimary`, e mais.

Acessar via `Theme.of(context).colorScheme.primary`. Nunca `Color(0xFF...)` literal num widget.

### Tinted neutrals (Flutter version)

Cinza puro é morto. M3 já entrega isso de graça via `surfaceTint`: cada nível de elevação compõe a `surface` com um leve tint da `primary`. Resultado: surfaces "neutras" carregam vestígio da cor de marca, sem ler como tintas conscientes. Não desligue isso.

Onde você ainda precisa montar à mão (ex: divider line, scrim, overlay), tinte em direção à `primary` da marca, não em direção ao default "warm orange ou cool blue".

### Estrutura completa

| Papel | Propósito | Exemplo Flutter |
|---|---|---|
| **Primary** | Marca, CTAs, ações-chave | `colorScheme.primary` |
| **Secondary** | Apoio, complementar | `colorScheme.secondary` (use só se a marca pede) |
| **Tertiary** | Cor terceira, raro | `colorScheme.tertiary` (90% dos apps não precisa) |
| **Neutral** | Texto, fundos, bordas | `colorScheme.surface*`, `onSurface`, `outline` |
| **Semantic** | Erro, sucesso, warning | `colorScheme.error` + `ThemeExtension<Semantic>` para success/warning/info |
| **Surface scale** | Cards, modais, overlays | `surfaceContainer*` família (5 níveis M3) |

**Pular secondary/tertiary a menos que você precise.** A maioria dos apps funciona com uma cor de acento. Adicionar mais cria fadiga de decisão e ruído visual. M3 deixa ambos disponíveis, mas isso não é convite.

### Regra 60-30-10 (correta)

É sobre **peso visual**, não pixels:

- **60%**: superfícies base, espaço branco, neutros (`surface`, `surfaceContainer`)
- **30%**: secundários: texto, bordas, estados inativos (`onSurface`, `outline`, `surfaceContainerHighest`)
- **10%**: acento: CTAs, highlights, focus (`primary`, `tertiary`)

Erro comum: usar primary em todo lugar "porque é a cor da marca". Acento funciona porque é raro. Excesso mata o poder.

## Contraste & acessibilidade

### Requisitos WCAG (idênticos web)

| Tipo | AA mínimo | AAA alvo |
|---|---|---|
| Body text | 4.5:1 | 7:1 |
| Large text (18pt+ ou 14pt bold) | 3:1 | 4.5:1 |
| Componentes UI, ícones | 3:1 | 4.5:1 |
| Decorações não-essenciais | nenhum | nenhum |

### Validar com cor RESOLVIDA, não literal

Esse é o ponto crítico em Flutter, e tropeça quem vem da web: `colorScheme.onSurface` não é uma cor fixa. Em light mode é tipo `0xFF1B1C1F`, em dark é tipo `0xFFE4E2E6`, em Material You vira algo derivado do wallpaper do Android. Validar contraste literalmente lendo `0xFF666` num código não diz se passa. Resolva primeiro:

```dart
final color = Theme.of(context).colorScheme.onSurfaceVariant;
final bg = Theme.of(context).colorScheme.surface;
final ratio = computeWcagContrast(color, bg);
assert(ratio >= 4.5, 'body falla contraste em $brightness');
```

Faça isso em widget tests com `MaterialApp(theme: ..., home: ...)` em ambos os brightness.

### Combinações perigosas (mobile)

- **Texto cinza claro em fundo branco**: o erro número 1.
- **Texto cinza em fundo colorido**: cinza fica washed-out e morto sobre cor. Use uma sombra mais escura da mesma cor de fundo, ou opacidade.
- **Vermelho em verde** ou vice-versa: 8% dos homens não diferenciam.
- **Texto fino sobre imagem**: contraste imprevisível. Use `Container` com `gradient` overlay ou `BackdropFilter`.
- **Texto sobre `Image.network`** sem placeholder de cor: durante o load, o texto pode estar sobre branco ou preto sem você saber. Sempre `loadingBuilder:` com cor do placeholder.

### Nunca `Colors.black` ou `Colors.white` literal

Cinza puro e preto puro não existem na natureza; toda sombra real tem nuance. Use `colorScheme.onSurface` (≈ preto-tintado em light mode), `colorScheme.surface` (≈ branco-tintado), `colorScheme.shadow`. Material 3 já entrega esses tintados.

Onde a regra é difícil: status bar, splash screen, bordas de SystemUiOverlayStyle. Aqui você passa cor. Use `Theme.of(context).colorScheme.surface` se o contexto está disponível, ou os defaults do M3.

### Testando

Não confiar nos olhos. Ferramentas:

- [`accessibility_tools`](https://pub.dev/packages/accessibility_tools) package: overlay no app dev mode que sinaliza contraste, touch targets, semantics ausentes.
- [`flutter_screen_lock`-style golden tests](https://docs.flutter.dev/testing/overview#golden-tests): render a tela em ambos os brightness, exporta PNG, valida contraste pixel-a-pixel.
- DevTools → Inspector → "Show Guidelines" e "Highlight Repaints" para visualizar a árvore.

## Theming: light & dark

### Dark não é light invertido

Você não pode só trocar cores. Dark exige decisões diferentes:

| Light | Dark |
|---|---|
| Sombras para profundidade | Surfaces mais claros para profundidade (sombras quase não aparecem em dark) |
| Texto preto sobre branco | Texto branco sobre preto: reduzir `fontWeight` em um nível (regular → light) |
| Acentos vibrantes | Dessaturar acentos um pouco (M3 já faz via `inversePrimary`) |
| Branco puro | Nunca preto puro: use `surface` em ~12-18% lightness (M3 default) |

Em dark mode, profundidade vem de **claridade da surface**, não da sombra. M3 entrega isso pronto: `surface < surfaceContainerLow < surfaceContainerHigh < surfaceContainerHighest`. Use direto. Não invente escala paralela.

### Em Flutter, o setup correto

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.light),
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.dark),
  ),
  themeMode: ThemeMode.system,  // segue Settings do device
)
```

`themeMode: ThemeMode.system` é o default certo. Permitir override por tela do app (`themeMode: ThemeMode.dark` no Provider) para casos como "esta tela é sempre dark" (player de vídeo, mapa noturno).

### Hierarquia de tokens

Duas camadas: primitivos (`brandBlue500`) e semânticos (`colorScheme.primary` aponta para `brandBlue500`). Para dark, redefina só a camada semântica via `darkTheme`; primitivos ficam iguais.

Para tokens fora do M3 (success green, warning amber, info cyan, brand-secondary, etc.), `ThemeExtension<SemanticColors>`:

```dart
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({required this.success, required this.warning, required this.info});
  final Color success, warning, info;
  @override SemanticColors copyWith({...}) => SemanticColors(...);
  @override SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) =>
      other is! SemanticColors ? this : SemanticColors(
        success: Color.lerp(success, other.success, t)!,
        warning: Color.lerp(warning, other.warning, t)!,
        info: Color.lerp(info, other.info, t)!,
      );
}
```

Acessar: `Theme.of(context).extension<SemanticColors>()!.success`. Definir versões light e dark separadas, registrar em `extensions:` de cada `ThemeData`.

## Alpha é cheiro de design

Uso pesado de alpha (`Color.fromRGBO(0,0,0,0.6)`, `withOpacity(0.7)`) costuma sinalizar paleta incompleta. Alpha cria contraste imprevisível, custo de performance (composição com camadas abaixo) e inconsistência. Defina cores explícitas de overlay para cada contexto.

Exceções legítimas:
- Focus rings e estados interativos onde o ver-através é necessário.
- `Scrim` em modal backdrops (Material 3 já entrega `colorScheme.scrim` com alpha calibrado).
- Disabled state (M3 sugere 0.38 sobre `onSurface`).

`withOpacity()` foi marcado deprecated em Flutter 3.27 em favor de `withValues(alpha:)` para precisão wide-gamut. Use o novo.

## Material You / dynamic color

No Android 12+, o usuário pode pedir que apps sigam o wallpaper. Em Flutter, isso vem via package [`dynamic_color`](https://pub.dev/packages/dynamic_color):

```dart
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) => MaterialApp(
    theme: ThemeData(colorScheme: lightDynamic ?? fallbackLight),
    darkTheme: ThemeData(colorScheme: darkDynamic ?? fallbackDark),
  ),
)
```

Decisão de marca: brand-strict (sempre minha cor) ou system-respecting (segue wallpaper quando disponível, fallback para minha cor). System-respecting é o caminho mais Android-nativo. Brand-strict é correto para apps de marca forte (Spotify, Instagram).

Se você adota dynamic color, **valide contraste em pelo menos 5 wallpapers diferentes** (verde, vermelho, azul, neutro claro, neutro escuro). M3 garante que os 30 papéis se mantêm coerentes, mas seu `ThemeExtension` custom pode quebrar.

---

**Evitar**: literais `Colors.black` / `Colors.white` no código de UI. `Color(0xFF...)` literal num widget (sempre via `colorScheme`). Pular validação de contraste em dark. Inventar escala de surface paralela aos 5 níveis M3. Hard-code de `seedColor: Colors.deepPurple` (default `flutter create`).
