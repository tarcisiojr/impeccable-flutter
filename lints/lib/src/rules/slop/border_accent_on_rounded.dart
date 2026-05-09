import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `BoxDecoration(border: Border.all(width: >2), borderRadius:
/// BorderRadius.circular(...))`. Borda grossa colorida em retângulo
/// arredondado é tell de "AI Material 3 tutorial card".
///
/// Categoria: slop. Em M3, separação de superfícies vem de `surfaceContainer*`
/// + `Material(elevation:)`. Borda grossa colorida raramente é intencional;
/// quando é (badge, chip), borderRadius alto + borda fina (1) faz sentido.
class BorderAccentOnRounded extends DartLintRule {
  BorderAccentOnRounded() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_border_accent_on_rounded',
    problemMessage:
        'Border.all >2 + borderRadius arredondado lê como "AI tutorial card".',
    correctionMessage:
        'Use Material(elevation:) + surfaceContainerHigh para hierarquia M3. '
        'Se a borda é intencional, mantenha width <= 1 (hairline).',
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
      if (type != 'BoxDecoration') return;

      final src = node.toSource();
      final hasBorderAll = src.contains('Border.all');
      final hasRadius = src.contains('borderRadius');
      if (!hasBorderAll || !hasRadius) return;

      // Width >2 → flag. Regex tolerante a parênteses aninhados via [\s\S]*?.
      final widthMatch = RegExp(
        r'Border\.all\([\s\S]*?width\s*:\s*(\d+(?:\.\d+)?)',
      ).firstMatch(src);
      if (widthMatch == null) return;
      final width = double.tryParse(widthMatch.group(1)!) ?? 0;
      if (width > 2) {
        reporter.atNode(node, _code);
      }
    });
  }
}
