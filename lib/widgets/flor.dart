import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Uma florzinha do Cantinho.
///
/// - [petalasBrilhantes] 1–3: flor rosa desabrochada, com pétalas brilhantes.
/// - 0: botão de flor fechado em lavanda com um "zzz" bem pequeno
///   (dia de descanso — bonito, não triste).
/// - [hoje]: contorno pontilhado animado.
class Flor extends StatefulWidget {
  const Flor({
    super.key,
    required this.petalasBrilhantes,
    this.hoje = false,
    this.selecionada = false,
    this.tamanho = 44,
  });

  final int petalasBrilhantes;
  final bool hoje;
  final bool selecionada;
  final double tamanho;

  @override
  State<Flor> createState() => _FlorState();
}

class _FlorState extends State<Flor> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _atualizar();
  }

  @override
  void didUpdateWidget(Flor antiga) {
    super.didUpdateWidget(antiga);
    _atualizar();
  }

  void _atualizar() {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.hoje && !reduzir) {
      if (!_ctl.isAnimating) _ctl.repeat();
    } else {
      _ctl.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _atualizar();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tam = widget.tamanho;
    return AnimatedScale(
      scale: widget.selecionada ? 1.12 : 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      child: SizedBox(
        width: tam,
        height: tam,
        child: CustomPaint(painter: _PintorFlor(widget, _ctl)),
      ),
    );
  }
}

class _PintorFlor extends CustomPainter {
  _PintorFlor(this.flor, this.ctl) : super(repaint: ctl);

  final Flor flor;
  final AnimationController ctl;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    if (flor.hoje) _contorno(canvas, c, r);

    if (flor.petalasBrilhantes > 0) {
      _desabrochada(canvas, c, r * 0.78, flor.petalasBrilhantes);
    } else {
      _botao(canvas, c, r * 0.78);
    }
  }

  void _contorno(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = Paleta.rosaForte
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const tracos = 16;
    final giro = ctl.value * 2 * math.pi;
    for (var i = 0; i < tracos; i++) {
      final a = giro + i * 2 * math.pi / tracos;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r - 1), a,
          math.pi / tracos * 0.9, false, paint);
    }
  }

  void _desabrochada(Canvas canvas, Offset c, double r, int brilhantes) {
    const petalas = 5;
    for (var i = 0; i < petalas; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / petalas;
      final brilha = i < brilhantes;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a + math.pi / 2);
      final rect = Rect.fromCenter(
          center: Offset(0, -r * 0.5), width: r * 0.74, height: r * 0.86);
      canvas.drawOval(rect, Paint()..color = brilha ? Paleta.rosaForte : Paleta.rosa);
      if (brilha) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(-r * 0.08, -r * 0.62), width: r * 0.18, height: r * 0.3),
          Paint()..color = Paleta.branco.withValues(alpha: 0.75),
        );
      }
      canvas.restore();
    }
    canvas.drawCircle(c, r * 0.28, Paint()..color = Paleta.dourado);
    canvas.drawCircle(c + Offset(-r * 0.07, -r * 0.07), r * 0.08,
        Paint()..color = Paleta.branco.withValues(alpha: 0.8));
    // Brilhinhos nas pétalas brilhantes.
    for (var i = 0; i < brilhantes; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / petalas;
      _estrela(canvas, c + Offset(math.cos(a), math.sin(a)) * r * 0.95, r * 0.2);
    }
  }

  void _botao(Canvas canvas, Offset c, double r) {
    // Folhinhas.
    final folha = Paint()..color = Paleta.menta;
    canvas.save();
    canvas.translate(c.dx, c.dy + r * 0.45);
    for (final lado in [-1.0, 1.0]) {
      canvas.save();
      canvas.rotate(lado * 0.7);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(lado * r * 0.3, 0), width: r * 0.5, height: r * 0.26),
          folha);
      canvas.restore();
    }
    canvas.restore();
    // Botão fechado (gotinha lavanda).
    final p = Path()
      ..moveTo(c.dx, c.dy - r * 0.85)
      ..cubicTo(c.dx + r * 0.9, c.dy - r * 0.2, c.dx + r * 0.7, c.dy + r * 0.6,
          c.dx, c.dy + r * 0.6)
      ..cubicTo(c.dx - r * 0.7, c.dy + r * 0.6, c.dx - r * 0.9, c.dy - r * 0.2,
          c.dx, c.dy - r * 0.85)
      ..close();
    canvas.drawPath(p, Paint()..color = Paleta.lavanda);
    canvas.drawPath(
      p,
      Paint()
        ..color = Paleta.cacauClaro.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - r * 0.8),
      Offset(c.dx, c.dy + r * 0.3),
      Paint()
        ..color = Paleta.cacauClaro.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );
    // zzz bem pequeno.
    final tp = TextPainter(
      text: TextSpan(
          text: 'zzz',
          style: Textos.titulo(tamanho: r * 0.42, cor: Paleta.cacauClaro)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx + r * 0.35, c.dy - r * 1.05));
  }

  void _estrela(Canvas canvas, Offset c, double r) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = Paleta.dourado);
  }

  @override
  bool shouldRepaint(_PintorFlor old) =>
      old.flor.petalasBrilhantes != flor.petalasBrilhantes ||
      old.flor.hoje != flor.hoje;
}
