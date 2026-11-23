import 'package:material_ui/material_ui.dart';

import '../models.dart';
import '../theme.dart';
import 'botao_fofo.dart';
import 'pepita.dart';
import 'switch_coracao.dart';

class ResultadoNota {
  const ResultadoNota.salvar(this.nota) : apagar = false;
  const ResultadoNota.apagar()
      : nota = null,
        apagar = true;

  final Nota? nota;
  final bool apagar;
}

/// Sheet para escrever/editar uma notinha: fonte, papel e bolinha de "feitinho".
Future<ResultadoNota?> mostrarSheetNota(BuildContext context, {Nota? atual}) {
  return showModalBottomSheet<ResultadoNota>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Paleta.cacau.withValues(alpha: 0.25),
    sheetAnimationStyle: AnimationStyle(
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 520),
      reverseCurve: Curves.easeIn,
      reverseDuration: const Duration(milliseconds: 220),
    ),
    builder: (_) => _SheetNota(atual: atual),
  );
}

class _SheetNota extends StatefulWidget {
  const _SheetNota({this.atual});

  final Nota? atual;

  @override
  State<_SheetNota> createState() => _SheetNotaState();
}

class _SheetNotaState extends State<_SheetNota> {
  late final TextEditingController _texto;
  late int _fonte;
  late int _papel;
  late bool _tarefinha;

  @override
  void initState() {
    super.initState();
    final n = widget.atual;
    _texto = TextEditingController(text: n?.texto ?? '');
    _fonte = n?.fonte ?? 0;
    _papel = n?.papel ?? 0;
    _tarefinha = n?.tarefinha ?? false;
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _guardar() {
    final texto = _texto.text.trim();
    // Notinha em branco: só fecha, sem guardar nada.
    if (texto.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final base = widget.atual ??
        Nota(id: DateTime.now().millisecondsSinceEpoch, texto: texto);
    Navigator.pop(
      context,
      ResultadoNota.salvar(base.copiar(
        texto: texto,
        fonte: _fonte,
        papel: _papel,
        tarefinha: _tarefinha,
        feita: _tarefinha ? base.feita : false,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.viewInsetsOf(context).bottom;
    final fonte = FonteNota.todas[_fonte];

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 42),
            padding: const EdgeInsets.fromLTRB(22, 50, 22, 24),
            decoration: BoxDecoration(
              color: Paleta.creme,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(Raios.sheet)),
              boxShadow: Sombras.suave,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.atual == null ? 'Nova notinha ✏️' : 'Sua notinha ✏️',
                        style: Textos.titulo(tamanho: 22)),
                    const SizedBox(height: 14),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: papeisDoCaderno[_papel],
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: Sombras.leve,
                      ),
                      child: TextField(
                        controller: _texto,
                        autofocus: widget.atual == null,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 280,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Paleta.rosaForte,
                        style: fonte.estilo(),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: 'Escreve aqui uma coisinha…',
                          hintStyle: fonte.estilo(cor: Paleta.cacauClaro),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < FonteNota.todas.length; i++)
                          Toque(
                            aoTocar: () => setState(() => _fonte = i),
                            semantica: 'Fonte ${FonteNota.todas[i].nome}',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: i == _fonte
                                    ? Paleta.rosaBebe
                                    : Paleta.cremeEscuro,
                                borderRadius: BorderRadius.circular(Raios.pilula),
                                border: Border.all(
                                  color: i == _fonte
                                      ? Paleta.rosaForte
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(FonteNota.todas[i].nome,
                                  style: FonteNota.todas[i].estilo(tamanhoExtra: 17)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < papeisDoCaderno.length; i++)
                          Toque(
                            aoTocar: () => setState(() => _papel = i),
                            semantica: 'Papel ${i + 1}',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: i == _papel ? 40 : 32,
                              height: i == _papel ? 40 : 32,
                              decoration: BoxDecoration(
                                color: papeisDoCaderno[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: i == _papel
                                      ? Paleta.rosaForte
                                      : Paleta.rosa,
                                  width: i == _papel ? 2.5 : 1.2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text('com bolinha de feitinho',
                              style: Textos.corpo(tamanho: 15)),
                        ),
                        SwitchCoracao(
                          valor: _tarefinha,
                          semantica: 'Bolinha de feitinho',
                          aoMudar: (v) => setState(() => _tarefinha = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    BotaoPilula(
                      texto: 'Guardar 💗',
                      largura: double.infinity,
                      aoTocar: _guardar,
                    ),
                    if (widget.atual != null) ...[
                      const SizedBox(height: 6),
                      Toque(
                        aoTocar: () =>
                            Navigator.pop(context, const ResultadoNota.apagar()),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'apagar notinha',
                            style: Textos.corpo(
                                    tamanho: 14, cor: Paleta.cacauClaro)
                                .copyWith(decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            child: IgnorePointer(child: Pepita(tamanho: 92)),
          ),
        ],
      ),
    );
  }
}
