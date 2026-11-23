import 'package:material_ui/material_ui.dart';

import 'theme.dart';
import 'widgets/pepita.dart';

void main() {
  runApp(const PepitaApp());
}

class PepitaApp extends StatelessWidget {
  const PepitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pepita',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      home: const _Vitrine(),
    );
  }
}

/// Tela provisória só para ver a Pepita (será substituída pela tela Hoje).
class _Vitrine extends StatefulWidget {
  const _Vitrine();

  @override
  State<_Vitrine> createState() => _VitrineState();
}

class _VitrineState extends State<_Vitrine> {
  EstadoPepita _estado = EstadoPepita.tranquila;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pepita(estado: _estado, tamanho: 240),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                for (final e in EstadoPepita.values)
                  ChoiceChip(
                    label: Text(e.name),
                    selected: e == _estado,
                    onSelected: (_) => setState(() => _estado = e),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
