import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class Tokens {
  static const primary = Color(0xFF00513C);
  static const primaryContainer = Color(0xFF176B52);
  static const primaryDark = Color(0xFF103F34);
  static const background = Color(0xFFE7FFF5);
  static const mint = Color(0xFFA4F2D2);
  static const soft = Color(0xFFE1F9EF);
  static const text = Color(0xFF0B1F19);
  static const secondary = Color(0xFF3F4944);
  static const inverseSurface = Color(0xFF20342E);
  static const surfaceVariant = Color(0xFFD0E8DE);
  static const secondaryContainer = Color(0xFFBDEDDC);
  static const secondaryFixedDim = Color(0xFFA2D0C1);
  // Exact named colors exported by Google Stitch; no generated light shades.
  static const stitchLight = ColorScheme.light(
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    onInverseSurface: Color(0xFFDFF6EC),
    inversePrimary: Color(0xFF89D6B7),
    inverseSurface: Color(0xFF20342E),
    onError: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF93000A),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFF9BE9C9),
    onPrimaryFixed: Color(0xFF002116),
    onPrimaryFixedVariant: Color(0xFF00513C),
    onSecondary: Color(0xFFFFFFFF),
    onSecondaryContainer: Color(0xFF416D60),
    onSecondaryFixed: Color(0xFF002019),
    onSecondaryFixedVariant: Color(0xFF224E43),
    onSurface: Color(0xFF0B1F19),
    onSurfaceVariant: Color(0xFF3F4944),
    onTertiary: Color(0xFFFFFFFF),
    onTertiaryContainer: Color(0xFF9CE9C6),
    onTertiaryFixed: Color(0xFF002115),
    onTertiaryFixedVariant: Color(0xFF00513A),
    outline: Color(0xFF6F7974),
    outlineVariant: Color(0xFFBEC9C2),
    primary: Color(0xFF00513C),
    primaryContainer: Color(0xFF176B52),
    primaryFixed: Color(0xFFA4F2D2),
    primaryFixedDim: Color(0xFF89D6B7),
    secondary: Color(0xFF3B665A),
    secondaryContainer: Color(0xFFBDEDDC),
    secondaryFixed: Color(0xFFBDEDDC),
    secondaryFixedDim: Color(0xFFA2D0C1),
    surface: Color(0xFFE7FFF5),
    surfaceBright: Color(0xFFE7FFF5),
    surfaceContainer: Color(0xFFDCF3E9),
    surfaceContainerHigh: Color(0xFFD6EDE4),
    surfaceContainerHighest: Color(0xFFD0E8DE),
    surfaceContainerLow: Color(0xFFE1F9EF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFC8DFD6),
    surfaceTint: Color(0xFF176B52),
    tertiary: Color(0xFF00523A),
    tertiaryContainer: Color(0xFF1A6B50),
    tertiaryFixed: Color(0xFFA5F2CF),
    tertiaryFixedDim: Color(0xFF8AD6B4),
  );
  static const income = Color(0xFF16835D);
  static const expense = Color(0xFFD65C61);
  static const incomeDark = Color(0xFF83D8B5);
  static const expenseDark = Color(0xFFF5A2A5);
  static const summaryBreakpoint = 280.0;
  static const gap = 16.0,
      small = 8.0,
      page = 20.0,
      radius = 24.0,
      maxWidth = 760.0,
      fieldHeight = 52.0;
  static const round = BorderRadius.all(Radius.circular(radius));
  static ThemeData theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = (dark
        ? ColorScheme.fromSeed(
            seedColor: primary,
            brightness: brightness,
          ).copyWith(
            primary: dark ? const Color(0xFF83D8B5) : primary,
            secondaryContainer: dark ? const Color(0xFF244E40) : soft,
            onSecondaryContainer: dark ? mint : primaryDark,
            surface: dark ? const Color(0xFF15241E) : Colors.white,
            onSurface: dark ? const Color(0xFFE2EEE7) : text,
            onSurfaceVariant: dark ? const Color(0xFFADBCB3) : secondary,
          )
        : stitchLight);
    final baseText = Typography.material2021().black.apply(
      fontFamily: 'Inter',
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    TextStyle heading(double size) => TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: scheme.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0D1813) : background,
      textTheme: baseText.copyWith(
        bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: baseText.bodySmall?.copyWith(fontSize: 12),
        headlineLarge: heading(32),
        headlineMedium: heading(28),
        headlineSmall: heading(22),
        titleLarge: heading(20),
        titleMedium: heading(16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF0D1813) : background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: heading(18),
        centerTitle: false,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: const StadiumBorder(),
        selectedColor: primary,
        backgroundColor: scheme.surface,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: round),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? scheme.surface : soft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(gap),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(gap),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(gap),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(gap),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, fieldHeight),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;
  void set(ThemeMode value) => state = value;
}

final themeProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
