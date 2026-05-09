import 'dart:io';

import 'package:args/command_runner.dart';

const _version = '0.0.1';

class VersionCommand extends Command<int> {
  @override
  String get name => 'version';

  @override
  String get description => 'Mostra a versão do impeccable_flutter CLI.';

  @override
  Future<int> run() async {
    stdout.writeln('impeccable_flutter $_version');
    return 0;
  }
}
