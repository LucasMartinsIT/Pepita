import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models.dart';
import '../theme.dart';
import 'botao_fofo.dart';

/// Card de um dos 3 momentos do dia.
class CardMomento extends StatefulWidget {
  const CardMomento({
    super.key,
    required this.momento,
    required this.estado,
    required this.registro,
    required this.aoTocar,
  });

  final Momento momento;
  final EstadoMomento estado;
  final Registro? registro;
  final VoidCallback aoTocar;

  @override
  State<CardMomento> createState() => _CardMomentoState();
}

class _CardMomentoState extends State<CardMomento>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso;

  bool get _agora =>
      widget.estado == EstadoMomento.agora && widget.registro == null;

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    if (_agora) _pulso.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CardMomento antigo) {
    super.didUpdateWidget(antigo);
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_agora && !reduzir) {
      if (!_pulso.isAnimating) _pulso.repeat(reverse: true);
    } else {
      _pulso.stop();
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final m = widget.momento;
    final agora = _agora;
    final passou =
        widget.estado == EstadoMomento.depois && widget.registro == null;

    return Toque(
      aoTocar: widget.aoTocar,
      semantica: '${m.nome}, ${m.faixa}',
      child: AnimatedBuilder(
        animation: _pulso,
        builder: (context, filho) {
          final glow = agora ? (reduzir ? 0.5 : Curves.easeInOut.transform(_pulso.value)) : 0.0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            decoration: BoxDecoration(
              color: agora ? Paleta.rosaBebe : Paleta.creme,
              borderRadius: BorderRadius.circular(Raios.card),
              border: Border.all(
                color: agora
                    ? Color.lerp(Paleta.rosa, Paleta.rosaForte, glow)!
                    : Paleta.cremeEscuro,
                width: agora ? 2 : 1.5,
              ),
              boxShadow: agora
                  ? Sombras.brilho(Paleta.rosaForte, glow)
                  : Sombras.leve,
            ),
            child: Opacity(opacity: passou ? 0.78 : 1, child: filho),
          );
        },
        child: Row(
          children: [
            _Emoji(emoji: m.emoji, balancar: agora && !reduzir, pulso: _pulso),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.nome, style: Textos.titulo(tamanho: 18, peso: 500)),
                  const SizedBox(height: 3),
                  Text(m.faixa,
                      style: Textos.corpo(tamanho: 13, cor: Paleta.cacauClaro)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Estado(
              estado: widget.estado,
              registro: widget.registro,
              aoTocar: widget.aoTocar,
            ),
          ],
        ),
      ),
    );
  }
}

class _Emoji extends StatelessWidget {
  const _Emoji({required this.emoji, required this.balancar, required this.pulso});

  final String emoji;
  final bool balancar;
  final Animation<double> pulso;

  @override
  Widget build(BuildContext context) {
    final texto = Text(emoji, style: const TextStyle(fontSize: 36));
    if (!balancar) return texto;
    return AnimatedBuilder(
      animation: pulso,
      builder: (_, filho) => Transform.rotate(
        angle: math.sin(pulso.value * math.pi) * 0.14 - 0.07,
        child: filho,
      ),
      child: texto,
    );
  }
}

/// Lado direito do card: botão, texto suave ou selinho.
class _Estado extends StatelessWidget {
  const _Estado({
    required this.estado,
    required this.registro,
    required this.aoTocar,
  });

  final EstadoMomento estado;
  final Registro? registro;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final Widget filho;
    final r = registro;
    if (r != null) {
      filho = r.tipo == TipoRegistro.postei
          ? _Selo(
              key: ValueKey('postei-${r.qtd}'),
              texto: r.qtd != null
                  ? '✨ ${r.qtd} ${r.qtd == 1 ? 'achado' : 'achados'}'
                  : '✨ passei por aqui',
              cor: Paleta.menta,
            )
          : const _Selo(
              key: ValueKey('descanso'),
              texto: '☁️ descansei',
              cor: Paleta.lavanda,
            );
    } else {
      switch (estado) {
        case EstadoMomento.agora:
          filho = Container(
            key: const ValueKey('agora'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Paleta.rosaForte,
              borderRadius: BorderRadius.circular(Raios.pilula),
              boxShadow: Sombras.leve,
            ),
            child: Text('Bora garimpar 💎',
                style: Textos.titulo(
                    tamanho: 13, cor: Paleta.branco, peso: 500)),
          );
        case EstadoMomento.antes:
          filho = Row(
            key: const ValueKey('antes'),
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 16, color: Paleta.cacauClaro),
              const SizedBox(width: 4),
              Text('mais tarde',
                  style: Textos.corpo(tamanho: 13, cor: Paleta.cacauClaro)),
            ],
          );
        case EstadoMomento.depois:
          filho = Container(
            key: const ValueKey('depois'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Paleta.cremeEscuro,
              borderRadius: BorderRadius.circular(Raios.pilula),
            ),
            child: Text('anotar',
                style: Textos.corpo(tamanho: 13, cor: Paleta.cacauClaro)),
          );
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim.drive(CurveTween(curve: const Interval(0, 0.5))), child: child),
      ),
      child: filho,
    );
  }
}

class _Selo extends StatelessWidget {
  const _Selo({super.key, required this.texto, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(Raios.pilula),
      ),
      child: Text(texto, style: Textos.titulo(tamanho: 13, peso: 500)),
    );
  }
}
