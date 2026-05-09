import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Text(..., style: TextStyle(...))` cru sem derivar do
/// `Theme.of(context).textTheme`. Hard-code de fontSize/weight quebra
/// Dynamic Type, dark mode tipográfico e desconecta da escala do app.
///
/// Categoria: quality. Substituir por:
///   - `style: Theme.of(context).textTheme.bodyLarge`
///   - `style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ...)`
///
/// False positives aceitáveis: tests, prototypes, casos onde TextStyle vem
/// já de `textTheme.X` mas o lint não consegue rastrear. Use
/// `// ignore: impeccable_textstyle_outside_theme` quando justificado.
///
/// Esta versão proof é simples: detecta `TextStyle(...)` literal aparecendo
/// num argumento. Versão mais sofisticada faria type-flow para confirmar que
/// não vem de `textTheme.*` por copyWith. Type-flow ficaria para v0.2.
class TextStyleOutsideTheme extends DartLintRule {
  TextStyleOutsideTheme() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_textstyle_outside_theme',
    problemMessage:
        'TextStyle literal hard-codado quebra Dynamic Type e dark mode.',
    correctionMessage:
        'Use Theme.of(context).textTheme.bodyLarge (ou outro papel M3) e '
        '.copyWith(...) se precisa override pontual.',
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

      // Heurística simples: TextStyle(...) com pelo menos um argumento literal
      // é cheiro. TextStyle() vazio passa.
      if (node.argumentList.arguments.isEmpty) return;

      reporter.atNode(node, _code);
    });
  }
}
