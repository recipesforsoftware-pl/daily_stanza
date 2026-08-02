import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/core/theme/app_spacing.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:daily_stanza/features/onboarding/presentation/widgets/onboarding_choice_tile.dart';
import 'package:daily_stanza/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';
import 'package:daily_stanza/features/settings/domain/model/poem_language.dart';
import 'package:daily_stanza/features/settings/domain/model/theme_preference.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const int _pageCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.isCompleting) return;

    // The router redirect will move the user to /today once the cubit emits
    // a completed state.
    cubit.completeOnboarding();
  }

  String get _primaryButtonLabel {
    return _currentPage == _pageCount - 1 ? 'Start reading' : 'Continue';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              currentPage: _currentPage,
              pageCount: _pageCount,
              showSkip: _currentPage < _pageCount - 1,
              onSkip: _finish,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  _IntroPage(
                    title: 'Meet Stanzi',
                    body:
                        'Your friendly companion for a daily moment with poetry.',
                  ),
                  _IntroPage(
                    title: 'One poem every day',
                    body:
                        'Discover a carefully selected poem in English or Polish.',
                  ),
                  _LanguageStep(),
                  _ThemeStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PrimaryButton(
                        label: _primaryButtonLabel,
                        onPressed: _nextPage,
                        isLoading: state.isCompleting,
                      ),
                      if (_currentPage > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _BackButton(onPressed: _previousPage),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.currentPage,
    required this.pageCount,
    required this.showSkip,
    required this.onSkip,
  });

  final int currentPage;
  final int pageCount;
  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          OnboardingProgressDots(count: pageCount, activeIndex: currentPage),
          const Spacer(),
          if (showSkip)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: Text(
                'Skip',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: accent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.02,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          'Back',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/stanzi.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
              semanticLabel: 'Stanzi',
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/stanzi.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            semanticLabel: 'Stanzi',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Choose a language',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You can change this later in Settings.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<LanguagePreferencesCubit, LanguagePreferencesState>(
            builder: (context, state) {
              return Column(
                children: [
                  OnboardingChoiceTile(
                    icon: const Icon(Icons.format_align_left),
                    title: 'English',
                    subtitle: 'English-language poetry',
                    selected: state.language == PoemLanguage.english,
                    onTap: () {
                      context.read<LanguagePreferencesCubit>().changeLanguage(
                        PoemLanguage.english,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OnboardingChoiceTile(
                    icon: const Icon(Icons.format_align_center),
                    title: 'Polish',
                    subtitle: 'Polish poetry',
                    selected: state.language == PoemLanguage.polish,
                    onTap: () {
                      context.read<LanguagePreferencesCubit>().changeLanguage(
                        PoemLanguage.polish,
                      );
                    },
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

class _ThemeStep extends StatelessWidget {
  const _ThemeStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/stanzi.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            semanticLabel: 'Stanzi',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Make it yours',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Save favourites, share meaningful lines, and choose your reading theme.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<ThemePreferencesCubit, ThemePreferencesState>(
            builder: (context, state) {
              return Column(
                children: [
                  OnboardingChoiceTile(
                    icon: const Icon(Icons.brightness_auto),
                    title: 'System',
                    subtitle: 'Match device',
                    selected: state.preference == ThemePreference.system,
                    onTap: () {
                      context.read<ThemePreferencesCubit>().changeTheme(
                        ThemePreference.system,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OnboardingChoiceTile(
                    icon: const Icon(Icons.wb_sunny_outlined),
                    title: 'Light',
                    subtitle: 'Warm cream',
                    selected: state.preference == ThemePreference.light,
                    onTap: () {
                      context.read<ThemePreferencesCubit>().changeTheme(
                        ThemePreference.light,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OnboardingChoiceTile(
                    icon: const Icon(Icons.nights_stay_outlined),
                    title: 'Dark',
                    subtitle: 'Calm navy',
                    selected: state.preference == ThemePreference.dark,
                    onTap: () {
                      context.read<ThemePreferencesCubit>().changeTheme(
                        ThemePreference.dark,
                      );
                    },
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
