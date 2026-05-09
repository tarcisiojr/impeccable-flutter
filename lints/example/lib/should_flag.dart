// Fixture: cada widget aqui DEVE ser flag pelo detector quando rodado via
// `dart run custom_lint`. Usado para validação manual durante desenvolvimento
// das regras.
//
// Para validar:
//   cd lints/example && flutter pub get && dart run custom_lint
// Espera: 16+ warnings cobrindo as 15 regras (algumas regras flag múltiplos).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShouldFlagDeepPurple extends StatelessWidget {
  const ShouldFlagDeepPurple({super.key});

  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_deep_purple_seed
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Placeholder(),
    );
  }
}

class ShouldFlagBounceCurve extends StatefulWidget {
  const ShouldFlagBounceCurve({super.key});
  @override
  State<ShouldFlagBounceCurve> createState() => _ShouldFlagBounceCurveState();
}

class _ShouldFlagBounceCurveState extends State<ShouldFlagBounceCurve>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut, // FLAG: impeccable_bounce_elastic_curve
      ),
      builder: (_, __) => const SizedBox(),
    );
  }
}

class ShouldFlagBlackLiteral extends StatelessWidget {
  const ShouldFlagBlackLiteral({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // FLAG: impeccable_black_white_literal
      color: Colors.black,
      child: const Text(
        'Olá',
        // FLAG: impeccable_black_white_literal (white literal)
        // FLAG: impeccable_textstyle_outside_theme (TextStyle cru)
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ShouldFlagMissingTooltip extends StatelessWidget {
  const ShouldFlagMissingTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_missing_tooltip
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {},
    );
  }
}

class ShouldFlagGradientText extends StatelessWidget {
  const ShouldFlagGradientText({super.key});

  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_gradient_text
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
      ).createShader(bounds),
      child: const Text('Hero'),
    );
  }
}

class ShouldFlagNestedCards extends StatelessWidget {
  const ShouldFlagNestedCards({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        // FLAG: impeccable_nested_cards
        child: Card(child: Text('Inner')),
      ),
    );
  }
}

class ShouldFlagDarkGlow extends StatelessWidget {
  const ShouldFlagDarkGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          // FLAG: impeccable_dark_glow (blurRadius 40 > 30)
          BoxShadow(blurRadius: 40, color: Color(0xFF6366F1)),
        ],
      ),
    );
  }
}

class ShouldFlagAiPalette extends StatelessWidget {
  const ShouldFlagAiPalette({super.key});

  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_ai_color_palette (#6366F1 indigo-500 IA default)
    return Container(color: const Color(0xFF6366F1));
  }
}


class ShouldFlagJustified extends StatelessWidget {
  const ShouldFlagJustified({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Lorem ipsum dolor sit amet.',
      // FLAG: impeccable_justified_text
      textAlign: TextAlign.justify,
    );
  }
}

class ShouldFlagMaterialBaseline extends StatelessWidget {
  const ShouldFlagMaterialBaseline({super.key});

  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_material_baseline (sem theme:)
    return const MaterialApp(home: Placeholder());
  }
}

class ShouldFlagTinyText extends StatelessWidget {
  const ShouldFlagTinyText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'minúsculo',
      // FLAG: impeccable_tiny_text (fontSize 9 < 12)
      // (também flag impeccable_textstyle_outside_theme)
      style: TextStyle(fontSize: 9),
    );
  }
}

class ShouldFlagTightLeading extends StatelessWidget {
  const ShouldFlagTightLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'apertado',
      // FLAG: impeccable_tight_leading (height 1.0 < 1.15)
      // (também flag impeccable_textstyle_outside_theme)
      style: TextStyle(height: 1.0),
    );
  }
}

class ShouldFlagUseMaterial3False extends StatelessWidget {
  const ShouldFlagUseMaterial3False({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // FLAG: impeccable_use_material3_false
        useMaterial3: false,
      ),
      home: const Placeholder(),
    );
  }
}

class ShouldFlagCrampedPadding extends StatelessWidget {
  const ShouldFlagCrampedPadding({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_cramped_padding (4 < 8)
    return const Padding(
      padding: EdgeInsets.all(4),
      child: Text('apertado'),
    );
  }
}

class ShouldFlagWideTracking extends StatelessWidget {
  const ShouldFlagWideTracking({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text(
      'tracking exagerado',
      // FLAG: impeccable_wide_tracking (4 > 2)
      // (também impeccable_textstyle_outside_theme)
      style: TextStyle(letterSpacing: 4),
    );
  }
}

class ShouldFlagLayoutTransition extends StatefulWidget {
  const ShouldFlagLayoutTransition({super.key});
  @override
  State<ShouldFlagLayoutTransition> createState() => _LtState();
}

class _LtState extends State<ShouldFlagLayoutTransition> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_layout_transition (anima width)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: expanded ? 200 : 100,
      child: const SizedBox(),
    );
  }
}

class ShouldFlagSideTab extends StatelessWidget {
  const ShouldFlagSideTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // FLAG: impeccable_side_tab (left width 4)
        border: Border(
          left: BorderSide(color: Color(0xFF1F4ED8), width: 4),
        ),
      ),
      child: const Text('side tab'),
    );
  }
}


class ShouldFlagMissingSafeArea extends StatelessWidget {
  const ShouldFlagMissingSafeArea({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_missing_safe_area (extendBodyBehindAppBar sem SafeArea)
    return const Scaffold(
      extendBodyBehindAppBar: true,
      body: Placeholder(),
    );
  }
}

class ShouldFlagBorderAccentOnRounded extends StatelessWidget {
  const ShouldFlagBorderAccentOnRounded({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // FLAG: impeccable_border_accent_on_rounded (width 4 + radius)
        border: Border.all(color: const Color(0xFF1F4ED8), width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class ShouldFlagAllCapsBody extends StatelessWidget {
  const ShouldFlagAllCapsBody({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_all_caps_body (>12 chars + uppercase)
    return const Text('NUNCA ESCREVA ASSIM EM BODY TEXT');
  }
}

class ShouldFlagTouchTarget extends StatelessWidget {
  const ShouldFlagTouchTarget({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_touch_target_too_small (padding zero)
    return IconButton(
      tooltip: 'foo',
      padding: EdgeInsets.zero,
      iconSize: 16,
      icon: const Icon(Icons.close),
      onPressed: () {},
    );
  }
}

class ShouldFlagItalicSerif extends StatelessWidget {
  const ShouldFlagItalicSerif({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Editorial',
      // FLAG: impeccable_italic_serif_display (Fraunces italic 56)
      // (também impeccable_textstyle_outside_theme)
      style: TextStyle(
        fontFamily: 'Fraunces',
        fontStyle: FontStyle.italic,
        fontSize: 56,
      ),
    );
  }
}

class ShouldFlagSingleFont extends StatelessWidget {
  const ShouldFlagSingleFont({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      // FLAG: impeccable_single_font (Inter em todos os 4 papéis)
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 57),
        headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 32),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16),
        labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 11),
      ),
    );
    return MaterialApp(theme: theme, home: const Placeholder());
  }
}


class ShouldFlagMissingSemantics extends StatelessWidget {
  const ShouldFlagMissingSemantics({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_missing_semantics (GestureDetector com onTap, sem label)
    return GestureDetector(
      onTap: () {},
      child: Container(width: 48, height: 48, color: const Color(0xFF1F4ED8)),
    );
  }
}

class ShouldFlagFlatHierarchy extends StatelessWidget {
  const ShouldFlagFlatHierarchy({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      // FLAG: impeccable_flat_type_hierarchy (32/30 = 1.07 < 1.2)
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32),
        displayMedium: TextStyle(fontSize: 30),
        displaySmall: TextStyle(fontSize: 28),
      ),
    );
    return MaterialApp(theme: theme, home: const Placeholder());
  }
}

class ShouldFlagHeroEyebrow extends StatelessWidget {
  const ShouldFlagHeroEyebrow({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FLAG: impeccable_hero_eyebrow_chip (chip pequeno + hero)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1F4ED8),
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text('NEW'),
        ),
        Text(
          'Hero gigante',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }
}

class ShouldFlagLineLength extends StatelessWidget {
  const ShouldFlagLineLength({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_line_length (>100 chars sem maxLines)
    return const Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    );
  }
}

class ShouldFlagIconTileStack extends StatelessWidget {
  const ShouldFlagIconTileStack({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_icon_tile_stack (3+ tiles Icon+Text em Row)
    return Row(
      children: [
        Container(child: const Column(children: [Icon(Icons.star), Text('Fast')])),
        Container(child: const Column(children: [Icon(Icons.lock), Text('Safe')])),
        Container(child: const Column(children: [Icon(Icons.cloud), Text('Cloud')])),
      ],
    );
  }
}

class ShouldFlagMissingConstDeco extends StatelessWidget {
  const ShouldFlagMissingConstDeco({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_missing_const_decoration (BoxDecoration literal sem const)
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
    );
  }
}

class ShouldFlagOverusedFont extends StatelessWidget {
  const ShouldFlagOverusedFont({super.key});
  @override
  Widget build(BuildContext context) {
    // FLAG: impeccable_overused_font (Inter na reflex-reject list)
    return Text(
      'inter direto',
      style: GoogleFonts.inter(),
    );
  }
}
