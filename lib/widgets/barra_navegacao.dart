import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'botao_fofo.dart';

class _Item {
  const _Item(this.icone, this.rotulo);
  final IconData icone;
  final String rotulo;
}

/// Barra inferior flutuante e arredondada: pílula creme com sombra rosa.
/// O ícone ativo dá um "pulinho".
class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({
    super.key,
    required this.indice,
    required this.aoMudar,
  });

  final int indice;
  final ValueChanged<int> aoMudar;

  static const _itens = [
    _Item(Icons.favorite_rounded, 'Hoje'),
    _Item(Icons.local_florist_rounded, 'Cantinho'),
    _Item(Icons.edit_note_rounded, 'Caderninho'),
    _Item(Icons.tune_rounded, 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Paleta.creme,
            borderRadius: BorderRadius.circular(Raios.pilula),
            border: Border.all(color: Paleta.rosaBebe, width: 1.5),
            boxShadow: Sombras.suave,
          ),
          child: Row(
            children: [
              for (var i = 0; i < _itens.length; i++)
                Expanded(
                  flex: i == indice ? 5 : 3,
                  child: _Aba(
                    item: _itens[i],
                    ativa: i == indice,
                    aoTocar: () {
                      if (i != indice) {
                        HapticFeedback.selectionClick();
                        aoMudar(i);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  const _Aba({required this.item, required this.ativa, required this.aoTocar});

  final _Item item;
  final bool ativa;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Toque(
      haptic: false,
      aoTocar: aoTocar,
      semantica: item.rotulo,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        decoration: BoxDecoration(
          color: ativa ? Paleta.rosaBebe : Colors.transparent,
          borderRadius: BorderRadius.circular(Raios.pilula),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulinho do ícone ao ficar ativo.
              TweenAnimationBuilder<double>(
                key: ValueKey(ativa),
                tween: Tween(begin: ativa && !reduzir ? 1.0 : 0.0, end: 0.0),
                duration: const Duration(milliseconds: 550),
                curve: Curves.elasticOut,
                builder: (context, v, filho) => Transform.translate(
                  offset: Offset(0, -10 * v),
                  child: filho,
                ),
                child: Icon(
                  item.icone,
                  size: 23,
                  color: ativa ? Paleta.rosaForte : Paleta.cacauClaro,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: ativa
                    ? Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          item.rotulo,
                          style: Textos.titulo(tamanho: 12.5, peso: 500),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
