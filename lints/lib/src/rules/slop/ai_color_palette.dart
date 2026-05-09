import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `seedColor` ou `Color(0xFF...)` literal correspondendo a hues que
/// dominam apps gerados por IA: a família roxo-azul (#5B21B6, #6366F1,
/// #8B5CF6, #7C3AED, #A78BFA, #4F46E5).
///
/// Categoria: slop. Cores não são erradas em si, mas a frequência destas
/// específicas em apps Flutter "novos" é alarmante. É um second-order
/// reflex: já evitou deepPurple, caiu na próxima cor "AI" mais comum.
class AiColorPalette extends DartLintRule {
  AiColorPalette() : super(code: _code);

  /// Hex (sem alpha, lowercase) das cores mais comuns em Flutter apps de IA.
  static const _aiHexes = {
    '5b21b6', // violet-800
    '6d28d9', // violet-700
    '7c3aed', // violet-600
    '8b5cf6', // violet-500
    'a78bfa', // violet-400
    '4f46e5', // indigo-600
    '6366f1', // indigo-500
    '818cf8', // indigo-400
    '4338ca', // indigo-700
    '3730a3', // indigo-800
  };

  static const _code = LintCode(
    name: 'impeccable_ai_color_palette',
    problemMessage:
        'Cor da família roxo/índigo dominante em apps Flutter gerados por IA.',
    correctionMessage:
        'Escolha uma cor de marca derivada da identidade do produto (não de '
        'training data defaults). oklch.com ajuda a explorar hues incomuns.',
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
      if (type != 'Color') return;

      // Color(0xFF5B21B6) ou Color(0x_______): pega a string hex.
      for (final arg in node.argumentList.arguments) {
        final src = arg.toSource().toLowerCase().replaceAll('_', '');
        // Match 0xFF<hex6> ou 0x<hex8>
        final hex6 = RegExp(r'0x[0-9a-f]{2}([0-9a-f]{6})').firstMatch(src);
        if (hex6 == null) continue;
        final candidate = hex6.group(1)!;
        if (_aiHexes.contains(candidate)) {
          reporter.atNode(node, _code);
        }
      }
    });
  }
}
