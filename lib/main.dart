import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'notifications.dart';
import 'screens/hoje.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final store = Store();
  await store.carregar();
  await Notificacoes.iniciar();
  store.aoMudarAjustes =
      () => Notificacoes.reagendar(store.momentos, store.nome);
  // Reagenda a cada abertura: sorteia frases novas para os próximos dias.
  await Notificacoes.reagendar(store.momentos, store.nome);

  runApp(PepitaApp(store: store));
}

class PepitaApp extends StatelessWidget {
  const PepitaApp({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pepita',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      home: Scaffold(body: TelaHoje(store: store)),
    );
  }
}
