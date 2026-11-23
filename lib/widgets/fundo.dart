import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme.dart';

enum _Tipo { nuvem, coracao, estrela }

class _Flutuante {
  const _Flutuante(this.tipo, this.x, this.y, this.tamanho, this.velocidade,
      this.fase, this.alcance);
  final _Tipo tipo;
  final double x; // 0–1
  final double y; // 0–1
  final double tamanho;
  final double velocidade;
  final double fase;
  final double alcance;
}

/// Fundo da tela Hoje: degradê sutil creme → rosa-bebê, com nuvenzinhas,
/// corações e estrelinhas flutuando devagar (movimento senoidal lento).
/// O céu muda de leve conforme a hora do dia.
class FundoFlutuante extends StatefulWidget {
  const FundoFlutuante({super.key, required this.hora});

  /// Hora atual (0–23) para escolher o tom do céu.
  final int hora;

  @override
  State<FundoFlutuante> createState() => _FundoFlutuanteState();
}

class _FundoFlutuanteState extends State<FundoFlutuante>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  static const _itens = [
    _Flutuante(_Tipo.nuvem, 0.12, 0.10, 54, 0.6, 0.0, 18),
    _Flutuante(_Tipo.nuvem, 0.80, 0.22, 42, 0.45, 1.8, 14),
    _Flutuante(_Tipo.coracao, 0.88, 0.07, 18, 0.9, 0.7, 9),
    _Flutuante(_Tipo.estrela, 0.30, 0.05, 14, 1.0, 2.4, 7),
    _Flutuante(_Tipo.coracao, 0.06, 0.38, 14, 0.8, 3.1, 8),
    _Flutuante(_Tipo.estrela, 0.92, 0.46, 12, 1.1, 4.0, 7),
    _Flutuante(_Tipo.nuvem, 0.05, 0.62, 36, 0.5, 5.2, 12),
    _Flutuante(_Tipo.estrela, 0.84, 0.74, 13, 0.9, 1.1, 8),
  ];

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Color get _ceu {
    final h = widget.hora;
    if (h >= 5 && h < 11) return Paleta.ceuManha;
    if (h >= 11 && h < 16) return Paleta.ceuTarde;
    return Paleta.ceuNoite;
  }

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: _ceu),
      duration: const Duration(seconds: 2),
      builder: (context, ceu, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ceu ?? _ceu, Paleta.creme, Paleta.rosaBebe],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: _PintorFundo(reduzir ? null : _ctl),
            ),
          ),
        );
      },
    );
  }
}

class _PintorFundo extends CustomPainter {
  _PintorFundo(this.ctl) : super(repaint: ctl);

  final AnimationController? ctl;

  @override
  void paint(Canvas canvas, Size size) {
    final t = (ctl?.value ?? 0) * 60; // segundos
    for (final f in _FundoFlutuanteState._itens) {
      final dx = math.sin(t * 0.35 * f.velocidade + f.fase) * f.alcance;
      final dy = math.cos(t * 0.28 * f.velocidade + f.fase * 1.3) * f.alcance * 0.7;
      final c = Offset(size.width * f.x + dx, size.height * f.y + dy);
      switch (f.tipo) {
        case _Tipo.nuvem:
          _nuvem(canvas, c, f.tamanho);
        case _Tipo.coracao:
          _coracao(canvas, c, f.tamanho);
        case _Tipo.estrela:
          _estrela(canvas, c, f.tamanho, t * f.velocidade + f.fase);
      }
    }
  }

  void _nuvem(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = Paleta.branco.withValues(alpha: 0.65);
    canvas.drawCircle(c, r * 0.5, p);
    canvas.drawCircle(c + Offset(-r * 0.45, r * 0.12), r * 0.36, p);
    canvas.drawCircle(c + Offset(r * 0.48, r * 0.14), r * 0.4, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, r * 0.3), width: r * 1.5, height: r * 0.5),
        Radius.circular(r * 0.25),
      ),
      p,
    );
  }

  void _coracao(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r * 0.45)
      ..cubicTo(c.dx - r, c.dy - r * 0.1, c.dx - r * 0.45, c.dy - r * 0.65,
          c.dx, c.dy - r * 0.2)
      ..cubicTo(c.dx + r * 0.45, c.dy - r * 0.65, c.dx + r, c.dy - r * 0.1,
          c.dx, c.dy + r * 0.45)
      ..close();
    canvas.drawPath(path, Paint()..color = Paleta.rosa.withValues(alpha: 0.55));
  }

  void _estrela(Canvas canvas, Offset c, double r, double fase) {
    final brilho = 0.45 + 0.25 * math.sin(fase * 1.5);
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = Paleta.dourado.withValues(alpha: brilho));
  }

  @override
  bool shouldRepaint(_PintorFundo old) => old.ctl != ctl;
}
