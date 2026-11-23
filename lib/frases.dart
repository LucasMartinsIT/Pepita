import 'dart:math';

/// Bancos de frases carinhosas. Sorteio aleatório sem repetir a última usada.
/// `{nome}` vira o nome configurado e `{momento}` o nome do momento.
class Frases {
  Frases._();

  static const notifTitulo = [
    'Hora do garimpo, {nome}! 💎',
    'Psiu, {nome}… ✨',
    '{momento} chegou 🌸',
    'A Pepita achou um tempinho pra você 💗',
    'Oi, {nome}! ☁️',
  ];

  static const notifCorpo = [
    'Se der, posta umas promos. Se não der, tudo bem também 💕',
    'Achou algo legal? Compartilha com a turma. Achou nada? Descansa 🌷',
    'Sem pressa nenhuma: posta quantas você quiser 💎',
    'Uma promo já vale. Nenhuma também vale 🫶',
    'Bora garimpar uns achadinhos? Só se você estiver a fim ✨',
    'Seu tempo é seu. Se quiser, o Garimpô tá te esperando 💗',
  ];

  static const saudacao = [
    'Vamos com calma hoje 🌷',
    'Você já faz muita coisa, viu? 💗',
    'Hoje é dia de fazer o que der ✨',
    'Respira, toma uma água e segue no seu ritmo ☁️',
  ];

  static const comemoracao = [
    'Que garimpo lindo! 💎',
    'Arrasou, {nome}! ✨',
    'O Garimpô agradece 💗',
    'Achadinhos entregues com carinho 🌸',
    'Olha você brilhando mais que a minha pepita! ✨',
  ];

  static const descanso = [
    'Descansar também é produtivo 💤',
    'Tá tudo bem. Amanhã tem mais 🌙',
    'Seu lazer vem primeiro, sempre 💗',
    'Hoje a Pepita guarda as joias pra você ☁️',
  ];

  static const semPressao = [
    'Hoje é sobre você, não sobre números 🌷',
    'Nenhuma cobrança aqui, só carinho 💗',
    'O que der, deu ✨',
  ];

  static const conquista = [
    'Quantos achadinhos! 💎',
    'Que semana garimpada ✨',
    'A turma do Garimpô tem sorte de ter você 💗',
  ];

  /// Quando se toca na Pepita.
  static const carinho = [
    'Oi! 💗',
    'Hihi, cócegas!',
    'Achei uma joia: você ✨',
    'Já bebeu água hoje? 💧',
    'Tô orgulhosa de você 🌸',
  ];

  /// Todos os bancos (usado nos testes de linguagem gentil).
  static const todos = {
    'notifTitulo': notifTitulo,
    'notifCorpo': notifCorpo,
    'saudacao': saudacao,
    'comemoracao': comemoracao,
    'descanso': descanso,
    'semPressao': semPressao,
    'conquista': conquista,
    'carinho': carinho,
  };

  static final _aleatorio = Random();
  static final Map<List<String>, String> _ultima = {};

  /// Sorteia uma frase do [banco] sem repetir a última sorteada dele.
  static String sortear(
    List<String> banco, {
    String nome = '',
    String momento = '',
  }) {
    final anterior = _ultima[banco];
    var escolhida = banco[_aleatorio.nextInt(banco.length)];
    if (banco.length > 1) {
      while (escolhida == anterior) {
        escolhida = banco[_aleatorio.nextInt(banco.length)];
      }
    }
    _ultima[banco] = escolhida;
    return preencher(escolhida, nome: nome, momento: momento);
  }

  static String preencher(
    String frase, {
    String nome = '',
    String momento = '',
  }) =>
      frase.replaceAll('{nome}', nome).replaceAll('{momento}', momento);
}
