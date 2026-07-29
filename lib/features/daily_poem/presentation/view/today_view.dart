import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_bloc.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_event.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_state.dart';
import 'package:daily_stanza/features/daily_poem/presentation/widgets/daily_poem_content.dart';
import 'package:daily_stanza/features/daily_poem/presentation/widgets/daily_poem_status_view.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:daily_stanza/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_cubit.dart';
import 'package:daily_stanza/features/settings/presentation/cubit/language_preferences_state.dart';

class TodayView extends StatefulWidget {
  const TodayView({super.key, this.now});

  /// Override the current date for testability.
  final DateTime Function()? now;

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    final language = context.read<LanguagePreferencesCubit>().state.language;
    context.read<DailyPoemBloc>().add(
      DailyPoemRequested(date: _now, languageCode: language.code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguagePreferencesCubit, LanguagePreferencesState>(
      listenWhen: (previous, current) {
        return previous.language != current.language &&
            !current.isSaving &&
            current.mutationError == null;
      },
      listener: (context, state) {
        context.read<DailyPoemBloc>().add(
          DailyPoemRequested(date: _now, languageCode: state.language.code),
        );
      },
      child: Scaffold(
        body: BlocBuilder<DailyPoemBloc, DailyPoemState>(
          builder: (context, state) {
            return switch (state) {
              DailyPoemInitial() => const SizedBox.shrink(),
              DailyPoemLoading() => const DailyPoemStatusView(
                title: "Finding today's poem\u2026",
                subtitle: 'A calm moment while we look.',
              ),
              DailyPoemLoaded(:final poem, :final isFromCache) =>
                BlocBuilder<FavouritesCubit, FavouritesState>(
                  builder: (context, favState) {
                    final isFav =
                        favState is FavouritesLoaded &&
                        favState.isFavourite(poem.id);
                    final isUpdating =
                        favState is FavouritesLoaded &&
                        favState.updatingPoemIds.contains(poem.id);
                    return DailyPoemContent(
                      poem: poem,
                      isFromCache: isFromCache,
                      formattedDate: _formatDate(_now),
                      isFavourite: isFav,
                      isFavouriteUpdating: isUpdating,
                      onFavouriteToggle: () {
                        if (isFav) {
                          context.read<FavouritesCubit>().removeFavourite(
                            poem.id,
                          );
                        } else {
                          context.read<FavouritesCubit>().addFavourite(poem);
                        }
                      },
                      onReadFocusMode: () =>
                          context.push('/today/poem/${poem.id}'),
                    );
                  },
                ),
              DailyPoemMissing() => DailyPoemStatusView(
                title: "Today's poem is not available yet",
                subtitle: 'Please try again later.',
                showRetry: true,
                onRetry: () => context.read<DailyPoemBloc>().add(
                  const DailyPoemRetryRequested(),
                ),
              ),
              DailyPoemFailure(:final failureType) => DailyPoemStatusView(
                title: _failureTitle(failureType),
                subtitle: _failureSubtitle(failureType),
                showRetry: true,
                onRetry: () => context.read<DailyPoemBloc>().add(
                  const DailyPoemRetryRequested(),
                ),
              ),
            };
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _failureTitle(DailyPoemFailureType type) {
    return switch (type) {
      DailyPoemFailureType.network => "We couldn't load today's poem",
      DailyPoemFailureType.permission => 'This poem is currently unavailable',
      DailyPoemFailureType.unknown => 'Something went wrong',
    };
  }

  String _failureSubtitle(DailyPoemFailureType type) {
    return switch (type) {
      DailyPoemFailureType.network => 'Check your connection and try again.',
      DailyPoemFailureType.permission =>
        'This content is not available right now.',
      DailyPoemFailureType.unknown => 'Please try again.',
    };
  }
}
