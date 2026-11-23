// Modelos e helpers de data do Pepita.

enum TipoRegistro { postei, descanso }

enum EstadoMomento { antes, agora, depois }

class Momento {
  final int id;
  final String nome;
  final String emoji;

  /// Minutos desde a meia-noite.
  final int ini;
  final int fim;
  final bool lembrete;

  const Momento({
    required this.id,
    required this.nome,
    required this.emoji,
    required this.ini,
    required this.fim,
    required this.lembrete,
  });

  Momento copiar({
    String? nome,
    String? emoji,
    int? ini,
    int? fim,
    bool? lembrete,
  }) =>
      Momento(
        id: id,
        nome: nome ?? this.nome,
        emoji: emoji ?? this.emoji,
        ini: ini ?? this.ini,
        fim: fim ?? this.fim,
        lembrete: lembrete ?? this.lembrete,
      );

  /// "07:00 – 08:00"
  String get faixa => '${formatarMinutos(ini)} – ${formatarMinutos(fim)}';

  /// Em que ponto do dia estamos em relação a este momento.
  EstadoMomento estadoEm(DateTime agora) {
    final min = agora.hour * 60 + agora.minute;
    if (min < ini) return EstadoMomento.antes;
    if (min < fim) return EstadoMomento.agora;
    return EstadoMomento.depois;
  }

  Map<String, dynamic> paraJson() => {
        'id': id,
        'nome': nome,
        'emoji': emoji,
        'ini': ini,
        'fim': fim,
        'lembrete': lembrete,
      };

  factory Momento.deJson(Map<String, dynamic> j) => Momento(
        id: j['id'] as int,
        nome: j['nome'] as String,
        emoji: j['emoji'] as String,
        ini: j['ini'] as int,
        fim: j['fim'] as int,
        lembrete: j['lembrete'] as bool,
      );

  /// Os 3 momentos padrão (sempre exatamente 3).
  static const padrao = [
    Momento(
        id: 0,
        nome: 'Garimpo da manhã',
        emoji: '☀️',
        ini: 7 * 60,
        fim: 8 * 60,
        lembrete: true),
    Momento(
        id: 1,
        nome: 'Garimpo do almoço',
        emoji: '🍙',
        ini: 12 * 60,
        fim: 13 * 60,
        lembrete: true),
    Momento(
        id: 2,
        nome: 'Garimpo da volta',
        emoji: '🌙',
        ini: 17 * 60 + 30,
        fim: 18 * 60 + 30,
        lembrete: true),
  ];
}

class Registro {
  final TipoRegistro tipo;

  /// Quantidade de achados (opcional, 1–999).
  final int? qtd;

  const Registro({required this.tipo, this.qtd});

  Map<String, dynamic> paraJson() => {
        'tipo': tipo.name,
        if (qtd != null) 'qtd': qtd,
      };

  factory Registro.deJson(Map<String, dynamic> j) => Registro(
        tipo: TipoRegistro.values.firstWhere(
          (t) => t.name == j['tipo'],
          orElse: () => TipoRegistro.descanso,
        ),
        qtd: j['qtd'] as int?,
      );
}

/// "AAAA-MM-DD"
String chaveDia(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime diaDeChave(String chave) {
  final p = chave.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// "07:30"
String formatarMinutos(int minutos) {
  final h = (minutos ~/ 60).toString().padLeft(2, '0');
  final m = (minutos % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// Segunda-feira da semana de [d] (à meia-noite).
DateTime inicioDaSemana(DateTime d) {
  final dia = DateTime(d.year, d.month, d.day);
  return dia.subtract(Duration(days: dia.weekday - 1));
}

/// Soma de dias respeitando horário de verão (usa o construtor, não Duration).
DateTime somarDias(DateTime d, int dias) =>
    DateTime(d.year, d.month, d.day + dias);

bool mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const nomesDiasSemana = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

const nomesMeses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];
