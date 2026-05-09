/// Teste integration end-to-end do plugin.
///
/// Roda `dart run custom_lint` na pasta example/ e asserta:
///   1. Nenhum issue em should_pass.dart
///   2. Cada regra do plugin tem >=1 issue em should_flag.dart
///
/// Esse é o teste mais confiável porque exercita o exato pipeline que o
/// usuário final invoca. Mais lento que unit tests (boota custom_lint), mas
/// captura regressões reais (regra registrada mas não rodada, fixture que
/// mudou, etc.).
///
/// Roda via:
///   cd lints && dart test
///
/// Pré-requisito: `cd example && flutter pub get` rodou pelo menos uma vez.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('impeccable_flutter_lints integration', () {
    late String output;

    setUpAll(() async {
      // Boota custom_lint contra example/. Pode demorar 30-60s na primeira vez.
      final result = await Process.run(
        'dart',
        ['run', 'custom_lint'],
        workingDirectory: '${Directory.current.path}/example',
        runInShell: true,
      );
      output = result.stdout.toString();
      // exit code 1 quando há findings, 0 quando clean. Não asserta o code aqui;
      // os testes individuais validam contagens.
    });

    test('Detecta deep_purple_seed em should_flag', () {
      expect(
        output,
        contains('impeccable_deep_purple_seed'),
        reason: 'Regra deep_purple_seed deveria flagar Colors.deepPurple seed.',
      );
    });

    test('Detecta bounce_elastic_curve em should_flag', () {
      expect(output, contains('impeccable_bounce_elastic_curve'));
    });

    test('Detecta black_white_literal em should_flag', () {
      expect(output, contains('impeccable_black_white_literal'));
    });

    test('Detecta missing_tooltip em should_flag', () {
      expect(output, contains('impeccable_missing_tooltip'));
    });

    test('Detecta textstyle_outside_theme em should_flag', () {
      expect(output, contains('impeccable_textstyle_outside_theme'));
    });

    test('Detecta gradient_text em should_flag', () {
      expect(output, contains('impeccable_gradient_text'));
    });

    test('Detecta nested_cards em should_flag', () {
      expect(output, contains('impeccable_nested_cards'));
    });

    test('Detecta dark_glow em should_flag', () {
      expect(output, contains('impeccable_dark_glow'));
    });

    test('Detecta ai_color_palette em should_flag', () {
      expect(output, contains('impeccable_ai_color_palette'));
    });

    test('Detecta justified_text em should_flag', () {
      expect(output, contains('impeccable_justified_text'));
    });

    test('Detecta material_baseline em should_flag', () {
      expect(output, contains('impeccable_material_baseline'));
    });

    test('Detecta tiny_text em should_flag', () {
      expect(output, contains('impeccable_tiny_text'));
    });

    test('Detecta tight_leading em should_flag', () {
      expect(output, contains('impeccable_tight_leading'));
    });

    test('Detecta use_material3_false em should_flag', () {
      expect(output, contains('impeccable_use_material3_false'));
    });

    test('Detecta cramped_padding em should_flag', () {
      expect(output, contains('impeccable_cramped_padding'));
    });

    test('Detecta wide_tracking em should_flag', () {
      expect(output, contains('impeccable_wide_tracking'));
    });

    test('Detecta layout_transition em should_flag', () {
      expect(output, contains('impeccable_layout_transition'));
    });

    test('Detecta side_tab em should_flag', () {
      expect(output, contains('impeccable_side_tab'));
    });

    test('Detecta missing_safe_area em should_flag', () {
      expect(output, contains('impeccable_missing_safe_area'));
    });

    test('Detecta border_accent_on_rounded em should_flag', () {
      expect(output, contains('impeccable_border_accent_on_rounded'));
    });

    test('Detecta all_caps_body em should_flag', () {
      expect(output, contains('impeccable_all_caps_body'));
    });

    test('Detecta touch_target_too_small em should_flag', () {
      expect(output, contains('impeccable_touch_target_too_small'));
    });

    test('Detecta italic_serif_display em should_flag', () {
      expect(output, contains('impeccable_italic_serif_display'));
    });

    test('Detecta single_font em should_flag', () {
      expect(output, contains('impeccable_single_font'));
    });

    test('Detecta missing_semantics em should_flag', () {
      expect(output, contains('impeccable_missing_semantics'));
    });

    test('Detecta flat_type_hierarchy em should_flag', () {
      expect(output, contains('impeccable_flat_type_hierarchy'));
    });

    test('Detecta hero_eyebrow_chip em should_flag', () {
      expect(output, contains('impeccable_hero_eyebrow_chip'));
    });

    test('Detecta line_length em should_flag', () {
      expect(output, contains('impeccable_line_length'));
    });

    test('Detecta icon_tile_stack em should_flag', () {
      expect(output, contains('impeccable_icon_tile_stack'));
    });

    test('Detecta missing_const_decoration em should_flag', () {
      expect(output, contains('impeccable_missing_const_decoration'));
    });

    test('Detecta overused_font em should_flag', () {
      expect(output, contains('impeccable_overused_font'));
    });

    test('should_pass.dart não dispara nenhum impeccable_*', () {
      // Cada linha do output que cita "should_pass.dart" não deveria existir.
      // O output do custom_lint usa o path; se uma regra disparar em
      // should_pass, "should_pass.dart" aparece nessa linha.
      final lines = output.split('\n');
      final passViolations = lines.where(
        (l) => l.contains('should_pass.dart') && l.contains('impeccable_'),
      );
      expect(
        passViolations,
        isEmpty,
        reason: 'Nenhuma regra impeccable_* deveria flagar em should_pass.dart. '
            'Encontradas: $passViolations',
      );
    });
  });
}
