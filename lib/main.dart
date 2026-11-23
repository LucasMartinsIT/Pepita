import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'notifications.dart';
import 'screens/ajustes.dart';
import 'screens/cantinho.dart';
import 'screens/hoje.dart';
import 'screens/onboarding.dart';
import 'store.dart';
import 'theme.dart';
import 'widgets/barra_navegacao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final store = Store();
  await store.carregar();
  store.aoMudarAjustes =
      () => Notificacoes.reagendar(store.momentos, store.nome);

  // O app abre primeiro; as notificações iniciam depois e, se algo falhar
  // nelas, a tela continua funcionando normalmente.
  runApp(PepitaApp(store: store));
  _iniciarNotificacoes(store);
}

Future<void> _iniciarNotificacoes(Store store) async {
  try {
    await Notificacoes.iniciar();
    // Reagenda a cada abertura: sorteia frases novas para os próximos dias.
    if (store.onboardingFeito) {
      await Notificacoes.reagendar(store.momentos, store.nome);
    }
  } catch (e) {
    debugPrint('Notificações indisponíveis: $e');
  }
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
      home: ListenableBuilder(
        listenable: store,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: store.onboardingFeito
              ? Principal(key: const ValueKey('principal'), store: store)
              : TelaOnboarding(key: const ValueKey('onboarding'), store: store),
        ),
      ),
    );
  }
}

/// As 3 abas (Hoje · Cantinho · Ajustes) com a barra flutuante.
class Principal extends StatefulWidget {
  const Principal({super.key, required this.store});

  final Store store;

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    Notificacoes.pedidoAbrirMomento.addListener(_aoTocarNotificacao);
  }

  @override
  void dispose() {
    Notificacoes.pedidoAbrirMomento.removeListener(_aoTocarNotificacao);
    super.dispose();
  }

  /// Tocar numa notificação leva para a aba Hoje (que abre a sheet).
  void _aoTocarNotificacao() {
    if (Notificacoes.pedidoAbrirMomento.value != null && _aba != 0) {
      setState(() => _aba = 0);
    }
  }

  Widget _tela() => switch (_aba) {
        0 => TelaHoje(key: const ValueKey(0), store: widget.store),
        1 => TelaCantinho(key: const ValueKey(1), store: widget.store),
        _ => TelaAjustes(key: const ValueKey(2), store: widget.store),
      };

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            // Troca de aba: fade + leve slide.
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: reduzir ? 150 : 350),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (filho, anim) => FadeTransition(
                opacity: anim,
                child: reduzir
                    ? filho
                    : SlideTransition(
                        position: Tween(
                                begin: const Offset(0.04, 0), end: Offset.zero)
                            .animate(anim),
                        child: filho,
                      ),
              ),
              child: _tela(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BarraNavegacao(
              indice: _aba,
              aoMudar: (i) => setState(() => _aba = i),
            ),
          ),
        ],
      ),
    );
  }
}
