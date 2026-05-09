import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `ShaderMask` envolvendo um `Text` com `LinearGradient`/`RadialGradient`
/// ou similar. Gradient text é decorativo, raramente significativo, e leio
/// como AI slop quando aplicado em hero copy.
///
/// Categoria: slop. O ban absoluto do impeccable parent: gradient text só
/// existe para chamar atenção para si mesmo, não para o conteúdo. Use peso,
/// tamanho e cor sólida do `colorScheme.primary`.
class GradientText extends DartLintRule {
  GradientText() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_gradient_text',
    problemMessage:
        'ShaderMask + gradient sobre Text é decorativo. Use peso/tamanho.',
    correctionMessage:
        'Substitua por TextStyle com fontWeight maior (w900) ou cor sólida '
        '(`scheme.primary`). Hierarquia tipográfica nunca é gradient.',
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
      if (type != 'ShaderMask') return;

      // Heurística: o callback `shaderCallback:` retorna um Gradient e o
      // child é Text. Usamos string match no source porque type-flow exige
      // resolução pesada.
      final src = node.toSource();
      final hasGradient = src.contains('Gradient(') ||
          src.contains('LinearGradient') ||
          src.contains('RadialGradient') ||
          src.contains('SweepGradient');
      final hasText = src.contains('Text(');

      if (hasGradient && hasText) {
        reporter.atNode(node, _code);
      }
    });
  }
}
