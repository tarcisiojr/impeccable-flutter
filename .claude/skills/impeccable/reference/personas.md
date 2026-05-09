# Persona-Based Design Testing (Flutter)

Testar a interface pelos olhos de 6 arquétipos de usuário. Cada persona expõe modos de falha que uma única perspectiva de "design director" perde. Em mobile, o **Distracted Mobile User** sai de "secundário" para **primário**; quase todo app Flutter atende ele.

**Como usar**: selecione 2–3 personas mais relevantes para a interface. Caminhe pela ação primária como cada persona. Reporte red flags específicos, não preocupações genéricas.

---

## 1. Distracted Mobile User: "Casey" (PRIMARY em Flutter)

**Profile**: Phone uma mão, em movimento. Interrompido frequentemente. Talvez em conexão lenta.

**Behaviors**:
- Polegar único; prefere ações na metade inferior da tela.
- Interrompido no meio do fluxo, retorna depois.
- Troca entre apps frequentemente (notificação, mensagem, voltar).
- Atenção limitada e baixa paciência.
- Tipa o mínimo possível, prefere taps e seleções.

**Test questions**:
- Ações primárias estão na thumb zone (metade inferior)?
- State é preservado se sai e volta? (`RestorationMixin`?)
- Funciona em conexão lenta? (cached_network_image, optimistic UI?)
- Forms usam autocomplete, smart defaults, e `TextInputType` específico (`emailAddress`, `phone`, `number`)?
- Touch targets ≥48dp?
- O app respeita `MediaQuery.textScaler` em 130%? 200%?

**Red flags** (reporte específico):
- Ações primárias no topo, fora do polegar (botão "Continuar" no `AppBar`).
- Sem persistência de state; progresso perdido em background/foreground.
- Inputs grandes de texto onde seleção (chip, dropdown) resolveria.
- Assets pesados em cada tela (sem lazy load).
- Touch targets minúsculos ou colados.
- `TextField` sem `keyboardType:` correto (teclado padrão para email faz o usuário trocar de teclado manualmente).

---

## 2. Low-End Android: "Diego" (mobile-specific)

**Profile**: Moto G de 4 anos, RAM apertada, CPU mediana. Conexão 4G ou 3G. Bateria que dura 3 horas.

**Behaviors**:
- Reage mal a animações pesadas (jank visível).
- Perde paciência em loading >2s.
- Bateria critica em viagem; toda animação custa.
- Usuário típico de mercado emergente; representa uma fatia enorme da base global Flutter.

**Test questions**:
- O app rode 60fps no `flutter run --profile` em device baixo custo?
- App size <30MB? (Devices baratos têm 16-32GB total.)
- Imagens otimizadas via `cacheWidth`/`cacheHeight`?
- `RepaintBoundary` em listas longas?
- `const` constructors em todo widget que pode?
- `BackdropFilter` confinado a áreas pequenas (não `BackdropFilter` em fullscreen)?
- Initial route renderiza em <2s (`flutter run --trace-startup`)?

**Red flags**:
- Splash screen >2s.
- Listas com `Image.network` cru (sem cache, sem cacheWidth).
- `BackdropFilter` em tela inteira.
- Widget sem `const` que faz rebuild a cada `setState`.
- `StatefulWidget` que reconstrói toda a árvore por causa de uma seta animada.
- App que consome >150MB de RAM em uso normal.
- Animation que não dropa para `Duration.zero` em `disableAnimationsOf`.

---

## 3. Accessibility-Dependent: "Sam"

**Profile**: TalkBack (Android) ou VoiceOver (iOS), navegação por gesto/swipe. Pode ter low vision, motor impairment, ou diferenças cognitivas. Pode ter Switch Control.

**Behaviors**:
- Navega linear pela árvore Semantics.
- Depende de `Semantics(label:)` e estrutura de heading via `Semantics(header: true)`.
- Não vê hover states ou indicadores só-visuais.
- Precisa contraste adequado (4.5:1 mínimo).
- Pode usar `MediaQuery.textScaler` em 200%+.
- iOS: pode usar AssistiveTouch em vez de gestos.

**Test questions**:
- Fluxo primário inteiro completável com TalkBack/VoiceOver?
- Todo elemento interativo tem `Semantics` com label útil?
- `IconButton` tem `tooltip:` (que vira label de a11y)?
- `Image`/`Icon` informativo tem `semanticLabel:`?
- Contraste WCAG AA passa em ambos os brightness?
- Screen reader anuncia mudanças de state (loading, success, error)? (Use `Semantics(liveRegion: true)`.)
- Touch target 48dp? `MaterialTapTargetSize.padded` no theme?
- App respeita 200% text scale sem quebrar layout?

**Red flags**:
- `GestureDetector` sem `Semantics` envolvendo.
- `IconButton` sem `tooltip:`.
- Cor sozinha conveying significado (vermelho = erro, verde = sucesso).
- `Image.asset` decorativa sem `semanticLabel: ''` (excludeFromSemantics seria limpo).
- Custom widgets que quebram fluxo do screen reader.
- Time-limited actions sem opção de extender.
- Hard-code `MediaQuery.copyWith(textScaler: TextScaler.noScaling)`.

---

## 4. Confused First-Timer: "Jordan"

**Profile**: Nunca usou esse tipo de produto. Precisa guidance em cada passo. Abandona em vez de figure-out.

**Behaviors**:
- Lê todas as instruções com cuidado.
- Hesita antes de tocar em qualquer coisa não-familiar.
- Procura ajuda ou suporte constantemente.
- Não entende jargão e abreviações.
- Pega a interpretação mais literal de qualquer label.

**Test questions**:
- A primeira ação é obviamente clara em 5 segundos?
- Todos os ícones têm label de texto?
- Há ajuda contextual em pontos de decisão (`Tooltip`, `helperText`)?
- Terminologia assume conhecimento prévio?
- Há "voltar" ou "desfazer" claro em cada passo?

**Red flags**:
- Navegação só-ícone sem labels.
- Jargão técnico sem explicação.
- Sem opção visível de ajuda.
- Próximo passo ambíguo após completar uma ação.
- Sem confirmação que ação teve sucesso (sem `SnackBar`, sem feedback visual).

---

## 5. Impatient Power User: "Alex"

**Profile**: Expert em produtos similares. Espera eficiência, odeia hand-holding. Vai achar atalhos ou sair.

**Behaviors**:
- Pula todo onboarding e instructions.
- Procura atalhos imediato.
- Tenta bulk-select, batch-edit, automatizar.
- Frustra com passos required que parecem desnecessários.
- Abandona se algo parece lento ou paternalista.

**Test questions**:
- Alex completa a tarefa core em <60s?
- Há atalhos de teclado para ações comuns? (Especialmente em Flutter web/desktop.)
- Onboarding é totalmente skipável?
- Modais têm dismiss por gesture (swipe down) e back button?
- Há um caminho power user (gestos, bulk actions, long-press menu)?

**Red flags**:
- Tutoriais forçados ou onboarding não-skipável.
- Sem keyboard nav para ações primárias (Flutter desktop/web).
- Animações lentas que não podem ser puladas.
- Workflows um-item-por-vez onde batch seria natural.
- Confirmação redundante para ações low-risk.

---

## 6. Deliberate Stress Tester: "Riley"

**Profile**: Usuário metódico que empurra interfaces além do happy path. Testa edge cases, tenta inputs inesperados, busca gaps.

**Behaviors**:
- Testa edge cases intencionalmente (estado vazio, strings longas, caracteres especiais).
- Submete forms com data inesperado (emoji, RTL, valores enormes).
- Tenta quebrar workflows: voltar, refresh, abrir em múltiplas telas, force-close mid-flow.
- Procura inconsistências entre o que UI promete e o que entrega.

**Test questions**:
- O que acontece nos limites (0 items, 1000 items, texto muito longo)?
- Erros recuperam graciosamente, ou deixam a UI quebrada?
- Refresh mid-workflow preserva state?
- Features parecem funcionar mas produzem resultados quebrados?
- Como UI lida com input inesperado (emoji, especiais, paste)?
- App entra em background e volta com state íntegro?
- Sem internet, app degrada graciosamente ou trava?

**Red flags**:
- Features que parecem funcionar mas falham silencioso.
- Error handling expondo detalhes técnicos (stack trace na UI).
- Empty states que mostram nada útil ("Sem resultados" sem orientação).
- Workflows que perdem dados em refresh ou navegação.
- Comportamento inconsistente entre interações similares em partes diferentes da UI.
- App que crash em rotação de tela.
- App que crash sem internet e não recupera.

---

## Selecionando personas

Escolha por tipo de interface:

| Tipo | Personas primárias | Razão |
|---|---|---|
| App de consumo (social, e-commerce, content) | Casey, Jordan, Diego | Mobile-first, primeira impressão, performance baixa |
| Productivity / dashboard / admin | Alex, Sam, Casey | Power users, a11y, mobile companion |
| Onboarding | Jordan, Casey | Confusão, interrupção |
| Form-heavy (cadastro, checkout) | Casey, Jordan, Riley | Mobile, claridade, edge cases |
| App offline-first | Riley, Diego | Recuperação de erro, conexão pobre |
| App crítico (saúde, financeiro) | Sam, Riley, Jordan | A11y compliance, integridade, claridade |
| App de jogo casual | Diego, Sam | Performance, a11y |

---

## Personas project-specific

Se `CLAUDE.md` ou `PRODUCT.md` contém uma seção `## Design Context` (gerada por `/impeccable teach`), derive 1-2 personas adicionais:

1. Leia a descrição de target audience.
2. Identifique o arquétipo primário não coberto pelas 6 predefinidas.
3. Crie persona seguindo o template:

```
### [Role]: "[Name]"

**Profile**: [2-3 características-chave do Design Context]

**Behaviors**: [3-4 comportamentos específicos baseados na audiência]

**Red flags**: [3-4 coisas que alienariam esse usuário específico]
```

Só gere personas project-specific quando há dados reais de Design Context. Não invente detalhes; use as 6 predefinidas quando não há contexto.
