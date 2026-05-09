import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `Text('STRING TODA EM UPPERCASE')` com >12 chars. Body em ALL-CAPS
/// reduz readability dramaticamente; aceitável só em labels curtos (chip,
/// eyebrow, button label opcional).
///
/// Categoria: quality. Mais que 12 chars + tudo uppercase é cheiro.
/// Para emphasis use `FontWeight.w700` ou cor; para labels curtos
/// (`labelSmall`), aplicar via `String.toUpperCase()` no callsite e adicionar
/// `letterSpacing` 0.5-1.5.
class AllCapsBody extends DartLintRule {
  AllCapsBody() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_all_caps_body',
    problemMessage:
        'String em ALL-CAPS com >12 chars no Text reduz readability.',
    correctionMessage:
        'Use case mixed e enfatize via FontWeight ou cor. ALL-CAPS só em '
        'labels curtos (<=12 chars) com letterSpacing 0.5-1.5.',
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
      if (type != 'Text' && type != 'SelectableText') return;

      if (node.argumentList.arguments.isEmpty) return;
      final first = node.argumentList.arguments.first;
      if (first is! StringLiteral) return;

      // Pega valor da string. Não tentamos resolver interpolation complexa.
      String? value;
      if (first is SimpleStringLiteral) value = first.value;
      if (value == null) return;
      if (value.length <= 12) return;

      // É all-caps se uppercase(value) == value E há pelo menos uma letra
      final hasLetter = value.contains(RegExp(r'[A-Za-zÀ-ÿ]'));
      if (!hasLetter) return;
      if (value.toUpperCase() != value) return;

      reporter.atNode(first, _code);
    });
  }
}
