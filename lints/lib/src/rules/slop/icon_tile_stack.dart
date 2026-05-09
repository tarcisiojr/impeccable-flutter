import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta o padrão "feature grid": `Column` com `Container/Card` arredondado
/// contendo `Icon` no topo + 1-2 `Text` abaixo, repetido em irmãos numa
/// `Row`/`GridView`/`Wrap`. É o template SaaS landing page mais saturado
/// pelo Material 3 tutorials.
///
/// Categoria: slop. Em vez disso, considere lista vertical com ícone
/// inline + texto longo, ou hero image + descrição, ou simplesmente prosa
/// com bullet points. Tile-grid genérico é o pior cenário.
///
/// Heurística: dentro de uma `Row` ou `GridView` ou `Wrap`, ≥3 children
/// que sejam `Container`/`Card` cujo source contém pattern `Icon(` +
/// `Text(`. Reportado uma vez por container pai.
class IconTileStack extends DartLintRule {
  IconTileStack() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_icon_tile_stack',
    problemMessage:
        'Grid de tiles "Icon + Text + Text" repetidos é template SaaS landing.',
    correctionMessage:
        'Use lista vertical com Icon inline + texto, ou hero image + '
        'descrição. Tiles genéricos são reflex-reject.',
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
      if (type != 'Row' && type != 'Wrap' && type != 'GridView') return;

      // children: [...]
      final childrenArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((a) => a.name.label.name == 'children')
          .firstOrNull;
      if (childrenArg == null) return;

      final list = childrenArg.expression;
      if (list is! ListLiteral) return;
      final items = list.elements;
      if (items.length < 3) return;

      var tileCount = 0;
      for (final item in items) {
        if (_isIconTextTile(item)) tileCount++;
      }
      if (tileCount >= 3) {
        reporter.atNode(node.constructorName, _code);
      }
    });
  }

  bool _isIconTextTile(CollectionElement node) {
    if (node is! InstanceCreationExpression) return false;
    final type = node.constructorName.type.name2.lexeme;
    if (type != 'Container' &&
        type != 'Card' &&
        type != 'Padding' &&
        type != 'DecoratedBox') {
      return false;
    }
    final src = node.toSource();
    return src.contains('Icon(') && src.contains('Text(');
  }
}
