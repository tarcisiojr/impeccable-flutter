/// impeccable_flutter_lints
///
/// Plugin custom_lint que registra regras de detecção de anti-padrões
/// de design em código Flutter. Cobre AI slop (Colors.deepPurple,
/// Curves.bounce, gradient AppBar, gradient text, nested cards, dark glow,
/// AI color palette, monotonous spacing) e qualidade (TextStyle literal,
/// missing tooltip, justified text, tiny text, tight leading, material
/// baseline, useMaterial3 false).
///
/// Uso pelo consumidor:
///   dev_dependencies:
///     custom_lint: ^0.7.0
///     impeccable_flutter_lints: ^0.0.1
///
///   analysis_options.yaml:
///     analyzer:
///       plugins:
///         - custom_lint
///
///   $ dart run custom_lint
library;

import 'package:custom_lint_builder/custom_lint_builder.dart';

// slop
import 'src/rules/slop/ai_color_palette.dart';
import 'src/rules/slop/border_accent_on_rounded.dart';
import 'src/rules/slop/colors_deep_purple_seed.dart';
import 'src/rules/slop/curves_bounce_elastic.dart';
import 'src/rules/slop/dark_glow.dart';
// Nota: everything_centered exige agregação cross-node (≥6 ocorrências
// no arquivo). custom_lint_core 0.7.5 não suporta bem essa contagem via
// addCompilationUnit. A regra vive em cli_dart/.../fast_scanner.dart e
// é detectada por `impeccable_flutter detect --fast`.
// import 'src/rules/slop/everything_centered.dart';
import 'src/rules/slop/gradient_text.dart';
import 'src/rules/slop/hero_eyebrow_chip.dart';
import 'src/rules/slop/icon_tile_stack.dart';
import 'src/rules/slop/italic_serif_display.dart';
import 'src/rules/slop/nested_cards.dart';
import 'src/rules/slop/overused_font.dart';
import 'src/rules/slop/side_tab.dart';
import 'src/rules/slop/single_font.dart';
// Nota: monotonous_spacing exige agregação cross-node (mesma N de
// EdgeInsets.all repetida ≥4×). Mesma limitação de everything_centered;
// vive em cli_dart/.../fast_scanner.dart e dispara via `--fast`.

// quality
import 'src/rules/quality/all_caps_body.dart';
import 'src/rules/quality/colors_black_white_literal.dart';
import 'src/rules/quality/cramped_padding.dart';
import 'src/rules/quality/flat_type_hierarchy.dart';
import 'src/rules/quality/gray_on_color.dart';
import 'src/rules/quality/justified_text.dart';
import 'src/rules/quality/layout_transition.dart';
import 'src/rules/quality/line_length.dart';
import 'src/rules/quality/low_contrast.dart';
import 'src/rules/quality/material_baseline.dart';
import 'src/rules/quality/missing_const_decoration.dart';
import 'src/rules/quality/missing_safe_area.dart';
import 'src/rules/quality/missing_semantics.dart';
import 'src/rules/quality/missing_tooltip_iconbutton.dart';
import 'src/rules/quality/skipped_heading.dart';
import 'src/rules/quality/textstyle_outside_theme.dart';
import 'src/rules/quality/tight_leading.dart';
import 'src/rules/quality/tiny_text.dart';
import 'src/rules/quality/touch_target_too_small.dart';
import 'src/rules/quality/use_material3_false.dart';
import 'src/rules/quality/wide_tracking.dart';

/// Entrypoint do plugin. Chamado pelo `custom_lint` runner.
PluginBase createPlugin() => _ImpeccableFlutterLintsPlugin();

class _ImpeccableFlutterLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        // slop (sinal de UI gerada por IA / template)
        AiColorPalette(),
        BorderAccentOnRounded(),
        ColorsDeepPurpleSeed(),
        CurvesBounceElastic(),
        DarkGlow(),
        // EverythingCentered() roda via `--fast` scanner (CLI). Veja nota no import.
        GradientText(),
        HeroEyebrowChip(),
        IconTileStack(),
        ItalicSerifDisplay(),
        NestedCards(),
        OverusedFont(),
        SideTab(),
        SingleFont(),

        // quality (anti-pattern objetivo)
        AllCapsBody(),
        ColorsBlackWhiteLiteral(),
        CrampedPadding(),
        FlatTypeHierarchy(),
        GrayOnColor(),
        JustifiedText(),
        LayoutTransition(),
        LineLength(),
        LowContrast(),
        MaterialBaseline(),
        MissingConstDecoration(),
        MissingSafeArea(),
        MissingSemantics(),
        MissingTooltipIconButton(),
        SkippedHeading(),
        TextStyleOutsideTheme(),
        TightLeading(),
        TinyText(),
        TouchTargetTooSmall(),
        UseMaterial3False(),
        WideTracking(),
      ];
}
