import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/core/theme/app_theme.dart';
import 'package:daily_stanza/core/router/app_router.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preference_ext.dart';

class App extends StatelessWidget {
  const App({required this.scaffoldMessengerKey, super.key});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemePreferencesCubit, ThemePreferencesState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: 'Daily Stanza',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: toThemeMode(themeState.preference),
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
