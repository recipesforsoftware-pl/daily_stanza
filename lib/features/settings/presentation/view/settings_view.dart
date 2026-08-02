import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/core/config/app_links.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/domain/service/external_link_launcher.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_state.dart';
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

          const SizedBox(height: AppSpacing.lg),

          // ---- App information section ----
          Text('App information', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          BlocBuilder<AppInformationCubit, AppInformationState>(
            builder: (context, state) {
              final appInfo = state.appInfo;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Application name',
                    value: appInfo?.appName ?? 'Daily Stanza',
                  ),
                  _InfoRow(label: 'Version', value: _formatVersion(state)),
                ],
              );
            },
          ),
          _LinkRow(label: 'GitHub repository', url: AppLinks.githubRepository),
          _LinkRow(label: 'Privacy policy', url: AppLinks.privacyPolicy),
        ],
      ),
    );
  }

  String _formatVersion(AppInformationState state) {
    final appInfo = state.appInfo;
    if (appInfo == null) return '—';
    final build = appInfo.buildNumber;
    if (build.isEmpty) return appInfo.version;
    return 'Version ${appInfo.version} ($build)';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 48,
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});

  final String label;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final launcher = context.read<ExternalLinkLauncher>();
    return Semantics(
      button: true,
      label: '$label, opens in external browser',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minTileHeight: 48,
        title: Text(label, style: theme.textTheme.bodyLarge),
        trailing: Icon(
          Icons.open_in_new,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onTap: () => _launchLink(context, launcher),
      ),
    );
  }

  Future<void> _launchLink(
    BuildContext context,
    ExternalLinkLauncher launcher,
  ) async {
    final success = await launcher.launchUrl(url);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
    }
  }
}
