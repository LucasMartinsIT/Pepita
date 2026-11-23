import 'package:material_ui/material_ui.dart';

import '../frases.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/botao_fofo.dart';
import '../widgets/flor.dart';
import '../widgets/pepita.dart';

/// Histórico gentil: ela vê o que fez com carinho, nunca o que "faltou".
/// Sem porcentagens, médias, comparações, "melhor dia" ou sequências.
class TelaCantinho extends StatefulWidget {
  const TelaCantinho({super.key, required this.store});

  final Store store;

  @override
  State<TelaCantinho> createState() => _TelaCantinhoState();
}

class _TelaCantinhoState extends State<TelaCantinho> {
  late DateTime _segunda = inicioDaSemana(DateTime.now());
  late DateTime _selecionado = DateTime.now();
  bool _indoParaFrente = true;
  late final String _fraseConquista;
  late final String _fraseSemPressao;

  Store get store => widget.store;

  @override
  void initState() {
    super.initState();
    _fraseConquista = Frases.sortear(Frases.conquista);
    _fraseSemPressao = Frases.sortear(Frases.semPressao);
  }

  void _mudarSemana(int delta) {
    setState(() {
      _indoParaFrente = delta > 0;
      _segunda = somarDias(_segunda, 7 * delta);
      // Mantém o mesmo dia da semana selecionado na nova semana.
      _selecionado = somarDias(_segunda, _selecionado.weekday - 1);
    });
  }

  String get _rotuloSemana {
    final fim = somarDias(_segunda, 6);
    String abrev(DateTime d) => nomesMeses[d.month - 1].substring(0, 3);
    if (_segunda.month == fim.month) {
      return '${_segunda.day} – ${fim.day} de ${abrev(fim)}';
    }
    return '${_segunda.day} ${abrev(_segunda)} – ${fim.day} ${abrev(fim)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final hoje = DateTime.now();
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Seu cantinho 💗',
                          style: Textos.titulo(tamanho: 30)),
                    ),
                    const Pepita(tamanho: 84),
                  ],
                ),
                const SizedBox(height: 10),
                _navegacaoSemana(),
                const SizedBox(height: 14),
                _semana(hoje),
                const SizedBox(height: 18),
                _cardDia(hoje),
                const SizedBox(height: 14),
                _cardSemana(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navegacaoSemana() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Seta(icone: Icons.chevron_left_rounded, aoTocar: () => _mudarSemana(-1),
            semantica: 'Semana anterior'),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(_rotuloSemana,
              key: ValueKey(_segunda),
              style: Textos.titulo(tamanho: 18, peso: 500)),
        ),
        _Seta(icone: Icons.chevron_right_rounded, aoTocar: () => _mudarSemana(1),
            semantica: 'Próxima semana'),
      ],
    );
  }

  Widget _semana(DateTime hoje) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      transitionBuilder: (filho, anim) {
        final entrando = filho.key == ValueKey(_segunda);
        final dir = _indoParaFrente ? 1.0 : -1.0;
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
                    begin: Offset(entrando ? 0.25 * dir : -0.25 * dir, 0),
                    end: Offset.zero)
                .animate(anim),
            child: filho,
          ),
        );
      },
      child: Container(
        key: ValueKey(_segunda),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: Paleta.creme,
          borderRadius: BorderRadius.circular(Raios.card),
          boxShadow: Sombras.leve,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < 7; i++) _diaDaSemana(i, hoje),
          ],
        ),
      ),
    );
  }

  Widget _diaDaSemana(int i, DateTime hoje) {
    final dia = somarDias(_segunda, i);
    final selecionado = mesmoDia(dia, _selecionado);
    return Toque(
      aoTocar: () => setState(() => _selecionado = dia),
      semantica: '${nomesDiasSemana[i]}, ${dia.day}',
      child: Column(
        children: [
          Text(nomesDiasSemana[i],
              style: Textos.corpo(
                  tamanho: 12,
                  cor: selecionado ? Paleta.rosaForte : Paleta.cacauClaro)),
          const SizedBox(height: 6),
          Flor(
            petalasBrilhantes: store.momentosComPostagem(dia),
            hoje: mesmoDia(dia, hoje),
            selecionada: selecionado,
            tamanho: 40,
          ),
          const SizedBox(height: 4),
          Text('${dia.day}',
              style: Textos.titulo(
                  tamanho: 13,
                  peso: selecionado ? 600 : 400,
                  cor: selecionado ? Paleta.cacau : Paleta.cacauClaro)),
        ],
      ),
    );
  }

  Widget _cardDia(DateTime hoje) {
    final dia = _selecionado;
    final futuro = DateTime(dia.year, dia.month, dia.day)
        .isAfter(DateTime(hoje.year, hoje.month, hoje.day));
    final nomeDia = nomesDiasSemana[dia.weekday - 1];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(chaveDia(dia)),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Paleta.creme,
          borderRadius: BorderRadius.circular(Raios.card),
          boxShadow: Sombras.leve,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$nomeDia, ${dia.day} de ${nomesMeses[dia.month - 1]}',
                style: Textos.titulo(tamanho: 18, peso: 500)),
            const SizedBox(height: 10),
            if (futuro)
              Text('Esse dia ainda vai chegar 🌷',
                  style: Textos.corpo(cor: Paleta.cacauClaro))
            else
              for (final m in store.momentos) _linhaMomento(m, dia),
          ],
        ),
      ),
    );
  }

  Widget _linhaMomento(Momento m, DateTime dia) {
    final r = store.registroDe(dia, m.id);
    final String texto;
    final Color cor;
    if (r == null) {
      texto = '☁️ de folga';
      cor = Paleta.cremeEscuro;
    } else if (r.tipo == TipoRegistro.descanso) {
      texto = '☁️ descansei';
      cor = Paleta.lavanda;
    } else if (r.qtd != null) {
      texto = '✨ ${r.qtd} ${r.qtd == 1 ? 'achado' : 'achados'}';
      cor = Paleta.menta;
    } else {
      texto = '✨ passei por aqui';
      cor = Paleta.menta;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(m.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Text(m.nome, style: Textos.corpo())),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(Raios.pilula),
            ),
            child: Text(texto, style: Textos.titulo(tamanho: 13, peso: 500)),
          ),
        ],
      ),
    );
  }

  Widget _cardSemana() {
    final soma = store.achadosDaSemana(_segunda);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Paleta.rosaBebe,
        borderRadius: BorderRadius.circular(Raios.card),
        boxShadow: Sombras.leve,
      ),
      child: Column(
        children: [
          Text('Achados da semana',
              style: Textos.corpo(cor: Paleta.cacauClaro)),
          const SizedBox(height: 6),
          // Se a soma for 0 (ou não houver quantidade): frase gentil, nunca "0".
          if (soma > 0) ...[
            Text('$soma 💎', style: Textos.titulo(tamanho: 40, cor: Paleta.rosaForte)),
            const SizedBox(height: 4),
            Text(_fraseConquista,
                textAlign: TextAlign.center, style: Textos.corpo()),
          ] else
            Text(_fraseSemPressao,
                textAlign: TextAlign.center, style: Textos.corpo()),
        ],
      ),
    );
  }
}

class _Seta extends StatelessWidget {
  const _Seta({required this.icone, required this.aoTocar, required this.semantica});

  final IconData icone;
  final VoidCallback aoTocar;
  final String semantica;

  @override
  Widget build(BuildContext context) {
    return Toque(
      aoTocar: aoTocar,
      semantica: semantica,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Paleta.creme,
          shape: BoxShape.circle,
          boxShadow: Sombras.leve,
        ),
        child: Icon(icone, color: Paleta.cacau),
      ),
    );
  }
}
