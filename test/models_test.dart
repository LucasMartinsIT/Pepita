import 'package:flutter_test/flutter_test.dart';
import 'package:pepita/models.dart';

void main() {
  test('são sempre 3 momentos padrão, com os horários combinados', () {
    expect(Momento.padrao.length, 3);
    expect(Momento.padrao[0].faixa, '07:00 – 08:00');
    expect(Momento.padrao[1].faixa, '12:00 – 13:00');
    expect(Momento.padrao[2].faixa, '17:30 – 18:30');
  });

  test('estado do momento: antes, agora e depois', () {
    final m = Momento.padrao[0];
    expect(m.estadoEm(DateTime(2026, 1, 1, 6, 59)), EstadoMomento.antes);
    expect(m.estadoEm(DateTime(2026, 1, 1, 7, 0)), EstadoMomento.agora);
    expect(m.estadoEm(DateTime(2026, 1, 1, 7, 59)), EstadoMomento.agora);
    expect(m.estadoEm(DateTime(2026, 1, 1, 8, 0)), EstadoMomento.depois);
  });

  test('ida e volta em JSON', () {
    final m =
        Momento.padrao[2].copiar(nome: 'Garimpo da noite', lembrete: false);
    final volta = Momento.deJson(m.paraJson());
    expect(volta.nome, 'Garimpo da noite');
    expect(volta.lembrete, isFalse);
    expect(volta.ini, 17 * 60 + 30);

    const r = Registro(tipo: TipoRegistro.postei, qtd: 7);
    final rv = Registro.deJson(r.paraJson());
    expect(rv.tipo, TipoRegistro.postei);
    expect(rv.qtd, 7);
    expect(
        Registro.deJson(const Registro(tipo: TipoRegistro.descanso).paraJson())
            .qtd,
        isNull);
  });

  test('chave do dia e início da semana (segunda)', () {
    expect(chaveDia(DateTime(2026, 3, 5)), '2026-03-05');
    expect(diaDeChave('2026-03-05'), DateTime(2026, 3, 5));
    // 2026-11-25 é quarta; a segunda é 2026-11-23.
    expect(inicioDaSemana(DateTime(2026, 11, 25, 15)), DateTime(2026, 11, 23));
    expect(inicioDaSemana(DateTime(2026, 11, 29)), DateTime(2026, 11, 23));
    expect(somarDias(DateTime(2026, 12, 30), 3), DateTime(2027, 1, 2));
  });
}
