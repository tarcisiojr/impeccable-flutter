import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta uso excessivo de `Center(...)` ou `MainAxisAlignment.center`
/// no mesmo arquivo (≥6 ocorrências combinadas). Sinal de "tudo centralizado"
/// que mata composição assimétrica e leio como template AI.
///
/// Categoria: slop. Centralização pontual é fine; sistemática é o anti-pattern.
/// `Align(alignment: Alignment.centerStart)` ou layouts assimétricos via
/// `Row` + `Expanded` em proporção 70/30 são alternativas.
///
/// Heurística: contagem por arquivo. Não rastreia hierarchy, só density.
/// Reportado na primeira ocorrência. False positives possíveis em telas
/// genuinamente centradas (login, splash, error). Use `// ignore: ...`.
class EverythingCentered extends DartLintRule {
  EverythingCentered() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_everything_centered',
    problemMessage:
        'Tudo centralizado no arquivo (≥6 Center/MainAxisAlignment.center). '
        'Composição assimétrica costuma ler "designed", centered-stack lê template.',
    correctionMessage:
        'Considere Align(alignment: Alignment.centerStart), Row + Expanded em '
        '70/30, ou Stack + Positioned para hierarquia mais decisiva.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    AstNode? firstHit;
    var count = 0;

    void visit(AstNode node) {
      if (firstHit == null) firstHit = node;
      count++;
    }

    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.name2.lexeme;
      if (type == 'Center') visit(node);
    });

    context.registry.addPrefixedIdentifier((node) {
      if (node.prefix.name == 'MainAxisAlignment' &&
          node.identifier.name == 'center') {
        visit(node);
      }
      if (node.prefix.name == 'CrossAxisAlignment' &&
          node.identifier.name == 'center') {
        visit(node);
      }
    });

    context.registry.addCompilationUnit((_) {
      if (count >= 6 && firstHit != null) {
        reporter.atNode(firstHit!, _code);
      }
    });
  }
}
