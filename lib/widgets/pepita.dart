import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Os 5 estados da mascote (o Chocolatinho) (ver docs/SPEC.md §5.2).
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

  /// Orelhas: -0.4 (bem caídas) a 1 (levantadas). 0 = relaxadas.
  double orelhas = 0;

  /// Só a orelha direita levantada (curiosidade).
  double orelhaD = 0;

  /// Multiplicador do balanço das orelhas e do rabinho (0 = parado).
  double balancoOrelhas = 1;

  /// Tempo em segundos, para animar os "zzz".
  double tempo = 0;

  void atualizar() => notifyListeners();
}

/// Desenha o Chocolatinho: um coelhinho fofo de orelhas caídas, olhos azuis e
/// rabinho enrolado, segurando uma estrelinha dourada. Tudo em formas
/// arredondadas, numa grade de 100×100.
class PepitaPainter extends CustomPainter {
  PepitaPainter(this.pose) : super(repaint: pose);

  final PosePepita pose;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100;
    canvas.save();
    canvas.scale(u);
    // Um pouco menor, para as orelhas (que se abrem e levantam) caberem.
    canvas.translate(50, 94);
    canvas.scale(0.78);
    canvas.translate(-50, -94);

    // Sombra no chão (não gira, só encolhe quando ela pula).
    final altura = (-pose.deslocY).clamp(0.0, 30.0);
    final encolher = 1 - altura / 60;
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(50, 94), width: 54 * encolher, height: 6.5),
      Paint()..color = Paleta.azul.withValues(alpha: 0.45 * encolher),
    );

    // Corpo: gira/estica a partir dos pezinhos.
    canvas.save();
    canvas.translate(50, 93 + pose.deslocY);
    canvas.rotate(pose.inclinacao);
    canvas.scale(pose.escalaX, pose.escalaY);
    canvas.translate(-50, -93);

    _cauda(canvas);
    _corpo(canvas);
    _pes(canvas);
    _orelha(canvas, -1);
    _orelha(canvas, 1);
    _cabeca(canvas);
    _rosto(canvas);
    _estrela(canvas);
    _patinhas(canvas);
    _coracaoDaCabeca(canvas);
    canvas.restore();

    _zzz(canvas);
    _interrogacao(canvas);
    canvas.restore();
  }

  Paint get _contorno => Paint()
    ..color = Paleta.contornoAzul
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  void _branco(Canvas canvas, Rect r) {
    canvas.drawOval(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.4),
          radius: 1.0,
          colors: [Paleta.branco, Paleta.branco, Paleta.azulBebe],
          stops: [0.0, 0.7, 1.0],
        ).createShader(r),
    );
    canvas.drawOval(r, _contorno);
  }

  void _cauda(Canvas canvas) {
    final balanco = math.sin(pose.tempo * 4.2) * 0.12 * pose.balancoOrelhas;
    canvas.save();
    canvas.translate(68, 88);
    canvas.rotate(balanco);
    canvas.translate(-68, -88);
    const c = Offset(76, 83);
    canvas.drawCircle(c, 7.2, Paint()..color = Paleta.branco);
    canvas.drawCircle(c, 7.2, _contorno);
    // Espiral do rabinho.
    final espiral = Path();
    for (var i = 0; i <= 36; i++) {
      final t = i / 36;
      final ang = 0.6 + t * 3.2 * math.pi;
      final raio = 0.8 + t * 4.6;
      final pt = c + Offset(raio * math.cos(ang), raio * math.sin(ang));
      if (i == 0) {
        espiral.moveTo(pt.dx, pt.dy);
      } else {
        espiral.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(espiral, _contorno);
    canvas.restore();
  }

  void _corpo(Canvas canvas) {
    _branco(canvas,
        Rect.fromCenter(center: const Offset(50, 80), width: 40, height: 29));
  }

  void _pes(Canvas canvas) {
    for (final x in [39.0, 61.0]) {
      _branco(canvas,
          Rect.fromCenter(center: Offset(x, 91.8), width: 15, height: 8.5));
    }
  }

  /// [lado]: -1 esquerda, 1 direita. As orelhas caem para os lados, balançam
  /// de leve e levantam na comemoração.
  void _orelha(Canvas canvas, int lado) {
    final sway = math.sin(pose.tempo * 1.7 + (lado > 0 ? 0.9 : 0)) *
        0.05 *
        pose.balancoOrelhas;
    var ang = 0.55 - 1.2 * pose.orelhas + sway;
    if (lado > 0) ang -= 1.1 * pose.orelhaD;
    canvas.save();
    canvas.translate(50 + lado * 22.0, 44);
    canvas.rotate(lado * ang);
    final r =
        Rect.fromCenter(center: Offset(lado * 17.0, 0), width: 38, height: 18);
    _branco(canvas, r);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(lado * 18.0, 0.5), width: 24, height: 9),
      Paint()..color = Paleta.rosaBebe.withValues(alpha: 0.7),
    );
    canvas.restore();
  }

  void _cabeca(Canvas canvas) {
    _branco(canvas,
        Rect.fromCenter(center: const Offset(50, 52), width: 62, height: 48));
  }

  void _rosto(Canvas canvas) {
    // Bochechas.
    final b = Paint()..color = Paleta.rosaForte.withValues(alpha: 0.4);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(29.5, 61), width: 10, height: 6), b);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(70.5, 61), width: 10, height: 6), b);

    for (final x in [38.0, 62.0]) {
      _olho(canvas, x, 54);
    }

    // Narizinho.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 58.8), width: 3.8, height: 2.6),
      Paint()..color = Paleta.rosaForte,
    );

    // Boquinha: "ω" fofa; abre na comemoração.
    final aberta = pose.boca;
    if (aberta > 0.15) {
      final rect = Rect.fromCenter(
          center: Offset(50, 63.6 + aberta),
          width: 6.4,
          height: 1.5 + 4.5 * aberta);
      canvas.drawOval(rect, Paint()..color = Paleta.cacau.withValues(alpha: 0.85));
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(50, 65.2 + aberta), width: 3.4, height: 2.2 * aberta),
        Paint()..color = Paleta.rosaForte,
      );
    } else {
      final boca = Path()
        ..moveTo(46.6, 62)
        ..quadraticBezierTo(48.3, 65, 50, 62.3)
        ..quadraticBezierTo(51.7, 65, 53.4, 62);
      canvas.drawPath(
        boca,
        Paint()
          ..color = Paleta.olhoAzul.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _olho(Canvas canvas, double x, double y) {
    // Troca arquinho <-> pontinho sem os dois aparecerem juntos.
    final arcoAlpha = (1 - pose.pontos * 2).clamp(0.0, 1.0);
    final pontoAlpha = (pose.pontos * 2 - 1).clamp(0.0, 1.0);
    if (arcoAlpha > 0.01) {
      // Arquinho: curva para cima (feliz) ou para baixo (soninho).
      final curva = (1 - 2 * pose.sono) * (1 - 0.9 * pose.piscar);
      final p = Path()
        ..moveTo(x - 3.8, y + 1)
        ..quadraticBezierTo(x, y + 1 - 6 * curva, x + 3.8, y + 1);
      canvas.drawPath(
        p,
        Paint()
          ..color = Paleta.olhoAzul.withValues(alpha: arcoAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.1
          ..strokeCap = StrokeCap.round,
      );
    }
    if (pontoAlpha > 0.01) {
      final alt = 6.4 * (1 - 0.92 * pose.piscar);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 5.2, height: alt),
        Paint()..color = Paleta.olhoAzul.withValues(alpha: pontoAlpha),
      );
      if (pose.piscar < 0.5) {
        canvas.drawCircle(Offset(x + 0.9, y - 1.4), 1.1,
            Paint()..color = Paleta.branco.withValues(alpha: pontoAlpha));
        canvas.drawCircle(Offset(x - 0.9, y + 1.2), 0.55,
            Paint()..color = Paleta.branco.withValues(alpha: 0.7 * pontoAlpha));
      }
    }
  }

  Path _caminhoEstrela(double cx, double cy, double r) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final raio = i.isEven ? r : r * 0.46;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = Offset(cx + raio * math.cos(a), cy + raio * math.sin(a));
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    return p..close();
  }

  void _estrela(Canvas canvas) {
    const cx = 50.0, cy = 79.5;
    const r = 8.2;
    final g = _caminhoEstrela(cx, cy, r);
    canvas.drawPath(g, Paint()..color = Paleta.dourado);
    canvas.drawPath(
      g,
      Paint()
        ..color = Paleta.douradoForte
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(const Offset(cx - 2.2, cy - 2.4), 1.2,
        Paint()..color = Paleta.branco.withValues(alpha: 0.85));

    // Cintilar.
    if (pose.joia > 0.01) {
      _brilho(canvas, Offset(cx + r * 1.05, cy - r * 1.05), 5.5 * pose.joia,
          Paleta.douradoForte.withValues(alpha: pose.joia));
      _brilho(canvas, Offset(cx - r * 1.2, cy + r * 0.2), 3.2 * pose.joia,
          Paleta.dourado.withValues(alpha: pose.joia));
    }
  }

  void _brilho(Canvas canvas, Offset c, double r, Color cor) {
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
    final a = Curves.easeInOut.transform(pose.abraca);
    for (final lado in [-1.0, 1.0]) {
      final x = lerpDouble(50 + lado * 19, 50 + lado * 8.5, a)!;
      final y = lerpDouble(79, 80.5, a)!;
      final r = Rect.fromCenter(center: Offset(x, y), width: 9, height: 10.5);
      _branco(canvas, r);
      canvas.drawCircle(Offset(x, y + 1.4), 1.5,
          Paint()..color = Paleta.rosa.withValues(alpha: 0.8));
    }
  }

  /// Coraçãozinho-lanterna sobre a cabeça (brilho dourado nas comemorações).
  void _coracaoDaCabeca(Canvas canvas) {
    const c = Offset(50, 27);
    if (pose.lanterna > 0.01) {
      canvas.drawCircle(
        c,
        7 + 5 * pose.lanterna,
        Paint()
          ..color = Paleta.dourado.withValues(alpha: 0.55 * pose.lanterna)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
    final coracao = _coracao(c, 4.6);
    canvas.drawPath(
      coracao,
      Paint()..color = Color.lerp(Paleta.rosa, Paleta.dourado, pose.lanterna)!,
    );
    canvas.drawPath(
      coracao,
      Paint()
        ..color =
            Color.lerp(Paleta.rosaForte, Paleta.douradoForte, pose.lanterna)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawCircle(Offset(c.dx - 1.7, c.dy - 1.5), 0.9,
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
    double orelhas = 0, orelhaD = 0;
    switch (estado) {
      case EstadoPepita.tranquila:
        break;
      case EstadoPepita.animada:
        lanterna = 0.55 + 0.35 * math.sin(_t * 2.6);
        orelhas = 0.25;
        inclina = 0.07 * math.sin(_t * 2 * math.pi / 2.4) * mov;
        break;
      case EstadoPepita.comemorando:
        pontos = 1;
        lanterna = 1;
        boca = 1;
        orelhas = 0.85 + 0.15 * math.sin(_t * 14) * mov;
        inclina = 0.05 * math.sin(_t * 9) * mov;
        break;
      case EstadoPepita.aconchegada:
        sono = 1;
        abraca = 1;
        zzz = 1;
        respPeriodo = 5;
        respAmp = 0.025;
        lanterna = 0.05;
        orelhas = -0.35;
        break;
      case EstadoPepita.curiosa:
        pontos = 1;
        duvida = 1;
        inclina = 0.2;
        lanterna = 0.3;
        orelhaD = 1;
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
    p.orelhas = _suave(p.orelhas, orelhas, dt, 7);
    p.orelhaD = _suave(p.orelhaD, orelhaD, dt, 7);
    p.balancoOrelhas = mov;
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
      label: 'Chocolatinho, o coelhinho do app',
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
