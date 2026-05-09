import 'dart:math' as math;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Container`/`Material`/`Card` com fundo literal e texto descendente
/// com `TextStyle.color` literal cujo contraste WCAG é menor que 4.5:1
/// (limiar AA para texto body).
///
/// Categoria: quality. Esta é a regra-mãe de a11y tipográfica.
///
/// Limitações honestas:
/// - Só resolve cores LITERAIS: `Color(0xFF...)` ou `Colors.<name>` /
///   `Colors.<name>.shade<N>` / `Colors.<name>[<N>]`. Cores resolvidas em
///   runtime (`Theme.of(context).colorScheme.X`, `Color.lerp(...)`,
///   `withOpacity`) são ignoradas — type-flow no `analyzer` direto fica
///   para uma versão futura.
/// - Quando não consegue resolver, pula silenciosamente. Falsos negativos
///   nesse caso são esperados; falsos positivos são raros (só dispara
///   quando ambas as cores foram extraídas com confiança).
///
/// Threshold: 4.5:1 (WCAG AA texto body). Texto ≥18pt regular ou ≥14pt
/// bold poderia usar 3:1 (AA large), mas como não conseguimos sempre
/// resolver fontSize/weight, ficamos no limite mais conservador.
class LowContrast extends DartLintRule {
  LowContrast() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_low_contrast',
    problemMessage:
        'Contraste de texto vs fundo abaixo de 4.5:1 (WCAG AA body).',
    correctionMessage:
        'Use Theme.of(context).colorScheme.onPrimary/onSurface (respeita '
        'contraste por construção) ou ajuste manualmente para ≥4.5:1. '
        'webaim.org/resources/contrastchecker para conferir.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.name2.lexeme;
      if (type != 'Container' && type != 'Material' && type != 'Card') return;

      // Resolver cor de fundo do widget container.
      final bg = _extractBackgroundColor(node);
      if (bg == null) return;

      // Buscar Text descendente com TextStyle.color literal.
      final fg = _findDescendantTextColor(node);
      if (fg == null) return;

      final ratio = _contrastRatio(bg, fg);
      if (ratio >= 4.5) return;

      reporter.atNode(node, _code);
    });
  }

  /// Extrai a cor de fundo do widget. Procura por `color:` direto ou por
  /// `decoration: BoxDecoration(color: ...)`. Retorna `null` se não conseguir
  /// resolver para um valor RGB.
  int? _extractBackgroundColor(InstanceCreationExpression node) {
    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final name = arg.name.label.name;

      if (name == 'color') {
        return _resolveColor(arg.expression);
      }

      if (name == 'decoration') {
        // BoxDecoration(color: ...)
        final expr = arg.expression;
        if (expr is InstanceCreationExpression) {
          for (final innerArg in expr.argumentList.arguments) {
            if (innerArg is NamedExpression &&
                innerArg.name.label.name == 'color') {
              return _resolveColor(innerArg.expression);
            }
          }
        }
      }
    }
    return null;
  }

  /// Busca por `TextStyle(color: ...)` no source descendente. Heurística
  /// textual: pega o primeiro `TextStyle(...)` que contém `color:` literal.
  int? _findDescendantTextColor(InstanceCreationExpression containerNode) {
    final src = containerNode.toSource();
    // Encontra `TextStyle(` e tenta parsear `color:` dentro dele.
    final textStyleMatch = RegExp(r'TextStyle\(').firstMatch(src);
    if (textStyleMatch == null) return null;

    // Busca `color: <expr>` na vizinhança (até o próximo `)` de mesmo nível
    // ou ~200 chars). Heurística simples.
    final tail = src.substring(textStyleMatch.end);
    final colorMatch = RegExp(r'color:\s*([^,\)]+)').firstMatch(tail);
    if (colorMatch == null) return null;

    final colorExpr = colorMatch.group(1)!.trim();
    return _resolveColorString(colorExpr);
  }

  /// Resolve uma `Expression` AST para um valor int 0xRRGGBB ou null.
  int? _resolveColor(Expression expr) {
    final src = expr.toSource();
    return _resolveColorString(src);
  }

  /// Resolve uma string Dart de cor para 0xRRGGBB (sem alpha) ou null.
  int? _resolveColorString(String src) {
    final s = src.trim();

    // Color(0xFFXXXXXX)
    final hexMatch = RegExp(r'Color\(\s*0x([0-9a-fA-F]{8})\s*\)').firstMatch(s);
    if (hexMatch != null) {
      final hex = hexMatch.group(1)!.toLowerCase();
      // Pula alpha (primeiros 2 chars) — comparamos só RGB.
      return int.parse(hex.substring(2), radix: 16);
    }

    // Color.fromARGB(a, r, g, b)
    final argbMatch = RegExp(
            r'Color\.fromARGB\(\s*\d+\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)')
        .firstMatch(s);
    if (argbMatch != null) {
      final r = int.parse(argbMatch.group(1)!);
      final g = int.parse(argbMatch.group(2)!);
      final b = int.parse(argbMatch.group(3)!);
      return (r << 16) | (g << 8) | b;
    }

    // Colors.<name> ou Colors.<name>.shade<N> ou Colors.<name>[<N>]
    final colorsMatch =
        RegExp(r'Colors\.([a-zA-Z]+)(?:\.shade(\d+)|\[(\d+)\])?').firstMatch(s);
    if (colorsMatch != null) {
      final name = colorsMatch.group(1)!;
      final shade = colorsMatch.group(2) ?? colorsMatch.group(3);
      return _materialPalette[shade != null ? '$name.$shade' : name];
    }

    return null;
  }

  /// Calcula contrast ratio WCAG entre dois RGB (0xRRGGBB).
  double _contrastRatio(int rgb1, int rgb2) {
    final l1 = _relativeLuminance(rgb1);
    final l2 = _relativeLuminance(rgb2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  double _relativeLuminance(int rgb) {
    final r = ((rgb >> 16) & 0xFF) / 255.0;
    final g = ((rgb >> 8) & 0xFF) / 255.0;
    final b = (rgb & 0xFF) / 255.0;
    double channel(double c) =>
        c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
  }

  /// Subset do Material color palette (m3.material.io). Cobre as cores
  /// e shades mais usadas. Cada entrada é 0xRRGGBB (sem alpha).
  /// Quando shade não é especificado, default é o "500" (centro da escala).
  static const _materialPalette = <String, int>{
    // Neutros
    'black': 0x000000,
    'white': 0xFFFFFF,
    'transparent': 0x000000, // não calculável, mas evita null
    // Grey
    'grey': 0x9E9E9E,
    'grey.50': 0xFAFAFA,
    'grey.100': 0xF5F5F5,
    'grey.200': 0xEEEEEE,
    'grey.300': 0xE0E0E0,
    'grey.400': 0xBDBDBD,
    'grey.500': 0x9E9E9E,
    'grey.600': 0x757575,
    'grey.700': 0x616161,
    'grey.800': 0x424242,
    'grey.900': 0x212121,
    'gray': 0x9E9E9E,
    'blueGrey': 0x607D8B,
    'blueGrey.50': 0xECEFF1,
    'blueGrey.100': 0xCFD8DC,
    'blueGrey.200': 0xB0BEC5,
    'blueGrey.300': 0x90A4AE,
    'blueGrey.400': 0x78909C,
    'blueGrey.500': 0x607D8B,
    'blueGrey.600': 0x546E7A,
    'blueGrey.700': 0x455A64,
    'blueGrey.800': 0x37474F,
    'blueGrey.900': 0x263238,
    // Cores principais (shade 500 default)
    'red': 0xF44336,
    'red.300': 0xE57373,
    'red.500': 0xF44336,
    'red.700': 0xD32F2F,
    'pink': 0xE91E63,
    'pink.500': 0xE91E63,
    'purple': 0x9C27B0,
    'purple.500': 0x9C27B0,
    'deepPurple': 0x673AB7,
    'deepPurple.500': 0x673AB7,
    'indigo': 0x3F51B5,
    'indigo.500': 0x3F51B5,
    'blue': 0x2196F3,
    'blue.300': 0x64B5F6,
    'blue.500': 0x2196F3,
    'blue.700': 0x1976D2,
    'blue.900': 0x0D47A1,
    'lightBlue': 0x03A9F4,
    'cyan': 0x00BCD4,
    'teal': 0x009688,
    'green': 0x4CAF50,
    'green.500': 0x4CAF50,
    'green.700': 0x388E3C,
    'lightGreen': 0x8BC34A,
    'lime': 0xCDDC39,
    'yellow': 0xFFEB3B,
    'amber': 0xFFC107,
    'orange': 0xFF9800,
    'deepOrange': 0xFF5722,
    'brown': 0x795548,
  };
}
