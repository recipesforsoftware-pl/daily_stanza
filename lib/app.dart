import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/core/theme/app_theme.dart';
import 'package:daily_stanza/core/router/app_router.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preferences_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/theme_preference_ext.dart';
import 'package:daily_stanza/features/share_poem/application/poem_share_text_builder.dart';
import 'package:daily_stanza/features/share_poem/data/service/share_plus_poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_state.dart';

class App extends StatelessWidget {
  App({
    required this.scaffoldMessengerKey,
    this.routerConfig,
    PoemShareService? shareService,
    super.key,
  }) : _shareService = shareService;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final GoRouter? routerConfig;
  final PoemShareService? _shareService;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PoemShareCubit>(
      create: (_) => PoemShareCubit(
        shareService: _shareService ?? SharePlusPoemShareService(),
        textBuilder: const PoemShareTextBuilder(),
      ),
      child: BlocListener<PoemShareCubit, PoemShareState>(
        listenWhen: (previous, current) {
          return current.mutationError != null &&
              current.mutationError != previous.mutationError;
        },
        listener: (context, state) {
          final error = state.mutationError;
          if (error == null) return;
          scaffoldMessengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error)));
        },
        child: BlocBuilder<ThemePreferencesCubit, ThemePreferencesState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              scaffoldMessengerKey: scaffoldMessengerKey,
              title: 'Daily Stanza',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: toThemeMode(themeState.preference),
              routerConfig: routerConfig ?? appRouter,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
