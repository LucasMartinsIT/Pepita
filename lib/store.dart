import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Guarda tudo localmente (shared_preferences). Cada escrita persiste na hora.
class Store extends ChangeNotifier {
  static const nomePadrao = 'linda';

  static const _kNome = 'nome';
  static const _kMomentos = 'momentos';
  static const _kRegistros = 'registros';
  static const _kOnboarding = 'onboardingFeito';
  static const _kNotas = 'notas';

  late SharedPreferences _prefs;

  String nome = nomePadrao;
  List<Momento> momentos = List.of(Momento.padrao);
  bool onboardingFeito = false;

  /// Notinhas do Caderninho, da mais nova para a mais antiga.
  List<Nota> notas = [];

  /// "AAAA-MM-DD" -> { idMomento -> Registro }
  final Map<String, Map<int, Registro>> _registros = {};

  /// Chamado sempre que os momentos ou o nome mudam (para reagendar lembretes).
  VoidCallback? aoMudarAjustes;

  Future<void> carregar() async {
    _prefs = await SharedPreferences.getInstance();
    nome = _prefs.getString(_kNome) ?? nomePadrao;
    onboardingFeito = _prefs.getBool(_kOnboarding) ?? false;

    final jm = _prefs.getString(_kMomentos);
    if (jm != null) {
      try {
        final lista = (jsonDecode(jm) as List)
            .map((e) => Momento.deJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
        if (lista.length == 3) momentos = lista;
      } catch (_) {
        // dado ilegível: segue com os horários padrão
      }
    }

    final jn = _prefs.getString(_kNotas);
    if (jn != null) {
      try {
        notas = (jsonDecode(jn) as List)
            .map((e) => Nota.deJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        notas = [];
      }
    }

    final jr = _prefs.getString(_kRegistros);
    if (jr != null) {
      try {
        final mapa = jsonDecode(jr) as Map<String, dynamic>;
        mapa.forEach((dia, porMomento) {
          final m = <int, Registro>{};
          (porMomento as Map<String, dynamic>).forEach((id, r) {
            m[int.parse(id)] = Registro.deJson(r as Map<String, dynamic>);
          });
          _registros[dia] = m;
        });
      } catch (_) {
        _registros.clear();
      }
    }
  }

  // ---------- leitura ----------

  Registro? registroDe(DateTime dia, int idMomento) =>
      _registros[chaveDia(dia)]?[idMomento];

  /// Soma das quantidades de um dia. Retorna 0 se não houver quantidade.
  int achadosDoDia(DateTime dia) {
    final m = _registros[chaveDia(dia)];
    if (m == null) return 0;
    return m.values
        .where((r) => r.tipo == TipoRegistro.postei)
        .fold(0, (soma, r) => soma + (r.qtd ?? 0));
  }

  /// Quantos momentos do dia tiveram "postei".
  int momentosComPostagem(DateTime dia) =>
      _registros[chaveDia(dia)]
          ?.values
          .where((r) => r.tipo == TipoRegistro.postei)
          .length ??
      0;

  /// Soma dos achados de 7 dias a partir de [segunda].
  int achadosDaSemana(DateTime segunda) {
    var soma = 0;
    for (var i = 0; i < 7; i++) {
      soma += achadosDoDia(somarDias(segunda, i));
    }
    return soma;
  }

  // ---------- escrita ----------

  Future<void> salvarRegistro(
      DateTime dia, int idMomento, Registro registro) async {
    _registros.putIfAbsent(chaveDia(dia), () => {})[idMomento] = registro;
    notifyListeners();
    await _persistirRegistros();
  }

  Future<void> apagarRegistro(DateTime dia, int idMomento) async {
    final chave = chaveDia(dia);
    _registros[chave]?.remove(idMomento);
    if (_registros[chave]?.isEmpty ?? false) _registros.remove(chave);
    notifyListeners();
    await _persistirRegistros();
  }

  Future<void> atualizarMomento(Momento novo) async {
    momentos = [
      for (final m in momentos) m.id == novo.id ? novo : m,
    ];
    notifyListeners();
    await _persistirMomentos();
    aoMudarAjustes?.call();
  }

  Future<void> restaurarPadrao() async {
    momentos = List.of(Momento.padrao);
    notifyListeners();
    await _persistirMomentos();
    aoMudarAjustes?.call();
  }

  Future<void> definirNome(String novo) async {
    final limpo = novo.trim();
    nome = limpo.isEmpty ? nomePadrao : limpo;
    notifyListeners();
    await _prefs.setString(_kNome, nome);
    aoMudarAjustes?.call();
  }

  /// Cria a nota (id novo) ou atualiza a existente.
  Future<void> salvarNota(Nota nota) async {
    final i = notas.indexWhere((n) => n.id == nota.id);
    if (i >= 0) {
      notas = [...notas]..[i] = nota;
    } else {
      notas = [nota, ...notas];
    }
    notifyListeners();
    await _persistirNotas();
  }

  /// Devolve a posição para o "desfazer" poder recolocar no mesmo lugar.
  Future<void> apagarNota(int id) async {
    notas = notas.where((n) => n.id != id).toList();
    notifyListeners();
    await _persistirNotas();
  }

  Future<void> restaurarNota(Nota nota, int posicao) async {
    final lista = [...notas]..removeWhere((n) => n.id == nota.id);
    lista.insert(posicao.clamp(0, lista.length), nota);
    notas = lista;
    notifyListeners();
    await _persistirNotas();
  }

  Future<void> concluirOnboarding() async {
    onboardingFeito = true;
    notifyListeners();
    await _prefs.setBool(_kOnboarding, true);
  }

  Future<void> _persistirNotas() => _prefs.setString(
      _kNotas, jsonEncode(notas.map((n) => n.paraJson()).toList()));

  Future<void> _persistirMomentos() => _prefs.setString(
      _kMomentos, jsonEncode(momentos.map((m) => m.paraJson()).toList()));

  Future<void> _persistirRegistros() => _prefs.setString(
        _kRegistros,
        jsonEncode({
          for (final e in _registros.entries)
            e.key: {
              for (final r in e.value.entries) '${r.key}': r.value.paraJson(),
            },
        }),
      );
}
