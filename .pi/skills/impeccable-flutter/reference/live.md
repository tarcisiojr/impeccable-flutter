# Live (Flutter)

Modo iterativo interativo. O equivalente conceitual do `live` web (selecionar elemento → pedir variante → IA gera → HMR aplica), em Flutter mobile/desktop.

**Status**: MVP. Versão 1 deste documento descreve o caminho que funciona hoje (edit + hot reload manual). Versão 2 ganha overlay de seleção via VM Service e ciclo automático. Veja seção **Roadmap** ao final.

Leia [flutter-foundations.md](flutter-foundations.md) primeiro.

## Pré-requisitos

- `pubspec.yaml` na raiz.
- App roda com `flutter run` num device ou emulador.
- PRODUCT.md e DESIGN.md carregados (loader rodou).
- `dart format` configurado no editor (variantes são re-formatadas).

## MVP (v0.1): edit + hot reload + manual select

### Como funciona

1. Você abre o app no device alvo via `flutter run -d <device>`.
2. Você navega até a tela que quer iterar.
3. Você diz ao agente: "iterar no `OnboardingHero` em `lib/screens/onboarding.dart`, fazer 3 variantes mais bold".
4. Agente carrega o snippet do widget, gera 3 variantes (escritas a comentários ou branches).
5. Agente edita o arquivo, salva. Hot reload (`r` no terminal) aplica.
6. Você vê no device, escolhe uma, descarta as outras.

Sem overlay, sem VM Service no MVP. Ciclo manual mas funcional.

### Workflow do agente

#### Step 1: Confirmar contexto

```
ATTRS:
- Target widget: <ClassName ou path:line>
- Direction: <bolder | quieter | colorize | typeset | layout | animate | delight>
- Number of variants: 3 (default; user pode pedir 5 ou 1)
- Constraint: <opcional, ex "manter dimensões", "só cor", "apenas tipo">
```

Se o user não foi específico, pergunte. Variantes sem alvo claro são gambiarra.

#### Step 2: Ler o widget atual

```bash
# Localize o widget
grep -rn "class OnboardingHero" lib/
# Leia o arquivo
```

Capture:
- Imports relevantes.
- ThemeData/ColorScheme/TextTheme em uso (`Theme.of(context).colorScheme.primary`).
- Widget tree atual.
- Comprimento (variantes muito longas viram dor de revisar).

#### Step 3: Gerar 3 variantes

Cada variante tem:
- Nome (`_VariantA`, `_VariantB`, `_VariantC`) ou descrição em comentário.
- Mudança específica e nomeada (não "melhorado").
- Mesma assinatura pública do widget original (mesmos parâmetros, mesmo retorno).

Estrutura recomendada: as 3 variantes ficam ABAIXO do widget original, comentadas ou em factories que o usuário troca o `runtimeType` que usa.

```dart
// Original (em uso)
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({super.key});
  @override
  Widget build(BuildContext context) { /* ... */ }
}

// ---- IMPECCABLE LIVE VARIANTS ----
// Para testar uma variante, troque OnboardingHero por _OnboardingHeroBolder no parent.

class _OnboardingHeroBolder extends StatelessWidget {
  // bolder: tipografia displayLarge em vez de headlineLarge,
  // peso w900, fundo primaryContainer.
  const _OnboardingHeroBolder();
  @override
  Widget build(BuildContext context) { /* ... */ }
}

class _OnboardingHeroQuieter extends StatelessWidget { /* ... */ }
class _OnboardingHeroAsymmetric extends StatelessWidget { /* ... */ }
```

#### Step 4: Salvar + hot reload

Edite o arquivo. Diga ao usuário:

> Variantes A/B/C escritas em `lib/screens/onboarding.dart`. No terminal do `flutter run`, pressione `r` para hot reload. Para testar uma, troque `OnboardingHero()` por `_OnboardingHeroBolder()` no parent (linha 47).

Se o user usa flag/runtime selector (raro mas robusto), pode ser:

```dart
// no parent
const variant = String.fromEnvironment('VARIANT', defaultValue: 'a');
final hero = switch (variant) {
  'b' => const _OnboardingHeroQuieter(),
  'c' => const _OnboardingHeroAsymmetric(),
  _ => const OnboardingHero(),
};
```

E o usuário roda `flutter run --dart-define=VARIANT=b`.

#### Step 5: Aceitar / descartar

Quando o usuário escolhe:
- Substitua o widget original pelo conteúdo da variante escolhida.
- Remova as variantes não escolhidas (limpe o bloco `// ---- IMPECCABLE LIVE VARIANTS ----`).
- Rode `dart format` no arquivo.
- Confirme: "Variante B aplicada como `OnboardingHero`. Variantes A e C removidas."

Se o usuário pede mais variantes, recomece com a nova como base.

### Restrições do MVP

- **Não há seleção visual** no app. Usuário precisa nomear o widget alvo.
- **Não há ciclo automático**: aceitar/descartar é manual.
- **Variantes são source-level**: precisa hot reload manual (`r`) ou hot restart (`R`) se mudou state.
- **Multi-screen variants** (mesma variante aplicada a múltiplos widgets) não tem suporte; faça um por vez.

Para casos onde MVP não basta (iterar muito rápido, comparar lado a lado), use [`widgetbook`](https://pub.dev/packages/widgetbook): catalog de variantes que roda paralelo ao app principal. Não é live mode mas resolve metade do problema.

## Roadmap (v0.2 e além)

Funcional planejado, ainda não implementado. Quando o pacote `impeccable_flutter_live` existir:

```dart
// dev_dependencies em pubspec.yaml
dev_dependencies:
  impeccable_flutter_live: ^0.2.0
```

```dart
// main.dart, em modo dev
void main() {
  runApp(kDebugMode
    ? const ImpeccableLiveOverlay(child: MyApp())
    : const MyApp());
}
```

O overlay registra:
- Long-press num widget → captura `runtimeType` + `_widgetSourceLocation` (via `package:flutter/foundation.dart` debug info).
- Envia para servidor local impeccable rodando.
- Servidor expõe HTTP endpoint que o agente CLI poll.
- Agente recebe evento, gera variantes, edita source, hot reload aplica via VM Service.

**Tech stack planejado para v0.2**:
- Servidor local: `dart:io` HTTP server, SSE para polling.
- Comunicação app↔server: `dart:io` HttpClient com auth token.
- VM Service via `vm_service` package para hot reload programático.
- Detecção de source location: `WidgetInspectorService.instance.getSelectedWidget()` (já disponível em debug builds).

**Decisões pendentes**:
- Como lidar com state ao trocar variantes (hot reload preserva, hot restart limpa).
- Como testar variantes em ambos light/dark sem rebuild.
- Como persistir "variante A foi aceita" no journal (similar à durável journal do live web).
- Suporte a desktop Flutter (deve funcionar igual mobile, mas não testado).

Veja `FLUTTER-PORT.md` na raiz do repo para status atual.

## Anti-patterns

Mesmo no MVP manual:

- **Variantes que mudam contrato público**: agente troca `OnboardingHero({super.key})` por `OnboardingHero({super.key, required Color tint})`. Quebra o callsite. Variantes mantêm assinatura.
- **Variantes que misturam direções**: "bolder + quieter + adicionar Hero". Gera ruído. Uma direção por sweep.
- **Variantes longas**: mais de ~80 linhas cada, fica impossível revisar. Decomponha o widget primeiro via `extract`, depois itera no sub-widget.
- **Sem `dart format` no fim**: variantes escritas em formatação inconsistente confundem o diff.
- **Agente que não lê DESIGN.md**: sugere cor que não está no `colorScheme`. Sempre cite `Theme.of(context).colorScheme.X` na variante.

## Verificar

Após aceitar uma variante:
- `dart analyze` passa.
- `flutter run` continua funcionando (sem erros de compilação).
- Widget renderiza no device alvo.
- Hot reload (`r`) reflete a mudança imediato.
- Se o user pediu uma direção específica (bolder), a variante final realmente cumpre.

Após o ciclo, hand off para `/impeccable-flutter polish` para o pass final.
