import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `TextStyle(fontStyle: FontStyle.italic, fontFamily: '<serif>',
/// fontSize: >32)`. O combo italic + serif em display size é o fingerprint
/// da lane editorial-tipográfica (Fraunces/Lora/Newsreader em italic gigante)
/// que saturou Stripe-adjacent e Notion-adjacent brand surfaces.
///
/// Categoria: slop. Não erro estético em si, mas sinal de second-order
/// reflex (já evitou Inter/Roboto, caiu no editorial italic). Se a marca
/// é literalmente magazine, ignore. Caso contrário, considere algo mais
/// distintivo.
///
/// Heurística: TextStyle com fontStyle italic + fontFamily contendo um nome
/// reflex-rejected da lista serif + fontSize >32.
class ItalicSerifDisplay extends DartLintRule {
  ItalicSerifDisplay() : super(code: _code);

  static const _serifFonts = {
    'Fraunces',
    'Lora',
    'Crimson',
    'Crimson Pro',
    'Crimson Text',
    'Newsreader',
    'Playfair Display',
    'Cormorant',
    'Cormorant Garamond',
    'DM Serif Display',
    'DM Serif Text',
    'Recoleta',
  };

  static const _code = LintCode(
    name: 'impeccable_italic_serif_display',
    problemMessage:
        'Italic + serif (Fraunces/Lora/Newsreader/etc.) em display size é a '
        'lane editorial saturada por brand sites de IA.',
    correctionMessage:
        'Para magazine real, OK. Para outros briefs, considere display sans '
        'condensed, hand-drawn, ou serif menos óbvio. Ver brand.md.',
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
      if (type != 'TextStyle') return;

      var italic = false;
      String? family;
      double? size;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        final expr = arg.expression;
        if (name == 'fontStyle' && expr.toSource() == 'FontStyle.italic') {
          italic = true;
        }
        if (name == 'fontFamily' && expr is SimpleStringLiteral) {
          family = expr.value;
        }
        if (name == 'fontSize') {
          if (expr is IntegerLiteral) size = (expr.value ?? 0).toDouble();
          if (expr is DoubleLiteral) size = expr.value;
        }
      }

      if (italic &&
          family != null &&
          _serifFonts.contains(family) &&
          (size ?? 0) > 32) {
        reporter.atNode(node, _code);
      }
    });
  }
}
