import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/core/widgets/scaffold_with_nav_bar.dart';
import 'package:daily_stanza/features/today/today_view.dart';
import 'package:daily_stanza/features/favourites/favourites_view.dart';
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
              builder: (context, state) => const TodayView(),
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
