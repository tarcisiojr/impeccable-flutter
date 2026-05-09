import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta hierarquia incorreta de headings semânticos dentro de um mesmo
/// método `build()`: múltiplos `Semantics(header: true, child: Text(_, style:
/// TextStyle(fontSize: <N>)))` onde os fontSizes não estão em ordem
/// decrescente (h1 → h2 → h3) na ordem de aparição no source.
///
/// Em Flutter, `Semantics(header: true)` é boolean (não tem level h1/h2/h3
/// explícito como HTML), mas screen readers usam o `header` flag para permitir
/// navegação rápida por seções. Quando há múltiplos no mesmo scope visual, a
/// expectativa do leitor é que o tamanho corresponda à importância: h1 grande,
/// h2 médio, h3 menor.
///
/// Categoria: quality (a11y). Acessibilidade real: TalkBack/VoiceOver listam
/// os headings em ordem; se o segundo é maior que o primeiro, o usuário fica
/// desorientado.
///
/// Implementação: agrupa Semantics(header: true) pelo método/função enclosing
/// (geralmente `Widget build(...)`) usando state acumulado por arquivo. Cada
/// novo heading dispara verificação contra o anterior do mesmo escopo. O
/// `addCompilationUnit` callback do custom_lint 0.7.5 não dispara de forma
/// confiável, então a verificação é inline no visitor.
///
/// Limitação: heurística de fontSize literal. fontSizes vindos de textTheme
/// (`Theme.of(context).textTheme.headlineMedium`) não são considerados —
/// pula silenciosamente.
class SkippedHeading extends DartLintRule {
  SkippedHeading() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_skipped_heading',
    problemMessage:
        'Heading semântico fora de ordem: fontSize maior que o heading '
        'anterior no mesmo método. Screen reader vai navegar errado.',
    correctionMessage:
        'Reordene os Semantics(header: true) para que o fontSize seja '
        'decrescente (h1 maior, h2 médio, h3 menor) na ordem do código. '
        'Ou troque para Semantics(label: ...) se não for um header real.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Map: escopo (método/função enclosing) → último fontSize visto.
    final lastSizeByScope = <AstNode?, double>{};

    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.name2.lexeme;
      if (type != 'Semantics') return;

      var hasHeaderTrue = false;
      Expression? childExpr;
      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        if (name == 'header' && arg.expression.toSource().trim() == 'true') {
          hasHeaderTrue = true;
        }
        if (name == 'child') {
          childExpr = arg.expression;
        }
      }
      if (!hasHeaderTrue || childExpr == null) return;

      final fontSize = _extractFontSize(childExpr);
      if (fontSize == null) return; // sem fontSize literal — pula silenciosamente.

      // Identifica o escopo (método ou função enclosing). Isola headings de
      // widgets distintos no mesmo arquivo.
      final scope = node.thisOrAncestorOfType<MethodDeclaration>() ??
          node.thisOrAncestorOfType<FunctionDeclaration>();

      final last = lastSizeByScope[scope];
      if (last != null && fontSize > last) {
        // Heading atual é maior que o anterior do mesmo escopo: ordem errada.
        reporter.atNode(node, _code);
      }
      // Atualiza referência para o próximo heading do mesmo escopo.
      lastSizeByScope[scope] = fontSize;
    });
  }

  /// Procura `Text(_, style: TextStyle(fontSize: <num>))` dentro do source
  /// do child do Semantics. Retorna o fontSize literal ou null.
  double? _extractFontSize(Expression childExpr) {
    final src = childExpr.toSource();
    if (!src.contains('Text(') && !src.contains('Text.rich(')) return null;

    final match = RegExp(r'fontSize:\s*([\d.]+)').firstMatch(src);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }
}
