import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Text(string >100 chars)` sem `softWrap:` explícito false e sem
/// `maxLines:`. Em telas largas (tablet, desktop, foldable), strings longas
/// podem render como linha única horrível ou cortar; Flutter wrap é o
/// default mas o lint chama atenção para considerar `maxLines` conscientemente.
///
/// Categoria: quality. False positive frequente em prosa intencionalmente
/// longa (Card body); aceite com `// ignore: ...`. Severity INFO porque é
/// heurística amigável.
class LineLength extends DartLintRule {
  LineLength() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_line_length',
    problemMessage:
        'Text com string >100 chars sem maxLines/softWrap explícito.',
    correctionMessage:
        'Considere maxLines: N + overflow: TextOverflow.ellipsis para limitar, '
        'ou ConstrainedBox(maxWidth: 600) para forçar largura confortável.',
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
      if (type != 'Text' && type != 'SelectableText') return;

      final args = node.argumentList.arguments;
      if (args.isEmpty) return;

      // Primeiro arg deve ser a string literal.
      final first = args.first;
      if (first is! SimpleStringLiteral) return;
      if (first.value.length <= 100) return;

      // Verificar se já tem maxLines: ou softWrap: false
      final hasGuard = args.whereType<NamedExpression>().any((arg) {
        final name = arg.name.label.name;
        return name == 'maxLines' || name == 'softWrap';
      });
      if (hasGuard) return;

      reporter.atNode(first, _code);
    });
  }
}
