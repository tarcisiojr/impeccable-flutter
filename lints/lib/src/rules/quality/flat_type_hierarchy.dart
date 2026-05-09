import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `TextTheme(...)` com `fontSize` ratios <1.2 entre papéis
/// adjacentes ordenados (display, headline, title, body, label).
/// Hierarquia "flat" (1.05x-1.15x) lê como muddy: usuário não percebe
/// diferença entre headlineLarge e headlineMedium.
///
/// Categoria: quality. Material 3 default usa razões 1.125-1.27. Customizar
/// abaixo disso geralmente é perda. Para hierarquia decisiva, use ≥1.25.
///
/// Heurística: extrair fontSize de cada TextStyle filho do TextTheme,
/// agrupar por papel (display*, headline*, title*, body*, label*), e checar
/// se entre dois papéis adjacentes (ex: displayLarge e displayMedium) o
/// ratio é <1.2.
class FlatTypeHierarchy extends DartLintRule {
  FlatTypeHierarchy() : super(code: _code);

  /// Ordem M3: cada par (large, medium) e (medium, small) dentro de uma
  /// família deveria ter ratio >=1.2. Listamos só os pares relevantes.
  static const _adjacentPairs = [
    ['displayLarge', 'displayMedium'],
    ['displayMedium', 'displaySmall'],
    ['headlineLarge', 'headlineMedium'],
    ['headlineMedium', 'headlineSmall'],
    ['titleLarge', 'titleMedium'],
    ['titleMedium', 'titleSmall'],
    ['bodyLarge', 'bodyMedium'],
    ['bodyMedium', 'bodySmall'],
    ['labelLarge', 'labelMedium'],
    ['labelMedium', 'labelSmall'],
  ];

  static const _code = LintCode(
    name: 'impeccable_flat_type_hierarchy',
    problemMessage:
        'TextTheme com fontSize ratio <1.2 entre papéis adjacentes = '
        'hierarquia flat e muddy.',
    correctionMessage:
        'Use ratio ≥1.2 entre níveis (display: 57/45/36 = 1.27/1.25; '
        'body: 16/14/12 = 1.14 default M3 OK porque o salto principal já '
        'foi entre title e body). Customize com cuidado.',
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
      if (type != 'TextTheme') return;

      // Extrair fontSize por papel.
      final sizes = <String, double>{};
      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final role = arg.name.label.name;
        final expr = arg.expression;
        if (expr is! InstanceCreationExpression) continue;
        if (expr.constructorName.type.name2.lexeme != 'TextStyle') continue;

        for (final inner in expr.argumentList.arguments) {
          if (inner is! NamedExpression) continue;
          if (inner.name.label.name != 'fontSize') continue;
          final v = inner.expression;
          double? size;
          if (v is IntegerLiteral) size = (v.value ?? 0).toDouble();
          if (v is DoubleLiteral) size = v.value;
          if (size != null) sizes[role] = size;
        }
      }

      // Checar pares adjacentes.
      for (final pair in _adjacentPairs) {
        final big = sizes[pair[0]];
        final small = sizes[pair[1]];
        if (big == null || small == null) continue;
        if (small <= 0) continue;
        final ratio = big / small;
        if (ratio < 1.2) {
          reporter.atNode(node.constructorName, _code);
          return; // 1 finding por TextTheme basta
        }
      }
    });
  }
}
