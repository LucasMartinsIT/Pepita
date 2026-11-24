// Gera a arte do Android (ícone do app e imagem grande da notificação)
// a partir do próprio desenho do mascote (Chocolatinho) (CustomPainter).
//
// Rode com:  flutter test tool/gerar_arte_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pepita/theme.dart';
import 'package:pepita/widgets/pepita.dart';

const _res = 'android/app/src/main/res';

PosePepita _poseIcone() => PosePepita()
  ..lanterna = 0.9
  ..joia = 0.7
  ..boca = 0.15;

Future<void> _salvar(WidgetTester t, GlobalKey chave, String caminho,
    int lado) async {
  await t.runAsync(() async {
    final RenderRepaintBoundary r =
        chave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await r.toImage(pixelRatio: lado / r.size.width);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final arq = File(caminho)..createSync(recursive: true);
    arq.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _desenhar(WidgetTester t, GlobalKey chave, Widget filho) async {
  await t.binding.setSurfaceSize(const Size(400, 400));
  t.view.devicePixelRatio = 1;
  await t.pumpWidget(Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: RepaintBoundary(key: chave, child: filho)),
  ));
}

void main() {
  testWidgets('imagem grande da notificação', (t) async {
    final k = GlobalKey();
    await _desenhar(
        t,
        k,
        Container(
          width: 400,
          height: 400,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Paleta.azulBebe, shape: BoxShape.circle),
          child: CustomPaint(painter: PepitaPainter(_poseIcone())),
        ));
    await _salvar(t, k, '$_res/drawable-nodpi/pepita_grande.png', 256);
  });

  testWidgets('ícone adaptativo (foreground)', (t) async {
    final k = GlobalKey();
    // Área de 108dp com a Pepita dentro da zona segura (~66dp).
    await _desenhar(
        t,
        k,
        SizedBox(
          width: 400,
          height: 400,
          child: Padding(
            padding: const EdgeInsets.all(58),
            child: CustomPaint(painter: PepitaPainter(_poseIcone())),
          ),
        ));
    await _salvar(t, k, '$_res/drawable-nodpi/ic_launcher_foreground.png', 432);
  });

  const densidades = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
  for (final e in densidades.entries) {
    testWidgets('ícone legado ${e.key}', (t) async {
      final k = GlobalKey();
      await _desenhar(
          t,
          k,
          Container(
            width: 400,
            height: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Paleta.azulBebe,
              borderRadius: BorderRadius.circular(90),
            ),
            child: CustomPaint(painter: PepitaPainter(_poseIcone())),
          ));
      await _salvar(t, k, '$_res/mipmap-${e.key}/ic_launcher.png', e.value);
    });
  }
}
