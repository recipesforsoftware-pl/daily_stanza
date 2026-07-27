import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightAccent,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lightHighlight,
      onPrimaryContainer: AppColors.lightFg,
      secondary: AppColors.lightMuted,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSurface,
      onSecondaryContainer: AppColors.lightFg,
      tertiary: AppColors.lightSuccess,
      onTertiary: Colors.white,
      error: AppColors.lightDanger,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightFg,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightFg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightAccent.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium.copyWith(
              color: AppColors.lightAccent,
            );
          }
          return AppTextStyles.labelMedium.copyWith(
            color: AppColors.lightMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightAccent, size: 24);
          }
          return const IconThemeData(color: AppColors.lightMuted, size: 24);
        }),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          side: BorderSide(color: AppColors.lightBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineSmall: AppTextStyles.headlineSmall,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkAccent,
      onPrimary: AppColors.darkBg,
      primaryContainer: AppColors.darkHighlight,
      onPrimaryContainer: AppColors.darkFg,
      secondary: AppColors.darkMuted,
      onSecondary: AppColors.darkBg,
      secondaryContainer: AppColors.darkSurface,
      onSecondaryContainer: AppColors.darkFg,
      tertiary: AppColors.darkSuccess,
      onTertiary: AppColors.darkBg,
      error: AppColors.darkDanger,
      onError: AppColors.darkBg,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkFg,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkFg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkAccent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium.copyWith(
              color: AppColors.darkAccent,
            );
          }
          return AppTextStyles.labelMedium.copyWith(color: AppColors.darkMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkAccent, size: 24);
          }
          return const IconThemeData(color: AppColors.darkMuted, size: 24);
        }),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.darkFg,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.darkFg,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.darkFg,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkFg,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkFg,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkFg),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkFg),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkMuted),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.darkFg),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkMuted,
        ),
      ),
    );
  }
}
