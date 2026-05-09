import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `ThemeData(useMaterial3: false)` ou `useMaterial3: false` numa
/// constante de tema. Material 2 está deprecated e a paleta inteira muda.
/// Apps novos NÃO devem opt-out sem motivo documentado.
///
/// Categoria: quality. Em Flutter 3.16+, true é default; opt-out é
/// declaração explícita que precisa justificativa.
class UseMaterial3False extends DartLintRule {
  UseMaterial3False() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_use_material3_false',
    problemMessage:
        'useMaterial3: false desliga Material 3 e cai em paleta deprecated.',
    correctionMessage:
        'Remova a linha (true é default em Flutter 3.16+) ou troque para '
        'useMaterial3: true e migre componentes.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addNamedExpression((node) {
      if (node.name.label.name != 'useMaterial3') return;
      final expr = node.expression;
      if (expr is BooleanLiteral && !expr.value) {
        reporter.atNode(node, _code);
      }
    });
  }
}
