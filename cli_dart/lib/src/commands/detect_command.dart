import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../fast_scanner.dart';

/// `impeccable_flutter detect [path]`
///
/// Dois modos:
///
///  - **full** (default): wrapper sobre `dart run custom_lint`. Detector real
///    vive em `impeccable_flutter_lints` (custom_lint plugin). Roda análise
///    tipada; mais preciso, mais lento.
///  - **`--fast`**: scanner regex puro sobre `.dart` files. Sem dependência
///    de analyzer. Cobre ~6 das 14 regras com precisão razoável. Útil para
///    codebases grandes (>500 arquivos) ou CI rápido.
class DetectCommand extends Command<int> {
  DetectCommand() {
    argParser
      ..addOption(
        'format',
        abbr: 'f',
        defaultsTo: 'human',
        allowed: ['human', 'json'],
        help: 'Formato de saída.',
      )
      ..addFlag(
        'fast',
        defaultsTo: false,
        help:
            'Modo rápido: pula análise tipada (analyzer) e usa só regex sobre '
            'arquivos .dart. Sacrifica precisão por velocidade em codebases '
            'grandes (>500 arquivos).',
      );
  }

  @override
  String get name => 'detect';

  @override
  String get description =>
      'Roda as regras do impeccable_flutter_lints sobre o projeto Flutter.';

  @override
  String get invocation => 'impeccable_flutter detect [path]';

  @override
  Future<int> run() async {
    final argResults = this.argResults!;
    final path =
        argResults.rest.isEmpty ? Directory.current.path : argResults.rest.first;
    final format = argResults['format'] as String;
    final fast = argResults['fast'] as bool;

    final dir = Directory(path);
    if (!await dir.exists()) {
      stderr.writeln('Caminho não existe: $path');
      return 1;
    }

    if (fast) {
      return _runFast(dir, format);
    }
    return _runFull(dir, format);
  }

  Future<int> _runFast(Directory dir, String format) async {
    stderr.writeln('Modo --fast: scanner regex sobre ${dir.path}');
    final findings = await scanDirectory(dir);

    if (format == 'json') {
      stdout.writeln(jsonEncode({
        'mode': 'fast',
        'count': findings.length,
        'findings': findings.map((f) => f.toJson()).toList(),
      }));
    } else {
      if (findings.isEmpty) {
        stdout.writeln('No issues found.');
      } else {
        for (final f in findings) {
          stdout.writeln(f.toHuman());
        }
        stdout.writeln('\n${findings.length} issue(s) found.');
      }
    }
    return findings.isEmpty ? 0 : 1;
  }

  Future<int> _runFull(Directory dir, String format) async {
    final pubspec = await _findPubspec(dir);
    if (pubspec == null) {
      stderr.writeln(
        'Nenhum pubspec.yaml encontrado em ${dir.path} ou diretórios pais. '
        'Você está num projeto Flutter?',
      );
      return 1;
    }

    stderr.writeln('Rodando custom_lint em ${pubspec.parent.path}...');

    final result = await Process.run(
      'dart',
      ['run', 'custom_lint', if (format == 'json') '--format=json'],
      workingDirectory: pubspec.parent.path,
      runInShell: true,
    );

    stdout.write(result.stdout);
    if (result.stderr.toString().isNotEmpty) {
      stderr.write(result.stderr);
    }
    return result.exitCode;
  }

  /// Sobe na árvore de diretórios procurando pubspec.yaml.
  Future<File?> _findPubspec(Directory start) async {
    var current = start.absolute;
    while (true) {
      final candidate = File('${current.path}/pubspec.yaml');
      if (await candidate.exists()) return candidate;
      final parent = current.parent;
      if (parent.path == current.path) return null;
      current = parent;
    }
  }
}
