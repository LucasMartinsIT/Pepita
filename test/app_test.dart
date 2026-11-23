import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepita/main.dart';
import 'package:pepita/models.dart';
import 'package:pepita/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Store> _abrirApp(WidgetTester t) async {
  SharedPreferences.setMockInitialValues({'onboardingFeito': true});
  final store = Store();
  await store.carregar();
  await t.binding.setSurfaceSize(const Size(400, 900));
  await t.pumpWidget(PepitaApp(store: store));
  await t.pump(const Duration(seconds: 2));
  return store;
}

/// Carrega as fontes do app: com a fonte padrão dos testes (Ahem) os textos
/// ficam largos demais e escondem botões.
Future<void> _carregarFontes() async {
  for (final f in const {
    'Fredoka': 'assets/fonts/Fredoka.ttf',
    'Quicksand': 'assets/fonts/Quicksand.ttf',
  }.entries) {
    final dados = ByteData.sublistView(File(f.value).readAsBytesSync());
    await (FontLoader(f.key)..addFont(Future.value(dados))).load();
  }
}

void main() {
  setUpAll(_carregarFontes);
  setUp(() {
    // haptic no teste não tem canal nativo
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  testWidgets('Hoje mostra os 3 momentos e a Pepita', (t) async {
    await _abrirApp(t);
    expect(find.text('Garimpo da manhã'), findsOneWidget);
    expect(find.text('Garimpo do almoço'), findsOneWidget);
    expect(find.text('Garimpo da volta'), findsOneWidget);
    expect(find.bySemanticsLabel('Pepita, a toupeirinha garimpeira'),
        findsWidgets);
  });

  testWidgets('registrar "descansei" pela sheet persiste o registro', (t) async {
    final store = await _abrirApp(t);
    await t.tap(find.text('Garimpo da manhã'));
    await t.pump(); // monta a rota
    await t.pump(const Duration(seconds: 1)); // termina a mola
    expect(find.text('Como foi esse garimpo?'), findsOneWidget);

    await t.tap(find.text('Hoje não, e tá tudo bem ☁️'));
    await t.pump(const Duration(seconds: 1));

    expect(store.registroDe(DateTime.now(), 0)?.tipo, TipoRegistro.descanso);
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('registrar "postei" com atalho de quantidade', (t) async {
    final store = await _abrirApp(t);
    await t.tap(find.text('Garimpo do almoço'));
    await t.pump();
    await t.pump(const Duration(seconds: 1));

    await t.tap(find.text('5'));
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('Postei! ✨'));
    await t.pump(const Duration(seconds: 1));

    final r = store.registroDe(DateTime.now(), 1);
    expect(r?.tipo, TipoRegistro.postei);
    expect(r?.qtd, 5);
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('navega entre as abas', (t) async {
    await _abrirApp(t);
    await t.tap(find.bySemanticsLabel('Cantinho'));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Seu cantinho 💗'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Ajustes'));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Ajustes ✨'), findsOneWidget);
  });
}
