import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:naqirgiftbox/core/constants/app_colors.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';

/// Builds the app's light/dark [ThemeData] from the brand palette.
///
/// Uses `ColorScheme.fromSeed(...).copyWith(...)` rather than a hand-rolled
/// [ColorScheme] constructor: seeding gives Material 3 harmonious container/
/// outline/surface-tint roles for free, and `copyWith` then pins the exact
/// brand hex values the design calls for on top of it.
abstract final class AppTheme {
  static ThemeData light(String languageCode) =>
      _build(Brightness.light, languageCode);

  static ThemeData dark(String languageCode) =>
      _build(Brightness.dark, languageCode);

  static ThemeData _build(Brightness brightness, String languageCode) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final textTheme = _textTheme(languageCode, colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarThemeData(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        scrolledUnderElevation: AppElevation.card,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: AppElevation.card,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primary,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.4 : 0.6,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        elevation: AppElevation.flat,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  static final _lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.backgroundLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textLight,
        tertiary: AppColors.accent,
        onTertiary: AppColors.textLight,
        surface: AppColors.backgroundLight,
        onSurface: AppColors.textLight,
        error: AppColors.error,
        outline: AppColors.outlineLight,
      );

  static final _darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.secondary,
        onPrimary: AppColors.textLight,
        secondary: AppColors.primary,
        onSecondary: AppColors.backgroundDark,
        tertiary: AppColors.accent,
        onTertiary: AppColors.textLight,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.textDark,
        error: AppColors.errorDark,
        outline: AppColors.outlineDark,
      );

  /// English pairs a display serif ([GoogleFonts.marcellus]) with a clean
  /// sans body ([GoogleFonts.inter]); Arabic has no equivalent classic-serif
  /// webfont, so it uses [GoogleFonts.cairo] throughout, varying weight for
  /// hierarchy instead of family. See docs/ARCHITECTURE.md §6.
  static TextTheme _textTheme(String languageCode, ColorScheme colorScheme) {
    final isArabic = languageCode == 'ar';
    final body = isArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.interTextTheme();
    final display = isArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.marcellusTextTheme();

    final merged = body.copyWith(
      displayLarge: display.displayLarge,
      displayMedium: display.displayMedium,
      displaySmall: display.displaySmall,
      headlineLarge: display.headlineLarge,
      headlineMedium: display.headlineMedium,
      headlineSmall: display.headlineSmall,
      titleLarge: (isArabic ? display.titleLarge : body.titleLarge)?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return merged.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}
