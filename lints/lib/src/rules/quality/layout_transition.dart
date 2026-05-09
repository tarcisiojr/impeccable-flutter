import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `AnimatedContainer` que anima width/height/padding/margin.
/// Animar essas propriedades dispara relayout em cada frame, custoso e
/// frequentemente jankoso.
///
/// Categoria: quality. Para mudar size animadamente, prefira `AnimatedScale`
/// (transform-only, GPU). Para mudar layout, `AnimatedAlign`/`AnimatedSize`.
/// Para padding, considere `AnimatedPadding` se o impacto é mensurável.
class LayoutTransition extends DartLintRule {
  LayoutTransition() : super(code: _code);

  static const _laidOut = {'width', 'height', 'padding', 'margin', 'constraints'};

  static const _code = LintCode(
    name: 'impeccable_layout_transition',
    problemMessage:
        'AnimatedContainer com width/height/padding causa relayout cada frame.',
    correctionMessage:
        'Use AnimatedScale (transform), AnimatedAlign, ou AnimatedSize. '
        'AnimatedContainer é OK quando muda só cor/decoration.',
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
      if (type != 'AnimatedContainer') return;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        if (_laidOut.contains(arg.name.label.name)) {
          reporter.atNode(arg, _code);
          return;
        }
      }
    });
  }
}
