import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/core/widgets/scaffold_with_nav_bar.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_bloc.dart';
import 'package:daily_stanza/features/daily_poem/presentation/view/today_view.dart';
import 'package:daily_stanza/features/favourites/presentation/view/favourites_view.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_cubit.dart';
import 'package:daily_stanza/features/poem_details/presentation/view/poem_details_view.dart';
import 'package:daily_stanza/features/settings/settings_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Widget _poemDetailsBuilder(BuildContext context, GoRouterState state) {
  final id = state.pathParameters['id'] ?? '';
  return BlocProvider(
    create: (context) =>
        PoemDetailsCubit(repository: context.read<PoemRepository>())
          ..loadPoem(id),
    child: const PoemDetailsView(),
  );
}

List<RouteBase> _buildRoutes({GlobalKey<NavigatorState>? rootNavigatorKey}) {
  final rootKey = rootNavigatorKey ?? _rootNavigatorKey;
  return [
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
                  parentNavigatorKey: rootKey,
                  builder: _poemDetailsBuilder,
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
                  parentNavigatorKey: rootKey,
                  builder: _poemDetailsBuilder,
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
  ];
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/today',
  routes: _buildRoutes(),
);

/// Creates a fresh, isolated GoRouter instance with the same route
/// configuration.  Each call returns a fully independent router so
/// tests do not share navigation state.
GoRouter createRouter() {
  final key = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: key,
    initialLocation: '/today',
    routes: _buildRoutes(rootNavigatorKey: key),
  );
}
