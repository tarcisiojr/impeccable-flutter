import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Scaffold(extendBodyBehindAppBar: true, ...)` ou `Scaffold` cujo
/// body imediatamente é um widget que cobre tudo (`Stack`, `Container`,
/// `DecoratedBox`) sem `SafeArea` no caminho.
///
/// Categoria: quality. `Scaffold.body` aplica `SafeArea` em padrão, mas
/// `extendBodyBehindAppBar: true` e overlays full-screen (modais, splash,
/// telas de câmera) precisam declarar.
///
/// Heurística simples: flag `Scaffold(extendBodyBehindAppBar: true)` sem
/// detectar SafeArea descendente (string match). Versão melhor faria walk
/// real da árvore. False positives possíveis quando SafeArea está em
/// componente filho não inlineable; ignore quando justificado.
class MissingSafeArea extends DartLintRule {
  MissingSafeArea() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_missing_safe_area',
    problemMessage:
        'Scaffold com extendBodyBehindAppBar: true sem SafeArea explícita.',
    correctionMessage:
        'Envolva o body com SafeArea(...). Notch e gesture bar comem '
        'conteúdo silenciosamente sem isso.',
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
      if (type != 'Scaffold') return;

      final args = node.argumentList.arguments;

      // Apenas flag se extendBodyBehindAppBar: true OU extendBody: true
      final extendsBody = args.any((arg) {
        if (arg is! NamedExpression) return false;
        final n = arg.name.label.name;
        if (n != 'extendBodyBehindAppBar' && n != 'extendBody') return false;
        final v = arg.expression;
        return v is BooleanLiteral && v.value;
      });
      if (!extendsBody) return;

      // Procura SafeArea no source (heurística simples).
      final src = node.toSource();
      if (!src.contains('SafeArea')) {
        reporter.atNode(node.constructorName, _code);
      }
    });
  }
}
