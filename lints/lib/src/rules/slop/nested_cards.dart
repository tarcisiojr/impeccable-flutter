import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Card` aninhado dentro de outro `Card`. Anti-pattern clássico:
/// produz double border + double elevation + visual noise.
///
/// Categoria: slop. Hierarquia interna a um `Card` deve usar spacing,
/// `Divider` sutil, ou `surfaceTint` mais alto. Nunca outro `Card`.
class NestedCards extends DartLintRule {
  NestedCards() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_nested_cards',
    problemMessage:
        'Card aninhado em Card produz double border e visual noise.',
    correctionMessage:
        'Use Padding + Divider para hierarquia interna ao Card pai. Para '
        'elevation diferente, surfaceContainerHigh em vez de outro Card.',
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
      if (type != 'Card') return;

      // Walk ancestors looking for outer Card.
      AstNode? parent = node.parent;
      while (parent != null) {
        if (parent is InstanceCreationExpression) {
          final parentType = parent.constructorName.type.name2.lexeme;
          if (parentType == 'Card') {
            reporter.atNode(node, _code);
            return;
          }
        }
        parent = parent.parent;
      }
    });
  }
}
