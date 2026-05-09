import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Text(textAlign: TextAlign.justify)`. Em mobile, justify quase
/// sempre piora a legibilidade: rivers de espaço entre palavras curtas em
/// linhas estreitas.
///
/// Categoria: quality. Use `TextAlign.start` (default) ou `TextAlign.left`
/// para prosa em mobile. Justify só faz sentido em colunas largas com
/// hifenização (não disponível em Flutter por padrão).
class JustifiedText extends DartLintRule {
  JustifiedText() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_justified_text',
    problemMessage:
        'TextAlign.justify cria rivers em linhas estreitas mobile.',
    correctionMessage:
        'Use TextAlign.start (default) para prosa em mobile.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPrefixedIdentifier((node) {
      if (node.prefix.name == 'TextAlign' && node.identifier.name == 'justify') {
        reporter.atNode(node, _code);
      }
    });
  }
}
