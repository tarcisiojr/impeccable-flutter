# Typography (Flutter)

Leia [flutter-foundations.md](flutter-foundations.md) primeiro. Procedimento de seleção de fonte e lista reflex-reject vivem em [brand.md](brand.md).

## Princípios clássicos, em vocabulário Flutter

### Ritmo vertical

`TextStyle.height` é a base de todo espaçamento vertical do app. Se `bodyLarge` tem `fontSize: 16` com `height: 1.5` (linha de 24 lógicos), seus tokens de spacing devem ser múltiplos de 24. Texto e espaço compartilham fundamento matemático e o app inteiro respira no mesmo ritmo.

Em Flutter, isso vira `EdgeInsets` semânticos num `ThemeExtension<SpacingTokens>`:

```dart
@immutable
class SpacingTokens extends ThemeExtension<SpacingTokens> {
  const SpacingTokens({this.xs = 4, this.sm = 8, this.md = 16, this.lg = 24, this.xl = 32});
  final double xs, sm, md, lg, xl;
  @override SpacingTokens copyWith(...) => SpacingTokens(...);
  @override SpacingTokens lerp(...) => this;
}
```

Acessar via `Theme.of(context).extension<SpacingTokens>()!.lg`.

### Escala modular & hierarquia

O erro comum: tamanhos demais e próximos demais (14, 15, 16, 18). Hierarquia muddy.

**Material 3 já entrega 15 papéis prontos no `TextTheme`.** Use-os. Não invente paralelo.

| Papel M3 | Tamanho default | Quando usar |
|---|---|---|
| `displayLarge` / `displayMedium` / `displaySmall` | 57 / 45 / 36 | Hero de brand surface, splash, marketing screen |
| `headlineLarge` / `headlineMedium` / `headlineSmall` | 32 / 28 / 24 | Títulos de tela, headers de seção |
| `titleLarge` / `titleMedium` / `titleSmall` | 22 / 16 / 14 | Títulos de card, AppBar title, dialog title |
| `bodyLarge` / `bodyMedium` / `bodySmall` | 16 / 14 / 12 | Conteúdo. `bodyLarge` é o default de `Text` |
| `labelLarge` / `labelMedium` / `labelSmall` | 14 / 12 / 11 | Botões, chips, captions, metadata |

Razões M3 entre níveis adjacentes ficam entre 1.125 e 1.27. Coerentes. Quando você customiza, mantenha 1.2-1.333 entre vizinhos. Não menos que 1.125 (fica flat e a hierarquia some).

Acessar:

```dart
Text('Olá', style: Theme.of(context).textTheme.headlineMedium);
```

Nunca `TextStyle(fontSize: 28)` cru. Mata Dynamic Type, mata dark mode tipográfico (peso e cor vêm do tema), e desconecta do scale do app.

### Legibilidade & medida

Mobile não tem `ch` unit. Aproxime: para fonte de 16, 50 a 75 caracteres por linha cabem em 280 a 420 lógicos. Acima disso (tablets, desktop), use `ConstrainedBox(maxWidth: 600)` para não passar de ~75 chars em prosa.

`TextStyle.height` escala inversamente ao comprimento da linha. Coluna estreita (mobile portrait): 1.3 a 1.4. Coluna larga (tablet, desktop, leitor longo): 1.5 a 1.6. Material 3 default em `bodyLarge` é 1.5.

**Não óbvio**: texto claro em fundo escuro precisa compensar em três eixos, não um. Aumentar `height` em 0.05-0.1, adicionar `letterSpacing` 0.01-0.02, e opcionalmente subir o peso em um nível (regular → medium). Peso percebido cai nos três eixos. Compense nos três.

**Ritmo de parágrafo**: ou espaço entre parágrafos (`Padding` com `vertical: spacing.md` entre) OU indent de primeira linha (raro em mobile, pede `RichText` com `WidgetSpan`). Nunca os dois. Digital quase sempre quer espaço.

## Fonte: como carregar em Flutter

Duas vias razoáveis:

### `google_fonts` package

Bom para protótipo e marcas que aceitam dependência Google. Em produção:

```dart
GoogleFonts.config.allowRuntimeFetching = false;  // não baixa em runtime
// e copie os .ttf para assets/google_fonts/, declare no pubspec
```

Razão: runtime fetching depende da rede no primeiro launch. Bundlado garante entrega.

### Bundle direto

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

```dart
// theme.dart
ThemeData(textTheme: GoogleFonts.interTextTheme().apply(fontFamily: 'Inter'));
// ou cru:
ThemeData(textTheme: const TextTheme(/* todos os 15 papéis */));
```

Para marca séria, bundle. Licença na sua mão, controle de qual subset (latin-ext etc), suporte a `axes` de variable font.

### Variable fonts

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/InterVariable.ttf
```

```dart
TextStyle(
  fontFamily: 'Inter',
  fontVariations: [const FontVariation('wght', 480)],  // peso 480 fracionário
)
```

Um arquivo variable costuma ser menor que três pesos estáticos. `wght`, `wdth`, `slnt`, `opsz` são os eixos comuns. Se sua fonte tem `opsz`, `fontFeatures: [FontFeature.enable('opsz')]` ou `fontVariations: [FontVariation('opsz', fontSize)]`.

## Anti-reflexos a defender

- Brief técnico/utilitário NÃO precisa de serif "para calor". A maioria das ferramentas tech deve parecer ferramenta tech.
- Brief editorial/premium NÃO precisa do mesmo serif expressivo que todo mundo está usando agora. Premium pode ser Swiss-modern, neo-grotesque, mono literal, sans humanist quieta.
- Produto infantil NÃO precisa de display arredondado. Livros infantis usam type real.
- Brief "moderno" NÃO precisa de geométrico sans. A coisa mais moderna que você pode fazer é não usar a fonte que todo mundo usa.

**System fonts são subestimadas em Flutter**: deixar `fontFamily` ausente em `TextStyle` cai pra SF Pro no iOS, Roboto no Android, Segoe UI no Windows. Carrega instantâneo, é altamente legível, parece nativo. Considere para apps onde performance > personalidade. Para brand, raramente é a escolha; para product, costuma ser certa.

## Pairing

**Verdade não-óbvia**: você quase sempre não precisa de uma segunda fonte. Uma família bem escolhida em múltiplos pesos cria hierarquia mais limpa que duas tipografias competindo. Adicione uma segunda só quando precisa de contraste genuíno (display + body, por exemplo).

Quando pareiar, contraste em múltiplos eixos:

- Serif + Sans (estrutura)
- Geométrica + Humanista (personalidade)
- Condensed display + Wide body (proporção)

**Nunca pareie fontes parecidas mas diferentes** (dois geométricos sans). Cria tensão visual sem hierarquia clara.

Em Flutter, mistura é via dois `TextStyle` distintos no mesmo `TextTheme`:

```dart
textTheme: TextTheme(
  displayLarge: GoogleFonts.fraunces(fontWeight: FontWeight.w900),  // serif para hero
  bodyLarge: GoogleFonts.inter(),                                    // sans para conteúdo
)
```

## Dynamic Type, escala acessível

`MediaQuery.textScalerOf(context)` reflete a configuração de tamanho de texto do sistema. Em iOS, Settings → Display & Brightness → Text Size; em Android, Settings → Display → Font size. O usuário pode ir até 200%+ em iOS, 130% típico em Android.

**Nunca passe `textScaler: TextScaler.noScaling` "porque quebra o layout".** Isso quebra acessibilidade hard. Se a tela quebra a 130%, a tela está errada. Use `Flexible`, `Wrap`, `FittedBox` (com cuidado), ou `LayoutBuilder` para lidar.

Para medir altura de texto em código (raro):

```dart
final scale = MediaQuery.textScalerOf(context).scale(16);
// scale agora é o tamanho efetivo do "16" para o usuário atual
```

## OpenType features

A maioria dos devs Flutter não sabe que existe. Use para polish:

```dart
TextStyle(
  fontFeatures: const [
    FontFeature.tabularFigures(),           // dígitos do mesmo width, para listas/tabelas
    FontFeature.enable('frac'),             // frações reais (1/2)
    FontFeature.enable('smcp'),             // small caps
    FontFeature.disable('liga'),            // tira ligaduras (em código, costuma ser certo)
    FontFeature.enable('ss01'),             // stylistic set 1 (varia por fonte)
  ],
)
```

Tabular figures é a feature mais útil em product. Toda lista/tabela com números deveria usar. Sem isso, "1.234.567" e "9.876.543" desalinham.

Verifique features da sua fonte em [Wakamai Fondue](https://wakamaifondue.com/).

## Polish de renderização

```dart
Text(
  'Headline com break ruim',
  style: Theme.of(context).textTheme.headlineMedium,
  textHeightBehavior: const TextHeightBehavior(
    applyHeightToFirstAscent: false,   // remove leading da primeira linha
    applyHeightToLastDescent: false,   // remove leading da última
  ),
)
```

`textHeightBehavior` corrige o leading "extra" que `height` adiciona no topo e na base. Em headers grandes, isso muda o alinhamento óptico inteiro.

Não há `text-wrap: balance` ou `text-wrap: pretty` em Flutter ainda. Quebras ruins em hero exigem `\n` manual ou `Wrap` com `runSpacing`. Vale uma pesquisa por issue do `flutter/flutter` antes de assumir que falta para sempre.

**Tracking ALL-CAPS**: maiúsculas ficam apertadas no spacing default. Adicione 5-12% letterSpacing em labels curtos e headings small all-caps.

```dart
TextStyle(letterSpacing: 0.08 * fontSize)  // ~8%
```

## Arquitetura do system tipográfico

Tokens semânticos no `TextTheme` (`bodyLarge`, `titleMedium`), nunca por valor (`text16Regular`, `text14Bold`). Stack de fontes, escala de tamanho, pesos, line-heights, tracking entram no token.

Para tokens fora do M3 (caption-uppercase, button-loud, code-inline), use `ThemeExtension<TextTokens>`:

```dart
@immutable
class TextTokens extends ThemeExtension<TextTokens> {
  const TextTokens({required this.code, required this.captionAllCaps});
  final TextStyle code;
  final TextStyle captionAllCaps;
  // copyWith, lerp...
}
```

## Considerações de acessibilidade

Para além de contraste (coberto em [color-and-contrast.md](color-and-contrast.md)):

- **Honrar `textScaler` em todas as telas.** Nada quebra acessibilidade Flutter mais que `MediaQueryData.copyWith(textScaler: TextScaler.noScaling)`.
- **`Semantics(textField: true, label: ...)` em fields customizados** que não sejam `TextField` Material padrão.
- **Body 16 mínimo.** `bodyLarge` M3 default é 16. Não desça `bodyMedium` para caption. Use `bodySmall` ou `labelSmall`.
- **Touch target 48dp em todo link/botão de texto.** Padding ou `MaterialTapTargetSize.padded` no theme.
- **`semanticLabel`** em `RichText` complexo, porque o screen reader lê os spans em sequência sem contexto.

---

**Evitar**: mais que 2-3 famílias por projeto. Pular declaração no pubspec e contar com runtime fetching em produção. Hard-code de `fontSize` fora do `TextTheme`. Display fonts em body. Disable de `textScaler`.
