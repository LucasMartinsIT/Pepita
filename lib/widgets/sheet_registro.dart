import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../models.dart';
import '../theme.dart';
import 'botao_fofo.dart';
import 'particulas.dart';
import 'pepita.dart';

enum AcaoRegistro { postei, descanso, apagar }

class ResultadoRegistro {
  const ResultadoRegistro(this.acao, [this.qtd]);
  final AcaoRegistro acao;
  final int? qtd;
}

/// Abre a sheet de registro com animação de mola, de baixo para cima.
Future<ResultadoRegistro?> mostrarSheetRegistro(
  BuildContext context, {
  required Momento momento,
  Registro? atual,
}) {
  return showModalBottomSheet<ResultadoRegistro>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Paleta.cacau.withValues(alpha: 0.25),
    sheetAnimationStyle: AnimationStyle(
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 520),
      reverseCurve: Curves.easeIn,
      reverseDuration: const Duration(milliseconds: 220),
    ),
    builder: (_) => _SheetRegistro(momento: momento, atual: atual),
  );
}

class _SheetRegistro extends StatefulWidget {
  const _SheetRegistro({required this.momento, this.atual});

  final Momento momento;
  final Registro? atual;

  @override
  State<_SheetRegistro> createState() => _SheetRegistroState();
}

class _SheetRegistroState extends State<_SheetRegistro> {
  int? _qtd;
  bool _subiu = true;
  final _brilhos = GlobalKey<ExplosaoDeParticulasState>();

  @override
  void initState() {
    super.initState();
    if (widget.atual?.tipo == TipoRegistro.postei) _qtd = widget.atual?.qtd;
  }

  void _mudar(int? novo, {bool brilhar = true}) {
    if (novo != null) novo = novo.clamp(1, 999);
    if (novo == _qtd) return;
    final antes = _qtd ?? 0;
    setState(() {
      _subiu = (novo ?? 0) >= antes;
      _qtd = novo;
    });
    HapticFeedback.lightImpact();
    // brilhinhos extras ao passar de 10, 20, 30…
    if (brilhar && novo != null && novo > antes && novo % 10 == 0) {
      _brilhos.currentState?.disparar();
    }
  }

  void _mais() => _mudar((_qtd ?? 0) + 1);
  void _menos() {
    if (_qtd == null) return;
    _mudar(_qtd! <= 1 ? null : _qtd! - 1);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.momento;
    final teclado = MediaQuery.viewInsetsOf(context).bottom;
    final existe = widget.atual != null;

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 42),
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 28),
            decoration: BoxDecoration(
              color: Paleta.creme,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Raios.sheet)),
              boxShadow: Sombras.suave,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${m.emoji} ${m.nome}',
                      textAlign: TextAlign.center,
                      style: Textos.titulo(tamanho: 24)),
                  const SizedBox(height: 4),
                  Text('Como foi esse garimpo?',
                      style: Textos.corpo(cor: Paleta.cacauClaro)),
                  const SizedBox(height: 20),
                  _contador(),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final n in const [1, 3, 5, 10])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: _Chip(
                            texto: '$n',
                            marcado: _qtd == n,
                            aoTocar: () => _mudar(n),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  BotaoPilula(
                    texto: 'Postei! ✨',
                    largura: double.infinity,
                    aoTocar: () => Navigator.pop(
                        context, ResultadoRegistro(AcaoRegistro.postei, _qtd)),
                  ),
                  const SizedBox(height: 12),
                  BotaoPilula(
                    texto: 'Hoje não, e tá tudo bem ☁️',
                    largura: double.infinity,
                    cor: Paleta.lavanda,
                    corTexto: Paleta.cacau,
                    sombra: false,
                    aoTocar: () => Navigator.pop(
                        context, const ResultadoRegistro(AcaoRegistro.descanso)),
                  ),
                  if (existe) ...[
                    const SizedBox(height: 8),
                    Toque(
                      aoTocar: () => Navigator.pop(
                          context, const ResultadoRegistro(AcaoRegistro.apagar)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'apagar anotação',
                          style: Textos.corpo(
                                  tamanho: 14, cor: Paleta.cacauClaro)
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // A Pepita espia na borda superior da sheet.
          const Positioned(
            top: 0,
            child: IgnorePointer(child: Pepita(tamanho: 92)),
          ),
        ],
      ),
    );
  }

  Widget _contador() {
    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 96,
            child: ExplosaoDeParticulas(key: _brilhos, quantidade: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BotaoRedondo(
                simbolo: '−',
                cor: Paleta.rosa,
                aoPressionar: _menos,
                semantica: 'Menos um achado',
              ),
              SizedBox(
                width: 120,
                child: ClipRect(
                  child: AnimatedSwitcher(
                    duration: Duration(
                        milliseconds:
                            (MediaQuery.maybeDisableAnimationsOf(context) ??
                                    false)
                                ? 0
                                : 220),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (filho, anim) {
                      final entrando = filho.key == ValueKey<int?>(_qtd);
                      final dir = _subiu ? 1.0 : -1.0;
                      final offset = Tween<Offset>(
                        begin: Offset(0, entrando ? dir * 0.8 : -dir * 0.8),
                        end: Offset.zero,
                      ).animate(anim);
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(position: offset, child: filho),
                      );
                    },
                    child: Text(
                      _qtd?.toString() ?? '—',
                      key: ValueKey<int?>(_qtd),
                      textAlign: TextAlign.center,
                      style: Textos.titulo(
                        tamanho: 56,
                        cor: _qtd == null ? Paleta.cacauClaro : Paleta.cacau,
                      ),
                    ),
                  ),
                ),
              ),
              _BotaoRedondo(
                simbolo: '+',
                cor: Paleta.azulBebe,
                aoPressionar: _mais,
                semantica: 'Mais um achado',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botão redondo grande. Segurar acelera a contagem.
class _BotaoRedondo extends StatefulWidget {
  const _BotaoRedondo({
    required this.simbolo,
    required this.cor,
    required this.aoPressionar,
    required this.semantica,
  });

  final String simbolo;
  final Color cor;
  final VoidCallback aoPressionar;
  final String semantica;

  @override
  State<_BotaoRedondo> createState() => _BotaoRedondoState();
}

class _BotaoRedondoState extends State<_BotaoRedondo> {
  Timer? _timer;
  bool _apertado = false;
  int _repeticoes = 0;

  void _comecar() {
    setState(() => _apertado = true);
    widget.aoPressionar();
    _repeticoes = 0;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 420), _repetir);
  }

  void _repetir() {
    widget.aoPressionar();
    _repeticoes++;
    // acelera aos poucos
    final ms = _repeticoes < 6 ? 150 : (_repeticoes < 16 ? 90 : 45);
    _timer = Timer(Duration(milliseconds: ms), _repetir);
  }

  void _parar() {
    _timer?.cancel();
    if (_apertado && mounted) setState(() => _apertado = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semantica,
      button: true,
      child: Listener(
        onPointerDown: (_) => _comecar(),
        onPointerUp: (_) => _parar(),
        onPointerCancel: (_) => _parar(),
        child: AnimatedScale(
          scale: _apertado ? 0.92 : 1,
          duration: Duration(milliseconds: _apertado ? 80 : 300),
          curve: _apertado ? Curves.easeOut : Curves.elasticOut,
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.cor,
              shape: BoxShape.circle,
              boxShadow: Sombras.leve,
            ),
            child: Text(widget.simbolo,
                style: Textos.titulo(tamanho: 34, peso: 500)),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.texto,
    required this.marcado,
    required this.aoTocar,
  });

  final String texto;
  final bool marcado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Toque(
      aoTocar: aoTocar,
      semantica: 'Atalho $texto',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: marcado ? Paleta.rosaBebe : Paleta.cremeEscuro,
          borderRadius: BorderRadius.circular(Raios.pilula),
          border: Border.all(
              color: marcado ? Paleta.rosaForte : Colors.transparent, width: 1.5),
        ),
        child: Text(texto, style: Textos.titulo(tamanho: 16, peso: 500)),
      ),
    );
  }
}
