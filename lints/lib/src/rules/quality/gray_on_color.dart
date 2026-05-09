import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Container` (ou `Material`/`Card`) com fundo de cor saturada que
/// envolve um `Text` cujo `TextStyle.color` é cinza (`Colors.grey*`,
/// `Colors.blueGrey`). Padrão típico de apps "modernos": fundo de marca azul
/// ou roxo + body em cinza para parecer "neutro" — fica ilegível.
///
/// Categoria: quality. Cinza tem ~50% luminância; cor saturada com fundo
/// claro/médio fica próxima também — contraste cai para 1.5:1 a 2.5:1
/// quando deveria ser ≥4.5:1 (WCAG AA body).
///
/// Solução: usar `Theme.of(context).colorScheme.onPrimary` ou `.onSurface`,
/// que respeitam contraste. Se quiser cor secundária sobre brand surface,
/// use `Colors.white.withOpacity(0.7)` — mantém luminance alta.
///
/// Heurística: visita Container/Material/Card; se contém background literal
/// numa cor saturada (Colors.<saturated>), busca em seu source por
/// `TextStyle(color: Colors.grey...)`. Esta é uma versão pragmática; uma
/// versão mais sofisticada resolveria cores via type-flow (ColorScheme,
/// Color.lerp). False positives aceitáveis: `// ignore: impeccable_gray_on_color`.
class GrayOnColor extends DartLintRule {
  GrayOnColor() : super(code: _code);

  /// Material colors saturadas — fundo "de marca". Exclui cinzas, preto,
  /// branco, transparente.
  static const _saturatedFamilies = [
    'Colors.red',
    'Colors.pink',
    'Colors.purple',
    'Colors.deepPurple',
    'Colors.indigo',
    'Colors.blue',
    'Colors.lightBlue',
    'Colors.cyan',
    'Colors.teal',
    'Colors.green',
    'Colors.lightGreen',
    'Colors.lime',
    'Colors.yellow',
    'Colors.amber',
    'Colors.orange',
    'Colors.deepOrange',
    'Colors.brown',
  ];

  /// Cinzas conhecidos — texto que fica ilegível sobre fundo saturado.
  static const _grayFamilies = [
    'Colors.grey',
    'Colors.gray',
    'Colors.blueGrey',
  ];

  static const _code = LintCode(
    name: 'impeccable_gray_on_color',
    problemMessage:
        'Texto cinza sobre Container com fundo saturado tem contraste '
        'insuficiente (geralmente <2.5:1). Falha WCAG AA (4.5:1 mínimo).',
    correctionMessage:
        'Use Theme.of(context).colorScheme.onPrimary/onSurface (respeita '
        'contraste) ou Colors.white.withOpacity(0.7-0.9) para texto secundário '
        'sobre brand surface.',
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

      final src = node.toSource();

      // Há um fundo de cor saturada?
      // Patterns: `color: Colors.X` ou `decoration: BoxDecoration(color: Colors.X ...)`
      final hasSaturatedBg = _saturatedFamilies.any((family) {
        // Procura `color: <family>` ou `color: <family>.<shade>` ou `color: <family>[N]`
        final pattern = RegExp('color:\\s*$family[\\s,.\\[]');
        return pattern.hasMatch(src);
      });
      if (!hasSaturatedBg) return;

      // Há texto cinza dentro?
      // Busca por TextStyle(color: <gray>...) no descendant source.
      final hasGrayText = _grayFamilies.any((family) {
        // Match `color: Colors.grey` ou `Colors.grey[400]` ou `Colors.grey.shade400`
        final pattern = RegExp('color:\\s*$family[\\s,.\\[)]');
        // Mas só dentro de TextStyle(... )
        return src.contains('TextStyle(') && pattern.hasMatch(src);
      });
      if (!hasGrayText) return;

      // Confirmação extra: o cinza tem que aparecer DEPOIS do TextStyle
      // (não em outro contexto, ex: shadow color).
      final textStyleIdx = src.indexOf('TextStyle(');
      if (textStyleIdx < 0) return;
      final afterTextStyle = src.substring(textStyleIdx);
      final cinzaInTextStyle = _grayFamilies.any((family) {
        return RegExp('color:\\s*$family[\\s,.\\[)]').hasMatch(afterTextStyle);
      });
      if (!cinzaInTextStyle) return;

      reporter.atNode(node, _code);
    });
  }
}
