import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/core/theme/app_text_styles.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/widgets/language_option_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Poem language',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.lightFg),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose the language used for the daily poem.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightMuted,
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
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.lightMuted,
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
