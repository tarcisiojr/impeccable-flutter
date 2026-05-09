/// CLI entrypoint do impeccable_flutter.
///
/// Subcomandos:
///   impeccable_flutter detect [path]    - roda regras sobre lib/
///   impeccable_flutter live              - boota modo live (MVP stub)
///   impeccable_flutter version           - mostra versão
///
/// Para uso global:
///   dart pub global activate impeccable_flutter
///
/// Para uso local (dev):
///   dart run cli_dart/bin/impeccable_flutter.dart detect lib/

import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:impeccable_flutter/src/commands/detect_command.dart';
import 'package:impeccable_flutter/src/commands/live_command.dart';
import 'package:impeccable_flutter/src/commands/skills_command.dart';
import 'package:impeccable_flutter/src/commands/version_command.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<int>(
    'impeccable_flutter',
    'Detector de anti-padrões de design para apps Flutter.',
  )
    ..addCommand(DetectCommand())
    ..addCommand(LiveCommand())
    ..addCommand(SkillsCommand())
    ..addCommand(VersionCommand());

  try {
    final code = await runner.run(args) ?? 0;
    exit(code);
  } on UsageException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln();
    stderr.writeln(e.usage);
    exit(64); // EX_USAGE
  }
}
