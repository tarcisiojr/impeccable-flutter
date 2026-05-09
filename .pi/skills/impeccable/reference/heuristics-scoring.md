# Heuristics Scoring Guide (Flutter)

Pontue cada uma das 10 Heurísticas de Nielsen numa escala 0–4. Seja honesto: 4 significa genuinamente excelente, não "bom o suficiente."

Princípios universais. "Check for" reescrito em vocabulário Flutter. Leia [flutter-foundations.md](flutter-foundations.md).

## Heurísticas de Nielsen (10)

### 1. Visibilidade do estado do sistema

Manter usuário informado do que está acontecendo via feedback oportuno e apropriado.

**Check for**:
- Loading indicators em operações async (`CircularProgressIndicator`, skeleton, `LinearProgressIndicator`).
- Confirmação de ações (`SnackBar` no save, no delete).
- Indicadores de progresso em fluxos multi-step (`Stepper`, `LinearProgressIndicator` no top).
- Localização atual em navegação (`NavigationBar.selectedIndex`, `BottomNavigationBar.currentIndex`, breadcrumbs em desktop).
- Validação de form inline (`TextFormField` `errorText`), não só no submit.

**Scoring**:
| Score | Critério |
|---|---|
| 0 | Sem feedback; usuário adivinha o que aconteceu |
| 1 | Feedback raro; maioria das ações sem resposta visível |
| 2 | Parcial; alguns estados comunicados, gaps majores |
| 3 | Bom; maioria das operações dá feedback claro, gaps menores |
| 4 | Excelente; toda ação confirma, progresso sempre visível |

### 2. Match entre sistema e mundo real

Falar a linguagem do usuário. Seguir convenções reais. Informação em ordem natural.

**Check for**:
- Terminologia familiar (sem jargão sem explicação).
- Ordem lógica de informação igual à expectativa do usuário.
- Ícones reconhecíveis (`Icons.shopping_cart`, `Icons.search`; não inventar).
- Linguagem apropriada ao domínio para a audiência alvo.
- Reading flow natural (top-to-bottom, start-to-end com Directionality correto).

**Scoring**:
| Score | Critério |
|---|---|
| 0 | Jargão tech puro, alien para usuários |
| 1 | Mostly confuso; pede expertise para navegar |
| 2 | Misturado; alguma linguagem clara, jargão escapando |
| 3 | Mostly natural; termo ocasional precisa de contexto |
| 4 | Fala a linguagem do usuário fluentemente |

### 3. Controle e liberdade do usuário

Saída clara de estados indesejados sem diálogo extenso.

**Check for**:
- Undo (`SnackBarAction(label: 'Desfazer', ...)`).
- Cancel em forms e modais.
- Navegação clara de volta (`Navigator.pop`, back button do sistema, swipe-to-back no iOS).
- Limpar filtros, busca, seleções facilmente.
- Saída de fluxos longos (`AppBar.leading: IconButton(icon: Icons.close)` em fullscreen modal).
- Predictive back gesture no Android 14+.

**Scoring**:
| Score | Critério |
|---|---|
| 0 | Usuários ficam presos; sem saída sem force-close |
| 1 | Saídas difíceis; precisa achar caminhos obscuros |
| 2 | Algumas saídas; flows main têm escape, edge não |
| 3 | Bom controle; usuário escapa e undo a maioria |
| 4 | Controle total; undo, cancel, back, escape em todo lugar |

### 4. Consistência e padrões

Usuário não deveria se perguntar se palavras/situações/ações diferentes significam o mesmo.

**Check for**:
- Terminologia consistente.
- Mesma ação produz mesmo resultado em todo lugar.
- Convenções de plataforma respeitadas (Material no Android, Cupertino no iOS quando appropriado).
- Consistência visual (cores via `colorScheme`, type via `textTheme`, spacing via tokens).
- Padrões de interação consistentes (mesmo gesto = mesmo comportamento).

**Scoring**:
| Score | Critério |
|---|---|
| 0 | Inconsistente em todo lugar; parece produtos diferentes costurados |
| 1 | Muitas inconsistências; coisas similares parecem/comportam diferente |
| 2 | Parcialmente consistente; flows main matched, detalhes divergem |
| 3 | Mostly consistente; desvio ocasional, nada confuso |
| 4 | Totalmente consistente; sistema coeso, comportamento previsível |

### 5. Prevenção de erro

Melhor que boa mensagem de erro é design que previne o problema.

**Check for**:
- Confirmação antes de destrutivos (delete, overwrite).
- Constraints prevenindo input inválido (`TextInputType.number`, `inputFormatters: [FilteringTextInputFormatter.digitsOnly]`, `DatePicker` em vez de field livre).
- Defaults inteligentes que reduzem erros.
- Labels claros.
- Autosave e draft recovery (`RestorationMixin`, `SharedPreferences` para drafts).

**Scoring**: idêntico ao framework geral.

### 6. Reconhecimento em vez de recall

Minimizar load de memória. Tornar objetos, ações e opções visíveis ou facilmente recuperáveis.

**Check for**:
- Opções visíveis (não enterradas em menus escondidos).
- Ajuda contextual (`Tooltip`, `helperText`, inline hints).
- Items recentes e history.
- Autocomplete e sugestões (`Autocomplete<T>` widget).
- Labels em ícones (não icon-only nav, exceto onde icon é universal: home, busca, perfil).

**Scoring**: idêntico.

### 7. Flexibilidade e eficiência

Aceleradores invisíveis ao novato aceleram interação experiente.

**Check for em mobile**:
- Long-press para ações secundárias.
- Swipe gestures (`Dismissible`) com fallback visível.
- Pull-to-refresh em listas.
- Items recentes/favoritos no topo.
- Bulk actions (`SelectableText`, `MultiSelect` patterns).

**Em desktop/web Flutter**:
- Atalhos de teclado via `Shortcuts` + `Actions`.
- Comandos via `SearchAnchor` (M3 search bar).
- Customização de interface (themes, density).

**Scoring**: idêntico.

### 8. Design estético e minimalista

Interfaces não devem conter informação irrelevante ou raramente necessária.

**Check for**:
- Só informação necessária visível em cada passo.
- Hierarquia visual clara dirigindo atenção.
- Uso proposital de cor e ênfase (`colorScheme.primary` raro).
- Sem clutter decorativo competindo (no `Card` desnecessário, no shadow excessiva).
- Layouts focados.

**Scoring**: idêntico.

### 9. Ajuda usuário a reconhecer, diagnosticar e recuperar de erros

Mensagens de erro em linguagem clara, problema preciso, solução construtiva.

**Check for**:
- Linguagem clara (sem error codes para usuários).
- Identificação específica ("Email falta @" não "Input inválido").
- Sugestões acionáveis de recuperação.
- Erros mostrados perto da fonte (`InputDecoration.errorText`, não diálogo separado).
- Error handling não-bloqueante (não limpa o form, preserva input).

**Scoring**: idêntico.

### 10. Ajuda e documentação

Mesmo que o sistema seja usável sem docs, ajuda deve ser fácil de achar, focada em tarefa, concisa.

**Check for**:
- Help searchable.
- Ajuda contextual (`Tooltip`, `Showcaseview`, inline hints, guided tours).
- Organização por tarefa (não por feature).
- Conteúdo conciso, scannable.
- Acesso fácil sem deixar contexto atual.

**Scoring**: idêntico.

---

## Sumário do score

**Total possível**: 40 pontos (10 heurísticas × 4 max)

| Faixa | Rating | Significado |
|---|---|---|
| 36–40 | Excelente | Polish menor; ship |
| 28–35 | Bom | Resolver áreas fracas, fundação sólida |
| 20–27 | Aceitável | Melhorias significativas antes de usuários ficarem felizes |
| 12–19 | Pobre | Overhaul de UX major; experience core quebrada |
| 0–11 | Crítico | Redesign; inutilizável no estado atual |

---

## Severidade de issue (P0–P3)

Tagueie cada issue encontrado durante scoring com nível de prioridade:

| Prioridade | Nome | Descrição | Ação |
|---|---|---|---|
| **P0** | Blocking | Impede completar tarefa inteiramente | Corrigir imediato; é showstopper |
| **P1** | Major | Causa dificuldade ou confusão significativa | Corrigir antes do release |
| **P2** | Minor | Annoyance, mas há workaround | Corrigir no próximo pass |
| **P3** | Polish | Nice-to-fix, sem impacto real | Corrigir se sobra tempo |

**Tip**: Se incerto entre dois níveis, pergunte: "Usuário contataria suporte por isso?" Se sim, é pelo menos P1.

## P0-P3 mobile-specific examples

- **P0**: app crash em rotação. Backup falha silencioso. Botão de "comprar" sem feedback (usuário compra duas vezes). Login que perde credenciais em background.
- **P1**: ação primária fora do thumb reach. SnackBar duration 1s (some antes de ler). Animation que não respeita `disableAnimationsOf`. Validação de form só no submit.
- **P2**: `IconButton` sem tooltip. `Image.asset` decorativa sem `excludeFromSemantics`. Splash 1.5s onde 800ms cabia.
- **P3**: spacing 14 onde 16 pertencia. Cor de divider ligeiramente fora do scheme. Microcopy "Tudo OK" em vez de "Salvo".
