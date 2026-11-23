import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Switch customizado: a bolinha é um coração que desliza (e quica) no trilho.
class SwitchCoracao extends StatelessWidget {
  const SwitchCoracao({
    super.key,
    required this.valor,
    required this.aoMudar,
    this.semantica,
  });

  final bool valor;
  final ValueChanged<bool> aoMudar;
  final String? semantica;

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dur = Duration(milliseconds: reduzir ? 0 : 380);
    return Semantics(
      label: semantica,
      toggled: valor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          aoMudar(!valor);
        },
        child: AnimatedContainer(
          duration: dur,
          curve: Curves.easeOut,
          width: 62,
          height: 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: valor ? Paleta.rosa : Paleta.cremeEscuro,
            borderRadius: BorderRadius.circular(Raios.pilula),
          ),
          child: AnimatedAlign(
            duration: dur,
            curve: Curves.elasticOut,
            alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Paleta.creme,
                shape: BoxShape.circle,
                boxShadow: Sombras.leve,
              ),
              child: AnimatedSwitcher(
                duration: dur,
                child: Icon(
                  valor ? Icons.favorite_rounded : Icons.cloud_rounded,
                  key: ValueKey(valor),
                  size: 18,
                  color: valor ? Paleta.rosaForte : Paleta.cacauClaro,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
