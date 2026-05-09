import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Subcommand `skills` com 3 ações: install, update, check.
///
/// `install`: clona o repo do impeccable-flutter via git (shallow), copia
/// os bundles de cada harness (`dist/<harness>/skills/impeccable-flutter/`)
/// para os diretórios correspondentes do projeto atual.
///
/// `update`: igual a install, mas força sobrescrita.
///
/// `check`: compara a versão local do skill (lida do plugin.json) com a
/// remota (lida do raw GitHub) e reporta se há atualização disponível.
///
/// Workflow do usuário num app Flutter:
///   $ cd /meu/app
///   $ impeccable_flutter skills install
///   → cria .claude/skills/impeccable-flutter/, .cursor/skills/..., etc.
///
/// Para Claude Code Plugin marketplace, prefira:
///   /plugin marketplace add tarcisiojr/impeccable-flutter
///   /plugin install impeccable-flutter
class SkillsCommand extends Command<int> {
  SkillsCommand() {
    addSubcommand(_SkillsInstallCommand());
    addSubcommand(_SkillsUpdateCommand());
    addSubcommand(_SkillsCheckCommand());
  }

  @override
  String get name => 'skills';

  @override
  String get description =>
      'Instala/atualiza/verifica o skill impeccable-flutter no projeto atual.';
}

/// Constantes compartilhadas pelos subcommands.
class _SkillsConfig {
  static const repoUrl = 'https://github.com/tarcisiojr/impeccable-flutter.git';
  static const skillName = 'impeccable-flutter';
  static const versionUrl =
      'https://raw.githubusercontent.com/tarcisiojr/impeccable-flutter/main/.claude-plugin/plugin.json';

  /// Harness directories que receberão o skill quando instalado. Cada item:
  /// (dir local no projeto, sub-path no clone do dist/).
  static const harnessTargets = [
    _HarnessTarget('.claude/skills', 'dist/claude-code/.claude/skills'),
    _HarnessTarget('.cursor/skills', 'dist/cursor/.cursor/skills'),
    _HarnessTarget('.agents/skills', 'dist/agents/.agents/skills'),
    _HarnessTarget('.gemini/skills', 'dist/gemini/.gemini/skills'),
    _HarnessTarget('.opencode/skills', 'dist/opencode/.opencode/skills'),
    _HarnessTarget('.kiro/skills', 'dist/kiro/.kiro/skills'),
    _HarnessTarget('.pi/skills', 'dist/pi/.pi/skills'),
    _HarnessTarget('.qoder/skills', 'dist/qoder/.qoder/skills'),
    _HarnessTarget('.rovodev/skills', 'dist/rovo-dev/.rovodev/skills'),
    _HarnessTarget('.trae/skills', 'dist/trae/.trae/skills'),
    _HarnessTarget('.trae-cn/skills', 'dist/trae/.trae-cn/skills'),
  ];
}

class _HarnessTarget {
  const _HarnessTarget(this.localDir, this.distSubPath);
  final String localDir;
  final String distSubPath;
}

class _SkillsInstallCommand extends Command<int> {
  _SkillsInstallCommand() {
    argParser
      ..addOption(
        'target',
        abbr: 't',
        help: 'Harness específico (.claude, .cursor, etc.). Default: detecta '
            'automaticamente harness dirs já presentes; se nenhum, instala em .claude.',
      )
      ..addFlag(
        'all',
        help: 'Instala em TODOS os 11 harnesses suportados.',
        defaultsTo: false,
      );
  }

  @override
  String get name => 'install';

  @override
  String get description =>
      'Clona o skill impeccable-flutter e instala nos harness dirs do projeto.';

  @override
  Future<int> run() => _doInstall(argResults!, force: false);
}

class _SkillsUpdateCommand extends Command<int> {
  _SkillsUpdateCommand() {
    argParser
      ..addOption('target', abbr: 't', help: 'Harness específico.')
      ..addFlag('all', help: 'Atualiza em TODOS os harnesses.', defaultsTo: false);
  }

  @override
  String get name => 'update';

  @override
  String get description =>
      'Atualiza o skill impeccable-flutter (sobrescreve harness dirs existentes).';

  @override
  Future<int> run() => _doInstall(argResults!, force: true);
}

class _SkillsCheckCommand extends Command<int> {
  @override
  String get name => 'check';

  @override
  String get description =>
      'Verifica se há nova versão do skill impeccable-flutter disponível.';

  @override
  Future<int> run() async {
    final cwd = Directory.current.path;
    final localVersion = _readLocalSkillVersion(cwd);
    final remoteVersion = await _readRemoteSkillVersion();

    if (remoteVersion == null) {
      stderr.writeln('Não foi possível ler a versão remota '
          '(${_SkillsConfig.versionUrl}). Verifique conectividade.');
      return 1;
    }

    if (localVersion == null) {
      stdout.writeln('Skill local: NÃO INSTALADO');
      stdout.writeln('Skill remoto: $remoteVersion');
      stdout.writeln('Rode `impeccable_flutter skills install` para instalar.');
      return 0;
    }

    stdout.writeln('Skill local:  $localVersion');
    stdout.writeln('Skill remoto: $remoteVersion');
    if (localVersion == remoteVersion) {
      stdout.writeln('✓ Atualizado.');
    } else {
      stdout.writeln('⚠ Atualização disponível. Rode '
          '`impeccable_flutter skills update`.');
    }
    return 0;
  }

  String? _readLocalSkillVersion(String cwd) {
    // Procura o SKILL.md em qualquer harness dir local.
    for (final target in _SkillsConfig.harnessTargets) {
      final skillMd = File(p.join(
        cwd,
        target.localDir,
        _SkillsConfig.skillName,
        'SKILL.md',
      ));
      if (!skillMd.existsSync()) continue;
      final content = skillMd.readAsStringSync();
      // Procura linha `version: <X>` no frontmatter ou em qualquer lugar.
      final match = RegExp(r'^version:\s*(.+)$', multiLine: true)
          .firstMatch(content);
      if (match != null) return match.group(1)!.trim();
    }
    return null;
  }

  Future<String?> _readRemoteSkillVersion() async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(_SkillsConfig.versionUrl));
      final resp = await req.close();
      if (resp.statusCode != 200) return null;
      final body = await resp.transform(utf8.decoder).join();
      // plugin.json: {"name": "...", "version": "X.Y.Z", ...}
      final match = RegExp(r'"version"\s*:\s*"([^"]+)"').firstMatch(body);
      return match?.group(1);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}

/// Implementação compartilhada por install/update.
Future<int> _doInstall(ArgResults args, {required bool force}) async {
  final cwd = Directory.current.path;

  // Decide quais harnesses receberão o skill.
  List<_HarnessTarget> targets;
  if (args['all'] as bool) {
    targets = _SkillsConfig.harnessTargets;
  } else if (args['target'] != null) {
    final wanted = (args['target'] as String).replaceAll('.', '');
    targets = _SkillsConfig.harnessTargets
        .where((t) => t.localDir.replaceAll('.', '').startsWith(wanted))
        .toList();
    if (targets.isEmpty) {
      stderr.writeln('Harness desconhecido: ${args['target']}. Suportados: '
          '${_SkillsConfig.harnessTargets.map((t) => t.localDir).join(", ")}.');
      return 1;
    }
  } else {
    // Auto-detecta harness dirs já presentes no projeto.
    targets = _SkillsConfig.harnessTargets
        .where((t) =>
            Directory(p.join(cwd, p.dirname(t.localDir))).existsSync())
        .toList();
    if (targets.isEmpty) {
      // Nenhum harness presente: default para .claude.
      targets = [_SkillsConfig.harnessTargets.first];
      stdout.writeln('Nenhum harness detectado. Instalando em .claude/skills/ '
          'por default. Use --all ou --target=<harness> para customizar.');
    } else {
      stdout.writeln('Harnesses detectados: '
          '${targets.map((t) => t.localDir).join(", ")}.');
    }
  }

  // Clona o repo num diretório temporário.
  final tmp = await Directory.systemTemp.createTemp('impeccable-flutter-');
  try {
    stdout.writeln('Clonando ${_SkillsConfig.repoUrl} (shallow)...');
    final clone = await Process.run(
      'git',
      ['clone', '--depth=1', _SkillsConfig.repoUrl, tmp.path],
      runInShell: true,
    );
    if (clone.exitCode != 0) {
      stderr.writeln('git clone falhou:\n${clone.stderr}');
      return 1;
    }

    // Roda `bun run build` no clone para gerar dist/. Se bun não estiver
    // disponível ou falhar, usa os harness dirs já commitados (.claude/, etc.).
    var distRoot = p.join(tmp.path, 'dist');
    var useHarnessRoot = !Directory(distRoot).existsSync();
    if (useHarnessRoot) {
      stdout.writeln('dist/ não está no repo (gitignored). Usando harness dirs '
          'commitados (.claude/, .cursor/, etc.) como fonte.');
    }

    var copied = 0;
    for (final target in targets) {
      // Source: dist/<harness>/.<harness>/skills/<skill> OU <repo>/.<harness>/skills/<skill>
      final src = useHarnessRoot
          ? Directory(p.join(
              tmp.path,
              p.dirname(target.localDir), // .claude/, .cursor/, etc.
              'skills',
              _SkillsConfig.skillName,
            ))
          : Directory(p.join(tmp.path, target.distSubPath, _SkillsConfig.skillName));
      if (!src.existsSync()) {
        stderr.writeln('  skip: source ${src.path} não existe');
        continue;
      }

      final dst = Directory(p.join(cwd, target.localDir, _SkillsConfig.skillName));
      if (dst.existsSync() && !force) {
        stderr.writeln('  ${target.localDir}/${_SkillsConfig.skillName}: '
            'já existe (use `update` para sobrescrever)');
        continue;
      }
      if (dst.existsSync()) dst.deleteSync(recursive: true);
      _copyDirectory(src, dst);
      copied++;
      stdout.writeln('  ✓ ${target.localDir}/${_SkillsConfig.skillName}');
    }

    if (copied == 0) {
      stderr.writeln('Nenhum harness instalado. '
          'Use --target=<harness> ou --all para forçar.');
      return 1;
    }

    stdout.writeln('Instalado em $copied harness dir(s).');
    return 0;
  } finally {
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {/* ignore */}
  }
}

/// Copia diretório recursivamente.
void _copyDirectory(Directory src, Directory dst) {
  dst.createSync(recursive: true);
  for (final entity in src.listSync(recursive: false)) {
    final basename = p.basename(entity.path);
    if (entity is Directory) {
      _copyDirectory(entity, Directory(p.join(dst.path, basename)));
    } else if (entity is File) {
      entity.copySync(p.join(dst.path, basename));
    }
  }
}

