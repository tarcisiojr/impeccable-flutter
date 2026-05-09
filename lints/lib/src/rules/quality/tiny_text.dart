import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `TextStyle(fontSize: <12)` literal. Texto abaixo de 12 lógicos
/// é difícil de ler em mobile e não deveria existir fora de `labelSmall`
/// (que é 11 e oficial M3 para metadata específico).
///
/// Categoria: quality. Em mobile, body começa em 14 (`bodyMedium`) e o
/// ideal é 16 (`bodyLarge`). Smaller = considere `labelSmall` ou `bodySmall`,
/// mas não invente um literal.
class TinyText extends DartLintRule {
  TinyText() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_tiny_text',
    problemMessage:
        'fontSize <12 é difícil de ler em mobile. Use textTheme.labelSmall.',
    correctionMessage:
        'Substitua por Theme.of(context).textTheme.labelSmall (M3, 11) ou '
        'bodySmall (12). Hard-code de fontSize quebra Dynamic Type.',
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
      if (type != 'TextStyle') return;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        if (arg.name.label.name != 'fontSize') continue;
        final expr = arg.expression;
        double? size;
        if (expr is IntegerLiteral) size = (expr.value ?? 0).toDouble();
        if (expr is DoubleLiteral) size = expr.value;
        if (size != null && size < 12) {
          reporter.atNode(arg, _code);
        }
      }
    });
  }
}
