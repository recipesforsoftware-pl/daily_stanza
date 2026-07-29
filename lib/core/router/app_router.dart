import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/core/widgets/scaffold_with_nav_bar.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_bloc.dart';
import 'package:daily_stanza/features/daily_poem/presentation/view/today_view.dart';
import 'package:daily_stanza/features/favourites/presentation/view/favourites_view.dart';
import 'package:daily_stanza/features/settings/settings_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/today',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => BlocProvider(
                create: (context) =>
                    DailyPoemBloc(repository: context.read<PoemRepository>()),
                child: const TodayView(),
              ),
              routes: [
                GoRoute(
                  path: 'poem/:id',
                  builder: (context, state) => const _PoemPlaceholder(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favourites',
              builder: (context, state) => const FavouritesView(),
              routes: [
                GoRoute(
                  path: 'poem/:id',
                  builder: (context, state) => const _PoemPlaceholder(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsView(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _PoemPlaceholder extends StatelessWidget {
  const _PoemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Poem view — Phase 3')));
  }
}
