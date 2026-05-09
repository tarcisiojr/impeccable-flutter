import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `BoxShadow` com blurRadius alto (>30) e cor saturada não-preta
/// (provavelmente brand glow), tipicamente em fundo escuro. Padrão clássico
/// de "AI dark dashboard": glow azul/roxo sob cards.
///
/// Categoria: slop. Em M3, profundidade em dark vem de `surfaceContainer*`
/// mais claro, não de glow saturado. Glow real só faz sentido em superfície
/// brand surface deliberada (raro).
///
/// Heurística: BoxShadow(blurRadius: >30) E cor não-neutra (não Colors.black*,
/// não Colors.grey*, não scheme.shadow). Cobre casos óbvios; saturação real
/// via HSL conversion ficaria para v2.
class DarkGlow extends DartLintRule {
  DarkGlow() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_dark_glow',
    problemMessage:
        'BoxShadow com blurRadius >30 sugere "AI dashboard glow". Em M3 use '
        'surfaceContainer* mais claro para profundidade.',
    correctionMessage:
        'Substitua por Material(elevation: N) ou shift surfaceContainer. '
        'Glow saturado só em hero brand surface deliberado.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.name2.lexeme;
      if (type != 'BoxShadow') return;

      var blurOver30 = false;
      var hasNonNeutralColor = false;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        final expr = arg.expression;

        if (name == 'blurRadius') {
          double? v;
          if (expr is IntegerLiteral) v = (expr.value ?? 0).toDouble();
          if (expr is DoubleLiteral) v = expr.value;
          if (v != null && v > 30) blurOver30 = true;
        }

        if (name == 'color') {
          final src = expr.toSource();
          // Colors.black*, Colors.grey*, ou scheme.shadow = neutro, OK.
          final isNeutral = RegExp(r'Colors\.(black|grey|gray)').hasMatch(src) ||
              src.contains('.shadow') ||
              src.contains('.scrim');
          if (!isNeutral) hasNonNeutralColor = true;
        }
      }

      if (blurOver30 && hasNonNeutralColor) {
        reporter.atNode(node, _code);
      }
    });
  }
}
