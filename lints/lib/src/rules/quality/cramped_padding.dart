import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `EdgeInsets.all(N)` com `N < 8`. Padding apertado em conteúdo
/// principal cria sensação de UI sufocada.
///
/// Categoria: quality. 4 lógicos é OK em contextos densos (chip interno,
/// badge), mas em widgets de conteúdo (`Card`, `Container`, `Padding` direto)
/// fica apertado. Versão simplificada flag todo `EdgeInsets.all(<8)` literal.
/// False positives aceitáveis em badges/chips: `// ignore: ...`.
class CrampedPadding extends DartLintRule {
  CrampedPadding() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_cramped_padding',
    problemMessage:
        'EdgeInsets.all(<8) é apertado para conteúdo principal.',
    correctionMessage:
        'Use SpacingTokens.sm (8) ou .md (16) via ThemeExtension. Para chips '
        'e badges intencionalmente densos, ignore o lint.',
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
      final ctor = node.constructorName.name?.name;
      if (type != 'EdgeInsets' || ctor != 'all') return;

      if (node.argumentList.arguments.length != 1) return;
      final arg = node.argumentList.arguments.first;
      double? value;
      if (arg is IntegerLiteral) value = (arg.value ?? 0).toDouble();
      if (arg is DoubleLiteral) value = arg.value;
      if (value != null && value > 0 && value < 8) {
        reporter.atNode(node, _code);
      }
    });
  }
}
