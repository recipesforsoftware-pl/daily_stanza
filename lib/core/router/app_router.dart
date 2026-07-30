import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/core/widgets/scaffold_with_nav_bar.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_bloc.dart';
import 'package:daily_stanza/features/daily_poem/presentation/view/today_view.dart';
import 'package:daily_stanza/features/favourites/presentation/view/favourites_view.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:daily_stanza/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:daily_stanza/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:daily_stanza/features/onboarding/presentation/view/splash_screen.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_cubit.dart';
import 'package:daily_stanza/features/poem_details/presentation/view/poem_details_view.dart';
import 'package:daily_stanza/features/settings/domain/service/app_info_service.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/app_information_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/view/settings_view.dart';

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
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
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
              builder: (context, state) => BlocProvider(
                create: (context) => AppInformationCubit(
                  appInfoService: context.read<AppInfoService>(),
                )..load(),
                child: const SettingsView(),
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}

String? _onboardingRedirect(
  BuildContext context,
  GoRouterState state,
  OnboardingCubit cubit,
) {
  final onboardingState = cubit.state;
  final location = state.matchedLocation;
  final isSplash = location == '/splash';
  final isOnboarding = location == '/onboarding';

  // Stay on splash while onboarding status is still being resolved.
  if (onboardingState.status == OnboardingStatus.resolving) {
    if (!isSplash) return '/splash';
    return null;
  }

  final completed = onboardingState.completed;

  // Onboarding incomplete: only the onboarding route is reachable.
  if (!completed) {
    if (isOnboarding) return null;
    return '/onboarding';
  }

  // Onboarding complete: splash and onboarding redirect to Today.
  if (isSplash || isOnboarding) return '/today';

  // Any other route (including shell routes) is allowed once complete.
  return null;
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/today',
  routes: _buildRoutes(),
);

/// Creates a fresh, isolated GoRouter instance with the same route
/// configuration.  Each call returns a fully independent router so
/// tests do not share navigation state.
///
/// When [onboardingCubit] is provided, the router starts at
/// `/splash` and enforces first-launch onboarding redirects.
GoRouter createRouter({OnboardingCubit? onboardingCubit}) {
  final key = GlobalKey<NavigatorState>();

  ValueNotifier<OnboardingState?>? refreshNotifier;
  if (onboardingCubit != null) {
    refreshNotifier = ValueNotifier<OnboardingState?>(onboardingCubit.state);
    onboardingCubit.stream.listen((state) {
      refreshNotifier!.value = state;
    });
  }

  return GoRouter(
    navigatorKey: key,
    initialLocation: onboardingCubit != null ? '/splash' : '/today',
    refreshListenable: refreshNotifier,
    redirect: onboardingCubit != null
        ? (context, state) =>
              _onboardingRedirect(context, state, onboardingCubit)
        : null,
    routes: _buildRoutes(rootNavigatorKey: key),
  );
}
