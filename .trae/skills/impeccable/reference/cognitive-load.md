# Cognitive Load Assessment (Flutter)

Carga cognitiva é o esforço mental total para usar uma interface. Em mobile, o orçamento é menor: uma mão, polegar, três segundos, contexto interrompido. Esse arquivo identifica e resolve sobrecarga.

Princípios universais; exemplos em vocabulário Flutter. Leia [flutter-foundations.md](flutter-foundations.md).

---

## Três tipos de carga cognitiva

### Intrínseca: a tarefa em si

Complexidade inerente ao que o usuário tenta fazer. Você não elimina; estrutura.

**Gerencie via**:
- Quebrar tarefas em passos discretos (`Navigator` em fluxo, ou `Stepper` widget).
- Scaffolding (`InitialValue` em `TextFormField`, defaults sensatos, exemplos).
- Disclosure progressiva: mostrar o necessário agora, esconder o resto (`ExpansionTile`, `BottomSheet` com layers).
- Agrupar decisões relacionadas (form sections com headers visíveis).

### Extrínseca: design ruim

Esforço causado por escolhas pobres. **Elimine sem misericórdia.** É puro desperdício.

**Fontes comuns em Flutter**:
- Navegação confusa que pede mapa mental (drawer com 12 itens sem hierarquia).
- Labels ambíguos que forçam o usuário a adivinhar.
- `Card` em todo lugar competindo por atenção.
- Padrões inconsistentes (botão de "salvar" diferente em cada tela).
- Passos desnecessários entre intenção e resultado (3 taps para uma ação que cabia em 1).

### Germânica: esforço de aprendizado

Esforço gasto construindo entendimento. Esse é *bom*: leva à maestria.

**Suporte via**:
- Disclosure progressiva que revela complexidade gradualmente.
- Padrões consistentes que recompensam aprendizado (botão flutuante sempre faz a mesma classe de ação).
- Feedback que confirma entendimento correto (`SnackBar` "Salvo", animação de check).
- Onboarding que ensina por ação, não por wall of text. `Showcaseview` package destaca elementos durante uso real.

---

## Checklist de carga cognitiva

Avalie a interface contra esses 8 pontos:

- [ ] **Foco único**: o usuário consegue completar a tarefa primária sem distração de elementos competindo?
- [ ] **Chunking**: informação é apresentada em grupos digestíveis (≤4 itens por grupo)?
- [ ] **Agrupamento**: itens relacionados estão visualmente juntos (proximidade, `Card`, `Divider`, fundo compartilhado)?
- [ ] **Hierarquia visual**: é imediatamente claro o que é mais importante na tela?
- [ ] **Uma coisa por vez**: o usuário pode focar numa única decisão antes de ir à próxima?
- [ ] **Mínimo de escolhas**: decisões simplificadas (≤4 opções visíveis em qualquer ponto)?
- [ ] **Memória de trabalho**: o usuário precisa lembrar info de uma tela anterior para agir nesta?
- [ ] **Disclosure progressiva**: complexidade revelada só quando o usuário precisa?

**Pontuação**: conte os falhos. 0–1 = baixa carga (bom). 2–3 = moderada (resolver logo). 4+ = alta (correção crítica).

---

## A regra da memória de trabalho

**Humanos seguram ≤4 itens em working memory ao mesmo tempo** (Miller's Law revisado por Cowan, 2001). Em mobile, com interrupções constantes, esse número cai para ~3.

Em qualquer ponto de decisão, conte opções/ações/informações que o usuário precisa considerar simultaneamente:

- **≤3 itens**: confortável.
- **4 itens**: limite OK.
- **5–7**: empurrando o limite; considere agrupamento ou disclosure.
- **8+**: sobrecarga; usuário pula, mistapeia, abandona.

**Aplicações práticas em Flutter**:
- `BottomNavigationBar` / `NavigationBar`: ≤5 destinos top-level. Apple HIG diz 5 max; Material flexibiliza, mas a memória não.
- `TabBar` em sub-página: ≤4 tabs visíveis sem scroll. Mais que isso vira `TabBar(isScrollable: true)` e perde discoverability.
- `Form` sections: ≤4 fields visíveis por grupo antes de quebra visual (`Divider`, header).
- Botões de ação na `AppBar`: 1 primário (action button), 1-2 secundários (`IconButton`), resto em `PopupMenuButton` ou `MenuAnchor`.
- `Drawer` items: ≤7 no total; agrupar por categoria com `ListTile.subtitle` ou seções.
- Tiers de pricing: ≤3 (mais causa paralisia de análise).

---

## Violações comuns em Flutter

### 1. The wall of options
**Problema**: drawer com 15 destinos no mesmo nível. `BottomSheet` com 12 ações.
**Fix**: agrupar em categorias com `ExpansionTile` ou seções `ListTile.title` em bold + `subtitle`. Destacar recomendado com `selected: true` ou cor.

### 2. The memory bridge
**Problema**: usuário precisa lembrar info da tela 1 (ex: ID de pedido) para usar na tela 3.
**Fix**: passe os dados via `Navigator.push` arguments ou state management; mostre breadcrumb ou pill no topo da tela 3 com o contexto.

### 3. The hidden navigation
**Problema**: usuário precisa construir mapa mental de onde tudo está. Drawer escondido sem indicador de "você está aqui".
**Fix**: sempre mostrar localização atual: `selected: true` no item de `BottomNavigationBar`/`NavigationRail`/`NavigationDrawer`. Em fluxos multi-step, `Stepper` ou `LinearProgressIndicator` com label "Passo 2 de 4".

### 4. The jargon barrier
**Problema**: linguagem técnica força tradução mental. App de finanças que usa "ETF" sem explicar; app de saúde que usa "BMI" sem rótulo.
**Fix**: linguagem clara. Se termos do domínio são inevitáveis, define inline (`tooltip:`, helper text via `InputDecoration.helperText`).

### 5. The visual noise floor
**Problema**: todo widget tem o mesmo peso visual; nada se destaca.
**Fix**: hierarquia clara via `TextTheme` + cores do scheme + spacing. Um elemento primário, 2-3 secundários, resto muted (`onSurfaceVariant`).

### 6. The inconsistent pattern
**Problema**: ações similares funcionam diferente em lugares diferentes. "Salvar" é botão na tela A, é check no AppBar na tela B, é gesto swipe na tela C.
**Fix**: padronize. Defina o padrão no design system: "save sempre é botão `FilledButton` no fim da tela; em forms inline, é check `IconButton` no AppBar".

### 7. The multi-task demand
**Problema**: interface pede processar múltiplos inputs simultâneos (ler + decidir + navegar + manter contexto).
**Fix**: sequencie passos. Use `Stepper` ou `PageView` com indicador. Uma decisão por vez.

### 8. The context switch
**Problema**: usuário precisa pular entre telas/tabs/modais para juntar info para uma única decisão.
**Fix**: co-localize informação necessária para cada decisão. `BottomSheet` que carrega dados relevantes mantendo o contexto da tela. Reduza vai-e-volta.

### 9. (Mobile-specific) The thumb-reach assumption
**Problema**: ações primárias no topo da tela, fora do alcance do polegar quando o phone tem 6.7"+.
**Fix**: ações primárias na metade inferior. `FloatingActionButton` é canônico. Para confirmar/avançar, botão fixo no bottom com `BottomAppBar` ou `Padding` + `SafeArea`.

### 10. (Mobile-specific) The no-state-on-return
**Problema**: usuário sai do app por uma notificação, volta 30 segundos depois, fluxo perdido. Form em branco, scroll no topo, tab em outro.
**Fix**: state restoration. Use `RestorationMixin`, `RestorableProperty`. `MaterialApp(restorationScopeId: 'app')`. Persista drafts em `SharedPreferences` ou `Hive`.
