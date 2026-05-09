Designs that only work with perfect data aren't production-ready. Harden the interface against the inputs, errors, languages, and network conditions that real users will throw at it.

## Assess Hardening Needs

Identify weaknesses and edge cases:

1. **Test with extreme inputs**:
   - Very long text (names, descriptions, titles)
   - Very short text (empty, single character)
   - Special characters (emoji, RTL text, accents)
   - Large numbers (millions, billions)
   - Many items (1000+ list items, 50+ options)
   - No data (empty states)

2. **Test error scenarios**:
   - Network failures (offline, slow, timeout)
   - API errors (400, 401, 403, 404, 500)
   - Validation errors
   - Permission errors
   - Rate limiting
   - Concurrent operations

3. **Test internationalization**:
   - Long translations (German is often 30% longer than English)
   - RTL languages (Arabic, Hebrew)
   - Character sets (Chinese, Japanese, Korean, emoji)
   - Date/time formats
   - Number formats (1,000 vs 1.000)
   - Currency symbols

**CRITICAL**: Designs that only work with perfect data aren't production-ready. Harden against reality.

## Hardening Dimensions

Systematically improve resilience:

### Text Overflow & Wrapping (Flutter)

**Long text handling**:

```dart
// Single line com ellipsis
Text(
  'Texto muito longo aqui',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)

// Multi-line com clamp em 3 linhas
Text(
  longText,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
)

// Allow wrapping (default)
Text(longText, softWrap: true)
```

**Row/Column overflow**:

```dart
// Prevenir Row overflow: Flexible/Expanded
Row(children: [
  const Icon(Icons.person),
  const SizedBox(width: 8),
  Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
])

// Prevenir Column overflow vertical
Column(children: [
  Flexible(child: Text(longText)),
  const SizedBox(height: 8),
  Text(footer),
])
```

**Sem `Flexible`/`Expanded`**: `Row`/`Column` overflow → "RIGHT OVERFLOWED BY N PIXELS" amarelo no debug, e clipping em produção.

**Text scaling acessível**:
- Honra `MediaQuery.textScaler` em todas as telas. Não passe `TextScaler.noScaling`.
- Tamanho mínimo legível: `bodyLarge` M3 default = 16. Não desça.
- Teste a 130% e 200% (`MediaQueryData.copyWith(textScaler: TextScaler.linear(2.0))` em widget tests).
- Containers devem crescer com texto (use `IntrinsicHeight`, `Wrap`, ou layout que não trava height).

### Internationalization (i18n)

**Text expansion (Flutter)**:
- Adicione 30-40% de orçamento de espaço para traduções.
- Use widgets que adaptam ao conteúdo (`IntrinsicWidth`, `Wrap`, `Flexible`).
- Teste com idioma mais longo (geralmente alemão ou finlandês).
- Evite `width:` hard-codado em botões/containers de texto.

```dart
// RUIM: assume texto inglês curto
SizedBox(width: 96, child: ElevatedButton(child: Text('Submit'), ...))

// BOM: adapta ao conteúdo
ElevatedButton(child: Text(t.submit), ...)
```

**RTL (Right-to-Left) em Flutter**:

```dart
// Use EdgeInsetsDirectional em vez de EdgeInsets.fromLTRB
Padding(padding: EdgeInsetsDirectional.only(start: 16, end: 8))

// AlignmentDirectional em vez de Alignment
Container(alignment: AlignmentDirectional.centerStart)

// Em Row, considere `textDirection:` se precisar override local
Row(textDirection: TextDirection.rtl, children: [...])

// MaterialApp já injeta Directionality baseada na locale.
// Para testar RTL: MaterialApp(locale: Locale('ar'))
```

**Character sets**:
- UTF-8 é default em Dart.
- Teste com CJK characters, emoji, scripts diferentes.
- Fontes precisam suportar os ranges. Inter cobre latin + cyrillic + greek + vietnamese; CJK precisa Noto Sans CJK; árabe precisa Noto Sans Arabic.

**Date/Time / number formatting (Flutter)**:

```dart
// ✅ Use intl package
import 'package:intl/intl.dart';

DateFormat.yMd('pt_BR').format(date);       // 15/01/2024
DateFormat.yMd('en_US').format(date);       // 1/15/2024

NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(1234.56);
// R$ 1.234,56

NumberFormat.compactCurrency(locale: 'en_US', symbol: '\$').format(1234567);
// $1.23M
```

**Pluralization (`.arb` files)**:

```json
// app_pt.arb
{
  "items": "{count, plural, one{# item} other{# itens}}",
  "@items": { "placeholders": { "count": { "type": "int" } } }
}
```

```dart
Text(AppLocalizations.of(context)!.items(count));
```

`{count, plural, ...}` cobre russo, polonês, árabe (que tem 6 formas). Não tente plural manual.

### Error Handling

**Network errors (Flutter)**:
- Mensagens claras.
- Botão de retry.
- Explicar o que aconteceu.
- Offline mode quando aplica (`connectivity_plus` package).
- Timeout via `Future.timeout(Duration(seconds: 10))`.

```dart
// Error state com recovery
class _MyDataState extends State<MyData> {
  AsyncValue<Data>? _state;
  
  @override
  Widget build(context) {
    if (_state is AsyncError) {
      return Column(children: [
        Icon(Icons.cloud_off, size: 48, color: scheme.error),
        const SizedBox(height: 16),
        Text('Não conseguimos carregar.', style: textTheme.bodyMedium),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
        ),
      ]);
    }
    // ... loading + success
  }
}
```

Em pipelines reais, considere `riverpod`/`bloc` que entregam `AsyncValue`/`AsyncSnapshot` com error handling estruturado.

**Form validation errors**:
- Inline errors near fields
- Clear, specific messages
- Suggest corrections
- Don't block submission unnecessarily
- Preserve user input on error

**API errors**:
- Handle each status code appropriately
  - 400: Show validation errors
  - 401: Redirect to login
  - 403: Show permission error
  - 404: Show not found state
  - 429: Show rate limit message
  - 500: Show generic error, offer support

**Graceful degradation**:
- Core functionality works without JavaScript
- Images have alt text
- Progressive enhancement
- Fallbacks for unsupported features

### Edge Cases & Boundary Conditions

**Empty states**:
- No items in list
- No search results
- No notifications
- No data to display
- Provide clear next action

**Loading states**:
- Initial load
- Pagination load
- Refresh
- Show what's loading ("Loading your projects...")
- Time estimates for long operations

**Large datasets**:
- Pagination or virtual scrolling
- Search/filter capabilities
- Performance optimization
- Don't load all 10,000 items at once

**Concurrent operations**:
- Prevent double-submission (disable button while loading)
- Handle race conditions
- Optimistic updates with rollback
- Conflict resolution

**Permission states**:
- No permission to view
- No permission to edit
- Read-only mode
- Clear explanation of why

**Browser compatibility**:
- Polyfills for modern features
- Fallbacks for unsupported CSS
- Feature detection (not browser detection)
- Test in target browsers

### Input Validation & Sanitization

**Client-side validation**:
- Required fields
- Format validation (email, phone, URL)
- Length limits
- Pattern matching
- Custom validation rules

**Server-side validation** (always):
- Never trust client-side only
- Validate and sanitize all inputs
- Protect against injection attacks
- Rate limiting

**Constraint handling (Flutter)**:
```dart
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Username',
    helperText: 'Letras e números, até 100 caracteres',
    counterText: '',  // esconde contador automático se quer custom
  ),
  maxLength: 100,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
  ],
  keyboardType: TextInputType.text,
  textInputAction: TextInputAction.next,
  validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
  autovalidateMode: AutovalidateMode.onUserInteraction,
)
```

`inputFormatters` rejeitam keystroke inválido em runtime. `validator` valida no submit ou onChange. Use ambos.

### Accessibility Resilience

**Keyboard navigation**:
- All functionality accessible via keyboard
- Logical tab order
- Focus management in modals
- Skip links for long content

**Screen reader support**:
- Proper ARIA labels
- Announce dynamic changes (live regions)
- Descriptive alt text
- Semantic HTML

**Motion sensitivity (Flutter)**:
```dart
// Em todo widget que anima
final reduceMotion = MediaQuery.disableAnimationsOf(context);

AnimatedContainer(
  duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
  curve: reduceMotion ? Curves.linear : Curves.easeOutCubic,
  // ...
)

// Helper extension recomendado:
extension MotionAware on BuildContext {
  Duration motionDuration(Duration normal) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : normal;
}
```

`MediaQuery.disableAnimationsOf(context)` reflete iOS Settings → Accessibility → Motion → Reduce Motion, e Android Settings → Accessibility → Remove Animations.

**High contrast mode**:
- Test in Windows high contrast mode
- Don't rely only on color
- Provide alternative visual cues

### Performance Resilience

**Slow connections**:
- Progressive image loading
- Skeleton screens
- Optimistic UI updates
- Offline support (service workers)

**Memory leaks (Flutter)**:
- `dispose()` em todo `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode`, `StreamSubscription`, `Timer`.
- `StatefulWidget` sem `dispose()` é cheiro forte de leak.
- `StreamBuilder` cuida da sua subscription, mas se você cria stream manual, lembre `cancel()`.
- `mounted` check antes de `setState` em callback async (evita "setState after dispose" exception).

**Throttling & Debouncing (Flutter)**:
```dart
// Debounce de busca via Timer
Timer? _debounce;

void _onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
}

@override
void dispose() {
  _debounce?.cancel();
  super.dispose();
}

// Para throttle de scroll, use NotificationListener com check de timestamp,
// ou package `rxdart` com `throttleTime`/`debounceTime` em Stream.
```

## Testing Strategies

**Manual testing**:
- Test with extreme data (very long, very short, empty)
- Test in different languages
- Test offline
- Test slow connection (throttle to 3G)
- Test with screen reader
- Test keyboard-only navigation
- Test on old browsers

**Automated testing**:
- Unit tests for edge cases
- Integration tests for error scenarios
- E2E tests for critical paths
- Visual regression tests
- Accessibility tests (axe, WAVE)

**IMPORTANT**: Hardening is about expecting the unexpected. Real users will do things you never imagined.

**NEVER**:
- Assume perfect input (validate everything)
- Ignore internationalization (design for global)
- Leave error messages generic ("Error occurred")
- Forget offline scenarios
- Trust client-side validation alone
- Use fixed widths for text
- Assume English-length text
- Block entire interface when one component errors

## Verify Hardening

Test thoroughly with edge cases:

- **Long text**: Try names with 100+ characters
- **Emoji**: Use emoji in all text fields
- **RTL**: Test with Arabic or Hebrew
- **CJK**: Test with Chinese/Japanese/Korean
- **Network issues**: Disable internet, throttle connection
- **Large datasets**: Test with 1000+ items
- **Concurrent actions**: Click submit 10 times rapidly
- **Errors**: Force API errors, test all error states
- **Empty**: Remove all data, test empty states

When edge cases are covered, hand off to `$impeccable-flutter polish` for the final pass.
