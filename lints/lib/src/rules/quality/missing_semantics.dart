import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `GestureDetector` ou `InkWell` interativo (com `onTap:` definido)
/// sem `Semantics` ancestor próximo OU sem child que carregue label
/// (`Text`, `Icon` com `semanticLabel:`, etc.).
///
/// Categoria: quality. Sem isso, screen reader (TalkBack/VoiceOver) lê
/// "tocável" sem contexto. Para widgets visuais sem texto óbvio, embrulhe
/// em `Semantics(label: 'Verbo objeto', button: true, child: ...)`.
///
/// Heurística simples: flag `GestureDetector(onTap: ...)` ou
/// `InkWell(onTap: ...)` cujo source não contém `Semantics(` nem `Text(`
/// nem `tooltip:` nem `semanticLabel:`. False positives possíveis quando
/// label vive em widget filho separado; use `// ignore: ...`.
class MissingSemantics extends DartLintRule {
  MissingSemantics() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_missing_semantics',
    problemMessage:
        'GestureDetector/InkWell interativo sem label semântico óbvio.',
    correctionMessage:
        'Embrulhe em Semantics(label: "Verbo objeto", button: true, child: ...) '
        'ou adicione Text/Icon com semanticLabel no child.',
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
      if (type != 'GestureDetector' && type != 'InkWell') return;

      // Precisa ter onTap (ou onLongPress, etc.) para ser interativo.
      final hasInteractive = node.argumentList.arguments.any((arg) {
        if (arg is! NamedExpression) return false;
        const handlers = {
          'onTap',
          'onTapDown',
          'onLongPress',
          'onDoubleTap',
          'onSecondaryTap',
        };
        return handlers.contains(arg.name.label.name);
      });
      if (!hasInteractive) return;

      // Source contém algo que sugere label?
      final src = node.toSource();
      final hasLabel = src.contains('Semantics(') ||
          src.contains('semanticLabel:') ||
          src.contains('Text(') ||
          src.contains('tooltip:');
      if (!hasLabel) {
        reporter.atNode(node.constructorName, _code);
      }
    });
  }
}
