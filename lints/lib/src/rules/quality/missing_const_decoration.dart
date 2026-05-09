import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `BoxDecoration(...)`, `TextStyle(...)`, `EdgeInsets.all(N)` etc.
/// sem `const` quando todos os argumentos são literais const-able. O lint
/// padrão `prefer_const_constructors` cobre o caso geral; esta regra foca
/// nos quatro tipos que mais aparecem em hot path de UI Flutter e cuja
/// alocação por frame mais machuca performance:
///
///  - `BoxDecoration` em `Container.decoration`
///  - `TextStyle` em `Text.style`
///  - `EdgeInsets.*` em `Padding.padding` / `Container.margin`
///  - `BorderRadius.circular(N)` em `BoxDecoration.borderRadius`
///
/// Categoria: quality. Reportado quando o construtor é candidate (todos
/// args const) e `const` keyword está ausente.
class MissingConstDecoration extends DartLintRule {
  MissingConstDecoration() : super(code: _code);

  static const _hotPathTypes = {
    'BoxDecoration',
    'TextStyle',
    'EdgeInsets',
    'EdgeInsetsDirectional',
    'BorderRadius',
    'BoxConstraints',
  };

  static const _code = LintCode(
    name: 'impeccable_missing_const_decoration',
    problemMessage:
        'BoxDecoration/TextStyle/EdgeInsets/BorderRadius literal sem const '
        'aloca por frame em hot path.',
    correctionMessage:
        'Adicione `const` antes do construtor. Se algum argumento não for '
        'const-able, extraia constantes para tokens via ThemeExtension.',
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
      if (!_hotPathTypes.contains(type)) return;

      // Já é const? skip.
      if (node.keyword?.lexeme == 'const') return;
      // Está dentro de outra expressão const? skip (Dart já elide const aninhado).
      if (_isInsideConstContext(node)) return;

      // Todos os args devem ser potencialmente const (literais simples,
      // const expressions). Heurística: se source não contém referência a
      // identificador minúsculo que não seja Color/Colors/etc., assume OK.
      // Versão mais robusta usaria type-flow.
      if (!_argsLookConstAble(node)) return;

      reporter.atNode(node.constructorName, _code);
    });
  }

  bool _isInsideConstContext(AstNode node) {
    var current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression &&
          current.keyword?.lexeme == 'const') {
        return true;
      }
      // Dentro de listas/maps const também elide.
      if (current is ListLiteral && current.constKeyword != null) return true;
      if (current is SetOrMapLiteral && current.constKeyword != null) {
        return true;
      }
      current = current.parent;
    }
    return false;
  }

  bool _argsLookConstAble(InstanceCreationExpression node) {
    for (final arg in node.argumentList.arguments) {
      final expr = arg is NamedExpression ? arg.expression : arg;
      // Se expressão é literal numérico, string, booleano, null, OK.
      if (expr is Literal) continue;
      // Color literal (Color(0xFF...)) precisa ser const também
      if (expr is InstanceCreationExpression) {
        if (expr.keyword?.lexeme == 'const') continue;
        // Color(0xFF...) sem const não é const-able sem alteração
        return false;
      }
      // PrefixedIdentifier (Colors.black, FontWeight.w700, EdgeInsets.zero) OK
      if (expr is PrefixedIdentifier) continue;
      // SimpleIdentifier referenciando const — não dá para verificar sem
      // type-flow. Conservadoramente, skip.
      return false;
    }
    return true;
  }
}
