import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta o padrão "eyebrow chip + hero text": um `Container` arredondado
/// pequeno (com `BoxDecoration(borderRadius:)` e padding pequeno) seguido
/// imediatamente por um `Text` em display size dentro de uma `Column`.
///
/// Categoria: slop. É o template Stripe-clone que dominou Material 3
/// tutorials: chip pequeno em uppercase no topo + headline gigante embaixo.
/// Indica falta de hierarquia tipográfica forte; a marca tenta vender
/// "categoria" via chip em vez de via composição.
///
/// Heurística: dentro de uma `Column`, achar Container pequeno com
/// borderRadius seguido de Text imediato. Pode produzir falso positivo em
/// "label de seção legítimo + título"; aceite via `// ignore: ...` quando
/// for design intencional.
class HeroEyebrowChip extends DartLintRule {
  HeroEyebrowChip() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_hero_eyebrow_chip',
    problemMessage:
        'Eyebrow chip + headline grande em Column é template Stripe-clone.',
    correctionMessage:
        'Confie na hierarquia tipográfica: displayLarge bold + bodyMedium '
        'sem chip. Se categoria importa, use cor de fundo na seção, não chip.',
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
      if (type != 'Column') return;

      // Pegar lista `children:`
      final childrenArg = node.argumentList.arguments.whereType<NamedExpression>()
          .where((a) => a.name.label.name == 'children')
          .firstOrNull;
      if (childrenArg == null) return;

      final list = childrenArg.expression;
      if (list is! ListLiteral) return;
      final items = list.elements;
      if (items.length < 2) return;

      // Procurar par adjacente: Container/Chip pequeno arredondado seguido
      // por Text grande.
      for (var i = 0; i < items.length - 1; i++) {
        final a = items[i];
        final b = items[i + 1];
        if (_isEyebrowChip(a) && _isHeroText(b)) {
          reporter.atNode(node.constructorName, _code);
          return;
        }
      }
    });
  }

  bool _isEyebrowChip(CollectionElement node) {
    if (node is! InstanceCreationExpression) return false;
    final type = node.constructorName.type.name2.lexeme;
    if (type != 'Container' && type != 'Chip' && type != 'DecoratedBox') {
      return false;
    }
    final src = node.toSource();
    // Heurística: tem borderRadius (arredondado) E (cor de fundo OU pequeno).
    return src.contains('borderRadius') &&
        (src.contains('color:') || src.contains('padding:'));
  }

  bool _isHeroText(CollectionElement node) {
    if (node is! InstanceCreationExpression) return false;
    final type = node.constructorName.type.name2.lexeme;
    if (type != 'Text') return false;
    final src = node.toSource();
    // Heurística: estilo aponta para display* ou tem fontSize >32 literal.
    if (src.contains('displayLarge') ||
        src.contains('displayMedium') ||
        src.contains('displaySmall') ||
        src.contains('headlineLarge')) {
      return true;
    }
    // ou fontSize literal grande
    final m = RegExp(r'fontSize\s*:\s*(\d+)').firstMatch(src);
    if (m != null) {
      final v = int.tryParse(m.group(1)!) ?? 0;
      if (v > 32) return true;
    }
    return false;
  }
}
