import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Border(left: BorderSide(...))` ou `Border(right: ...)` com
/// `width > 1`. Side stripe colorido é o anti-pattern absoluto banido pelo
/// impeccable parent: nunca intencional, sempre AI slop.
///
/// Categoria: slop. Para indicar "ativo"/"warning"/"selected", use:
///  - `Border.all` completo (hairline ou colorido).
///  - Background tint (`surfaceContainerHigh`).
///  - Leading icon ou número.
///  - Selected state via `WidgetState.selected` no theme.
///
/// Heurística: string-match no source porque a estrutura `Border(left:
/// BorderSide(color:, width: N))` é estável.
class SideTab extends DartLintRule {
  SideTab() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_side_tab',
    problemMessage:
        'Border lateral colorido (left/right) é AI slop. Banido absoluto.',
    correctionMessage:
        'Use Border.all (perímetro completo), background tint, leading icon, '
        'ou selected state via WidgetStateProperty. Nunca side stripe.',
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
      if (type != 'Border') return;

      final src = node.toSource();
      // Match: Border( left: BorderSide(...) ) ou ( right: BorderSide(...) )
      // sem que top/bottom também tenham BorderSide significativo.
      final hasLeft = RegExp(r'left\s*:\s*BorderSide\b').hasMatch(src);
      final hasRight = RegExp(r'right\s*:\s*BorderSide\b').hasMatch(src);
      final hasTop = RegExp(r'top\s*:\s*BorderSide\b').hasMatch(src);
      final hasBottom = RegExp(r'bottom\s*:\s*BorderSide\b').hasMatch(src);

      // Side-stripe verdadeiro: só lateral, sem top/bottom (ou top/bottom
      // explicitamente BorderSide.none).
      final asymmetric =
          (hasLeft || hasRight) && !(hasTop && hasBottom);
      if (!asymmetric) return;

      // Width >1 indica decorativo, não hairline divider.
      final widthMatch =
          RegExp(r'width\s*:\s*(\d+(?:\.\d+)?)').firstMatch(src);
      if (widthMatch == null) return;
      final width = double.tryParse(widthMatch.group(1)!) ?? 0;
      if (width > 1) {
        reporter.atNode(node, _code);
      }
    });
  }
}
