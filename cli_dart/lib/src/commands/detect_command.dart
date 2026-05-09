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
      // Schema unificado: array direto de findings (paridade com impeccable
      // web original). Ver `FastFinding.toJson` para o shape de cada item.
      stdout.writeln(jsonEncode(findings.map((f) => f.toJson()).toList()));
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

    if (format == 'json') {
      // custom_lint emite `{version, diagnostics: [{code, severity, type,
      // location: {file, range: {start: {offset, line, column}, end: {...}}},
      // problemMessage, correctionMessage}]}`. Convertemos para o schema
      // unificado: array de `{antipattern, name, description, file, line,
      // snippet, severity, column}` igual ao --fast.
      try {
        final raw = jsonDecode(result.stdout.toString());
        final diagnostics =
            (raw['diagnostics'] as List?) ?? const <dynamic>[];
        final normalized = await Future.wait(
          diagnostics.map((d) async => await _normalizeDiagnostic(d as Map)),
        );
        stdout.writeln(jsonEncode(normalized));
      } catch (e) {
        // Se parse falhar (versão diferente do custom_lint, output não-JSON),
        // emite raw e avisa via stderr.
        stderr.writeln('warn: falha ao parsear JSON do custom_lint ($e). '
            'Emitindo output bruto.');
        stdout.write(result.stdout);
      }
    } else {
      stdout.write(result.stdout);
    }
    if (result.stderr.toString().isNotEmpty) {
      stderr.write(result.stderr);
    }
    return result.exitCode;
  }

  /// Converte um diagnostic do `custom_lint` no schema unificado.
  /// Tenta extrair o snippet do arquivo via `start.offset` + `end.offset`.
  Future<Map<String, dynamic>> _normalizeDiagnostic(Map d) async {
    final code = (d['code'] as String?) ?? 'unknown';
    final location = d['location'] as Map?;
    final file = location?['file'] as String? ?? '';
    final range = location?['range'] as Map?;
    final start = range?['start'] as Map?;
    final end = range?['end'] as Map?;
    final line = (start?['line'] as int?) ?? 0;
    final column = (start?['column'] as int?) ?? 0;
    final startOffset = (start?['offset'] as int?) ?? 0;
    final endOffset = (end?['offset'] as int?) ?? startOffset;

    String snippet = '';
    if (file.isNotEmpty && endOffset > startOffset) {
      try {
        final source = await File(file).readAsString();
        if (endOffset <= source.length) {
          snippet =
              source.substring(startOffset, endOffset).replaceAll('\n', ' ').trim();
          if (snippet.length > 200) snippet = '${snippet.substring(0, 200)}...';
        }
      } catch (_) {/* arquivo inacessível: snippet vazio */}
    }

    return {
      'antipattern': _toCanonicalId(code),
      'name': _ruleIdToName(code),
      'description': (d['problemMessage'] as String?) ?? '',
      'file': file,
      'line': line,
      'snippet': snippet,
      'severity': (d['severity'] as String?) ?? 'INFO',
      'column': column,
    };
  }

  /// Converte `impeccable_deep_purple_seed` → `deep-purple-seed`.
  String _toCanonicalId(String ruleId) {
    final stripped =
        ruleId.startsWith('impeccable_') ? ruleId.substring(11) : ruleId;
    return stripped.replaceAll('_', '-');
  }

  /// Converte `impeccable_deep_purple_seed` → `Deep Purple Seed`.
  String _ruleIdToName(String ruleId) {
    final canonical = _toCanonicalId(ruleId);
    return canonical
        .split('-')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
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
