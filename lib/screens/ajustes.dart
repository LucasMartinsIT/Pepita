import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models.dart';
import '../notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/botao_fofo.dart';
import '../widgets/pepita.dart';
import '../widgets/snack_fofa.dart';
import '../widgets/switch_coracao.dart';

const _emojisFofos = [
  '☀️', '🍙', '🌙', '🌸', '💎', '✨', '☁️', '🌷',
  '🍓', '🍰', '🧁', '🦋', '🐝', '🌈', '⭐', '🫶',
];

/// Ajustes: nome, os 3 momentos (nome, emoji, horários, lembrete) e extras.
class TelaAjustes extends StatefulWidget {
  const TelaAjustes({super.key, required this.store});

  final Store store;

  @override
  State<TelaAjustes> createState() => _TelaAjustesState();
}

class _TelaAjustesState extends State<TelaAjustes> {
  late final TextEditingController _nome;
  Timer? _debounce;
  EstadoPepita _pepita = EstadoPepita.tranquila;
  Timer? _timerPepita;

  Store get store => widget.store;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: store.nome == Store.nomePadrao ? '' : store.nome);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timerPepita?.cancel();
    _nome.dispose();
    super.dispose();
  }

  void _salvarNome(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () => store.definirNome(v));
  }

  /// A Pepita inclina a cabeça (curiosa) quando algo precisa de um ajuste.
  void _pepitaCuriosa() {
    _timerPepita?.cancel();
    setState(() => _pepita = EstadoPepita.curiosa);
    _timerPepita = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _pepita = EstadoPepita.tranquila);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Paleta.creme, Paleta.rosaBebe],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
            children: [
              Row(
                children: [
                  Expanded(child: Text('Ajustes ✨', style: Textos.titulo(tamanho: 30))),
                  Pepita(tamanho: 84, estado: _pepita),
                ],
              ),
              const SizedBox(height: 10),
              _Secao(
                titulo: 'Como posso te chamar?',
                filho: TextField(
                  controller: _nome,
                  onChanged: _salvarNome,
                  onSubmitted: store.definirNome,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 24,
                  style: Textos.corpo(tamanho: 17),
                  cursorColor: Paleta.rosaForte,
                  decoration: _decoracaoCampo('${Store.nomePadrao} (padrão)'),
                ),
              ),
              const SizedBox(height: 18),
              Text('Seus momentos', style: Textos.titulo(tamanho: 20, peso: 500)),
              const SizedBox(height: 10),
              for (final m in store.momentos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CardMomentoEditavel(
                    key: ValueKey(m.id),
                    momento: m,
                    store: store,
                    aoErro: _pepitaCuriosa,
                  ),
                ),
              const SizedBox(height: 6),
              BotaoPilula(
                texto: 'Testar lembrete 🔔',
                cor: Paleta.azulBebe,
                corTexto: Paleta.cacau,
                largura: double.infinity,
                sombra: false,
                aoTocar: _testar,
              ),
              const SizedBox(height: 12),
              BotaoPilula(
                texto: 'Restaurar horários padrão',
                cor: Paleta.lavanda,
                corTexto: Paleta.cacau,
                largura: double.infinity,
                sombra: false,
                aoTocar: () {
                  store.restaurarPadrao();
                  mostrarSnackFofa(context, 'Horários de volta ao começo 🌷');
                },
              ),
              const SizedBox(height: 28),
              Center(
                child: Text('feito com 💗 pelo Lucas',
                    style: Textos.corpo(tamanho: 14, cor: Paleta.cacauClaro)),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text('Pepita 1.0.0',
                    style: Textos.corpo(tamanho: 12, cor: Paleta.cacauClaro)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testar() async {
    var ok = await Notificacoes.permissaoConcedida();
    if (!ok) ok = await Notificacoes.pedirPermissao();
    if (!mounted) return;
    if (!ok) {
      mostrarSnackFofa(context,
          'Tudo bem! Você pode ligar os recadinhos nas configurações do celular 💗');
      return;
    }
    await Notificacoes.testar(store.nome);
    if (mounted) mostrarSnackFofa(context, 'Mandei um recadinho pra você 💌');
  }
}

InputDecoration _decoracaoCampo(String dica) => InputDecoration(
      hintText: dica,
      hintStyle: Textos.corpo(tamanho: 16, cor: Paleta.cacauClaro),
      counterText: '',
      filled: true,
      fillColor: Paleta.creme,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Raios.pilula),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Raios.pilula),
        borderSide: const BorderSide(color: Paleta.rosaForte, width: 1.8),
      ),
    );

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.filho});

  final String titulo;
  final Widget filho;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Textos.titulo(tamanho: 20, peso: 500)),
        const SizedBox(height: 10),
        filho,
      ],
    );
  }
}

class _CardMomentoEditavel extends StatefulWidget {
  const _CardMomentoEditavel({
    super.key,
    required this.momento,
    required this.store,
    required this.aoErro,
  });

  final Momento momento;
  final Store store;
  final VoidCallback aoErro;

  @override
  State<_CardMomentoEditavel> createState() => _CardMomentoEditavelState();
}

class _CardMomentoEditavelState extends State<_CardMomentoEditavel> {
  late final TextEditingController _nome;
  bool _emojisAbertos = false;
  bool _horarioInvalido = false;
  Timer? _debounce;

  Momento get m => widget.momento;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: m.nome);
  }

  @override
  void didUpdateWidget(_CardMomentoEditavel antigo) {
    super.didUpdateWidget(antigo);
    // "Restaurar padrão" muda o nome por fora do campo.
    if (antigo.momento.nome != m.nome && _nome.text != m.nome) {
      _nome.text = m.nome;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nome.dispose();
    super.dispose();
  }

  void _salvarNome(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final limpo = v.trim();
      if (limpo.isNotEmpty) widget.store.atualizarMomento(m.copiar(nome: limpo));
    });
  }

  Future<void> _escolherHorario({required bool inicio}) async {
    final atual = inicio ? m.ini : m.fim;
    final escolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: atual ~/ 60, minute: atual % 60),
      helpText: inicio ? 'Quando começa?' : 'Quando termina?',
      cancelText: 'Cancelar',
      confirmText: 'Pronto',
      builder: (context, filho) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Paleta.rosaForte,
                surface: Paleta.creme,
                onSurface: Paleta.cacau,
              ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Paleta.creme,
            hourMinuteColor: Paleta.rosaBebe,
            dayPeriodColor: Paleta.rosaBebe,
            dialBackgroundColor: Paleta.rosaBebe,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Raios.card)),
          ),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: filho!,
        ),
      ),
    );
    if (escolhido == null) return;
    final minutos = escolhido.hour * 60 + escolhido.minute;
    final ini = inicio ? minutos : m.ini;
    final fim = inicio ? m.fim : minutos;
    // Validação gentil: o fim precisa vir depois do começo.
    if (fim <= ini) {
      setState(() => _horarioInvalido = true);
      widget.aoErro();
      return;
    }
    setState(() => _horarioInvalido = false);
    widget.store.atualizarMomento(m.copiar(ini: ini, fim: fim));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Paleta.creme,
        borderRadius: BorderRadius.circular(Raios.card),
        boxShadow: Sombras.leve,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Toque(
                aoTocar: () => setState(() => _emojisAbertos = !_emojisAbertos),
                semantica: 'Escolher emoji',
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Paleta.rosaBebe,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(m.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nome,
                  onChanged: _salvarNome,
                  maxLength: 28,
                  style: Textos.titulo(tamanho: 17, peso: 500),
                  cursorColor: Paleta.rosaForte,
                  decoration: _decoracaoCampo('Nome do momento'),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            alignment: Alignment.topCenter,
            child: _emojisAbertos
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in _emojisFofos)
                          Toque(
                            aoTocar: () {
                              widget.store.atualizarMomento(m.copiar(emoji: e));
                              setState(() => _emojisAbertos = false);
                            },
                            semantica: 'Emoji $e',
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: e == m.emoji
                                    ? Paleta.rosaBebe
                                    : Paleta.cremeEscuro,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(e, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Horario(
                  rotulo: 'começa',
                  valor: formatarMinutos(m.ini),
                  aoTocar: () => _escolherHorario(inicio: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Horario(
                  rotulo: 'termina',
                  valor: formatarMinutos(m.fim),
                  aoTocar: () => _escolherHorario(inicio: false),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: _horarioInvalido
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'hmm, o fim precisa vir depois do começo 🙈',
                      style: Textos.corpo(tamanho: 14, cor: Paleta.rosaForte),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('me lembrar', style: Textos.corpo(tamanho: 16)),
              ),
              SwitchCoracao(
                valor: m.lembrete,
                semantica: 'Lembrete de ${m.nome}',
                aoMudar: (v) => widget.store.atualizarMomento(m.copiar(lembrete: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Horario extends StatelessWidget {
  const _Horario({
    required this.rotulo,
    required this.valor,
    required this.aoTocar,
  });

  final String rotulo;
  final String valor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Toque(
      aoTocar: aoTocar,
      semantica: '$rotulo às $valor',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Paleta.azulBebe,
          borderRadius: BorderRadius.circular(Raios.pilula),
        ),
        child: Column(
          children: [
            Text(rotulo, style: Textos.corpo(tamanho: 12, cor: Paleta.cacauClaro)),
            Text(valor, style: Textos.titulo(tamanho: 20, peso: 500)),
          ],
        ),
      ),
    );
  }
}
