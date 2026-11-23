import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Fundo de folha de caderno fofinha: linhas azul-bebê, margem rosa e
/// furinhos de fichário na lateral.
class FolhaDeCaderno extends StatelessWidget {
  const FolhaDeCaderno({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFFFFCF6)),
      child: CustomPaint(
        painter: _PintorFolha(),
        child: child,
      ),
    );
  }
}

class _PintorFolha extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linha = Paint()
      ..color = Paleta.papelLinha
      ..strokeWidth = 1.4;
    const passo = 34.0;
    for (var y = 112.0; y < size.height; y += passo) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linha);
    }

    // Margem rosa (linha dupla fininha).
    final margem = Paint()
      ..color = Paleta.papelMargem
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(54, 0), Offset(54, size.height), margem);
    canvas.drawLine(Offset(58, 0), Offset(58, size.height),
        margem..color = Paleta.papelMargem.withValues(alpha: 0.5));

    // Furinhos de fichário com um brilhinho.
    for (var y = 70.0; y < size.height; y += 150) {
      final c = Offset(20, y);
      canvas.drawCircle(c, 9, Paint()..color = Paleta.rosaBebe);
      canvas.drawCircle(
        c,
        9,
        Paint()
          ..color = Paleta.rosa
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(c + const Offset(-2.5, -2.5), 2,
          Paint()..color = Paleta.branco.withValues(alpha: 0.8));
    }
  }

  @override
  bool shouldRepaint(_PintorFolha old) => false;
}
