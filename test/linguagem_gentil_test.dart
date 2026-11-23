import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pepita/frases.dart';
import 'package:pepita/theme.dart';

/// Palavras que o app nunca pode usar (ver CLAUDE.md — "regra de ouro").
const _proibidas = [
  'atrasad',
  'pendente',
  'esqueceu',
  'meta',
  'sequência',
  'streak',
  'falhou',
  'não fez',
];

void main() {
  test('nenhum banco de frases tem linguagem de cobrança', () {
    for (final e in Frases.todos.entries) {
      for (final frase in e.value) {
        for (final p in _proibidas) {
          expect(frase.toLowerCase(), isNot(contains(p)),
              reason: 'banco ${e.key}: "$frase" contém "$p"');
        }
      }
    }
  });

  test('nenhum texto do código da UI tem linguagem de cobrança', () {
    final arquivos = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final f in arquivos) {
      final texto = f.readAsStringSync().toLowerCase();
      for (final p in _proibidas) {
        expect(texto, isNot(contains(p)), reason: '${f.path} contém "$p"');
      }
    }
  });

  test('nenhuma cor da paleta é vermelha ou laranja de alerta', () {
    final cores = <String, Color>{
      'creme': Paleta.creme,
      'cremeEscuro': Paleta.cremeEscuro,
      'rosaBebe': Paleta.rosaBebe,
      'rosa': Paleta.rosa,
      'rosaForte': Paleta.rosaForte,
      'azulBebe': Paleta.azulBebe,
      'azul': Paleta.azul,
      'menta': Paleta.menta,
      'lavanda': Paleta.lavanda,
      'cacau': Paleta.cacau,
      'cacauClaro': Paleta.cacauClaro,
      'dourado': Paleta.dourado,
      'pessego': Paleta.pessego,
      'douradoForte': Paleta.douradoForte,
    };
    for (final e in cores.entries) {
      final hsl = HSLColor.fromColor(e.value);
      final alertaVermelho = hsl.saturation > 0.5 &&
          hsl.lightness < 0.75 &&
          (hsl.hue < 25 || hsl.hue > 350);
      expect(alertaVermelho, isFalse, reason: '${e.key} parece vermelho');
    }
  });

  test('o sorteio não repete a última frase', () {
    String? anterior;
    for (var i = 0; i < 60; i++) {
      final f = Frases.sortear(Frases.carinho);
      expect(f, isNot(anterior));
      anterior = f;
    }
  });

  test('{nome} e {momento} são substituídos', () {
    final f = Frases.preencher('Oi, {nome}! {momento}',
        nome: 'Maria', momento: 'Garimpo');
    expect(f, 'Oi, Maria! Garimpo');
  });
}
