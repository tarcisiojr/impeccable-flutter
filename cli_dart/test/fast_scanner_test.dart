/// Testes do scanner regex puro do `--fast` mode.
///
/// Não depende de Flutter SDK nem analyzer. Cada teste cria um arquivo
/// temporário com o pattern alvo e asserta que o scanner detecta.

import 'dart:io';

import 'package:test/test.dart';

import 'package:impeccable_flutter/src/fast_scanner.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('impeccable_fast_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<File> writeFixture(String name, String content) async {
    final f = File('${tempDir.path}/$name');
    await f.writeAsString(content);
    return f;
  }

  test('detecta deep_purple_seed', () async {
    await writeFixture('a.dart', '''
import 'package:flutter/material.dart';
final t = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple));
''');
    final findings = await scanDirectory(tempDir);
    expect(
      findings.where((f) => f.ruleId == 'impeccable_deep_purple_seed'),
      hasLength(1),
    );
  });

  test('detecta bounce_elastic_curve', () async {
    await writeFixture('b.dart', '''
import 'package:flutter/material.dart';
final c = Curves.bounceOut;
final d = Curves.elasticIn;
''');
    final findings = await scanDirectory(tempDir);
    expect(
      findings.where((f) => f.ruleId == 'impeccable_bounce_elastic_curve'),
      hasLength(2),
    );
  });

  test('detecta black/white literal', () async {
    await writeFixture('c.dart', '''
import 'package:flutter/material.dart';
final w = Container(color: Colors.black);
final x = Container(color: Colors.white);
final y = Text('x', style: TextStyle(color: Colors.black87));
''');
    final findings = await scanDirectory(tempDir);
    expect(
      findings.where((f) => f.ruleId == 'impeccable_black_white_literal'),
      hasLength(3),
    );
  });

  test('detecta justified_text', () async {
    await writeFixture('d.dart', '''
import 'package:flutter/material.dart';
final t = Text('x', textAlign: TextAlign.justify);
''');
    final findings = await scanDirectory(tempDir);
    expect(findings.where((f) => f.ruleId == 'impeccable_justified_text'),
        hasLength(1));
  });

  test('detecta useMaterial3 false', () async {
    await writeFixture('e.dart', '''
import 'package:flutter/material.dart';
final t = ThemeData(useMaterial3: false);
''');
    final findings = await scanDirectory(tempDir);
    expect(findings.where((f) => f.ruleId == 'impeccable_use_material3_false'),
        hasLength(1));
  });

  test('detecta ai_color_palette case-insensitive', () async {
    await writeFixture('f.dart', '''
import 'package:flutter/material.dart';
final a = Color(0xFF6366F1);
final b = Color(0xff6366f1);
''');
    final findings = await scanDirectory(tempDir);
    expect(findings.where((f) => f.ruleId == 'impeccable_ai_color_palette'),
        hasLength(2));
  });

  test('ignora comentários', () async {
    await writeFixture('g.dart', '''
// final c = Colors.deepPurple;
final x = 1;
''');
    final findings = await scanDirectory(tempDir);
    expect(findings, isEmpty);
  });

  test('ignora arquivos generated (.g.dart, .freezed.dart)', () async {
    await writeFixture('foo.g.dart',
        'final c = Colors.deepPurple;');
    await writeFixture('foo.freezed.dart',
        'final c = Colors.deepPurple;');
    final findings = await scanDirectory(tempDir);
    expect(findings, isEmpty);
  });

  test('código limpo não dispara', () async {
    await writeFixture('clean.dart', '''
import 'package:flutter/material.dart';
class Clean extends StatelessWidget {
  const Clean({super.key});
  @override
  Widget build(BuildContext context) {
    return Text('hi', style: Theme.of(context).textTheme.bodyLarge);
  }
}
''');
    final findings = await scanDirectory(tempDir);
    expect(findings, isEmpty);
  });

  test('detecta overused_font (GoogleFonts.<font>)', () async {
    await writeFixture('h.dart', '''
import 'package:google_fonts/google_fonts.dart';
final a = Text('x', style: GoogleFonts.inter());
final b = Text('y', style: GoogleFonts.fraunces(fontSize: 24));
final c = ThemeData(textTheme: GoogleFonts.dmSansTextTheme());
''');
    final findings = await scanDirectory(tempDir);
    expect(
      findings.where((f) => f.ruleId == 'impeccable_overused_font'),
      hasLength(3),
    );
  });

  test('detecta monotonous_spacing (EdgeInsets.all(N) repetido ≥4×)',
      () async {
    await writeFixture('i.dart', '''
import 'package:flutter/material.dart';
final a = Padding(padding: EdgeInsets.all(16), child: Text('a'));
final b = Padding(padding: EdgeInsets.all(16), child: Text('b'));
final c = Padding(padding: EdgeInsets.all(16), child: Text('c'));
final d = Padding(padding: EdgeInsets.all(16), child: Text('d'));
''');
    final findings = await scanDirectory(tempDir);
    final monotonous =
        findings.where((f) => f.ruleId == 'impeccable_monotonous_spacing');
    expect(monotonous, hasLength(1));
    expect(monotonous.first.message, contains('4×'));
  });

  test('NÃO dispara monotonous_spacing com <4 ocorrências', () async {
    await writeFixture('j.dart', '''
import 'package:flutter/material.dart';
final a = Padding(padding: EdgeInsets.all(16), child: Text('a'));
final b = Padding(padding: EdgeInsets.all(16), child: Text('b'));
final c = Padding(padding: EdgeInsets.all(16), child: Text('c'));
''');
    final findings = await scanDirectory(tempDir);
    expect(findings.where((f) => f.ruleId == 'impeccable_monotonous_spacing'),
        isEmpty);
  });

  test('detecta everything_centered (≥6 Center/.center)', () async {
    await writeFixture('k.dart', '''
import 'package:flutter/material.dart';
final a = Center(child: Center(child: Center(child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [Center(child: Text('x'))],
))));
''');
    final findings = await scanDirectory(tempDir);
    final centered =
        findings.where((f) => f.ruleId == 'impeccable_everything_centered');
    expect(centered, hasLength(1));
    expect(centered.first.message, contains('6'));
  });
}
