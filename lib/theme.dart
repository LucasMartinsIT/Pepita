import 'package:material_ui/material_ui.dart';

/// Paleta, fontes, sombras e raios do Pepita.
/// Cores e estilos só vivem aqui — nenhum widget usa cor solta.
class Paleta {
  Paleta._();

  static const creme = Color(0xFFFFF8F0);
  static const cremeEscuro = Color(0xFFF8EBDD);
  static const rosaBebe = Color(0xFFFDE4EE);
  static const rosa = Color(0xFFF9C6DA);
  static const rosaForte = Color(0xFFEE8FB4);
  static const azulBebe = Color(0xFFD7ECFF);
  static const azul = Color(0xFFA9D3F5);
  static const menta = Color(0xFFD3F2E4);
  static const lavanda = Color(0xFFE9E0FA);
  static const cacau = Color(0xFF6E4F5E);
  static const cacauClaro = Color(0xFFA88D9A);
  static const dourado = Color(0xFFFFD98A);

  // Caderninho (folha de caderno fofinha)
  static const manteiga = Color(0xFFFFF3C9);
  static const papelLinha = Color(0xFFCFE6FA);
  static const papelMargem = Color(0xFFF7B6CF);

  // Tons da mascote
  static const pessego = Color(0xFFF6D3C6);
  static const pessegoSombra = Color(0xFFEBB9AA);
  static const douradoForte = Color(0xFFF5B94F);
  static const branco = Color(0xFFFFFFFF);

  // Céu do fundo animado, conforme o momento do dia
  static const ceuManha = Color(0xFFE6F3FF);
  static const ceuTarde = Color(0xFFFFF3E6);
  static const ceuNoite = Color(0xFFEFE4FA);
}

class Raios {
  Raios._();

  static const card = 28.0;
  static const sheet = 36.0;
  static const pilula = 999.0;
}

class Sombras {
  Sombras._();

  /// Sombra rosada, suave e difusa.
  static List<BoxShadow> suave = [
    BoxShadow(
      color: Paleta.rosa.withValues(alpha: 0.55),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> leve = [
    BoxShadow(
      color: Paleta.rosa.withValues(alpha: 0.35),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  /// Brilho (glow) em volta de algo; a intensidade vai de 0 a 1.
  static List<BoxShadow> brilho(Color cor, double intensidade) => [
        BoxShadow(
          color: cor.withValues(alpha: 0.25 + 0.5 * intensidade),
          blurRadius: 10 + 18 * intensidade,
          spreadRadius: 1 + 3 * intensidade,
        ),
      ];
}

/// Fontinhas fofas do Caderninho.
class FonteNota {
  const FonteNota(this.nome, this.familia, this.tamanho);
  final String nome;
  final String familia;
  final double tamanho;

  TextStyle estilo({Color cor = Paleta.cacau, double? tamanhoExtra}) =>
      TextStyle(
        fontFamily: familia,
        fontSize: tamanhoExtra ?? tamanho,
        color: cor,
        height: 1.25,
      );

  static const todas = [
    FonteNota('Letrinha', 'PatrickHand', 22),
    FonteNota('Chique', 'Pacifico', 19),
    FonteNota('Rabisco', 'Caveat', 27),
    FonteNota('Redondinha', 'Sniglet', 19),
  ];
}

/// Cores dos papeizinhos do Caderninho.
const papeisDoCaderno = [
  Paleta.creme,
  Paleta.rosaBebe,
  Paleta.azulBebe,
  Paleta.menta,
  Paleta.lavanda,
  Paleta.manteiga,
];

class Textos {
  Textos._();

  static TextStyle titulo({
    double tamanho = 24,
    Color cor = Paleta.cacau,
    double peso = 600,
  }) =>
      TextStyle(
        fontFamily: 'Fredoka',
        fontSize: tamanho,
        color: cor,
        fontWeight: _peso(peso),
        fontVariations: [FontVariation('wght', peso)],
        height: 1.15,
      );

  static TextStyle corpo({
    double tamanho = 15,
    Color cor = Paleta.cacau,
    double peso = 600,
  }) =>
      TextStyle(
        fontFamily: 'Quicksand',
        fontSize: tamanho,
        color: cor,
        fontWeight: _peso(peso),
        fontVariations: [FontVariation('wght', peso)],
        height: 1.3,
      );

  static FontWeight _peso(double p) =>
      FontWeight.values[((p / 100).round().clamp(1, 9)) - 1];
}

ThemeData criarTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Paleta.rosaForte,
    brightness: Brightness.light,
  ).copyWith(
    primary: Paleta.rosaForte,
    onPrimary: Paleta.branco,
    secondary: Paleta.azul,
    surface: Paleta.creme,
    onSurface: Paleta.cacau,
    // Sem vermelho em lugar nenhum: o "erro" do tema também é rosa/lavanda.
    error: Paleta.rosaForte,
    onError: Paleta.branco,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Paleta.creme,
    fontFamily: 'Quicksand',
    textTheme: TextTheme(
      bodyMedium: Textos.corpo(),
      bodyLarge: Textos.corpo(tamanho: 17),
      titleLarge: Textos.titulo(),
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
