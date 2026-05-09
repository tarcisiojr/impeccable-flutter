import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `TextStyle(height: <1.15)` em literal. Em body text, `height`
/// abaixo de 1.15 fica apertado e prejudica readability. Material 3
/// `bodyLarge` default é 1.5.
///
/// Categoria: quality. `height` baixo só faz sentido em headlines grandes
/// (`displayLarge`/`headlineLarge`) onde leading apertado é estético.
/// Como literal não conhece o papel, sempre flag.
class TightLeading extends DartLintRule {
  TightLeading() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_tight_leading',
    problemMessage:
        'TextStyle.height <1.15 prejudica readability em body text.',
    correctionMessage:
        'Use Theme.of(context).textTheme.bodyLarge (height 1.5 default M3). '
        'Para headlines, height 1.1-1.2 é OK mas pertence ao headlineLarge.',
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
      if (type != 'TextStyle') return;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        if (arg.name.label.name != 'height') continue;
        final expr = arg.expression;
        double? h;
        if (expr is IntegerLiteral) h = (expr.value ?? 0).toDouble();
        if (expr is DoubleLiteral) h = expr.value;
        if (h != null && h < 1.15 && h > 0) {
          reporter.atNode(arg, _code);
        }
      }
    });
  }
}
