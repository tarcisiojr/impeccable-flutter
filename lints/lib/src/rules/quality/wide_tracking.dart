import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `TextStyle(letterSpacing: > 2)` literal. Tracking exagerado em
/// body text é cheiro: além de hard-codar, prejudica readability.
///
/// Categoria: quality. ALL-CAPS labels pequenos podem precisar `letterSpacing`
/// 0.05-0.12 em em-multiplier (ou ~0.5-1 em pontos). Acima de 2 só faz
/// sentido em display arts deliberados.
class WideTracking extends DartLintRule {
  WideTracking() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_wide_tracking',
    problemMessage:
        'TextStyle.letterSpacing >2 prejudica readability em body.',
    correctionMessage:
        'Para ALL-CAPS labels, use 0.5-1.5. Para body, deixe default. '
        'Se intencional em display art, ignore o lint.',
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
        if (arg.name.label.name != 'letterSpacing') continue;
        final expr = arg.expression;
        double? v;
        if (expr is IntegerLiteral) v = (expr.value ?? 0).toDouble();
        if (expr is DoubleLiteral) v = expr.value;
        if (v != null && v > 2) {
          reporter.atNode(arg, _code);
        }
      }
    });
  }
}
