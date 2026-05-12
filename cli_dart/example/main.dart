// Exemplo mínimo de uso programático do impeccable_flutter.
//
// Roda o scanner `--fast` (regex-only, sem analyzer) sobre um snippet
// inline de código Flutter cheio de anti-padrões e imprime os findings
// em JSON, no mesmo schema do impeccable web original.
//
// Rode com:
//   dart run example/main.dart
//
// Para uso real (sobre o seu app Flutter):
//   dart pub global activate impeccable_flutter
//   impeccable_flutter detect lib/

import 'dart:convert';
import 'dart:io';

import 'package:impeccable_flutter/src/fast_scanner.dart';

Future<void> main() async {
  // Snippet com 3 anti-padrões propositais: deepPurple seed, bounce easing
  // e cor literal pura. Os 3 são detectáveis pelo scanner regex-only.
  const sampleCode = '''
import 'package:flutter/material.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.bounceOut,
        color: Colors.black,
      ),
    );
  }
}
''';

  // Grava o snippet num arquivo temporário, varre o diretório, depois apaga.
  final tmp = await Directory.systemTemp.createTemp('impeccable_example_');
  final file = File('${tmp.path}/sample.dart');
  await file.writeAsString(sampleCode);

  try {
    final findings = await scanDirectory(tmp);
    final json = findings.map((f) => f.toJson()).toList();
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(json));
    stdout.writeln('\n→ ${findings.length} finding(s) detected.');
  } finally {
    await tmp.delete(recursive: true);
  }
}
