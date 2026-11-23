import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/botao_fofo.dart';
import '../widgets/folha_caderno.dart';
import '../widgets/pepita.dart';
import '../widgets/sheet_nota.dart';
import '../widgets/snack_fofa.dart';

/// Caderninho: um cantinho livre para anotar coisinhas, numa folha de caderno.
/// Sem prazo, sem contagem e sem "pendências": a bolinha de feitinho é só um carinho.
class TelaCaderninho extends StatelessWidget {
  const TelaCaderninho({super.key, required this.store});

  final Store store;

  Future<void> _editar(BuildContext context, [Nota? nota]) async {
    final r = await mostrarSheetNota(context, atual: nota);
    if (r == null || !context.mounted) return;
    if (r.apagar && nota != null) {
      final posicao = store.notas.indexWhere((n) => n.id == nota.id);
      await store.apagarNota(nota.id);
      if (!context.mounted) return;
      mostrarSnackFofa(
        context,
        'Notinha apagada',
        rotuloAcao: 'desfazer',
        aoAcao: () => store.restaurarNota(nota, posicao),
      );
    } else if (r.nota != null) {
      await store.salvarNota(r.nota!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FolhaDeCaderno(
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final notas = store.notas;
            return ListView(
              padding: const EdgeInsets.fromLTRB(70, 18, 20, 130),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Caderninho ✏️',
                          style: const FonteNota('Chique', 'Pacifico', 27).estilo()),
                    ),
                    const Pepita(tamanho: 76),
                  ],
                ),
                const SizedBox(height: 6),
                BotaoPilula(
                  texto: '+ nova notinha',
                  compacto: true,
                  aoTocar: () => _editar(context),
                ),
                const SizedBox(height: 18),
                if (notas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      'Aqui cabe qualquer ideia, lembrete ou rabisco fofo 🌷',
                      textAlign: TextAlign.center,
                      style: const FonteNota('Letrinha', 'PatrickHand', 22)
                          .estilo(cor: Paleta.cacauClaro),
                    ),
                  ),
                for (final n in notas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _Notinha(
                      key: ValueKey(n.id),
                      nota: n,
                      aoTocar: () => _editar(context, n),
                      aoMarcar: () {
                        HapticFeedback.lightImpact();
                        store.salvarNota(n.copiar(feita: !n.feita));
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Um papelzinho colado na folha, com fitinha e uma inclinação levinha.
class _Notinha extends StatelessWidget {
  const _Notinha({
    super.key,
    required this.nota,
    required this.aoTocar,
    required this.aoMarcar,
  });

  final Nota nota;
  final VoidCallback aoTocar;
  final VoidCallback aoMarcar;

  @override
  Widget build(BuildContext context) {
    final fonte = FonteNota.todas[nota.fonte.clamp(0, FonteNota.todas.length - 1)];
    final papel = papeisDoCaderno[nota.papel.clamp(0, papeisDoCaderno.length - 1)];
    final inclinacao = ((nota.id % 5) - 2) * 0.008;

    return Transform.rotate(
      angle: inclinacao,
      child: Toque(
        aoTocar: aoTocar,
        semantica: 'Notinha: ${nota.texto}',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              decoration: BoxDecoration(
                color: papel,
                borderRadius: BorderRadius.circular(20),
                boxShadow: Sombras.leve,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nota.tarefinha) ...[
                    Toque(
                      aoTocar: aoMarcar,
                      semantica: nota.feita ? 'Desmarcar feitinho' : 'Marcar feitinho',
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12, top: 2),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.elasticOut,
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: Icon(
                            nota.feita
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(nota.feita),
                            size: 28,
                            color: Paleta.rosaForte,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: nota.feita ? 0.6 : 1,
                      child: Text(nota.texto, style: fonte.estilo()),
                    ),
                  ),
                ],
              ),
            ),
            // Fitinha (washi tape) colando o papel.
            Positioned(
              top: -9,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    width: 64,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Paleta.rosa.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
