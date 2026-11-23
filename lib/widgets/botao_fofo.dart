import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Envolve qualquer widget com a microinteração padrão do app:
/// escala 0.95 ao pressionar, volta com mola e dá um haptic leve.
class Toque extends StatefulWidget {
  const Toque({
    super.key,
    required this.child,
    this.aoTocar,
    this.aoSegurar,
    this.haptic = true,
    this.semantica,
  });

  final Widget child;
  final VoidCallback? aoTocar;
  final VoidCallback? aoSegurar;
  final bool haptic;
  final String? semantica;

  @override
  State<Toque> createState() => _ToqueState();
}

class _ToqueState extends State<Toque> {
  bool _apertado = false;

  void _mudar(bool v) {
    if (_apertado != v && mounted) setState(() => _apertado = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    Widget filho = AnimatedScale(
      scale: _apertado && !reduzir ? 0.95 : 1,
      duration: Duration(milliseconds: reduzir ? 0 : (_apertado ? 90 : 320)),
      curve: _apertado ? Curves.easeOut : Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: _apertado && reduzir ? 0.8 : 1,
        duration: const Duration(milliseconds: 90),
        child: widget.child,
      ),
    );
    if (widget.semantica != null) {
      filho = Semantics(label: widget.semantica, button: true, child: filho);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _mudar(true),
      onTapUp: (_) => _mudar(false),
      onTapCancel: () => _mudar(false),
      onTap: widget.aoTocar == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.aoTocar!();
            },
      onLongPress: widget.aoSegurar,
      child: filho,
    );
  }
}

/// Botão em forma de pílula, com sombra rosada.
class BotaoPilula extends StatelessWidget {
  const BotaoPilula({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.cor = Paleta.rosaForte,
    this.corTexto = Paleta.branco,
    this.largura,
    this.compacto = false,
    this.sombra = true,
  });

  final String texto;
  final VoidCallback? aoTocar;
  final Color cor;
  final Color corTexto;
  final double? largura;
  final bool compacto;
  final bool sombra;

  @override
  Widget build(BuildContext context) {
    return Toque(
      aoTocar: aoTocar,
      semantica: texto,
      child: Container(
        width: largura,
        padding: EdgeInsets.symmetric(
          horizontal: compacto ? 16 : 24,
          vertical: compacto ? 9 : 15,
        ),
        alignment: largura != null ? Alignment.center : null,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(Raios.pilula),
          boxShadow: sombra ? Sombras.leve : null,
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: Textos.titulo(
              tamanho: compacto ? 14 : 17, cor: corTexto, peso: 500),
        ),
      ),
    );
  }
}
