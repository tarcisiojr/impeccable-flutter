import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta chamada direta a `GoogleFonts.<defaultFont>(...)` em qualquer
/// lugar fora do `theme/text_themes.dart`. As fontes da reflex-reject list
/// são: Inter, DM Sans, Plus Jakarta Sans, Outfit, Instrument Sans/Serif,
/// IBM Plex *, Space Grotesk/Mono, Fraunces, Crimson*, Newsreader, Lora,
/// Playfair Display, Cormorant*, Syne, DM Serif*.
///
/// Categoria: slop. Essas fontes não são erradas em si, mas são os defaults
/// de training data. Em decisão new design, escolha algo fora desta lista
/// (ver brand.md).
class OverusedFont extends DartLintRule {
  OverusedFont() : super(code: _code);

  static const _bannedFonts = {
    'inter',
    'dmSans',
    'dmSerifDisplay',
    'dmSerifText',
    'plusJakartaSans',
    'outfit',
    'instrumentSans',
    'instrumentSerif',
    'iBMPlexSans',
    'iBMPlexMono',
    'iBMPlexSerif',
    'spaceGrotesk',
    'spaceMono',
    'fraunces',
    'crimson',
    'crimsonPro',
    'crimsonText',
    'newsreader',
    'lora',
    'playfairDisplay',
    'cormorant',
    'cormorantGaramond',
    'syne',
  };

  static const _code = LintCode(
    name: 'impeccable_overused_font',
    problemMessage:
        'GoogleFonts default da reflex-reject list (Inter, DM Sans, Fraunces, etc.).',
    correctionMessage:
        'Procure fontes fora da lista (Klim, Pangram Pangram, Velvetyne, '
        'ABC Dinamo). Veja brand.md > "Reflex-reject list".',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Estratégia: scan source de toda InstanceCreationExpression (Text,
    // ThemeData, MaterialApp, etc.) procurando padrão GoogleFonts.<font>(.
    // Reportado uma vez por uso. Funciona porque InstanceCreationExpression
    // dispara confiavelmente em custom_lint 0.7.5 (testado em outras regras).
    context.registry.addInstanceCreationExpression((node) {
      final src = node.toSource();
      // Match inline GoogleFonts.<x>( em qualquer lugar do source
      final pattern = RegExp(
        r'GoogleFonts\.(\w+)\(',
      );
      for (final match in pattern.allMatches(src)) {
        final method = match.group(1)!;
        final base = method.endsWith('TextTheme')
            ? method.substring(0, method.length - 'TextTheme'.length)
            : method;
        if (_bannedFonts.contains(base)) {
          reporter.atNode(node.constructorName, _code);
          return; // 1 finding por instance creation basta
        }
      }
    });
  }
}
