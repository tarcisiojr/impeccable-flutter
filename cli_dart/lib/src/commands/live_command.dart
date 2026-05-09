import 'dart:io';

import 'package:args/command_runner.dart';

/// `impeccable_flutter live`
///
/// Stub do modo live. MVP v0.1 documenta o workflow manual em
/// `skill/reference/live.md`: agente edita variantes inline em lib/, usuário
/// aplica via hot reload (`r` no terminal de `flutter run`).
///
/// v0.2 ganha:
/// - HTTP server local (dart:io HttpServer) com SSE para poll de eventos.
/// - Pacote dev `impeccable_flutter_live` com overlay para selecionar widget
///   via long-press, capturando runtimeType + source location via
///   WidgetInspectorService.
/// - VM Service (vm_service package) para hot reload programático após edits.
class LiveCommand extends Command<int> {
  @override
  String get name => 'live';

  @override
  String get description =>
      'Modo iterativo de variantes (MVP: workflow manual via hot reload).';

  @override
  Future<int> run() async {
    stdout.writeln('''
╭─ impeccable_flutter live ─────────────────────────────────────╮
│                                                                │
│  MVP v0.1: workflow manual.                                    │
│                                                                │
│  1. Em outro terminal, rode: flutter run -d <device>           │
│  2. Diga ao agente:                                            │
│       "iterar no <Widget> em <path>, fazer 3 variantes <X>"   │
│  3. Agente edita o source. No terminal flutter run, pressione  │
│     'r' para hot reload e 'R' para hot restart se necessário.  │
│  4. Aceite uma variante; agente limpa as outras.               │
│                                                                │
│  Roadmap v0.2: HTTP server + overlay de seleção via            │
│  long-press + VM Service. Veja skill/reference/live.md.        │
│                                                                │
╰────────────────────────────────────────────────────────────────╯
''');
    return 0;
  }
}
