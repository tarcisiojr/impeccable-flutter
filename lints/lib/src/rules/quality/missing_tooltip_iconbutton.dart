import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detecta `IconButton(...)` construído sem `tooltip:` nem `Semantics`
/// envolvendo. Sem isso, screen reader (TalkBack/VoiceOver) lê apenas
/// "botão", o que é pior que invisível.
///
/// Categoria: quality. Sempre que `IconButton` é interativo, ele precisa
/// de label acessível. `tooltip:` cobre dois casos: a) acessibilidade
/// (vira label de Semantics), b) discoverability em desktop (hover) e
/// mobile (long-press).
///
/// Esta regra é um proof simples: marca todo `IconButton(...)` cujo
/// argumentList não tem `tooltip:`. Versão mais sofisticada checaria
/// se há `Semantics(label: ...)` ancestor; ancestor walk ficaria para v0.2.
class MissingTooltipIconButton extends DartLintRule {
  MissingTooltipIconButton() : super(code: _code);

  static const _code = LintCode(
    name: 'impeccable_missing_tooltip',
    problemMessage:
        'IconButton sem tooltip vira "botão" sem rótulo no screen reader.',
    correctionMessage:
        'Adicione tooltip: \'Verbo + objeto\' (ex: tooltip: \'Excluir item\'). '
        'Tooltip vira label de Semantics e dá discoverability em hover/long-press.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.name2.lexeme;
      if (type != 'IconButton') return;

      // Verifica se tooltip: foi passado.
      final hasTooltip = node.argumentList.arguments.any((arg) {
        final src = arg.toSource();
        return src.startsWith('tooltip:');
      });
      if (hasTooltip) return;

      reporter.atNode(node, _code);
    });
  }
}
