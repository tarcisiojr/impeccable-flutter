import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

const ROOT = process.cwd();

// Contrato do live.md depois do port para Flutter. O equivalente do antigo
// "styleMode capability mode" da era web é o **hot reload + dart format +
// preservação de assinatura pública** — propriedades que o agente precisa
// honrar sempre, independente do widget.
describe('live reference authoring contract (Flutter)', () => {
  it('descreve o ciclo iterativo em vocabulário Flutter', () => {
    const liveMd = readFileSync(join(ROOT, 'skill/reference/live.md'), 'utf-8');

    // Cabeçalho identifica a era Flutter explicitamente.
    assert.match(
      liveMd,
      /^# Live \(Flutter\)/,
      'live.md deve declarar plataforma Flutter no título (port concluído)',
    );

    // Hot reload é o canal de feedback (não HMR de bundler web).
    assert.match(
      liveMd,
      /hot reload/i,
      'live.md deve apontar hot reload como mecanismo de feedback',
    );

    // dart format obrigatório no fim do ciclo: variantes formatadas
    // inconsistentes confundem o diff e quebram o `dart analyze` da review.
    assert.match(
      liveMd,
      /`?dart format`?/,
      'live.md deve exigir dart format ao final do ciclo de variantes',
    );

    // Anti-pattern explícito: agente não pode quebrar contrato público
    // do widget ao gerar variantes.
    assert.match(
      liveMd,
      /[Vv]ariantes? (que )?(mudam|altera|muda) (o )?contrato p[úu]blico|mantêm assinatura|manter assinatura/,
      'live.md deve listar como anti-pattern variantes que quebram a assinatura pública do widget',
    );
  });

  it('não deixa restos da era web (CSS scopes, Astro, styleMode)', () => {
    const liveMd = readFileSync(join(ROOT, 'skill/reference/live.md'), 'utf-8');

    assert.doesNotMatch(
      liveMd,
      /styleMode/,
      'live.md (Flutter) não deve mencionar styleMode (capability da era web)',
    );
    assert.doesNotMatch(
      liveMd,
      /astro-global-prefixed/,
      'live.md (Flutter) não deve mencionar capacities CSS específicas da era web',
    );
    assert.doesNotMatch(
      liveMd,
      /@scope \(/,
      'live.md (Flutter) não deve mencionar @scope CSS — Flutter não tem cascata',
    );
  });
});
