import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const Color emerald = Color(0xFF1DBF73);
  static const Color jade = Color(0xFF16A664);
  static const Color mint = Color(0xFFB9F7D6);
  static const Color ocean = Color(0xFF082B31);
  static const Color slate = Color(0xFF0E1620);
  static const Color charcoal = Color(0xFF161F2B);
  static const Color mist = Color(0xFFF4F7FB);
  static const Color ink = Color(0xFF111827);
  static const Color warning = Color(0xFFFFA94D);
  static const Color danger = Color(0xFFFF5D73);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: brightness,
      primary: AppColors.emerald,
      secondary: AppColors.jade,
      surface: isDark ? const Color(0xFF121A24) : Colors.white,
    ).copyWith(
      tertiary: AppColors.warning,
      error: AppColors.danger,
      outline: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.08),
      surfaceContainerHighest:
          isDark ? const Color(0xFF1A2532) : const Color(0xFFF1F5F9),
    );

    final TextTheme baseTextTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
    ).textTheme;

    final TextTheme textTheme = GoogleFonts.plusJakartaSansTextTheme(
      baseTextTheme,
    ).copyWith(
      displayLarge: GoogleFonts.sora(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: isDark ? Colors.white : AppColors.ink,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: isDark ? Colors.white : AppColors.ink,
      ),
      headlineMedium: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.ink,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.ink,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.ink,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 1.45,
        color: isDark
            ? Colors.white.withValues(alpha: 0.92)
            : AppColors.ink.withValues(alpha: 0.90),
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 1.4,
        color: isDark
            ? Colors.white.withValues(alpha: 0.80)
            : AppColors.ink.withValues(alpha: 0.72),
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: isDark ? AppColors.slate : AppColors.mist,
      dividerColor: scheme.outline,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.88),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF192331) : Colors.white,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.86),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.emerald, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.90),
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          textTheme.labelLarge!,
        ),
        indicatorColor: AppColors.emerald.withValues(alpha: 0.18),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.emerald,
        inactiveTrackColor: AppColors.emerald.withValues(alpha: 0.18),
        thumbColor: AppColors.emerald,
        overlayColor: AppColors.emerald.withValues(alpha: 0.14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppColors.emerald
              : scheme.surfaceContainerHighest,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppColors.emerald.withValues(alpha: 0.35)
              : scheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  static LinearGradient shellGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const <Color>[
              Color(0xFF071117),
              Color(0xFF0F1D2C),
              Color(0xFF142833),
            ]
          : const <Color>[
              Color(0xFFF4FFF8),
              Color(0xFFEAF8FF),
              Color(0xFFF5F8FF),
            ],
    );
  }

  static LinearGradient accentGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1DBF73),
      Color(0xFF0C9E61),
      Color(0xFF0B7D73),
    ],
  );
}
