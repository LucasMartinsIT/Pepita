import 'package:material_ui/material_ui.dart';

import '../models.dart';
import '../notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/botao_fofo.dart';
import '../widgets/fundo.dart';
import '../widgets/pepita.dart';

/// Primeira abertura: 3 telinhas, com a Pepita em parallax leve.
class TelaOnboarding extends StatefulWidget {
  const TelaOnboarding({super.key, required this.store});

  final Store store;

  @override
  State<TelaOnboarding> createState() => _TelaOnboardingState();
}

class _TelaOnboardingState extends State<TelaOnboarding> {
  final _ctl = PageController();
  double _pagina = 0;
  String? _recado;
  bool _terminando = false;

  @override
  void initState() {
    super.initState();
    _ctl.addListener(() {
      if (_ctl.hasClients) setState(() => _pagina = _ctl.page ?? 0);
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _proxima() {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _ctl.nextPage(
      duration: Duration(milliseconds: reduzir ? 1 : 450),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _pedirNotificacao() async {
    if (_terminando) return;
    setState(() => _terminando = true);
    final ok = await Notificacoes.pedirPermissao();
    if (!ok) {
      if (!mounted) return;
      setState(() => _recado = 'Tudo bem! Você pode ligar depois nos ajustes 💗');
      await Future<void>.delayed(const Duration(milliseconds: 1800));
    }
    await _concluir();
  }

  Future<void> _concluir() async {
    await widget.store.concluirOnboarding();
    await Notificacoes.reagendar(widget.store.momentos, widget.store.nome);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final paginaAtual = _pagina.round();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: FundoFlutuante(hora: DateTime.now().hour)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // A Pepita desliza devagar, mais que o texto (parallax).
                SizedBox(
                  height: 250,
                  child: Transform.translate(
                    offset: Offset(-(_pagina - paginaAtual) * 90, 0),
                    child: Center(
                      child: Pepita(
                        tamanho: 230,
                        estado: paginaAtual == 1
                            ? EstadoPepita.tranquila
                            : EstadoPepita.animada,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _ctl,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _Pagina(
                        titulo: 'Oi, ${store.nome}!',
                        texto:
                            'Eu sou o Chocolatinho 💎\nVou te lembrar dos seus momentos de garimpo, sem pressão nenhuma.',
                        botao: 'Oi, Chocolatinho!',
                        aoTocar: _proxima,
                      ),
                      _Pagina(
                        titulo: 'Esses horários funcionam?',
                        texto: 'Você pode mudar quando quiser.',
                        botao: 'Funcionam sim',
                        aoTocar: _proxima,
                        extra: Column(
                          children: [
                            for (final m in store.momentos)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _MiniMomento(m),
                              ),
                          ],
                        ),
                      ),
                      _Pagina(
                        titulo: 'Posso te mandar um recadinho?',
                        texto: _recado ?? 'Na hora do garimpo, só um aviso carinhoso. Nada de cobrança.',
                        botao: _terminando ? 'Um instante…' : 'Pode sim 💗',
                        aoTocar: _terminando ? null : _pedirNotificacao,
                        secundario: _terminando ? null : 'Agora não',
                        aoSecundario: _concluir,
                      ),
                    ],
                  ),
                ),
                _Bolinhas(pagina: paginaAtual, total: 3),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pagina extends StatelessWidget {
  const _Pagina({
    required this.titulo,
    required this.texto,
    required this.botao,
    required this.aoTocar,
    this.extra,
    this.secundario,
    this.aoSecundario,
  });

  final String titulo;
  final String texto;
  final String botao;
  final VoidCallback? aoTocar;
  final Widget? extra;
  final String? secundario;
  final VoidCallback? aoSecundario;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Text(titulo,
              textAlign: TextAlign.center, style: Textos.titulo(tamanho: 28)),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(texto,
                key: ValueKey(texto),
                textAlign: TextAlign.center,
                style: Textos.corpo(tamanho: 16, cor: Paleta.cacauClaro)),
          ),
          if (extra != null) ...[const SizedBox(height: 16), extra!],
          const SizedBox(height: 22),
          BotaoPilula(texto: botao, aoTocar: aoTocar, largura: double.infinity),
          if (secundario != null) ...[
            const SizedBox(height: 8),
            Toque(
              aoTocar: aoSecundario,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(secundario!,
                    style: Textos.corpo(cor: Paleta.cacauClaro)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniMomento extends StatelessWidget {
  const _MiniMomento(this.m);

  final Momento m;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Paleta.creme,
        borderRadius: BorderRadius.circular(Raios.card),
        boxShadow: Sombras.leve,
      ),
      child: Row(
        children: [
          Text(m.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(child: Text(m.nome, style: Textos.titulo(tamanho: 16, peso: 500))),
          Text(m.faixa, style: Textos.corpo(tamanho: 13, cor: Paleta.cacauClaro)),
        ],
      ),
    );
  }
}

/// Bolinhas que viram coraçõezinhos.
class _Bolinhas extends StatelessWidget {
  const _Bolinhas({required this.pagina, required this.total});

  final int pagina;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: i == pagina
                  ? const Icon(Icons.favorite_rounded,
                      key: ValueKey('coracao'), size: 20, color: Paleta.rosaForte)
                  : Container(
                      key: ValueKey('bolinha$i'),
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                          color: Paleta.rosa, shape: BoxShape.circle),
                    ),
            ),
          ),
      ],
    );
  }
}
