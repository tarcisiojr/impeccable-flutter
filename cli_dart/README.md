# impeccable_flutter (CLI)

CLI Dart para detectar anti-padrões de design em apps Flutter.

**Status**: pré-MVP. Esqueleto funcional com 3 subcomandos. Empacotamento pub.dev TODO.

## Instalação local (dev)

```bash
cd cli_dart
dart pub get
dart run bin/impeccable_flutter.dart --help
```

## Instalação global (pub.dev — quando publicado)

```bash
dart pub global activate impeccable_flutter
impeccable_flutter --help
```

## Subcomandos

### `detect [path]`

Roda as regras do `impeccable_flutter_lints` sobre o projeto. Wrapper de `dart run custom_lint`.

```bash
impeccable_flutter detect lib/
impeccable_flutter detect --format=json lib/
```

Pré-requisito: o projeto alvo precisa ter `custom_lint` e `impeccable_flutter_lints` em `dev_dependencies`.

### `live`

Modo iterativo de variantes. MVP v0.1 imprime o workflow manual; v0.2 ganha HTTP server + overlay de seleção via VM Service. Veja `skill/reference/live.md`.

```bash
impeccable_flutter live
```

### `version`

```bash
impeccable_flutter version
```

## Roadmap

- [ ] `--fast` mode (regex puro, sem analyzer).
- [ ] Output JSON estruturado.
- [ ] `live` v0.2 com HTTP server + overlay.
- [ ] Empacotamento pub.dev.
- [ ] CI: testes contra projetos Flutter de exemplo.

## Licença

Apache 2.0. Veja `NOTICE.md` na raiz do repo.
