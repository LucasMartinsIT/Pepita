import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../frases.dart';
import '../models.dart';
import '../notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/card_momento.dart';
import '../widgets/fundo.dart';
import '../widgets/particulas.dart';
import '../widgets/pepita.dart';
import '../widgets/rodape_dia.dart';
import '../widgets/sheet_registro.dart';
import '../widgets/snack_fofa.dart';

/// Tela principal: saudação, Pepita, os 3 momentos e o rodapé do dia.
class TelaHoje extends StatefulWidget {
  const TelaHoje({super.key, required this.store});

  final Store store;

  @override
  State<TelaHoje> createState() => _TelaHojeState();
}

class _TelaHojeState extends State<TelaHoje> with TickerProviderStateMixin {
  late final AnimationController _entrada;
  Timer? _relogio;
  Timer? _timerBalao;
  Timer? _timerEstado;

  DateTime _agora = DateTime.now();
  late final String _fraseSaudacao;

  // Estados temporários da Pepita.
  bool _comemorando = false;
  bool _aconchegada = false;
  bool _curiosa = false;
  bool _cavando = false;
  String? _balao;

  // Número que "voa" até o rodapé.
  ({int qtd, Offset de, Offset para})? _voo;

  final _chaveParticulas = GlobalKey<ExplosaoDeParticulasState>();
  final _chaveCoracoes = GlobalKey<ExplosaoDeParticulasState>();
  final _chavePepita = GlobalKey();
  final _chaveRodape = GlobalKey();
  final _chavePilha = GlobalKey();

  Store get store => widget.store;

  @override
  void initState() {
    super.initState();
    _fraseSaudacao = Frases.sortear(Frases.saudacao);
    _entrada = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward();
    _relogio = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _agora = DateTime.now());
    });
    Notificacoes.pedidoAbrirMomento.addListener(_aoPedirAbrir);
    WidgetsBinding.instance.addPostFrameCallback((_) => _aoPedirAbrir());
  }

  @override
  void dispose() {
    Notificacoes.pedidoAbrirMomento.removeListener(_aoPedirAbrir);
    _relogio?.cancel();
    _timerBalao?.cancel();
    _timerEstado?.cancel();
    _entrada.dispose();
    super.dispose();
  }

  /// Tocar na notificação abre a sheet do momento correspondente.
  void _aoPedirAbrir() {
    final id = Notificacoes.pedidoAbrirMomento.value;
    if (id == null || !mounted) return;
    Notificacoes.pedidoAbrirMomento.value = null;
    final m = store.momentos.where((m) => m.id == id).firstOrNull;
    if (m != null) _abrir(m);
  }

  // ---------- saudação ----------

  String get _saudacao {
    final h = _agora.hour;
    final nome = store.nome;
    if (h < 12) return 'Bom dia, $nome ☀️';
    if (h < 18) return 'Boa tarde, $nome';
    return 'Boa noite, $nome 🌙';
  }

  // ---------- estado da Pepita ----------

  EstadoPepita get _estadoPepita {
    if (_comemorando) return EstadoPepita.comemorando;
    if (_curiosa) return EstadoPepita.curiosa;
    if (_aconchegada) return EstadoPepita.aconchegada;
    final ms = store.momentos;
    if (ms.any((m) => m.estadoEm(_agora) == EstadoMomento.agora)) {
      return EstadoPepita.animada;
    }
    // Noite, depois do último momento: ela se aconchega.
    final ultimoFim = ms.map((m) => m.fim).reduce((a, b) => a > b ? a : b);
    if (_agora.hour * 60 + _agora.minute >= ultimoFim) {
      return EstadoPepita.aconchegada;
    }
    return EstadoPepita.tranquila;
  }

  void _falar(String frase) {
    _timerBalao?.cancel();
    setState(() => _balao = frase);
    _timerBalao = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _balao = null);
    });
  }

  void _estadoTemporario(void Function(bool) definir, Duration duracao) {
    _timerEstado?.cancel();
    setState(() {
      _comemorando = false;
      _aconchegada = false;
      _curiosa = false;
      definir(true);
    });
    _timerEstado = Timer(duracao, () {
      if (!mounted) return;
      setState(() {
        _comemorando = false;
        _aconchegada = false;
        _curiosa = false;
      });
    });
  }

  void _tocouNaPepita() {
    _falar(Frases.sortear(Frases.carinho, nome: store.nome));
    _chaveCoracoes.currentState?.disparar();
  }

  void _segurouNaPepita() {
    HapticFeedback.selectionClick();
    _estadoTemporario((v) => _curiosa = v, const Duration(milliseconds: 2200));
    _falar('Hmm? 🤔');
  }

  // ---------- registro ----------

  Future<void> _abrir(Momento m) async {
    final dia = DateTime.now();
    final atual = store.registroDe(dia, m.id);
    final r = await mostrarSheetRegistro(context, momento: m, atual: atual);
    if (r == null || !mounted) return;

    switch (r.acao) {
      case AcaoRegistro.postei:
        await store.salvarRegistro(
            dia, m.id, Registro(tipo: TipoRegistro.postei, qtd: r.qtd));
        _celebrar(r.qtd, m);
      case AcaoRegistro.descanso:
        await store.salvarRegistro(
            dia, m.id, const Registro(tipo: TipoRegistro.descanso));
        _estadoTemporario((v) => _aconchegada = v, const Duration(seconds: 5));
        _falar(Frases.sortear(Frases.descanso, nome: store.nome));
      case AcaoRegistro.apagar:
        await store.apagarRegistro(dia, m.id);
        if (!mounted) return;
        mostrarSnackFofa(
          context,
          'Anotação apagada',
          rotuloAcao: 'desfazer',
          aoAcao: () {
            if (atual != null) store.salvarRegistro(dia, m.id, atual);
          },
        );
    }
  }

  /// Comemoração (~1,6s): pulo, partículas, selinho, número voando e balão.
  void _celebrar(int? qtd, Momento m) {
    _estadoTemporario((v) => _comemorando = v, const Duration(milliseconds: 2600));
    _falar(Frases.sortear(Frases.comemoracao, nome: store.nome, momento: m.nome));
    if (qtd != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _iniciarVoo(qtd);
      });
    }
  }

  void _iniciarVoo(int qtd) {
    final pilha = _chavePilha.currentContext?.findRenderObject() as RenderBox?;
    final pepita = _chavePepita.currentContext?.findRenderObject() as RenderBox?;
    final rodape = _chaveRodape.currentContext?.findRenderObject() as RenderBox?;
    if (pilha == null || pepita == null || rodape == null) return;
    final de = pilha.globalToLocal(
        pepita.localToGlobal(pepita.size.center(Offset.zero)));
    final para = pilha.globalToLocal(
        rodape.localToGlobal(rodape.size.center(Offset.zero)));
    setState(() => _voo = (qtd: qtd, de: de, para: para));
  }

  // ---------- visual ----------

  Widget _cascata(int i, Widget filho) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return filho;
    final anim = CurvedAnimation(
      parent: _entrada,
      curve: Interval(0.08 * i, (0.08 * i + 0.55).clamp(0.0, 1.0),
          curve: Curves.easeOutBack),
    );
    return FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: const Interval(0, 0.6)),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(anim),
        child: filho,
      ),
    );
  }

  Widget _areaPepita() {
    final reduzir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return SizedBox(
      height: 270,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Almofada / nuvem creme.
          Positioned(
            bottom: 14,
            child: Container(
              width: 210,
              height: 46,
              decoration: BoxDecoration(
                color: Paleta.cremeEscuro,
                borderRadius: BorderRadius.circular(Raios.pilula),
                boxShadow: Sombras.suave,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            child: AnimatedSlide(
              duration: Duration(milliseconds: reduzir ? 0 : 450),
              curve: Curves.easeInOut,
              offset: _cavando ? const Offset(0, 0.28) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _cavando ? 0.55 : 1,
                child: Pepita(
                  key: _chavePepita,
                  tamanho: 190,
                  estado: _estadoPepita,
                  aoTocar: _tocouNaPepita,
                  aoSegurar: _segurouNaPepita,
                  aoDecolar: () => _chaveParticulas.currentState?.disparar(),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ExplosaoDeParticulas(key: _chaveParticulas, quantidade: 18),
          ),
          Positioned.fill(
            child: ExplosaoDeParticulas(key: _chaveCoracoes, quantidade: 4),
          ),
          // Balãozinho que some em 3s.
          Positioned(
            top: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (c, a) => ScaleTransition(
                  scale: a, alignment: Alignment.bottomCenter, child: FadeTransition(opacity: a, child: c)),
              child: _balao == null
                  ? const SizedBox(key: ValueKey('vazio'), height: 1)
                  : Container(
                      key: ValueKey(_balao),
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Paleta.creme,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Paleta.rosa, width: 1.5),
                        boxShadow: Sombras.leve,
                      ),
                      child: Text(_balao!,
                          textAlign: TextAlign.center,
                          style: Textos.corpo(tamanho: 15)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final hoje = _agora;
        final momentos = store.momentos;
        final achados = store.achadosDoDia(hoje);

        return Stack(
          key: _chavePilha,
          children: [
            Positioned.fill(child: FundoFlutuante(hora: hoje.hour)),
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: Paleta.rosaForte,
                backgroundColor: Paleta.creme,
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  setState(() => _cavando = true);
                  await Future<void>.delayed(const Duration(milliseconds: 1100));
                  if (!mounted) return;
                  setState(() {
                    _cavando = false;
                    _agora = DateTime.now();
                  });
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
                  children: [
                    _cascata(
                      0,
                      Column(
                        children: [
                          Text(_saudacao,
                              textAlign: TextAlign.center,
                              style: Textos.titulo(tamanho: 28)),
                          const SizedBox(height: 6),
                          Text(_fraseSaudacao,
                              textAlign: TextAlign.center,
                              style: Textos.corpo(
                                  tamanho: 14, cor: Paleta.cacauClaro)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _cascata(1, _areaPepita()),
                    const SizedBox(height: 14),
                    for (var i = 0; i < momentos.length; i++)
                      _cascata(
                        i + 2,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CardMomento(
                            momento: momentos[i],
                            estado: momentos[i].estadoEm(hoje),
                            registro: store.registroDe(hoje, momentos[i].id),
                            aoTocar: () => _abrir(momentos[i]),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    _cascata(5, KeyedSubtree(key: _chaveRodape, child: RodapeDia(achados: achados))),
                  ],
                ),
              ),
            ),
            if (_voo != null) _numeroVoando(_voo!),
          ],
        );
      },
    );
  }

  Widget _numeroVoando(({int qtd, Offset de, Offset para}) voo) {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(voo),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 950),
          curve: Curves.easeInOutCubic,
          onEnd: () {
            if (mounted) setState(() => _voo = null);
          },
          builder: (context, t, _) {
            final pos = Offset.lerp(voo.de, voo.para, t)! +
                Offset(0, -60 * (1 - (2 * t - 1) * (2 * t - 1)));
            final escala = 1.4 - 0.5 * t;
            final alpha = t < 0.85 ? 1.0 : (1 - (t - 0.85) / 0.15);
            return Stack(
              children: [
                Positioned(
                  left: pos.dx - 40,
                  top: pos.dy - 20,
                  width: 80,
                  child: Opacity(
                    opacity: alpha.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: escala,
                      child: Text(
                        '+${voo.qtd} 💎',
                        textAlign: TextAlign.center,
                        style: Textos.titulo(
                            tamanho: 24, cor: Paleta.rosaForte, peso: 600),
                      ),
                    ),
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
