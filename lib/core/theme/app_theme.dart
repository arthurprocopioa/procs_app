import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// V3 Híbrido (FINAL):
/// 1. 'darkTheme' = 100% PURE V3 (Nosso destino de refatoração).
/// 2. Variáveis Estáticas (@Deprecated) = 100% V1 (Nossa origem, para compatibilidade).
class AppTheme {
  // ---
  // V3: Definições da Paleta (Briefing)
  // ---
  static const Color _accentBrand = Color(0xFFD4AF37);
  static const Color _background = Color(0xFF121212);
  static const Color _backgroundSecondary = Color(0xFF1E1E1E);
  static const Color _ctaPrimaryBackground = Color(0xFFFFFFFF);
  static const Color _ctaPrimaryText = Color(0xFF1C1C1E);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFB3B3B3); // Mais claro que o V1
  static const Color _errorRed = Color(0xFFFF4C4C);

  // ---
  // V1: Ponte de Refatoração (Cores V1 Antigas)
  // ---
  @Deprecated('Refatorar para usar Theme.of(context).colorScheme.primary')
  static const Color primaryGold = Color(0xFFDDAA33);

  @Deprecated('Refatorar para usar Theme.of(context).scaffoldBackgroundColor')
  static const Color darkBackground = Color(0xFF121212);

  @Deprecated(
      'Refatorar para usar Theme.of(context).colorScheme.surfaceContainer')
  static const Color lightBackground = Color(0xFF1E1E1E);

  @Deprecated('Refatorar para usar Theme.of(context).colorScheme.onBackground')
  static const Color primaryText = Color(0xFFFFFFFF);

  @Deprecated(
      'Refatorar para usar Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme._textSecondary')
  static const Color secondaryText = Color(0xFFAAAAAA);

  @Deprecated('Refatorar para usar Theme.of(context).colorScheme.error')
  static const Color errorRed = Color(0xFFFF4C4C);

  @Deprecated('Refatorar para usar cores V3 definidas no tema')
  static const Color successGreen = Color(0xFF4CAF50);

  // ---
  // V3: O Tema PURE V3 (Nosso Destino)
  // ---
  static ThemeData get darkTheme {
    // 1. Definições de Cor V3
    const ColorScheme colorSchemeV3 = ColorScheme.dark(
      primary: _accentBrand,
      secondary: _accentBrand,
      surface: _background,
      surfaceContainer: _backgroundSecondary, // #1E1E1E
      onSurface: _textPrimary,
      onPrimary: _ctaPrimaryText,
      onSecondary: _ctaPrimaryText,
      error: _errorRed,
      onError: _textPrimary,
    );

    // 2. Definições de Texto V3 (Semântica)
    final TextTheme textThemeV3 = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme.apply(
            bodyColor: _textPrimary,
            displayColor: _textPrimary,
          ),
    ).copyWith(
      // (Estes substituem os estilos V1)
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary, // Nosso V3 'B3B3B3'
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      // V3 (FINAL CORRIGIDO): Estilo semântico para o título do AppBar
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _textSecondary, // Cor de Etapa (Ex: "Etapa 4 de 13")
      ),
    );

    // 3. Tema V3
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      primaryColor: _accentBrand,
      colorScheme: colorSchemeV3,
      textTheme: textThemeV3,

      // ---
      // Componentes V3
      // ---

      // AppBar V3
      appBarTheme: AppBarTheme(
        backgroundColor: _background, // Fundo V3
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _textPrimary), // Back button
        // V3 (FINAL CORRIGIDO): Aponta para o estilo semântico
        titleTextStyle: textThemeV3.titleMedium,
      ),

      // Botão CTA V3 (Branco)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _ctaPrimaryBackground, // Fundo Branco V3
          foregroundColor: _ctaPrimaryText, // Texto Preto V3
          minimumSize: const Size(double.infinity, 56), // Altura padrão
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Borda V3
          ),
          textStyle: textThemeV3.labelLarge?.copyWith(color: _ctaPrimaryText),
        ),
      ),

      // Card V3 (FINALMENTE CORRIGIDO)
      cardTheme: CardThemeData(
        // <-- CORRIGIDO PARA CardThemeData
        color: _backgroundSecondary, // #1E1E1E
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input V3
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _backgroundSecondary, // #1E1E1E
        hintStyle: textThemeV3.bodyMedium, // V3 'B3B3B3'
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: _accentBrand, width: 2.0),
        ),
      ),
    );
  }
}
