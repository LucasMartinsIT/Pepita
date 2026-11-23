import 'package:flutter_test/flutter_test.dart';
import 'package:pepita/models.dart';
import 'package:pepita/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final dia = DateTime(2026, 11, 23);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('começa com nome padrão e momentos padrão', () async {
    final s = Store();
    await s.carregar();
    expect(s.nome, Store.nomePadrao);
    expect(s.momentos.length, 3);
    expect(s.onboardingFeito, isFalse);
  });

  test('registros sobrevivem a "fechar o app"', () async {
    var s = Store();
    await s.carregar();
    await s.salvarRegistro(
        dia, 0, const Registro(tipo: TipoRegistro.postei, qtd: 7));
    await s.salvarRegistro(dia, 1, const Registro(tipo: TipoRegistro.descanso));
    await s.salvarRegistro(dia, 2, const Registro(tipo: TipoRegistro.postei));

    s = Store(); // novo "processo"
    await s.carregar();
    expect(s.registroDe(dia, 0)?.qtd, 7);
    expect(s.registroDe(dia, 1)?.tipo, TipoRegistro.descanso);
    expect(s.registroDe(dia, 2)?.qtd, isNull);
    expect(s.achadosDoDia(dia), 7);
    expect(s.momentosComPostagem(dia), 2);
  });

  test('apagar e desfazer', () async {
    final s = Store();
    await s.carregar();
    const r = Registro(tipo: TipoRegistro.postei, qtd: 3);
    await s.salvarRegistro(dia, 0, r);
    await s.apagarRegistro(dia, 0);
    expect(s.registroDe(dia, 0), isNull);
    expect(s.achadosDoDia(dia), 0);
    await s.salvarRegistro(dia, 0, r); // desfazer
    expect(s.registroDe(dia, 0)?.qtd, 3);
  });

  test('soma da semana só conta quantidades de "postei"', () async {
    final s = Store();
    await s.carregar();
    final segunda = inicioDaSemana(dia);
    await s.salvarRegistro(
        segunda, 0, const Registro(tipo: TipoRegistro.postei, qtd: 4));
    await s.salvarRegistro(somarDias(segunda, 6), 1,
        const Registro(tipo: TipoRegistro.postei, qtd: 5));
    await s.salvarRegistro(
        somarDias(segunda, 2), 1, const Registro(tipo: TipoRegistro.descanso));
    await s.salvarRegistro(somarDias(segunda, 7), 1,
        const Registro(tipo: TipoRegistro.postei, qtd: 99));
    expect(s.achadosDaSemana(segunda), 9);
  });

  test('ajustes persistem e avisam para reagendar lembretes', () async {
    var s = Store();
    await s.carregar();
    var avisos = 0;
    s.aoMudarAjustes = () => avisos++;

    await s.atualizarMomento(s.momentos[0]
        .copiar(nome: 'Cafezinho', ini: 6 * 60 + 30, lembrete: false));
    await s.definirNome('  Maria  ');
    expect(avisos, 2);

    s = Store();
    await s.carregar();
    expect(s.momentos[0].nome, 'Cafezinho');
    expect(s.momentos[0].ini, 390);
    expect(s.momentos[0].lembrete, isFalse);
    expect(s.nome, 'Maria');

    await s.restaurarPadrao();
    expect(s.momentos[0].nome, 'Garimpo da manhã');
  });

  test('nome vazio volta para o padrão', () async {
    final s = Store();
    await s.carregar();
    await s.definirNome('   ');
    expect(s.nome, Store.nomePadrao);
  });

  test('notinhas: criar, marcar feitinho, apagar e desfazer na mesma posição',
      () async {
    var s = Store();
    await s.carregar();
    await s.salvarNota(const Nota(id: 1, texto: 'primeira'));
    await s.salvarNota(const Nota(id: 2, texto: 'segunda', fonte: 2, papel: 3, tarefinha: true));
    expect(s.notas.map((n) => n.id), [2, 1]); // mais nova primeiro

    await s.salvarNota(s.notas.first.copiar(feita: true));

    s = Store();
    await s.carregar();
    expect(s.notas.first.feita, isTrue);
    expect(s.notas.first.fonte, 2);
    expect(s.notas.first.papel, 3);

    final apagada = s.notas.first;
    await s.apagarNota(apagada.id);
    expect(s.notas.length, 1);
    await s.restaurarNota(apagada, 0);
    expect(s.notas.map((n) => n.id), [2, 1]);
  });
}
