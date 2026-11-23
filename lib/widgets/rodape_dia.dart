import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../frases.dart';
import '../theme.dart';

/// Rodapé do dia: "Hoje você garimpou **12** achados 💗" com joias animadas.
/// Sem nenhum "postei com quantidade" mostra uma frase do banco `semPressao`
/// — nunca mostra "0".
class RodapeDia extends StatefulWidget {
  const RodapeDia({super.key, required this.achados});

  final int achados;

  @override
  State<RodapeDia> createState() => _RodapeDiaState();
}

class _RodapeDiaState extends State<RodapeDia> {
  late final String _semPressao;

  @override
  void initState() {
    super.initState();
    _semPressao = Frases.sortear(Frases.semPressao);
  }

  @override
  Widget build(BuildContext context) {
    final tem = widget.achados > 0;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: tem
          ? _ComAchados(key: const ValueKey('tem'), achados: widget.achados)
          : Padding(
              key: const ValueKey('nao'),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Text(
                _semPressao,
                textAlign: TextAlign.center,
                style: Textos.corpo(cor: Paleta.cacauClaro),
              ),
            ),
    );
  }
}

class _ComAchados extends StatefulWidget {
  const _ComAchados({super.key, required this.achados});

  final int achados;

  @override
  State<_ComAchados> createState() => _ComAchadosState();
}

class _ComAchadosState extends State<_ComAchados>
    with SingleTickerProviderStateMixin {
  late final AnimationController _joias;

  @override
  void initState() {
    super.initState();
    _joias = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
  }

  @override
  void dispose() {
    _joias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Paleta.creme,
        borderRadius: BorderRadius.circular(Raios.card),
        boxShadow: Sombras.leve,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 22,
            child: AnimatedBuilder(
              animation: _joias,
              builder: (_, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 5; i++)
                    Transform.translate(
                      offset: Offset(
                          0,
                          reduzir
                              ? 0
                              : math.sin((_joias.value + i / 5) * 2 * math.pi) *
                                  3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(i.isEven ? '💎' : '✨',
                            style: const TextStyle(fontSize: 15)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // O total "sobe contando" quando muda.
          TweenAnimationBuilder<double>(
            tween: Tween(end: widget.achados.toDouble()),
            duration: Duration(milliseconds: reduzir ? 0 : 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => Text.rich(
              TextSpan(
                style: Textos.corpo(tamanho: 16),
                children: [
                  const TextSpan(text: 'Hoje você garimpou '),
                  TextSpan(
                    text: '${v.round()}',
                    style: Textos.titulo(
                        tamanho: 24, cor: Paleta.rosaForte, peso: 600),
                  ),
                  TextSpan(
                      text: widget.achados == 1 ? ' achado 💗' : ' achados 💗'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
