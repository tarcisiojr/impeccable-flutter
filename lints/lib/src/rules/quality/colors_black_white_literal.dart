import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Colors.black` ou `Colors.white` literal usado em código de UI.
/// Quebra dark mode silenciosamente: literais não respondem a brightness.
///
/// Categoria: quality. Substituir por:
///   - `Theme.of(context).colorScheme.onSurface` para texto escuro em light /
///     claro em dark
///   - `Theme.of(context).colorScheme.surface` para fundo
///   - `Theme.of(context).colorScheme.shadow` para sombra
///
/// False positives aceitáveis: tests, themes/, splash screen estática,
/// SystemUiOverlayStyle. Adicione `// ignore: impeccable_black_white_literal`.
class ColorsBlackWhiteLiteral extends DartLintRule {
  ColorsBlackWhiteLiteral() : super(code: _code);

  static const _bannedColors = {
    'black',
    'black87',
    'black54',
    'black45',
    'black38',
    'black26',
    'black12',
    'white',
    'white70',
    'white60',
    'white54',
    'white38',
    'white30',
    'white24',
    'white12',
    'white10',
  };

  static const _code = LintCode(
    name: 'impeccable_black_white_literal',
    problemMessage:
        'Colors.black/white literal quebra dark mode. Use ColorScheme.',
    correctionMessage:
        'Substitua por Theme.of(context).colorScheme.onSurface (texto), '
        '.surface (fundo), .shadow (sombra), ou outro papel M3 apropriado.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPrefixedIdentifier((node) {
      if (node.prefix.name == 'Colors' &&
          _bannedColors.contains(node.identifier.name)) {
        reporter.atNode(node, _code);
      }
    });
  }
}
