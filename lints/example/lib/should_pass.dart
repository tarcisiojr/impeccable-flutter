// Fixture: nenhum widget aqui deve ser flag.
// Cada um é o "jeito certo" da regra correspondente.

import 'package:flutter/material.dart';

class ShouldPassBrandSeed extends StatelessWidget {
  const ShouldPassBrandSeed({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        // PASS: cor de marca explícita (azul cobalto, não AI palette)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4ED8)),
      ),
      home: const Placeholder(),
    );
  }
}

class ShouldPassEaseOut extends StatefulWidget {
  const ShouldPassEaseOut({super.key});
  @override
  State<ShouldPassEaseOut> createState() => _ShouldPassEaseOutState();
}

class _ShouldPassEaseOutState extends State<ShouldPassEaseOut>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _controller,
        // PASS: ease-out cubic é o default M3 standard
        curve: Curves.easeOutCubic,
      ),
      builder: (_, __) => const SizedBox(),
    );
  }
}

class ShouldPassThemedText extends StatelessWidget {
  const ShouldPassThemedText({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      // PASS: surface do scheme
      color: scheme.surface,
      child: Text(
        'Olá',
        // PASS: textTheme + colorScheme
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class ShouldPassTooltipIcon extends StatelessWidget {
  const ShouldPassTooltipIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // PASS: tooltip presente
    return IconButton(
      tooltip: 'Excluir item',
      icon: const Icon(Icons.delete),
      onPressed: () {},
    );
  }
}

class ShouldPassPlainCard extends StatelessWidget {
  const ShouldPassPlainCard({super.key});

  @override
  Widget build(BuildContext context) {
    // PASS: Card com Padding/Divider para hierarquia interna, sem aninhamento
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text('Title'),
            Divider(),
            Text('Body'),
          ],
        ),
      ),
    );
  }
}

class ShouldPassSubtleShadow extends StatelessWidget {
  const ShouldPassSubtleShadow({super.key});

  @override
  Widget build(BuildContext context) {
    // PASS: Material elevation (M3 way), não BoxShadow custom
    return const Material(
      elevation: 4,
      child: SizedBox(width: 100, height: 100),
    );
  }
}

class ShouldPassVariedSpacing extends StatelessWidget {
  const ShouldPassVariedSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    // PASS: spacing varia intencionalmente, sem repetição monotônica
    return Column(
      children: const [
        Padding(padding: EdgeInsets.all(8), child: Text('tight')),
        Padding(padding: EdgeInsets.all(16), child: Text('mid')),
        Padding(padding: EdgeInsets.all(24), child: Text('generous')),
      ],
    );
  }
}

class ShouldPassStartAlign extends StatelessWidget {
  const ShouldPassStartAlign({super.key});

  @override
  Widget build(BuildContext context) {
    // PASS: TextAlign.start (default) em prosa mobile
    return const Text(
      'Lorem ipsum',
      textAlign: TextAlign.start,
    );
  }
}

class ShouldPassMaterialAppWithTheme extends StatelessWidget {
  const ShouldPassMaterialAppWithTheme({super.key});

  @override
  Widget build(BuildContext context) {
    // PASS: theme: definido
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4ED8)),
      ),
      home: const Placeholder(),
    );
  }
}

class ShouldPassThemeColorsContainer extends StatelessWidget {
  const ShouldPassThemeColorsContainer({super.key});
  @override
  Widget build(BuildContext context) {
    // PASS: cores do scheme não são literais — gray_on_color e low_contrast
    // pulam silenciosamente (não dispara false positive).
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primary,
      child: Text(
        'on-primary do tema',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary,
            ),
      ),
    );
  }
}

class ShouldPassHeadingsInOrder extends StatelessWidget {
  const ShouldPassHeadingsInOrder({super.key});
  @override
  Widget build(BuildContext context) {
    // PASS: headings em ordem decrescente (h1 → h2 → h3) no MESMO build().
    // ignore_for_file: impeccable_textstyle_outside_theme, impeccable_missing_const_decoration
    return Column(
      children: [
        Semantics(
          header: true,
          child: const Text('Título', style: TextStyle(fontSize: 32)),
        ),
        Semantics(
          header: true,
          child: const Text('Seção', style: TextStyle(fontSize: 24)),
        ),
        Semantics(
          header: true,
          child: const Text('Subseção', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}

class ShouldPassSingleHeading extends StatelessWidget {
  const ShouldPassSingleHeading({super.key});
  @override
  Widget build(BuildContext context) {
    // PASS: apenas um Semantics(header: true) — sem ordem para violar.
    // (em outro método build distinto do anterior — escopo isolado).
    return Semantics(
      header: true,
      child: const Text('Apenas título', style: TextStyle(fontSize: 28)),
    );
  }
}
