import 'package:flutter/material.dart';
import 'package:daily_stanza/core/theme/app_theme.dart';
import 'package:daily_stanza/core/router/app_router.dart';

class App extends StatelessWidget {
  const App({required this.scaffoldMessengerKey, super.key});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Daily Stanza',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
