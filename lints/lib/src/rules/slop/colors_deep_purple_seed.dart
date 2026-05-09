import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`, que é
/// o default literal de `flutter create`. Apps em produção deveriam ter
/// uma seedColor de marca explícita.
///
/// Categoria: slop. É o fingerprint mais rápido de "Flutter app que ninguém
/// customizou tema".
class ColorsDeepPurpleSeed extends DartLintRule {
  ColorsDeepPurpleSeed() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_deep_purple_seed',
    problemMessage:
        'Colors.deepPurple é a seedColor default de `flutter create`. Defina '
        'uma cor de marca explícita.',
    correctionMessage:
        'Substitua por uma `Color(0xFF...)` derivada da identidade do app, '
        'ou exponha como token em `theme/color_schemes.dart`.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      // Match ColorScheme.fromSeed(...)
      final type = node.constructorName.type.name2.lexeme;
      final ctor = node.constructorName.name?.name;
      if (type != 'ColorScheme' || ctor != 'fromSeed') return;

      // Procura argumento nomeado seedColor: Colors.deepPurple
      for (final arg in node.argumentList.arguments) {
        if (arg.toSource().contains('Colors.deepPurple')) {
          reporter.atNode(arg, _code);
        }
      }
    });
  }
}
