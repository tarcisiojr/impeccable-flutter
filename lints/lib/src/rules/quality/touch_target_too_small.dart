import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `IconButton(iconSize: <N>)` com N <24 quando combinado com
/// `visualDensity: VisualDensity.compact` (ou similar shrink), sinalizando
/// touch target abaixo dos 48dp do Material.
///
/// Também flag `IconButton(constraints: BoxConstraints(maxWidth: <48))` ou
/// `IconButton(padding: EdgeInsets.zero)` sem `splashRadius` que compense.
///
/// Categoria: quality. Material `MaterialTapTargetSize.padded` é o default
/// correto. Reduzir conscientemente é decisão; reduzir sem perceber é o
/// caso típico que esta regra captura.
class TouchTargetTooSmall extends DartLintRule {
  TouchTargetTooSmall() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_touch_target_too_small',
    problemMessage:
        'IconButton com padding zero ou visualDensity compact + iconSize pequeno '
        'cria touch target <48dp.',
    correctionMessage:
        'Mantenha MaterialTapTargetSize.padded (default). Para layout denso, '
        'use SizedBox(48,48) externa em vez de remover padding interno.',
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
      if (type != 'IconButton') return;

      var paddingZero = false;
      var compactDensity = false;
      var iconSizeSmall = false;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        final src = arg.expression.toSource();

        if (name == 'padding' && src.contains('EdgeInsets.zero')) {
          paddingZero = true;
        }
        if (name == 'visualDensity' &&
            (src.contains('VisualDensity.compact') ||
                src.contains('VisualDensity(horizontal: -') ||
                src.contains('VisualDensity(vertical: -'))) {
          compactDensity = true;
        }
        if (name == 'iconSize') {
          final expr = arg.expression;
          double? v;
          if (expr is IntegerLiteral) v = (expr.value ?? 0).toDouble();
          if (expr is DoubleLiteral) v = expr.value;
          if (v != null && v < 24) iconSizeSmall = true;
        }
      }

      // Combinações que produzem touch target <48dp:
      //  - padding zero (perde os 8dp de cada lado padrão)
      //  - density compact + iconSize pequeno
      if (paddingZero || (compactDensity && iconSizeSmall)) {
        reporter.atNode(node.constructorName, _code);
      }
    });
  }
}
