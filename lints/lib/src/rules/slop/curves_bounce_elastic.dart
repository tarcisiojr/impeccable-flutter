import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta uso de `Curves.bounceIn`, `Curves.bounceOut`, `Curves.bounceInOut`,
/// `Curves.elasticIn`, `Curves.elasticOut`, `Curves.elasticInOut` em código de
/// produto.
///
/// Categoria: slop. Bounce/elastic foram trend em 2015, hoje leem amador e
/// barateiam o efeito. Real objects don't bounce when they stop.
///
/// Para entrance / state change use `Curves.easeOutCubic`, `easeOutQuart`, ou
/// `easeOutExpo`. Material 3 emphasized motion usa essas curvas.
class CurvesBounceElastic extends DartLintRule {
  CurvesBounceElastic() : super(code: _code);

  static const _bannedCurves = {
    'bounceIn',
    'bounceOut',
    'bounceInOut',
    'elasticIn',
    'elasticOut',
    'elasticInOut',
  };

  static const _code = LintCode(
    name: 'impeccable_bounce_elastic_curve',
    problemMessage:
        'Curves.bounce*/elastic* leem amador em product. Use easeOutCubic, '
        'easeOutQuart, ou easeOutExpo.',
    correctionMessage:
        'Substitua por `Curves.easeOutCubic` (default), `Curves.easeOutQuart` '
        '(refinado), ou Cubic(0.16, 1, 0.3, 1) para easeOutExpo manual.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPrefixedIdentifier((node) {
      // Match Curves.<bannedCurve>
      if (node.prefix.name == 'Curves' &&
          _bannedCurves.contains(node.identifier.name)) {
        reporter.atNode(node, _code);
      }
    });
  }
}
