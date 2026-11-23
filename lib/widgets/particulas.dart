import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../theme.dart';

enum _Forma { coracao, estrela, joia }

class _Particula {
  _Particula({
    required this.forma,
    required this.cor,
    required this.vx,
    required this.vy,
    required this.tamanho,
    required this.giro,
    required this.vida,
  });

  final _Forma forma;
  final Color cor;
  final double vx;
  final double vy;
  final double tamanho;
  final double giro;
  final double vida;
}

/// Explosão de corações rosa, estrelinhas douradas e joinhas azuis,
/// com gravidade leve e fade. Chame `disparar()` pela [GlobalKey].
class ExplosaoDeParticulas extends StatefulWidget {
  const ExplosaoDeParticulas({super.key, this.quantidade = 16});

  final int quantidade;

  @override
  State<ExplosaoDeParticulas> createState() => ExplosaoDeParticulasState();
}

class ExplosaoDeParticulasState extends State<ExplosaoDeParticulas>
    with SingleTickerProviderStateMixin {
  final _rnd = math.Random();
  late final Ticker _ticker;
  List<_Particula> _particulas = [];
  double _t = 0;
  Duration _anterior = Duration.zero;
  final ValueNotifier<int> _quadro = ValueNotifier(0);
  bool _ativa = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_aoTique);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _quadro.dispose();
    super.dispose();
  }

  /// Solta uma nova rajada de partículas (12–20).
  void disparar() {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    final n = widget.quantidade;
    _particulas = List.generate(n, (i) {
      final forma = _Forma.values[_rnd.nextInt(3)];
      final angulo = -math.pi / 2 + (_rnd.nextDouble() - 0.5) * math.pi * 1.5;
      final forca = 140 + _rnd.nextDouble() * 190;
      return _Particula(
        forma: forma,
        cor: switch (forma) {
          _Forma.coracao => i.isEven ? Paleta.rosaForte : Paleta.rosa,
          _Forma.estrela => Paleta.dourado,
          _Forma.joia => Paleta.azul,
        },
        vx: math.cos(angulo) * forca,
        vy: math.sin(angulo) * forca,
        tamanho: 7 + _rnd.nextDouble() * 8,
        giro: (_rnd.nextDouble() - 0.5) * 6,
        vida: 1.1 + _rnd.nextDouble() * 0.6,
      );
    });
    _t = 0;
    _anterior = Duration.zero;
    _ativa = true;
    if (!_ticker.isActive) _ticker.start();
  }

  void _aoTique(Duration agora) {
    var dt = (agora - _anterior).inMicroseconds / 1e6;
    _anterior = agora;
    if (dt <= 0 || dt > 0.1) dt = 1 / 60;
    _t += dt;
    if (_t > 2.0) {
      _ativa = false;
      _ticker.stop();
    }
    _quadro.value++;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _PintorParticulas(this, _quadro),
        ),
      ),
    );
  }
}

class _PintorParticulas extends CustomPainter {
  _PintorParticulas(this.estado, Listenable repintar) : super(repaint: repintar);

  final ExplosaoDeParticulasState estado;

  @override
  void paint(Canvas canvas, Size size) {
    if (!estado._ativa) return;
    final origem = Offset(size.width / 2, size.height / 2);
    final t = estado._t;
    for (final p in estado._particulas) {
      if (t > p.vida) continue;
      final f = t / p.vida;
      // posição: velocidade com atrito + gravidade leve
      final atrito = 1 - math.exp(-t * 2.2);
      final x = origem.dx + p.vx * atrito / 2.2;
      final y = origem.dy + p.vy * atrito / 2.2 + 120 * t * t * 0.5;
      final escala = f < 0.15 ? Curves.easeOutBack.transform(f / 0.15) : 1.0;
      final alpha = f < 0.65 ? 1.0 : (1 - (f - 0.65) / 0.35);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.giro * t);
      canvas.scale(escala);
      final paint = Paint()..color = p.cor.withValues(alpha: alpha.clamp(0.0, 1.0));
      switch (p.forma) {
        case _Forma.coracao:
          canvas.drawPath(_coracao(p.tamanho), paint);
        case _Forma.estrela:
          canvas.drawPath(_estrela(p.tamanho), paint);
        case _Forma.joia:
          canvas.drawPath(_joia(p.tamanho), paint);
      }
      canvas.restore();
    }
  }

  Path _coracao(double r) => Path()
    ..moveTo(0, r * 0.9)
    ..cubicTo(-r * 1.9, -r * 0.2, -r * 0.9, -r * 1.3, 0, -r * 0.4)
    ..cubicTo(r * 0.9, -r * 1.3, r * 1.9, -r * 0.2, 0, r * 0.9)
    ..close();

  Path _estrela(double r) => Path()
    ..moveTo(0, -r)
    ..quadraticBezierTo(0, 0, r, 0)
    ..quadraticBezierTo(0, 0, 0, r)
    ..quadraticBezierTo(0, 0, -r, 0)
    ..quadraticBezierTo(0, 0, 0, -r)
    ..close();

  Path _joia(double r) => Path()
    ..moveTo(-r, -r * 0.3)
    ..lineTo(-r * 0.5, -r * 0.9)
    ..lineTo(r * 0.5, -r * 0.9)
    ..lineTo(r, -r * 0.3)
    ..lineTo(0, r)
    ..close();

  @override
  bool shouldRepaint(_PintorParticulas old) => false;
}
