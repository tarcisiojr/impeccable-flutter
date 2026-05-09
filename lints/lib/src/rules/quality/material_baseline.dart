import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `MaterialApp(...)` sem `theme:` declarado. App fica com look
/// default Material 2 (a menos que useMaterial3 esteja em true por SDK
/// version) e parece "flutter create app".
///
/// Categoria: quality + slop. Mesmo que useMaterial3 default seja true em
/// 3.16+, o `MaterialApp` precisa de `theme:` explícito com cor de marca.
class MaterialBaseline extends DartLintRule {
  MaterialBaseline() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_material_baseline',
    problemMessage:
        'MaterialApp sem theme: definido cai no look default ("flutter create").',
    correctionMessage:
        'Adicione theme: ThemeData(useMaterial3: true, colorScheme: '
        'ColorScheme.fromSeed(seedColor: <brand>)) e darkTheme: equivalente.',
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
      if (type != 'MaterialApp' && type != 'CupertinoApp') return;

      final hasTheme = node.argumentList.arguments.any((arg) {
        if (arg is! NamedExpression) return false;
        final name = arg.name.label.name;
        return name == 'theme' || name == 'darkTheme';
      });
      if (!hasTheme) {
        reporter.atNode(node.constructorName, _code);
      }
    });
  }
}
