import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/widgets/language_option_tile.dart';
import 'package:daily_stanza/features/settings/presentation/widgets/theme_option_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ---- Poem language section ----
          Text('Poem language', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose the language used for the daily poem.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          BlocBuilder<LanguagePreferencesCubit, LanguagePreferencesState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AbsorbPointer(
                    absorbing: state.isSaving,
                    child: RadioGroup<PoemLanguage>(
                      groupValue: state.language,
                      onChanged: (PoemLanguage? value) {
                        if (value != null) {
                          context
                              .read<LanguagePreferencesCubit>()
                              .changeLanguage(value);
                        }
                      },
                      child: const Column(
                        children: [
                          LanguageOptionTile(
                            language: PoemLanguage.english,
                            label: 'English',
                          ),
                          LanguageOptionTile(
                            language: PoemLanguage.polish,
                            label: 'Polski',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: Text(
                      'Saved on this device.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // ---- Appearance section ----
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose how Daily Stanza looks on this device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          BlocBuilder<ThemePreferencesCubit, ThemePreferencesState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AbsorbPointer(
                    absorbing: state.isSaving,
                    child: RadioGroup<ThemePreference>(
                      groupValue: state.preference,
                      onChanged: (ThemePreference? value) {
                        if (value != null) {
                          context.read<ThemePreferencesCubit>().changeTheme(
                            value,
                          );
                        }
                      },
                      child: const Column(
                        children: [
                          ThemeOptionTile(
                            preference: ThemePreference.system,
                            label: 'System',
                            description: 'Use your device setting.',
                          ),
                          ThemeOptionTile(
                            preference: ThemePreference.light,
                            label: 'Light',
                            description: 'Always use the light theme.',
                          ),
                          ThemeOptionTile(
                            preference: ThemePreference.dark,
                            label: 'Dark',
                            description: 'Always use the dark theme.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: Text(
                      'Saved on this device.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
