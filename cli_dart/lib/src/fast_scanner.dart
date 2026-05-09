/// Scanner regex puro para varredura rápida de arquivos `.dart`.
///
/// Sem dependência do `analyzer` (sem AST). Cobre subset das regras que dão
/// para detectar com regex confiável. Útil para:
///  - Codebases grandes (>500 arquivos) onde analyzer + custom_lint é lento.
///  - CI rápido pré-commit.
///  - Pre-flight check antes do `dart run custom_lint` completo.
///  - Cobertura de regras agregadoras (cross-node) que `custom_lint_core`
///    0.7.5 não suporta bem: monotonous_spacing, everything_centered.
///  - Cobertura de regras com bug de callback no plugin: overused_font.
///
/// Trade-off: regex perde casos onde o pattern usa identifier renomeado
/// (`import 'package:flutter/material.dart' as m; m.Colors.deepPurple`).
/// Para precisão máxima, use o detector full (`custom_lint`).
library;

import 'dart:io';

class FastFinding {
  FastFinding({
    required this.ruleId,
    required this.severity,
    required this.message,
    required this.path,
    required this.line,
    required this.column,
  });

  final String ruleId;
  final String severity;
  final String message;
  final String path;
  final int line;
  final int column;

  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'severity': severity,
        'message': message,
        'path': path,
        'line': line,
        'column': column,
      };

  String toHuman() => '  $path:$line:$column • $message • $ruleId • $severity';
}

class _FastRule {
  _FastRule({
    required this.id,
    required this.severity,
    required this.message,
    required this.pattern,
  });

  final String id;
  final String severity;
  final String message;
  final RegExp pattern;
}

/// Lista de regras line-level (uma linha por vez). Subset do detector full,
/// escolhidas onde regex tem precisão razoável.
final List<_FastRule> _fastLineRules = [
  _FastRule(
    id: 'impeccable_deep_purple_seed',
    severity: 'WARNING',
    message: 'Colors.deepPurple seed = look "flutter create".',
    pattern: RegExp(r'seedColor\s*:\s*Colors\.deepPurple'),
  ),
  _FastRule(
    id: 'impeccable_bounce_elastic_curve',
    severity: 'WARNING',
    message: 'Curves.bounce*/elastic* lê amador.',
    pattern: RegExp(r'Curves\.(bounce|elastic)\w+'),
  ),
  _FastRule(
    id: 'impeccable_black_white_literal',
    severity: 'WARNING',
    message: 'Colors.black/white literal quebra dark mode.',
    // black, black87, etc. + white, white70, etc.
    pattern: RegExp(r'Colors\.(black|white)(\d{1,3})?\b'),
  ),
  _FastRule(
    id: 'impeccable_justified_text',
    severity: 'WARNING',
    message: 'TextAlign.justify cria rivers em mobile.',
    pattern: RegExp(r'TextAlign\.justify\b'),
  ),
  _FastRule(
    id: 'impeccable_use_material3_false',
    severity: 'WARNING',
    message: 'useMaterial3: false cai em paleta deprecated.',
    pattern: RegExp(r'useMaterial3\s*:\s*false\b'),
  ),
  _FastRule(
    id: 'impeccable_ai_color_palette',
    severity: 'INFO',
    message: 'Cor da família roxo/índigo dominante em apps Flutter de IA.',
    // Hex literal Color(0xFF<hex6>) onde hex está na lista de AI defaults.
    // Case-insensitive porque hex em Dart é tipicamente uppercase.
    pattern: RegExp(
      r'Color\(0xFF(5b21b6|6d28d9|7c3aed|8b5cf6|a78bfa|4f46e5|6366f1|818cf8|4338ca|3730a3)',
      caseSensitive: false,
    ),
  ),
  _FastRule(
    id: 'impeccable_overused_font',
    severity: 'INFO',
    message: 'GoogleFonts default da reflex-reject list.',
    // GoogleFonts.<font>() ou GoogleFonts.<font>TextTheme()
    pattern: RegExp(
      r'GoogleFonts\.(inter|dmSans|dmSerifDisplay|dmSerifText|plusJakartaSans|outfit|instrumentSans|instrumentSerif|iBMPlexSans|iBMPlexMono|iBMPlexSerif|spaceGrotesk|spaceMono|fraunces|crimson|crimsonPro|crimsonText|newsreader|lora|playfairDisplay|cormorant|cormorantGaramond|syne)(TextTheme)?\(',
    ),
  ),
];

/// Padrão para `EdgeInsets.all(N)` capturando o N. Usado por
/// `monotonous_spacing` (agregação por valor).
final _edgeInsetsAllPattern = RegExp(r'EdgeInsets\.all\(\s*(\d+)\s*\)');

/// Padrão para `Center(...)` ou `MainAxisAlignment.center` /
/// `CrossAxisAlignment.center`. Usado por `everything_centered`.
final _centerPattern =
    RegExp(r'\bCenter\s*\(|\b(?:Main|Cross)AxisAlignment\.center\b');

/// Escaneia um diretório recursivamente; retorna findings em ordem.
Future<List<FastFinding>> scanDirectory(Directory dir) async {
  final findings = <FastFinding>[];
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;
    if (_isExcluded(entity.path)) continue;
    findings.addAll(await _scanFile(entity));
  }
  return findings;
}

bool _isExcluded(String path) =>
    path.contains('/.dart_tool/') ||
    path.contains('/build/') ||
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart');

Future<List<FastFinding>> _scanFile(File file) async {
  final findings = <FastFinding>[];
  final lines = await file.readAsLines();

  // Pass 1: line-level regex rules.
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().startsWith('//')) continue;
    for (final rule in _fastLineRules) {
      final match = rule.pattern.firstMatch(line);
      if (match != null) {
        findings.add(FastFinding(
          ruleId: rule.id,
          severity: rule.severity,
          message: rule.message,
          path: file.path,
          line: i + 1,
          column: match.start + 1,
        ));
      }
    }
  }

  // Pass 2: agregação cross-line para regras que custom_lint não suporta.
  findings.addAll(_aggregateMonotonousSpacing(file.path, lines));
  findings.addAll(_aggregateEverythingCentered(file.path, lines));

  return findings;
}

/// `monotonous_spacing`: `EdgeInsets.all(N)` com mesmo N ≥4 vezes no arquivo.
/// Reporta a primeira ocorrência por valor que cruza o threshold.
List<FastFinding> _aggregateMonotonousSpacing(
  String path,
  List<String> lines,
) {
  final byValue = <int, List<({int line, int col})>>{};

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().startsWith('//')) continue;
    for (final m in _edgeInsetsAllPattern.allMatches(line)) {
      final v = int.tryParse(m.group(1)!);
      if (v == null) continue;
      byValue.putIfAbsent(v, () => []).add((line: i + 1, col: m.start + 1));
    }
  }

  final findings = <FastFinding>[];
  byValue.forEach((value, occurrences) {
    if (occurrences.length >= 4) {
      final first = occurrences.first;
      findings.add(FastFinding(
        ruleId: 'impeccable_monotonous_spacing',
        severity: 'INFO',
        message:
            'EdgeInsets.all($value) repetido ${occurrences.length}× = padding monotônico.',
        path: path,
        line: first.line,
        column: first.col,
      ));
    }
  });
  return findings;
}

/// `everything_centered`: ≥6 ocorrências de `Center(` ou `*.center` no
/// mesmo arquivo. Sinaliza composição centralizada-em-tudo.
List<FastFinding> _aggregateEverythingCentered(
  String path,
  List<String> lines,
) {
  final hits = <({int line, int col})>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().startsWith('//')) continue;
    for (final m in _centerPattern.allMatches(line)) {
      hits.add((line: i + 1, col: m.start + 1));
    }
  }

  if (hits.length < 6) return const [];
  final first = hits.first;
  return [
    FastFinding(
      ruleId: 'impeccable_everything_centered',
      severity: 'INFO',
      message:
          'Tudo centralizado (${hits.length} Center/MainAxisAlignment.center). '
          'Considere composição assimétrica.',
      path: path,
      line: first.line,
      column: first.col,
    ),
  ];
}
