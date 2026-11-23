import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Os 5 estados da Pepita (ver docs/SPEC.md §5.2).
enum EstadoPepita { tranquila, animada, comemorando, aconchegada, curiosa }

/// Parâmetros que o painter desenha. Mutável e "ouvível": o painter repinta
/// sempre que a pose muda, sem reconstruir a árvore de widgets.
///
/// É esta classe (e o painter abaixo) que pode ser trocada no futuro por uma
/// arte desenhada à mão, sem mexer no resto do app.
class PosePepita extends ChangeNotifier {
  /// 0 = arquinhos felizes, 1 = pontinhos brilhantes.
  double pontos = 0;

  /// 0 = arquinho para cima (feliz), 1 = arquinho para baixo (soninho).
  double sono = 0;

  /// 0 = olhos abertos, 1 = piscando.
  double piscar = 0;

  /// Inclinação do corpo, em radianos.
  double inclinacao = 0;
  double escalaX = 1;
  double escalaY = 1;

  /// Deslocamento vertical do pulo, em unidades do desenho (negativo = sobe).
  double deslocY = 0;

  /// Brilho da lanterna em forma de coração (0–1).
  double lanterna = 0.15;

  /// Cintilar da joia (0–1).
  double joia = 0;

  /// 0 = patinhas ao lado, 1 = abraçando a joia.
  double abraca = 0;

  /// Abertura da boquinha (0–1).
  double boca = 0;

  /// Visibilidade dos "zzz" e do "?".
  double zzz = 0;
  double interrogacao = 0;

  /// Tempo em segundos, para animar os "zzz".
  double tempo = 0;

  void atualizar() => notifyListeners();
}

/// Desenha a Pepita: uma toupeirinha garimpeira, tudo em formas arredondadas.
/// O desenho usa uma grade de 100×100.
class PepitaPainter extends CustomPainter {
  PepitaPainter(this.pose) : super(repaint: pose);

  final PosePepita pose;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100;
    canvas.save();
    canvas.scale(u);

    // Sombra no chão (não gira, só encolhe quando ela pula).
    final altura = (-pose.deslocY).clamp(0.0, 30.0);
    final encolher = 1 - altura / 60;
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(50, 94), width: 54 * encolher, height: 6.5),
      Paint()..color = Paleta.rosa.withValues(alpha: 0.55 * encolher),
    );

    // Corpo: gira/estica a partir dos pezinhos.
    canvas.save();
    canvas.translate(50, 93 + pose.deslocY);
    canvas.rotate(pose.inclinacao);
    canvas.scale(pose.escalaX, pose.escalaY);
    canvas.translate(-50, -93);

    _pes(canvas);
    _orelhas(canvas);
    _corpo(canvas);
    _rosto(canvas);
    _joia(canvas);
    _patinhas(canvas);
    _capacete(canvas);
    canvas.restore();

    _zzz(canvas);
    _interrogacao(canvas);
    canvas.restore();
  }

  void _pes(Canvas canvas) {
    final p = Paint()..color = Paleta.pessegoSombra;
    canvas.drawOval(Rect.fromCenter(center: const Offset(37, 92), width: 13, height: 7), p);
    canvas.drawOval(Rect.fromCenter(center: const Offset(63, 92), width: 13, height: 7), p);
  }

  void _orelhas(Canvas canvas) {
    final fora = Paint()..color = Paleta.pessego;
    final dentro = Paint()..color = Paleta.rosa;
    for (final x in [21.0, 79.0]) {
      canvas.drawCircle(Offset(x, 50), 7, fora);
      canvas.drawCircle(Offset(x, 50), 3.6, dentro);
    }
  }

  void _corpo(Canvas canvas) {
    final rect = Rect.fromCenter(center: const Offset(50, 63), width: 66, height: 60);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 1.0,
          colors: [Color(0xFFFBE3D8), Paleta.pessego, Paleta.pessegoSombra],
          stops: [0.0, 0.6, 1.0],
        ).createShader(rect),
    );
    // Barriguinha creme.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 80), width: 38, height: 24),
      Paint()..color = Paleta.creme,
    );
  }

  void _rosto(Canvas canvas) {
    // Bochechas.
    final b = Paint()..color = Paleta.rosaForte.withValues(alpha: 0.45);
    canvas.drawOval(Rect.fromCenter(center: const Offset(33, 63.5), width: 9, height: 6), b);
    canvas.drawOval(Rect.fromCenter(center: const Offset(67, 63.5), width: 9, height: 6), b);

    // Olhos.
    for (final x in [40.0, 60.0]) {
      _olho(canvas, x, 56);
    }

    // Focinho.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 61.5), width: 8, height: 6),
      Paint()..color = Paleta.rosaForte,
    );
    canvas.drawCircle(const Offset(48.6, 60.4), 1.1,
        Paint()..color = Paleta.branco.withValues(alpha: 0.7));

    // Boquinha.
    final aberta = pose.boca;
    final boca = Path()
      ..moveTo(45.5, 66)
      ..quadraticBezierTo(50, 66 + 3 + 4 * aberta, 54.5, 66);
    if (aberta > 0.15) {
      canvas.drawPath(
        boca..close(),
        Paint()..color = Paleta.cacau.withValues(alpha: 0.85),
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(50, 68.2 + 2 * aberta), width: 4.2, height: 2.4 * aberta),
        Paint()..color = Paleta.rosaForte,
      );
    } else {
      canvas.drawPath(
        boca,
        Paint()
          ..color = Paleta.cacau
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _olho(Canvas canvas, double x, double y) {
    final arcoAlpha = 1 - pose.pontos;
    if (arcoAlpha > 0.01) {
      // Arquinho: curva para cima (feliz) ou para baixo (soninho).
      final curva = (1 - 2 * pose.sono) * (1 - 0.9 * pose.piscar);
      final p = Path()
        ..moveTo(x - 4.2, y + 1.5 * (curva > 0 ? 1 : -1) * 0)
        ..quadraticBezierTo(x, y - 6 * curva, x + 4.2, y);
      canvas.drawPath(
        p,
        Paint()
          ..color = Paleta.cacau.withValues(alpha: arcoAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..strokeCap = StrokeCap.round,
      );
    }
    if (pose.pontos > 0.01) {
      final alt = 5.4 * (1 - 0.92 * pose.piscar);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 5.4, height: alt),
        Paint()..color = Paleta.cacau.withValues(alpha: pose.pontos),
      );
      if (pose.piscar < 0.5) {
        canvas.drawCircle(Offset(x + 1, y - 1.2), 1.1,
            Paint()..color = Paleta.branco.withValues(alpha: pose.pontos));
      }
    }
  }

  Path _gema(double cx, double cy, double r) => Path()
    ..moveTo(cx - r, cy - r * 0.35)
    ..lineTo(cx - r * 0.55, cy - r * 0.95)
    ..lineTo(cx + r * 0.55, cy - r * 0.95)
    ..lineTo(cx + r, cy - r * 0.35)
    ..lineTo(cx, cy + r * 1.05)
    ..close();

  void _joia(Canvas canvas) {
    const cx = 50.0, cy = 80.0;
    const r = 7.5;
    final g = _gema(cx, cy, r);
    final rect = g.getBounds();
    canvas.drawPath(
      g,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFEBB8), Paleta.dourado, Paleta.douradoForte],
        ).createShader(rect),
    );
    // Facetas.
    final faceta = Paint()
      ..color = Paleta.branco.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(cx - r, cy - r * 0.35)
        ..lineTo(cx + r, cy - r * 0.35)
        ..moveTo(cx - r * 0.2, cy - r * 0.35)
        ..lineTo(cx - r * 0.55, cy - r * 0.95)
        ..moveTo(cx + r * 0.2, cy - r * 0.35)
        ..lineTo(cx + r * 0.55, cy - r * 0.95)
        ..moveTo(cx - r * 0.2, cy - r * 0.35)
        ..lineTo(cx, cy + r * 1.05)
        ..moveTo(cx + r * 0.2, cy - r * 0.35)
        ..lineTo(cx, cy + r * 1.05),
      faceta,
    );

    // Cintilar.
    if (pose.joia > 0.01) {
      _estrela(canvas, Offset(cx + r * 0.9, cy - r * 1.1), 5.5 * pose.joia,
          Paleta.branco.withValues(alpha: pose.joia));
      _estrela(canvas, Offset(cx - r * 1.1, cy + r * 0.2), 3.2 * pose.joia,
          Paleta.dourado.withValues(alpha: pose.joia));
    }
  }

  void _estrela(Canvas canvas, Offset c, double r, Color cor) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = cor);
  }

  void _patinhas(Canvas canvas) {
    final fora = Paint()..color = Paleta.pessego;
    final borda = Paint()
      ..color = Paleta.pessegoSombra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final almofada = Paint()..color = Paleta.rosa;
    final a = Curves.easeInOut.transform(pose.abraca);
    for (final lado in [-1.0, 1.0]) {
      final x = lerpDouble(50 + lado * 25, 50 + lado * 9, a)!;
      final y = lerpDouble(76, 80, a)!;
      final giro = lado * lerpDouble(0.25, -0.5, a)!;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(giro);
      final r = Rect.fromCenter(center: Offset.zero, width: 9.5, height: 12);
      canvas.drawOval(r, fora);
      canvas.drawOval(r, borda);
      canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, 1.6), width: 4.4, height: 3.6), almofada);
      for (final dx in [-2.4, 0.0, 2.4]) {
        canvas.drawCircle(Offset(dx, -2.6), 1.0, almofada);
      }
      canvas.restore();
    }
  }

  void _capacete(Canvas canvas) {
    // Cúpula.
    final cupula = Path()
      ..moveTo(20, 46)
      ..arcTo(Rect.fromCenter(center: const Offset(50, 46), width: 60, height: 50),
          math.pi, math.pi, false)
      ..close();
    canvas.drawPath(cupula, Paint()..color = Paleta.creme);
    canvas.drawPath(
      cupula,
      Paint()
        ..color = Paleta.rosa
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
    // Faixa rosinha.
    canvas.save();
    canvas.clipPath(cupula);
    canvas.drawRect(const Rect.fromLTWH(18, 33, 64, 3.2),
        Paint()..color = Paleta.rosaBebe);
    canvas.restore();
    // Aba.
    final aba = RRect.fromRectAndRadius(
        const Rect.fromLTWH(17, 44.5, 66, 5.6), const Radius.circular(3));
    canvas.drawRRect(aba, Paint()..color = Paleta.cremeEscuro);
    canvas.drawRRect(
      aba,
      Paint()
        ..color = Paleta.rosa
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // Lanterna em forma de coração (brilho dourado).
    const c = Offset(50, 28.5);
    if (pose.lanterna > 0.01) {
      canvas.drawCircle(
        c,
        15 + 6 * pose.lanterna,
        Paint()
          ..color = Paleta.dourado.withValues(alpha: 0.55 * pose.lanterna)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    final coracao = _coracao(c, 5.6);
    canvas.drawPath(
      coracao,
      Paint()
        ..color = Color.lerp(Paleta.rosa, Paleta.dourado, pose.lanterna)!,
    );
    canvas.drawPath(
      coracao,
      Paint()
        ..color = Paleta.douradoForte.withValues(alpha: 0.5 + 0.4 * pose.lanterna)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawCircle(Offset(c.dx - 2, c.dy - 1.8), 1,
        Paint()..color = Paleta.branco.withValues(alpha: 0.85));
  }

  Path _coracao(Offset c, double r) {
    final p = Path();
    p.moveTo(c.dx, c.dy + r * 1.0);
    p.cubicTo(c.dx - r * 2.0, c.dy - r * 0.2, c.dx - r * 0.9, c.dy - r * 1.4,
        c.dx, c.dy - r * 0.45);
    p.cubicTo(c.dx + r * 0.9, c.dy - r * 1.4, c.dx + r * 2.0, c.dy - r * 0.2,
        c.dx, c.dy + r * 1.0);
    p.close();
    return p;
  }

  void _zzz(Canvas canvas) {
    if (pose.zzz < 0.01) return;
    for (var i = 0; i < 3; i++) {
      final fase = ((pose.tempo * 0.45) + i / 3) % 1.0;
      final alpha = math.sin(math.pi * fase) * pose.zzz;
      final tp = TextPainter(
        text: TextSpan(
          text: 'z',
          style: Textos.titulo(
            tamanho: 7 + 5 * fase,
            cor: Paleta.cacauClaro.withValues(alpha: alpha.clamp(0.0, 1.0)),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(70 + 9 * fase, 30 - 20 * fase));
    }
  }

  void _interrogacao(Canvas canvas) {
    if (pose.interrogacao < 0.01) return;
    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: Textos.titulo(
          tamanho: 13 * (0.6 + 0.4 * pose.interrogacao),
          cor: Paleta.rosaForte.withValues(alpha: pose.interrogacao),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final balanco = math.sin(pose.tempo * 5) * 1.5;
    tp.paint(canvas, Offset(74 + balanco, 14));
  }

  @override
  bool shouldRepaint(PepitaPainter old) => old.pose != pose;
}

/// A Pepita com todos os estados e animações.
///
/// `Pepita(estado:, tamanho:)` controla os próprios controladores; o painter só
/// recebe parâmetros (ver [PosePepita]).
class Pepita extends StatefulWidget {
  const Pepita({
    super.key,
    this.estado = EstadoPepita.tranquila,
    this.tamanho = 180,
    this.aoTocar,
    this.aoSegurar,
    this.aoDecolar,
  });

  final EstadoPepita estado;
  final double tamanho;
  final VoidCallback? aoTocar;
  final VoidCallback? aoSegurar;

  /// Chamado no instante em que ela salta, durante a comemoração
  /// (a tela usa para soltar as partículas).
  final VoidCallback? aoDecolar;

  @override
  State<Pepita> createState() => _PepitaState();
}

class _PepitaState extends State<Pepita> with SingleTickerProviderStateMixin {
  final PosePepita _pose = PosePepita();
  final math.Random _rnd = math.Random();
  late final Ticker _ticker;

  Duration _anterior = Duration.zero;
  double _t = 0;

  // Entradas de estado / toque.
  double _inicioEstado = 0;
  bool _decolou = false;
  double _inicioToque = -10;

  // Piscar e cintilar da joia.
  double _proximoPiscar = 2;
  double _inicioPiscar = -10;
  double _proximaJoia = 3;
  double _inicioJoia = -10;

  bool _reduzir = false;

  @override
  void initState() {
    super.initState();
    _proximoPiscar = 2 + _rnd.nextDouble() * 3;
    _proximaJoia = 2 + _rnd.nextDouble() * 4;
    _ticker = createTicker(_aoTique)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void didUpdateWidget(Pepita antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.estado != widget.estado) {
      _inicioEstado = _t;
      _decolou = false;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pose.dispose();
    super.dispose();
  }

  double _suave(double atual, double alvo, double dt, [double k = 8]) =>
      atual + (alvo - atual) * (1 - math.exp(-dt * k));

  void _aoTique(Duration agora) {
    var dt = (agora - _anterior).inMicroseconds / 1e6;
    _anterior = agora;
    if (dt <= 0 || dt > 0.1) dt = 1 / 60;
    _t += dt;
    final p = _pose;
    p.tempo = _t;
    final estado = widget.estado;
    final mov = _reduzir ? 0.0 : 1.0; // "reduzir animações": sem movimento forte

    // ---- alvos por estado ----
    double pontos = 0, sono = 0, lanterna = 0.15, abraca = 0, boca = 0;
    double zzz = 0, duvida = 0, inclina = 0, respPeriodo = 3, respAmp = 0.03;
    switch (estado) {
      case EstadoPepita.tranquila:
        break;
      case EstadoPepita.animada:
        lanterna = 0.55 + 0.35 * math.sin(_t * 2.6);
        pontos = 0.35;
        inclina = 0.07 * math.sin(_t * 2 * math.pi / 2.4) * mov;
        break;
      case EstadoPepita.comemorando:
        pontos = 1;
        lanterna = 1;
        boca = 1;
        inclina = 0.05 * math.sin(_t * 9) * mov;
        break;
      case EstadoPepita.aconchegada:
        sono = 1;
        abraca = 1;
        zzz = 1;
        respPeriodo = 5;
        respAmp = 0.025;
        lanterna = 0.05;
        break;
      case EstadoPepita.curiosa:
        pontos = 1;
        duvida = 1;
        inclina = 0.2;
        lanterna = 0.3;
        break;
    }

    // Toque: piscadinha de alegria + pulinho.
    final dtToque = _t - _inicioToque;
    final toque = dtToque >= 0 && dtToque < 0.7;
    if (toque) {
      pontos = math.max(pontos, 0.9);
      boca = math.max(boca, 0.6);
    }

    p.pontos = _suave(p.pontos, pontos, dt);
    p.sono = _suave(p.sono, sono, dt, 5);
    p.lanterna = _suave(p.lanterna, lanterna.clamp(0.0, 1.0), dt, 6);
    p.abraca = _suave(p.abraca, abraca, dt, 4);
    p.boca = _suave(p.boca, boca, dt, 10);
    p.zzz = _suave(p.zzz, zzz, dt, 3);
    p.interrogacao = _suave(p.interrogacao, duvida, dt, 6);
    p.inclinacao = _suave(p.inclinacao, inclina, dt, estado == EstadoPepita.curiosa ? 7 : 10);

    // ---- respiração ----
    final resp = math.sin(_t * 2 * math.pi / respPeriodo) * respAmp * mov;
    var sx = 1 - resp * 0.5;
    var sy = 1 + resp;
    var y = 0.0;

    // ---- pulo da comemoração (squash & stretch) ----
    if (estado == EstadoPepita.comemorando) {
      final r = _pulo(_t - _inicioEstado);
      sx *= r.sx;
      sy *= r.sy;
      y += r.y * mov;
      if (!_decolou && _t - _inicioEstado >= 0.18) {
        _decolou = true;
        HapticFeedback.mediumImpact();
        widget.aoDecolar?.call();
      }
    }
    if (toque) {
      final f = dtToque / 0.7;
      y += -5 * math.sin(math.pi * f) * mov;
      p.inclinacao += 0.08 * math.sin(f * 4 * math.pi) * (1 - f) * mov;
    }
    p.escalaX = sx;
    p.escalaY = sy;
    p.deslocY = y;

    // ---- piscar a cada 3–6s ----
    if (_t >= _proximoPiscar) {
      _inicioPiscar = _t;
      _proximoPiscar = _t + 3 + _rnd.nextDouble() * 3;
    }
    final fb = (_t - _inicioPiscar) / 0.18;
    p.piscar = (fb >= 0 && fb <= 1) ? math.sin(math.pi * fb) : 0;

    // ---- joia cintila de vez em quando ----
    if (_t >= _proximaJoia) {
      _inicioJoia = _t;
      _proximaJoia = _t + 4 + _rnd.nextDouble() * 5;
    }
    final fj = (_t - _inicioJoia) / 0.9;
    var joia = (fj >= 0 && fj <= 1) ? math.sin(math.pi * fj) : 0.0;
    if (estado == EstadoPepita.comemorando) {
      joia = math.max(joia, 0.6 + 0.4 * math.sin(_t * 8));
    }
    p.joia = joia;

    p.atualizar();
  }

  /// Linha do tempo do pulo (segundos desde o início da comemoração).
  ({double y, double sx, double sy}) _pulo(double t) {
    if (t < 0.18) {
      final f = Curves.easeOut.transform(t / 0.18);
      return (y: 0, sx: 1 + 0.12 * f, sy: 1 - 0.18 * f);
    }
    if (t < 0.38) {
      final f = (t - 0.18) / 0.2;
      return (
        y: -17 * Curves.easeOut.transform(f),
        sx: lerpDouble(1.12, 0.92, f)!,
        sy: lerpDouble(0.82, 1.18, f)!,
      );
    }
    if (t < 0.66) {
      final f = (t - 0.38) / 0.28;
      return (
        y: -17 * (1 - Curves.easeIn.transform(f)),
        sx: lerpDouble(0.92, 0.96, f)!,
        sy: lerpDouble(1.18, 1.1, f)!,
      );
    }
    if (t < 0.82) {
      final f = (t - 0.66) / 0.16;
      return (
        y: 0,
        sx: lerpDouble(0.96, 1.12, Curves.easeOut.transform(f))!,
        sy: lerpDouble(1.1, 0.85, Curves.easeOut.transform(f))!,
      );
    }
    if (t < 1.15) {
      final f = (t - 0.82) / 0.33;
      final e = Curves.elasticOut.transform(f);
      return (y: -4 * math.sin(math.pi * f), sx: lerpDouble(1.12, 1, e)!, sy: lerpDouble(0.85, 1, e)!);
    }
    return (y: 0, sx: 1, sy: 1);
  }

  void _tocou() {
    HapticFeedback.lightImpact();
    _inicioToque = _t;
    widget.aoTocar?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pepita, a toupeirinha garimpeira',
      button: widget.aoTocar != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tocou,
        onLongPress: widget.aoSegurar,
        child: SizedBox(
          width: widget.tamanho,
          height: widget.tamanho,
          child: RepaintBoundary(
            child: CustomPaint(painter: PepitaPainter(_pose)),
          ),
        ),
      ),
    );
  }
}
