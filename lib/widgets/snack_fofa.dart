import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'botao_fofo.dart';
import 'pepita.dart';

/// Snackbar customizada: pílula creme com a Pepita mini à esquerda.
void mostrarSnackFofa(
  BuildContext context,
  String texto, {
  String? rotuloAcao,
  VoidCallback? aoAcao,
  Duration duracao = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: duracao,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 104),
      padding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
        decoration: BoxDecoration(
          color: Paleta.creme,
          borderRadius: BorderRadius.circular(Raios.pilula),
          border: Border.all(color: Paleta.rosa, width: 1.5),
          boxShadow: Sombras.suave,
        ),
        child: Row(
          children: [
            const Pepita(tamanho: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Text(texto, style: Textos.corpo(tamanho: 14)),
            ),
            if (rotuloAcao != null)
              Toque(
                aoTocar: () {
                  messenger.hideCurrentSnackBar();
                  aoAcao?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    rotuloAcao,
                    style: Textos.titulo(
                        tamanho: 14, cor: Paleta.rosaForte, peso: 600),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
