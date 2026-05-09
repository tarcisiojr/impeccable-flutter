import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta criação de `TextTheme(...)` com `fontFamily:` em todos os papéis
/// E todos com a mesma família. Brand surfaces ganham distinção quando há
/// pareamento de pelo menos uma família de display + uma de body.
///
/// Categoria: slop. Para product, single-font costuma ser CORRETO (Inter
/// stack carrega tudo). Para brand, indica falta de pairing intencional.
///
/// Heurística simples: TextTheme literal com >=4 papéis declarados, e a
/// mesma `fontFamily` em todos. Severity INFO porque legítimo em product.
class SingleFont extends DartLintRule {
  SingleFont() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_single_font',
    problemMessage:
        'TextTheme com mesma fontFamily em todos os papéis. Para brand, '
        'considere display + body distintos.',
    correctionMessage:
        'Pareie display serif + sans body (editorial), ou um sans único com '
        'contraste forte de peso. Ver brand.md > Pairing.',
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
      if (type != 'TextTheme') return;

      // Pegar fontFamily de cada TextStyle filho.
      final families = <String?>{};
      var styleCount = 0;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        // Cada papel M3 (displayLarge, headlineMedium, bodyLarge, ...) é
        // construído como TextStyle.
        final expr = arg.expression;
        if (expr is! InstanceCreationExpression) continue;
        if (expr.constructorName.type.name2.lexeme != 'TextStyle') continue;
        styleCount++;

        String? family;
        for (final inner in expr.argumentList.arguments) {
          if (inner is! NamedExpression) continue;
          if (inner.name.label.name != 'fontFamily') continue;
          if (inner.expression is SimpleStringLiteral) {
            family = (inner.expression as SimpleStringLiteral).value;
          }
        }
        families.add(family);
      }

      // Só flag se houver pelo menos 4 papéis E todos com mesma família
      // não-null (família null = system, OK).
      if (styleCount >= 4 && families.length == 1 && families.first != null) {
        reporter.atNode(node.constructorName, _code);
      }
    });
  }
}
