# UX Writing (Flutter)

Universal por natureza, com itens mobile-specific (notificações push, SnackBar, brevidade no widget). Leia [flutter-foundations.md](flutter-foundations.md).

## O problema do label de botão

**Nunca use "OK", "Submit", "Sim/Não".** Preguiçoso e ambíguo. Use verbo + objeto específico:

| Ruim | Bom | Por quê |
|---|---|---|
| OK | Salvar alterações | Diz o que vai acontecer |
| Enviar | Criar conta | Foco no resultado |
| Sim | Excluir mensagem | Confirma a ação |
| Cancelar | Continuar editando | Esclarece o que "cancelar" significa |
| Toque aqui | Baixar PDF | Descreve o destino |

Em Flutter, isso vai em `child: Text(...)` de `FilledButton`, `OutlinedButton`, `TextButton`. `child:` literal "OK" é cheiro. Vai diretamente para `SnackBarAction.label` também.

**Para ações destrutivas**, nomeie a destruição:
- "Excluir" não "Remover" (excluir é permanente, remover sugere recuperável).
- "Excluir 5 itens" não "Excluir selecionados" (mostre a contagem).

## Mensagens de erro: a fórmula

Toda mensagem de erro responde: (1) O que aconteceu? (2) Por quê? (3) Como corrigir? Exemplo: "Endereço de email inválido. Inclua um @." em vez de "Input inválido".

### Templates

| Situação | Template |
|---|---|
| **Erro de formato** | "[Campo] precisa ser [formato]. Exemplo: [exemplo]" |
| **Required ausente** | "Por favor, informe [o que falta]" |
| **Permissão negada** | "Você não tem acesso a [coisa]. [O que fazer em vez]" |
| **Erro de rede** | "Não conseguimos chegar em [coisa]. Verifique a conexão e [ação]." |
| **Erro de servidor** | "Algo deu errado do nosso lado. Estamos investigando. [Alternativa]" |

### Onde isso vive em Flutter

- Erro de field: `InputDecoration(errorText: ...)` ou `validator:` que retorna string.
- Erro de tela: `SnackBar` com `behavior: SnackBarBehavior.floating` e `action:` para retry.
- Erro full-screen (sem internet, conta bloqueada): `Scaffold` com `Column` centralizada, ícone, mensagem, botão de ação.
- Erro inline em diálogo: `AlertDialog` com `content:` claro, e `actions:` específicos ("Tentar novamente" / "Cancelar"), não "OK"/"Cancel".

### Não culpe o usuário

"Por favor, informe data em formato DD/MM/AAAA" em vez de "Você inseriu uma data inválida". Mude o foco do "você errou" para "esse formato funciona".

## Empty states são oportunidades

Empty states são momento de onboarding: (1) Reconheça brevemente, (2) Explique o valor de preencher, (3) Forneça ação clara. "Nenhum projeto ainda. Crie o primeiro para começar." em vez de só "Sem itens".

Em Flutter, padrão para empty state:

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  // ...
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Voz vs tom

**Voz** é a personalidade da marca, consistente em todo lugar.
**Tom** adapta ao momento.

| Momento | Tom | Exemplo Flutter |
|---|---|---|
| Sucesso | Celebratório, breve | `SnackBar('Salvo!')` ou `SnackBar('Pedido confirmado')` |
| Erro | Empático, útil | `SnackBar('Não funcionou. Tente novamente em alguns segundos.')` com `action: 'Tentar agora'` |
| Loading | Reassuring | `Text('Salvando seu rascunho…')` em vez de só `CircularProgressIndicator` |
| Confirmação destrutiva | Sério, claro | `AlertDialog(title: 'Excluir este projeto?', content: 'Não pode ser desfeito.')` |

**Nunca use humor para erros.** Usuário já está frustrado. Seja útil, não fofo.

## Mobile-specific: brevidade

Mobile tem espaço apertado. Cortar palavras sem perder claridade:

| Verbose (web-OK) | Mobile-tight |
|---|---|
| "Por favor, insira seu endereço de email" | "Email" (no `labelText`) + "jane@example.com" (no `hintText`) |
| "Sua mensagem foi enviada com sucesso" | "Mensagem enviada" |
| "Não foi possível conectar ao servidor" | "Sem conexão" |
| "Excluir este item permanentemente?" | "Excluir item?" + "Não pode desfazer." (subtitle) |

Não corte tanto a ponto de virar críptico. "OK" → "Salvar" é correção; "Salvar" → "Save" não é.

### SnackBar específico

`SnackBar` tem ~80 chars úteis em portrait padrão. Use:
- 1 linha quando possível.
- `action:` como verbo curto (`'Desfazer'`, `'Tentar novamente'`, `'Ver'`).
- `duration: const Duration(seconds: 4)` é o default certo. 6s para mensagens com action.
- `behavior: SnackBarBehavior.floating` em apps modernos M3.

### Push notifications

Push tem ainda menos espaço, e compete com tudo. Regras:
- Title: ≤30 chars, conteúdo, não app name.
- Body: ≤120 chars, com a info que vale a vibração no bolso.
- Não notificar por notificar. Cada push gasta confiança.

```
RUIM: "Você tem 1 notificação"
BOM:  "Mariana respondeu sua mensagem"

RUIM: "Lembrete"
BOM:  "Reunião com time em 15 min: Sala Carbon"
```

## Acessibilidade na escrita

**Texto de link** precisa de significado standalone: "Ver planos" em vez de "Toque aqui". Em Flutter, `InkWell.semanticsLabel` ou `Semantics(label: 'Ver planos')` envolvendo o widget interativo.

**`semanticLabel:`** em `Image`/`Icon` informativo: descreve a informação, não a imagem. "Receita aumentou 40% no Q4" em vez de "Gráfico". Use `semanticLabel: ''` ou `excludeFromSemantics: true` para imagens decorativas.

**`tooltip:`** em todo `IconButton`. Vira label de a11y automaticamente. Sem isso, screen reader lê "botão" sem contexto.

## Escrevendo para tradução

### Plano para expansão

Texto alemão é ~30% mais longo que inglês. Aloque espaço:

| Idioma | Expansão |
|---|---|
| Alemão | +30% |
| Francês | +20% |
| Finlandês | +30-40% |
| Português (BR) | +15-25% |
| Chinês | -30% (menos chars, mesmo width) |
| Árabe / Hebraico | similar, mas RTL |

### Em Flutter

Use `flutter_localizations` + `intl` package. Strings em `.arb` files. Para inserção de números/datas, **use placeholders nomeados** em vez de concatenação:

```json
// app_pt.arb
"unreadMessages": "Você tem {count, plural, one{# mensagem} other{# mensagens}} não lidas"

// uso:
Text(AppLocalizations.of(context)!.unreadMessages(messageCount))
```

`{count, plural, ...}` cobre línguas com plurais complexos (russo, polonês). Não tente plural manual em Dart.

### RTL

Sempre use `Directionality` (que `MaterialApp` injeta), `EdgeInsetsDirectional` (em vez de `EdgeInsets.fromLTRB`), `AlignmentDirectional`, `start`/`end` em vez de `left`/`right`.

```dart
// RUIM: quebra em árabe
Padding(padding: EdgeInsets.only(left: 16))

// BOM
Padding(padding: EdgeInsetsDirectional.only(start: 16))
```

## Consistência: o problema da terminologia

Pegue um termo e fique com ele:

| Inconsistente | Consistente |
|---|---|
| Excluir / Remover / Apagar / Lixeira | Excluir |
| Configurações / Preferências / Opções | Configurações |
| Entrar / Login / Acessar | Entrar |
| Criar / Adicionar / Novo | Criar |

Construa um glossário e force. Variedade cria confusão.

## Evite copy redundante

Se o heading explica, o intro é redundante. Se o botão é claro, não explique de novo. Diga uma vez, diga bem.

```
// RUIM
Card(
  child: Column(children: [
    Text('Backup automático'),
    Text('Configure backup automático para seus dados'),
    Switch(value: enabled, onChanged: ...),
  ]),
)

// BOM
SwitchListTile(
  title: Text('Backup automático'),
  subtitle: Text('Diário, em Wi-Fi'),     // info NOVA, não restate
  value: enabled,
  onChanged: ...,
)
```

## Loading states

Seja específico: "Salvando seu rascunho…" em vez de "Carregando…". Para esperas longas, set expectativa: "Costuma levar 30s" ou mostre progresso real.

## Diálogos de confirmação: use raramente

A maioria de diálogos de confirmação são falhas de design; considere undo. Quando deve confirmar: nomeie a ação, explique consequências, use labels específicos:

```dart
AlertDialog(
  title: const Text('Excluir projeto?'),
  content: const Text('Esta ação não pode ser desfeita. Todos os arquivos serão removidos permanentemente.'),
  actions: [
    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Manter projeto')),
    FilledButton(
      onPressed: () => Navigator.pop(context, true),
      style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
      child: const Text('Excluir projeto'),
    ),
  ],
)
```

Não "Sim"/"Não". Não "OK"/"Cancel".

## Form instructions

Mostre formato com `hintText`, não com instructions. Para fields não-óbvios, `helperText` explica o porquê.

```dart
TextFormField(
  decoration: const InputDecoration(
    labelText: 'CPF',
    hintText: '000.000.000-00',
    helperText: 'Usado apenas para verificação de identidade',
  ),
)
```

---

**Evitar**: jargão sem explicação. Culpar usuário ("Você errou" → "Este campo é obrigatório"). Erros vagos ("Algo deu errado"). Variar terminologia por variar. Humor em erros. "OK"/"Cancel" em diálogos. Push notifications genéricos. Concatenação de strings em vez de `.arb` placeholders.
